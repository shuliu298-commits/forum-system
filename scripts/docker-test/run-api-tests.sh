#!/usr/bin/env bash
# 端到端 API 测试:对运行中的测试环境(http://localhost:8081)执行完整业务链路断言
# 覆盖:健康检查、帖子列表(Mock)、注册/登录、发帖、评论、更新、注销、鉴权
set -uo pipefail

BASE_URL="${1:-http://localhost:8081}"
REPORT_DIR="$(cd "$(dirname "$0")" && pwd)/report"
mkdir -p "$REPORT_DIR"

python3 - "$BASE_URL" "$REPORT_DIR" <<'PY'
import json
import sys
import time
import urllib.error
import urllib.request
import uuid

BASE = sys.argv[1]
REPORT_DIR = sys.argv[2]
FAILED = 0
CASES = []


def request(method, path, body=None, token=None, expect_code=0):
    """发送请求,断言业务 code == expect_code,返回 (data, status)"""
    url = BASE + path
    data = json.dumps(body).encode() if body is not None else None
    req = urllib.request.Request(url, data=data, method=method)
    req.add_header("Content-Type", "application/json")
    if token:
        req.add_header("Authorization", "Bearer " + token)
    try:
        with urllib.request.urlopen(req, timeout=10) as resp:
            payload = json.loads(resp.read().decode())
            status = resp.status
    except urllib.error.HTTPError as e:
        payload = json.loads(e.read().decode())
        status = e.code
    if payload.get("code") != expect_code:
        raise AssertionError(
            f"{method} {path}\n  expect code={expect_code}, got code={payload.get('code')} "
            f"message={payload.get('message')} (http {status})"
        )
    return payload.get("data"), status


def case(name, fn):
    global FAILED
    try:
        fn()
        print(f"  [PASS] {name}")
        CASES.append((name, "PASS", ""))
        return True
    except AssertionError as e:
        print(f"  [FAIL] {name}: {e}")
        CASES.append((name, "FAIL", str(e)))
        FAILED = 1
        return False


def wait_health(retries=30):
    for _ in range(retries):
        try:
            request("GET", "/api/health")
            return True
        except Exception:
            time.sleep(2)
    return False


def main():
    print(f"==> E2E 测试目标: {BASE}")
    if not wait_health():
        print("!! 服务未就绪")
        sys.exit(1)

    # 测试数据(时间戳保证可重复执行)
    suffix = uuid.uuid4().hex[:8]
    username = f"e2e_{suffix}"
    new_username = f"e2e_{suffix}_renamed"
    password = "123456"

    def t01_health():
        request("GET", "/api/health", expect_code=0)

    def t02_posts_mock():
        data, _ = request("GET", "/api/posts", expect_code=0)
        assert data["total"] >= 5, f"mock 数据不足: total={data['total']}"
        assert data["items"][0]["authorName"], "列表缺少作者字段"

    def t03_register():
        data, _ = request("POST", "/api/auth/register",
                          {"username": username, "password": password}, expect_code=0)
        assert data["username"] == username

    def t04_duplicate_register():
        request("POST", "/api/auth/register",
                {"username": username, "password": password}, expect_code=40901)

    def t05_login():
        data, _ = request("POST", "/api/auth/login",
                          {"username": username, "password": password}, expect_code=0)
        global token
        token = data["token"]
        assert token and data["userId"] and data["username"] == username

    def t06_login_wrong_password():
        request("POST", "/api/auth/login",
                {"username": username, "password": "wrongpass"}, expect_code=40101)

    def t07_create_post():
        data, _ = request("POST", "/api/posts",
                          {"title": "E2E 帖子", "content": "端到端测试内容"}, token=token, expect_code=0)
        global post_id
        post_id = data["id"]
        assert data["authorName"] == username

    def t08_add_comment():
        data, _ = request("POST", f"/api/posts/{post_id}/comments",
                          {"content": "E2E 评论"}, token=token, expect_code=0)
        global comment_id
        comment_id = data["id"]
        assert data["userName"] == username

    def t09_detail_contains_comment():
        data, _ = request("GET", f"/api/posts/{post_id}", expect_code=0)
        assert any(c["id"] == comment_id for c in data["comments"]), "详情中未找到评论"

    def t10_delete_comment():
        request("DELETE", f"/api/comments/{post_id}/{comment_id}", token=token, expect_code=0)
        data, _ = request("GET", f"/api/posts/{post_id}", expect_code=0)
        assert not any(c["id"] == comment_id for c in data["comments"]), "评论删除失败"

    def t11_update_user():
        request("PUT", f"/api/users/{uid}",
                {"username": new_username, "oldPassword": password}, token=token, expect_code=0)
        data, _ = request("GET", f"/api/users/{uid}", expect_code=0)
        assert data["username"] == new_username, "用户名未更新"

    def t12_unauthorized_create_post():
        request("POST", "/api/posts", {"content": "游客发帖"}, expect_code=40100)

    def t13_delete_other_user_post():
        # 用另一个账号尝试删除 mock 帖(作者为 Tom),应 403
        u2 = f"e2e_2_{suffix}"
        request("POST", "/api/auth/register", {"username": u2, "password": password}, expect_code=0)
        d2, _ = request("POST", "/api/auth/login", {"username": u2, "password": password}, expect_code=0)
        request("DELETE", "/api/posts/post-001", token=d2["token"], expect_code=40300)

    def t14_delete_user():
        request("DELETE", f"/api/users/{uid}", token=token, expect_code=0)
        request("GET", f"/api/users/{uid}", expect_code=40401)

    # 依赖顺序执行:注册 → 登录 → 发帖 → 评论 ...
    case("T01 健康检查", t01_health)
    case("T02 帖子列表(Mock 数据)", t02_posts_mock)
    case("T03 注册新用户", t03_register)
    case("T04 重复注册 → 40901", t04_duplicate_register)

    # 通过登录获取 uid 与 token
    def t05_login_inner():
        data, _ = request("POST", "/api/auth/login",
                          {"username": username, "password": password}, expect_code=0)
        global token, uid
        token = data["token"]
        uid = data["userId"]
    case("T05 登录成功", t05_login_inner)
    case("T06 密码错误 → 40101", t06_login_wrong_password)

    post_id = None
    case("T07 发帖(需登录)", t07_create_post)
    comment_id = None
    case("T08 发表评论", t08_add_comment)
    case("T09 详情包含评论", t09_detail_contains_comment)
    case("T10 删除评论", t10_delete_comment)
    case("T11 更新用户名", t11_update_user)
    case("T12 未登录发帖 → 40100", t12_unauthorized_create_post)
    case("T13 删除他人帖子 → 40300", t13_delete_other_user_post)
    case("T14 注销用户", t14_delete_user)

    # 输出报告
    report = {"target": BASE, "time": time.strftime("%Y-%m-%d %H:%M:%S"),
              "cases": [{"case": n, "result": r, "detail": d} for n, r, d in CASES],
              "total": len(CASES), "failed": FAILED}
    with open(f"{REPORT_DIR}/e2e-report.json", "w", encoding="utf-8") as f:
        json.dump(report, f, ensure_ascii=False, indent=2)

    print(f"\n==> 用例: {len(CASES)} 通过: {len(CASES) - FAILED} 失败: {FAILED}")
    print(f"==> 报告: {REPORT_DIR}/e2e-report.json")
    sys.exit(FAILED if FAILED else 0)


token = None
post_id = None
comment_id = None
uid = None

main()
PY

exit $?

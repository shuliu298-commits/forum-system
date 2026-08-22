package com.forum.common;

import org.springframework.http.HttpStatus;

/**
 * 业务错误码与 HTTP 状态码映射。
 */
public enum ErrorCode {

    SUCCESS(0, "success", HttpStatus.OK),
    PARAM_ERROR(40001, "参数校验失败", HttpStatus.BAD_REQUEST),
    UNAUTHORIZED(40100, "未登录或登录已失效", HttpStatus.UNAUTHORIZED),
    FORBIDDEN(40300, "无权执行该操作", HttpStatus.FORBIDDEN),
    NOT_FOUND(40401, "资源不存在", HttpStatus.NOT_FOUND),
    CONFLICT(40901, "用户名已存在", HttpStatus.CONFLICT),
    AUTH_FAILED(40101, "用户名或密码错误", HttpStatus.UNAUTHORIZED),
    INTERNAL_ERROR(50000, "服务器内部错误", HttpStatus.INTERNAL_SERVER_ERROR);

    private final int code;
    private final String message;
    private final HttpStatus httpStatus;

    ErrorCode(int code, String message, HttpStatus httpStatus) {
        this.code = code;
        this.message = message;
        this.httpStatus = httpStatus;
    }

    public int getCode() {
        return code;
    }

    public String getMessage() {
        return message;
    }

    public HttpStatus getHttpStatus() {
        return httpStatus;
    }
}

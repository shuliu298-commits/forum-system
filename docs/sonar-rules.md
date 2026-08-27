# Sonar 规则映射(Checkstyle / SpotBugs 覆盖)

本项目不单独部署 Sonar 服务(初版)。以下 Sonar 核心规则由
`docs/checkstyle.xml` + SpotBugs 配置映射覆盖,供人工 Review 参考:

| Sonar 规则 | 覆盖工具 | 说明 |
|---|---|---|
| Java:NamingConvention | Checkstyle | 类/方法/变量命名规范 |
| Java:EmptyBlock | Checkstyle | 禁止空代码块 |
| Java:UnusedImports | Checkstyle | 未使用导入 |
| Java:S00112 (未捕获异常) | Checkstyle | 禁止裸 throw new RuntimeException |
| Java:S107 (构造器参数过多) | SpotBugs | - |
| Java:S2259 (空指针解引用) | SpotBugs (NP_*) | 空指针风险 |
| Java:S1481 (未使用局部变量) | SpotBugs (URF_UNREAD_*) | 未使用字段 |
| Java:S1128 (未使用依赖) | SpotBugs | 未使用 import |
| Java:S2119 (静态随机数) | SpotBugs | 潜在 Bug |

执行方式:
- `scripts/lint/run-checkstyle.sh` → `mvn checkstyle:check`
- `scripts/lint/run-spotbugs.sh` → `mvn spotbugs:check`

> 后续若需要更严格的门禁,可引入 sonar-scanner + SonarQube 容器,规则集在此基础上扩展。

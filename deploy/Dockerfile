# 后端镜像:多阶段构建
# 构建上下文为 backend/(由 docker-compose 指定 context: ../backend)
FROM maven:3.9-eclipse-temurin-21 AS build
WORKDIR /build

# Maven Central 在 CI 构建高峰期可能返回 429,增大重试与超时以提升稳定性
ENV MAVEN_OPTS="-Dmaven.wagon.http.retryHandler.count=6 \
  -Dmaven.wagon.http.connectionTimeout=120000 \
  -Dmaven.wagon.http.readTimeout=120000"

COPY pom.xml .
RUN mvn -q -B dependency:go-offline || mvn -q -B dependency:resolve
COPY src ./src
RUN mvn -q -B package -DskipTests

FROM eclipse-temurin:21-jre
WORKDIR /app
COPY --from=build /build/target/forum-backend.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]

# 使用一个包含 JDK 11 的基础镜像
FROM openjdk:11-jre-slim

# 设置工作目录
WORKDIR /app

# 将构建好的 JAR 包从 target 目录复制到容器的 /app 目录
# JAR 包的名字需要和你 pom.xml 中的 <finalName> 匹配
COPY target/TestSpringApp-0.0.1-SNAPSHOT.jar app.jar

# 暴露应用配置的端口
EXPOSE 10456

# 容器启动时执行的命令
ENTRYPOINT ["java", "-jar", "app.jar"]
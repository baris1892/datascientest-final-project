# -----------------------------
# Build Stage
# -----------------------------
FROM eclipse-temurin:21-jdk AS build
WORKDIR /app

# Maven Wrapper + dependencies caching
COPY mvnw .
COPY .mvn .mvn
COPY pom.xml .
# Download dependencies first (better for caching)
RUN ./mvnw dependency:go-offline

COPY src src
RUN chmod +x ./mvnw
RUN ./mvnw clean package -DskipTests

# -----------------------------
# Run Stage
# -----------------------------
FROM eclipse-temurin:21-jre
WORKDIR /app
COPY --from=build /app/target/*.jar app.jar

EXPOSE 9966
ENTRYPOINT ["java","-jar","app.jar"]

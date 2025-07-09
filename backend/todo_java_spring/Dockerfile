FROM eclipse-temurin:17-jdk as build
WORKDIR /app
COPY . .
RUN ./mvnw clean package -DskipTests

FROM eclipse-temurin:17-jre
WORKDIR /app
COPY --from=build /app/target/*.jar app.jar
# COPY ../.env .env
ENV SPRING_CONFIG_IMPORT=optional:file:.env
EXPOSE 8080
CMD ["java", "-jar", "app.jar"]

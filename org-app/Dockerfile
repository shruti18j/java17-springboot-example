# Build
FROM maven:3.9-eclipse-temurin-17 AS build
WORKDIR /app
COPY pom.xml ../pom.xml
COPY ../pom.xml /project-root-pom.xml
# copy full project to build module with deps cached
COPY .. /project
WORKDIR /project/org-app
RUN mvn -q -DskipTests package

# Run
FROM eclipse-temurin:17-jre
WORKDIR /app
COPY --from=build /project/org-app/target/org-app-0.0.1-SNAPSHOT.jar app.jar
EXPOSE 8081
ENTRYPOINT ["java","-jar","/app/app.jar"]

# ── STAGE 1: Build ─────────────────────────────────────────
FROM maven:3.8-openjdk-8-slim AS builder

WORKDIR /app

# Copy pom.xml and source code
COPY pom.xml .
COPY src ./src

# Build the application
RUN mvn clean package -DskipTests

# ── STAGE 2: Run ──────────────────────────────────────────
FROM tomcat:9.0-jdk8-openjdk-slim

LABEL maintainer="Saurabh Singh Rajput"

# Remove default webapps to keep it clean
RUN rm -rf /usr/local/tomcat/webapps/*

# Copy the WAR from builder stage
COPY --from=builder /app/target/*.war /usr/local/tomcat/webapps/ROOT.war

EXPOSE 8080

CMD ["catalina.sh", "run"]
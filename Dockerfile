# syntax=docker/dockerfile:1

# ---------- Build stage ----------
FROM eclipse-temurin:17-jdk-jammy AS build
WORKDIR /workspace

# Version is supplied by the semantic-versioning / CI workflow.
ARG VERSION=0.0.0-dev

# Copy the wrapper + build config first so dependency resolution is cached
# independently of source changes.
COPY gradlew ./
COPY gradle ./gradle
COPY settings.gradle build.gradle gradle.properties ./
RUN chmod +x gradlew && ./gradlew --no-daemon --version

# Build the runnable jar. Tests run in the CI "build" job, so skip them here.
COPY src ./src
RUN ./gradlew --no-daemon clean build -x test -PappVersion="${VERSION}" \
 && cp build/libs/*.jar app.jar

# ---------- Runtime stage ----------
FROM eclipse-temurin:17-jre-jammy AS runtime
ARG VERSION=0.0.0-dev
LABEL org.opencontainers.image.title="hello-world" \
      org.opencontainers.image.description="Gradle Hello World with semantic versioning" \
      org.opencontainers.image.version="${VERSION}"
WORKDIR /app
RUN useradd --system --uid 10001 appuser
COPY --from=build /workspace/app.jar /app/app.jar
USER appuser
ENTRYPOINT ["java", "-jar", "/app/app.jar"]

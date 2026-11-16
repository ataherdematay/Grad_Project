# syntax=docker/dockerfile:1
# --- build ---
FROM eclipse-temurin:21-jdk AS build
WORKDIR /build
COPY .mvn .mvn
COPY mvnw pom.xml ./
RUN chmod +x mvnw && ./mvnw -B -q dependency:go-offline
COPY src src
RUN ./mvnw -B -q -DskipTests package && cp target/*.jar app.jar

# --- runtime ---
FROM eclipse-temurin:21-jre
# socat: the dev profile only starts on 127.0.0.1 (DevProfileGuard), so the app binds
# loopback inside the container and socat exposes it on 0.0.0.0:8091 for the port mapping.
RUN apt-get update && apt-get install -y --no-install-recommends socat \
    && rm -rf /var/lib/apt/lists/* \
    && useradd --system --uid 10001 --create-home bitadilat \
    && mkdir -p /app/data/media && chown -R bitadilat /app
WORKDIR /app
COPY --from=build /build/app.jar app.jar
COPY --chmod=755 <<'SH' /app/entrypoint.sh
#!/bin/sh
set -e
if [ "${SPRING_PROFILES_ACTIVE:-dev}" = "dev" ]; then
  socat TCP-LISTEN:8091,fork,reuseaddr TCP:127.0.0.1:${BITADILAT_PORT:-8090} &
fi
exec java $JAVA_OPTS -jar /app/app.jar
SH
USER bitadilat
# Profile and all secrets come from the environment (see docker-compose.yml / .env.example).
ENV SPRING_PROFILES_ACTIVE=dev \
    MEDIA_DIR=/app/data/media \
    JAVA_OPTS="-XX:MaxRAMPercentage=75"
EXPOSE 8091
# No actuator in this project: a TCP check on the exposed port is the health signal.
HEALTHCHECK --interval=10s --timeout=3s --start-period=60s --retries=6 \
  CMD bash -c 'exec 3<>/dev/tcp/127.0.0.1/8091' || exit 1
ENTRYPOINT ["/app/entrypoint.sh"]

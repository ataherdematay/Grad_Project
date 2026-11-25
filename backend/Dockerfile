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
# The dev profile refuses to start unless server.address is loopback (DevProfileGuard). In dev the app
# binds 127.0.0.1:8090 inside the container and socat publishes it on 0.0.0.0:8091 for the port mapping.
# Every connection through socat reaches the app from 127.0.0.1, so the loopback check on
# POST /api/v1/dev/reset is satisfied for anyone who can reach 8091: compose therefore publishes 8091
# on the host's loopback only. Any other profile (prod) runs without socat and the app binds
# 0.0.0.0:${BITADILAT_PORT:-8090} itself (application-prod.properties), so publish 8090 in that case.
RUN apt-get update && apt-get install -y --no-install-recommends socat \
    && rm -rf /var/lib/apt/lists/* \
    && useradd --system --uid 10001 --create-home bitadilat \
    && mkdir -p /app/data/media && chown -R bitadilat /app
WORKDIR /app
COPY --from=build /build/app.jar app.jar
COPY --chmod=755 <<'SH' /app/entrypoint.sh
#!/bin/sh
set -e
case ",${SPRING_PROFILES_ACTIVE:-dev}," in
  *,prod,*) ;;
  *,dev,*)
    socat TCP-LISTEN:8091,fork,reuseaddr TCP:127.0.0.1:${BITADILAT_PORT:-8090} &
    ;;
esac
exec java $JAVA_OPTS -jar /app/app.jar
SH
USER bitadilat
# Profile and all secrets come from the environment (see docker-compose.yml / .env.example;
# prod variables: docs/spec/PROD_CONFIG.md).
ENV SPRING_PROFILES_ACTIVE=dev \
    MEDIA_DIR=/app/data/media \
    JAVA_OPTS="-XX:MaxRAMPercentage=75"
EXPOSE 8090 8091
# No actuator in this project: a TCP check on the app's own port is the health signal. It checks the
# app port, not socat's 8091 (socat accepts connections even while the app is down). 127.0.0.1 works
# in both profiles (dev binds loopback, prod binds 0.0.0.0).
HEALTHCHECK --interval=10s --timeout=3s --start-period=60s --retries=6 \
  CMD bash -c 'exec 3<>/dev/tcp/127.0.0.1/${BITADILAT_PORT:-8090}' || exit 1
ENTRYPOINT ["/app/entrypoint.sh"]

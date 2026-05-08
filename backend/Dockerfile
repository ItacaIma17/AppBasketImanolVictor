# Dockerfile - Compila dentro del contenedor
FROM eclipse-temurin:17-jdk-alpine AS build

WORKDIR /app

# Instalar Maven
RUN apk add --no-cache maven

# Copiar el código fuente
COPY pom.xml .
COPY src ./src

# Descargar dependencias y compilar
RUN mvn clean package -DskipTests

# Etapa final
FROM eclipse-temurin:17-jre-alpine

WORKDIR /app

# Crear usuario no root
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

# Copiar el jar desde la etapa de build
COPY --from=build /app/target/*.jar app.jar

USER appuser

EXPOSE 8080

ENTRYPOINT ["java", "-jar", "app.jar"]
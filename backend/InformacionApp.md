# 📚 Documentación del Sistema de Autenticación y Usuarios

## Federación Aragonesa de Baloncesto

------------------------------------------------------------------------

## 📋 Índice

-   Arquitectura General\
-   Estructura de Datos\
-   Flujo de Registro\
-   API Endpoints\
-   Servicios\
-   Seguridad\
-   Guía de Uso

------------------------------------------------------------------------

## 🏗 Arquitectura General

El sistema sigue una arquitectura por capas con un diseño centralizado
para la autenticación pero especializado para la lógica de negocio de
cada rol.

    ┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
    │   Controllers   │ ──▶ │    Services     │ ──▶ │   Repositories  │ ──▶ │   Database   │
    └─────────────────┘     └─────────────────┘     └─────────────────┘
             │                       │                        │
             ▼                       ▼                        ▼
        API REST         Lógica de negocio      Acceso a datos (JPA)

### Principios de Diseño

-   **Single Responsibility**\
-   **Centralización de autenticación**\
-   **Especialización por rol**\
-   **DTOs con herencia**

------------------------------------------------------------------------

## 💾 Estructura de Datos

### Usuario

``` sql
CREATE TABLE usuarios (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    email VARCHAR(255) UNIQUE NOT NULL,
    username VARCHAR(255) UNIQUE NOT NULL,
    nombre VARCHAR(255),
    apellido VARCHAR(255),
    edad INT,
    password VARCHAR(255) NOT NULL,
    role VARCHAR(50) NOT NULL,
    verificado BOOLEAN DEFAULT FALSE,
    bloqueado BOOLEAN DEFAULT FALSE,
    token VARCHAR(500),
    refresh_token VARCHAR(500)
);
```

------------------------------------------------------------------------

## 🌐 API Endpoints

### UserController

Método   Endpoint     Descripción
  -------- ------------ ------------------
POST     /registro    Registro inicial
POST     /verificar   Verificar email
POST     /login       Login

------------------------------------------------------------------------

## 🛠 Servicios

### UserService

-   registrarInicial\
-   verificarCodigo\
-   login\
-   refreshToken\
-   logout

------------------------------------------------------------------------

## 🔐 Seguridad

-   BCrypt\
-   JWT\
-   Tokens con expiración

------------------------------------------------------------------------

## 📝 Guía de Uso

``` bash
POST /api/usuarios/registro
```

``` bash
POST /api/usuarios/login
```

------------------------------------------------------------------------

## 📞 Soporte

Última actualización: Marzo 2026

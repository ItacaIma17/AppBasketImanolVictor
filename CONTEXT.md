Actúa como un desarrollador full-stack senior especializado en debugging, arquitectura y corrección de aplicaciones web. Quiero que analices el código existente, identifiques la causa raíz de cada problema y apliques soluciones limpias sin romper funcionalidades ya existentes.

Reglas importantes:
- NO hagas parches rápidos ni soluciones temporales.
- Analiza frontend, backend, base de datos, modelos, validaciones, endpoints, permisos y estado.
- Revisa relaciones entre entidades y posibles errores de persistencia.
- Si hay lógica duplicada, unifícala.
- Mantén consistencia en nombres de campos y estructuras.
- Corrige tanto la lógica como la interfaz si es necesario.
- Añade validaciones y manejo de errores donde falten.
- Si una funcionalidad está mal implementada y eliminarla es mejor opción, indícalo.
- Tras cada corrección explica:
    1. causa del error
    2. solución aplicada
    3. archivos modificados
    4. posibles efectos secundarios

Problemas a corregir:

1. CREACIÓN DE LIGA
   Problema:
   Al crear una liga, el campo "temporada" no se guarda aunque el usuario la introduce.

Revisar:
- formulario frontend
- estado del formulario
- payload enviado
- endpoint
- modelo de liga
- persistencia en base de datos
- nombre exacto del campo (temporada/season/etc.)
- migraciones o schema

Objetivo:
La temporada debe guardarse correctamente y mostrarse después.

---

2. EDICIÓN DE LIGA

Problema:
Las ligas no se pueden editar.

Revisa si:
- faltan endpoints PUT/PATCH
- permisos
- errores en formularios
- rutas rotas

Si la edición está mal diseñada o no aporta valor:
elimina la funcionalidad completa (botón, rutas, lógica y referencias) sin romper la app.

---

3. EQUIPOS

Problema:
No se puede:
- crear equipos
- añadir equipos a una liga

Revisar:
- creación de equipo
- relaciones Liga ↔ Equipo
- tablas intermedias
- IDs
- endpoints
- permisos
- errores frontend/backend

Objetivo:
Un admin debe poder crear equipos y asociarlos a una liga sin errores.

---

4. RESULTADOS DE PARTIDOS

Problema:
El administrador no puede editar resultados.

Revisar:
- permisos admin
- endpoints update
- lógica de partidos
- restricciones
- estado del partido

Si esta funcionalidad está rota estructuralmente y eliminarla es mejor:
quítala completamente y limpia referencias.

---

5. BLOQUEAR Y DESBLOQUEAR USUARIOS

Problema:
No funcionan las acciones de bloquear/desbloquear usuarios.

Revisar:
- campo bloqueado/isBlocked/status
- lógica backend
- middleware
- permisos
- UI
- persistencia

Objetivo:
El admin debe poder bloquear y desbloquear usuarios correctamente.

---

6. CREACIÓN DE ENTRENADORES

Problema:
El administrador no puede crear entrenadores.

Revisar:
- roles
- permisos
- formulario
- endpoint
- creación de usuario
- asignación de rol entrenador
- validaciones

Objetivo:
El admin debe poder crear entrenadores correctamente.

---

Además:
Haz una auditoría general buscando errores relacionados con permisos, roles, relaciones rotas o campos que puedan estar causando varios problemas a la vez.

No te limites a corregir síntomas. Encuentra la causa raíz.

Entrega código final limpio y funcional.
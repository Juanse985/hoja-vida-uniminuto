# 001 — Login con correo institucional

**Estado:** aprobada

## Objetivo
Que solo los estudiantes con cuenta de Outlook `@uniminuto.edu.co` puedan entrar, y que al entrar encuentren su hoja de vida.

## Historias de usuario
- Como estudiante quiero entrar con mi correo institucional para no crear otra contraseña.
- Como estudiante quiero que mi hoja de vida aparezca donde la dejé cada vez que entro.

## Criterios de aceptación
1. **Dado** un visitante sin sesión, **cuando** abre cualquier página distinta de `/login`, **entonces** es redirigido a `/login`.
2. **Dado** un estudiante con cuenta `@uniminuto.edu.co`, **cuando** inicia sesión con Microsoft, **entonces** llega a `/hoja-vida`.
3. **Dado** un usuario con un correo de otro dominio (por ejemplo `@gmail.com` o `@outlook.com`), **cuando** intenta iniciar sesión, **entonces** ve "Solo se permiten cuentas institucionales @uniminuto.edu.co" y no se crea ningún registro.
4. **Dado** un estudiante que entra por primera vez, **cuando** termina el login, **entonces** existen su `Usuario` y una `HojaVida` en estado `BORRADOR`.
5. **Dado** un estudiante que ya había llenado datos, **cuando** vuelve a entrar, **entonces** el formulario abre en `ultimoPaso` con todos sus datos cargados.
6. **Dado** una sesión de más de 8 horas, **cuando** el estudiante hace cualquier petición, **entonces** se le pide iniciar sesión de nuevo.
7. Cada login exitoso queda en `Auditoria` con la acción `LOGIN`.

## Campos del Formato Único que toca
Ninguno directamente; crea la `HojaVida` vacía que contendrá las secciones 1 a 8.

## Impacto
- **Datos:** `Usuario`, `HojaVida`, `Auditoria`.
- **API:** `/api/auth/[...nextauth]`, `GET /api/hoja-vida`.
- **Interfaz:** `/login` con el botón "Ingresar con correo institucional" y los mensajes de error.

## Fuera de alcance
- Roles de administrador.
- Login con Google o con usuario y contraseña.

## Preguntas abiertas
- ¿TI de UNIMINUTO puede registrar la app en su tenant (single-tenant)? Mientras tanto se usa `common` con filtro de dominio.

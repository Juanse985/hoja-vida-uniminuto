# Arquitectura — Sistema de Hoja de Vida UNIMINUTO

Documento completo (con diagrama): https://claude.ai/artifact/Jg2X3pS16HfmNeWHj36w6m

## Resumen para los agentes
- **Capas:** navegador (Next.js + React) → API (Next.js Route Handlers) → PostgreSQL (Supabase) y Storage privado. El login lo hace Microsoft Entra ID.
- **Login:** OIDC con Microsoft 365; solo `@uniminuto.edu.co` y el tenant de UNIMINUTO. Primer ingreso crea `Usuario` + `HojaVida` en `BORRADOR`.
- **Datos:** un modelo Prisma por sección del Formato Único (ver `prisma/schema.prisma`). Secciones repetibles = relaciones 1 a N. La sección 7 se calcula a partir de 5 y 6.
- **Guardado:** autoguardado por sección (debounce 2 s, `PUT`), control de `version` (409 en conflicto), respaldo en `localStorage` sin conexión.
- **Carga:** `GET /api/hoja-vida` devuelve todo; el formulario abre en `ultimoPaso`.
- **PDF:** `@react-pdf/renderer`, 4 páginas, numeración y códigos del Formato Único; la sección 9 se imprime vacía.
- **Plantilla UNIMINUTO:** tabla `Plantilla` (logo, encabezado, secciones visibles, definición de campos extra); valores extra en `HojaVida.camposAdicionales`.
- **Seguridad:** `usuario_id` solo desde la sesión, Zod en servidor, RLS, cifrado de documento y libreta, URLs firmadas, auditoría, habeas data (Ley 1581 de 2012).

## Catálogo oficial (base de datos extra + API)
- **Fuente obligatoria:** colegios del MEN en datos.gov.co (`cfw5-qzt5`). Opcional: IES del SNIES (`n5yy-8nav`). Configuración en `config/fuentes.json`.
- **Base propia:** `CATALOGO_DATABASE_URL`, esquema `prisma/catalogo/schema.prisma`. Tablas `fuente`, `carga` (bitácora y linaje), `colegio` e `institucion_superior` (SCD tipo 2: una fila por versión, llave sustituta, `vigente_desde`, `vigente_hasta`, `es_actual`) y `cliente_api`.
- **Actualización diaria (Write → Audit → Publish):** se compara `rowsUpdatedAt`; descarga por páginas con `$select` a bronce + SHA-256; se deduplica por `codigo_dane` (año más reciente); se audita (columnas, patrón de 12 dígitos, < 2 % sin llave, caída < 20 %); se publica en una sola transacción. Si se rechaza, sigue la versión anterior.
- **API:** `/api/catalogo/v1` con `X-Api-Key`; contrato en `docs/openapi-catalogo.yaml`.
- **Conexión:** la hoja de vida guarda `colegio_codigo_dane`, `colegio_version_id` y el nombre copiado del catálogo, con estado `VERIFICADO`, `VERIFICADO_CON_SOPORTE` o `SIN_FUENTE`. El colegio es obligatorio para completar la hoja de vida.
- **Recarga:** `npm run catalogo:recargar` reconstruye el catálogo desde bronce sin tocar hojas de vida.

## API
| Método | Ruta | Qué hace |
| --- | --- | --- |
| GET / POST | `/api/auth/[...nextauth]` | Login Microsoft |
| GET | `/api/hoja-vida` | Hoja de vida completa |
| PUT | `/api/hoja-vida/{seccion}` | datos-personales, educacion-basica, declaracion |
| POST | `/api/hoja-vida/{coleccion}` | educacion-superior, educacion-trabajo, idiomas, experiencia-laboral, experiencia-docente |
| PUT / DELETE | `/api/hoja-vida/{coleccion}/{id}` | Editar / borrar registro |
| POST | `/api/hoja-vida/completar` | Validar y marcar COMPLETA |
| GET | `/api/hoja-vida/pdf` | PDF en Formato Único |
| POST | `/api/soportes/url-subida` | URL firmada de subida |
| DELETE | `/api/soportes/{id}` | Borrar soporte |
| GET | `/api/catalogos/{tipo}` | Países, departamentos, municipios (DIVIPOLA) |

# 002 — Catálogo oficial de colegios (base de datos extra + API)

**Estado:** aprobada

## Objetivo
Que el colegio de cada hoja de vida se elija de un catálogo oficial (Ministerio de Educación, datos.gov.co `cfw5-qzt5`) que vive en su propia base de datos, se actualiza solo y se consulta únicamente por API.

## Historias de usuario
- Como estudiante quiero buscar mi colegio por nombre y municipio para no escribirlo a mano.
- Como evaluador quiero saber que cada colegio de una hoja de vida existe en el registro oficial.
- Como administrador quiero que el catálogo se actualice solo y poder ver de qué carga salió cada dato.

## Criterios de aceptación

### Ingesta (Write → Audit → Publish)
1. **Dado** que `rowsUpdatedAt` de `cfw5-qzt5` no cambió desde la última carga publicada, **cuando** corre `npm run catalogo:actualizar`, **entonces** no descarga nada y registra una carga `SIN_CAMBIOS`.
2. **Dado** que la fuente cambió, **cuando** corre la actualización, **entonces** descarga por páginas de 50.000 filas pidiendo solo las columnas de `config/fuentes.json` y guarda los archivos en `bronce/colegios_men/<fecha>/` con su SHA-256.
3. La descarga solo pide las columnas de la lista blanca: nunca trae rector, teléfono, fax ni correo del colegio.
4. **Dado** un archivo con el mismo SHA-256 que la última carga, **entonces** termina como `SIN_CAMBIOS`.
5. Cada `codigo_dane` queda una sola vez, con el `a_o` más reciente.
6. **Dado** que la auditoría falla (columna obligatoria ausente, código que no tiene 12 dígitos en más del 2 %, o caída de filas mayor al 20 %), **entonces** la carga queda `RECHAZADA` con el motivo en `errores`, y el catálogo sigue con la versión anterior.
7. **Dado** un colegio nuevo, **entonces** se inserta con `es_actual = true`.
8. **Dado** un colegio cuyos atributos cambiaron, **entonces** su versión vigente se cierra (`vigente_hasta`, `es_actual = false`) y se inserta una versión nueva. El nombre anterior sigue consultable.
9. **Dado** un colegio que ya no aparece en la fuente, **entonces** se cierra su versión y nunca se borra.
10. La publicación ocurre en una sola transacción: entra completa o no entra nada.
11. Nunca hay dos versiones vigentes del mismo `codigo_dane` (índice único parcial).

### API
12. Toda ruta de `/api/catalogo/v1` responde 401 sin `X-Api-Key` válida.
13. `GET /colegios?q=san jose&municipio=11001` devuelve como máximo 20 colegios vigentes, ordenados por similitud, ignorando tildes y mayúsculas.
14. `GET /colegios/{codigoDane}` devuelve 404 si el código no existe.
15. `GET /colegios/{codigoDane}/versiones` devuelve todas las versiones, la vigente primero.
16. Las respuestas cumplen `docs/openapi-catalogo.yaml`.

### Conexión con la hoja de vida
17. El navegador nunca llama al catálogo: busca por `GET /api/catalogos/colegios`, que reenvía la consulta desde el servidor con la llave.
18. **Dado** que el estudiante elige un colegio, **cuando** se guarda la sección 2, **entonces** el backend vuelve a consultar `GET /colegios/{codigoDane}` y guarda código, `versionId`, nombre y municipio copiados del catálogo, con estado `VERIFICADO`. Ignora cualquier nombre que mande el navegador.
19. **Dado** que el estudiante marca "Mi colegio no aparece" y sube el diploma, **entonces** se guarda con estado `VERIFICADO_CON_SOPORTE` y la hoja de vida no se bloquea.
20. **Dado** que la API del catálogo no responde, **entonces** se guarda con estado `SIN_FUENTE` y se vuelve a verificar en la siguiente carga publicada.
21. El colegio es obligatorio: no se puede marcar la hoja de vida como `COMPLETA` si el estado de verificación es `PENDIENTE`.

### Operación
22. `npm run catalogo:recargar` vacía la base del catálogo y la reconstruye desde bronce, sin tocar la base de hojas de vida. Con `--forzar` vuelve a descargar.
23. El workflow `catalogo-actualizar.yml` corre todos los días a las 3:00 a. m. (hora de Colombia) y se puede lanzar a mano.

## Campos del Formato Único que toca
| Sección | Campo | Tipo | Obligatorio |
| --- | --- | --- | --- |
| 2. Educación básica y media | Colegio (código DANE + nombre) | Referencia al catálogo | Sí (ajuste UNIMINUTO) |
| 2. Educación básica y media | Estado de verificación | `EstadoVerificacion` | Sí |

## Impacto
- **Datos:** nueva base `catalogo` (`prisma/catalogo/schema.prisma` + `sql/indices.sql`); campos nuevos en `EducacionBasica` y `EducacionSuperior`.
- **API:** nueva `/api/catalogo/v1/*` (contrato en `docs/openapi-catalogo.yaml`); `/api/catalogos/colegios` en la hoja de vida.
- **Interfaz:** buscador con autocompletar en la sección 2; opción "Mi colegio no aparece".
- **Operación:** `.github/workflows/catalogo-actualizar.yml`; scripts `catalogo:actualizar` y `catalogo:recargar`.

## Fuera de alcance
- IES del SNIES (spec 003, mismo patrón; primero hay que confirmar sus columnas).
- Empresas (RUES) y entidades públicas.

## Preguntas abiertas
- ¿El catálogo debe exponerse también a otras aplicaciones de UNIMINUTO?

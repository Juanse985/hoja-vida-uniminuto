# Hoja de Vida UNIMINUTO — reglas del proyecto

Aplicación web donde cada estudiante de UNIMINUTO inicia sesión con su correo institucional (Outlook / Microsoft 365), diligencia su hoja de vida en el **Formato Único de Hoja de Vida** (Leyes 190 de 1995, 489 y 443 de 1998) con los ajustes de UNIMINUTO, y la encuentra guardada cada vez que vuelve.

Arquitectura completa: `docs/arquitectura.md`. Léela antes de cualquier tarea que toque más de un módulo.

## Stack (no cambiar sin una spec aprobada)
- Next.js 15 (App Router) + TypeScript estricto
- Auth.js v5 con proveedor Microsoft Entra ID
- PostgreSQL (Supabase) + Prisma
- React Hook Form + Zod (el mismo esquema en cliente y servidor)
- @react-pdf/renderer para el PDF
- Vitest (unitarias) + Playwright (E2E)
- Despliegue en Vercel; CI en GitHub Actions

## Reglas que NINGÚN agente puede romper
1. **Solo cuentas `@uniminuto.edu.co`.** El callback `signIn` de Auth.js rechaza cualquier otro dominio y cualquier `tid` distinto de `AZURE_AD_TENANT_ID`.
2. **El `usuario_id` sale siempre de la sesión** (`auth()`), nunca de la URL, query string ni body.
3. **Todo dato que entra se valida con Zod en el servidor**, aunque ya se haya validado en el cliente.
4. **El PDF respeta el Formato Único**: misma numeración de secciones (1 a 9), mismos códigos (TC, TL, TE, UN, ES, MG, DOC, INF, TR_DES, R/B/MB).
5. **La sección 7 (tiempo total de experiencia) se calcula**, no se guarda.
6. **Habeas data (Ley 1581 de 2012):** no se guarda nada antes de que el usuario acepte la autorización.
7. **Secretos solo en variables de entorno.** Nunca leer, imprimir ni commitear `.env*`.
8. **Textos de interfaz en español**; código (nombres de variables y funciones) en español sin tildes.
9. **El catálogo oficial es otra base de datos.** La hoja de vida NUNCA consulta las tablas del catálogo: solo usa `/api/catalogo/v1` con `X-Api-Key`, según `docs/openapi-catalogo.yaml`. Dos esquemas Prisma: `prisma/schema.prisma` (hojas de vida) y `prisma/catalogo/schema.prisma` (catálogo).
10. **El nombre del colegio se copia del catálogo**, nunca del navegador. El colegio es obligatorio para marcar la hoja de vida como `COMPLETA`.
11. **El catálogo es SCD tipo 2:** nunca `UPDATE` de atributos ni `DELETE` de filas; se cierra la versión vigente y se inserta una nueva. La publicación va en una sola transacción y solo después de pasar la auditoría (Write → Audit → Publish).
12. **Minimización:** de datos.gov.co solo se piden las columnas de `config/fuentes.json` (`$select`). El catálogo no guarda datos personales.

## Convenciones
- Rutas de API en `src/app/api/**/route.ts`; lógica de negocio en `src/lib/`, nunca en los handlers.
- Un esquema Zod por sección en `src/lib/validaciones/<seccion>.ts`.
- Componentes del formulario en `src/components/formulario/<seccion>/`.
- Ramas: `feat/NNN-nombre`, `fix/NNN-nombre`. Commits en español, en imperativo.
- Cada funcionalidad nace de una spec en `specs/NNN-nombre.md`.

## La fábrica (flujo obligatorio)
`/spec` → `/plan` → `/implementar` → `/probar` → `/revisar` → `/entregar`

No saltes estaciones. Si una estación falla, vuelve a la anterior.

## Comandos útiles
- `npm run dev` — servidor local
- `npm run lint` · `npm run typecheck` · `npm test` · `npm run test:e2e`
- `npx prisma migrate dev --name <nombre>` — nueva migración (nunca `migrate reset`)
- `npx prisma migrate dev --schema prisma/catalogo/schema.prisma --name <nombre>` — migración del catálogo
- `npm run catalogo:actualizar -- --fuente colegios_men [--forzar]` — Write → Audit → Publish
- `npm run catalogo:recargar` — vacía el catálogo y lo reconstruye desde bronce (no toca hojas de vida)

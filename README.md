# Hoja de Vida UNIMINUTO

Sistema web para que los estudiantes de UNIMINUTO diligencien su hoja de vida en el Formato Único (Función Pública, con ajustes UNIMINUTO), con login por correo institucional de Outlook y guardado automático.

- Arquitectura: [`docs/arquitectura.md`](docs/arquitectura.md)
- Reglas para agentes y humanos: [`CLAUDE.md`](CLAUDE.md)

## El harness (fábrica de software)

Este repositorio está preparado para construirse con **Claude Code** como fábrica: cada funcionalidad entra como requisito y sale como PR probado y revisado.

```
requisito ──/spec──▶ spec ──/plan──▶ plan ──/implementar──▶ código
   ──/probar──▶ pruebas en verde ──/revisar──▶ APROBADO ──/entregar──▶ PR + vista previa
```

| Pieza | Dónde | Para qué |
| --- | --- | --- |
| Reglas del proyecto | `CLAUDE.md` | Lo que ningún agente puede romper |
| Agentes | `.claude/agents/` | arquitecto, backend, frontend, qa, revisor-seguridad |
| Estaciones | `.claude/commands/` | `/spec` `/plan` `/implementar` `/probar` `/revisar` `/entregar` |
| Controles automáticos | `.claude/settings.json` + `.claude/hooks/` | Bloquea comandos peligrosos, formatea al editar, exige tipos y pruebas al terminar |
| Herramientas externas | `.mcp.json` | Postgres (solo lectura), GitHub, Playwright |
| Entrada de la fábrica | `specs/` | Una spec por funcionalidad |
| Línea de calidad | `.github/workflows/ci.yml` | lint, tipos, pruebas, E2E y build en cada PR |

### Cómo usarlo
1. Instala Claude Code y `jq`; clona el repo y corre `npm install`.
2. Copia `.env.example` a `.env.local` y llena los valores.
3. Abre `claude` en la raíz del repo.
4. Ejemplo de ciclo completo:
   ```
   /spec El estudiante puede agregar varios estudios de educación superior con modalidad TC, TL, TE, UN, ES, MG o DOC
   /plan 002
   /implementar 002
   /probar 002
   /revisar
   /entregar
   ```

La spec `001-login-institucional` ya está aprobada y lista para `/plan 001`.

## Backlog sugerido de specs
| # | Funcionalidad |
| --- | --- |
| 001 | Login con correo institucional ✅ spec aprobada |
| 002 | Catálogo oficial de colegios: BD extra + API + actualización diaria ✅ spec aprobada |
| 003 | Catálogo de IES (SNIES), mismo patrón que 002 |
| 004 | Sección 1 — Datos personales con autoguardado |
| 005 | Sección 2 — Educación básica, media y superior (conectada al catálogo) |
| 006 | Sección 3 — Educación para el trabajo |
| 007 | Sección 4 — Idiomas |
| 008 | Secciones 5 y 6 — Experiencia laboral y docente |
| 009 | Sección 7 — Cálculo automático de tiempo de experiencia |
| 010 | Sección 8 — Declaración, habeas data y firma |
| 011 | Generación del PDF en Formato Único |
| 012 | Soportes (foto y certificados) |
| 013 | Plantilla UNIMINUTO (logo y campos extra) |

## Dos servicios, dos bases de datos
| Servicio | Base de datos | Esquema | Contrato |
| --- | --- | --- | --- |
| Hoja de vida | `DATABASE_URL` | `prisma/schema.prisma` | rutas `/api/hoja-vida/*` |
| Catálogo oficial | `CATALOGO_DATABASE_URL` | `prisma/catalogo/schema.prisma` | `docs/openapi-catalogo.yaml` |

La hoja de vida solo habla con el catálogo por su API. El catálogo se actualiza con `.github/workflows/catalogo-actualizar.yml` (diario) usando las fuentes de `config/fuentes.json`.

---
description: Estación 6 — abre el PR de la rama actual con el resumen de la spec
---

Antes de nada confirma que `/probar` y `/revisar` pasaron en esta rama. Si no, detente.

1. Corre `npm run lint`, `npm run typecheck` y `npm test -- --run`. Si algo falla, detente.
2. Sube la rama con `git push -u origin HEAD`.
3. Abre un PR con `gh pr create`:
   - Título: `[NNN] <objetivo de la spec>`
   - Cuerpo: enlace a la spec, criterios de aceptación con su estado, tabla de pruebas de `/probar`, veredicto de `/revisar`.
4. Muéstrame la URL del PR. GitHub Actions corre el CI y Vercel publica la vista previa.

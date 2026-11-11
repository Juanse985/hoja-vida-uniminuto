---
description: Estación 3 — implementa el plan de una spec en una rama nueva
argument-hint: <NNN de la spec>
---

Implementa el `## Plan` de `specs/$ARGUMENTS-*.md`.

1. Crea la rama `feat/$ARGUMENTS-<nombre-de-la-spec>` desde `main`.
2. Delega las tareas de servidor al subagente `backend` y las de interfaz al subagente `frontend`. Si son independientes, lánzalos en paralelo.
3. Haz un commit por tarea terminada, en español y en imperativo.
4. Al final, lista cada criterio de aceptación y qué archivos lo implementan.

No escribas pruebas aquí; eso es `/probar`.

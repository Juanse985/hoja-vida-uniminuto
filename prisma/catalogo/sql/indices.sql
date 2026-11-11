-- Índices que Prisma no puede declarar. Se agregan a la primera migración del catálogo.

-- SCD tipo 2: solo una versión vigente por colegio / institución
CREATE UNIQUE INDEX IF NOT EXISTS colegio_vigente_unico
  ON colegio (codigo_dane) WHERE es_actual = true;

CREATE UNIQUE INDEX IF NOT EXISTS ies_vigente_unica
  ON institucion_superior (codigo_snies) WHERE es_actual = true;

-- Búsqueda por similitud para el autocompletar (extensión pg_trgm)
CREATE EXTENSION IF NOT EXISTS pg_trgm;
CREATE INDEX IF NOT EXISTS colegio_nombre_trgm
  ON colegio USING gin (nombre_normalizado gin_trgm_ops) WHERE es_actual = true;

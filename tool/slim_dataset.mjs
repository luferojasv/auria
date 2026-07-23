/**
 * Reduce exercises.json (16.6 MB, 10 idiomas) al subconjunto que la app necesita.
 *
 * Descarta:
 *   - `category`      -> duplicado exacto de `body_part`
 *   - `instructions`  -> prosa redundante, es el join de instruction_steps
 *   - los 9 idiomas que no usamos
 *   - `image` / `gif_url` -> derivables de {id}-{media_id}
 *   - `created_at`, `attribution` -> la atribucion va una sola vez en la cabecera
 *
 * Uso:  node tool/slim_dataset.mjs <entrada.json> <salida.json>
 */
import { readFileSync, writeFileSync, mkdirSync } from 'node:fs';
import { dirname } from 'node:path';

const [, , inPath, outPath] = process.argv;
if (!inPath || !outPath) {
  console.error('uso: node tool/slim_dataset.mjs <entrada.json> <salida.json>');
  process.exit(1);
}

const raw = JSON.parse(readFileSync(inPath, 'utf8'));
console.log(`entrada : ${raw.length} ejercicios`);

const issues = { sinPasosEs: [], mediaNoDerivable: [], categoryDistinta: [] };

const exercises = raw.map((e) => {
  const pasos = e.instruction_steps?.es ?? [];
  if (pasos.length === 0) issues.sinPasosEs.push(e.id);
  if (e.category !== e.body_part) issues.categoryDistinta.push(e.id);

  // Verificamos que la ruta de media sea reconstruible antes de tirarla.
  const esperado = `images/${e.id}-${e.media_id}.jpg`;
  if (e.image !== esperado) issues.mediaNoDerivable.push({ id: e.id, real: e.image, esperado });

  return {
    id: e.id,
    name: e.name,
    bodyPart: e.body_part,
    equipment: e.equipment,
    target: e.target,
    muscleGroup: e.muscle_group ?? null,
    secondary: e.secondary_muscles ?? [],
    mediaId: e.media_id,
    // Pasos en espanol; si faltaran, caemos a ingles para no dejar la ficha vacia.
    steps: pasos.length > 0 ? pasos : (e.instruction_steps?.en ?? []),
    stepsLang: pasos.length > 0 ? 'es' : 'en',
  };
});

const vocab = (campo) => [...new Set(exercises.map((e) => e[campo]).filter(Boolean))].sort();

const salida = {
  version: 1,
  source: 'https://github.com/hasaneyldrm/exercises-dataset',
  mediaAttribution: '© Gym visual — https://gymvisual.com/',
  mediaBase: 'https://cdn.jsdelivr.net/gh/hasaneyldrm/exercises-dataset@main',
  count: exercises.length,
  vocab: {
    bodyPart: vocab('bodyPart'),
    equipment: vocab('equipment'),
    target: vocab('target'),
    muscleGroup: vocab('muscleGroup'),
  },
  exercises,
};

mkdirSync(dirname(outPath), { recursive: true });
writeFileSync(outPath, JSON.stringify(salida), 'utf8');

const mb = (p) => (readFileSync(p).length / 1024 / 1024).toFixed(2);
console.log(`salida  : ${outPath}`);
console.log(`tamano  : ${mb(inPath)} MB -> ${mb(outPath)} MB`);
console.log(`vocab   : bodyPart=${salida.vocab.bodyPart.length} equipment=${salida.vocab.equipment.length} target=${salida.vocab.target.length} muscleGroup=${salida.vocab.muscleGroup.length}`);
console.log('--- verificaciones ---');
console.log(`sin pasos en espanol      : ${issues.sinPasosEs.length}` + (issues.sinPasosEs.length ? ` -> ${issues.sinPasosEs.slice(0, 10).join(', ')}` : ''));
console.log(`category != body_part     : ${issues.categoryDistinta.length}`);
console.log(`media no derivable de id  : ${issues.mediaNoDerivable.length}`);
if (issues.mediaNoDerivable.length) {
  console.log('  ejemplos:', JSON.stringify(issues.mediaNoDerivable.slice(0, 5), null, 2));
}

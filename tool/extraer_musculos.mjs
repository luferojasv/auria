/**
 * Extrae los paths SVG de MuscleMapJS (MIT, abdofallah/MuscleMapJS) a un JSON
 * que Flutter dibuja con CustomPainter.
 *
 * De cada músculo tomamos slug + todos sus paths (common/left/right juntos).
 * Solo el modelo masculino, vista frontal y trasera — suficiente para resaltar
 * los músculos que trabaja un ejercicio.
 *
 * Uso: node tool/extraer_musculos.mjs <dir_con_los_ts> <salida.json>
 */
import { readFileSync, writeFileSync, mkdirSync } from 'node:fs';
import { dirname, join } from 'node:path';

const [, , dirTs, outPath] = process.argv;
if (!dirTs || !outPath) {
  console.error('uso: node tool/extraer_musculos.mjs <dir_ts> <salida.json>');
  process.exit(1);
}

function cargar(archivo) {
  let txt = readFileSync(join(dirTs, archivo), 'utf8');
  // Quitar imports de tipos y anotación de tipo del export, dejarlo evaluable.
  txt = txt.replace(/import[^;]*;/g, '');
  txt = txt.replace(/export const \w+\s*:\s*[^=]+=/, 'return ');
  // eslint-disable-next-line no-new-func
  return new Function(txt)();
}

function aMapa(arr) {
  const m = {};
  for (const bp of arr) {
    const paths = [
      ...(bp.common ?? []),
      ...(bp.left ?? []),
      ...(bp.right ?? []),
    ].filter((p) => typeof p === 'string' && p.trim());
    if (paths.length) m[bp.slug] = paths;
  }
  return m;
}

const front = aMapa(cargar('male-front-paths.ts'));
const back = aMapa(cargar('male-back-paths.ts'));

const salida = {
  source: 'https://github.com/abdofallah/MuscleMapJS (MIT)',
  front,
  back,
};

mkdirSync(dirname(outPath), { recursive: true });
writeFileSync(outPath, JSON.stringify(salida));

const kb = (readFileSync(outPath).length / 1024).toFixed(1);
console.log(`salida: ${outPath} (${kb} KB)`);
console.log(`front: ${Object.keys(front).length} músculos -> ${Object.keys(front).join(', ')}`);
console.log(`back:  ${Object.keys(back).length} músculos -> ${Object.keys(back).join(', ')}`);

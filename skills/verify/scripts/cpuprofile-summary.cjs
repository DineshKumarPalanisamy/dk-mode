// Summarize a .cpuprofile: top functions by self time and by total (inclusive) time.
// Usage: node summarize.cjs <file.cpuprofile> [top]
const fs = require('node:fs');
const prof = JSON.parse(fs.readFileSync(process.argv[2], 'utf8'));
const top = Number(process.argv[3] || 20);
const byId = new Map(prof.nodes.map((n) => [n.id, n]));
const parent = new Map();
for (const n of prof.nodes) for (const c of n.children || []) parent.set(c, n.id);

const self = new Map();
const dts = prof.timeDeltas;
prof.samples.forEach((id, i) => self.set(id, (self.get(id) || 0) + (dts[i + 1] || 0)));

const key = (n) => {
  const f = n.callFrame;
  const file = (f.url || '').split('/').pop().split('?')[0];
  return `${f.functionName || '(anon)'} ${file}:${f.lineNumber + 1}`;
};
const selfBy = new Map();
const totalBy = new Map();
for (const [id, t] of self) {
  const n = byId.get(id);
  selfBy.set(key(n), (selfBy.get(key(n)) || 0) + t);
  const seen = new Set();
  for (let cur = id; cur !== undefined; cur = parent.get(cur)) {
    const k = key(byId.get(cur));
    if (seen.has(k)) continue;
    seen.add(k);
    totalBy.set(k, (totalBy.get(k) || 0) + t);
  }
}
const ms = (us) => (us / 1000).toFixed(0).padStart(7) + ' ms';
const total = [...self.values()].reduce((a, b) => a + b, 0);
console.log(`profile span ${ms(total)}`);
console.log('--- self time');
[...selfBy].sort((a, b) => b[1] - a[1]).slice(0, top).forEach(([k, t]) => console.log(ms(t), k));
console.log('--- total time (app and grid code only)');
[...totalBy].filter(([k]) => /ng-grid|base-model|discounts|vis-|angular\.js|\.js:/.test(k) && !/^\((root|program|idle)\)/.test(k))
  .sort((a, b) => b[1] - a[1]).slice(0, top).forEach(([k, t]) => console.log(ms(t), k));

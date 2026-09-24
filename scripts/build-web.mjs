// Bundles an editor entry point for the Mac or iOS app.
// Usage: node scripts/build-web.mjs <entry> <outfile>
// TOAST UI Editor 3.2.2 embeds DOMPurify 2.3.3 in its ESM build. The plugin strips that
// copy and imports the pinned dompurify dependency instead; the build fails if the
// embedded sanitizer survives or the pinned version is missing.
import { build } from 'esbuild';
import { readFile } from 'node:fs/promises';
const [entry, outfile] = process.argv.slice(2);
if (!entry || !outfile) throw new Error('Usage: node scripts/build-web.mjs <entry> <outfile>');
const start = '/*! @license DOMPurify 2.3.3';
const end = 'var purify = createDOMPurify();';
await build({
  entryPoints: [entry],
  bundle: true,
  minify: true,
  outfile,
  loader: { '.woff': 'file', '.ttf': 'file' },
  plugins: [{
    name: 'current-dompurify',
    setup(context) {
      context.onLoad({ filter: /@toast-ui\/editor\/dist\/esm\/index\.js$/ }, async ({ path }) => {
        const source = await readFile(path, 'utf8');
        const first = source.indexOf(start);
        const last = source.indexOf(end, first);
        if (first < 0 || last < 0 || source.indexOf(start, first + 1) >= 0) throw new Error('Review the editor sanitizer integration before building.');
        return { contents: "import purify from 'dompurify';\n" + source.slice(0, first) + source.slice(last + end.length), loader: 'js' };
      });
    }
  }]
});
const output = await readFile(outfile, 'utf8');
if (output.includes('DOMPurify 2.3.3') || !output.includes('3.4.15')) throw new Error('Unexpected bundled sanitizer version.');

import { build } from 'esbuild';
import { readFile } from 'node:fs/promises';
const start = '/*! @license DOMPurify 2.3.3';
const end = 'var purify = createDOMPurify();';
await build({
  entryPoints: ['ios/Web/editor.js'],
  bundle: true,
  minify: true,
  outfile: 'ios/Resources/web/editor.js',
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
const output = await readFile('ios/Resources/web/editor.js', 'utf8');
if (output.includes('DOMPurify 2.3.3') || !output.includes('3.4.15')) throw new Error('Unexpected bundled sanitizer version.');

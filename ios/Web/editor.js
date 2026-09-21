import Editor from '@toast-ui/editor';
import '@toast-ui/editor/dist/toastui-editor.css';
import './style.css';
let loading = false;
let edited = false;
const send = (name, body) => window.webkit?.messageHandlers[name]?.postMessage(body);
const editor = new Editor({
  el: document.querySelector('#editor'), height: '100%', initialEditType: 'wysiwyg',
  usageStatistics: false, autofocus: false, hideModeSwitch: true, toolbarItems: [],
  placeholder: 'Start writing…',
  events: { change: () => { if (!loading) { edited = true; send('changed', editor.getMarkdown()); } } }
});
window.markdown = {
  async load(value) {
    loading = true;
    editor.setMarkdown(value, false);
    editor.moveCursorToStart(false);
    editor.blur();
    await new Promise(resolve => requestAnimationFrame(() => requestAnimationFrame(resolve)));
    document.querySelectorAll('#editor, .toastui-editor-main, .toastui-editor-ww-container, .toastui-editor-contents').forEach(el => { el.scrollTop = 0; });
    window.scrollTo(0, 0);
    loading = false;
    edited = false;
  },
  snapshot() { return { text: editor.getMarkdown(), edited }; },
  command(name) { editor.exec(name); editor.focus(); },
  heading(level) { editor.exec('heading', { level }); editor.focus(); },
  blur() { editor.blur(); }
};
document.addEventListener('click', event => {
  if (event.target.closest('a[href]')) event.preventDefault();
});
send('ready', true);

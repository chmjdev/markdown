import Editor from '@toast-ui/editor';
import '@toast-ui/editor/dist/toastui-editor.css';
import './style.css';
let loading = false;
let edited = false;
let originalText = '';
const changeMode = Editor.prototype.changeMode;
Editor.prototype.changeMode = function(mode, withoutFocus) {
  const previousLoading = loading;
  loading = true;
  try {
    changeMode.call(this, mode, withoutFocus);
    if (mode === 'markdown' && !edited) this.setMarkdown(originalText, false);
  } finally { loading = previousLoading; }
};
const send = (name, body) => window.webkit?.messageHandlers[name]?.postMessage(body);
const editor = new Editor({
  el: document.querySelector('#editor'), height: '100%', initialEditType: 'wysiwyg',
  previewStyle: 'vertical', usageStatistics: false, autofocus: true,
  placeholder: 'Start writing…', hideModeSwitch: false,
  toolbarItems: [['heading', 'bold', 'italic', 'strike'], ['hr', 'quote'], ['ul', 'ol', 'task'], ['table', 'link'], ['code', 'codeblock']],
  events: { change: () => { if (!loading) { edited = true; send('changed', editor.getMarkdown()); updateCount(); } } }
});
function updateCount() {
  const text = editor.getMarkdown().trim();
  document.querySelector('#count').textContent = `${text ? text.split(/\s+/u).length : 0} words`;
}
window.markdown = {
  load(value) { originalText = value; loading = true; editor.setMarkdown(value, false); loading = false; edited = false; updateCount(); },
  value() { return editor.getMarkdown(); },
  snapshot() { return { text: editor.getMarkdown(), edited }; },
  command(name) { editor.exec(name); editor.focus(); },
  insert(text) { editor.insertText(text); },
  focus() { editor.focus(); },
  html() { return editor.getHTML(); },
  mode(mode) { editor.changeMode(mode, true); },
  selection() { return editor.getSelection(); }
};
document.addEventListener('click', event => {
  const link = event.target.closest('a[href]');
  if (link) { event.preventDefault(); if (event.metaKey) send('openLink', link.href); }
});
send('ready', true);

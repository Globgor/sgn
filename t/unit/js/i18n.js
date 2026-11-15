const assert = require('node:assert/strict');
const fs = require('node:fs');
const vm = require('node:vm');
function page(catalog) {
    const context = vm.createContext({ JSAN: { use: function () {} } }, {
        codeGeneration: { strings: false, wasm: false }
    });
    if (catalog) vm.runInContext(fs.readFileSync('t/data/i18n/' + catalog + '.js', 'utf8'), context);
    ['tannin_min.js', 'CXGN/I18N.js'].forEach(function (file) {
        vm.runInContext(fs.readFileSync('js/source/legacy/' + file, 'utf8'), context, { filename: file });
    });
    return context;
}
let p = page();
assert.equal(p.gettext('Search'), 'Search');
assert.equal(p.pgettext('verb', 'Search'), 'Search');
[0, 1, 2, 21].forEach(function (n) {
    assert.equal(p.ngettext('plot', 'plots', n), n === 1 ? 'plot' : 'plots');
});
p = page('uk');
assert.equal(p.gettext('Search'), 'Пошук');
assert.equal(p.pgettext('verb', 'Search'), 'Шукати');
assert.deepEqual([1, 2, 5, 21].map(function (n) { return p.ngettext('trial', 'trials', n); }),
    ['дослід', 'досліди', 'дослідів', 'дослід']);
assert.equal(p.npgettext('field', 'trial', 'trials', 5), 'польових дослідів');
assert.equal(p.gettext('Missing'), 'Missing');
assert.equal(p.pgettext('unknown', 'Search'), 'Search');
[1, 2, 5, 21].forEach(function (n) {
    assert.equal(p.ngettext('plot', 'plots', n), n === 1 ? 'plot' : 'plots');
    assert.equal(p.npgettext('unknown', 'plot', 'plots', n), n === 1 ? 'plot' : 'plots');
});
p = page('ar');
assert.deepEqual([0, 1, 2, 3, 11, 100].map(function (n) { return p.ngettext('trial', 'trials', n); }),
    ['صفر', 'واحد', 'اثنان', 'قليل', 'كثير', 'آخر']);
p = page('empty');
assert.equal(p.gettext('Search'), 'Search');
assert.equal(p.ngettext('plot', 'plots', 21), 'plots');
p = page();
assert.equal(p.i18n_html('List Name'), 'List Name');
assert.equal(p.i18n_html('<img src=x onerror="a()"> & \'b\''), '&#60;img src=x onerror=&#34;a()&#34;&#62; &#38; &#39;b&#39;');
assert.equal(p.i18n_html('Select {bold}Group{end_bold} now', { bold: '<strong>', end_bold: '</strong>' }),
    'Select <strong>Group</strong> now');
assert.equal(p.i18n_html('{bold}<b>{x}{toString}', { bold: '<em>' }), '<em>&#60;b&#62;{x}{toString}');
console.log('English, Ukrainian, Arabic, context, missing text, CSP and HTML escape checks passed');

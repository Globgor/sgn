const assert = require('node:assert/strict');
const fs = require('node:fs');
const { JSDOM } = require('../../../js/node_modules/jsdom');
const base = 'js/source/legacy/';
const keys = {
    lengthMenu: 'Show _MENU_ entries', search: 'Search:',
    info: 'Showing _START_ to _END_ of _TOTAL_ entries',
    infoEmpty: 'Showing 0 to 0 of 0 entries',
    infoFiltered: '(filtered from _MAX_ total entries)',
    emptyTable: 'No data available in table', zeroRecords: 'No matching records found',
    loadingRecords: 'Loading...', processing: 'Processing...'
};
for (const translated of [false, true]) {
    const dom = new JSDOM('<table id="a"><thead><tr><th>Name</th></tr></thead><tbody></tbody></table>' +
        '<table id="b"><thead><tr><th>Name</th></tr></thead><tbody><tr><td>Sample</td></tr></tbody></table>',
    { runScripts: 'outside-only' });
    const w = dom.window;
    w.JSAN = { use() {} };
    if (translated) {
        w.sgn_locale_data = { '': { plural_forms: 'nplurals=2; plural=(n != 1);' } };
        [...Object.values(keys), 'First', 'Last', 'Next', 'Previous'].forEach(text => {
            w.sgn_locale_data[text] = ['«' + text + '»'];
        });
    }
    for (const file of ['jquery.js', 'jquery/dataTables.js', 'tannin_min.js', 'CXGN/I18N.js']) {
        w.eval(fs.readFileSync(base + file, 'utf8'));
    }
    const original = JSON.parse(JSON.stringify(w.jQuery.fn.dataTable.defaults.oLanguage));
    w.eval(fs.readFileSync(base + 'CXGN/TableLanguage.js', 'utf8'));
    const expected = text => translated ? '«' + text + '»' : text;
    const defaults = w.jQuery.fn.dataTable.defaults.language;
    for (const [key, text] of Object.entries(keys)) assert.equal(defaults[key], expected(text));
    for (const key of ['first', 'last', 'next', 'previous']) {
        assert.equal(defaults.paginate[key], expected(key[0].toUpperCase() + key.slice(1)));
    }
    const empty = w.jQuery('#a').DataTable();
    const populated = w.jQuery('#b').DataTable();
    for (const table of [empty, populated]) {
        const language = table.settings()[0].oLanguage;
        if (!translated) {
            for (const [key, value] of Object.entries(original)) {
                if (typeof value === 'string') assert.equal(language[key], value);
            }
            for (const key of ['sFirst', 'sLast', 'sNext', 'sPrevious']) {
                assert.equal(language.oPaginate[key], original.oPaginate[key]);
            }
        }
        assert.equal(language.sSearch, expected('Search:'));
        assert.equal(language.oPaginate.sNext, expected('Next'));
    }
    assert.ok(w.document.querySelector('#a_info').textContent.includes(expected(keys.infoEmpty)));
    assert.ok(w.document.querySelector('#a td').textContent.includes(expected(keys.emptyTable)));
    populated.search('absent').draw();
    assert.ok(w.document.querySelector('#b td').textContent.includes(expected(keys.zeroRecords)));
    dom.window.close();
}
const dom = new JSDOM('', { runScripts: 'outside-only' });
dom.window.JSAN = { use() {} };
const source = fs.readFileSync(base + 'CXGN/TableLanguage.js', 'utf8');
dom.window.eval(source);
dom.window.eval(fs.readFileSync(base + 'jquery.js', 'utf8'));
dom.window.eval(source);
dom.window.close();
console.log('DataTables 1.10.12 English defaults, translated defaults, two tables and absent plugin passed');

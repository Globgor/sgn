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
// The Buttons extension (copy, print, column visibility) takes its texts from the same defaults.
const buttons = { 'Copy': 'copy', 'Print': 'print', 'Column visibility': 'colvis' };
for (const translation of [null, text => '«' + text + '»', () => '<img src=x onerror="window.hit=1">']) {
    const dom = new JSDOM('<table id="c"><thead><tr><th>Name</th></tr></thead><tbody><tr><td>Sample</td></tr></tbody></table>',
        { runScripts: 'outside-only' });
    const w = dom.window;
    w.JSAN = { use() {} };
    if (translation) {
        w.sgn_locale_data = { '': { plural_forms: 'nplurals=2; plural=(n != 1);' } };
        for (const text of [...Object.keys(buttons), 'Copy to clipboard', 'Copied one row to clipboard', 'Copied %d rows to clipboard']) {
            w.sgn_locale_data[text] = [translation(text)];
        }
    }
    for (const file of ['jquery.js', 'jquery/dataTables.js', 'jquery/dataTables-buttons-min.js', 'buttons/html5-min.js',
        'buttons/print-min.js', 'buttons/colvis-min.js', 'tannin_min.js', 'CXGN/I18N.js', 'CXGN/TableLanguage.js']) {
        w.eval(fs.readFileSync(base + file, 'utf8'));
    }
    const table = w.jQuery('#c').DataTable({ dom: 'Bfrtip', buttons: ['copy', 'print', 'colvis'] });
    const shown = [...w.document.querySelectorAll('.dt-button')].map(b => b.textContent.trim());
    const expected = Object.keys(buttons).map(text => translation ? translation(text) : text);
    assert.deepEqual(shown, expected);
    // The message of the copy button is HTML: the translation is escaped.
    const html = text => text.replace(/[&<>"']/g, c => '&#' + c.charCodeAt(0) + ';');
    const message = text => html(translation ? translation(text) : text);
    assert.equal(table.i18n('buttons.copySuccess', '', 1), message('Copied one row to clipboard'));
    assert.equal(table.i18n('buttons.copySuccess', '', 5), message('Copied %d rows to clipboard').replace('%d', 5));
    assert.equal(w.document.querySelectorAll('.dt-buttons img').length, 0);
    assert.equal(w.hit, undefined);
    dom.window.close();
}
console.log('DataTables 1.10.12 English defaults, translated defaults, two tables, absent plugin and Buttons texts passed');

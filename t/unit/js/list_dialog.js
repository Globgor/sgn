// The Your Lists dialog that CXGN.List builds in HTML strings: English is unchanged, every
// text follows the page catalog, and a translation cannot add markup.
const assert = require('node:assert/strict');
const fs = require('node:fs');
const { JSDOM } = require('../../../js/node_modules/jsdom');
const base = 'js/source/legacy/';
const texts = ['Create New List:', 'Create New List. Type New List Name Here', 'New List', 'Description For New List',
    'Filter Lists by Type', 'Any', 'Include Autocreated Lists', 'List Name', 'Date Created', 'Date Modified',
    'Validate', 'Share', 'Group', 'View', 'Make Public',
    'Select 2 or more lists in the {bold}Group{end_bold} column to modify or combine them'];
function dialog(translate) {
    const dom = new JSDOM('<div id="list_dialog_div"></div>', { runScripts: 'outside-only' });
    const w = dom.window;
    w.JSAN = { use() {} };
    w.CXGN = {};
    if (translate) {
        w.sgn_locale_data = { '': { plural_forms: 'nplurals=2; plural=(n != 1);' } };
        texts.forEach(text => { w.sgn_locale_data[text] = [translate(text)]; });
    }
    for (const file of ['jquery.js', 'jquery/dataTables.js', 'tannin_min.js', 'CXGN/I18N.js', 'CXGN/List.js']) {
        w.eval(fs.readFileSync(base + file, 'utf8'));
    }
    w.CXGN.List.prototype.availableLists = () => [[7, 'Field 7', 'Data stays English', 3, null, 'accessions', 0, null, null]];
    w.CXGN.List.prototype.allListTypes = () => [[1, 'accessions']];
    new w.CXGN.List().renderLists('list_dialog');
    const html = w.document.querySelector('#list_dialog_div').innerHTML;
    const images = w.document.querySelectorAll('img').length;
    const header = w.document.querySelector('#private_list_data_table th').textContent;
    const hit = w.hit;
    dom.window.close();
    return translate ? Object.assign(new String(html), { images, header, hit }) : html;
}
const english = dialog();
for (const text of ['<label class="col-sm-3 control-label">Create New List: </label>', 'placeholder="Create New List. Type New List Name Here"',
    '>New List</button>', 'placeholder="Description For New List"', '<strong>Filter Lists by Type</strong>:', '<option value="">Any</option>',
    '<strong>Include Autocreated Lists</strong>:', '>List Name</th>', '>Date Created</th>', '>Group</th>', 'title="View"', 'title="Make Public"',
    '<em>Select 2 or more lists in the <strong>Group</strong> column to modify or combine them</em>', 'Field 7', 'Data stays English']) {
    assert.ok(english.includes(text), 'English: ' + text);
}
const translated = dialog(text => '«' + text + '»');
for (const text of ['>«Create New List:» </label>', 'placeholder="«Create New List. Type New List Name Here»"', '>«New List»</button>',
    '<strong>«Filter Lists by Type»</strong>', '>«Any»</option>', '>«List Name»</th>', '>«Group»</th>', 'title="«View»"', 'title="«Make Public»"',
    '<em>«Select 2 or more lists in the <strong>Group</strong> column to modify or combine them»</em>', 'Field 7', 'Data stays English']) {
    assert.ok(translated.includes(text), 'translated: ' + text);
}
const hostile = dialog(() => '<img src=x onerror="window.hit=1">"');
assert.equal(hostile.images, 0, 'a translation adds no element');
assert.equal(hostile.hit, undefined, 'a translation runs no script');
assert.equal(hostile.header, '<img src=x onerror="window.hit=1">"', 'a translation is shown as text');
console.log('Lists dialog: English unchanged, translated texts and escaped translations passed');

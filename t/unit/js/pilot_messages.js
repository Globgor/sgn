const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const vm = require('node:vm');
const root = process.argv[2] || '.';
const kind = process.argv[3] || 'both';
const texts = ['An error occurred.', 'Please provide a name for the new list.',
    'Delete the selected lists? This cannot be undone.', 'The phenotypic data has been deleted.',
    'The field trial has been deleted.'];
for (const translated of [false, true]) {
    const alerts = [], confirmations = [], requests = [], modal = [];
    const context = vm.createContext({
        CXGN: {}, document: {}, JSAN: { use() {} }, window: { location: {} }, console,
        alert(text) { alerts.push(text); },
        confirm(text) { confirmations.push(text); return true; },
        jQuery(selector) { return { on() {}, ready() {}, modal(action) { modal.push([selector, action]); }, html() {} }; }
    });
    context.jQuery.ajax = options => requests.push(options);
    context.jQuery.noConflict = () => context.jQuery;
    if (translated) {
        context.sgn_locale_data = { '': { plural_forms: 'nplurals=2; plural=(n != 1);' } };
        texts.forEach(text => { context.sgn_locale_data[text] = ['«' + text + '»']; });
    }
    for (const file of ['tannin_min.js', 'CXGN/I18N.js', 'CXGN/List.js', 'CXGN/Trial.js']) {
        vm.runInContext(fs.readFileSync(path.join(root, 'js/source/legacy', file), 'utf8'), context);
    }
    const expected = text => translated ? '«' + text + '»' : text;
    if (kind !== 'trial') {
        const list = new context.CXGN.List();
        list.getList(42);
        assert.equal(requests.at(-1).url, '/list/contents/42');
        requests.at(-1).error({});
        assert.equal(alerts.pop(), expected(texts[0]));
        list.existsList = () => null;
        assert.equal(list.newList('', 'Description'), 0);
        assert.equal(alerts.pop(), expected(texts[1]));
        list.newList('Field 7', 'Data stays English');
        assert.equal(requests.at(-1).data.name, 'Field 7');
        assert.equal(requests.at(-1).data.desc, 'Data stays English');
        requests.at(-1).success({ error: 'Server detail' });
        assert.equal(alerts.pop(), 'Server detail');
        const deleted = [];
        context.CXGN.List.prototype.deleteList = id => deleted.push(id);
        context.CXGN.List.prototype.renderLists = () => {};
        context.deleteSelectedListGroup([5, 8]);
        assert.equal(confirmations.pop(), expected(texts[2]));
        assert.deepEqual(deleted, [5, 8]);
    }
    if (kind !== 'list') {
        for (const [method, ending, message] of [
            ['delete_phenotype_data_by_trial_id', 'phenotypes', texts[3]],
            ['delete_layout_data_by_trial_id', 'layout', texts[4]]
        ]) {
            context[method](17);
            const request = requests.at(-1);
            assert.equal(request.url, '/ajax/breeders/trial/17/delete/' + ending);
            // Concatenated confirmations are deliberately unchanged in this pass.
            assert.ok(confirmations.pop().includes('trial 17'));
            request.beforeSend();
            request.success({ error: 'Field data' });
            assert.equal(alerts.pop(), 'Field data');
            request.success({});
            assert.equal(alerts.pop(), expected(message));
            assert.equal(context.window.location.href, '/breeders/trial/17');
            request.error({});
            assert.equal(alerts.pop(), expected(texts[0]));
        }
        assert.ok(modal.length > 0);
    }
}
console.log((kind === 'both' ? 'List and trial' : kind) +
    ' English/translated messages, callbacks, URLs, data and server errors passed');

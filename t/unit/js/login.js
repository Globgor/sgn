const assert = require('node:assert/strict');
const fs = require('node:fs');
const vm = require('node:vm');
function page(translated) {
    const dialogs = {};
    const alerts = [];
    const calls = [];
    const context = vm.createContext({
        JSAN: { use: function () {} },
        alert: function (text) { alerts.push(text); },
        jQuery: function (selector) {
            return { dialog: function (options) { dialogs[selector] = options; } };
        }
    });
    context.jQuery.ajax = function (options) { calls.push(options); };
    if (translated) {
        context.sgn_locale_data = {
            '': { plural_forms: 'nplurals=2; plural=(n != 1);' },
            'Working...': ['Обробка...'], 'Login': ['Увійти'], 'Cancel': ['Скасувати'],
            'An error occurred.': ['Сталася помилка.']
        };
    }
    ['tannin_min.js', 'CXGN/I18N.js', 'CXGN/Login.js'].forEach(function (file) {
        vm.runInContext(fs.readFileSync('js/source/legacy/' + file, 'utf8'), context);
    });
    context.setUpLogin();
    assert.equal(dialogs['#working'].title, translated ? 'Обробка...' : 'Working...');
    const login = dialogs['#login_window'];
    assert.equal(login.title, translated ? 'Увійти' : 'Login');
    // jQuery UI accepts both named buttons and its standard button array.
    const buttons = Array.isArray(login.buttons) ? login.buttons : Object.keys(login.buttons).map(function (text) {
        return { text: text, click: login.buttons[text] };
    });
    assert.deepEqual(Array.from(buttons, function (button) { return button.text; }),
        translated ? ['Увійти', 'Скасувати'] : ['Login', 'Cancel']);
    let clicked = 0;
    context.login = function () { clicked++; };
    buttons[0].click();
    assert.equal(clicked, 1);
    buttons[1].click();
    assert.equal(dialogs['#login_window'], 'close');
    assert.equal(login.modal, true);
    assert.equal(login.autoOpen, false);
    assert.equal(context.isLoggedIn(), undefined);
    assert.equal(context.getUserRoles(), undefined);
    assert.deepEqual(calls.map(function (call) { return call.url; }), ['/user/logged_in', '/user/get_roles']);
    calls.forEach(function (call) { assert.equal(call.async, false); call.error('HTTP 500'); });
    const error = (translated ? 'Сталася помилка. ' : 'An error occurred. ') + 'HTTP 500';
    assert.deepEqual(alerts, [error, error]);
    calls[0].success({ error: 'Server detail' });
    assert.equal(alerts[2], 'Server detail');
}
page(false);
page(true);
console.log('English and translated login controls, callbacks, errors and response data passed');

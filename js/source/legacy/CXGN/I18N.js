JSAN.use("tannin_min");

var sgn_i18n_data = (typeof sgn_locale_data !== 'undefined') ? sgn_locale_data
    : { '': { plural_forms: 'nplurals=2; plural=(n != 1);' } };          // English without a catalog
var sgn_i18n = new Tannin({ sgn: sgn_i18n_data });

function npgettext(msgctxt, msgid, msgid_plural, n) {
    var key = msgctxt ? msgctxt + '\u0004' + msgid : msgid;
    var entry = sgn_i18n_data[key];
    if (n !== undefined && !(entry && entry[0])) {                        // Missing translations use the English plural rule.
        return Number(n) === 1 ? msgid : msgid_plural;
    }
    return sgn_i18n.dcnpgettext('sgn', msgctxt, msgid, msgid_plural, n);
}
function gettext(msgid) { return npgettext(undefined, msgid); }
function ngettext(msgid, msgid_plural, n) { return npgettext(undefined, msgid, msgid_plural, n); }
function pgettext(msgctxt, msgid) { return npgettext(msgctxt, msgid); }

// A translation inside an HTML string: the text is HTML-escaped, so a catalog adds no markup;
// then each {name} becomes parts[name], markup that the script gives.
function i18n_html(text, parts) {
    var html = String(text).replace(/[&<>"']/g, function (c) { return '&#' + c.charCodeAt(0) + ';'; });
    if (!parts) return html;
    return html.replace(/\{(\w+)\}/g, function (all, name) {
        return Object.prototype.hasOwnProperty.call(parts, name) ? parts[name] : all;
    });
}

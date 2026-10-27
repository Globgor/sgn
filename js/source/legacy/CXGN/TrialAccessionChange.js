/**
 * Describes a change of the accessions of plots in a trial (Replace Accession,
 * Shift Accessions, the Change Accessions upload) for the user.
 *
 * The summary is the one that the replace_stock, shift_accessions and
 * change_plot_accessions_using_file endpoints return, see
 * CXGN::Trial::AccessionChange::summary().
 */

/**
 * The lines that describe a summary.
 * @param {Object} summary - the summary (or the preview) from the server
 * @param {boolean} planned - true for a preview (what will change), false for what changed
 * @param {number} [max_items=10] - how many plots to list for renames and check marks
 * @returns {string[]} the lines, without HTML
 */
function trial_accession_change_lines(summary, planned, max_items) {
    max_items = max_items || 10;
    var lines = [];
    var list = function (items, describe) {
        items.slice(0, max_items).forEach(function (item) { lines.push('    ' + describe(item)); });
        if (items.length > max_items) {
            lines.push('    ... and ' + (items.length - max_items) + ' more');
        }
    };

    if (summary.first_plot) {
        lines.push('Plots ' + summary.first_plot + ' to ' + summary.last_plot + ' (' + summary.plots_in_stretch + ' plots in this order).');
    }
    lines.push(summary.changed + ' plot(s) ' + (planned ? 'will get' : 'got') + ' another accession.');
    if (summary.replicates_changed) {
        lines.push(summary.replicates_changed + ' replicate number(s) ' + (planned ? 'will be' : 'were') + ' numbered again by plot number (completely randomized design).');
    }
    if (summary.checks && summary.checks.length) {
        lines.push('Check plots ' + (planned ? 'that will change' : 'that changed') + ':');
        list(summary.checks, function (k) { return k.plot_name + (k.check ? ' becomes a check plot' : ' becomes a test plot'); });
    }
    if (summary.renamed && summary.renamed.length) {
        lines.push(summary.renamed.length + ' plot(s) ' + (planned ? 'will be renamed' : 'were renamed') + ':');
        list(summary.renamed, function (r) { return r.old_name + ' -> ' + r.new_name; });
    }
    (summary.not_renamed || []).forEach(function (r) { lines.push('Not renamed: ' + r.plot_name + ' (' + r.reason + ')'); });
    if (summary.pushed_out && summary.pushed_out.length) {
        lines.push('No longer in these plots (add a plot if they were planted somewhere else):');
        list(summary.pushed_out, function (p) { return p.stock_name + ' (planned for ' + p.plot_name + ')'; });
    }
    (summary.entry_numbers || []).forEach(function (e) { lines.push(e.stock_name + (planned ? ' will get' : ' got') + ' entry number ' + e.entry_number + '.'); });
    (summary.warnings || []).forEach(function (w) { lines.push('Note: ' + w); });
    return lines;
}

/**
 * Shows the lines of a summary as the items of a list.
 * @param {string} list_selector - selector of an (empty or not) ul element
 * @param {Object} summary - the summary from the server
 * @param {boolean} planned - true for a preview, false for what changed
 */
function trial_accession_change_show(list_selector, summary, planned) {
    var list = jQuery(list_selector).empty();
    trial_accession_change_lines(summary, planned, 50).forEach(function (line) {
        list.append(jQuery('<li/>').text(line));
    });
}

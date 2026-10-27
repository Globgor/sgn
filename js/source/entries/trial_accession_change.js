import "../legacy/jquery.js";

/**
 * Changes of what grows on the plots of a field trial: Replace Accession,
 * Shift Accessions and Not Planted Plots (Field Layout Tools -> Edit Field
 * Layout), the plot dialog of the field map, and the Change Accessions upload.
 *
 * The endpoints answer with a summary (see CXGN::Trial::AccessionChange::summary()):
 * with preview=1 what would change ({ preview: summary }), otherwise what changed
 * ({ success: 1, ...summary }). Otherwise they answer { error }, or { warning }
 * when a curator has to confirm a change of a trial that already has data.
 * Errors about phenotypes of plots marked as not planted come with
 * not_planted_phenotypes, the number of those values.
 */

/**
 * The lines that describe a summary, without HTML.
 * @param {Object} summary - the summary (or the preview) from the server
 * @param {boolean} planned - true for a preview (what will change), false for what changed
 * @param {number} [maxItems=10] - how many plots to list for renames, check marks and planting
 * @returns {string[]}
 */
export function summaryLines(summary, planned, maxItems = 10) {
    const lines = [];
    const list = (items, describe) => {
        items.slice(0, maxItems).forEach((item) => lines.push("    " + describe(item)));
        if (items.length > maxItems) {
            lines.push("    ... and " + (items.length - maxItems) + " more");
        }
    };

    if (summary.first_plot) {
        lines.push(`Plots ${summary.first_plot} to ${summary.last_plot} (${summary.plots_in_stretch} plots in this order).`);
    }
    const planting = summary.planting || [];
    if (summary.changed || !planting.length) {
        lines.push(`${summary.changed} plot(s) ${planned ? "will get" : "got"} another accession.`);
    }
    const notPlanted = planting.filter((p) => p.not_planted);
    const planted = planting.filter((p) => !p.not_planted);
    if (notPlanted.length) {
        lines.push(`${notPlanted.length} plot(s) ${planned ? "will be" : "were"} marked as not planted:`);
        list(notPlanted, (p) => p.plot_name);
    }
    if (planted.length) {
        lines.push(`${planted.length} plot(s) ${planned ? "will be" : "were"} marked as planted again:`);
        list(planted, (p) => p.plot_name);
    }
    if (summary.replicates_changed) {
        lines.push(`${summary.replicates_changed} replicate number(s) ${planned ? "will be" : "were"} numbered again by plot number (completely randomized design).`);
    }
    if (summary.checks && summary.checks.length) {
        lines.push(`Check plots ${planned ? "that will change" : "that changed"}:`);
        list(summary.checks, (k) => k.plot_name + (k.check ? " becomes a check plot" : " becomes a test plot"));
    }
    if (summary.renamed && summary.renamed.length) {
        lines.push(`${summary.renamed.length} plot(s) ${planned ? "will be renamed" : "were renamed"}:`);
        list(summary.renamed, (r) => `${r.old_name} -> ${r.new_name}`);
    }
    (summary.not_renamed || []).forEach((r) => lines.push(`Not renamed: ${r.plot_name} (${r.reason})`));
    if (summary.pushed_out && summary.pushed_out.length) {
        lines.push("No longer in these plots (add a plot if they were planted somewhere else):");
        list(summary.pushed_out, (p) => `${p.stock_name} (planned for ${p.plot_name})`);
    }
    (summary.entry_numbers || []).forEach((e) => lines.push(`${e.stock_name}${planned ? " will get" : " got"} entry number ${e.entry_number}.`));
    if (!planned && summary.phenotypes_deleted) {
        lines.push(`${summary.phenotypes_deleted} phenotype value(s) were deleted.`);
    }
    (summary.warnings || []).forEach((w) => lines.push("Note: " + w));
    return lines;
}

/**
 * Shows the lines of a summary as the items of a list.
 * @param {string|HTMLElement} list - the ul element, or its selector
 * @param {Object} summary - the summary from the server
 * @param {boolean} planned - true for a preview, false for what changed
 */
export function showSummary(list, summary, planned) {
    const ul = jQuery(list).empty();
    summaryLines(summary, planned, 50).forEach((line) => ul.append(jQuery("<li/>").text(line)));
}

// the "Working..." dialog of the page, when there is one
function working(show) {
    const modal = jQuery("#working_modal");
    if (modal.length && typeof modal.modal === "function") {
        modal.modal(show ? "show" : "hide");
    }
}

function post(url, data) {
    working(true);
    return new Promise((resolve) => {
        jQuery.ajax({ type: "POST", url, data, dataType: "json", traditional: true })
            .done((response) => resolve(response || {}))
            .fail(() => resolve({ error: "The server could not be reached, or it failed; nothing may have been changed." }))
            .always(() => working(false));
    });
}

/**
 * Makes a change after the user has seen it: posts the request with preview=1,
 * shows what will change and asks to continue, then posts it again to change.
 * A curator confirms a change of a trial with data (the request is repeated
 * with override=1), and the user confirms deleting the phenotypes of plots
 * marked as not planted (with delete_phenotypes=1). Errors are shown with alert.
 * @param {string} url - e.g. /ajax/breeders/trial/<id>/replace_stock
 * @param {Object} data - the parameters of the change
 * @param {Object} [options]
 * @param {string} [options.action="Change"] - names the change in error messages
 * @param {function(string): boolean} [options.confirm] - asks the user; window.confirm by default
 * @param {function(string): void} [options.alert] - tells the user; window.alert by default
 * @returns {Promise<Object|null>} what changed (the summary), or null when nothing was changed
 */
export async function changeWithPreview(url, data, options = {}) {
    const action = options.action || "Change";
    const ask = options.confirm || ((message) => window.confirm(message));
    const tell = options.alert || ((message) => window.alert(message));
    const params = { ...data };

    for (;;) {
        const response = await post(url, { ...params, preview: 1 });
        if (response.warning) {
            if (params.override || !ask(`${response.warning}\n\nThis trial already has data. Change it anyway?`)) {
                return null;
            }
            params.override = 1;
            continue;
        }
        if (response.error) {
            if (response.not_planted_phenotypes && !params.delete_phenotypes) {
                if (ask(`${response.error}\n\nDelete these ${response.not_planted_phenotypes} phenotype value(s) with this change?`)) {
                    params.delete_phenotypes = 1;
                    continue;
                }
                return null;
            }
            tell(`${action}: ${response.error}`);
            return null;
        }
        if (!response.preview || !ask(summaryLines(response.preview, true).join("\n") + "\n\nContinue?")) {
            return null;
        }
        break;
    }

    const response = await post(url, params);
    if (response.error) {
        tell(`${action}: ${response.error}`);
        return null;
    }
    return response;
}

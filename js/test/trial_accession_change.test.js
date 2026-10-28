import test from "tape";
import { summaryLines, showSummary, changeWithPreview, confirmDialog, nothingChanges } from "../source/entries/trial_accession_change.js";

const empty = { changed: 0, replicates_changed: 0, checks: [], renamed: [], not_renamed: [], entry_numbers: [], planting: [], phenotypes_deleted: 0, warnings: [] };

// answers the POSTs in turn with the given responses, and records their data
function fakeServer(responses) {
    const requests = [];
    jQuery.ajax = (options) => {
        requests.push(options.data);
        return jQuery.Deferred().resolve(responses.shift()).promise();
    };
    return requests;
}

test("summaryLines", (t) => {
    t.test("a replacement", (t) => {
        const lines = summaryLines({ ...empty, changed: 2, renamed: [{ old_name: "T-A-1", new_name: "T-B-1" }], warnings: ["1 plot(s) already have phenotypes."] }, true);
        t.deepEqual(lines, [
            "2 plot(s) will get another accession.",
            "1 plot(s) will be renamed:",
            "    T-A-1 -> T-B-1",
            "Note: 1 plot(s) already have phenotypes.",
        ]);
        t.end();
    });

    t.test("plots marked as not planted, and planted again", (t) => {
        const summary = { ...empty, planting: [{ plot_name: "P1", not_planted: 1 }, { plot_name: "P2", not_planted: 0 }], phenotypes_deleted: 3 };
        t.deepEqual(summaryLines(summary, false), [
            "1 plot(s) were marked as not planted:",
            "    P1",
            "1 plot(s) were marked as planted again:",
            "    P2",
            "3 phenotype value(s) were deleted.",
        ], "no line about accessions when only the planting changes");
        t.notOk(summaryLines(summary, true).some((l) => /deleted/.test(l)), "the preview tells about deleting in its warnings");
        t.end();
    });

    t.test("a shift", (t) => {
        const lines = summaryLines({ ...empty, changed: 3, first_plot: "P4", last_plot: "P10", plots_in_stretch: 7, planting: [{ plot_name: "P4", not_planted: 1 }], pushed_out: [{ stock_name: "A10", plot_name: "P10" }] }, true);
        t.equal(lines[0], "Plots P4 to P10 (7 plots in this order).");
        t.equal(lines[1], "3 plot(s) will get another accession.");
        t.ok(lines.includes("    A10 (planned for P10)"));
        t.end();
    });

    t.test("the path of a shift along columns", (t) => {
        const summary = { ...empty, changed: 3, first_plot: "P7", last_plot: "P9", plots_in_stretch: 3, planting: [{ plot_name: "P7", not_planted: 1 }],
            lines: [{ line: "column", number: "2", from: "3", to: "1", plots: ["P7", "P8", "P9"] }], pushed_out: [{ stock_name: "A9", plot_name: "P9" }] };
        const lines = summaryLines(summary, true);
        t.equal(lines[1], "    Column 2, rows 3 to 1: P7, P8, P9", "column and direction");
        t.ok(lines.includes("Left over, no longer in these plots (for example thrown into a border):"));
        const row = summaryLines({ ...summary, lines: [{ line: "row", number: "4", from: "1", to: "12", plots: Array.from({ length: 12 }, (_, i) => "Q" + i) }] }, true, 10);
        t.equal(row[1], "    Row 4, columns 1 to 12: Q0, Q1, Q2, Q3, Q4, Q5, Q6, Q7, Q8, Q9, ... and 2 more", "long lines are cut");
        t.end();
    });

    t.test("long lists are cut", (t) => {
        const checks = Array.from({ length: 12 }, (_, i) => ({ plot_name: "P" + i, check: 1 }));
        const lines = summaryLines({ ...empty, changed: 12, checks }, false, 10);
        t.equal(lines.filter((l) => /becomes a check plot/.test(l)).length, 10);
        t.ok(lines.includes("    ... and 2 more"));
        t.end();
    });
});

test("showSummary", (t) => {
    document.body.innerHTML = "<ul id='summary'><li>old</li></ul>";
    showSummary("#summary", { ...empty, changed: 1, warnings: ["<b>not HTML</b>"] }, false);
    const items = [...document.querySelectorAll("#summary li")].map((li) => li.textContent);
    t.deepEqual(items, ["1 plot(s) got another accession.", "Note: <b>not HTML</b>"]);
    t.equal(document.querySelectorAll("#summary b").length, 0, "text, not HTML");
    t.end();
});

test("changeWithPreview", (t) => {
    t.test("preview, confirm, change", async (t) => {
        const requests = fakeServer([{ preview: { ...empty, changed: 1 } }, { success: 1, ...empty, changed: 1 }]);
        const asked = [];
        const result = await changeWithPreview("/url", { new_stock: "B" }, { confirm: (m) => { asked.push(m); return true; }, alert: () => t.fail("no alert") });
        t.deepEqual(requests, [{ new_stock: "B", preview: 1 }, { new_stock: "B" }]);
        t.ok(/1 plot\(s\) will get another accession\.\n\nContinue\?$/.test(asked[0]));
        t.equal(result.changed, 1);
        t.end();
    });

    t.test("the user says no", async (t) => {
        const requests = fakeServer([{ preview: { ...empty, changed: 1 } }]);
        const result = await changeWithPreview("/url", {}, { confirm: () => false });
        t.equal(result, null);
        t.equal(requests.length, 1, "nothing is changed");
        t.end();
    });

    t.test("an error", async (t) => {
        fakeServer([{ error: "Stock X is obsolete." }]);
        const told = [];
        const result = await changeWithPreview("/url", {}, { action: "Error Replacing Stock", confirm: () => true, alert: (m) => told.push(m) });
        t.equal(result, null);
        t.deepEqual(told, ["Error Replacing Stock: Stock X is obsolete."]);
        t.end();
    });

    t.test("a curator confirms a change of a trial with data", async (t) => {
        const requests = fakeServer([{ warning: "One or more traits have been assayed" }, { preview: { ...empty, changed: 1 } }, { success: 1, ...empty }]);
        await changeWithPreview("/url", { positions: 1 }, { confirm: () => true });
        t.deepEqual(requests, [{ positions: 1, preview: 1 }, { positions: 1, override: 1, preview: 1 }, { positions: 1, override: 1 }]);
        t.end();
    });

    t.test("phenotypes of plots marked as not planted", async (t) => {
        const requests = fakeServer([
            { error: "2 phenotype value(s) were stored for plots that are marked as not planted (P1).", not_planted_phenotypes: 2 },
            { preview: { ...empty, planting: [{ plot_name: "P1", not_planted: 1 }] } },
            { success: 1, ...empty, phenotypes_deleted: 2 },
        ]);
        const asked = [];
        const result = await changeWithPreview("/url", { plot_ids: "7" }, { confirm: (m) => { asked.push(m); return true; } });
        t.ok(/Delete these 2 phenotype values with this change\?$/.test(asked[0]));
        t.deepEqual(requests[2], { plot_ids: "7", delete_phenotypes: 1 });
        t.equal(result.phenotypes_deleted, 2);
        t.end();
    });

    t.test("the page can ask in its own dialog", async (t) => {
        const requests = fakeServer([{ preview: { ...empty, changed: 1 } }, { success: 1, ...empty, changed: 1 }]);
        const result = await changeWithPreview("/url", {}, { confirm: () => Promise.resolve(true) });
        t.equal(requests.length, 2);
        t.equal(result.changed, 1);
        t.end();
    });

    t.test("a plan that changes nothing is not asked about", async (t) => {
        const requests = fakeServer([{ preview: { ...empty, unchanged: ["P1", "P2"] } }]);
        const told = [];
        const result = await changeWithPreview("/url", {}, { confirm: () => t.fail("no question"), alert: (m) => told.push(m) });
        t.equal(result, null);
        t.deepEqual(told, ["Nothing to change."]);
        t.equal(requests.length, 1, "and nothing is posted to change");
        t.ok(nothingChanges({ ...empty }), "an empty plan");
        t.notOk(nothingChanges({ ...empty, planting: [{ plot_name: "P1", not_planted: 1 }] }), "a plan that marks a plot");
        t.end();
    });

    t.test("keeping the phenotypes changes nothing", async (t) => {
        const requests = fakeServer([{ error: "2 phenotype value(s) ...", not_planted_phenotypes: 2 }]);
        const result = await changeWithPreview("/url", {}, { confirm: () => false, alert: () => t.fail("no alert") });
        t.equal(result, null);
        t.equal(requests.length, 1);
        t.end();
    });
});

test("confirmDialog", (t) => {
    t.test("without Bootstrap: window.confirm", async (t) => {
        delete jQuery.fn.modal;
        const asked = [];
        window.confirm = (m) => { asked.push(m); return true; };
        t.equal(await confirmDialog("a\nb"), true);
        t.deepEqual(asked, ["a\nb"]);
        t.end();
    });

    t.test("a dialog with a line per item", async (t) => {
        // enough of Bootstrap's modal: hiding fires hidden.bs.modal
        jQuery.fn.modal = function (option) {
            if (option === "hide") this.trigger("hidden.bs.modal");
            return this;
        };
        const answer = confirmDialog("2 plot(s) will get another accession.\n    P1\n\nContinue?", { title: "Shift Accessions", ok: "Go" });
        const dialog = jQuery(".modal").last();
        t.equal(dialog.find(".modal-title").text(), "Shift Accessions");
        t.deepEqual(dialog.find("li").map((i, li) => jQuery(li).text()).get(), ["2 plot(s) will get another accession.", "    P1", "Continue?"], "one item per line, without empty lines");
        t.equal(dialog.find(".btn-primary").text(), "Go");
        dialog.find("[data-answer=yes]").trigger("click");
        t.equal(await answer, true, "yes");
        t.equal(jQuery(".modal").length, 0, "the dialog is removed");
        const no = confirmDialog("x");
        jQuery(".modal").last().find("[data-answer=no]").trigger("click");
        t.equal(await no, false, "cancel");
        delete jQuery.fn.modal;
        t.end();
    });
});

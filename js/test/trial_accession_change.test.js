import test from "tape";
import { summaryLines, showSummary, changeWithPreview, confirmDialog, nothingChanges, plainText, changedPlots } from "../source/entries/trial_accession_change.js";

const empty = { changed: 0, replicates_changed: 0, checks: [], renamed: [], not_renamed: [], entry_numbers: [], warnings: [] };

// answers the POSTs in turn with the given responses, and records their data
// (a FormData as an object); the options of the requests go to sent
function fakeServer(responses, sent = []) {
    const requests = [];
    jQuery.ajax = (options) => {
        sent.push(options);
        requests.push(options.data instanceof FormData ? Object.fromEntries(options.data.entries()) : options.data);
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

    t.test("which plot gets which accession", (t) => {
        const lines = summaryLines({ ...empty, changed: 2, changes: [{ plot_name: "P8", old_stock_name: "A1", new_stock_name: "A5" }, { plot_name: "P9", old_stock_name: "A3", new_stock_name: "A1" }] }, true);
        t.deepEqual(lines, ["2 plot(s) will get another accession:", "    P8: A1 -> A5", "    P9: A3 -> A1"]);
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

    t.test("the change is the one of the preview", async (t) => {
        const requests = fakeServer([{ preview: { ...empty, changed: 1, plan_digest: "abc" } }, { error: "Nothing was changed: The trial changed after the preview" }]);
        const told = [];
        const result = await changeWithPreview("/url", { new_stock: "B" }, { confirm: () => true, alert: (m) => told.push(m) });
        t.deepEqual(requests[1], { new_stock: "B", plan_digest: "abc" }, "the apply carries the digest of the preview");
        t.equal(result, null);
        t.ok(/changed after the preview/.test(told[0]), "and the refusal is shown");
        t.end();
    });

    t.test("the preview lists every change", async (t) => {
        const changes = Array.from({ length: 30 }, (_, i) => ({ plot_name: "P" + i, old_stock_name: "A", new_stock_name: "B" }));
        fakeServer([{ preview: { ...empty, changed: 30, changes } }]);
        let asked = "";
        await changeWithPreview("/url", {}, { confirm: (m) => { asked = m; return false; } });
        t.ok(asked.includes("    P29: A -> B") && !asked.includes("more"), "all 30, none hidden behind \"and N more\"");
        t.end();
    });

    t.test("an apply without success is not a success", async (t) => {
        fakeServer([{ preview: { ...empty, changed: 1 } }, { warning: "One or more traits have been assayed" }]);
        const told = [];
        const result = await changeWithPreview("/url", {}, { confirm: () => true, alert: (m) => told.push(m) });
        t.equal(result, null);
        t.deepEqual(told, ["Change: One or more traits have been assayed"]);
        t.end();
    });

    t.test("the server cannot be reached", async (t) => {
        jQuery.ajax = () => jQuery.Deferred().reject().promise();
        const told = [];
        const result = await changeWithPreview("/url", {}, { confirm: () => true, alert: (m) => told.push(m) });
        t.equal(result, null);
        t.deepEqual(told, ["Change: The server could not be reached, or it failed; nothing may have been changed."]);
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
        t.deepEqual(told, ["Nothing to change: the trial already matches."]);
        t.equal(requests.length, 1, "and nothing is posted to change");
        fakeServer([{ preview: { ...empty, warnings: ["Plot P1 has no seed transaction"] } }]);
        const notes = [];
        await changeWithPreview("/url", {}, { alert: (m) => notes.push(m) });
        t.deepEqual(notes, ["Nothing to change: the trial already matches.\nNote: Plot P1 has no seed transaction"], "with the notes of the plan");
        t.ok(nothingChanges({ ...empty }), "an empty plan");
        t.notOk(nothingChanges({ ...empty, changed: 1 }), "a plan that changes a plot");
        t.end();
    });

    t.test("a file of what was planted", async (t) => {
        const form = new FormData();
        form.append("trial_design_change_accessions_file", new Blob(["plot_name,accession_name\nP1,A2\n"]), "planted.csv");
        form.append("keep_plot_names", "1");
        const sent = [];
        const requests = fakeServer([
            { warning: "Phenotypes have been stored for this trial." },
            { preview: { ...empty, changed: 1 } },
            { success: 1, ...empty, changed: 1 },
        ], sent);
        const asked = [];
        const result = await changeWithPreview("/upload", form, { confirm: (m) => { asked.push(m); return true; } });
        t.equal(result.changed, 1);
        t.deepEqual(requests.map((r) => Object.keys(r).sort().join(",")), [
            "keep_plot_names,preview,trial_design_change_accessions_file",
            "keep_plot_names,override,preview,trial_design_change_accessions_file",
            "keep_plot_names,override,trial_design_change_accessions_file",
        ], "the file is posted each time, with the answers so far");
        t.ok(requests.every((r) => r.trial_design_change_accessions_file.name === "planted.csv"), "with its name");
        t.equal(sent[0].processData, false, "as multipart/form-data");
        t.equal(sent[0].contentType, false);
        t.equal([...form.keys()].length, 2, "the form itself is not changed");
        t.ok(asked[0].startsWith("Phenotypes have been stored for this trial.\n\nChange it anyway?"), "the warning as text");
        t.end();
    });

    t.test("errors and messages of a file", async (t) => {
        fakeServer([{ error: "Required column plot_name is missing<br>" }]);
        const errors = [];
        await changeWithPreview("/upload", new FormData(), { action: "Change Accessions", alert: (m, e) => errors.push([m, e]) });
        t.deepEqual(errors, [["Change Accessions: Required column plot_name is missing<br>", "Required column plot_name is missing<br>"]], "the error from the server alone, to show as it is");
        fakeServer([{ preview: { ...empty } }]);
        const told = [];
        await changeWithPreview("/upload", new FormData(), { alert: () => t.fail("not an error"), inform: (m) => told.push(m) });
        t.deepEqual(told, ["Nothing to change: the trial already matches."]);
        t.end();
    });
});

test("changedPlots", (t) => {
    const summary = { ...empty, changes: [{ plot_name: "P1" }, { plot_name: "P2" }], renamed: [{ old_name: "P2", new_name: "Q2" }, { old_name: "P3", new_name: "Q3" }] };
    t.deepEqual(changedPlots(summary), ["P1", "Q2", "Q3"], "each plot once, by its new name");
    t.end();
});

test("plainText", (t) => {
    window.ran = false;
    t.equal(plainText("Plot &lt;b&gt;1&lt;/b&gt; is obsolete.<br>Plot 2<BR/>x<img src=x onerror='window.ran = true'>"), "Plot <b>1</b> is obsolete.\nPlot 2\nx", "lines, entities decoded, tags dropped");
    t.notOk(window.ran, "and nothing in it runs");
    t.end();
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
        const answer = confirmDialog("2 plot(s) will get another accession.\n    P1\n\nContinue?", { title: "Change Accessions", ok: "Go" });
        const dialog = jQuery(".modal").last();
        t.equal(dialog.find(".modal-title").text(), "Change Accessions");
        t.deepEqual(dialog.find("li").map((i, li) => jQuery(li).text()).get(), ["2 plot(s) will get another accession.", "    P1", "Continue?"], "one item per line, without empty lines");
        t.equal(dialog.find(".btn-primary").text(), "Go");
        dialog.find("[data-answer=yes]").trigger("click");
        t.equal(await answer, true, "yes");
        t.equal(jQuery(".modal").length, 0, "the dialog is removed");
        const no = confirmDialog("x");
        jQuery(".modal").last().find("[data-answer=no]").trigger("click");
        t.equal(await no, false, "cancel");
        const message = confirmDialog("Nothing to change.", { ok: "OK", cancel: null });
        t.equal(jQuery(".modal").last().find("[data-answer=no]").length, 0, "a message has no cancel button");
        jQuery(".modal").last().find("[data-answer=yes]").trigger("click");
        t.equal(await message, true);
        delete jQuery.fn.modal;
        t.end();
    });
});

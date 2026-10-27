-- Replicate numbers that were rewritten after the trial was created.
-- rebuild_trial_plot_replicates (FieldMap.pm, added in PR #5985, merged 2026-04-07)
-- UPDATEs the 'replicate' stockprop of plots when accessions are changed
-- (upload Change Accessions, single plot replace, and replace_stock with PR #6384).
-- audit.stockprop_audit keeps the value before and after each UPDATE.
-- For blocked designs (RCBD, Alpha, Lattice, RRC, URDD, splitplot) the rep is part
-- of the physical layout, so every row here is a plot whose replicate may now be wrong.
WITH rep_type AS (
    SELECT cvterm_id FROM cvterm JOIN cv USING (cv_id)
    WHERE cvterm.name = 'replicate' AND cv.name = 'stock_property'
), design_type AS (
    SELECT cvterm_id FROM cvterm JOIN cv USING (cv_id)
    WHERE cvterm.name = 'design' AND cv.name = 'project_property'
), changes AS (
    SELECT a.audit_ts, a.logged_in_user,
           (a.after->>'stock_id')::int AS plot_id,
           a.before->>'value' AS replicate_before,
           a.after->>'value'  AS replicate_after
    FROM audit.stockprop_audit a
    WHERE a.operation = 'UPDATE'
      AND (a.before->>'type_id')::int = (SELECT cvterm_id FROM rep_type)
      AND a.before->>'value' IS DISTINCT FROM a.after->>'value'
      AND a.audit_ts >= '2026-04-07'
)
SELECT DISTINCT ON (c.plot_id)
       p.project_id, p.name AS trial, d.value AS design,
       s.uniquename AS plot, c.replicate_before, c.replicate_after,
       c.audit_ts, c.logged_in_user
FROM changes c
JOIN stock s ON s.stock_id = c.plot_id
JOIN nd_experiment_stock nes ON nes.stock_id = s.stock_id
JOIN nd_experiment_project nep ON nep.nd_experiment_id = nes.nd_experiment_id
JOIN project p ON p.project_id = nep.project_id
LEFT JOIN projectprop d ON d.project_id = p.project_id AND d.type_id = (SELECT cvterm_id FROM design_type)
ORDER BY c.plot_id, c.audit_ts;

JSAN.use("CXGN.I18N");

if (typeof jQuery !== 'undefined' && jQuery.fn && jQuery.fn.dataTable) {
    jQuery.extend(true, jQuery.fn.dataTable.defaults, { language: {
        lengthMenu: gettext('Show _MENU_ entries'),
        search: gettext('Search:'),
        info: gettext('Showing _START_ to _END_ of _TOTAL_ entries'),
        infoEmpty: gettext('Showing 0 to 0 of 0 entries'),
        infoFiltered: gettext('(filtered from _MAX_ total entries)'),
        emptyTable: gettext('No data available in table'),
        zeroRecords: gettext('No matching records found'),
        loadingRecords: gettext('Loading...'),
        processing: gettext('Processing...'),
        paginate: { first: gettext('First'), last: gettext('Last'),
            next: gettext('Next'), previous: gettext('Previous') }
    } });
}

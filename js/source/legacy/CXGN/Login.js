JSAN.use("CXGN.I18N");

//JSAN.use('jqueryui');

function isLoggedIn() {

    var user_id;

    jQuery.ajax( {
	url: '/user/logged_in',
	async: false,
	success: function(response) {
	    if (response.error) {
		alert(response.error);
	    }
	    else {
		//alert("LOGGED IN USER: "+response.person_id);
		user_id =  response.user_id;
	    }
	},
	error: function(response) {
	    alert(gettext("An error occurred.") + " " + response);
	}
    }

	       );

    return user_id;
}

function getUserRoles() {

    var roles;

    jQuery.ajax( {
	url: '/user/get_roles',
	async: false,
	success: function(response) {
	    if (response.error) {
		alert(response.error);
	    }
	    else {
		//alert("LOGGED IN USER ROLES: "+response.roles);
		roles =  response.roles;
	    }
	},
	error: function(response) {
	    alert(gettext("An error occurred.") + " " + response);
	}
    }

	       );

    return roles;
}

function login() {


}

function logout() {


}


function setUpLogin() {

 jQuery('#working').dialog( {
    height: 80,
    width: 100,
    modal: true,
    title: gettext("Working..."),
    closeOnEscape: false,
    autoOpen: false
  });

jQuery('#login_window').dialog( {
    height: 180,
    width: 300,
    modal: true,
    title: gettext('Login'),
    autoOpen: false,
    buttons: [
      { text: gettext("Login"),
        click: function() {
          login();
        } },
      { text: gettext("Cancel"),
        click: function() {
          jQuery('#login_window').dialog("close");
        } }
    ]


  });

}

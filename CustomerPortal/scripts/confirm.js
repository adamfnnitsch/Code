$(document).ready(function () {

    $("#tbEmail").blur(function () {
        checkEmail(true)
    });

    function checkEmail(sync) {
        if (isEmail($("#tbEmail").val()))
            $("#lblEmail").hide();
        else {
            $("#lblEmail").text("Invalid Email address.").show();
            return false; // no use hitting the server right now
        }

        // check to see if the email already exists
        var output = false;

        $.ajax({
            type: 'POST',
            async: sync,
            url: '../pages/CreateAccount.aspx/CheckEmail',
            data: '{"email":"' + encodeURIComponent($("#tbEmail").val()) + '"}',
            contentType: 'application/json; charset=utf-8',
            dataType: 'json',
            success: function (b) {
                var j = JSON.parse(b.d);
                if (j == true) {
                    $("#lblEmail").text("Email already exists.").show();
                    output = false;
                } else {
                    output = true;
                }
            }
        });
        return output;
    }

    $("#tbPassConfirm").keyup(function () {
        if ($(this).val() != $("#tbPassword").val())
            $("#lblPass").show();
        else
            $("#lblPass").hide();
    });

    $("#tbPassword").keyup(function () {
        if ($(this).val() != $("#tbPassConfirm").val())
            $("#lblPass").show();
        else
            $("#lblPass").hide();

        // check if any of the values are missing and make them red?
        if ($(this).val().length < 4) // length
            $("#pass_reqs").find("label:eq(0)").css("color", "indianred");
        else
            $("#pass_reqs").find("label:eq(0)").css("color", "#333");

        if (/\d/.test($(this).val())) // digit
            $("#pass_reqs").find("label:eq(3)").css("color", "#333");
        else
            $("#pass_reqs").find("label:eq(3)").css("color", "indianred");

        if (/([A-Z])/.test($(this).val())) // upper case
            $("#pass_reqs").find("label:eq(1)").css("color", "#333");
        else
            $("#pass_reqs").find("label:eq(1)").css("color", "indianred");

        if (/([a-z])/.test($(this).val())) // lower case
            $("#pass_reqs").find("label:eq(2)").css("color", "#333");
        else
            $("#pass_reqs").find("label:eq(2)").css("color", "indianred");

    });

    function isEmail(email) {
        var EmailRegex = /^([a-zA-Z0-9_.+-])+\@(([a-zA-Z0-9-])+\.)+([a-zA-Z0-9]{2,4})+$/;
        return EmailRegex.test(email);
    }

    function getFields() {
        return '"email":"' + encodeURIComponent($("#tbEmail").val()) + '","password":"' + encodeURIComponent($("#tbPassword").val()) + '","first_nm":"' + encodeURIComponent($("#tbFirstNm").val()) + '","last_nm":"' + encodeURIComponent($("#tbLastNm").val()) + '","street1":"' + encodeURIComponent($("#tbStreet1").val()) + '","street2":"' + encodeURIComponent($("#tbStreet2").val()) + '","city":"' + encodeURIComponent($("#tbCity").val()) + '","state":"' + encodeURIComponent($("#ddState option:selected").val()) + '","zip":"' + encodeURIComponent($("#tbZip").val()) + '","phone":"' + encodeURIComponent($("#tbPhone").val()) + '"';
    }

    function validateFields() {
        if (!checkEmail(false))
            return false;
        if ($("#tbPassConfirm").val() != $("#tbPassword").val())
            return false;
        if ($("#tbPassword").val().length < 4)
            return false;
        var passEx = /^(?=.*\d)(?=.*[a-z])(?=.*[A-Z])(?=.*[a-zA-Z]).{4,}$/;
        if (!passEx.test($("#tbPassword").val()))
            return false;
        if ($.trim($("#tbFirstNm").val()) == "")
            return false;
        if ($.trim($("#tbLastNm").val()) == "")
            return false;
        return true;
    }

    $("#btnSave").click(function () {
        saveInformation();
    });

    function saveInformation() {
        if (validateFields()) {
            // save the info into a dictionary and the json file
            $.ajax({
                type: 'POST',
                async: true,
                url: '../pages/CreateAccount.aspx/SaveFields',
                data: '{' + getFields() + '}',
                contentType: 'application/json; charset=utf-8',
                dataType: 'json',
                success: function (b) {
                    var j = JSON.parse(b.d);
                    if (j == true) {
                        // show the redirection on save
                        $("#div_main").hide();
                        $("#div_message").show();
                        setTimeout(function () { window.location.href = "../pages/Login.aspx" }, 3000);
                    } else {
                        // there was an error saving the information
                    }

                }
            });
        }
    }

});
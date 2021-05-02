$(document).ready(function () {

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

    function getFields() {
        return '"email":"' + encodeURIComponent($("#tbEmail").val()) + '","password":"' + encodeURIComponent($("#tbPassword").val()) + '","first_nm":"' + encodeURIComponent($("#tbFirstNm").val()) + '","last_nm":"' + encodeURIComponent($("#tbLastNm").val()) + '","street1":"' + encodeURIComponent($("#tbStreet1").val()) + '","street2":"' + encodeURIComponent($("#tbStreet2").val()) + '","city":"' + encodeURIComponent($("#tbCity").val()) + '","state":"' + encodeURIComponent($("#ddState option:selected").val()) + '","zip":"' + encodeURIComponent($("#tbZip").val()) + '","phone":"' + encodeURIComponent($("#tbPhone").val()) + '"';
    }

    function validateFields() {
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

    function loadAuditLog() {
        $.ajax({
            type: 'POST',
            async: true,
            url: '../pages/AccountView.aspx/GetAuditLog',
            data: '{}',
            contentType: 'application/json; charset=utf-8',
            dataType: 'json',
            success: function (b) {
                var j = JSON.parse(b.d);

                // show the redirection on save
                var tmpl = $.templates("#tmplAudit");
                var html = tmpl.render(j);
                $("#tblAudit").html(html);


            }
        });
    }

    function saveInformation() {
        if (validateFields()) {
            // save the info into a dictionary and the json file
            $.ajax({
                type: 'POST',
                async: true,
                url: '../pages/AccountView.aspx/SaveFields',
                data: '{' + getFields() + '}',
                contentType: 'application/json; charset=utf-8',
                dataType: 'json',
                success: function (b) {
                    var j = JSON.parse(b.d);
                    if (j == true) {
                        // show the redirection on save
                        
                    } else {
                        // there was an error saving the information
                    }
                    loadAuditLog();
                }
            });
        }
    }
    loadAuditLog();
});
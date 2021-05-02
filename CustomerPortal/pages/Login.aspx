<%@ Page Language="C#" AutoEventWireup="true" %>

<!DOCTYPE html>
<script runat="server">

    protected void Page_Load(object sender, EventArgs e)
    {
        // only load the json info in if the email and password match
    }

    protected void btnLogin_Click(object sender, EventArgs e)
    {
        if (string.IsNullOrWhiteSpace(tbPass.Text) || string.IsNullOrWhiteSpace(tbUser.Text))
        {
            lblErr.Visible = true;
            return;
        }

        string user_nfo = System.IO.File.ReadAllText(Server.MapPath("~/resx/login.json"));
        List<Dictionary<string, string>> login_info = Newtonsoft.Json.JsonConvert.DeserializeObject<List<Dictionary<string, string>>>(user_nfo);

        var exist = (from dict in login_info
                     from keyval in dict
                     where (keyval.Key == "Email" && keyval.Value == tbUser.Text)
                     select dict).ToArray();

        if (exist.Count() == 0)
        {
            lblErr.Visible = true;
            return;
        }

        if (exist[0]["Password"] != tbPass.Text)
        {
            lblErr.Visible = true;
            return;
        }

        Common.InsertAudit(tbUser.Text.Trim(), "Logged In");

        //AuditDB db_audit = new AuditDB();
        //db_audit.Email = tbUser.Text.Trim();
        //db_audit.insert_dt = DateTime.Now;
        //db_audit.audit_type = "User created";

        //string audit = System.IO.File.ReadAllText(System.Web.Hosting.HostingEnvironment.MapPath("~/resx/audit.json"));
        //string output = Newtonsoft.Json.JsonConvert.SerializeObject(db_audit);

        //if (!string.IsNullOrWhiteSpace(output))
        //    System.IO.File.WriteAllText(System.Web.Hosting.HostingEnvironment.MapPath("~/resx/audit.json"), audit.Substring(0, audit.Length - 1) + ((audit.Length != 2) ? "," : "") + output + "]");

        Session["LoggedIn"] = "1";
        LoginDB db = new LoginDB();
        db.Email = exist[0]["Email"];
        db.Password = exist[0]["Password"];
        db.First_nm = exist[0]["First_nm"];
        db.Last_nm = exist[0]["Last_nm"];
        db.Street1 = exist[0]["Street1"];
        db.Street2 = exist[0]["Street2"];
        db.City = exist[0]["City"];
        db.State = exist[0]["State"];
        db.Zip = exist[0]["Zip"];
        db.Phone = exist[0]["Phone"];

        Session["login_info"] = db;

        Response.Redirect("AccountView.aspx");
        Response.End();
    }
</script>


<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Customer Portal - Login</title>
    <link href="../style/main.css" rel="stylesheet" type="text/css" />
</head>
<body>
    <form id="form1" runat="server">
        <div class="border">
            <table class="login_tbl">
                <tr>
                    <td>
                        Email:
                    </td>
                    <td>
                        <asp:TextBox runat="server" ID="tbUser" CssClass="textbox_hidden" />
                    </td>
                </tr>
                <tr>
                    <td>
                        Password:
                    </td>
                    <td>
                        <asp:TextBox runat="server" ID="tbPass" TextMode="Password" CssClass="textbox_hidden"></asp:TextBox>
                    </td>
                </tr>
                <tr>
                    <td colspan="2">
                        <asp:Button runat="server" ID="btnLogin" Text="Login" CssClass="login_btn" OnClick="btnLogin_Click" />
                    </td>
                </tr>
                <tr>
                    <td colspan="2">
                        <asp:Label runat="server" ID="lblErr" Text="Invalid Login Info" CssClass="pass_req red" Visible="false"></asp:Label>
                    </td>
                </tr>
                <tr>
                    <td colspan="2">
                        <a href="CreateAccount.aspx" class="link">Click here to create an account.</a>
                    </td>
                </tr>
            </table>
        </div>
    </form>
</body>
</html>

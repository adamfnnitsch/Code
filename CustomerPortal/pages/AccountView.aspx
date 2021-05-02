<%@ Page Language="C#" AutoEventWireup="true" %>

<!DOCTYPE html>
<script runat="server">

    protected void Page_Load(object sender, EventArgs e)
    {
        if (string.IsNullOrEmpty((Session["LoggedIn"] + "").ToString()))
        {
            Response.Redirect("Login.aspx");
            Response.End();
            return;
        }

        if (!IsPostBack)
        {
            // build the state drop down
            string states = System.IO.File.ReadAllText(Server.MapPath("~/resx/states.json"));
            Dictionary<string, string> dict_states = Newtonsoft.Json.JsonConvert.DeserializeObject<Dictionary<string, string>>(states);
            foreach (string state in dict_states.Keys)
            {
                ddState.Items.Add(new ListItem(dict_states[state], state));
            }
        }

        // load the session information for the audit and make it down below
        LoginDB db_log = (LoginDB)Session["login_info"];

        tbEmail.Text = lblEmail.Text = db_log.Email;
        tbPassword.Attributes.Add("value", db_log.Password);
        tbPassConfirm.Attributes.Add("value", db_log.Password);
        tbFirstNm.Text = db_log.First_nm;
        tbLastNm.Text = db_log.Last_nm;
        tbStreet1.Text = db_log.Street1;
        tbStreet2.Text = db_log.Street2;
        tbCity.Text = db_log.City;
        ddState.SelectedValue = db_log.State;
        tbZip.Text = db_log.Zip;
        tbPhone.Text = db_log.Phone;

        // set the audit here into the memory
        string audits = System.IO.File.ReadAllText(Server.MapPath("~/resx/audit.json"));
        List<Dictionary<string, string>> dict_audit = Newtonsoft.Json.JsonConvert.DeserializeObject<List<Dictionary<string, string>>>(audits);
        var xtr = (from dict in dict_audit
                   from keyval in dict
                   where keyval.Key == "Email" && keyval.Value == tbEmail.Text
                   select dict).OrderByDescending(x => x["insert_dt"]).ToList();

        Session["audit"] = xtr;
    }

    [System.Web.Services.WebMethod(EnableSession = true)]
    public static string SaveFields(string email, string password, string first_nm, string last_nm, string street1, string street2, string city, string state, string zip, string phone)
    {
        // this isn't really neccessary to declare this
        LoginDB db_log = (LoginDB)HttpContext.Current.Session["login_info"];
        db_log.Email = HttpUtility.UrlDecode(email);
        if (db_log.Password != HttpUtility.UrlDecode(password))
        {
            db_log.Password = HttpUtility.UrlDecode(password);
            Common.InsertAudit(db_log.Email, "Password changed");
        }
        if (db_log.First_nm != HttpUtility.UrlDecode(first_nm))
        {
            db_log.First_nm = HttpUtility.UrlDecode(first_nm);
            Common.InsertAudit(db_log.Email, "First Name changed");
        }
        if (db_log.Last_nm != HttpUtility.UrlDecode(last_nm))
        {
            db_log.Last_nm = HttpUtility.UrlDecode(last_nm);
            Common.InsertAudit(db_log.Email, "Last Name changed");
        }
        if (db_log.Street1 != HttpUtility.UrlDecode(street1))
        {
            db_log.Street1 = HttpUtility.UrlDecode(street1);
            Common.InsertAudit(db_log.Email, "Street1 changed");
        }
        if (db_log.Street2 != HttpUtility.UrlDecode(street2))
        {
            db_log.Street2 = HttpUtility.UrlDecode(street2);
            Common.InsertAudit(db_log.Email, "Street2 changed");
        }
        if (db_log.City != HttpUtility.UrlDecode(city))
        {
            db_log.City = HttpUtility.UrlDecode(city);
            Common.InsertAudit(db_log.Email, "City changed");
        }
        if (db_log.State != HttpUtility.UrlDecode(state))
        {
            db_log.State = HttpUtility.UrlDecode(state);
            Common.InsertAudit(db_log.Email, "State changed");
        }
        if (db_log.Zip != HttpUtility.UrlDecode(zip))
        {
            db_log.Zip = HttpUtility.UrlDecode(zip);
            Common.InsertAudit(db_log.Email, "Zip changed");
        }
        if (db_log.Phone != HttpUtility.UrlDecode(phone))
        {
            db_log.Phone = HttpUtility.UrlDecode(phone);
            Common.InsertAudit(db_log.Email, "Phone changed");
        }

        HttpContext.Current.Session["login_info"] = db_log;

        //string output = Newtonsoft.Json.JsonConvert.SerializeObject(db_log);
        string all = System.IO.File.ReadAllText(System.Web.Hosting.HostingEnvironment.MapPath("~/resx/login.json"));
        List<Dictionary<string, string>> dict_login = Newtonsoft.Json.JsonConvert.DeserializeObject<List<Dictionary<string, string>>>(all);
        string output = "[";
        for (int i = 0; i < dict_login.Count(); i++)
        {
            if (output != "[")
                output += ",";
            if (dict_login[i]["Email"] == db_log.Email)
            {
                output += Newtonsoft.Json.JsonConvert.SerializeObject(db_log);
            }
            else
            {
                output += Newtonsoft.Json.JsonConvert.SerializeObject(dict_login[i]);
            }
        }

        System.IO.File.WriteAllText(System.Web.Hosting.HostingEnvironment.MapPath("~/resx/login.json"), output + "]");

        // update the audit session audit
        string audits = System.IO.File.ReadAllText(System.Web.Hosting.HostingEnvironment.MapPath("~/resx/audit.json"));
        List<Dictionary<string, string>> dict_audit = Newtonsoft.Json.JsonConvert.DeserializeObject<List<Dictionary<string, string>>>(audits);
        var xtr = (from dict in dict_audit
                   from keyval in dict
                   where keyval.Key == "Email" && keyval.Value == db_log.Email
                   select dict).OrderByDescending(x => x["insert_dt"]).ToList();

        HttpContext.Current.Session["audit"] = xtr;

        return "true";
    }

    [System.Web.Services.WebMethod(EnableSession = true)]
    public static string GetAuditLog() //string sort_field, string sort_dir, string page_num) // for simplicity, maybe not do paging and sorting dyanmically right now
    {
        List<Dictionary<string, string>> db_audit = (List<Dictionary<string, string>>)HttpContext.Current.Session["audit"];
        return Newtonsoft.Json.JsonConvert.SerializeObject(db_audit);
    }

    protected void btnLogout_Click(object sender, EventArgs e)
    {
        Common.InsertAudit(lblEmail.Text, "Logged Out");
        Session.Clear();
        Response.Redirect("Login.aspx");
        Response.End();
    }
</script>


<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Customer Portal - Account View</title>
    <link href="../style/main.css" rel="stylesheet" type="text/css" />
    <script src="../scripts/jquery.3.6.0.js"></script>
    <script src="../scripts/jsRender.js"></script>
    <script src="../scripts/view.js"></script>
</head>
<body>
    <form id="form1" runat="server">
        <div class="very_top">
            <asp:Button runat="server" ID="btnLogout" Text="Log Out" CssClass="cancel_btn" OnClick="btnLogout_Click" />
        </div>
        <div class="border more_width">
            <table class="login_tbl more_width label_change_create" id="div_main">
                <tr>
                    <td>
                        <label><b>Email:</b></label></td>
                    <td>
                        <asp:TextBox runat="server" ID="tbEmail" TextMode="Email" CssClass="hide"></asp:TextBox>
                        <asp:Label runat="server" ID="lblEmail"></asp:Label>
                    </td>
                    <td></td>
                </tr>
                <tr>
                    <td>
                        <label><b>Enter Password:</b></label></td>
                    <td>
                        <asp:TextBox runat="server" ID="tbPassword" TextMode="Password"></asp:TextBox></td>
                    <td>
                        <label class="pass_req">Password must be:</label>
                        <ul id="pass_reqs">
                            <li>
                                <label class="pass_req">Atleast 4 Characters</label>
                            </li>
                            <li>
                                <label class="pass_req">1 Upper Character</label>
                            </li>
                            <li>
                                <label class="pass_req">1 Lower Character</label>
                            </li>
                            <li>
                                <label class="pass_req">1 number</label>
                            </li>
                        </ul>
                    </td>
                </tr>
                <tr>
                    <td>
                        <label><b>Confirm Password:</b></label></td>
                    <td>
                        <asp:TextBox runat="server" ID="tbPassConfirm" TextMode="Password"></asp:TextBox></td>
                    <td>
                        <label id="lblPass" class="pass_req no_match message">Passwords do not match.</label></td>
                </tr>
                <tr>
                    <td>
                        <label><b>First Name:</b></label></td>
                    <td colspan="2">
                        <asp:TextBox runat="server" ID="tbFirstNm"></asp:TextBox></td>
                </tr>
                <tr>
                    <td>
                        <label><b>Last Name:</b></label></td>
                    <td colspan="2">
                        <asp:TextBox runat="server" ID="tbLastNm"></asp:TextBox></td>
                </tr>
                <tr>
                    <td>
                        <label>Street Address:</label></td>
                    <td colspan="2">
                        <asp:TextBox runat="server" ID="tbStreet1"></asp:TextBox></td>
                </tr>
                <tr>
                    <td>
                        <label>Street Address 2:</label></td>
                    <td colspan="2">
                        <asp:TextBox runat="server" ID="tbStreet2"></asp:TextBox></td>
                </tr>
                <tr>
                    <td>
                        <label>City:</label></td>
                    <td colspan="2">
                        <asp:TextBox runat="server" ID="tbCity"></asp:TextBox></td>
                </tr>
                <tr>
                    <td>
                        <label>State:</label></td>
                    <td colspan="2">
                        <asp:DropDownList runat="server" ID="ddState"></asp:DropDownList></td>
                </tr>
                <tr>
                    <td>
                        <label>Zip Code:</label></td>
                    <td colspan="2">
                        <asp:TextBox runat="server" ID="tbZip"></asp:TextBox></td>
                </tr>
                <tr>
                    <td>
                        <label>Phone Number:</label></td>
                    <td colspan="2">
                        <asp:TextBox runat="server" ID="tbPhone"></asp:TextBox></td>
                </tr>
                <tr>
                    <td></td>
                    <td>
                        <input type="button" value="Save" id="btnSave" class="login_btn" /></td>
                </tr>
            </table>
        </div>
        <div></div>
        <div class="border more_width">
            <table class="login_tbl more_width label_change_create">
                <thead>
                    <tr>
                        <td>Action
                        </td>
                        <td>Date Time
                        </td>
                    </tr>
                </thead>
                <tbody id="tblAudit">
                </tbody>
            </table>
        </div>
        <script id="tmplAudit" type="text/x-jsrender">
            <tr>
                <td>{{:audit_type}}</td>
                <td>{{:insert_dt}}</td>
            </tr>
        </script>
    </form>

</body>
</html>

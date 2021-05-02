<%@ Page Language="C#" AutoEventWireup="true" %>

<!DOCTYPE html>
<script runat="server">

    protected void tbCancel_Click(object sender, EventArgs e)
    {
        Response.Redirect("Login.aspx");
        Response.End();
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            // build the state drop down
            string states = System.IO.File.ReadAllText(Server.MapPath("~/resx/states.json"));
            Dictionary<string, string> dict_states = Newtonsoft.Json.JsonConvert.DeserializeObject<Dictionary<string, string>>(states);
            foreach (string state in dict_states.Keys)
            {
                ddState.Items.Add(new ListItem(dict_states[state], state));
            }

            states = System.IO.File.ReadAllText(Server.MapPath("~/resx/login.json"));
            List<Dictionary<string, string>> login_info = Newtonsoft.Json.JsonConvert.DeserializeObject<List<Dictionary<string, string>>>(states);
            Session["login_info"] = login_info;
        }
    }

    [System.Web.Services.WebMethod(EnableSession = true)]
    public static string CheckEmail(string email)
    {
        // page_load pulls the info from the json file and holds it in a session, since debug = true, the session never expires
        List<Dictionary<string, string>> dict_login = (List<Dictionary<string, string>>)HttpContext.Current.Session["login_info"];
        var xtr = (from dict in dict_login
                   from keyval in dict
                   where keyval.Key == "Email" && keyval.Value == HttpUtility.UrlDecode(email)
                   select keyval).ToList();

        if (xtr.Count() == 0)
            return "false";
        return "true";

    }

    // usually double check the info, as you can edit the info in the developer view and mess stuff up, but since this isn't production, i won't validate on server side
    //[System.Web.Services.WebMethod(EnableSession = true)]
    //public static string ValidateFields(string email, string password, string first_nm, string last_nm, string street1, string street2, string city, string state, string zip, string phone)
    //{
    //    return "";
    //}

    [System.Web.Services.WebMethod(EnableSession = true)]
    public static string SaveFields(string email, string password, string first_nm, string last_nm, string street1, string street2, string city, string state, string zip, string phone)
    {
        // this isn't really neccessary to declare this
        LoginDB db_log = new LoginDB();
        db_log.Email = HttpUtility.UrlDecode(email);
        db_log.Password = HttpUtility.UrlDecode(password);
        db_log.First_nm = HttpUtility.UrlDecode(first_nm);
        db_log.Last_nm = HttpUtility.UrlDecode(last_nm);
        db_log.Street1 = HttpUtility.UrlDecode(street1);
        db_log.Street2 = HttpUtility.UrlDecode(street2);
        db_log.City = HttpUtility.UrlDecode(city);
        db_log.State = HttpUtility.UrlDecode(state);
        db_log.Zip = HttpUtility.UrlDecode(zip);
        db_log.Phone = HttpUtility.UrlDecode(phone);

        string output = Newtonsoft.Json.JsonConvert.SerializeObject(db_log);
        string all = System.IO.File.ReadAllText(System.Web.Hosting.HostingEnvironment.MapPath("~/resx/login.json"));

        if (!string.IsNullOrWhiteSpace(output))
            System.IO.File.WriteAllText(System.Web.Hosting.HostingEnvironment.MapPath("~/resx/login.json"), all.Substring(0, all.Length - 1) + ((all.Length != 2) ? "," : "") + output + "]");

        Common.InsertAudit(db_log.Email, "User Created");

        return "true";
    }

</script>


<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Customer Portal - Create Account</title>
    <link href="../style/main.css" rel="stylesheet" type="text/css" />
    <script src="../scripts/jquery.3.6.0.js"></script>
    <script src="../scripts/confirm.js"></script>
</head>
<body>
    <form id="form1" runat="server">
        <div class="border more_width">
            <table class="login_tbl more_width label_change_create" id="div_main">
                <tr>
                    <td>
                        <label><b>Enter Email:</b></label></td>
                    <td>
                        <asp:TextBox runat="server" ID="tbEmail" TextMode="Email"></asp:TextBox></td>
                    <td>
                        <label id="lblEmail" class="pass_req no_match message">Invalid Email address.</label>
                    </td>
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
                    <td>
                        <asp:Button runat="server" ID="tbCancel" Text="Cancel" OnClick="tbCancel_Click" CssClass="cancel_btn" /></td>
                    <td>
                        <input type="button" value="Save" id="btnSave" class="login_btn" /></td>
                </tr>
            </table>
            <div class="message" id="div_message">
                <label>
                    Information saved, redirecting to the login page...
                </label>
            </div>
        </div>
    </form>
</body>
</html>

using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;


public static class Common
{
    public static void InsertAudit(string email, string type)
    {
        AuditDB db_audit = new AuditDB();
        db_audit.Email = email;
        db_audit.insert_dt = DateTime.Now.ToString("MM/dd/yyyy hh:mm:ss tt");
        db_audit.audit_type = type;

        string audit = System.IO.File.ReadAllText(System.Web.Hosting.HostingEnvironment.MapPath("~/resx/audit.json"));
        string output = Newtonsoft.Json.JsonConvert.SerializeObject(db_audit);

        if (!string.IsNullOrWhiteSpace(output))
            System.IO.File.WriteAllText(System.Web.Hosting.HostingEnvironment.MapPath("~/resx/audit.json"), audit.Substring(0, audit.Length - 1) + ((audit.Length != 2) ? "," : "") + output + "]");
    }
}

public class LoginDB // usually i'd use a primary key of id here, but this just adds more complexity right now for a simple project
                     // i'm using email as the "id" to match stuff back and forth
{
    public string Email { get; set; }
    public string Password { get; set; }
    public string First_nm { get; set; }
    public string Last_nm { get; set; }
    public string Street1 { get; set; }
    public string Street2 { get; set; }
    public string City { get; set; }
    public string State { get; set; }
    public string Zip { get; set; }
    public string Phone { get; set; }
}

public class AuditDB
{
    public string Email { get; set; }
    public string insert_dt { get; set; }
    public string audit_type { get; set; }
}

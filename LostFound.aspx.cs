using System;
using System.Data;
using System.Web.UI;
using System.Web.UI.WebControls;
using _0506_1.App_Code; 
namespace _0506_1
{
    public partial class LostFound : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserID"] == null)
            {
                Response.Redirect("Login.aspx");
                return;
            }

            if (!IsPostBack)
            {
                try
                {
                    if (Session["UserName"] != null)
                    {
                        lblUserName.Text = Session["UserName"].ToString();
                    }

                    this.DataBind();

                    // 管理员判定
                    string currentUserId = Session["UserID"]?.ToString().Trim();
                    if (!string.IsNullOrEmpty(currentUserId) && currentUserId.ToLower() == "admin")
                    {
                        if (phAdminLink != null) phAdminLink.Visible = true;
                    }

                    BindData("");
                }
                catch (Exception ex)
                {
                    Response.Write("<script>alert('加载异常：" + ex.Message + "');</script>");
                }
            }
        }

        private void BindData(string condition)
        {
            // 限制死 p.PostType = 3，只捞取失物招领贴
            string sql = @"SELECT p.*, u.UserName as SellerName 
                           FROM Products p 
                           LEFT JOIN Users u ON p.SellerID = u.UserID 
                           WHERE (p.Status = 0 OR p.Status IS NULL) 
                           AND p.PostType = 3 "
                           + condition + " ORDER BY PublishDate DESC";

            DataTable dt = DBHelper.GetDataTable(sql);
            rptProducts.DataSource = dt;
            rptProducts.DataBind();
        }

        protected void btnSearch_Click(object sender, EventArgs e)
        {
            string keyword = txtSearch.Text.Trim().Replace("'", "''");
            string cond = "";
            if (!string.IsNullOrEmpty(keyword))
            {
                cond = " AND (p.ProductName LIKE '%" + keyword + "%' OR p.Description LIKE '%" + keyword + "%')";
            }
            BindData(cond);
        }

        protected void lnkLogout_Click(object sender, EventArgs e)
        {
            Session.Clear();
            Session.Abandon();
            Response.Redirect("Login.aspx");
        }
    }
}
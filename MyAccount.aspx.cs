using System;
using System.Data;
using System.Web.UI.WebControls;
using _0506_1.App_Code;

namespace _0506_1
{
    public partial class MyAccount : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                // 1. 安全校验
                if (Session["UserID"] == null)
                {
                    Response.Redirect("Login.aspx");
                    return;
                }

                // 2. 绑定用户信息
                string uid = Session["UserID"].ToString();
                lblUserName.Text = Session["UserName"]?.ToString() ?? "未知用户";
                lblUserID.Text = uid;

                // 改用现有的 GetDataTable 来查询单行积分
                string sqlUser = $"SELECT CreditScore FROM Users WHERE UserID = '{uid.Replace("'", "''")}'";
                DataTable dtUser = DBHelper.GetDataTable(sqlUser);
                if (dtUser != null && dtUser.Rows.Count > 0)
                {
                    lblCreditScore.Text = dtUser.Rows[0]["CreditScore"]?.ToString() ?? "100";
                }
                else
                {
                    lblCreditScore.Text = "100"; // 兜底初始分
                }

                // 如果是系统管理员登录，将原本的“校内学生”改为红名高亮“超级管理员”
                if (lblUserID.Text.Trim().ToLower() == "admin")
                {
                    if (litAuthInfo != null)
                    {
                        litAuthInfo.Text = "<span style='color:#d93025; font-weight:bold;'>👑 超级管理员</span>";
                    }
                }
                else
                {
                    if (litAuthInfo != null)
                    {
                        litAuthInfo.Text = "校内学生";
                    }
                }

                // 3. 绑定三部分数据
                BindMyData();
            }
        }

        private void BindMyData()
        {
            if (Session["UserID"] == null) return;
            string uid = Session["UserID"].ToString();

            // --- 绑定物品 (PostType = 0) ---
            string sqlProducts = $"SELECT * FROM Products WHERE SellerID = '{uid}' AND Status = 0 AND PostType = 0 ORDER BY PublishDate DESC";
            DataTable dtProducts = DBHelper.GetDataTable(sqlProducts);

            rptMyProducts.DataSource = dtProducts;
            rptMyProducts.DataBind();

            // 确保控件存在再赋值，防止空引用
            if (pnlNoProducts != null)
            {
                pnlNoProducts.Visible = (dtProducts == null || dtProducts.Rows.Count == 0);
            }

            // --- 🎯 完美修改：把求助贴(PostType = 4)整合进当前的数据筛选中，这样个人中心就能一并显示我发过的求助贴了 ---
            // 提示：根据你原本的代码逻辑，这里只取了 Status = 0 的。如果是需要看待审核的避雷贴，可以后期视业务需求把 Status = 3 兼容进来
            string sqlPosts = $"SELECT * FROM Products WHERE SellerID = '{uid}' AND Status = 0 AND (PostType = 1 OR PostType = 2 OR PostType = 4) ORDER BY PublishDate DESC";
            DataTable dtPosts = DBHelper.GetDataTable(sqlPosts);

            rptMyPosts.DataSource = dtPosts;
            rptMyPosts.DataBind();

            if (pnlNoPosts != null)
            {
                pnlNoPosts.Visible = (dtPosts == null || dtPosts.Rows.Count == 0);
            }

            // --- 单独绑定失物招领 (PostType = 3) ---
            string sqlLostFounds = $"SELECT * FROM Products WHERE SellerID = '{uid}' AND Status = 0 AND PostType = 3 ORDER BY PublishDate DESC";
            DataTable dtLostFounds = DBHelper.GetDataTable(sqlLostFounds);

            rptMyLostFounds.DataSource = dtLostFounds;
            rptMyLostFounds.DataBind();

            if (pnlNoLostFounds != null)
            {
                pnlNoLostFounds.Visible = (dtLostFounds == null || dtLostFounds.Rows.Count == 0);
            }
        }

        // 下架/删除操作
        protected void btnDel_Command(object sender, CommandEventArgs e)
        {
            if (e.CommandArgument == null) return;

            string pid = e.CommandArgument.ToString();
            // 逻辑删除：将 Status 设为 1
            string sql = $"UPDATE Products SET Status = 1 WHERE ProductID = {pid}";

            if (DBHelper.ExecuteNonQuery(sql) > 0)
            {
                BindMyData(); // 重新加载数据
            }
        }

        protected void btnLogout_Click(object sender, EventArgs e)
        {
            Session.Clear(); // 清除所有Session
            Session.Abandon();
            Response.Redirect("Login.aspx");
        }
    }
}
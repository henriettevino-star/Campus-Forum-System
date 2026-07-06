using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data; 
using _0506_1.App_Code; 

namespace _0506_1
{
    public partial class Login : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            // 页面加载逻辑，暂时保持空白
        }

        // 这就是你要的按钮点击事件处理程序
        protected void btnLogin_Click(object sender, EventArgs e)
        {
            // 获取输入，注意 ID 必须与 .aspx 页面保持一致
            string uid = txtUserID.Text.Trim();
            string pwd = txtPwd.Text.Trim(); // 确保前台 ID 是 txtPwd

            if (string.IsNullOrEmpty(uid) || string.IsNullOrEmpty(pwd))
            {
                Response.Write("<script>alert('请输入学号和密码！');</script>");
                return;
            }

            // 2. 查询用户信息，包含角色和状态
            string sql = $"SELECT * FROM Users WHERE UserID = '{uid}' AND Password = '{pwd}'";
            DataTable dt = DBHelper.GetDataTable(sql);

            if (dt.Rows.Count > 0)
            {
                DataRow user = dt.Rows[0];

                // 3. 校验账号状态 (防止被封禁用户登录)
                // 注意：如果数据库没这个字段会报错，请确保执行了之前的 ALTER TABLE 语句
                string status = user["UserStatus"].ToString();
                if (status == "被封禁")
                {
                    Response.Write("<script>alert('您的账号已被封禁，请联系管理员！');</script>");
                    return;
                }

                // 4. 登录成功，存入 Session
                Session["UserID"] = user["UserID"].ToString();
                Session["UserName"] = user["UserName"].ToString();
                Session["Role"] = user["Role"].ToString();

                // 5. 根据角色跳转
                if (user["Role"].ToString() == "Admin")
                {
                    Response.Redirect("AdminCenter.aspx"); // 管理员去后台
                }
                else
                {
                    Response.Redirect("Default.aspx"); // 学生去广场
                }
            }
            else
            {
                Response.Write("<script>alert('学号或密码错误！');</script>");
            }
        }
    }
}
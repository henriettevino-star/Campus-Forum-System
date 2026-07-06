using System;
using System.Data;
using _0506_1.App_Code;

namespace _0506_1
{
    public partial class ResetPassword : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            // 页面首次加载，确保干净的初始状态
        }

        // 点击验证身份
        protected void btnVerify_Click(object sender, EventArgs e)
        {
            string uid = txtUserID.Text.Trim();
            string uname = txtUserName.Text.Trim();

            if (string.IsNullOrEmpty(uid) || string.IsNullOrEmpty(uname))
            {
                ClientScript.RegisterStartupScript(this.GetType(), "msg", "alert('请把学号和姓名填写完整！');", true);
                return;
            }

            // 防止 SQL 注入的安全字符过滤处理
            string safeUid = uid.Replace("'", "''");
            string safeUname = uname.Replace("'", "''");

            // 查询数据库是否存在该学号与姓名完全匹配的学生
            string sql = $"SELECT * FROM Users WHERE UserID = '{safeUid}' AND UserName = '{safeUname}'";
            DataTable dt = DBHelper.GetDataTable(sql);

            if (dt != null && dt.Rows.Count > 0)
            {
                // 验证成功：利用 Session 悄悄记住当前正在修改哪个学生的密码
                Session["ResetTargetUID"] = safeUid;

                // 切换面板显示：隐藏输入姓名的框，显示设置新密码的框
                phVerify.Visible = false;
                phReset.Visible = true;
            }
            else
            {
                // 验证失败：学号或姓名不匹配
                ClientScript.RegisterStartupScript(this.GetType(), "msg", "alert('身份验证失败！学号与姓名不匹配，请核对后重试。');", true);
            }
        }

        //击确认重置密码
        protected void btnReset_Click(object sender, EventArgs e)
        {
            // 确保是从第一步验证过过来的，安全校验
            if (Session["ResetTargetUID"] == null)
            {
                ClientScript.RegisterStartupScript(this.GetType(), "msg", "alert('会话已过期或非法访问，请重新验证身份！'); location.href='ResetPassword.aspx';", true);
                return;
            }

            string targetUid = Session["ResetTargetUID"].ToString();
            string newPwd = txtNewPwd.Text;
            string confirmPwd = txtConfirmPwd.Text;

            if (string.IsNullOrEmpty(newPwd))
            {
                ClientScript.RegisterStartupScript(this.GetType(), "msg", "alert('新密码不能为空！');", true);
                return;
            }

            if (newPwd != confirmPwd)
            {
                ClientScript.RegisterStartupScript(this.GetType(), "msg", "alert('两次输入的新密码不一致，请重新检查！');", true);
                return;
            }

            // 安全过滤新密码
            string safePwd = newPwd.Replace("'", "''");

            // 执行密码更新命令
            string updateSql = $"UPDATE Users SET Password = '{safePwd}' WHERE UserID = '{targetUid}'";
            int result = DBHelper.ExecuteNonQuery(updateSql);

            if (result > 0)
            {
                // 修改成功后清空安全 Session 变量
                Session.Remove("ResetTargetUID");

                // 弹窗成功提示，并自动跳回登录页
                ClientScript.RegisterStartupScript(this.GetType(), "msg", "alert('密码重置成功！请使用新密码重新登录。'); location.href='Login.aspx';", true);
            }
            else
            {
                ClientScript.RegisterStartupScript(this.GetType(), "msg", "alert('系统繁忙，密码修改失败，请稍后再试！');", true);
            }
        }
    }
}
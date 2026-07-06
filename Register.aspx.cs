using System;
using System.Data;
using System.Web.UI;
using _0506_1.App_Code;

namespace _0506_1
{
    public partial class Register : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                lblMsg.Text = "";
            }
        }

        // 检查学号是否被注册过
        protected void btnCheckID_Click(object sender, EventArgs e)
        {
            string uid = txtUserID.Text.Trim();
            if (string.IsNullOrEmpty(uid))
            {
                lblMsg.ForeColor = System.Drawing.Color.Red;
                lblMsg.Text = "⚠️ 请先输入学号再进行检查！";
                return;
            }

            // 查询用户表看该学号是否存在
            string sql = $"SELECT 1 FROM Users WHERE UserID = '{uid.Replace("'", "''")}'";
            DataTable dt = DBHelper.GetDataTable(sql);

            if (dt.Rows.Count > 0)
            {
                lblMsg.ForeColor = System.Drawing.Color.Red;
                lblMsg.Text = "❌ 该学号已被注册，请直接登录！";
            }
            else
            {
                lblMsg.ForeColor = System.Drawing.Color.Green;
                lblMsg.Text = "✅ 该学号尚未注册，可以继续填写！";
            }
        }

        // 实名核对并提交注册
        protected void btnRegister_Click(object sender, EventArgs e)
        {
            string uid = txtUserID.Text.Trim();
            string uname = txtUserName.Text.Trim();
            string pwd = txtPwd.Text.Trim();
            string pwd2 = txtPwdConfirm.Text.Trim();

            // 1. 防呆非空校验
            if (string.IsNullOrEmpty(uid) || string.IsNullOrEmpty(uname) || string.IsNullOrEmpty(pwd) || string.IsNullOrEmpty(pwd2))
            {
                Response.Write("<script>alert('所有信息均不能为空，请填写完整！');</script>");
                return;
            }

            // 2. 两次密码一致性校验
            if (pwd != pwd2)
            {
                Response.Write("<script>alert('两次输入的密码不一致，请重新核对！');</script>");
                return;
            }

            // 核对学号与姓名在预存学生表 Students 里是否匹配
            string sqlCheckStudent = $"SELECT 1 FROM Students WHERE StudentID = '{uid.Replace("'", "''")}' AND StudentName = '{uname.Replace("'", "''")}'";
            DataTable dtStudent = DBHelper.GetDataTable(sqlCheckStudent);

            if (dtStudent.Rows.Count == 0)
            {
                Response.Write("<script>alert('注册失败：学号与姓名不匹配，非本校合规学生！');</script>");
                return;
            }

            // 4. 二次查重拦截（防止用户不点击“检查按钮”直接点注册）
            string sqlCheckExist = $"SELECT 1 FROM Users WHERE UserID = '{uid.Replace("'", "''")}'";
            if (DBHelper.GetDataTable(sqlCheckExist).Rows.Count > 0)
            {
                Response.Write("<script>alert('该学号已被注册！');</script>");
                return;
            }

            // 5. 校验通过，写入用户表，初始状态赋予“正常”
            string sqlInsert = $"INSERT INTO Users (UserID, UserName, Password, Role, UserStatus) VALUES ('{uid.Replace("'", "''")}', '{uname.Replace("'", "''")}', '{pwd.Replace("'", "''")}', 'Student', '正常')";
            int result = DBHelper.ExecuteNonQuery(sqlInsert); // 假设你的DBHelper有增删改的方法

            if (result > 0)
            {
                // 6. 成功后，弹出提示并平滑返回登录界面
                Response.Write("<script>alert('注册成功！欢迎加入校园互助集市，正在跳转至登录页...'); window.location.href='Login.aspx';</script>");
            }
            else
            {
                Response.Write("<script>alert('服务器繁忙，注册失败，请稍后重试！');</script>");
            }
        }
    }
}
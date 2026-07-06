<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Login.aspx.cs" Inherits="_0506_1.Login" %>

<!DOCTYPE html>
<html>
<head runat="server">
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
    <title>欢迎登录 - 校园论坛</title>
    <style>
        body { 
            background-color: #FFFDF2;
            font-family: "Microsoft YaHei"; 
            margin: 0; 
            display: flex; 
            justify-content: center; 
            align-items: center; 
            height: 100vh; 
        }
        .login-card { 
            background: white; 
            padding: 40px; 
            border-radius: 20px; 
            box-shadow: 0 10px 30px rgba(255, 152, 0, 0.1); 
            width: 350px; 
            border: 1px solid #FFECB3; 
        }
        h2 { text-align: center; color: #FF9800; margin-bottom: 30px; }
        .input-group { margin-bottom: 20px; }
        .input-group label { display: block; margin-bottom: 8px; color: #666; font-size: 14px; }
        .input-ctrl { 
            width: 100%; padding: 12px; border: 1px solid #ddd; border-radius: 8px; 
            box-sizing: border-box; outline: none; transition: 0.3s;
        }
        .input-ctrl:focus { border-color: #FF9800; box-shadow: 0 0 5px rgba(255,152,0,0.2); }
        .btn-login { 
            width: 100%; padding: 12px; background: #FF9800; color: white; 
            border: none; border-radius: 8px; font-weight: bold; cursor: pointer; margin-top: 10px;
        }
        .btn-login:hover { background: #F57C00; }
        .footer-links { text-align: center; margin-top: 20px; font-size: 13px; color: #999; }
        .footer-links a { color: #FF9800; text-decoration: none; }
        /*为分割线稍微加点间距样式 */
        .split-line { margin: 0 8px; color: #ddd; }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div class="login-card">
            <h2>校内论坛登录</h2>
            <div class="input-group">
                <label>学号 / 账号</label>
                <asp:TextBox ID="txtUserID" runat="server" CssClass="input-ctrl" placeholder="请输入学号"></asp:TextBox>
            </div>
            <div class="input-group">
                <label>登录密码</label>
                <asp:TextBox ID="txtPwd" runat="server" CssClass="input-ctrl" TextMode="Password" placeholder="请输入密码"></asp:TextBox>
            </div>
            <asp:Button ID="btnLogin" runat="server" Text="立即登录" OnClick="btnLogin_Click" CssClass="btn-login" />
            
            <%--在立即注册后面用分割线并列加上“忘记密码”链接 --%>
            <div class="footer-links">
                还没有账号？<a href="Register.aspx">立即注册</a>
                <span class="split-line">|</span>
                <a href="ResetPassword.aspx" style="color: #6c757d;">忘记密码？</a>
            </div>
            
            <asp:Label ID="lblMsg" runat="server" ForeColor="Red" style="display:block; text-align:center; margin-top:10px; font-size:12px;"></asp:Label>
        </div>
    </form>
</body>
</html>
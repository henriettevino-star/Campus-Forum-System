<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Register.aspx.cs" Inherits="_0506_1.Register" %>

<!DOCTYPE html>
<html>
<head runat="server">
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
    <title>新用户注册 - 校园互助平台</title>
    <style>
        body { 
            background-color: #F2F9F3; /* 淡绿色背景 */
            font-family: "Microsoft YaHei"; 
            margin: 0; 
            display: flex; 
            justify-content: center; 
            align-items: center; 
            height: 100vh; 

        }
        .register-card { 
            background: white; 
            padding: 35px; 
            border-radius: 20px; 
            box-shadow: 0 10px 30px rgba(40, 167, 69, 0.08); /* 绿调淡阴影 */
            width: 360px; 
            border: 1px solid #C3E6CB; /* 边框颜色 */
        }
        h2 { text-align: center; color: #28a745; margin-bottom: 25px; } /* 绿色标题 */
        .input-group { margin-bottom: 15px; }
        .input-group label { display: block; margin-bottom: 6px; color: #555; font-size: 14px; font-weight: bold; }
        
        /* 带检测按钮的学号输入布局 */
        .uid-container { display: flex; gap: 10px; }
        
        .input-ctrl { 
            width: 100%; padding: 10px 12px; border: 1px solid #ddd; border-radius: 8px; 
            box-sizing: border-box; outline: none; transition: 0.3s; font-size: 14px;
        }
        .input-ctrl:focus { border-color: #28a745; box-shadow: 0 0 5px rgba(40,167,69,0.2); }
        
        /* 检查账号专用小按钮 */
        .btn-check {
            white-space: nowrap; padding: 0 15px; background: #e2f5e6; color: #28a745;
            border: 1px solid #28a745; border-radius: 8px; font-weight: bold; cursor: pointer; transition: 0.3s;
        }
        .btn-check:hover { background: #28a745; color: white; }
        
        /* 注册大按钮 */
        .btn-register { 
            width: 100%; padding: 12px; background: #28a745; color: white; 
            border: none; border-radius: 8px; font-weight: bold; cursor: pointer; margin-top: 15px; font-size: 16px;
        }
        .btn-register:hover { background: #218838; }
        
        .footer-links { text-align: center; margin-top: 15px; font-size: 13px; color: #999; }
        .footer-links a { color: #28a745; text-decoration: none; font-weight: bold; }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div class="register-card">
            <h2>校内账号注册</h2>
            
            <div class="input-group">
                <label>学生学号</label>
                <div class="uid-container">
                    <asp:TextBox ID="txtUserID" runat="server" CssClass="input-ctrl" placeholder="请输入学号"></asp:TextBox>
                    <asp:Button ID="btnCheckID" runat="server" Text="检查学号" OnClick="btnCheckID_Click" CssClass="btn-check" />
                </div>
            </div>
            
            <div class="input-group">
                <label>真实姓名</label>
                <asp:TextBox ID="txtUserName" runat="server" CssClass="input-ctrl" placeholder="请输入教务系统真实姓名"></asp:TextBox>
            </div>
            
            <div class="input-group">
                <label>设置密码</label>
                <asp:TextBox ID="txtPwd" runat="server" CssClass="input-ctrl" TextMode="Password" placeholder="请设置登录密码"></asp:TextBox>
            </div>
            
            <div class="input-group">
                <label>确认密码</label>
                <asp:TextBox ID="txtPwdConfirm" runat="server" CssClass="input-ctrl" TextMode="Password" placeholder="请再次输入密码"></asp:TextBox>
            </div>
            
            <asp:Button ID="btnRegister" runat="server" Text="提交注册" OnClick="btnRegister_Click" CssClass="btn-register" />
            
            <div class="footer-links">
                已有账号？<a href="Login.aspx">返回登录</a>
            </div>
            
            <asp:Label ID="lblMsg" runat="server" style="display:block; text-align:center; margin-top:10px; font-size:13px; font-weight:bold;"></asp:Label>
        </div>
    </form>
</body>
</html>
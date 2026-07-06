<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ResetPassword.aspx.cs" Inherits="_0506_1.ResetPassword" %>

<!DOCTYPE html>
<html>
<head runat="server">
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
    <title>找回并重置密码</title>
    <style>
        body { font-family: 'Microsoft YaHei'; background-color: #f4f7f6; padding: 50px 0; color: #333; }
        .reset-container { max-width: 450px; margin: 0 auto; background: #fff; padding: 30px; border-radius: 8px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
        .form-group { margin-bottom: 20px; }
        .form-group label { display: block; margin-bottom: 8px; font-weight: bold; font-size: 14px; }
        .form-control { width: 100%; padding: 10px; border: 1px solid #ced4da; border-radius: 4px; box-sizing: border-box; font-size: 14px; }
        .btn-submit { width: 100%; padding: 12px; background-color: #007bff; color: white; border: none; border-radius: 4px; font-weight: bold; cursor: pointer; font-size: 15px; }
        .btn-submit:hover { background-color: #0056b3; }
        .back-link { display: block; text-align: center; margin-top: 20px; color: #6c757d; text-decoration: none; font-size: 13px; }
        .back-link:hover { text-decoration: underline; }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div class="reset-container">
            <h2 style="text-align:center; color:#333; margin-bottom:30px;">🔐 找回并重置密码</h2>

            <asp:PlaceHolder ID="phVerify" runat="server" Visible="true">
                <div class="form-group">
                    <label>学号 / 账号</label>
                    <asp:TextBox ID="txtUserID" runat="server" CssClass="form-control" placeholder="请输入您的学号"></asp:TextBox>
                </div>
                <div class="form-group">
                    <label>真实姓名</label>
                    <asp:TextBox ID="txtUserName" runat="server" CssClass="form-control" placeholder="请输入您的真实姓名"></asp:TextBox>
                </div>
                <asp:Button ID="btnVerify" runat="server" Text="验证身份" CssClass="btn-submit" OnClick="btnVerify_Click" />
            </asp:PlaceHolder>

            <asp:PlaceHolder ID="phReset" runat="server" Visible="false">
                <div style="background-color: #e6f4ea; border: 1px solid #34a853; color: #137333; padding: 10px; border-radius: 4px; margin-bottom: 20px; font-size: 13px; text-align: center;">
                    身份验证成功！请设置您的新密码。
                </div>
                <div class="form-group">
                    <label>新密码</label>
                    <asp:TextBox ID="txtNewPwd" runat="server" CssClass="form-control" TextMode="Password" placeholder="请输入新密码"></asp:TextBox>
                </div>
                <div class="form-group">
                    <label>确认新密码</label>
                    <asp:TextBox ID="txtConfirmPwd" runat="server" CssClass="form-control" TextMode="Password" placeholder="请再次输入新密码"></asp:TextBox>
                </div>
                <asp:Button ID="btnReset" runat="server" Text="确认修改密码" CssClass="btn-submit" style="background-color:#28a745;" OnClick="btnReset_Click" />
            </asp:PlaceHolder>

            <asp:HyperLink ID="lnkBack" runat="server" NavigateUrl="Login.aspx" CssClass="back-link"><< 返回登录广场</asp:HyperLink>
        </div>
    </form>
</body>
</html>
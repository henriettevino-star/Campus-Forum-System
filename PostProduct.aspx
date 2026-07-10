<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="PostProduct.aspx.cs" Inherits="_0506_1.PostProduct" %>

<!DOCTYPE html>
<html>
<head runat="server">
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
    <title>发布帖子 - 校园二手市场</title>
    <style>

        /* 整体背景*/

        body { 
            background-color: #F4F9FD; 
            font-family: 'Segoe UI', 'Microsoft YaHei', sans-serif; 
            margin: 0; 
            padding-bottom: 50px;
        }

        /* 导航栏高亮和边框 */
        .nav-top { 
            background-color: #ffffff; 
            padding: 15px 0; 
            text-align: center; 
            max-width: 1100px; 
            margin: 20px auto; 
            border-radius: 15px; 
            border: 2px solid #3498DB; 
            box-shadow: 0 8px 25px rgba(52, 152, 219, 0.12); 
        }
        .nav-top a { 
            color: #555; 
            text-decoration: none; 
            margin: 0 25px; 
            font-weight: bold; 
            font-size: 1.1em; 
            transition: 0.3s;
        }
        .nav-top a:hover { color: #3498DB; }
        /* 我要发帖 */
        .nav-top a[href="PostProduct.aspx"] { color: #3498DB !important; }

        /* 3发布表单大卡片 */
        .post-container { 
            max-width: 600px; 
            margin: 30px auto; 
            background: white; 
            padding: 40px; 
            border-radius: 20px; 
            box-shadow: 0 10px 30px rgba(52, 152, 219, 0.05);
            border: 1px solid #eef3f8;
        }

        h2.form-title {
            text-align: center; 
            color: #2C3E50; 
            margin-bottom: 30px;
            font-size: 1.6em;
            letter-spacing: 1px;
        }

        /* 表单元素美化 */
        .form-group {
            margin-bottom: 20px;
        }
        .form-label {
            display: block;
            margin-bottom: 8px;
            font-weight: bold;
            color: #555;
            font-size: 0.95em;
        }
        .input-ctrl {
            width: 100%;
            padding: 12px 15px;
            border: 1px solid #d4dee5;
            border-radius: 8px;
            box-sizing: border-box; /* 防止宽度溢出 */
            font-size: 14px;
            transition: 0.3s;
            outline: none;
            background-color: #fafbfc;
        }
        .input-ctrl:focus {
            border-color: #3498DB;
            background-color: #fff;
            box-shadow: 0 0 8px rgba(52, 152, 219, 0.2);
        }

        /* 避雷专用样式 */
        #rowReport {
            background: #FFF2F1;
            padding: 15px;
            border: 1px solid #FADBD8;
            border-radius: 10px;
            margin-top: 10px;
        }

        /* 按钮美化 */
        .btn-post {
            width: 100%;
            height: 50px;
            background: linear-gradient(135deg, #4169E1 0%, #F0FFFF 100%);
            color: white;
            border: none;
            border-radius: 10px;
            font-size: 1.1em;
            font-weight: bold;
            cursor: pointer;
            margin-top: 20px;
            transition: 0.3s;
            box-shadow: 0 4px 12px rgba(44, 62, 80, 0.2);
        }
        .btn-post:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 15px rgba(44, 62, 80, 0.3);
        }

        /* 上传控件简单修饰 */
        .file-input {
            padding: 10px 0;
            color: #888;
        }
    </style>
    <script type="text/javascript">
        function switchPostMode() {
            var ddl = document.getElementById('<%= ddlPostType.ClientID %>');
            var selectedValue = ddl.value;

            // 控制价格栏的显示（避雷2、失物招领3、找同学帮忙4 隐藏）
            document.getElementById('rowPrice').style.display = (selectedValue == "2" || selectedValue == "3" || selectedValue == "4" ? 'none' : 'block');

            // 控制分类栏的显示（避雷2、失物招领3、找同学帮忙4 隐藏）
            document.getElementById('rowCategory').style.display = (selectedValue == "2" || selectedValue == "3" || selectedValue == "4" ? 'none' : 'block');

            // 控制避雷学号栏
            document.getElementById('rowReport').style.display = (selectedValue == "2" ? 'block' : 'none');

            var lbl = document.getElementById('lblName');
            if (selectedValue == "2") {
                lbl.innerText = "举报/避雷主题：";
            } else if (selectedValue == "1") {
                lbl.innerText = "想买的物品：";
            } else if (selectedValue == "3") {
                lbl.innerText = "拾获/遗失物品：";
            } else if (selectedValue == "4") {
                lbl.innerText = "需要帮忙的事项：";
            } else {
                lbl.innerText = "物品名称：";
            }
        }
        window.onload = switchPostMode;
    </script>
</head>
<body>
    <form id="form1" runat="server" enctype="multipart/form-data">
        <%-- 悬浮导航栏 --%>
        <div class="nav-top">
            <a href="Default.aspx">🛒 二手市场</a>
            <a href="LostFound.aspx">🤝 失物招领</a> 
            <a href="Community.aspx">📢 社区广场</a>
            <a href="PostProduct.aspx">➕ 我要发帖</a>
            <a href="MyAccount.aspx">👤 个人中心</a>
        </div>

        <div class="post-container">
            <h2 class="form-title">✨ 发布新的校园动态</h2>

            <div class="form-group">
                <label class="form-label">帖子类型</label>
                <asp:DropDownList ID="ddlPostType" runat="server" CssClass="input-ctrl" onchange="switchPostMode()">
                    <asp:ListItem Value="0">【出售】我要卖东西</asp:ListItem>
                    <asp:ListItem Value="1">【求购】我想买东西</asp:ListItem>
                    <asp:ListItem Value="2">【避雷】我要举报/提示风险</asp:ListItem>
                    <asp:ListItem Value="3">【招领】失物招领/寻物</asp:ListItem>
                    <asp:ListItem Value="4">【求助】找同学帮忙</asp:ListItem>
                </asp:DropDownList>
            </div>

            <div id="rowReport" style="display:none;">
                <label style="color:#C0392B; font-weight:bold; display:block; margin-bottom:5px;">🚨 被举报人的学号：</label>
                <asp:TextBox ID="txtTargetID" runat="server" CssClass="input-ctrl" placeholder="请核实后输入对方准确学号"></asp:TextBox>
            </div>

            <div class="form-group">
                <label id="lblName" class="form-label">物品名称：</label>
                <asp:TextBox ID="txtTitle" runat="server" CssClass="input-ctrl" placeholder="好的标题能吸引更多人关注哦"></asp:TextBox>
            </div>

            <div id="rowCategory" class="form-group">
                <label class="form-label">所属分类</label>
                <asp:DropDownList ID="ddlCategory" runat="server" CssClass="input-ctrl"></asp:DropDownList>
            </div>

            <div id="rowPrice" class="form-group">
                <label class="form-label">期望价格 / 预算 (￥)</label>
                <asp:TextBox ID="txtPrice" runat="server" CssClass="input-ctrl" placeholder="输入纯数字，如：99"></asp:TextBox>
            </div>

            <div class="form-group">
                <label class="form-label">详细描述</label>
                <asp:TextBox ID="txtDesc" runat="server" TextMode="MultiLine" Rows="5" CssClass="input-ctrl" placeholder="描述一下成色、交易地点等细节..."></asp:TextBox>
            </div>

            <div class="form-group">
                <label class="form-label">图片附件</label>
                <asp:FileUpload ID="fileUpload" runat="server" CssClass="file-input" AllowMultiple="true" />
            </div>

            <asp:Button ID="btnPost" runat="server" Text="确认发布并展示" OnClick="btnPost_Click" CssClass="btn-post" />
            
            <asp:Label ID="lblMsg" runat="server" ForeColor="#C0392B" style="display:block; text-align:center; margin-top:15px; font-weight:bold;"></asp:Label>
        </div>
    </form>
</body>
</html>
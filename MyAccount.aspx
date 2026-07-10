<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="MyAccount.aspx.cs" Inherits="_0506_1.MyAccount" %>

<!DOCTYPE html>
<html>
<head runat="server">
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
    <title>个人中心 - 校园二手市场</title>
    <style>

        /* 整体背景 */
        body { 
            background-color: #F8F9FA; 
            font-family: "Microsoft YaHei", sans-serif; 
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
            border: 2px solid #2C3E50; 
            box-shadow: 0 8px 25px rgba(44, 62, 80, 0.1); 
        }
        .nav-top a { 
            color: #555; 
            text-decoration: none; 
            margin: 0 25px; 
            font-weight: bold; 
            font-size: 1.1em; 
            transition: 0.3s;
        }
        .nav-top a:hover { color: #2C3E50; }
        .nav-top a[href="MyAccount.aspx"] { color: #2C3E50 !important; }

        /* 3. 布局容器 */
        .container { 
            display: flex; 
            max-width: 1100px; 
            margin: 30px auto; 
            gap: 25px; 
            align-items: flex-start;
        }

        /* 左侧侧边栏 */
        .user-sidebar { 
            width: 280px; 
            background: white; 
            padding: 35px 25px; 
            border-radius: 20px; 
            box-shadow: 0 10px 30px rgba(0,0,0,0.03); 
            text-align: center; 
            border: 1px solid #E9ECEF;
        }
        /* 头像 */
        .avatar { 
            width: 90px; 
            height: 90px; 
            background: #F1F3F5; 
            border-radius: 50%; 
            margin: 0 auto 15px; 
            line-height: 90px; 
            font-size: 45px; 
            color: #495057; 
            border: 3px solid #CED4DA;
        }
        .username { font-size: 1.2em; color: #212529; margin-bottom: 10px; }

        /* 右侧主内容区 */
        .main-content { 
            flex: 1; 
            background: white; 
            padding: 35px; 
            border-radius: 20px; 
            box-shadow: 0 10px 30px rgba(0,0,0,0.03); 
            border: 1px solid #E9ECEF;
        }

        /* 模块分隔线 */
        .tab-header { 
            border-bottom: 2px solid #E9ECEF; 
            margin-bottom: 25px; 
            padding-bottom: 12px; 
            margin-top: 30px; 
        }
        .tab-item { 
            font-size: 1.1em; 
            font-weight: bold; 
            color: #343A40; 
            border-left: 5px solid #2C3E50; 
            padding-left: 12px; 
        }

        /* 表格美化 */
        .item-list { width: 100%; border-collapse: collapse; }
        .item-list th { 
            text-align: left; 
            padding: 15px; 
            background: #F1F3F5; 
            color: #495057; 
            font-size: 0.9em;
            border-radius: 8px 8px 0 0;
        }
        .item-list td { padding: 18px 15px; border-bottom: 1px solid #F8F9FA; font-size: 0.95em; }
        .item-list tr:hover { background-color: #F8F9FA; }

        /* 🎯 新增：详情页可点击标题样式 */
        .detail-link {
            color: #212529;
            text-decoration: none;
            transition: color 0.2s ease;
        }
        .detail-link:hover {
            color: #1E88E5;
            text-decoration: underline;
        }

        /* 标签 */
        .label-post { padding: 4px 10px; border-radius: 6px; font-size: 12px; font-weight: bold; }
        .label-buy { background: #E3F2FD; color: #1E88E5; border: 1px solid #90CAF9; }
        .label-bad { background: #FFEBEE; color: #C62828; border: 1px solid #EF9A9A; }
        .label-lost { background: #FFF3E0; color: #EF6C00; border: 1px solid #FFCC80; }
        /* 🎯 新增：求助的个人中心标签，保持系统颜色一致性 */
        .label-help { background: #E8F8F5; color: #1ABC9C; border: 1px solid #A3E4D7; }
        
        .btn-logout {
            margin-top:25px; 
            padding: 10px; 
            background:#fff; 
            color:#C0392B; 
            border:1px solid #FADBD8; 
            border-radius:10px; 
            cursor:pointer; 
            font-weight:bold;
            transition: 0.3s;
        }
        .btn-logout:hover { background: #C0392B; color: white; }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <%-- 悬浮导航栏 --%>
        <div class="nav-top">
            <a href="Default.aspx">🛒 二手市场</a>
            <a href="LostFound.aspx">🤝 失物招领</a> 
            <a href="Community.aspx">📢 社区广场</a>
            <a href="PostProduct.aspx">➕ 我要发帖</a>
            <a href="MyAccount.aspx" class="active">👤 个人中心</a>
        </div>

        <div class="container">
            <%-- 左侧名片 --%>
            <div class="user-sidebar">
                <div class="avatar">👤</div>
                <div class="username">
                    <asp:Label ID="lblUserName" runat="server" Font-Bold="true"></asp:Label>
                </div>
                <div style="margin: 12px 0;">
                    <span style="color: #495057; background: #E9ECEF; padding: 4px 15px; border-radius: 12px; font-size: 12px; font-weight: bold;">
                        🌟 正式成员
                    </span>
                </div>
                <hr style="margin: 25px 0; border: 0; border-top: 1px solid #E9ECEF;" />
                <div style="text-align: left; font-size: 14px; color: #6C757D; padding-left: 10px;">
                    <p style="margin: 10px 0;">🆔 学号：<asp:Label ID="lblUserID" runat="server" ForeColor="#212529"></asp:Label></p>
                    <p style="margin: 10px 0;">📍 认证信息：<asp:Literal ID="litAuthInfo" runat="server" Text="校内 student"></asp:Literal></p>
                    <p style="margin: 10px 0; font-weight: bold; color: #212529;">🪙 信誉积分：<asp:Label ID="lblCreditScore" runat="server" ForeColor="#495057">100</asp:Label> 分</p>
                </div>
                <asp:Button ID="btnLogout" runat="server" Text="退出当前登录" OnClick="btnLogout_Click" CssClass="btn-logout" Width="100%" />
            </div>

            <%-- 右侧内容 --%>
            <div class="main-content">
                <%-- 模块 1 --%>
                <div class="tab-header" style="margin-top:0;">
                    <span class="tab-item" style="border-left-color: #2C3E50;">📦 我发布的物品 (出售中)</span>
                </div>
                <asp:Repeater ID="rptMyProducts" runat="server">
                    <HeaderTemplate>
                        <table class="item-list">
                            <tr><th>物品名称</th><th>单价</th><th>发布日期</th><th>管理操作</th></tr>
                    </HeaderTemplate>
                    <ItemTemplate>
                        <tr>
                            <%-- 🎯 完美修改：给在售物品标题套上 ProductDetail 跳转链接 --%>
                            <td>
                                <a href='<%# "ProductDetail.aspx?id=" + Eval("ProductID") %>' class="detail-link">
                                    <strong><%# Eval("ProductName") %></strong>
                                </a>
                            </td>
                            <td style="color:#C0392B; font-weight:bold;">￥<%# Eval("Price") %></td>
                            <td style="color:#888;"><%# Eval("PublishDate", "{0:yyyy-MM-dd}") %></td>
                            <td>
                                <a href='<%# "EditProduct.aspx?id=" + Eval("ProductID") %>' style="color:#1E88E5; text-decoration:none; margin-right:10px;">🖊️ 修改</a>
                                <asp:LinkButton runat="server" Text="🗑️ 下架" CommandArgument='<%# Eval("ProductID") %>' 
                                    OnCommand="btnDel_Command" OnClientClick="return confirm('确定要下架这件宝贝吗？')" style="color:#C62828; text-decoration:none;" />
                            </td>
                        </tr>
                    </ItemTemplate>
                    <FooterTemplate></table></FooterTemplate>
                </asp:Repeater>
                <asp:Panel ID="pnlNoProducts" runat="server" Visible="false" style="text-align:center; padding:30px; color:#999;">
                    💔 目前没有在售物品哦。
                </asp:Panel>

                <%-- 模块 2 --%>
                <div class="tab-header">
                    <span class="tab-item" style="border-left-color: #1E88E5;">📢 社区动态 (求购/避雷/求助)</span>
                </div>
                <asp:Repeater ID="rptMyPosts" runat="server">
                    <HeaderTemplate>
                        <table class="item-list">
                            <tr><th>板块</th><th>内容标题</th><th>发布日期</th><th>管理</th></tr>
                    </HeaderTemplate>
                    <ItemTemplate>
                        <tr>
                            <%-- 🎯 完美修改：适配 PostType = 4 (求助) 标签的输出展示样式 --%>
                            <td>
                                <span class='<%# "label-post " + (Eval("PostType").ToString() == "1" ? "label-buy" : (Eval("PostType").ToString() == "4" ? "label-help" : "label-bad")) %>'>
                                    <%# Eval("PostType").ToString() == "1" ? "求购" : (Eval("PostType").ToString() == "4" ? "求助" : "避雷") %>
                                </span>
                            </td>
                            <%-- 🎯 完美修改：给社区帖子标题套上 ProductDetail 跳转链接 --%>
                            <td>
                                <a href='<%# "ProductDetail.aspx?id=" + Eval("ProductID") %>' class="detail-link">
                                    <%# Eval("ProductName") %>
                                </a>
                            </td>
                            <td style="color:#888;"><%# Eval("PublishDate", "{0:yyyy-MM-dd}") %></td>
                            <td>
                                <asp:LinkButton runat="server" Text="删除记录" CommandArgument='<%# Eval("ProductID") %>' 
                                    OnCommand="btnDel_Command" OnClientClick="return confirm('确定要彻底删除这条帖子吗？')" style="color:#C62828; text-decoration:none;" />
                            </td>
                        </tr>
                    </ItemTemplate>
                    <FooterTemplate></table></FooterTemplate>
                </asp:Repeater>
                <asp:Panel ID="pnlNoPosts" runat="server" Visible="false" style="text-align:center; padding:30px; color:#999;">
                    💬 还没有在社区发言过。
                </asp:Panel>

                <%-- 模块 3 --%>
                <div class="tab-header">
                    <span class="tab-item" style="border-left-color: #27AE60;">🤝 失物招领 / 寻物启事</span>
                </div>
                <asp:Repeater ID="rptMyLostFounds" runat="server">
                    <HeaderTemplate>
                        <table class="item-list">
                            <tr><th>板块</th><th>内容标题</th><th>发布日期</th><th>管理</th></tr>
                    </HeaderTemplate>
                    <ItemTemplate>
                        <tr>
                            <td><span class="label-post label-lost">失物寻物</span></td>
                            <%-- 🎯 完美修改：给失物招领标题套上 ProductDetail 跳转链接 --%>
                            <td>
                                <a href='<%# "ProductDetail.aspx?id=" + Eval("ProductID") %>' class="detail-link">
                                    <strong><%# Eval("ProductName") %></strong>
                                </a>
                            </td>
                            <td style="color:#888;"><%# Eval("PublishDate", "{0:yyyy-MM-dd}") %></td>
                            <td>
                                <asp:LinkButton runat="server" Text="🤝 确认物归原主 (结帖)" CommandArgument='<%# Eval("ProductID") %>' 
                                    OnCommand="btnDel_Command" OnClientClick="return confirm('确认物品已成功送达失主/认领人并处理完毕吗？该贴将被移除展示。')" style="color:#27AE60; font-weight:bold; text-decoration:none; margin-right:10px;" />
                                <asp:LinkButton runat="server" Text="删除" CommandArgument='<%# Eval("ProductID") %>' 
                                    OnCommand="btnDel_Command" OnClientClick="return confirm('确定要删除此条失物招领贴吗？')" style="color:#999; text-decoration:underline;" />
                            </td>
                        </tr>
                    </ItemTemplate>
                    <FooterTemplate></table></FooterTemplate>
                </asp:Repeater>
                <asp:Panel ID="pnlNoLostFounds" runat="server" Visible="false" style="text-align:center; padding:30px; color:#999;">
                    🔍 目前没有发布过任何失物招领或寻物贴。
                </asp:Panel>
            </div>
        </div>
    </form>
</body>
</html>
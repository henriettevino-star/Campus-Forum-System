<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Community.aspx.cs" Inherits="_0506_1.Community" %>

<!DOCTYPE html>
<html>
<head runat="server">
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
    <title>社区广场 - 校园生活</title>
    <style>
        /* 页面背景 */
        body { 
            background-color: #FDFBFE; 
            font-family: 'Segoe UI', 'Microsoft YaHei', sans-serif; 
            margin: 0; 
            padding-top: 10px;
        }

        /* 导航栏边框与高亮 */
        .nav-top { 
            background-color: #ffffff; 
            padding: 15px 0; 
            text-align: center; 
            max-width: 1100px; 
            margin: 20px auto; 
            border-radius: 15px; 
            border: 2px solid #BB8FCE; 
            box-shadow: 0 8px 25px rgba(187, 143, 206, 0.15); 
        }
        .nav-top a { 
            color: #555; 
            text-decoration: none; 
            margin: 0 25px; 
            font-weight: bold; 
            font-size: 1.1em; 
            transition: 0.3s;
        }
        .nav-top a:hover { color: #BB8FCE; }
        /* 社区广场 */
        .nav-top a[href="Community.aspx"] { color: #BB8FCE !important; }

        /* 🔍 精心定制的淡紫色搜索栏样式结构 */
        .search-container {
            display: flex;
            justify-content: center;
            align-items: center;
            gap: 10px;
            margin: 20px 0;
            background: #ffffff;
            padding: 12px 20px;
            border-radius: 12px;
            border: 1px solid #f0e6f5;
            box-shadow: 0 4px 15px rgba(187, 143, 206, 0.05);
        }
        .search-input {
            flex: 1;
            max-width: 500px;
            padding: 10px 15px;
            border: 1px solid #E5D5ED;
            border-radius: 8px;
            font-size: 0.95em;
            outline: none;
            transition: all 0.3s ease;
            color: #333;
        }
        .search-input:focus {
            border-color: #BB8FCE;
            box-shadow: 0 0 8px rgba(187, 143, 206, 0.2);
        }
        .search-btn {
            padding: 10px 24px;
            background: linear-gradient(135deg, #CE9FFC 0%, #BB8FCE 100%);
            color: white;
            border: none;
            border-radius: 8px;
            cursor: pointer;
            font-weight: bold;
            font-size: 0.95em;
            transition: all 0.2s ease;
            box-shadow: 0 4px 12px rgba(187, 143, 206, 0.2);
        }
        .search-btn:hover {
            opacity: 0.9;
            transform: translateY(-1px);
        }

        /* 筛选选项卡样式栏 */
        .filter-tabs {
            display: flex;
            justify-content: center;
            gap: 12px;
            margin: 25px 0 30px 0;
            background: #ffffff;
            padding: 8px;
            border-radius: 12px;
            border: 1px solid #f0e6f5;
            box-shadow: 0 4px 15px rgba(187, 143, 206, 0.06);
        }
        .filter-tab-item {
            padding: 10px 22px;
            text-decoration: none;
            color: #666;
            font-weight: bold;
            font-size: 0.95em;
            border-radius: 8px;
            transition: all 0.2s ease;
            border: 1px solid transparent;
        }
        .filter-tab-item:hover {
            color: #BB8FCE;
            background: #Faf5fc;
        }
        
        .filter-tab-item.active {
            color: #ffffff;
            background: linear-gradient(135deg, #CE9FFC 0%, #BB8FCE 100%);
            box-shadow: 0 4px 12px rgba(187, 143, 206, 0.3);
        }

        /* 动态卡片悬浮 */
        .post-card { 
            background: white; 
            margin-bottom: 25px; 
            padding: 25px; 
            border-radius: 18px; 
            border: 1px solid #f6f0f8; 
            transition: all 0.3s ease; 
            box-shadow: 0 4px 12px rgba(0,0,0,0.02);
        }
        .post-card:hover { 
            transform: translateY(-5px);
            box-shadow: 0 10px 25px rgba(187, 143, 206, 0.2); 
            border-color: #BB8FCE;
        }

        /* 标签配色 */
        .badge { 
            padding: 4px 12px; 
            border-radius: 8px; 
            color: white; 
            font-size: 0.85em; 
            font-weight: bold; 
            margin-right: 12px; 
            display: inline-block;
        }
        /* 求购标签 */
        .badge-buy { background: linear-gradient(135deg, #5DADE2 0%, #3498DB 100%); } 
        /* 避雷标签 */
        .badge-warning { background: linear-gradient(135deg, #E67E22 0%, #C0392B 100%); } 
        /* 求助标签 */
        .badge-help { background: linear-gradient(135deg, #1ABC9C 0%, #2ECC71 100%); }

        /* 新增：前端置顶公告高亮标签与卡片高亮样式 */
        .badge-top-notice {
            background: linear-gradient(135deg, #e74c3c 0%, #c0392b 100%);
            padding: 4px 12px;
            border-radius: 8px;
            color: white;
            font-size: 0.85em;
            font-weight: bold;
            margin-right: 12px;
            display: inline-block;
            box-shadow: 0 2px 8px rgba(231, 76, 60, 0.3);
        }
        .post-card-top {
            border: 1.5px dashed #e74c3c !important;
            background: #fffdfd !important;
        }

        /* 避雷对象样式 */
        .reported-id { 
            color: #C0392B; 
            font-weight: bold; 
            background: #FDF2F1; 
            padding: 3px 8px; 
            border-radius: 6px; 
            border: 1px solid #FADBD8;
        }

        .post-title {
            text-decoration: none; 
            color: #222; 
            font-size: 1.25em; 
            font-weight: bold;
            transition: 0.3s;
        }
        /* 标题悬浮同步变为淡紫 */
        .post-title:hover { color: #BB8FCE; }

        .meta-info {
            font-size: 0.9em; 
            color: #888; 
            border-top: 1px solid #fbf9fc; 
            margin-top: 15px; 
            padding-top: 15px;
            display: flex;
            align-items: center;
            flex-wrap: wrap;
            gap: 15px;
        }

        /* 🎯 新增的点赞按钮样式 */
        .like-btn {
            text-decoration: none;
            color: #e74c3c;
            font-weight: bold;
            margin-left: auto; /* 推到最右侧 */
            padding: 4px 10px;
            background: #fdf2f1;
            border-radius: 6px;
            border: 1px solid #fadbd8;
            transition: all 0.2s;
        }
        .like-btn:hover {
            background: #e74c3c;
            color: white;
            transform: scale(1.05);
        }

        h2.page-title {
            text-align: center;
            color: #34495E;
            margin: 30px 0 10px 0;
            font-size: 1.8em;
        }
        p.page-subtitle {
            text-align: center;
            color: #7F8C8D;
            margin-bottom: 40px;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div class="nav-top">
            <a href="Default.aspx">🛒 二手市场</a>
            <a href="LostFound.aspx">🤝 失物招领</a> 
            <a href="Community.aspx">📢 社区广场</a>
            <a href="PostProduct.aspx">➕ 我要发帖</a>
            <a href="MyAccount.aspx">👤 个人中心</a>

            <asp:PlaceHolder ID="phAdminLink" runat="server" Visible="false">
                <a href="AdminCenter.aspx" style="color: #fff; background: #d93025; padding: 6px 12px; border-radius: 6px; margin-left: 15px; font-weight: bold;">
                    ⚙️ 管理员后台
                </a>
            </asp:PlaceHolder>
        </div>

        <div style="max-width: 850px; margin: 0 auto; padding: 0 20px;">
            <h2 class="page-title">📢 社区公告板</h2>
            <p class="page-subtitle">在这里求购心仪好物，分享校园避雷指南，或找同学帮忙互助</p>

            <%-- 🎯 完美嵌入：新增的模糊查找输入框与提交按钮组件 --%>
            <div class="search-container">
                <asp:TextBox ID="txtSearch" runat="server" CssClass="search-input" Placeholder="输入关键词搜索帖子标题或内容..."></asp:TextBox>
                <asp:Button ID="btnSearch" runat="server" CssClass="search-btn" Text="🔍 搜索" OnClick="BtnSearch_Click" />
            </div>

            <%-- 选项卡式外观设计 --%>
            <div class="filter-tabs">
                <asp:LinkButton ID="lnkAll" runat="server" CssClass="filter-tab-item active" OnClick="Filter_Click" CommandArgument="all">🌍 全部内容</asp:LinkButton>
                <asp:LinkButton ID="lnkBuying" runat="server" CssClass="filter-tab-item" OnClick="Filter_Click" CommandArgument="buying">🛒 正在求购</asp:LinkButton>
                <asp:LinkButton ID="lnkReceived" runat="server" CssClass="filter-tab-item" OnClick="Filter_Click" CommandArgument="received">✓ 已购结帖</asp:LinkButton>
                <asp:LinkButton ID="lnkAntiThunder" runat="server" CssClass="filter-tab-item" OnClick="Filter_Click" CommandArgument="thunder">⚡ 雷区避雷</asp:LinkButton>
                <asp:LinkButton ID="lnkHelp" runat="server" CssClass="filter-tab-item" OnClick="Filter_Click" CommandArgument="help">🤝 互助求助</asp:LinkButton>
                <asp:LinkButton ID="lnkSolvedHelp" runat="server" CssClass="filter-tab-item" OnClick="Filter_Click" CommandArgument="solved">✓ 互助解决</asp:LinkButton>
            </div>

            <%-- 🎯 修改点：为 Repeater 添加了 OnItemCommand 事件，用于捕捉处理点赞点击 --%>
            <asp:Repeater ID="rptCommunity" runat="server" OnItemCommand="RptCommunity_ItemCommand">
                <ItemTemplate>
                    <div class='post-card <%# Eval("IsTop") != DBNull.Value && Eval("IsTop").ToString().Trim() == "1" ? "post-card-top" : "" %>' runat="server" 
                         Visible='<%# !(Eval("PostType").ToString().Trim() == "2" && Eval("Status") != DBNull.Value && Eval("Status").ToString().Trim() == "3") %>'>
                        
                        <div style="display: flex; justify-content: space-between; align-items: flex-start;">
                            <div style="display: flex; align-items: center;">
                                <%# Eval("IsTop") != DBNull.Value && Eval("IsTop").ToString().Trim() == "1" ? "<span class='badge-top-notice'>📌 置顶公告</span>" : "" %>

                                <span class='<%# Eval("PostType").ToString() == "1" ? "badge badge-buy" : (Eval("PostType").ToString() == "4" ? "badge badge-help" : "badge badge-warning") %>'>
                                    <%# Eval("PostType").ToString() == "1" ? "求购" : (Eval("PostType").ToString() == "4" ? "求助" : "避雷") %>
                                </span>
                                 
                                <%# Eval("Status") != DBNull.Value && Eval("Status").ToString().Trim() == "3" 
                                    ? (Eval("PostType").ToString() == "1" 
                                        ? "<span style='background-color:#95A5A6; color:white; padding:2px 8px; font-size:0.8em; border-radius:6px; font-weight:bold; margin-right:8px;'>✓ 已收到</span>" 
                                        : (Eval("PostType").ToString() == "4" 
                                            ? "<span style='background-color:#95A5A6; color:white; padding:2px 8px; font-size:0.8em; border-radius:6px; font-weight:bold; margin-right:8px;'>✓ 已解决</span>" 
                                            : "")) 
                                    : "" %>

                                <a href='<%# "ProductDetail.aspx?id=" + Eval("ProductID") %>' class="post-title">
                                    <%# Eval("ProductName") %>
                                </a>
                            </div>
                            <span style="color: #bbb; font-size: 0.85em;"><%# Eval("PublishDate", "{0:MM-dd HH:mm}") %></span>
                        </div>
                        
                        <p style="color: #555; margin: 18px 0; line-height: 1.6; font-size: 1.05em;">
                            <%# Eval("Description") %>
                        </p>

                        <div class="meta-info">
                            <span>👤 发布人：<span style="color:#555; font-weight:600;"><%# Eval("SellerID") %></span></span>
                             
                            <%# Eval("PostType").ToString() == "1" ? "<span>💰 预算：<span style='color:#C0392B; font-weight:bold;'>￥" + Eval("Price") + "</span></span>" : "" %>
                             
                            <%# (Eval("PostType").ToString() == "2" && Eval("ReportedUserID") != DBNull.Value && Eval("ReportedUserID").ToString() != "") 
                                ? "<span>🚩 <span class='reported-id'>避雷对象：" + Eval("ReportedUserID") + "</span></span>" 
                                : "" %>

                            <%-- 🎯 完美添加：点赞触发按钮组件，显示实时获取的 LikeCount 字段数据 --%>
                            <asp:LinkButton ID="btnLike" runat="server" CssClass="like-btn" 
                                            CommandName="Like" CommandArgument='<%# Eval("ProductID") %>'>
                                ❤️ 赞 (<%# Eval("LikeCount") != DBNull.Value ? Eval("LikeCount") : 0 %>)
                            </asp:LinkButton>
                        </div>
                    </div>
                </ItemTemplate>
            </asp:Repeater>

            <asp:Panel ID="pnlEmpty" runat="server" Visible="false" style="text-align:center; padding: 100px 0; color: #ccc;">
                <div style="font-size: 50px; margin-bottom: 20px;">📭</div>
                <p>目前还没有任何社区动态，去发布一条吧！</p>
            </asp:Panel>
        </div>
    </form>
</body>
</html>
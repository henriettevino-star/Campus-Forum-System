<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Default.aspx.cs" Inherits="_0506_1.Default" %>

<!DOCTYPE html>
<html>
<head runat="server">
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
    <title>校园二手市场</title>
    <style>
        /* 页面背景 */
        body { background-color: #FFF9F4; font-family: 'Microsoft YaHei'; margin: 0; padding-top: 10px; }
        
        /* 导航栏 */
        .nav-top { background-color: #ffffff; padding: 15px 0; text-align: center; max-width: 1100px; margin: 20px auto; border-radius: 15px; border: 2px solid #E67E22; box-shadow: 0 8px 25px rgba(230, 126, 34, 0.15); }
        .nav-top a { color: #555; text-decoration: none; margin: 0 25px; font-weight: bold; font-size: 1.1em; transition: color 0.3s; }
        .nav-top a.active { color: #E67E22 !important; }
        .nav-top a:hover { color: #E67E22; }

        /* 商品卡片悬浮效果 */
        .product-card { width: 210px; height: 380px; background: white; border: 1px solid #f3eae1; padding: 15px; border-radius: 12px; transition: 0.3s; box-shadow: 0 2px 5px rgba(0,0,0,0.02); display: flex; flex-direction: column; }
        .product-card:hover { transform: translateY(-5px); box-shadow: 0 5px 15px rgba(230, 126, 34, 0.15) !important; border-color: #E67E22; }

        .card-img-box {
            width: 100%; height: 160px; background: #fdfaf7; border-radius: 8px;
            margin-bottom: 10px; overflow: hidden; display: flex; align-items: center; justify-content: center;
            color: #ccc; font-size: 12px;
        }
        .card-img { width: 100%; height: 100%; object-fit: cover; cursor: zoom-in; }

        #imgModal { display: none; position: fixed; z-index: 10000; top: 0; left: 0; width: 100%; height: 100%; background: rgba(0,0,0,0.85); justify-content: center; align-items: center; cursor: zoom-out; }
        #imgModal img { max-width: 90%; max-height: 90%; border-radius: 8px; box-shadow: 0 0 20px rgba(0,0,0,0.5); }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div class="nav-top">
            <a href="Default.aspx" class="active">🛒 二手市场</a>
            <a href="LostFound.aspx">🤝 失物招领</a> <a href="Community.aspx">📢 社区广场</a>
            <a href="PostProduct.aspx">➕ 我要发帖</a>
            <a href="MyAccount.aspx">👤 个人中心</a>

            <%-- 专属管理员的后台快捷入口 --%>
            <asp:PlaceHolder ID="phAdminLink" runat="server" Visible="false">
                <a href="AdminCenter.aspx" style="color: #fff; background: #d93025; padding: 6px 12px; border-radius: 6px; margin-left: 15px; font-weight: bold; box-shadow: 0 2px 6px rgba(217,48,37,0.3);">
                    ⚙️ 管理员后台
                </a>
            </asp:PlaceHolder>
        </div>

        <div style="padding: 20px; max-width: 1200px; margin: 0 auto;">
            <div style="background: white; padding: 15px 25px; border-radius: 8px; margin-bottom: 20px; display: flex; justify-content: space-between; align-items: center; box-shadow: 0 2px 5px rgba(0,0,0,0.05);">
                <h2 style="margin: 0; color: #333;">校园二手“跳蚤”市场</h2>
                <div style="font-size: 14px;">
                    欢迎您，<asp:Label ID="lblUserName" runat="server" Font-Bold="true" ForeColor="#E67E22"></asp:Label>！
                    <asp:LinkButton ID="lnkLogout" runat="server" OnClick="lnkLogout_Click" style="margin-left:15px; color:gray; text-decoration:none;">退出</asp:LinkButton>
                </div>
            </div>

            <div style="margin-bottom: 25px; background: white; padding: 15px; border-radius: 8px; box-shadow: 0 2px 5px rgba(0,0,0,0.05);">
                <span>筛选分类：</span>
                <asp:DropDownList ID="ddlCategory" runat="server" AutoPostBack="true" OnSelectedIndexChanged="ddlCategory_SelectedIndexChanged" style="padding: 5px; border-radius: 4px; border: 1px solid #ddd;"></asp:DropDownList>
                <span style="margin-left: 20px;">关键词：</span>
                <asp:TextBox ID="txtSearch" runat="server" placeholder="搜索商品..." style="padding: 5px; width: 200px; border-radius: 4px; border: 1px solid #ddd;"></asp:TextBox>
                <asp:Button ID="btnSearch" runat="server" Text="搜索" OnClick="btnSearch_Click" style="padding: 5px 15px; background: #1E90FF; color: white; border: none; border-radius: 4px; cursor: pointer; font-weight: bold;" />
                <a href="PostProduct.aspx" style="float:right; padding: 6px 18px; background: #27AE60; color: white; text-decoration: none; border-radius: 4px; font-weight: bold;">+ 发布物品</a>
            </div>

            <%-- 锁定最大宽度与导航栏一致，并使用 margin: 0 auto 整体居中，内部排版依然是原始的从左往右 --%>
            <div style="display: flex; flex-wrap: wrap; gap: 25px; max-width: 1100px; margin: 0 auto;">
                <asp:Repeater ID="rptProducts" runat="server" OnItemCommand="rptProducts_ItemCommand">
                    <ItemTemplate>
                        <div class="product-card">
                            <div class="card-img-box">
                                <%# Eval("ImageUrl") != DBNull.Value && Eval("ImageUrl").ToString() != "" ? 
                                    "<img src='" + ResolveUrl("~/Uploads/" + Eval("ImageUrl")) + "' class='card-img' onclick='showBigImg(this.src)' />" : 
                                    "<span>📷 暂无图片</span>" %>
                            </div>

                            <div style="font-weight: bold; font-size: 1.1em; color: #333; margin-bottom: 8px; white-space: nowrap; overflow: hidden; text-overflow: ellipsis;">
                                <%# Eval("PostType") != DBNull.Value && Eval("PostType").ToString() == "3" ? 
                                    "<span style='background:#27AE60; color:white; font-size:12px; padding:2px 6px; border-radius:4px; margin-right:5px; vertical-align:middle;'>失物</span>" : "" %><%# Eval("ProductName") %>
                            </div>

                            <div style="color: #E67E22; font-size: 1.3em; font-weight: bold; margin: 10px 0 5px 0;">
                                <%# Eval("PostType") != DBNull.Value && Eval("PostType").ToString() == "3" ? 
                                    "<span style='color:#27AE60; font-size:0.85em;'>🤝 寻物/招领贴</span>" : "￥" + Eval("Price") %>
                            </div>

                            <%-- 在详情描述上方，无缝嵌入发布者账号展示 --%>
                            <div style="font-size: 0.82em; color: #777; margin-bottom: 8px; white-space: nowrap; overflow: hidden; text-overflow: ellipsis;">
                                👤 发布者：<span style="font-weight: 600; color: #E67E22;"><%# Eval("SellerID") %></span>
                            </div>

                            <div style="font-size: 0.9em; color: #666; height: 40px; line-height: 20px; overflow: hidden; margin-bottom: 12px;"><%# Eval("Description") %></div>
                            
                            <div style="margin-top: auto;">
                                <%-- 按钮排列盒子：查看详情和快捷购买分上下或者并排展示 --%>
                                <div style="display: flex; flex-direction: column; gap: 4px;">
                                    <%-- 所有人都能点击进入详情页 --%>
                                    <a href='ProductDetail.aspx?id=<%# Eval("ProductID") %>' 
                                       style="display:block; text-align:center; padding: 6px; background:#1E90FF; color: white; text-decoration: none; border-radius: 6px; font-size: 0.85em; font-weight: bold;">
                                         查看详情
                                    </a>
                                    
                                    <%-- 精准捕获：不是我发布的、且不是失物招领贴，才显示快捷购买按钮 --%>
                                    <asp:Button ID="btnQuickBuy" runat="server" Text="⚡ 快捷购买" 
                                        CommandName="Buy" CommandArgument='<%# Eval("ProductID") %>'
                                        Visible='<%# IsNotMyProduct(Eval("SellerID")) && (Eval("PostType") == DBNull.Value || Eval("PostType").ToString() != "3") %>'
                                        style="display:block; width:100%; padding: 6px; background:#E67E22; color: white; border:none; border-radius: 6px; font-size: 0.85em; font-weight: bold; cursor:pointer;" />
                                </div>
                                
                                <%-- 仅作为一个“我的发布”小标签提示 --%>
                                <%# Eval("SellerID").ToString() == Session["UserID"].ToString() ? "<div style='color:#E67E22; font-size:12px; text-align:center; margin-top:4px; font-weight:bold;'>✨ 我发布的</div>" : "" %>
                            </div>
                        </div>
                    </ItemTemplate>
                </asp:Repeater>
            </div>
        </div>

        <div id="imgModal" onclick="this.style.display='none'">
            <img id="bigImg" src="" />
        </div>
    </form>
    <script>
        function showBigImg(src) {
            document.getElementById('bigImg').src = src;
            document.getElementById('imgModal').style.display = 'flex';
        }
    </script>
</body>
</html>
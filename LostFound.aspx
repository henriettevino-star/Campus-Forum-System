<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="LostFound.aspx.cs" Inherits="_0506_1.LostFound" %>

<!DOCTYPE html>
<html>
<head runat="server">
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
    <title>校园失物招领 - 寻物</title>

    <style>
        body { background-color: #FFFDF2; font-family: 'Microsoft YaHei'; margin: 0; padding-top: 10px; }
        .nav-top { background-color: #ffffff; padding: 15px 0; text-align: center; max-width: 1100px; margin: 20px auto; border-radius: 15px; border: 2px solid #28a745; box-shadow: 0 8px 25px rgba(40, 167, 69, 0.2); }
        .nav-top a { color: #333; text-decoration: none; margin: 0 25px; font-weight: bold; font-size: 1.1em; }
        .nav-top a.active { color: #28a745 !important; }
        .nav-top a:hover { color: #28a745; }

        .product-card { width: 210px; height: 380px; background: white; border: 1px solid #eee; padding: 15px; border-radius: 12px; transition: 0.3s; box-shadow: 0 2px 5px rgba(0,0,0,0.02); display: flex; flex-direction: column; }
        .product-card:hover { transform: translateY(-5px); box-shadow: 0 5px 15px rgba(40, 167, 69, 0.15) !important; }

        .card-img-box {
            width: 100%; height: 160px; background: #f5f5f5; border-radius: 8px;
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
            <a href="Default.aspx">🛒 二手市场</a>
            <a href="LostFound.aspx" class="active">🤝 失物招领</a>
            <a href="Community.aspx">📢 社区广场</a>
            <a href="PostProduct.aspx">➕ 我要发帖</a>
            <a href="MyAccount.aspx">👤 个人中心</a>

            <asp:PlaceHolder ID="phAdminLink" runat="server" Visible="false">
                <a href="AdminCenter.aspx" style="color: #fff; background: #d93025; padding: 6px 12px; border-radius: 6px; margin-left: 15px; font-weight: bold;">
                    ⚙️ 管理员后台
                </a>
            </asp:PlaceHolder>
        </div>

        <div style="padding: 20px; max-width: 1200px; margin: 0 auto;">
            <div style="background: white; padding: 15px 25px; border-radius: 8px; margin-bottom: 20px; display: flex; justify-content: space-between; align-items: center; box-shadow: 0 2px 5px rgba(0,0,0,0.05);">
                <h2 style="margin: 0; color: #28a745;">🤝 校园失物招领中心</h2>
                <div style="font-size: 14px;">
                    欢迎您，<asp:Label ID="lblUserName" runat="server" Font-Bold="true" ForeColor="#28a745"></asp:Label>！
                    <asp:LinkButton ID="lnkLogout" runat="server" OnClick="lnkLogout_Click" style="margin-left:15px; color:gray; text-decoration:none;">退出</asp:LinkButton>
                </div>
            </div>

            <div style="margin-bottom: 25px; background: white; padding: 15px; border-radius: 8px; box-shadow: 0 2px 5px rgba(0,0,0,0.05);">
                <span>关键词搜索：</span>
                <asp:TextBox ID="txtSearch" runat="server" placeholder="搜索失物信息..." style="padding: 5px; width: 250px; border-radius: 4px; border: 1px solid #ddd;"></asp:TextBox>
                <asp:Button ID="btnSearch" runat="server" Text="搜索" OnClick="btnSearch_Click" style="padding: 5px 15px; background: #28a745; color: white; border: none; border-radius: 4px; cursor: pointer;" />
                <a href="PostProduct.aspx" style="float:right; padding: 6px 18px; background: #007bff; color: white; text-decoration: none; border-radius: 4px; font-weight: bold;">+ 发布寻物/招领</a>
            </div>

            <%-- 增加 max-width: 1100px; margin: 0 auto; 实现商品大区域在页面中间对齐，内部排版依然是原始的一行 4 个、左对齐布局 --%>
            <div style="display: flex; flex-wrap: wrap; gap: 25px; max-width: 1100px; margin: 0 auto;">
                <asp:Repeater ID="rptProducts" runat="server">
                    <ItemTemplate>
                        <div class="product-card">
                            <div class="card-img-box">
                                <%# Eval("ImageUrl") != DBNull.Value && Eval("ImageUrl").ToString() != "" ? 
                                    "<img src='" + ResolveUrl("~/Uploads/" + Eval("ImageUrl")) + "' class='card-img' onclick='showBigImg(this.src)' />" : 
                                    "<span>📷 暂无图片</span>" %>
                            </div>

                            <div style="font-weight: bold; font-size: 1.1em; color: #333; margin-bottom: 6px; white-space: nowrap; overflow: hidden; text-overflow: ellipsis;">
                                <span style='background:#28a745; color:white; font-size:12px; padding:2px 6px; border-radius:4px; margin-right:5px; vertical-align:middle;'>失物</span>
                                <%# Eval("ProductName") %>
                            </div>

                            <%-- 在详情描述上方，无缝嵌入寻物/招领人发布账号展示 --%>
                            <div style="font-size: 0.82em; color: #777; margin-bottom: 8px; white-space: nowrap; overflow: hidden; text-overflow: ellipsis;">
                                👤 发布者：<span style="font-weight: 600; color: #28a745;"><%# Eval("SellerID") %></span>
                            </div>

                            <div style="font-size: 0.9em; color: #666; height: 40px; line-height: 20px; overflow: hidden; margin-bottom: 12px;"><%# Eval("Description") %></div>
                            
                            <div style="margin-top: auto;">
                                <a href='ProductDetail.aspx?id=<%# Eval("ProductID") %>' 
                                   style="display:block; text-align:center; padding: 8px; background: #28a745; color: white; text-decoration: none; border-radius: 6px; font-size: 0.9em; font-weight:bold;">
                                    查看详情
                                </a>
                                <%# Eval("SellerID").ToString() == Session["UserID"].ToString() ? "<div style='color:orange; font-size:12px; text-align:center; margin-top:3px;'>✨ 我发布的</div>" : "" %>
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
<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="AdminCenter.aspx.cs" Inherits="_0506_1.AdminCenter" %>

<!DOCTYPE html>
<html>
<head runat="server">
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
    <title>校园 market 系统管理后台</title>
    <script src="https://cdn.jsdelivr.net/npm/echarts@5.4.3/dist/echarts.min.js"></script>
    <style>
        body { font-family: 'Microsoft YaHei'; background-color: #f4f7f6; padding: 20px; color: #333; }
        .admin-container { max-width: 1250px; margin: 0 auto; background: #fff; padding: 30px; border-radius: 8px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
        .header { display: flex; justify-content: space-between; align-items: center; border-bottom: 2px solid #eee; padding-bottom: 20px; margin-bottom: 20px; }
        .section-title { border-left: 5px solid #d9534f; padding-left: 15px; margin: 30px 0 15px 0; font-size: 1.2em; font-weight: bold; }
        .admin-table { width: 100%; border-collapse: collapse; margin-bottom: 40px; }
        .admin-table th { background-color: #f8f9fa; padding: 12px; border-bottom: 2px solid #dee2e6; text-align: left; }
        .admin-table td { padding: 12px; border-bottom: 1px solid #eee; }
        .badge { padding: 4px 8px; border-radius: 4px; font-size: 12px; color: #fff; }
        .badge-0 { background-color: #28a745; } 
        .badge-1 { background-color: #17a2b8; } 
        .badge-2 { background-color: #dc3545; } 
        .badge-3 { background-color: #3498DB; } 
        .badge-4 { background-color: #9B59B6; } 
        .btn-action { padding: 5px 10px; border-radius: 4px; cursor: pointer; border: 1px solid #ced4da; background: #fff; font-size: 12px; }
        .btn-ban { background-color: #dc3545; color: white; border: none; }
        .btn-delete { color: #999; font-size: 12px; margin-left: 10px; text-decoration: underline; background:none; border:none; cursor:pointer; }
        
        .btn-verify-success { background-color: #28a745; color: white; border: none; font-weight: bold; margin-right: 5px; }
        .btn-verify-fail { background-color: #ff9800; color: white; border: none; font-weight: bold; margin-right: 5px; }
        .audit-alert { color: #d93025; font-weight: bold; background: #fff1f0; border: 1px solid #ffa39e; padding: 2px 6px; border-radius: 4px; font-size: 11px; margin-right: 5px; }
        
        /* 新增：置顶标签与按钮样式 */
        .badge-top { background-color: #e74c3c; font-weight: bold; animation: blink 2s infinite; margin-right: 5px; }
        .btn-top { background-color: #f1c40f; color: #2c3e50; border: 1px solid #f39c12; font-weight: bold; margin-right: 5px; }
        .btn-untop { background-color: #7f8c8d; color: white; border: none; margin-right: 5px; }

        /* 🎯 新增：参与度统计专属样式组件 */
        .stats-box { background: #fdfdfd; border: 1px solid #e3e8ee; padding: 20px; border-radius: 8px; margin-bottom: 30px; }
        .filter-bar { display: flex; align-items: center; gap: 15px; background: #f8f9fa; padding: 12px 20px; border-radius: 6px; border: 1px solid #e9ecef; margin-bottom: 20px; }
        .date-input { padding: 6px 12px; border: 1px solid #ced4da; border-radius: 4px; outline: none; }
        .btn-query { background: #4A90E2; color: #fff; border: none; padding: 7px 20px; border-radius: 4px; font-weight: bold; cursor: pointer; transition: 0.2s; }
        .btn-query:hover { background: #357ABD; }
        .charts-flex-container { display: flex; gap: 30px; align-items: flex-start; }
        #pieChartContainer { width: 450px; height: 320px; background: #fff; border: 1px solid #f0f0f0; border-radius: 6px; padding: 10px; box-shadow: 0 2px 5px rgba(0,0,0,0.02); }
        .table-container { flex: 1; min-width: 0; }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div class="admin-container">
            <div class="header">
                <h2 style="color:#c53030;">🛡️ 校园 market 系统管理后台</h2>
                <asp:HyperLink runat="server" NavigateUrl="Default.aspx">返回广场首页 >></asp:HyperLink>
            </div>

            <div class="section-title" style="border-left-color: #4A90E2;">📊 全平台论坛参与度与成员活跃度统计</div>
            <div class="stats-box">
                <div class="filter-bar">
                    <span>📅 统计时间段：</span>
                    <asp:TextBox ID="txtStartDate" runat="server" TextMode="Date" CssClass="date-input"></asp:TextBox>
                    <span>至</span>
                    <asp:TextBox ID="txtEndDate" runat="server" TextMode="Date" CssClass="date-input"></asp:TextBox>
                    <asp:Button ID="btnFilterStats" runat="server" Text="⚡ 联动筛查" CssClass="btn-query" OnClick="BtnFilterStats_Click" />
                </div>

                <div class="charts-flex-container">
                    <div id="pieChartContainer"></div>

                    <div class="table-container">
                        <asp:GridView ID="gvUserStats" runat="server" AutoGenerateColumns="False" CssClass="admin-table" GridLines="None" Width="100%">
                            <Columns>
                                <asp:BoundField DataField="UserID" HeaderText="成员账号" />
                                <asp:BoundField DataField="UserName" HeaderText="成员姓名" />
                                <asp:BoundField DataField="PostCount" HeaderText="📝 发帖数量" HeaderStyle-ForeColor="#2ecc71" ItemStyle-Font-Bold="true" />
                                <asp:BoundField DataField="ReplyCount" HeaderText="💬 回帖数量" HeaderStyle-ForeColor="#e67e22" ItemStyle-Font-Bold="true" />
                                <asp:BoundField DataField="ActivityScore" HeaderText="🔥 总活跃度" HeaderStyle-ForeColor="#e74c3c" ItemStyle-Font-Bold="true" />
                            </Columns>
                        </asp:GridView>
                        <asp:Panel ID="pnlNoStats" runat="server" Visible="false" Style="text-align:center; padding: 40px; color:#999;">
                            当前选定时间段内没有任何成员发帖或回帖数据。
                        </asp:Panel>
                    </div>
                </div>
            </div>

            <div class="section-title">1. 全平台信息审核 (出售、求购、避雷、招领、求助)</div>
            <asp:GridView ID="gvProducts" runat="server" AutoGenerateColumns="False" CssClass="admin-table" GridLines="None" OnRowCommand="gvProducts_RowCommand">
                <Columns>
                    <asp:BoundField DataField="ProductID" HeaderText="编号" />
                    <asp:TemplateField HeaderText="类型">
                        <ItemTemplate>
                            <span class='badge badge-<%# Eval("PostType").ToString().Trim() %>'>
                                <%# 
                                    Eval("PostType").ToString().Trim() == "0" ? "出售" : 
                                    Eval("PostType").ToString().Trim() == "1" ? "求购" : 
                                    Eval("PostType").ToString().Trim() == "2" ? "避雷" : 
                                    Eval("PostType").ToString().Trim() == "3" ? "招领" : 
                                    Eval("PostType").ToString().Trim() == "4" ? "求助" : "普通" 
                                %>
                            </span>
                        </ItemTemplate>
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="标题内容">
                        <ItemTemplate>
                            <%# Eval("IsTop") != DBNull.Value && Eval("IsTop").ToString().Trim() == "1" ? "<span class='badge badge-top'>📌 置顶</span>" : "" %>
                            <%# Eval("PostType").ToString().Trim() == "2" && Eval("Status").ToString().Trim() == "3" ? "<span class='audit-alert'>【待审避雷】</span>" : "" %>
                            <a href='ProductDetail.aspx?id=<%# Eval("ProductID") %>' style="text-decoration:none; color:#007bff; font-weight:bold;">
                                <%# Eval("ProductName") %>
                            </a>
                        </ItemTemplate>
                    </asp:TemplateField>
                    <asp:BoundField DataField="SellerID" HeaderText="发布人" />
                    <asp:TemplateField HeaderText="被举报人">
                        <ItemTemplate>
                            <%# Eval("PostType").ToString().Trim() == "2" ? "<b style='color:#dc3545;'>" + (string.IsNullOrEmpty(Eval("ReportedUserID").ToString()) ? "未填写" : Eval("ReportedUserID")) + "</b>" : "--" %>
                        </ItemTemplate>
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="当前状态">
                        <ItemTemplate>
                            <%# Eval("Status").ToString().Trim() == "0" || Eval("Status").ToString().Trim() == "1" ? "<span style='color:#28a745; font-weight:bold;'>展示中</span>" : 
                                (Eval("Status").ToString().Trim() == "3" ? "<span style='color:#ff9800; font-weight:bold;'>待审核</span>" :
                                (Eval("PostType").ToString().Trim() == "0" ? "<span style='color:#6c757d;'>[已售罄]</span>" : "<span style='color:#6c757d;'>[已下架]</span>")) %>
                        </ItemTemplate>
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="管理操作">
                        <ItemTemplate>
                            <asp:PlaceHolder runat="server" Visible='<%# Eval("PostType").ToString().Trim() == "2" && Eval("Status").ToString().Trim() == "3" %>'>
                                <asp:Button ID="btnVerifyOk" runat="server" Text="情况属实(-20)" CssClass="btn-action btn-verify-success"
                                    CommandName="VerifyTrue" CommandArgument='<%# Eval("ProductID") %>' OnClientClick="return confirm('确认审核属实？将被举报人扣除20积分，帖子状态将变变更为已审核并继续展示。');" />
                                <asp:Button ID="btnVerifyNo" runat="server" Text="虚假抹黑(下架-10)" CssClass="btn-action btn-verify-fail"
                                    CommandName="VerifyFalse" CommandArgument='<%# Eval("ProductID") %>' OnClientClick="return confirm('确认不属实？此贴将被强制下架，并发帖人扣除10积分！');" />
                            </asp:PlaceHolder>

                            <asp:PlaceHolder runat="server" Visible='<%# Eval("Status").ToString().Trim() == "0" || Eval("Status").ToString().Trim() == "1" %>'>
                                <asp:Button ID="btnSetTop" runat="server" Text="📌 置顶" CssClass="btn-action btn-top"
                                    CommandName="SetProductTop" CommandArgument='<%# Eval("ProductID") %>' 
                                    Visible='<%# Eval("IsTop") == DBNull.Value || Eval("IsTop").ToString().Trim() != "1" %>' />
                                <asp:Button ID="btnCancelTop" runat="server" Text="❌ 取消置顶" CssClass="btn-action btn-untop"
                                    CommandName="CancelProductTop" CommandArgument='<%# Eval("ProductID") %>' 
                                    Visible='<%# Eval("IsTop") != DBNull.Value && Eval("IsTop").ToString().Trim() == "1" %>' />
                            </asp:PlaceHolder>

                            <asp:Button ID="btnOffline" runat="server" Text="强制下架" CssClass="btn-action"
                                CommandName="ForceOffline" CommandArgument='<%# Eval("ProductID") %>' 
                                OnClientClick="return confirm('确定要执行下架操作吗？');" 
                                Visible='<%# Eval("Status").ToString().Trim() == "0" || Eval("Status").ToString().Trim() == "1" %>' />
                        </ItemTemplate>
                    </asp:TemplateField>
                </Columns>
            </asp:GridView>

            <div class="section-title">2. 用户账号管理 (拉黑、注销)</div>
            <asp:GridView ID="gvUsers" runat="server" AutoGenerateColumns="False" CssClass="admin-table" GridLines="None" OnRowCommand="gvUsers_RowCommand">
                <Columns>
                    <asp:BoundField DataField="UserID" HeaderText="学号" />
                    <asp:BoundField DataField="UserName" HeaderText="姓名" />
                    
                    <asp:TemplateField HeaderText="信誉分">
                        <ItemTemplate>
                            <b style='<%# Convert.ToInt32(Eval("CreditScore")) < 60 ? "color:#dc3545;" : "color:#ff9800;" %>'>
                                <%# Eval("CreditScore") %> 分
                            </b>
                        </ItemTemplate>
                    </asp:TemplateField>

                    <asp:TemplateField HeaderText="账号状态">
                        <ItemTemplate>
                            <span style='<%# Eval("UserStatus").ToString().Trim() == "Refused" || Eval("UserStatus").ToString().Trim() == "被封禁" ? "color:red; font-weight:bold;" : "color:green;" %>'>
                                <%# Eval("UserStatus") %>
                            </span>
                        </ItemTemplate>
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="管理操作">
                        <ItemTemplate>
                            <asp:Button ID="btnBan" runat="server" Text="封禁" CssClass="btn-action btn-ban" CommandName="BanUser" 
                                CommandArgument='<%# Eval("UserID") %>' Visible='<%# Eval("UserStatus").ToString().Trim() == "正常" %>' />
                            <asp:Button ID="btnUnban" runat="server" Text="解封" CssClass="btn-action" CommandName="UnbanUser" 
                                CommandArgument='<%# Eval("UserID") %>' Visible='<%# Eval("UserStatus").ToString().Trim() == "Refused" || Eval("UserStatus").ToString().Trim() == "被封禁" %>' />
                            
                            <asp:Button ID="btnDelete" runat="server" Text="注销账号" CssClass="btn-delete" CommandName="DeleteUser" 
                                CommandArgument='<%# Eval("UserID") %>' OnClientClick="return confirm('危险：注销将永久删除该用户及所有帖子，确定吗？');" />
                        </ItemTemplate>
                    </asp:TemplateField>
                </Columns>
            </asp:GridView>
        </div>
    </form>

    <asp:Literal ID="litChartScript" runat="server"></asp:Literal>
</body>
</html>
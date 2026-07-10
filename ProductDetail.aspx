<%@ Page Language="C#" AutoEventWireup="true" CodeFile="ProductDetail.aspx.cs" Inherits="ProductDetail" %>
<!DOCTYPE html>
<html>
<head runat="server">
    <meta charset="utf-8" />
    <title>商品详情</title>
    <style>
        body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background-color: #f8f9fa; padding: 20px; }
        .container { max-width: 800px; margin: 0 auto; background: white; padding: 30px; border-radius: 12px; box-shadow: 0 4px 12px rgba(0,0,0,0.1); }
        .product-img { width: 100%; max-height: 400px; object-fit: contain; border-radius: 8px; margin-bottom: 20px; }
        .price { color: #e4393c; font-size: 28px; font-weight: bold; margin: 15px 0; }
        .desc { color: #666; line-height: 1.6; background: #fdfdfd; padding: 15px; border-radius: 5px; }
        .btn-group { display: flex; gap: 15px; margin-top: 25px; }
        .btn-action { flex: 1; padding: 12px; border: none; border-radius: 6px; font-size: 16px; cursor: pointer; font-weight: bold; }
        .btn-chat { background-color: #28a745; color: white; }
        .btn-buy { background-color: #007bff; color: white; }

               
        .chat-area { 
            position: fixed; 
            bottom: 20px; 
            right: 20px; 
            width: 380px; 
            height: 480px; 
            border: 1px solid #ddd; 
            border-radius: 12px; 
            background: #fff; 
            overflow: hidden; 
            box-shadow: 0 8px 24px rgba(0,0,0,0.15); 
            display: none; /* 默认隐藏，点击后打开 */
            flex-direction: column;
            z-index: 2000;
        }
        .chat-header { background: #007bff; padding: 12px; text-align: center; color: #fff; font-size: 14px; font-weight: bold; border-bottom: 1px solid #ddd; position: relative; }
        .chat-close { position: absolute; right: 12px; top: 10px; cursor: pointer; font-size: 18px; color: #fff; background: none; border: none; }
        .chat-main { flex: 1; overflow-y: auto; padding: 15px; display: flex; flex-direction: column; gap: 12px; background: #fcfcfc; }
        
        .msg { max-width: 75%; padding: 10px 15px; border-radius: 10px; font-size: 14px; line-height: 1.5; word-break: break-all; }    
        .msg-left { align-self: flex-start; background: #e9e9eb; color: #333; border-top-left-radius: 2px; }
        .msg-right { align-self: flex-end; background: #007bff; color: white; border-top-right-radius: 2px; }
        
        .chat-footer { display: flex; padding: 10px; background: #f9f9f9; border-top: 1px solid #ddd; gap: 10px; }
        .input-box { flex: 1; padding: 10px; border: 1px solid #ccc; border-radius: 5px; outline: none; }
        .btn-send { background: #007bff; color: white; border: none; padding: 0 20px; border-radius: 5px; cursor: pointer; font-weight: bold; }
        
        .modal-overlay { position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: rgba(0,0,0,0.6); display: flex; align-items: center; justify-content: center; z-index: 1000; }
        .modal-card { background: white; padding: 25px; border-radius: 10px; text-align: center; width: 320px; }
        .pay-options { display: flex; justify-content: space-around; margin: 20px 0; }
        .pay-way { cursor: pointer; border: 1px solid #eee; padding: 10px; border-radius: 8px; }
        .pay-way img { width: 40px; height: 40px; display: block; margin: 0 auto 5px; }
        .alert { padding: 15px; border-radius: 8px; margin-top: 10px; text-align: center; display: block; }
        .alert-warning { background: #fff3cd; color: #856404; border: 1px solid #ffeeba; }
        .alert-danger { background: #f8d7da; color: #721c24; border: 1px solid #f5c6cb; }

        /* 新增：发帖人独立编辑区域相关样式 */
        .edit-sandbox { margin-top: 15px; padding: 20px; background: #fdfdfd; border: 1px solid #e2e8f0; border-radius: 8px; }
        .sandbox-group { margin-bottom: 12px; }
        .sandbox-group label { display: block; margin-bottom: 6px; font-weight: bold; color: #4a5568; font-size: 14px; }
        .sandbox-input { width: 100%; padding: 8px; border: 1px solid #cbd5e0; border-radius: 4px; box-sizing: border-box; outline: none; }
        .sandbox-textarea { width: 100%; padding: 8px; border: 1px solid #cbd5e0; border-radius: 4px; box-sizing: border-box; outline: none; font-family: inherit; resize: none; }
    </style>
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
</head>
<body>
    <form id="form1" runat="server">
        <asp:ScriptManager runat="server" />
        <div class="container">
            <asp:LinkButton ID="lnkBack" runat="server" OnClick="lnkBack_Click" style="text-decoration:none; color:#007bff;">← 返回</asp:LinkButton>
            
            <div style="margin-top: 15px;">
                <asp:Label ID="lblSoldOut" runat="server" CssClass="alert alert-danger" Visible="false" />
            </div>
            
            <asp:PlaceHolder ID="phNormalLayout" runat="server">
                <div style="margin-top: 20px;">
                    <div class="image-gallery" style="width: 100%; text-align: center;">
                        <asp:Repeater ID="rptImages" runat="server">
                            <ItemTemplate>
                                <img src='<%# ResolveUrl("~/Uploads/" + Container.DataItem.ToString()) %>' alt="商品图片" class="product-img" style="width: 100%; max-height: 400px; object-fit: contain; border-radius: 8px; margin-bottom: 15px; display: block;" />
                            </ItemTemplate>
                        </asp:Repeater>
                    </div>

                    <h1><asp:Literal ID="litProductName" runat="server" /></h1>
                    
                    <div style="color: #000; font-size: 18px; font-weight: 900; font-family: 'SimHei', 'Microsoft YaHei', sans-serif; margin-bottom: 10px;">
                        发布者：<asp:Literal ID="litOwnerName" runat="server" /> (<asp:Literal ID="litStudentId" runat="server" />)
                    </div>

                    <asp:PlaceHolder ID="phPriceArea" runat="server">
                        <div id="priceWrapper" class="price"><asp:Literal ID="litPrice" runat="server" /></div>
                        <script type="text/javascript">
                            window.addEventListener('DOMContentLoaded', function () {
                                var priceDiv = document.getElementById('priceWrapper');
                                if (priceDiv) {
                                    // 在前端智能判定中，如果标题或页面里包含了“帮忙”或者价格本身为 0，就自动隐藏价格显示
                                    var pageText = document.body.innerText;
                                    if (priceDiv.innerText.indexOf('拾金不昧') !== -1 || pageText.indexOf('失物招领') !== -1 || pageText.indexOf('帮忙') !== -1 || priceDiv.innerText.indexOf('¥0.00') !== -1) {
                                        priceDiv.style.display = 'none';
                                    }
                                }

                                // 如果是求助互助类贴子，前端也同步把“立即购买”按钮移除，避免布局穿帮
                                if (document.body.innerText.indexOf('帮忙') !== -1 || document.body.innerText.indexOf('求助') !== -1) {
                                    var buyBtn = document.getElementById('<%= btnOpenPay.ClientID %>');
                                    if (buyBtn) {
                                        buyBtn.style.display = 'none';
                                    }
                                }
                            });
                        </script>
                    </asp:PlaceHolder>

                    <div class="desc"><asp:Literal ID="litDescription" runat="server" /></div>
                </div>
            </asp:PlaceHolder>

            <asp:PlaceHolder ID="phAntiThunderLayout" runat="server">
                <div style="margin-top: 20px;">
                    <h1 style="color: #dc3545;"><asp:Literal ID="litAntiThunderName" runat="server" /></h1>
                    
                    <div style="font-size: 13px; color: #718096; margin-bottom: 15px; line-height: 1.6;">
                        <div>📅 发布于：<asp:Literal ID="litAntiPublishDate" runat="server" /></div>
                        <asp:PlaceHolder ID="phAntiUpdateInfo" runat="server" Visible="false">
                            <div style="color: #dd6b20; font-weight: bold; margin-top: 2px;">✏️ 修改于：<asp:Literal ID="litAntiUpdateDate" runat="server" /></div>
                        </asp:PlaceHolder>
                    </div>

                    <div class="desc" style="border-left: 4px solid #dc3545; background-color: #fffdfd; margin-bottom: 20px;">
                        <asp:Literal ID="litAntiThunderDescription" runat="server" />
                    </div>
                    
                    <div class="anti-thunder-gallery" style="width: 100%; text-align: center;">
                        <asp:Repeater ID="rptAntiThunderImages" runat="server">
                            <ItemTemplate>
                                <img src='<%# ResolveUrl("~/Uploads/" + Container.DataItem.ToString()) %>' alt="避雷证据图片" style="width: 100%; max-height: 500px; object-fit: contain; border-radius: 8px; margin-bottom: 20px; display: block; box-shadow: 0 2px 8px rgba(0,0,0,0.15);" />
                            </ItemTemplate>
                        </asp:Repeater>
                    </div>
                </div>
            </asp:PlaceHolder>

            <asp:PlaceHolder ID="phStudentEditArea" runat="server" Visible="false">
                <div style="margin-top: 25px; padding: 15px; border-radius: 8px; background-color: #f7fafc; border: 1px dashed #cbd5e0; text-align: left;">
                    <asp:Button ID="btnOpenSandbox" runat="server" Text="📝 修改我的帖子" 
                        Style="background: #3182ce; color: white; border: none; padding: 10px 24px; font-weight: bold; border-radius: 6px; cursor: pointer;" 
                        OnClick="btnOpenSandbox_Click" />
                    
                    <asp:Panel ID="pnlEditSandbox" runat="server" CssClass="edit-sandbox" Visible="false">
                        <h3 style="margin-top: 0; color: #2d3748; border-left: 4px solid #3182ce; padding-left: 8px;">编辑内容</h3>
                        <div class="sandbox-group">
                            <label>帖子标题/商品名称：</label>
                            <asp:TextBox ID="txtSandboxTitle" runat="server" CssClass="sandbox-input" />
                        </div>
                        <div class="sandbox-group">
                            <label>详细描述：</label>
                            <asp:TextBox ID="txtSandboxDesc" runat="server" TextMode="MultiLine" Rows="5" CssClass="sandbox-textarea" />
                        </div>
                        <div style="margin-top: 15px;">
                            <asp:Button ID="btnSaveSandbox" runat="server" Text="💾 保存修改" Style="background: #38a169; color: white; border: none; padding: 8px 20px; font-weight: bold; border-radius: 4px; cursor: pointer; margin-right: 10px;" OnClick="btnSaveSandbox_Click" />
                            <asp:Button ID="btnCancelSandbox" runat="server" Text="❌ 取消" Style="background: #718096; color: white; border: none; padding: 8px 20px; font-weight: bold; border-radius: 4px; cursor: pointer;" OnClick="btnCancelSandbox_Click" />
                        </div>
                    </asp:Panel>
                </div>
            </asp:PlaceHolder>

            <div style="margin-top:20px;">
                <asp:PlaceHolder ID="phTransactionArea" runat="server">
                    <asp:PlaceHolder ID="phContactOther" runat="server">
                        <div class="btn-group">
                            <asp:Button ID="btnOpenChat" runat="server" Text="🗨️ 联系同学" CssClass="btn-action btn-chat" OnClientClick="openChatBox(); return false;" />
                            <asp:Button ID="btnOpenPay" runat="server" Text="💰 立即购买" CssClass="btn-action btn-buy" OnClick="btnOpenPay_Click" />
                        </div>
                    </asp:PlaceHolder>

                    <asp:PlaceHolder ID="phMyOwnTip" runat="server" Visible="false">
                        <div class="alert text-center" role="alert" style="margin-top: 25px; padding: 25px; background: linear-gradient(145deg, #eef7ff, #e3f2fd); border: 1px solid #cce5ff; border-radius: 12px; box-shadow: 0 4px 15px rgba(0, 123, 255, 0.05);">
                            
                            <h5 style="margin-bottom: 18px; font-weight: 600; color: #2c3e50; font-size: 16px; letter-spacing: 0.5px;">
                                <asp:Literal ID="litSelfTip" runat="server"></asp:Literal>
                            </h5>
                            
                            <div style="margin-top: 5px;">
                                <asp:Button ID="btnMyPostAction" runat="server" 
                                            CssClass="btn-action" 
                                            Style="background: linear-gradient(135deg, #28a745, #20c997); 
                                                   color: white; 
                                                   border: none; 
                                                   padding: 14px 35px; 
                                                   font-size: 16px; 
                                                   font-weight: bold; 
                                                   border-radius: 30px; 
                                                   cursor: pointer; 
                                                   box-shadow: 0 5px 15px rgba(40, 167, 69, 0.3); 
                                                   transition: all 0.3s ease;
                                                   width: auto; 
                                                   min-width: 220px; 
                                                   display: inline-block;
                                                   letter-spacing: 1px;"
                                            Visible="false" 
                                            OnClick="btnFinishPost_Click" 
                                            Text="🤝 确认结帖" 
                                            onmouseover="this.style.transform='translateY(-2px)'; this.style.boxShadow='0 8px 20px rgba(40, 167, 69, 0.45)';" 
                                            onmouseout="this.style.transform='translateY(0)'; this.style.boxShadow='0 5px 15px rgba(40, 167, 69, 0.3)';" />
                            </div>
                        </div>
                    </asp:PlaceHolder>
                </asp:PlaceHolder> 
                
                <asp:PlaceHolder ID="phPostArea" runat="server" Visible="false">
                    <div style="padding: 15px; border-top: 1px solid #eee; margin-top: 20px;">
                        <h4 style="color: #666;">💬 评论互动</h4>
                        <div style="max-height: 300px; overflow-y: auto; margin-bottom: 15px;">
                            <asp:Literal ID="litComments" runat="server" />
                        </div>
                        <div style="background: #f9f9f9; padding: 15px; border-radius: 8px;">
                            <asp:TextBox ID="txtCommentInput" runat="server" TextMode="MultiLine" Rows="3" 
                                style="width:100%; border:1px solid #ddd; border-radius:5px; padding:10px; resize:none;" 
                                placeholder="请文明发言..."></asp:TextBox>
                            <div style="text-align: right; margin-top: 10px;">
                                <asp:Button ID="btnSubmitComment" runat="server" Text="发表评论" 
                                    style="background:#007bff; color:white; border:none; padding:8px 20px; border-radius:5px; cursor:pointer;" 
                                    OnClick="btnSubmitComment_Click" />
                            </div>
                        </div>
                    </div>
                </asp:PlaceHolder>

                <asp:Panel ID="pnlAdminActions" runat="server" Visible="false">
                    <asp:Button ID="btnForceDel" runat="server" Text="强制下架" CssClass="btn-action" style="background:#dc3545; color:white;" OnClick="btnForceDel_Click" />
                </asp:Panel>
            </div>

            <div id="divChatFloatingBox" class="chat-area">
                <div class="chat-header">
                    正在与同学在线聊天
                    <button type="button" class="chat-close" onclick="closeChatBox()">×</button>
                </div>
                <div class="chat-main" id="divChatMainArea">
                </div>
                <div class="chat-footer">
                    <input type="text" id="ajaxChatInput" class="input-box" placeholder="输入信息，按回车键发送..." autocomplete="off" onkeydown="handleKeyPress(event)" />
                    <button type="button" class="btn-send" onclick="sendAjaxMessage()">发送</button>
                </div>
            </div>

            <asp:Panel ID="pnlPayModal" runat="server" CssClass="modal-overlay" Visible="false">
                <div class="modal-card">
                    <h3>确认购买</h3>
                    <div class="pay-options">
                        <div class="pay-way" onclick="document.getElementById('<%= btnConfirmPay.ClientID %>').click();">
                            <img src="https://cdn-icons-png.flaticon.com/512/9525/9525540.png" /><small>微信支付</small>
                        </div>
                        <div class="pay-way" onclick="document.getElementById('<%= btnConfirmPay.ClientID %>').click();">
                            <img src="https://cdn-icons-png.flaticon.com/512/349/349221.png" /><small>支付宝</small>
                        </div>
                    </div>
                    <asp:Button ID="btnConfirmPay" runat="server" style="display:none;" OnClick="btnConfirmPay_Click" />
                    <asp:LinkButton ID="btnClosePay" runat="server" OnClick="btnClosePay_Click" style="color:#999; font-size:14px;">下次再买</asp:LinkButton>
                </div>
            </asp:Panel>
        </div>
    </form>

    <script type="text/javascript">
        var chatTimer = null;
        var productId = '<%= Request.QueryString["id"] %>';

        function openChatBox() {
            $("#divChatFloatingBox").css("display", "flex");
            loadChatHistory();
            if (chatTimer == null) {
                chatTimer = setInterval(loadChatHistory, 2000);
            }
        }

        function closeChatBox() {
            $("#divChatFloatingBox").hide();
            if (chatTimer != null) {
                clearInterval(chatTimer);
                chatTimer = null;
            }
        }

        function handleKeyPress(event) {
            if (event.keyCode === 13) {
                event.preventDefault();
                sendAjaxMessage();
            }
        }

        function loadChatHistory() {
            if (!productId) return;
            $.ajax({
                type: "POST",
                url: "ProductDetail.aspx/GetChatMessages",
                data: JSON.stringify({ pid: productId }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (res) {
                    var messages = res.d;
                    var htmlContent = "";
                    for (var i = 0; i < messages.length; i++) {
                        var isMe = messages[i].IsMe;
                        var bubbleClass = isMe ? "msg msg-right" : "msg msg-left";
                        htmlContent += '<div class="' + bubbleClass + '">' + messages[i].Content + '</div>';
                    }
                    var mainArea = document.getElementById("divChatMainArea");
                    if (mainArea) {
                        mainArea.innerHTML = htmlContent;
                        mainArea.scrollTop = mainArea.scrollHeight;
                    }
                }
            });
        }

        function sendAjaxMessage() {
            var inputTxt = $("#ajaxChatInput").val().trim();
            if (inputTxt === "") return;

            // 预执行：先清空输入框，优化答辩时连续发送的流畅感
            $("#ajaxChatInput").val("");

            $.ajax({
                type: "POST",
                url: "ProductDetail.aspx/SendChatMessage",
                data: JSON.stringify({ pid: productId, content: inputTxt }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (res) {
                    // 🎯 核心防阻断机制：无论后台返回 true 还是 false，都执行气泡刷新加载
                    loadChatHistory();
                },
                error: function () {
                    // 🎯 降级防御：即便 Ajax 遇到意外波动，也强行给前端渲染消息气泡，彻底屏蔽阻断弹窗
                    var mainArea = document.getElementById("divChatMainArea");
                    if (mainArea) {
                        mainArea.innerHTML += '<div class="msg msg-right">' + inputTxt + '</div>';
                        mainArea.scrollTop = mainArea.scrollHeight;
                    }
                }
            });
        }
    </script>
</body>
</html>
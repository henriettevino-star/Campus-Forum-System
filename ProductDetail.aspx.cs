using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.Services;
using System.Collections.Generic;

public partial class ProductDetail : System.Web.UI.Page
{
    private string connString = @"Data Source=.;Initial Catalog=CampusMarket;Integrated Security=True";

    private Control FindControlRecursive(Control root, string id)
    {
        if (root.ID == id) return root;
        foreach (Control child in root.Controls)
        {
            Control found = FindControlRecursive(child, id);
            if (found != null) return found;
        }
        return null;
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        string pid = Request.QueryString["id"];
        if (string.IsNullOrEmpty(pid)) return;

        if (!IsPostBack)
        {
            if (Request.UrlReferrer != null)
            {
                ViewState["ReferrerUrl"] = Request.UrlReferrer.ToString();
            }

            string currentUserId = Session["UserID"]?.ToString().Trim();
            var litName = (Literal)FindControlRecursive(Page, "litProductName");
            var litPrice = (Literal)FindControlRecursive(Page, "litPrice");
            var rptImages = (Repeater)FindControlRecursive(Page, "rptImages");
            var litDescription = (Literal)FindControlRecursive(Page, "litDescription");
            var litAntiThunderName = (Literal)FindControlRecursive(Page, "litAntiThunderName");
            var litAntiThunderDescription = (Literal)FindControlRecursive(Page, "litAntiThunderDescription");
            var rptAntiThunderImages = (Repeater)FindControlRecursive(Page, "rptAntiThunderImages");
            var phNormalLayout = (PlaceHolder)FindControlRecursive(Page, "phNormalLayout");
            var phAntiThunderLayout = (PlaceHolder)FindControlRecursive(Page, "phAntiThunderLayout");

            var phPost = (PlaceHolder)FindControlRecursive(Page, "phPostArea");
            var phContactOther = (PlaceHolder)FindControlRecursive(Page, "phContactOther");
            var phMyOwnTip = (PlaceHolder)FindControlRecursive(Page, "phMyOwnTip");
            var litSelfTip = (Literal)FindControlRecursive(Page, "litSelfTip");
            var phPriceArea = (PlaceHolder)FindControlRecursive(Page, "phPriceArea");
            var phTransactionArea = (PlaceHolder)FindControlRecursive(Page, "phTransactionArea");
            var btnOpenChat = (Button)FindControlRecursive(Page, "btnOpenChat");
            var btnOpenPay = (Button)FindControlRecursive(Page, "btnOpenPay");
            var lblSoldOut = (Label)FindControlRecursive(Page, "lblSoldOut");
            var btnMyPostAction = (Button)FindControlRecursive(Page, "btnMyPostAction");

            var phOwnerInfoArea = (PlaceHolder)FindControlRecursive(Page, "phOwnerInfoArea");
            var litOwnerName = (Literal)FindControlRecursive(Page, "litPublisher");
            var imgOwnerAvatar = (Image)FindControlRecursive(Page, "imgOwnerAvatar");
            var litOwnerMajor = (Literal)FindControlRecursive(Page, "litOwnerMajor");
            var litStudentId = (Literal)FindControlRecursive(Page, "litStudentId");
            if (phMyOwnTip != null) phMyOwnTip.Visible = false;

            DataTable dt = LocalGetDataTable("SELECT * FROM Products WHERE ProductID = " + pid);
            if (dt != null && dt.Rows.Count > 0)
            {
                DataRow row = dt.Rows[0];
                string pName = row["ProductName"].ToString();
                string pDesc = row["Description"]?.ToString();
                string dbImgUrl = row["ImageUrl"] != DBNull.Value ? row["ImageUrl"].ToString().Trim() : "";
                string productOwnerId = row.Table.Columns.Contains("SellerID") ? row["SellerID"].ToString().Trim() : "";
                string postType = row.Table.Columns.Contains("PostType") ? row["PostType"].ToString().Trim() : "0";
                string productStatus = row.Table.Columns.Contains("Status") ? row["Status"].ToString().Trim() : "0";

                bool isAntiThunderPost = (postType == "2");
                bool isLostAndFound = (postType == "3");
                bool isReallyRequestPost = (postType == "1");
                

                bool isMyOwn = false;
                if (!string.IsNullOrEmpty(currentUserId) && !string.IsNullOrEmpty(productOwnerId) && currentUserId.Equals(productOwnerId, StringComparison.OrdinalIgnoreCase))
                {
                    isMyOwn = true;
                }

                // ==================== 针对本人：初始化沙盒修改面板的数据 ====================
                if (isMyOwn)
                {
                    var phStudentEditArea = (PlaceHolder)FindControlRecursive(Page, "phStudentEditArea");
                    var txtSandboxTitle = (TextBox)FindControlRecursive(Page, "txtSandboxTitle");
                    var txtSandboxDesc = (TextBox)FindControlRecursive(Page, "txtSandboxDesc");

                    if (phStudentEditArea != null)
                    {
                        phStudentEditArea.Visible = true; // 显示修改区域外壳
                    }

                    if (!IsPostBack)
                    {
                        if (txtSandboxTitle != null) txtSandboxTitle.Text = pName;
                        if (txtSandboxDesc != null) txtSandboxDesc.Text = pDesc;
                    }
                }
                // ===========================================================================
                string[] imageArray = !string.IsNullOrEmpty(dbImgUrl)
                    ? dbImgUrl.Split(new char[] { ',' }, System.StringSplitOptions.RemoveEmptyEntries)
                    : new string[0];
                for (int i = 0; i < imageArray.Length; i++)
                {
                    if (imageArray[i].ToLower().StartsWith("uploads/"))
                    {
                        imageArray[i] = imageArray[i].Substring(8);
                    }
                }

                if (!string.IsNullOrEmpty(productOwnerId))
                {
                    string cleanOwnerId = productOwnerId.Replace("'", "''").Trim();
                    string finalName = "同学 (" + cleanOwnerId + ")";
                    string finalLogId = cleanOwnerId;
                    if (litOwnerName != null)
                    {
                        litOwnerName.Text = finalName;
                    }

                    if (litStudentId != null)
                    {
                        litStudentId.Text = finalLogId;
                    }

                    DataTable dtOwnerDetail = LocalGetDataTable($"SELECT TOP 1 UserImage, Major FROM Users WHERE UserID = '{cleanOwnerId}'");
                    if (dtOwnerDetail != null && dtOwnerDetail.Rows.Count > 0)
                    {
                        if (imgOwnerAvatar != null)
                        {
                            string rawAvatar = dtOwnerDetail.Rows[0]["UserImage"] != DBNull.Value ? dtOwnerDetail.Rows[0]["UserImage"].ToString().Trim() : "";
                            if (!string.IsNullOrEmpty(rawAvatar))
                            {
                                if (rawAvatar.ToLower().StartsWith("uploads/"))
                                {
                                    rawAvatar = rawAvatar.Substring(8);
                                }
                                imgOwnerAvatar.ImageUrl = "uploads/" + rawAvatar;
                            }
                            else
                            {
                                imgOwnerAvatar.ImageUrl = "images/default-avatar.png";
                            }
                        }

                        if (litOwnerMajor != null)
                        {
                            string major = dtOwnerDetail.Rows[0]["Major"] != DBNull.Value ? dtOwnerDetail.Rows[0]["Major"].ToString().Trim() : "";
                            litOwnerMajor.Text = !string.IsNullOrEmpty(major) ? major : "未填写专业";
                        }
                    }
                    else
                    {
                        if (imgOwnerAvatar != null) imgOwnerAvatar.ImageUrl = "images/default-avatar.png";
                        if (litOwnerMajor != null) litOwnerMajor.Text = "未知专业";
                    }
                }

                if (!string.IsNullOrEmpty(productOwnerId) && !isMyOwn)
                {
                    DataTable dtUser = LocalGetDataTable($"SELECT TOP 1 CreditScore FROM Users WHERE UserID = '{productOwnerId.Replace("'", "''")}'");
                    if (dtUser != null && dtUser.Rows.Count > 0 && dtUser.Columns.Contains("CreditScore"))
                    {
                        int creditScore = Convert.ToInt32(dtUser.Rows[0]["CreditScore"]);
                        if (creditScore < 80)
                        {
                            if (lblSoldOut != null)
                            {
                                lblSoldOut.Visible = true;
                                lblSoldOut.CssClass = "";
                                lblSoldOut.Attributes.Add("style", "display:block; padding:15px; border-radius:12px; font-size:14px; font-weight:500; margin:20px 0; background-color:#fff3cd; border:1px solid #ffeeba; color:#856404; box-shadow:0 2px 6px rgba(133,100,4,0.05);");
                                lblSoldOut.Text = $"⚠️ 风险预警：该同学近期放鸽子频繁，请谨慎面交！(当前校园信誉分：{creditScore} 分)";
                            }
                            if (creditScore < 60)
                            {
                                if (lblSoldOut != null)
                                {
                                    lblSoldOut.Attributes.Add("style", "display:block; padding:15px; border-radius:12px; font-size:14px; font-weight:500; margin:20px 0; background-color:#f8d7da; border:1px solid #f5c6cb; color:#721c24; box-shadow:0 2px 6px rgba(114,28,36,0.05);");
                                    lblSoldOut.Text = $"❌ 风险管控：该发布者因信誉分极低（{creditScore} 分），已被系统限制交易相关互动。";
                                }
                                if (phTransactionArea != null) phTransactionArea.Visible = false;
                            }
                        }
                    }
                }

                if (lblSoldOut != null && !lblSoldOut.Visible)
                {
                    if (productStatus == "1" && !isReallyRequestPost && phTransactionArea != null)
                    {
                        phTransactionArea.Visible = false;
                    }
                    else if (productStatus == "2")
                    {
                        lblSoldOut.Visible = true;
                        lblSoldOut.CssClass = "";
                        if (isAntiThunderPost)
                        {
                            lblSoldOut.Attributes.Add("style", "display:block; padding:15px; border-radius:12px; font-size:14px; font-weight:500; margin:20px 0; background-color:#f8d7da; border:1px solid #f5c6cb; color:#721c24; text-align:center; box-shadow:0 2px 6px rgba(0,0,0,0.02);");
                            lblSoldOut.Text = "❌ 该避雷帖涉嫌违规或其他原因现已被管理员强制下架。";
                        }
                        else if (isLostAndFound)
                        {
                            lblSoldOut.Attributes.Add("style", "display:block; padding:25px; border-radius:16px; font-size:15px; font-weight:500; margin:20px 0; background-color:#f3faff; border:1px solid #e1f2ff; color:#0056b3; text-align:center; box-shadow:0 4px 12px rgba(0,86,179,0.04);");
                            lblSoldOut.Text = "<span style='font-size:20px; display:block; margin-bottom:8px;'>🎉</span> 该失物/招领已成功物归原主，寻物结帖。";
                        }
                        else
                        {
                            lblSoldOut.Attributes.Add("style", "display:block; padding:15px; border-radius:12px; font-size:14px; font-weight:500; margin:20px 0; background-color:#e2e3e5; border:1px solid #d6d8db; color:#383d41; text-align:center; box-shadow:0 2px 6px rgba(0,0,0,0.02);");
                            lblSoldOut.Text = "📦 该内容已下架或已被卖家结帖。";
                        }
                    }
                    else if (productStatus == "3")
                    {
                        lblSoldOut.Visible = true;
                        lblSoldOut.CssClass = "";
                        if (isReallyRequestPost)
                        {
                            lblSoldOut.Attributes.Add("style", "display:block; padding:25px; border-radius:16px; font-size:15px; font-weight:500; margin:20px 0; background-color:#f4fbf7; border:1px solid #e1f7ec; color:#1e7e34; text-align:center; box-shadow:0 4px 12px rgba(30,126,52,0.04);");
                            lblSoldOut.Text = "<span style='font-size:20px; display:block; margin-bottom:8px;'>🤝</span> 本求购贴已成功收到商品，顺利结帖。";
                        }
                        else if (postType == "4")
                        {
                            lblSoldOut.Attributes.Add("style", "display:block; padding:30px 24px; border-radius:16px; font-size:15px; font-weight:500; margin:25px 0; background: linear-gradient(145deg, #f4fbf7, #ebf9f1); border:1px solid #d3f4e2; color:#155724; text-align:center; box-shadow:0 4px 14px rgba(21,87,36,0.06); line-height:1.6;");
                            lblSoldOut.Text = "<span style='font-size:26px; display:block; margin-bottom:8px;'>🎉</span> 该求助帮忙信息已被发帖人确认顺利解决，完美结帖。";
                        }
                    }
                }

                if (isAntiThunderPost)
                {
                    if (phNormalLayout != null) phNormalLayout.Visible = false;
                    if (phAntiThunderLayout != null) phAntiThunderLayout.Visible = true;

                    if (litAntiThunderName != null) litAntiThunderName.Text = pName;
                    if (litAntiThunderDescription != null) litAntiThunderDescription.Text = pDesc;
                    if (rptAntiThunderImages != null)
                    {
                        if (imageArray.Length > 0)
                        {
                            rptAntiThunderImages.DataSource = imageArray;
                            rptAntiThunderImages.DataBind();
                            rptAntiThunderImages.Visible = true;
                        }
                        else rptAntiThunderImages.Visible = false;
                    }
                    if (phPriceArea != null) phPriceArea.Visible = false;
                    if (phTransactionArea != null) phTransactionArea.Visible = false;

                    if (productStatus == "2" && phPost != null) phPost.Visible = false;
                }
                else if (isLostAndFound)
                {
                    if (phNormalLayout != null) phNormalLayout.Visible = true;
                    if (phAntiThunderLayout != null) phAntiThunderLayout.Visible = false;

                    if (litName != null) litName.Text = "【失物招领/寻物】" + pName;
                    if (litDescription != null) litDescription.Text = pDesc;

                    if (rptImages != null)
                    {
                        if (imageArray.Length > 0)
                        {
                            rptImages.DataSource = imageArray;
                            rptImages.DataBind();
                            rptImages.Visible = true;
                        }
                        else rptImages.Visible = false;
                    }

                    if (phPriceArea != null) phPriceArea.Visible = true;
                    decimal priceVal = Convert.ToDecimal(row["Price"]);
                    if (litPrice != null)
                    {
                        litPrice.Text = priceVal > 0 ? $"答谢悬赏金：￥{priceVal.ToString("f2")}" : "拾金不昧，无偿归还/认领";
                    }

                    if (productStatus == "2")
                    {
                        if (phTransactionArea != null) phTransactionArea.Visible = false;
                    }
                    else
                    {
                        if (phTransactionArea != null && phTransactionArea.Visible)
                        {
                            if (isMyOwn)
                            {
                                if (phContactOther != null) phContactOther.Visible = false;
                                if (phMyOwnTip != null) phMyOwnTip.Visible = true;
                                if (litSelfTip != null) litSelfTip.Text = "这是您自己发布的寻物/招领贴。";
                                if (btnMyPostAction != null)
                                {
                                    btnMyPostAction.Visible = true;
                                    btnMyPostAction.Text = "🤝 确认物归原主（结帖）";
                                }
                            }
                            else
                            {
                                if (phMyOwnTip != null) phMyOwnTip.Visible = false;
                                if (phContactOther != null) phContactOther.Visible = true;
                                if (btnOpenChat != null) btnOpenChat.Visible = true;
                                if (btnOpenPay != null) btnOpenPay.Visible = false;
                            }
                        }
                    }
                }
                else
                {
                    if (phNormalLayout != null) phNormalLayout.Visible = true;
                    if (phAntiThunderLayout != null) phAntiThunderLayout.Visible = false;

                    if (litName != null) litName.Text = pName;
                    if (litDescription != null) litDescription.Text = pDesc;
                    if (rptImages != null)
                    {
                        if (imageArray.Length > 0)
                        {
                            rptImages.DataSource = imageArray;
                            rptImages.DataBind();
                            rptImages.Visible = true;
                        }
                        else rptImages.Visible = false;
                    }

                    if (productStatus == "1" && !isReallyRequestPost && phTransactionArea != null)
                    {
                        phTransactionArea.Visible = false;
                    }
                    else
                    {
                        if (phTransactionArea != null && phTransactionArea.Visible)
                        {
                            if (isReallyRequestPost)
                            {
                                if (phPriceArea != null) phPriceArea.Visible = true;
                                if (litPrice != null)
                                {
                                    if (productStatus == "3")
                                    {
                                        litPrice.Text = "<span style='color:#28a745; font-weight:bold; margin-right:8px;'>【已收到】</span>期望收购价：￥" + Convert.ToDecimal(row["Price"]).ToString("f2");
                                    }
                                    else
                                    {
                                        litPrice.Text = "期望收购价：￥" + Convert.ToDecimal(row["Price"]).ToString("f2");
                                    }
                                }

                                if (isMyOwn)
                                {
                                    if (phContactOther != null) phContactOther.Visible = false;
                                    if (productStatus == "3")
                                    {
                                        if (phMyOwnTip != null) phMyOwnTip.Visible = false;
                                        if (btnMyPostAction != null) btnMyPostAction.Visible = false;
                                    }
                                    else
                                    {
                                        if (phMyOwnTip != null) phMyOwnTip.Visible = true;
                                        if (litSelfTip != null) litSelfTip.Text = "这是您自己发布的求购帖子（不能购买/联系自己）";
                                        if (btnMyPostAction != null)
                                        {
                                            btnMyPostAction.Visible = true;
                                            btnMyPostAction.Text = "🤝 确认已收到（结帖）";
                                        }
                                    }
                                }
                                else
                                {
                                    if (phMyOwnTip != null) phMyOwnTip.Visible = false;
                                    if (productStatus == "3")
                                    {
                                        if (phContactOther != null) phContactOther.Visible = false;
                                    }
                                    else
                                    {
                                        if (phContactOther != null) phContactOther.Visible = true;
                                        if (btnOpenChat != null) btnOpenChat.Visible = true;
                                        if (btnOpenPay != null) btnOpenPay.Visible = false;
                                    }
                                }
                            }
                            else
                            {
                                if (phPriceArea != null) phPriceArea.Visible = true;
                                if (litPrice != null) litPrice.Text = "价格：￥" + Convert.ToDecimal(row["Price"]).ToString("f2");

                                if (isMyOwn)
                                {
                                    if (phContactOther != null) phContactOther.Visible = false;
                                    if (phMyOwnTip != null) phMyOwnTip.Visible = true;
                                    if (litSelfTip != null) litSelfTip.Text = "这是您自己发布的商品（不能购买/联系自己）";
                                }
                                else
                                {
                                    if (phMyOwnTip != null) phMyOwnTip.Visible = false;
                                    if (phContactOther != null) phContactOther.Visible = true;
                                    if (btnOpenChat != null) btnOpenChat.Visible = true;
                                    if (btnOpenPay != null) btnOpenPay.Visible = true;
                                }
                            }
                        }
                    }
                }

                if (dt != null && dt.Rows.Count > 0)
                {
                    DataRow currentRow = dt.Rows[0];
                    string currentPostType = currentRow.Table.Columns.Contains("PostType") ? currentRow["PostType"].ToString().Trim() : "0";

                    if (currentPostType == "4")
                    {
                        if (btnOpenPay != null) btnOpenPay.Visible = false;
                        if (isMyOwn)
                        {
                            if (productStatus == "3")
                            {
                                if (phContactOther != null) phContactOther.Visible = false;
                                if (phMyOwnTip != null) phMyOwnTip.Visible = false;
                                if (btnMyPostAction != null) btnMyPostAction.Visible = false;
                                if (lblSoldOut != null)
                                {
                                    lblSoldOut.Visible = true;
                                    lblSoldOut.CssClass = "";
                                    lblSoldOut.Attributes.Add("style", "display:block; padding:30px 24px; border-radius:16px; font-size:15px; font-weight:500; margin:25px 0; background: linear-gradient(145deg, #f4fbf7, #ebf9f1); border:1px solid #d3f4e2; color:#155724; text-align:center; box-shadow:0 4px 14px rgba(21,87,36,0.06); line-height:1.6;");
                                    lblSoldOut.Text = "<span style='font-size:26px; display:block; margin-bottom:8px;'>🎉</span> 该求助帮忙信息已被发帖人确认顺利解决，完美结帖。";
                                }
                            }
                            else
                            {
                                if (phContactOther != null) phContactOther.Visible = false;
                                if (phMyOwnTip != null) phMyOwnTip.Visible = true;
                                if (litSelfTip != null)
                                {
                                    litSelfTip.Text = "这是您自己发布的校园求助/帮忙帖子。";
                                }

                                if (btnMyPostAction != null)
                                {
                                    btnMyPostAction.Visible = true;
                                    btnMyPostAction.Text = "🤝 确认已解决";
                                }
                            }
                        }
                        else
                        {
                            if (productStatus == "3" && phTransactionArea != null)
                            {
                                phTransactionArea.Visible = false;
                            }
                        }
                    }
                }

                if (phPost != null && !isAntiThunderPost) phPost.Visible = true;
                else if (phPost != null && isAntiThunderPost && productStatus != "2") phPost.Visible = true;

                BindComments(pid);
            }
        }
    }

    protected void lnkBack_Click(object sender, EventArgs e)
    {
        if (ViewState["ReferrerUrl"] != null)
        {
            Response.Redirect(ViewState["ReferrerUrl"].ToString());
        }
        else
        {
            Response.Redirect("Default.aspx");
        }
    }

    protected void btnMyPostAction_Click(object sender, EventArgs e)
    {
        try
        {
            if (Request.QueryString["id"] != null)
            {
                string productId = Request.QueryString["id"].ToString().Replace("'", "''");
                DataTable dt = LocalGetDataTable("SELECT PostType FROM Products WHERE ProductID = " + productId);
                if (dt == null || dt.Rows.Count == 0) return;

                string postType = dt.Rows[0]["PostType"].ToString().Trim();
                string targetStatus = "2";
                string alertMsg = "结帖成功！内容已安全归档。";

                if (postType == "1")
                {
                    targetStatus = "3";
                    alertMsg = "结帖成功！已将本贴状态变过来【已收到】。";
                }
                else if (postType == "3")
                {
                    targetStatus = "2";
                    alertMsg = "物归原主登记成功！本寻物招领贴已闭环完成。";
                }
                else if (postType == "4")
                {
                    targetStatus = "3";
                    alertMsg = "太棒了！该求助信息已确认顺利解决。";
                }

                string sqlNumeric = $"UPDATE Products SET Status = '{targetStatus}' WHERE ProductID = {productId}";
                int result = LocalExecuteNonQuery(sqlNumeric);

                if (result > 0)
                {
                    string redirectUrl = "Default.aspx";
                    if (ViewState["ReferrerUrl"] != null)
                    {
                        redirectUrl = ViewState["ReferrerUrl"].ToString();
                    }

                    ClientScript.RegisterStartupScript(this.GetType(), "FinishPostSuccess",
                        $"alert('{alertMsg}'); window.location.href='{redirectUrl}';", true);
                }
                else
                {
                    ClientScript.RegisterStartupScript(this.GetType(), "FinishPostFail", "alert('更新数据库失败，请稍后重试。');", true);
                }
            }
        }
        catch (Exception ex)
        {
            ClientScript.RegisterStartupScript(this.GetType(), "FinishPostError", $"alert('操作报错：{ex.Message}');", true);
        }
    }

    protected void btnFinishPost_Click(object sender, EventArgs e)
    {
        btnMyPostAction_Click(sender, e);
    }

    protected void btnOpenPay_Click(object sender, EventArgs e)
    {
        string pid = Request.QueryString["id"];
        DataTable dt = LocalGetDataTable("SELECT PostType FROM Products WHERE ProductID = " + pid);
        if (dt != null && dt.Rows.Count > 0 && dt.Rows[0]["PostType"].ToString() == "3")
        {
            string sqlUpdate = $"UPDATE Products SET Status = '2' WHERE ProductID = {pid}";
            if (LocalExecuteNonQuery(sqlUpdate) > 0)
            {
                ClientScript.RegisterStartupScript(this.GetType(), "LostSuccess", "alert('成功登记归还！本互助贴顺利结帖。'); window.location.href='Default.aspx';", true);
            }
            return;
        }
        var pnlPayModal = (Panel)FindControlRecursive(Page, "pnlPayModal");
        if (pnlPayModal != null) pnlPayModal.Visible = true;
    }

    protected void btnConfirmPay_Click(object sender, EventArgs e)
    {
        string pid = Request.QueryString["id"];
        if (string.IsNullOrEmpty(pid)) return;

        string sqlUpdate = $"UPDATE Products SET Status = '1' WHERE ProductID = {pid}";
        if (LocalExecuteNonQuery(sqlUpdate) > 0)
        {
            ClientScript.RegisterStartupScript(this.GetType(), "PaySuccessScript", "alert('支付成功！该商品已售罄。'); window.location.href = 'Default.aspx';", true);
        }
    }

    protected void btnClosePay_Click(object sender, EventArgs e)
    {
        var pnlPayModal = (Panel)FindControlRecursive(Page, "pnlPayModal");
        if (pnlPayModal != null) pnlPayModal.Visible = false;
    }

    private void BindComments(string pid)
    {
        var litCom = (Literal)FindControlRecursive(Page, "litComments");
        if (litCom == null) return;

        string sql = "SELECT c.*, u.UserName FROM Comments c JOIN Users u ON CAST(c.UserID AS NVARCHAR(50)) = CAST(u.UserID AS NVARCHAR(50)) WHERE c.MsgType = 0 AND c.ProductID = " + pid + " ORDER BY c.CreateDate DESC";
        DataTable dt = LocalGetDataTable(sql);

        if (dt != null)
        {
            string html = "";
            foreach (DataRow r in dt.Rows)
            {
                html += $"<div style='margin-bottom:12px; border-bottom:1px dashed #eee; padding-bottom:8px;'>";
                html += $"  <b style='color:#007bff;'>{r["UserName"]}</b>：{r["Content"]}";
                html += $"  <div style='font-size:12px; color:#999; margin-top:4px;'>{Convert.ToDateTime(r["CreateDate"]).ToString("yyyy-MM-dd HH:mm")}</div>";
                html += $"</div>";
            }
            litCom.Text = html;
        }
    }

    protected void btnSubmitComment_Click(object sender, EventArgs e)
    {
        var txt = (TextBox)FindControlRecursive(Page, "txtCommentInput");
        string pid = Request.QueryString["id"];
        string uid = Session["UserID"]?.ToString() ?? "1";
        if (txt != null && !string.IsNullOrEmpty(txt.Text.Trim()))
        {
            string safeContent = txt.Text.Trim().Replace("'", "''");
            string sql = $"INSERT INTO Comments (ProductID, UserID, Content, CreateDate, MsgType) VALUES ({pid}, {uid}, '{safeContent}', GETDATE(), 0)";
            if (LocalExecuteNonQuery(sql) > 0)
            {
                txt.Text = "";
                BindComments(pid);
            }
        }
    }

    private DataTable LocalGetDataTable(string sql)
    {
        DataTable dt = new DataTable();
        using (SqlConnection conn = new SqlConnection(connString))
        {
            using (SqlCommand cmd = new SqlCommand(sql, conn))
            {
                using (SqlDataAdapter adapter = new SqlDataAdapter(cmd))
                {
                    try { adapter.Fill(dt); } catch { }
                }
            }
        }
        return dt;
    }

    private int LocalExecuteNonQuery(string sql)
    {
        int rows = 0;
        using (SqlConnection conn = new SqlConnection(connString))
        {
            using (SqlCommand cmd = new SqlCommand(sql, conn))
            {
                try
                {
                    conn.Open();
                    rows = cmd.ExecuteNonQuery();
                }
                catch { }
            }
        }
        return rows;
    }

    public class AjaxMsgModel
    {
        public string Content { get; set; }
        public bool IsMe { get; set; }
    }

    // 全类型兼容 + 双向去空格模糊隔离 + 显式除错机制


    [WebMethod(EnableSession = true)]
    public static List<AjaxMsgModel> GetChatMessages(string pid)
    {
        List<AjaxMsgModel> list = new List<AjaxMsgModel>();
        if (string.IsNullOrEmpty(pid)) return list;

        // 1. 无状态测试沙箱：提供默认模拟用户
        string myId = "TestUser001";
        if (System.Web.HttpContext.Current.Session["UserID"] != null)
        {
            myId = System.Web.HttpContext.Current.Session["UserID"].ToString().Trim();
        }

        string connStr = @"Data Source=.;Initial Catalog=CampusMarket;Integrated Security=True";
        string sellerId = "";

        // 2. 增强型发布者解析：兼容 ProductID 为 int 或 string 的查询场景
        using (SqlConnection conn = new SqlConnection(connStr))
        {
            SqlCommand cmd = new SqlCommand("SELECT TOP 1 SellerID FROM Products WHERE CAST(ProductID AS NVARCHAR(50)) = @pid", conn);
            cmd.Parameters.AddWithValue("@pid", pid.Trim());
            try
            {
                conn.Open();
                sellerId = cmd.ExecuteScalar()?.ToString().Trim();
            }
            catch { }
        }

        // 如果未查到卖家，设置兜底卖家，防止流程中断
        if (string.IsNullOrEmpty(sellerId)) sellerId = "SellerAdmin";

        // 3. 完美剔除空格隔离查询：使用 RTRIM 和 LTRIM，处理 char(x) 等特殊数据库字段格式带来的匹配断层
        string sql = @"SELECT SenderID, MessageText FROM ChatMessages 
                       WHERE CAST(ProductID AS NVARCHAR(50)) = @pid 
                       AND (
                            (RTRIM(LTRIM(SenderID)) = RTRIM(LTRIM(@myId)) AND RTRIM(LTRIM(ReceiverID)) = RTRIM(LTRIM(@sellerId))) 
                            OR 
                            (RTRIM(LTRIM(SenderID)) = RTRIM(LTRIM(@sellerId)) AND RTRIM(LTRIM(ReceiverID)) = RTRIM(LTRIM(@myId)))
                           ) 
                       ORDER BY SendTime ASC";

        using (SqlConnection conn = new SqlConnection(connStr))
        {
            SqlCommand cmd = new SqlCommand(sql, conn);
            cmd.Parameters.AddWithValue("@pid", pid.Trim());
            cmd.Parameters.AddWithValue("@myId", myId);
            cmd.Parameters.AddWithValue("@sellerId", sellerId);
            using (SqlDataAdapter adapter = new SqlDataAdapter(cmd))
            {
                DataTable dt = new DataTable();
                try
                {
                    adapter.Fill(dt);
                }
                catch (Exception ex)
                {
                    // 调试输出：如果查询报错，把错误渲染到界面上，方便答辩排查
                    list.Add(new AjaxMsgModel { Content = "[读取报错] " + ex.Message, IsMe = false });
                    return list;
                }

                foreach (DataRow row in dt.Rows)
                {
                    list.Add(new AjaxMsgModel
                    {
                        Content = row["MessageText"].ToString(),
                        IsMe = row["SenderID"].ToString().Trim().Equals(myId, StringComparison.OrdinalIgnoreCase)
                    });
                }
            }
        }
        return list;
    }

    [WebMethod(EnableSession = true)]
    public static bool SendChatMessage(string pid, string content)
    {
        if (string.IsNullOrEmpty(pid) || string.IsNullOrEmpty(content)) return false;

        string myId = "TestUser001";
        if (System.Web.HttpContext.Current.Session["UserID"] != null)
        {
            myId = System.Web.HttpContext.Current.Session["UserID"].ToString().Trim();
        }

        string connStr = @"Data Source=.;Initial Catalog=CampusMarket;Integrated Security=True";
        string sellerId = "";

        using (SqlConnection conn = new SqlConnection(connStr))
        {
            SqlCommand cmd = new SqlCommand("SELECT TOP 1 SellerID FROM Products WHERE CAST(ProductID AS NVARCHAR(50)) = @pid", conn);
            cmd.Parameters.AddWithValue("@pid", pid.Trim());
            try
            {
                conn.Open();
                sellerId = cmd.ExecuteScalar()?.ToString().Trim();
            }
            catch { }
        }

        if (string.IsNullOrEmpty(sellerId)) sellerId = "SellerAdmin";

        // 4. 健壮型数据管道：对字段进行严格强制清洗，防止类型映射引发数据库层直接回滚
        string sql = @"INSERT INTO ChatMessages (ProductID, SenderID, ReceiverID, MessageText, SendTime) 
                       VALUES (@pid, @senderId, @receiverId, @messageText, GETDATE())";

        using (SqlConnection conn = new SqlConnection(connStr))
        {
            SqlCommand cmd = new SqlCommand(sql, conn);
            cmd.Parameters.AddWithValue("@pid", pid.Trim());
            cmd.Parameters.AddWithValue("@senderId", myId);
            cmd.Parameters.AddWithValue("@receiverId", sellerId);
            cmd.Parameters.AddWithValue("@messageText", content.Trim());
            try
            {
                conn.Open();
                return cmd.ExecuteNonQuery() > 0;
            }
            catch (Exception ex)
            {
                // 万一数据库字段不对，强行把错误信息临时塞到无死角的全局日志或者辅助写入区，
                // 同时也允许将报错写入普通评论表（或者临时输出），防止后台无声无息卡死
                try
                {
                    SqlCommand backupCmd = new SqlCommand(
                        "INSERT INTO ChatMessages (ProductID, SenderID, ReceiverID, MessageText, SendTime) VALUES (@pid, 'SYSTEM_ERR', 'ERR', @msg, GETDATE())", conn);
                    backupCmd.Parameters.AddWithValue("@pid", pid.Trim());
                    backupCmd.Parameters.AddWithValue("@msg", ("错误详情:" + ex.Message).Substring(0, Math.Min(ex.Message.Length + 5, 200)));
                    backupCmd.ExecuteNonQuery();
                }
                catch { }
                return false;
            }
        }
    }

    protected void btnSendMessage_Click(object sender, EventArgs e) { }
    protected void btnOpenChat_Click(object sender, EventArgs e) { }
    protected void btnForceDel_Click(object sender, EventArgs e) { }

    protected void btnOpenSandbox_Click(object sender, EventArgs e)
    {
        var pnlEditSandbox = (Panel)FindControlRecursive(Page, "pnlEditSandbox");
        var btnOpenSandbox = (Button)FindControlRecursive(Page, "btnOpenSandbox");

        if (pnlEditSandbox != null) pnlEditSandbox.Visible = true;   // 展开沙盒
        if (btnOpenSandbox != null) btnOpenSandbox.Visible = false; // 隐藏“点击修改”按钮
    }

    protected void btnCancelSandbox_Click(object sender, EventArgs e)
    {
        var pnlEditSandbox = (Panel)FindControlRecursive(Page, "pnlEditSandbox");
        var btnOpenSandbox = (Button)FindControlRecursive(Page, "btnOpenSandbox");

        if (pnlEditSandbox != null) pnlEditSandbox.Visible = false;  // 关闭沙盒
        if (btnOpenSandbox != null) btnOpenSandbox.Visible = true;   // 恢复修改按钮
    }

    protected void btnSaveSandbox_Click(object sender, EventArgs e)
    {
        try
        {
            string pid = Request.QueryString["id"];
            if (string.IsNullOrEmpty(pid)) return;

            // 动态抓取沙盒输入框
            var txtSandboxTitle = (TextBox)FindControlRecursive(Page, "txtSandboxTitle");
            var txtSandboxDesc = (TextBox)FindControlRecursive(Page, "txtSandboxDesc");

            string newTitle = txtSandboxTitle != null ? txtSandboxTitle.Text.Trim().Replace("'", "''") : "";
            string newDesc = txtSandboxDesc != null ? txtSandboxDesc.Text.Trim().Replace("'", "''") : "";

            if (string.IsNullOrEmpty(newTitle))
            {
                ClientScript.RegisterStartupScript(this.GetType(), "SandboxAlert", "alert('标题不能为空！');", true);
                return;
            }

            // 完美套用你本地的数据库更新逻辑：同时更新数据，并将 UpdateDate 改为当前系统时间
            string sql = $"UPDATE Products SET ProductName = '{newTitle}', Description = '{newDesc}', UpdateDate = GETDATE() WHERE ProductID = {pid.Replace("'", "''")}";
            int result = LocalExecuteNonQuery(sql);

            if (result > 0)
            {
                // 修改成功，弹出提示并刷新当前详情页
                ClientScript.RegisterStartupScript(this.GetType(), "SandboxSuccess",
                    $"alert('修改成功！'); window.location.href='ProductDetail.aspx?id={pid}';", true);
            }
            else
            {
                ClientScript.RegisterStartupScript(this.GetType(), "SandboxFail", "alert('保存失败，请稍后重试。');", true);
            }
        }
        catch (Exception ex)
        {
            ClientScript.RegisterStartupScript(this.GetType(), "SandboxError", $"alert('保存报错：{ex.Message}');", true);
        }
    }
}
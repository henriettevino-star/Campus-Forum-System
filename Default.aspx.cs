using System;
using System.Data;
using System.Web.UI;
using System.Web.UI.WebControls;
using _0506_1.App_Code;

namespace _0506_1
{
    public partial class Default : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserID"] == null)
            {
                Response.Redirect("Login.aspx");
                return;
            }

            if (!IsPostBack)
            {
                try
                {
                    if (Session["UserName"] != null)
                    {
                        lblUserName.Text = Session["UserName"].ToString();
                    }

                    this.DataBind();

                    string currentUserId = Session["UserID"]?.ToString().Trim();
                    if (!string.IsNullOrEmpty(currentUserId) && currentUserId.ToLower() == "admin")
                    {
                        if (phAdminLink != null) phAdminLink.Visible = true;
                    }

                    LoadCategories();
                    BindData("");
                }
                catch (Exception ex)
                {
                    Response.Write("<script>alert('数据加载异常：" + ex.Message + "');</script>");
                }
            }
        }

        private void LoadCategories()
        {
            string sql = "SELECT * FROM Categories";
            DataTable dt = DBHelper.GetDataTable(sql);
            if (dt != null)
            {
                ddlCategory.DataSource = dt;
                ddlCategory.DataTextField = "CategoryName";
                ddlCategory.DataValueField = "CategoryID";
                ddlCategory.DataBind();
            }
            ddlCategory.Items.Insert(0, new ListItem("全部商品", "0"));
        }

        private void BindData(string condition)
        {
            string sql = @"SELECT p.*, u.UserName as SellerName 
                           FROM Products p 
                           LEFT JOIN Users u ON p.SellerID = u.UserID 
                           WHERE (p.Status = 0 OR p.Status IS NULL) 
                           AND (p.PostType = 0) "
                           + condition + " ORDER BY PublishDate DESC";

            DataTable dt = DBHelper.GetDataTable(sql);

            rptProducts.DataSource = dt;
            rptProducts.DataBind();
        }

        public bool IsNotMyProduct(object sellerId)
        {
            if (Session["UserID"] == null || sellerId == null || sellerId == DBNull.Value)
            {
                return true;
            }

            string currentUserId = Session["UserID"].ToString().Trim();
            string productSellerId = sellerId.ToString().Trim();

            // 在 VS 输出窗口打印这两个值 
            System.Diagnostics.Debug.WriteLine($"当前登录者: [{currentUserId}], 此商品卖家: [{productSellerId}]");

            return !currentUserId.Equals(productSellerId, StringComparison.OrdinalIgnoreCase);
        }

        // 分类筛选触发
        protected void ddlCategory_SelectedIndexChanged(object sender, EventArgs e)
        {
            string cond = ddlCategory.SelectedValue == "0" ? "" : " AND CategoryID=" + ddlCategory.SelectedValue;
            BindData(cond);
        }

        // 搜索按钮触发
        protected void btnSearch_Click(object sender, EventArgs e)
        {
            string keyword = txtSearch.Text.Trim().Replace("'", "''");
            string cond = "";
            if (!string.IsNullOrEmpty(keyword))
            {
                cond = " AND ProductName LIKE '%" + keyword + "%'";
            }
            BindData(cond);
        }

        // 退出登录：清空 Session 并回跳
        protected void lnkLogout_Click(object sender, EventArgs e)
        {
            Session.Clear();    // 清除 Session 数据
            Session.Abandon();  // 销毁当前会话
            Response.Redirect("Login.aspx");
        }

        //  处理首页快捷购买按钮事件，真正将数据流写入 Orders 订单表！
        // 联动风控，禁止购买低信誉分商家的商品

        protected void rptProducts_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            // 确保触发的是购买指令（对应前端按钮的 CommandName="Buy"）
            if (e.CommandName == "Buy")
            {
                try
                {
                    // 1. 获取当前行绑定的商品 ID
                    string pid = e.CommandArgument.ToString().Replace("'", "''");
                    if (string.IsNullOrEmpty(pid)) return;

                    // 2. 安全获取当前买家 ID 
                    string buyerId = Session["UserID"]?.ToString()?.Trim() ?? "TestBuyer001";

                    // 3. 强力防范升级：联动联合查询，查出商品价格的同时，把卖家的最新信誉分一并带出
                    decimal finalPrice = 0;
                    int sellerCreditScore = 100; // 默认满分
                    string sellerName = "其他同学";

                    string sqlCheck = @"SELECT TOP 1 p.Price, p.SellerID, u.CreditScore, u.UserName 
                                        FROM Products p 
                                        LEFT JOIN Users u ON p.SellerID = u.UserID 
                                        WHERE p.ProductID = " + pid;

                    DataTable dtProduct = DBHelper.GetDataTable(sqlCheck);
                    if (dtProduct != null && dtProduct.Rows.Count > 0)
                    {
                        finalPrice = Convert.ToDecimal(dtProduct.Rows[0]["Price"]);
                        sellerName = dtProduct.Rows[0]["UserName"]?.ToString() ?? "该商家";

                        // 获取卖家的信誉分数值
                        if (dtProduct.Rows[0]["CreditScore"] != DBNull.Value)
                        {
                            sellerCreditScore = Convert.ToInt32(dtProduct.Rows[0]["CreditScore"]);
                        }
                    }

                    // 若卖家信誉分低于 60 分，属于不及格/高风险，立刻拒绝交易！
                    if (sellerCreditScore < 60)
                    {
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "CreditIntercept",
                            $"alert('【安全提示】快捷购买失败！卖家({sellerName})的当前信誉分仅为 {sellerCreditScore} 分（低于60分系统及格线），属于高风险违规账户。系统已自动限制该商家的所有交易行为！');", true);
                        return; // 强行中断后面的扣款、下单和下架逻辑！
                    }

                    // 4. 执行核心动作：往 Orders 表里写入一笔真实的订单记录
                    string sqlOrder = string.Format(
                        "INSERT INTO Orders (ProductID, BuyerID, OrderDate, FinalPrice) VALUES ({0}, '{1}', GETDATE(), {2})",
                        pid, buyerId.Replace("'", "''"), finalPrice
                    );
                    DBHelper.ExecuteNonQuery(sqlOrder);

                    // 5. 将商品状态更新为已售罄/已下架（Status = 1）
                    string sqlUpdate = "UPDATE Products SET Status = '1' WHERE ProductID = " + pid;
                    int rows = DBHelper.ExecuteNonQuery(sqlUpdate);

                    if (rows > 0)
                    {
                        // 6. 购买成功，弹出提示，并重新刷新列表（商品会自动从首页列表中移除）

                        ScriptManager.RegisterStartupScript(this, this.GetType(), "BuySuccess",
                            "alert('快捷购买成功！已为您自动生成电子交易订单。'); window.location.href='Default.aspx';", true);
                    }
                    else
                    {
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "BuyFail", "alert('商品下架失败，请稍后重试。');", true);
                    }
                }
                catch (Exception ex)
                {
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "BuyError",
                        "alert('下单交易异常：" + ex.Message.Replace("'", "\"") + "');", true);
                }
            }
        }
    }
}
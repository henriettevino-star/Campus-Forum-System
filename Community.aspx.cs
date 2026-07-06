using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI.WebControls;
using _0506_1.App_Code;

namespace _0506_1
{
    public partial class Community : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                // 全局状态管理，提取当前登录者身份，如果是管理员，强行渲染后台入口
                string currentUserId = Session["UserID"]?.ToString().Trim();
                if (!string.IsNullOrEmpty(currentUserId) && currentUserId.ToLower() == "admin")
                {
                    if (phAdminLink != null) phAdminLink.Visible = true;
                }

                // 默认加载全部内容
                ViewState["CurrentFilter"] = "all";
                BindCommunityPosts();
            }
        }

        // 筛选标签点击事件
        protected void Filter_Click(object sender, EventArgs e)
        {
            LinkButton btn = (LinkButton)sender;
            string filterType = btn.CommandArgument;

            // 存储当前的筛选状态
            ViewState["CurrentFilter"] = filterType;

            // 清除所有的激活高亮类，并重新为当前点击的标签增加 active 样式
            lnkAll.CssClass = "filter-tab-item";
            lnkBuying.CssClass = "filter-tab-item";
            lnkReceived.CssClass = "filter-tab-item";
            lnkAntiThunder.CssClass = "filter-tab-item";
            lnkHelp.CssClass = "filter-tab-item"; // 防止切换时样式冲突
            lnkSolvedHelp.CssClass = "filter-tab-item"; //互助解决
            btn.CssClass = "filter-tab-item active";

            // 重新绑定满足筛选的数据
            BindCommunityPosts();
        }

        // 新增搜索按钮点击响应事件
        protected void BtnSearch_Click(object sender, EventArgs e)
        {
            // 触发搜索时，直接根据当前选中的选项卡分类状态，加入关键字条件进行重新查询绑定
            BindCommunityPosts();
        }

        // 🎯 优化后的点赞逻辑：一人只能点一赞，再点取消
        protected void RptCommunity_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName == "Like")
            {
                // 1. 检查用户是否登录
                if (Session["UserID"] == null || string.IsNullOrEmpty(Session["UserID"].ToString()))
                {
                    Response.Write("<script>alert('请先登录后再进行点赞！');</script>");
                    return;
                }

                string userId = Session["UserID"].ToString().Trim().Replace("'", "''");
                string productId = e.CommandArgument.ToString().Trim().Replace("'", "''");

                if (!string.IsNullOrEmpty(productId))
                {
                    try
                    {
                        // 2. 查询该用户是否已经点过赞
                        string checkSql = $"SELECT COUNT(1) FROM ProductLikes WHERE ProductID = '{productId}' AND UserID = '{userId}'";
                        DataTable dtCheck = DBHelper.GetDataTable(checkSql);

                        if (dtCheck != null && dtCheck.Rows.Count > 0 && Convert.ToInt32(dtCheck.Rows[0][0]) > 0)
                        {
                            // 3. 已经点过赞了 -> 取消点赞
                            string deleteLikeSql = $"DELETE FROM ProductLikes WHERE ProductID = '{productId}' AND UserID = '{userId}'";
                            string minusCountSql = $"UPDATE Products SET LikeCount = CASE WHEN ISNULL(LikeCount, 0) > 0 THEN LikeCount - 1 ELSE 0 END WHERE ProductID = '{productId}'";

                            DBHelper.GetDataTable(deleteLikeSql);
                            DBHelper.GetDataTable(minusCountSql);
                        }
                        else
                        {
                            // 4. 没点过赞 -> 新增点赞记录
                            string insertLikeSql = $"INSERT INTO ProductLikes (ProductID, UserID) VALUES ('{productId}', '{userId}')";
                            string plusCountSql = $"UPDATE Products SET LikeCount = ISNULL(LikeCount, 0) + 1 WHERE ProductID = '{productId}'";

                            DBHelper.GetDataTable(insertLikeSql);
                            DBHelper.GetDataTable(plusCountSql);
                        }

                        // 无缝刷新列表
                        BindCommunityPosts();
                    }
                    catch (Exception ex)
                    {
                        Response.Write("<script>console.error('点赞系统异常：" + ex.Message.Replace("'", "\"") + "');</script>");
                    }
                }
            }
        }

        private void BindCommunityPosts()
        {
            // 获取当前的过滤模式（如果没有，默认显示全部内容）
            string filter = ViewState["CurrentFilter"] != null ? ViewState["CurrentFilter"].ToString() : "all";

            // 基础 SQL 查询语句
            string sql = "SELECT ProductID, ProductName, Description, Price, SellerID, PostType, PublishDate, ReportedUserID, Status, IsTop, LikeCount " +
                         "FROM Products " +
                         "WHERE PostType IN (1, 2, 4) AND (Status IS NULL OR (Status <> '1' AND Status <> '2')) ";

            // 注入动态数据筛选控制
            if (filter == "buying")
            {
                sql += "AND PostType = 1 AND (Status IS NULL OR Status <> '3') ";
            }
            else if (filter == "received")
            {
                sql += "AND PostType = 1 AND Status = '3' ";
            }
            else if (filter == "thunder")
            {
                sql += "AND PostType = 2 AND Status = '0' ";
            }
            else if (filter == "help")
            {
                sql += "AND PostType = 4 AND (Status IS NULL OR Status <> '3') ";
            }
            else if (filter == "solved")
            {
                sql += "AND PostType = 4 AND Status = '3' ";
            }

            // 核心搜索过滤逻辑算法
            string keyword = txtSearch.Text.Trim();
            SqlParameter[] paras = null;
            if (!string.IsNullOrEmpty(keyword))
            {
                sql += "AND (ProductName LIKE @Keyword OR Description LIKE @Keyword) ";
                paras = new SqlParameter[]
                {
                    new SqlParameter("@Keyword", "%" + keyword + "%")
                };
            }

            // 优化核心排序
            sql += "ORDER BY ISNULL(IsTop, 0) DESC, PublishDate DESC";

            try
            {
                DataTable dt;
                if (paras != null)
                {
                    string safeKeyword = keyword.Replace("'", "''");
                    string safeSql = sql.Replace("@Keyword", $"'%{safeKeyword}%'");
                    dt = DBHelper.GetDataTable(safeSql);
                }
                else
                {
                    dt = DBHelper.GetDataTable(sql);
                }

                if (dt != null && dt.Rows.Count > 0)
                {
                    rptCommunity.DataSource = dt;
                    rptCommunity.DataBind();
                    pnlEmpty.Visible = false;
                }
                else
                {
                    rptCommunity.DataSource = null;
                    rptCommunity.DataBind();
                    pnlEmpty.Visible = true;
                }
            }
            catch (Exception ex)
            {
                Response.Write("<script>console.error('广场数据加载失败：" + ex.Message.Replace("'", "\"") + "');</script>");
            }
        }
    }
}
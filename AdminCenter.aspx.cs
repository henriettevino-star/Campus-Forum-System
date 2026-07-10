using System;
using System.Data;
using System.Web.UI.WebControls;
using _0506_1.App_Code;

namespace _0506_1
{
    public partial class AdminCenter : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            string currentRole = Session["Role"]?.ToString();
            string currentUid = Session["UserID"]?.ToString();

            if (currentRole != "Admin" && currentUid?.ToLower() != "admin")
            {
                Response.Write("<script>alert('无权访问！');location.href='Default.aspx';</script>");
                return;
            }

            if (!IsPostBack)
            {
                // 设置初始默认统计时间段（默认查询最近30天数据）
                txtStartDate.Text = DateTime.Now.AddDays(-30).ToString("yyyy-MM-dd");
                txtEndDate.Text = DateTime.Now.ToString("yyyy-MM-dd");

                BindAdminData();
                BindEngagementStats(); // 加载参与度与饼状图数据
            }
        }

        private void BindAdminData()
        {
            // 加载后台列表时按置顶优先，再按发布时间降序
            gvProducts.DataSource = DBHelper.GetDataTable("SELECT * FROM Products ORDER BY ISNULL(IsTop, 0) DESC, PublishDate DESC");
            gvProducts.DataBind();

            gvUsers.DataSource = DBHelper.GetDataTable("SELECT * FROM Users WHERE UserID <> 'admin' ORDER BY UserID");
            gvUsers.DataBind();
        }

        // 🎯 核心精准修正：已将字段名修正为你的真实字段 CreateDate
        private void BindEngagementStats()
        {
            string start = txtStartDate.Text.Trim();
            string end = txtEndDate.Text.Trim();

            if (string.IsNullOrEmpty(start)) start = "1900-01-01";
            if (string.IsNullOrEmpty(end)) end = DateTime.Now.ToString("yyyy-MM-dd");

            string startTime = start + " 00:00:00";
            string endTime = end + " 23:59:59";

            // ⚙️ 适配调整：这里成功将原先的 CommentDate 更改为了真正的 CreateDate
            string statsSql = $@"
                SELECT 
                    u.UserID, 
                    u.UserName,
                    ISNULL(p.PCount, 0) AS PostCount,
                    ISNULL(c.CCount, 0) AS ReplyCount,
                    (ISNULL(p.PCount, 0) + ISNULL(c.CCount, 0)) AS ActivityScore
                FROM Users u
                LEFT JOIN (
                    SELECT SellerID, COUNT(1) AS PCount 
                    FROM Products 
                    WHERE PublishDate BETWEEN '{startTime}' AND '{endTime}'
                    GROUP BY SellerID
                ) p ON u.UserID = p.SellerID
                LEFT JOIN (
                    SELECT UserID, COUNT(1) AS CCount 
                    FROM Comments 
                    WHERE CreateDate BETWEEN '{startTime}' AND '{endTime}'
                    GROUP BY UserID
                ) c ON u.UserID = c.UserID
                WHERE u.UserID <> 'admin'
                ORDER BY ActivityScore DESC, u.UserID ASC";

            try
            {
                DataTable dt = DBHelper.GetDataTable(statsSql);
                int totalPosts = 0;
                int totalReplies = 0;

                if (dt != null && dt.Rows.Count > 0)
                {
                    foreach (DataRow row in dt.Rows)
                    {
                        totalPosts += Convert.ToInt32(row["PostCount"]);
                        totalReplies += Convert.ToInt32(row["ReplyCount"]);
                    }

                    gvUserStats.DataSource = dt;
                    gvUserStats.DataBind();
                    gvUserStats.Visible = true;
                    pnlNoStats.Visible = false;
                }
                else
                {
                    gvUserStats.Visible = false;
                    pnlNoStats.Visible = true;
                }

                // 正常渲染 ECharts
                RenderPieChart(totalPosts, totalReplies);
            }
            catch (Exception ex)
            {
                Response.Write("<script>console.error('活跃度统计加载失败，请检查Comments表字段：" + ex.Message.Replace("'", "\"") + "');</script>");
            }
        }

        private void RenderPieChart(int posts, int replies)
        {
            int displayPosts = (posts == 0 && replies == 0) ? 0 : posts;
            int displayReplies = (posts == 0 && replies == 0) ? 0 : replies;

            string script = $@"
            <script type='text/javascript'>
                document.addEventListener('DOMContentLoaded', function () {{
                    var chartDom = document.getElementById('pieChartContainer');
                    if(chartDom) {{
                        var myChart = echarts.init(chartDom);
                        var option = {{
                            title: {{
                                text: '互动参与度占比',
                                subtext: '发帖与评论比例 (当前时段总计: {posts + replies} 条)',
                                left: 'center',
                                textStyle: {{ color: '#333', fontSize: 16 }}
                            }},
                            tooltip: {{
                                trigger: 'item',
                                formatter: '{{b}} : {{c}} 个 ({{d}}%)'
                            }},
                            legend: {{
                                bottom: '5%',
                                left: 'center'
                            }},
                            color: ['#2ecc71', '#e67e22'],
                            series: [
                                {{
                                    name: '参与类型',
                                    type: 'pie',
                                    radius: '55%',
                                    center: ['50%', '45%'],
                                    data: [
                                        {{ value: {displayPosts}, name: '📝 发帖总量' }},
                                        {{ value: {displayReplies}, name: '💬 评论总量' }}
                                    ],
                                    emphasis: {{
                                        itemStyle: {{
                                            shadowBlur: 10,
                                            shadowOffsetX: 0,
                                            shadowColor: 'rgba(0, 0, 0, 0.5)'
                                        }}
                                    }}
                                }}
                            ]
                        }};
                        myChart.setOption(option);
                        window.addEventListener('resize', function() {{ myChart.resize(); }});
                    }}
                }});
            </script>";

            litChartScript.Text = script;
        }

        protected void BtnFilterStats_Click(object sender, EventArgs e)
        {
            BindEngagementStats();
        }

        protected void btnOffline_Click(object sender, EventArgs e)
        {
        }

        protected void gvProducts_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            string pid = e.CommandArgument?.ToString();
            if (string.IsNullOrEmpty(pid)) return;

            if (e.CommandName == "SetProductTop")
            {
                DBHelper.ExecuteNonQuery($"UPDATE Products SET IsTop = 1 WHERE ProductID = {pid}");
                ClientScript.RegisterStartupScript(this.GetType(), "msg", "alert('该帖子已被成功置顶，将在学生端社区广场顶端高亮显示！');", true);
            }
            else if (e.CommandName == "CancelProductTop")
            {
                DBHelper.ExecuteNonQuery($"UPDATE Products SET IsTop = 0 WHERE ProductID = {pid}");
                ClientScript.RegisterStartupScript(this.GetType(), "msg", "alert('已取消该帖子的置顶状态！');", true);
            }
            else if (e.CommandName == "VerifyTrue")
            {
                DBHelper.ExecuteNonQuery($"UPDATE Products SET Status = 0 WHERE ProductID = {pid}");

                DataTable dt = DBHelper.GetDataTable($"SELECT ReportedUserID, ProductName, SellerID FROM Products WHERE ProductID = {pid}");
                if (dt != null && dt.Rows.Count > 0)
                {
                    string reportedUser = dt.Rows[0]["ReportedUserID"]?.ToString().Trim();
                    string sellerId = dt.Rows[0]["SellerID"]?.ToString().Trim().Replace("'", "''");

                    if (!string.IsNullOrEmpty(reportedUser))
                    {
                        string safeReportedUser = reportedUser.Replace("'", "''");
                        DBHelper.ExecuteNonQuery($"UPDATE Users SET CreditScore = CreditScore - 20 WHERE UserID = '{safeReportedUser}'");

                        DataTable dtNewScore = DBHelper.GetDataTable($"SELECT UserName, CreditScore FROM Users WHERE UserID = '{safeReportedUser}'");
                        if (dtNewScore != null && dtNewScore.Rows.Count > 0)
                        {
                            string uName = dtNewScore.Rows[0]["UserName"]?.ToString().Replace("'", "''");
                            int newScore = Convert.ToInt32(dtNewScore.Rows[0]["CreditScore"]);

                            string sqlCheck = $"SELECT COUNT(1) FROM UserReputation WHERE UserID = '{safeReportedUser}'";
                            int exists = Convert.ToInt32(DBHelper.GetDataTable(sqlCheck).Rows[0][0]);

                            if (exists > 0)
                            {
                                DBHelper.ExecuteNonQuery($"UPDATE UserReputation SET CurrentCreditScore = {newScore}, LastUpdateTime = GETDATE() WHERE UserID = '{safeReportedUser}'");
                            }
                            else
                            {
                                DBHelper.ExecuteNonQuery($"INSERT INTO UserReputation (UserID, UserName, CurrentCreditScore, LastUpdateTime) VALUES ('{safeReportedUser}', '{uName}', {newScore}, GETDATE())");
                            }
                        }
                    }

                    string sqlUpdateReportTrue = string.Format(
                        "UPDATE Reports SET ReportStatus = 1 WHERE ReporterID = '{0}' AND Reason LIKE '%[避雷贴同步]%'",
                        sellerId
                    );
                    DBHelper.ExecuteNonQuery(sqlUpdateReportTrue);
                }

                ClientScript.RegisterStartupScript(this.GetType(), "msg", "alert('判定成功：情况属实！该贴已通过审核，被举报人信誉分已扣除，实时信誉分表已同步更新！');", true);
            }
            else if (e.CommandName == "VerifyFalse")
            {
                DataTable dt = DBHelper.GetDataTable($"SELECT SellerID, ReportedUserID, ProductName FROM Products WHERE ProductID = {pid}");
                if (dt != null && dt.Rows.Count > 0)
                {
                    string maliciousUser = dt.Rows[0]["SellerID"]?.ToString().Trim();
                    if (!string.IsNullOrEmpty(maliciousUser))
                    {
                        string safeMaliciousUser = maliciousUser.Replace("'", "''");
                        DBHelper.ExecuteNonQuery($"UPDATE Users SET CreditScore = CreditScore - 10 WHERE UserID = '{safeMaliciousUser}'");

                        DataTable dtNewScore = DBHelper.GetDataTable($"SELECT UserName, CreditScore FROM Users WHERE UserID = '{safeMaliciousUser}'");
                        if (dtNewScore != null && dtNewScore.Rows.Count > 0)
                        {
                            string uName = dtNewScore.Rows[0]["UserName"]?.ToString().Replace("'", "''");
                            int newScore = Convert.ToInt32(dtNewScore.Rows[0]["CreditScore"]);

                            string sqlCheck = $"SELECT COUNT(1) FROM UserReputation WHERE UserID = '{safeMaliciousUser}'";
                            int exists = Convert.ToInt32(DBHelper.GetDataTable(sqlCheck).Rows[0][0]);

                            if (exists > 0)
                            {
                                DBHelper.ExecuteNonQuery($"UPDATE UserReputation SET CurrentCreditScore = {newScore}, LastUpdateTime = GETDATE() WHERE UserID = '{safeMaliciousUser}'");
                            }
                            else
                            {
                                DBHelper.ExecuteNonQuery($"INSERT INTO UserReputation (UserID, UserName, CurrentCreditScore, LastUpdateTime) VALUES ('{safeMaliciousUser}', '{uName}', {newScore}, GETDATE())");
                            }
                        }
                    }

                    string sqlUpdateReportFalse = string.Format(
                        "UPDATE Reports SET ReportStatus = 2 WHERE ReporterID = '{0}' AND Reason LIKE '%[避雷贴同步]%'",
                        maliciousUser.Replace("'", "''")
                    );
                    DBHelper.ExecuteNonQuery(sqlUpdateReportFalse);
                }

                DBHelper.ExecuteNonQuery($"UPDATE Products SET Status = 2, IsTop = 0 WHERE ProductID = {pid}");
                ClientScript.RegisterStartupScript(this.GetType(), "msg", "alert('判定成功：此贴属恶意造谣！帖子已强行下架，发帖人实时信誉分已同步扣除更新。');", true);
            }
            else if (e.CommandName == "ForceOffline")
            {
                DBHelper.ExecuteNonQuery($"UPDATE Products SET Status = 2, IsTop = 0 WHERE ProductID = {pid}");
                ClientScript.RegisterStartupScript(this.GetType(), "msg", "alert('该帖子已被管理员手动强行下架！');", true);
            }

            BindAdminData();
            BindEngagementStats();
        }


        protected void gvUsers_RowCommand(object sender, GridViewCommandEventArgs e)
        {

            string uid = e.CommandArgument.ToString();

            if (e.CommandName == "BanUser")
            {
                DBHelper.ExecuteNonQuery($"UPDATE Users SET UserStatus='被封禁' WHERE UserID='{uid}'");
            }
            else if (e.CommandName == "UnbanUser")
            {
                DBHelper.ExecuteNonQuery($"UPDATE Users SET UserStatus='正常' WHERE UserID='{uid}'");
            }
            else if (e.CommandName == "DeleteUser")
            {
                DBHelper.ExecuteNonQuery($"DELETE FROM Products WHERE SellerID='{uid}'");
                DBHelper.ExecuteNonQuery($"DELETE FROM Users WHERE UserID='{uid}'");
                DBHelper.ExecuteNonQuery($"DELETE FROM UserReputation WHERE UserID='{uid}'");
                ClientScript.RegisterStartupScript(this.GetType(), "msg", "alert('该账号已从系统中永久注销！');", true);
            }

            BindAdminData();
            BindEngagementStats();
        }
    }
}
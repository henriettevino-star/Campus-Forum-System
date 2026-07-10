using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;
using System.IO;
using _0506_1.App_Code;

namespace _0506_1
{
    public partial class PostProduct : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                if (Session["UserID"] == null)
                {
                    Response.Redirect("Login.aspx");
                    return;
                }
                LoadCategories();
            }
        }

        private void LoadCategories()
        {
            string sql = "SELECT * FROM Categories";
            DataTable dt = DBHelper.GetDataTable(sql);
            ddlCategory.DataSource = dt;
            ddlCategory.DataTextField = "CategoryName";
            ddlCategory.DataValueField = "CategoryID";
            ddlCategory.DataBind();
            ddlCategory.Items.Insert(0, new ListItem("--请选择分类--", "0"));
        }

        protected void btnPost_Click(object sender, EventArgs e)
        {
            // 基础变量获取
            string type = ddlPostType.SelectedValue; // 0:出售, 1:求购, 2:避雷, 3:失物招领, 4:找同学帮忙
            string title = txtTitle.Text.Trim();
            string priceStr = txtPrice.Text.Trim();
            string desc = txtDesc.Text.Trim();
            string cid = ddlCategory.SelectedValue;
            string sellerId = Session["UserID"].ToString();

            string reportedID = "";
            if (type == "2")
            {
                foreach (string key in Request.Form.AllKeys)
                {
                    if (key != null && key.Contains("txtTargetID"))
                    {
                        reportedID = Request.Form[key].Trim();
                        break;
                    }
                }
            }

            // 1. 标题校验
            if (string.IsNullOrEmpty(title))
            {
                lblMsg.Text = "标题/主题不能为空！";
                return;
            }

            // 2. 价格与分类逻辑
            decimal price = 0;
            // 将找同学帮忙(4) 与 避雷(2)、失物招领(3) 一起纳入免去价格与分类校验的逻辑中
            if (type == "2" || type == "3" || type == "4")
            {
                price = 0;
                // 如果分类是0，给帖子分配一个默认分类（防止数据库NULL约束报错）
                if (cid == "0" || string.IsNullOrEmpty(cid))
                {
                    if (ddlCategory.Items.Count > 1) cid = ddlCategory.Items[1].Value;
                }
            }
            else // 出售或求购
            {
                if (cid == "0") { lblMsg.Text = "请选择分类！"; return; }
                if (!decimal.TryParse(priceStr, out price)) { lblMsg.Text = "价格请输入纯数字！"; return; }
            }

            // 3. 多图片处理逻辑
            string dbFileName = ""; // 用于拼接最终存入数据库的所有图片名称
            if (fileUpload.HasFile)
            {
                try
                {
                    string uploadFolderPath = Server.MapPath("~/Uploads/");
                    if (!Directory.Exists(uploadFolderPath))
                    {
                        Directory.CreateDirectory(uploadFolderPath);
                    }

                    List<string> savedFileNames = new List<string>();

                    // 循环遍历用户选择的所有文件
                    foreach (HttpPostedFile uploadedFile in fileUpload.PostedFiles)
                    {
                        if (uploadedFile.ContentLength > 0)
                        {
                            string ext = Path.GetExtension(uploadedFile.FileName).ToLower();
                            // 为每一张图片生成独立的唯一文件名
                            string singleFileName = DateTime.Now.ToString("yyyyMMddHHmmssfff") + "_" + Guid.NewGuid().ToString().Substring(0, 5) + ext;

                            string fullSavePath = Path.Combine(uploadFolderPath, singleFileName);
                            uploadedFile.SaveAs(fullSavePath);

                            // 将成功保存的文件名加入队列
                            savedFileNames.Add(singleFileName);
                        }
                    }

                    // 将多张图片的文件名用英文逗号拼接
                    if (savedFileNames.Count > 0)
                    {
                        dbFileName = string.Join(",", savedFileNames);
                    }
                }
                catch (Exception ex)
                {
                    lblMsg.Text = "图片物理保存失败：" + ex.Message;
                    return;
                }
            }

            // 如果是避雷贴(2) 则赋予初始状态码 '3'（待审核），否则一律保持默认的 '0'（直接展示）
            string initialStatus = (type == "2") ? "3" : "0";

            // 数据库插入严格校对并锁定字段与 Value 参数的硬核映射顺序，杜绝数据错位
            string sql = string.Format(
                "INSERT INTO Products (ProductName, Price, Description, CategoryID, SellerID, Status, ImageUrl, PostType, PublishDate, ReportedUserID) " +
                "VALUES ('{0}', {1}, '{2}', {3}, '{4}', '{5}', '{6}', '{7}', GETDATE(), '{8}')",
                title.Replace("'", "''"),               // {0} -> ProductName
                price.ToString("F2"),                    // {1} -> Price
                desc.Replace("'", "''"),                 // {2} -> Description
                cid,                                     // {3} -> CategoryID
                sellerId,                               // {4} -> SellerID
                initialStatus,                           // {5} -> Status 
                dbFileName.Replace("'", "''"),          // {6} -> ImageUrl
                type,                                   // {7} -> PostType
                reportedID.Replace("'", "''")           // {8} -> ReportedUserID
            );

            try
            {
                int result = DBHelper.ExecuteNonQuery(sql);
                if (result > 0)
                {
                    // 如果发布的是“避雷贴”，强行向 Reports 用户举报表双写同步一条数据
                    if (type == "2")
                    {
                        // 如果未填写被举报人ID，提供默认值防止数据库报错
                        string targetUser = string.IsNullOrEmpty(reportedID) ? "未提供特定账号" : reportedID;

                        // 整合标题和具体描述作为举报原因
                        string reportReason = ("[避雷贴同步] " + title + "。" + desc).Replace("'", "''");

                        string sqlReport = string.Format(
                            "INSERT INTO Reports (ReporterID, TargetUserID, Reason, EvidencePath, ReportStatus, ReportDate) " +
                            "VALUES ('{0}', '{1}', '{2}', '{3}', 0, GETDATE())",
                            sellerId.Replace("'", "''"),
                            targetUser.Replace("'", "''"),
                            reportReason,
                            dbFileName.Replace("'", "''")
                        );

                        // 执行写入，让 Reports 表彻底充实起来
                        DBHelper.ExecuteNonQuery(sqlReport);
                    }

                    // 动态控制 找同学帮忙(4) 的专属跳转逻辑和提示语
                    string targetPage = "Default.aspx";
                    string alertMsg = "发布成功！";

                    if (type == "2")
                    {
                        targetPage = "Community.aspx";
                        alertMsg = "避雷曝光信息已发布，并已同步提交管理员进行违规审查！";
                    }
                    else if (type == "3")
                    {
                        targetPage = "LostFound.aspx";
                        alertMsg = "失物招领信息发布成功！";
                    }
                    else if (type == "4")
                    {
                        targetPage = "Community.aspx";
                        alertMsg = "求助信息发布成功！";

                    }

                    Response.Write($"<script>alert('{alertMsg}');window.location.href='{targetPage}';</script>");
                    Response.End();
                }
                else
                {
                    lblMsg.Text = "发布失败，请检查数据库。";
                }
            }
            catch (Exception ex)
            {
                lblMsg.Text = "数据库错误：" + ex.Message;
            }
        }
    }
}
using System;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;

namespace _0506_1.App_Code
{
    public class DBHelper
    {
        // 1. 获取 Web.config 中的连接字符串
        private static string connStr = ConfigurationManager.ConnectionStrings["ConnStr"].ConnectionString;

        // 2. 执行【增、删、改】的方法
        // 返回受影响的行数（int）
        public static int ExecuteNonQuery(string sql)
        {
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();
                SqlCommand cmd = new SqlCommand(sql, conn);
                return cmd.ExecuteNonQuery();
            }
        }

        // 3. 执行【查询】的方法
        // 返回一个结果表（DataTable）
        public static DataTable GetDataTable(string sql)
        {
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                SqlDataAdapter da = new SqlDataAdapter(sql, conn);
                DataTable dt = new DataTable();
                da.Fill(dt);
                return dt;
            }
        }
    }
}
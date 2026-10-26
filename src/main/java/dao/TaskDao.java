/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dao;
import model.Task;
import util.DBConnect;
import java.sql.*;
import java.util.*;
/**
 *
 * @author mai09
 */
public class TaskDao {
    // Tìm kiếm đa điều kiện: theo tên nhân viên, tên dự án, hoặc trạng thái
    public List<Task> searchTasks(String empName, String projectName, String status) {
        List<Task> list = new ArrayList<>();
        
        StringBuilder sql = new StringBuilder(
            "SELECT t.id, t.taskName, t.description, t.deadline, t.priority, t.status, " +
            "       p.projectName, " +
            "       ISNULL(e.name, N'') AS emp_name " +
            "FROM Task t " +
            "INNER JOIN Project p ON t.project_id = p.id " +
            "LEFT JOIN Assignment a ON t.id = a.task_id " +
            "LEFT JOIN Employee e ON a.employee_id = e.id " +
            "WHERE 1=1 "
        );

        List<Object> params = new ArrayList<>();

        if (empName != null && !empName.trim().isEmpty()) {
            sql.append("AND e.name LIKE ? ");
            params.add("%" + empName.trim() + "%");
        }
        if (projectName != null && !projectName.trim().isEmpty()) {
            sql.append("AND p.projectName LIKE ? ");
            params.add("%" + projectName.trim() + "%");
        }
        if (status != null && !status.trim().isEmpty()) {
            sql.append("AND t.status = ? ");
            params.add(status.trim());
        }

        sql.append("ORDER BY t.id DESC");

        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {

            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Task t = new Task();
                    t.setId(rs.getInt("id"));
                    t.setTaskName(rs.getNString("taskName"));
                    t.setDescription(rs.getNString("description"));
                    t.setDeadline(rs.getDate("deadline"));
                    t.setPriority(rs.getNString("priority"));
                    t.setStatus(rs.getNString("status"));
                    t.setProjectName(rs.getNString("projectName"));
                    
                    // Lấy tên nhân viên dạng Unicode an toàn
                    String emp = rs.getNString("emp_name");
                    if (emp == null || emp.trim().isEmpty()) {
                        emp = rs.getString("emp_name");
                    }
                    
                    // Gán đồng thời vào cả hai trường để JSP đọc đường nào cũng có dữ liệu
                    t.setEmployeeName(emp);
                    t.setAssignedEmployee(emp);

                    list.add(t);
                }
            }
        } catch (Exception e) {
            System.err.println("Lỗi tại searchTasks: " + e.getMessage());
            e.printStackTrace();
        }
        return list;
    }

    // Thống kê: Hoàn thành / Đang làm / Quá hạn (Cú pháp chuẩn SQL Server)
    public Map<String, Integer> getStatistics() {
        Map<String, Integer> stats = new HashMap<>();
        String sql = "SELECT " +
                     "SUM(CASE WHEN status = N'Hoàn thành' THEN 1 ELSE 0 END) AS completed, " +
                     "SUM(CASE WHEN status = N'Đang thực hiện' THEN 1 ELSE 0 END) AS inProgress, " +
                     "SUM(CASE WHEN deadline < CAST(GETDATE() AS DATE) AND status != N'Hoàn thành' THEN 1 ELSE 0 END) AS overdue " +
                     "FROM Task";
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                stats.put("completed", rs.getInt("completed"));
                stats.put("inProgress", rs.getInt("inProgress"));
                stats.put("overdue", rs.getInt("overdue"));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return stats;
    }

    public boolean insert(Task task) {
        String sql = "INSERT INTO Task (taskName, description, deadline, status, priority, project_id) VALUES (?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setNString(1, task.getTaskName());
            ps.setNString(2, task.getDescription());
            ps.setDate(3, task.getDeadline());
            ps.setNString(4, task.getStatus());
            ps.setNString(5, task.getPriority());
            ps.setInt(6, task.getProjectId());
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public int countByStatus(String status) {
        int count = 0;
        String sql = "SELECT COUNT(*) FROM Task WHERE status = ?";
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setNString(1, status);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    count = rs.getInt(1);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return count;
    }

    // Đếm công việc quá hạn
    public int countOverdue() {
        int count = 0;
        String sql = "SELECT COUNT(*) FROM Task WHERE deadline < CAST(GETDATE() AS DATE) AND status != N'Hoàn thành'";
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                count = rs.getInt(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return count;
    }

    /** Open tasks only: completed tasks stay in SQL for audit/history but disappear from active management. */
    /** Open tasks only; optional search spans task name, project, description and status. */
    public List<Task> getOpenTasks() { return getOpenTasks(null); }

    public List<Task> getOpenTasks(String keyword) {
        List<Task> list = new ArrayList<>();
        boolean filtered = keyword != null && !keyword.trim().isEmpty();
        String sql = "SELECT t.*, p.projectName, a.employee_id AS assignedEmployeeId, e.name AS assignedEmployeeName " +
                     "FROM Task t JOIN Project p ON t.project_id = p.id " +
                     "LEFT JOIN Assignment a ON a.task_id = t.id " +
                     "LEFT JOIN Employee e ON e.id = a.employee_id " +
                     "WHERE LTRIM(RTRIM(ISNULL(t.status, N''))) NOT IN (N'Hoàn thành', N'Hoan thanh') " +
                     "AND ISNULL(p.isArchived, 0) = 0 " +
                     (filtered ? "AND (t.taskName LIKE ? OR t.description LIKE ? OR p.projectName LIKE ? OR t.status LIKE ? OR t.priority LIKE ?) " : "") +
                     "ORDER BY t.id DESC";
        try (Connection conn = DBConnect.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            if (filtered) {
                String pattern = "%" + keyword.trim() + "%";
                for (int i = 1; i <= 5; i++) ps.setNString(i, pattern);
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Task t = new Task();
                    t.setId(rs.getInt("id")); t.setTaskName(rs.getNString("taskName"));
                    t.setProjectId(rs.getInt("project_id")); t.setProjectName(rs.getNString("projectName"));
                    t.setDeadline(rs.getDate("deadline")); t.setPriority(rs.getNString("priority"));
                    t.setStatus(rs.getNString("status")); t.setDescription(rs.getNString("description"));
                    int assignedEmployeeId = rs.getInt("assignedEmployeeId");
                    if (rs.wasNull()) assignedEmployeeId = 0;
                    t.setEmployeeId(assignedEmployeeId);
                    String assignedEmployeeName = rs.getNString("assignedEmployeeName");
                    t.setEmployeeName(assignedEmployeeName == null || assignedEmployeeName.trim().isEmpty()
                            ? "Chưa phân công" : assignedEmployeeName);
                    list.add(t);
                }
            }
        } catch (Exception e) { System.err.println("Lỗi lấy công việc đang mở: "+e.getMessage()); e.printStackTrace(); }
        return list;
    }

    public List<Task> getAssignableTasks() { return getOpenTasks(); }

    public List<Task> getAll() {
        List<Task> list = new ArrayList<>();
        String sql = "SELECT t.*, p.projectName FROM Task t JOIN Project p ON t.project_id = p.id";
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Task t = new Task();
                t.setId(rs.getInt("id"));
                t.setTaskName(rs.getNString("taskName"));
                t.setProjectId(rs.getInt("project_id"));
                t.setProjectName(rs.getNString("projectName"));
                t.setDeadline(rs.getDate("deadline"));
                t.setPriority(rs.getNString("priority"));
                t.setStatus(rs.getNString("status"));
                t.setDescription(rs.getNString("description"));
                list.add(t);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public Task getById(int id) {
        String sql = "SELECT * FROM Task WHERE id = ?";
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Task t = new Task();
                    t.setId(rs.getInt("id"));
                    t.setTaskName(rs.getNString("taskName"));
                    t.setProjectId(rs.getInt("project_id"));
                    t.setDeadline(rs.getDate("deadline"));
                    t.setPriority(rs.getNString("priority"));
                    t.setStatus(rs.getNString("status"));
                    t.setDescription(rs.getNString("description"));
                    return t;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public boolean update(Task task) {
        String sql = "UPDATE Task SET taskName = ?, project_id = ?, deadline = ?, priority = ?, status = ?, description = ? WHERE id = ?";
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setNString(1, task.getTaskName());
            ps.setInt(2, task.getProjectId());
            ps.setDate(3, task.getDeadline());
            ps.setNString(4, task.getPriority());
            ps.setNString(5, task.getStatus());
            ps.setNString(6, task.getDescription());
            ps.setInt(7, task.getId());
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }
    // Xóa công việc theo ID
    public boolean delete(int id) {
        String sql = "DELETE FROM Task WHERE id = ?";
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }
    // Lấy danh sách công việc kèm người phụ trách theo ID dự án
    public List<Task> getTasksByProjectId(int projectId) {
        List<Task> list = new ArrayList<>();
        String sql = "SELECT t.id, t.taskName, t.deadline, t.priority, t.status, " +
                     "       ISNULL(e.name, N'Chưa phân công') AS employeeName " +
                     "FROM Task t " +
                     "LEFT JOIN Assignment a ON t.id = a.task_id " +
                     "LEFT JOIN Employee e ON a.employee_id = e.id " +
                     "WHERE t.project_id = ? " +
                     "ORDER BY t.id DESC";
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, projectId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Task t = new Task();
                    t.setId(rs.getInt("id"));
                    t.setTaskName(rs.getNString("taskName"));
                    t.setDeadline(rs.getDate("deadline"));
                    t.setPriority(rs.getNString("priority"));
                    t.setStatus(rs.getNString("status"));
                    t.setEmployeeName(rs.getNString("employeeName"));
                    list.add(t);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }


    /** Ensures the attendance log exists even when the SQL migration was not run manually. */
    public boolean ensureAttendanceTableExists() {
        String sql = "IF OBJECT_ID(N'dbo.AttendanceLog', N'U') IS NULL BEGIN " +
                     "CREATE TABLE dbo.AttendanceLog (" +
                     "id INT IDENTITY(1,1) PRIMARY KEY, " +
                     "task_id INT NOT NULL, employee_id INT NOT NULL, " +
                     "checked_at DATETIME2(0) NOT NULL CONSTRAINT DF_AttendanceLog_checked_at DEFAULT SYSDATETIME(), " +
                     "CONSTRAINT UQ_AttendanceLog_task_employee UNIQUE (task_id, employee_id), " +
                     "CONSTRAINT FK_AttendanceLog_Task FOREIGN KEY (task_id) REFERENCES dbo.Task(id) ON DELETE CASCADE, " +
                     "CONSTRAINT FK_AttendanceLog_Employee FOREIGN KEY (employee_id) REFERENCES dbo.Employee(id) ON DELETE CASCADE" +
                     "); END";
        try (Connection conn = DBConnect.getConnection(); Statement stmt = conn.createStatement()) {
            stmt.execute(sql);
            return true;
        } catch (Exception e) {
            System.err.println("Không thể khởi tạo AttendanceLog: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
    /**
     * Lấy các công việc được giao cho nhân viên đăng nhập.
     * Schema hiện tại chưa có khóa ngoại nối Account với Employee,
     * nên đối chiếu fullname của tài khoản với tên nhân viên.
     */
    public List<Map<String, Object>> getTasksForEmployee(String employeeName) {
        List<Map<String, Object>> list = new ArrayList<>();
        if (!ensureAttendanceTableExists()) {
            return list;
        }
        String sql = "SELECT t.id, t.taskName, t.description, t.deadline, t.status, " +
                     "t.priority, p.projectName, a.assigned_date, al.checked_at " +
                     "FROM Assignment a " +
                     "JOIN Employee e ON e.id = a.employee_id " +
                     "JOIN Task t ON t.id = a.task_id " +
                     "JOIN Project p ON p.id = t.project_id " +
                     "LEFT JOIN AttendanceLog al ON al.task_id = t.id AND al.employee_id = e.id " +
                     "WHERE LTRIM(RTRIM(e.name)) = LTRIM(RTRIM(?)) " +
                     "ORDER BY CASE WHEN t.status = N'Hoàn thành' THEN 1 ELSE 0 END, t.deadline";
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setNString(1, employeeName);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> row = new HashMap<>();
                    row.put("id", rs.getInt("id"));
                    row.put("taskName", rs.getNString("taskName"));
                    row.put("description", rs.getNString("description"));
                    row.put("deadline", rs.getDate("deadline"));
                    row.put("status", rs.getNString("status"));
                    row.put("priority", rs.getNString("priority"));
                    row.put("projectName", rs.getNString("projectName"));
                    row.put("assignedDate", rs.getDate("assigned_date"));
                    row.put("checkedAt", rs.getTimestamp("checked_at"));
                    list.add(row);
                }
            }
        } catch (Exception e) {
            System.err.println("Lỗi lấy danh sách chấm công: " + e.getMessage());
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Chỉ hoàn thành công việc được giao cho nhân viên hiện tại.
     * Cập nhật trạng thái và lưu nhật ký trong cùng giao dịch.
     */
    public boolean completeTaskFromAttendance(int taskId, String employeeName) {
        if (!ensureAttendanceTableExists()) {
            return false;
        }
        String findSql = "SELECT t.status, e.id AS employee_id " +
                         "FROM Task t WITH (UPDLOCK, ROWLOCK) " +
                         "JOIN Assignment a ON a.task_id = t.id " +
                         "JOIN Employee e ON e.id = a.employee_id " +
                         "WHERE t.id = ? AND LTRIM(RTRIM(e.name)) = LTRIM(RTRIM(?))";
        String updateSql = "UPDATE Task SET status = N'Hoàn thành' " +
                           "WHERE id = ? AND status <> N'Hoàn thành'";
        String logSql = "INSERT INTO AttendanceLog (task_id, employee_id, checked_at) " +
                        "VALUES (?, ?, SYSDATETIME())";
        try (Connection conn = DBConnect.getConnection()) {
            conn.setAutoCommit(false);
            try {
                int employeeId;
                try (PreparedStatement ps = conn.prepareStatement(findSql)) {
                    ps.setInt(1, taskId);
                    ps.setNString(2, employeeName);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (!rs.next() || "Hoàn thành".equals(rs.getNString("status"))) {
                            conn.rollback();
                            return false;
                        }
                        employeeId = rs.getInt("employee_id");
                    }
                }
                try (PreparedStatement ps = conn.prepareStatement(updateSql)) {
                    ps.setInt(1, taskId);
                    if (ps.executeUpdate() != 1) {
                        conn.rollback();
                        return false;
                    }
                }
                try (PreparedStatement ps = conn.prepareStatement(logSql)) {
                    ps.setInt(1, taskId);
                    ps.setInt(2, employeeId);
                    ps.executeUpdate();
                }
                conn.commit();
                return true;
            } catch (Exception e) {
                conn.rollback();
                throw e;
            } finally {
                conn.setAutoCommit(true);
            }
        } catch (Exception e) {
            System.err.println("Lỗi chấm công hoàn thành công việc: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

}

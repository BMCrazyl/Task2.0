package controller;

import dao.AssignmentDao;
import dao.EmployeeDao;
import dao.ProjectDao;
import dao.TaskDao;
import model.Assignment;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.Date;

@WebServlet(name = "AssignmentServlet", urlPatterns = {"/assign"})
public class AssignmentServlet extends HttpServlet {
    private final TaskDao taskDao = new TaskDao();
    private final EmployeeDao employeeDao = new EmployeeDao();
    private final AssignmentDao assignmentDao = new AssignmentDao();
    private final ProjectDao projectDao = new ProjectDao();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        projectDao.ensureArchiveSchema();
        projectDao.archiveCompletedProjects();
        request.setAttribute("projectList", projectDao.getAll());
        request.setAttribute("taskList", taskDao.getAssignableTasks());
        request.setAttribute("employeeList", employeeDao.getAll());
        request.getRequestDispatcher("/assign.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        try {
            int taskId=Integer.parseInt(request.getParameter("taskId"));
            int projectId=Integer.parseInt(request.getParameter("projectId"));
            int employeeId=Integer.parseInt(request.getParameter("employeeId"));
            boolean validTask = taskDao.getAssignableTasks().stream()
                    .anyMatch(t -> t.getId() == taskId && t.getProjectId() == projectId);
            if (!validTask) {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Công việc không thuộc dự án đã chọn hoặc không còn khả dụng.");
                return;
            }
            String dateStr=request.getParameter("assignedDate");
            Date assignedDate=(dateStr != null && !dateStr.trim().isEmpty())
                    ? Date.valueOf(dateStr.trim()) : new Date(System.currentTimeMillis());
            Assignment a=new Assignment();
            a.setTaskId(taskId); a.setEmployeeId(employeeId); a.setAssignedDate(assignedDate);
            assignmentDao.assignTask(a);
        } catch (Exception e) { System.err.println("Lỗi phân công: "+e.getMessage()); e.printStackTrace(); }
        response.sendRedirect(request.getContextPath()+"/assign");
    }
}

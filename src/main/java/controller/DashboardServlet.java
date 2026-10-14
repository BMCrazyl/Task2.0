package controller;

import dao.TaskDao;
import dao.EmployeeDao;
import model.Employee;
import model.Account;
import model.Task;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

@WebServlet(name = "DashboardServlet", urlPatterns = {"/dashboard"})
public class DashboardServlet extends HttpServlet {
    private final TaskDao taskDao = new TaskDao();
    private final EmployeeDao employeeDao = new EmployeeDao();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(false);
        Account currentUser = session == null ? null : (Account) session.getAttribute("user");
        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        if ("EMPLOYEE".equalsIgnoreCase(currentUser.getRole())) {
            Employee currentEmployee = employeeDao.getByAccountId(currentUser.getId(), currentUser.getFullname());
            if (currentEmployee != null) {
                currentUser.setFullname(currentEmployee.getName());
                session.setAttribute("user", currentUser);
                request.setAttribute("currentEmployee", currentEmployee);
            }
        }

        String empName = request.getParameter("empName");
        String projectName = request.getParameter("projectName");
        String status = request.getParameter("status");
        if ("EMPLOYEE".equalsIgnoreCase(currentUser.getRole())) {
            empName = currentUser.getFullname();
        }

        List<Task> taskList = taskDao.searchTasks(empName, projectName, status);
        List<Task> overviewTasks = taskDao.searchTasks(empName, null, null);
        List<Task> completedDetails = new ArrayList<>();
        List<Task> inProgressDetails = new ArrayList<>();
        List<Task> overdueDetails = new ArrayList<>();
        LocalDate today = LocalDate.now();

        for (Task task : overviewTasks) {
            if ("Hoàn thành".equalsIgnoreCase(task.getStatus())) {
                completedDetails.add(task);
            } else if (task.getDeadline() != null && task.getDeadline().toLocalDate().isBefore(today)) {
                overdueDetails.add(task);
            } else if ("Đang thực hiện".equalsIgnoreCase(task.getStatus())) {
                inProgressDetails.add(task);
            }
        }

        request.setAttribute("taskList", taskList);
        request.setAttribute("completedDetails", completedDetails);
        request.setAttribute("inProgressDetails", inProgressDetails);
        request.setAttribute("overdueDetails", overdueDetails);
        request.setAttribute("completedCount", completedDetails.size());
        request.setAttribute("inProgressCount", inProgressDetails.size());
        request.setAttribute("overdueTasks", overdueDetails.size());
        request.getRequestDispatcher("/dashboard.jsp").forward(request, response);
    }
}

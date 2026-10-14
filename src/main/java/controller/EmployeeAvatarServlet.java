package controller;

import dao.EmployeeDao;
import model.Account;
import model.Employee;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.Set;

@WebServlet(name = "EmployeeAvatarServlet", urlPatterns = {"/employee-avatar"})
public class EmployeeAvatarServlet extends HttpServlet {
    private final EmployeeDao employeeDao = new EmployeeDao();
    private static final Set<String> ALLOWED_TYPES = Set.of("image/jpeg", "image/png", "image/gif");

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
        HttpSession session = request.getSession(false);
        Account user = session == null ? null : (Account) session.getAttribute("user");
        if (user == null) {
            response.sendError(HttpServletResponse.SC_UNAUTHORIZED);
            return;
        }

        Employee employee;
        String idParam = request.getParameter("id");
        if ("ADMIN".equalsIgnoreCase(user.getRole())) {
            if (idParam == null) {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Thiếu mã nhân viên.");
                return;
            }
            try {
                employee = employeeDao.getById(Integer.parseInt(idParam));
            } catch (NumberFormatException e) {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Mã nhân viên không hợp lệ.");
                return;
            }
        } else if ("EMPLOYEE".equalsIgnoreCase(user.getRole())) {
            employee = employeeDao.getByAccountId(user.getId(), user.getFullname());
            if (employee != null && idParam != null) {
                try {
                    if (employee.getId() != Integer.parseInt(idParam)) {
                        response.sendError(HttpServletResponse.SC_FORBIDDEN);
                        return;
                    }
                } catch (NumberFormatException e) {
                    response.sendError(HttpServletResponse.SC_BAD_REQUEST);
                    return;
                }
            }
        } else {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        if (employee != null && "EMPLOYEE".equalsIgnoreCase(user.getRole())) {
            // Load binary image only for the image response, not during profile/dashboard lookups.
            employee = employeeDao.getById(employee.getId());
        }
        if (employee == null || employee.getAvatarData() == null || employee.getAvatarData().length == 0
                || !ALLOWED_TYPES.contains(employee.getAvatarContentType())) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }
        response.setContentType(employee.getAvatarContentType());
        response.setHeader("X-Content-Type-Options", "nosniff");
        response.setHeader("Cache-Control", "private, no-store, max-age=0");
        response.setContentLength(employee.getAvatarData().length);
        response.getOutputStream().write(employee.getAvatarData());
    }
}

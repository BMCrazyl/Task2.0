package controller;

import dao.EmployeeDao;
import model.Account;
import model.Employee;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.Date;

@WebServlet(name = "EmployeeServlet", urlPatterns = {"/employees"})
public class EmployeeServlet extends HttpServlet {
    private final EmployeeDao employeeDao = new EmployeeDao();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        if (!requireAdmin(request, response)) return;
        if (!employeeDao.ensureProfileSchema()) {
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Không khởi tạo được dữ liệu hồ sơ nhân viên.");
            return;
        }

        String action = request.getParameter("action");
        String idParam = request.getParameter("id");
        String keyword = request.getParameter("keyword");
        try {
            if (("edit".equals(action) || "detail".equals(action)) && idParam != null && !idParam.trim().isEmpty()) {
                Employee selected = employeeDao.getByIdSummary(Integer.parseInt(idParam));
                if (selected == null) {
                    response.sendError(HttpServletResponse.SC_NOT_FOUND, "Không tìm thấy nhân viên.");
                    return;
                }
                if ("edit".equals(action)) request.setAttribute("employee", selected);
                else {
                    request.setAttribute("employeeDetail", selected);
                    request.setAttribute("showDetailModal", true);
                }
            } else if ("delete".equals(action) && idParam != null && !idParam.trim().isEmpty()) {
                employeeDao.delete(Integer.parseInt(idParam));
                response.sendRedirect(request.getContextPath() + "/employees");
                return;
            }
        } catch (NumberFormatException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Mã nhân viên không hợp lệ.");
            return;
        }

        request.setAttribute("searchKeyword", keyword == null ? "" : keyword);
        request.setAttribute("employeeList", employeeDao.searchEmployees(keyword));
        request.getRequestDispatcher("/employee-list.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        if (!requireAdmin(request, response)) return;
        if (!employeeDao.ensureProfileSchema()) {
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Không khởi tạo được dữ liệu hồ sơ nhân viên.");
            return;
        }

        String idStr = request.getParameter("id");
        String familyName = trim(request.getParameter("familyName"));
        String givenName = trim(request.getParameter("givenName"));
        String email = trim(request.getParameter("email"));
        String phone = trim(request.getParameter("phone"));
        String position = trim(request.getParameter("position"));

        // Compatibility with any older form that still submits a single full-name field.
        String legacyName = trim(request.getParameter("name"));
        if (familyName.isEmpty() && givenName.isEmpty() && !legacyName.isEmpty()) {
            int lastSpace = legacyName.lastIndexOf(' ');
            if (lastSpace > 0) {
                familyName = legacyName.substring(0, lastSpace).trim();
                givenName = legacyName.substring(lastSpace + 1).trim();
            } else {
                familyName = legacyName;
                givenName = "";
            }
        }

        if (familyName.isEmpty() || givenName.isEmpty() || email.isEmpty() || position.isEmpty()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Họ, tên, email và chức vụ là các trường bắt buộc.");
            return;
        }

        Employee employee = new Employee();
        employee.setFamilyName(familyName);
        employee.setGivenName(givenName);
        employee.setEmail(email);
        employee.setPhone(phone);
        employee.setPosition(position);
        employee.setDateOfBirth(parseDate(request.getParameter("dateOfBirth")));
        employee.setIdentityNumber(trim(request.getParameter("identityNumber")));
        employee.setRegion(trim(request.getParameter("region")));
        employee.setPermanentAddress(trim(request.getParameter("permanentAddress")));
        employee.setBankName(trim(request.getParameter("bankName")));
        employee.setBankAccountNumber(trim(request.getParameter("bankAccountNumber")));

        boolean saved;
        try {
            if (idStr != null && !idStr.trim().isEmpty()) {
                employee.setId(Integer.parseInt(idStr.trim()));
                saved = employeeDao.update(employee);
            } else {
                saved = employeeDao.insert(employee);
            }
        } catch (NumberFormatException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Mã nhân viên không hợp lệ.");
            return;
        } catch (IllegalArgumentException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Ngày sinh không hợp lệ.");
            return;
        }

        if (!saved) {
            request.setAttribute("formError", "Không lưu được nhân viên. Hãy kiểm tra dữ liệu bắt buộc và email có bị trùng hay không.");
            request.setAttribute("employee", employee);
            request.setAttribute("searchKeyword", "");
            request.setAttribute("employeeList", employeeDao.getAll());
            request.getRequestDispatcher("/employee-list.jsp").forward(request, response);
            return;
        }
        response.sendRedirect(request.getContextPath() + "/employees");
    }

    private boolean requireAdmin(HttpServletRequest request, HttpServletResponse response) throws IOException {
        HttpSession session = request.getSession(false);
        Account user = session == null ? null : (Account) session.getAttribute("user");
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return false;
        }
        if (!"ADMIN".equalsIgnoreCase(user.getRole())) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Chỉ quản trị viên được quản lý hồ sơ nhân viên.");
            return false;
        }
        return true;
    }

    private Date parseDate(String value) {
        if (value == null || value.trim().isEmpty()) return null;
        return Date.valueOf(value.trim());
    }

    private String trim(String value) {
        return value == null ? "" : value.trim();
    }
}

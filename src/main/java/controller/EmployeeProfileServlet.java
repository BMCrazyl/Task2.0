package controller;

import dao.EmployeeDao;
import model.Account;
import model.Employee;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;
import javax.imageio.ImageIO;
import javax.imageio.ImageReader;
import javax.imageio.stream.ImageInputStream;
import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.Iterator;
import java.util.Locale;

@WebServlet(name = "EmployeeProfileServlet", urlPatterns = {"/profile"})
@MultipartConfig(maxFileSize = 5242880, maxRequestSize = 6291456, fileSizeThreshold = 524288)
public class EmployeeProfileServlet extends HttpServlet {
    private static final int MAX_AVATAR_BYTES = 5 * 1024 * 1024;
    private final EmployeeDao employeeDao = new EmployeeDao();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        Account user = currentUser(request, response);
        if (user == null) return;
        if (!"EMPLOYEE".equalsIgnoreCase(user.getRole())) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Trang hồ sơ cá nhân chỉ dành cho nhân viên.");
            return;
        }

        Employee employee = employeeDao.getByAccountId(user.getId(), user.getFullname());
        if (employee == null) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND,
                    "Chưa liên kết được tài khoản đăng nhập với hồ sơ nhân viên. Vui lòng liên hệ quản trị viên.");
            return;
        }
        user.setFullname(employee.getName());
        request.getSession().setAttribute("user", user);
        request.setAttribute("employee", employee);
        request.getRequestDispatcher("/employee-profile.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        Account user = currentUser(request, response);
        if (user == null) return;
        if (!"EMPLOYEE".equalsIgnoreCase(user.getRole())) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Chỉ nhân viên mới được cập nhật ảnh đại diện tại trang hồ sơ.");
            return;
        }

        HttpSession session = request.getSession();
        Employee employee = employeeDao.getByAccountId(user.getId(), user.getFullname());
        if (employee == null) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "Không tìm thấy hồ sơ nhân viên.");
            return;
        }

        try {
            Part avatarPart = request.getPart("avatarFile");
            if (avatarPart == null || avatarPart.getSize() <= 0) {
                session.setAttribute("profileMessage", "Vui lòng chọn ảnh đại diện trước khi lưu.");
                response.sendRedirect(request.getContextPath() + "/profile");
                return;
            }
            if (avatarPart.getSize() > MAX_AVATAR_BYTES) {
                session.setAttribute("profileMessage", "Ảnh đại diện không được vượt quá 5 MB.");
                response.sendRedirect(request.getContextPath() + "/profile");
                return;
            }

            String submitted = avatarPart.getSubmittedFileName();
            if (submitted == null || submitted.trim().isEmpty()) {
                session.setAttribute("profileMessage", "Tên ảnh không hợp lệ.");
                response.sendRedirect(request.getContextPath() + "/profile");
                return;
            }
            submitted = submitted.replace("\\", "/");
            submitted = submitted.substring(submitted.lastIndexOf('/') + 1).trim();
            String extension = "";
            int dot = submitted.lastIndexOf('.');
            if (dot >= 0) extension = submitted.substring(dot + 1).toLowerCase(Locale.ROOT);
            if (!java.util.List.of("jpg", "jpeg", "png", "gif").contains(extension)) {
                session.setAttribute("profileMessage", "Chỉ chấp nhận ảnh JPG, PNG hoặc GIF.");
                response.sendRedirect(request.getContextPath() + "/profile");
                return;
            }

            byte[] bytes;
            try (InputStream input = avatarPart.getInputStream()) {
                bytes = input.readNBytes(MAX_AVATAR_BYTES + 1);
            }
            if (bytes.length == 0 || bytes.length > MAX_AVATAR_BYTES) {
                session.setAttribute("profileMessage", "Ảnh trống hoặc vượt quá 5 MB.");
                response.sendRedirect(request.getContextPath() + "/profile");
                return;
            }

            String contentType = detectImageType(bytes);
            if (contentType == null
                    || (contentType.equals("image/png") && !extension.equals("png"))
                    || (contentType.equals("image/gif") && !extension.equals("gif"))
                    || (contentType.equals("image/jpeg") && !(extension.equals("jpg") || extension.equals("jpeg")))) {
                session.setAttribute("profileMessage", "Tệp tải lên không phải ảnh hợp lệ hoặc phần mở rộng không khớp.");
                response.sendRedirect(request.getContextPath() + "/profile");
                return;
            }

            boolean saved = employeeDao.updateAvatar(employee.getId(), bytes, contentType);
            session.setAttribute("profileMessage", saved
                    ? "Ảnh đại diện đã được lưu và đồng bộ với khu vực quản lý."
                    : "Không thể lưu ảnh đại diện. Vui lòng thử lại.");
        } catch (IllegalStateException e) {
            session.setAttribute("profileMessage", "Ảnh đại diện vượt quá giới hạn 5 MB.");
        }
        response.sendRedirect(request.getContextPath() + "/profile");
    }

    private String detectImageType(byte[] bytes) throws IOException {
        try (ImageInputStream imageInput = ImageIO.createImageInputStream(new ByteArrayInputStream(bytes))) {
            if (imageInput == null) return null;
            Iterator<ImageReader> readers = ImageIO.getImageReaders(imageInput);
            if (!readers.hasNext()) return null;
            ImageReader reader = readers.next();
            try {
                reader.setInput(imageInput, true, true);
                int width = reader.getWidth(0);
                int height = reader.getHeight(0);
                if (width <= 0 || height <= 0 || width > 8000 || height > 8000) return null;
                String format = reader.getFormatName().toLowerCase(Locale.ROOT);
                if ("jpg".equals(format) || "jpeg".equals(format)) return "image/jpeg";
                if ("png".equals(format)) return "image/png";
                if ("gif".equals(format)) return "image/gif";
                return null;
            } finally {
                reader.dispose();
            }
        }
    }

    private Account currentUser(HttpServletRequest request, HttpServletResponse response) throws IOException {
        HttpSession session = request.getSession(false);
        Account user = session == null ? null : (Account) session.getAttribute("user");
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return null;
        }
        return user;
    }
}

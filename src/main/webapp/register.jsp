<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Đăng Ký Tài Khoản - Task Manager</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    <script>(function(){try{var t=localStorage.getItem("taskmanager-theme");document.documentElement.setAttribute("data-theme",t==="light"?"light":"dark");}catch(e){document.documentElement.setAttribute("data-theme","dark");}})();</script>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/taskmanager-theme.css">
    <script defer src="${pageContext.request.contextPath}/assets/taskmanager-theme.js"></script>
</head>
<body class="bg-light d-flex align-items-center min-vh-100 py-4">

<div class="container">
    <div class="row justify-content-center">
        <div class="col-md-6 col-lg-5">
            <div class="card shadow-sm border-0 rounded-4">
                <div class="card-body p-4">
                    <div class="text-center mb-4">
                        <i class="bi bi-person-plus text-primary fs-1"></i>
                        <h4 class="fw-bold mt-2">Đăng Ký Tài Khoản</h4>
                        <p class="text-muted small">Chọn vai trò Quản lý hoặc Nhân viên</p>
                    </div>

                    <c:if test="${not empty error}">
                        <div class="alert alert-danger py-2 small" role="alert">
                            <i class="bi bi-exclamation-circle-fill me-1"></i>${error}
                        </div>
                    </c:if>

                    <form action="${pageContext.request.contextPath}/register" method="POST">
                        <div class="mb-3">
                            <label class="form-label fw-semibold">Họ và tên</label>
                            <input type="text" name="fullname" class="form-control" placeholder="VD: Tấn Hồ Võ Phúc" required>
                        </div>
                        <div class="mb-3">
                            <label class="form-label fw-semibold">Tên đăng nhập</label>
                            <input type="text" name="username" class="form-control" placeholder="Tên viết liền không dấu" required>
                        </div>
                        <div class="row g-2 mb-3">
                            <div class="col-md-6">
                                <label class="form-label fw-semibold">Mật khẩu</label>
                                <input type="password" name="password" class="form-control" placeholder="Mật khẩu" required>
                            </div>
                            <div class="col-md-6">
                                <label class="form-label fw-semibold">Xác nhận mật khẩu</label>
                                <input type="password" name="confirmPassword" class="form-control" placeholder="Nhập lại mật khẩu" required>
                            </div>
                        </div>
                        <div class="mb-4">
                            <label class="form-label fw-semibold">Vai trò truy cập</label>
                            <select name="role" class="form-select" required>
                                <option value="EMPLOYEE" selected>Nhân Viên (Xem tiến độ)</option>
                                <option value="ADMIN">Quản Lý (Toàn quyền)</option>
                            </select>
                        </div>

                        <button type="submit" class="btn btn-primary w-100 fw-bold py-2">
                            <i class="bi bi-check2-circle me-1"></i> Hoàn Tất Đăng Ký
                        </button>
                    </form>

                    <div class="text-center mt-4">
                        <span class="text-muted small">Đã có tài khoản?</span>
                        <a href="${pageContext.request.contextPath}/login" class="fw-bold text-decoration-none small">Đăng nhập ngay</a>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
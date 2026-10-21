<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Khôi Phục Mật Khẩu - Task Manager</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    <script>(function(){try{var t=localStorage.getItem("taskmanager-theme");document.documentElement.setAttribute("data-theme",t==="light"?"light":"dark");}catch(e){document.documentElement.setAttribute("data-theme","dark");}})();</script>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/taskmanager-theme.css">
    <script defer src="${pageContext.request.contextPath}/assets/taskmanager-theme.js"></script>
</head>
<body class="bg-light d-flex align-items-center min-vh-100 py-4">

<div class="container">
    <div class="row justify-content-center">
        <div class="col-md-5 col-lg-4">
            <div class="card shadow-sm border-0 rounded-4">
                <div class="card-body p-4">
                    <div class="text-center mb-3">
                        <i class="bi bi-shield-lock-fill text-primary display-5"></i>
                        <h4 class="fw-bold mt-2">Khôi Phục Mật Khẩu</h4>
                    </div>

                    <c:if test="${not empty error}">
                        <div class="alert alert-danger py-2 small" role="alert">
                            <i class="bi bi-exclamation-circle-fill me-1"></i>${error}
                        </div>
                    </c:if>
                    <c:if test="${not empty msg}">
                        <div class="alert alert-info py-2 small" role="alert">
                            <i class="bi bi-envelope-check-fill me-1"></i>${msg}
                        </div>
                    </c:if>

                    <c:choose>
                        <%-- Khung bước 1: Nhập tài khoản --%>
                        <c:when test="${empty step}">
                            <form action="${pageContext.request.contextPath}/forgot-password" method="POST">
                                <input type="hidden" name="action" value="sendOtp">
                                <div class="mb-3">
                                    <label class="form-label fw-semibold">Tên tài khoản</label>
                                    <input type="text" name="username" class="form-control" placeholder="Nhập tài khoản của bạn" required autofocus>
                                </div>
                                <button type="submit" class="btn btn-primary w-100 fw-bold py-2">
                                    Tiếp Tục <i class="bi bi-arrow-right ms-1"></i>
                                </button>
                            </form>
                        </c:when>

                        <%-- Khung bước 2: Đổi mật khẩu (kèm ô OTP nếu là Quản Lý) --%>
                        <c:otherwise>
                            <form action="${pageContext.request.contextPath}/forgot-password" method="POST">
                                <input type="hidden" name="action" value="confirmReset">

                                <c:if test="${step == 'verifyOtp'}">
                                    <div class="mb-3">
                                        <label class="form-label fw-semibold text-danger">Mã xác thực OTP (6 số)</label>
                                        <input type="text" name="otp" class="form-control text-center fs-5 fw-bold tracking-wide" 
                                               placeholder="••••••" maxlength="6" required autofocus>
                                        <small class="text-muted d-block mt-1">Kiểm tra hộp thư hovophuctan1403@gmail.com (hoặc cửa sổ Output NetBeans).</small>
                                    </div>
                                </c:if>

                                <div class="mb-3">
                                    <label class="form-label fw-semibold">Mật khẩu mới</label>
                                    <input type="password" name="newPassword" class="form-control" placeholder="Nhập mật khẩu mới" required>
                                </div>
                                <div class="mb-4">
                                    <label class="form-label fw-semibold">Xác nhận mật khẩu</label>
                                    <input type="password" name="confirmPassword" class="form-control" placeholder="Nhập lại mật khẩu" required>
                                </div>

                                <button type="submit" class="btn btn-success w-100 fw-bold py-2">
                                    <i class="bi bi-check-circle me-1"></i> Xác Nhận Đổi Mật Khẩu
                                </button>
                            </form>
                        </c:otherwise>
                    </c:choose>

                    <div class="text-center mt-4">
                        <a href="${pageContext.request.contextPath}/" class="text-decoration-none small text-muted">
                            <i class="bi bi-arrow-left me-1"></i> Trở về trang chủ
                        </a>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
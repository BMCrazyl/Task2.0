<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Đăng Nhập - Task Manager</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    <style>
        body {
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            background-color: #f8f9fa;
        }
        .login-card {
            width: 100%;
            max-width: 420px;
        }
    </style>
    <script>(function(){try{var t=localStorage.getItem("taskmanager-theme");document.documentElement.setAttribute("data-theme",t==="light"?"light":"dark");}catch(e){document.documentElement.setAttribute("data-theme","dark");}})();</script>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/taskmanager-theme.css">
    <script defer src="${pageContext.request.contextPath}/assets/taskmanager-theme.js"></script>
</head>
<body>

<div class="container py-4">
    <div class="row justify-content-center">
        <div class="col-12 col-sm-10 col-md-8 col-lg-5 col-xl-4 d-flex justify-content-center">
            <div class="card shadow-sm border-0 rounded-4 login-card">
                <div class="card-body p-4">
                    <div class="text-center mb-3">
                        <i class="bi ${param.role == 'ADMIN' ? 'bi-shield-lock-fill text-danger' : 'bi-person-badge-fill text-primary'} display-5"></i>
                        <h4 class="fw-bold mt-2 mb-1">
                            ${param.role == 'ADMIN' ? 'Đăng Nhập Quản Lý' : 'Đăng Nhập Nhân Viên'}
                        </h4>
                        <span class="badge ${param.role == 'ADMIN' ? 'bg-danger' : 'bg-primary'} mb-2">
                            ${param.role == 'ADMIN' ? 'Quyền Quản Trị Hệ Thống' : 'Quyền Nhân Sự'}
                        </span>
                    </div>

                    <c:if test="${not empty error}">
                        <div class="alert alert-danger py-2 small" role="alert">
                            <i class="bi bi-exclamation-circle-fill me-1"></i>${error}
                        </div>
                    </c:if>
                    <c:if test="${not empty success}">
                        <div class="alert alert-success py-2 small" role="alert">
                            <i class="bi bi-check-circle-fill me-1"></i>${success}
                        </div>
                    </c:if>

                    <form action="${pageContext.request.contextPath}/login" method="POST">
                        <input type="hidden" name="expectedRole" value="${param.role}">

                        <div class="mb-3">
                            <label class="form-label fw-semibold">Tài khoản</label>
                            <input type="text" name="username" class="form-control" placeholder="Nhập tài khoản" required autofocus>
                        </div>
                        <div class="mb-2">
                            <div class="d-flex justify-content-between align-items-center">
                                <label class="form-label fw-semibold mb-0">Mật khẩu</label>
                                <a href="${pageContext.request.contextPath}/forgot-password?role=${param.role}" class="small text-decoration-none">
                                    Quên mật khẩu?
                                </a>
                            </div>
                            <input type="password" name="password" class="form-control mt-1" placeholder="Nhập mật khẩu" required>
                        </div>

                        <button type="submit" class="btn ${param.role == 'ADMIN' ? 'btn-danger' : 'btn-primary'} w-100 fw-bold py-2 mt-3">
                            <i class="bi bi-box-arrow-in-right me-1"></i> Đăng Nhập
                        </button>
                    </form>

                    <!-- Chỉ Nhân Viên mới có liên kết Đăng Ký -->
                    <c:choose>
                        <c:when test="${param.role != 'ADMIN'}">
                            <div class="text-center mt-4">
                                <span class="text-muted small">Chưa có tài khoản?</span>
                                <a href="${pageContext.request.contextPath}/register" class="fw-bold text-decoration-none small">Đăng ký ngay</a>
                            </div>
                        </c:when>
                        <c:otherwise>
                            <div class="alert alert-warning py-2 small mt-3 mb-0 text-center">
                                <i class="bi bi-info-circle me-1"></i>Hệ thống chỉ cấp duy nhất 1 tài khoản Quản lý.
                            </div>
                        </c:otherwise>
                    </c:choose>

                    <!-- Dẫn thẳng về file index.jsp thay vì dấu / để tránh trang trắng Hello World -->
                    <div class="text-center mt-3 border-top pt-3">
                        <a href="${pageContext.request.contextPath}/index.jsp" class="text-decoration-none small text-muted">
                            <i class="bi bi-arrow-left me-1"></i> Chọn lại vai trò
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
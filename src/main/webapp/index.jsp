<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Hệ Thống Phân Công Công Việc</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    <style>
        .role-card {
            transition: all 0.3s ease;
            cursor: pointer;
            border-radius: 1.25rem;
        }
        .role-card:hover {
            transform: translateY(-8px);
            box-shadow: 0 1rem 2.5rem rgba(0,0,0,0.15) !important;
        }
    </style>
    <script>(function(){try{var t=localStorage.getItem("taskmanager-theme");document.documentElement.setAttribute("data-theme",t==="light"?"light":"dark");}catch(e){document.documentElement.setAttribute("data-theme","dark");}})();</script>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/taskmanager-theme.css">
    <script defer src="${pageContext.request.contextPath}/assets/taskmanager-theme.js"></script>
</head>
<body class="bg-light min-vh-100 d-flex align-items-center justify-content-center py-5">

<div class="container">
    <div class="text-center mb-5">
        <i class="bi bi-kanban text-primary display-4"></i>
        <h2 class="fw-bold mt-2 text-dark">HỆ THỐNG QUẢN LÝ PHÂN CÔNG</h2>
        <p class="text-muted">Chọn đúng vai trò của bạn để truy cập hệ thống</p>
    </div>

    <div class="row justify-content-center g-4">
        <!-- 1. Cổng dành cho Nhân Viên -->
        <div class="col-md-5 col-lg-4">
            <div class="card shadow-sm border-0 role-card p-4 text-center h-100 bg-white">
                <div class="card-body d-flex flex-column align-items-center justify-content-center">
                    <div class="bg-primary-subtle text-primary p-4 rounded-circle mb-3">
                        <i class="bi bi-person-badge display-5"></i>
                    </div>
                    <h4 class="fw-bold text-dark">NHÂN VIÊN</h4>
                    <p class="text-muted small mb-4">Xem tiến độ công việc được giao cá nhân, đăng nhập hoặc đăng ký tài khoản mới.</p>
                    <a href="${pageContext.request.contextPath}/login?role=EMPLOYEE" class="btn btn-primary w-100 py-2 fw-bold rounded-pill">
                        <i class="bi bi-box-arrow-in-right me-1"></i> Vào Cổng Nhân Viên
                    </a>
                </div>
            </div>
        </div>

        <!-- 2. Cổng dành cho Quản Lý -->
        <div class="col-md-5 col-lg-4">
            <div class="card shadow-sm border-0 role-card p-4 text-center h-100 bg-white">
                <div class="card-body d-flex flex-column align-items-center justify-content-center">
                    <div class="bg-danger-subtle text-danger p-4 rounded-circle mb-3">
                        <i class="bi bi-shield-lock display-5"></i>
                    </div>
                    <h4 class="fw-bold text-dark">QUẢN LÝ</h4>
                    <p class="text-muted small mb-4">Quản lý dự án, toàn bộ công việc và nhân sự (Tài khoản bảo mật duy nhất).</p>
                    <a href="${pageContext.request.contextPath}/login?role=ADMIN" class="btn btn-danger w-100 py-2 fw-bold rounded-pill">
                        <i class="bi bi-shield-check me-1"></i> Vào Cổng Quản Lý
                    </a>
                </div>
            </div>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Hồ sơ cá nhân | Task Manager</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    <style>
        .profile-avatar { width: 156px; height: 156px; object-fit: cover; border-radius: 50%; border: 4px solid #e9ecef; }
        .profile-avatar-placeholder { width: 156px; height: 156px; border-radius: 50%; background: #e9ecef; color: #6c757d; display: flex; align-items: center; justify-content: center; font-size: 5rem; margin: 0 auto; }
        .profile-value { min-height: 42px; padding: .6rem .75rem; border: 1px solid #dee2e6; border-radius: .375rem; background: #f8f9fa; overflow-wrap: anywhere; }
    </style>
</head>
<body class="bg-light">
<nav class="navbar navbar-dark bg-dark shadow-sm">
    <div class="container">
        <a class="navbar-brand fw-bold" href="${pageContext.request.contextPath}/dashboard">
            <i class="bi bi-kanban me-2 text-info"></i>Task Manager
        </a>
        <span class="text-white-50">${sessionScope.user.fullname}</span>
    </div>
</nav>
<main class="container py-4">
    <div class="d-flex justify-content-between align-items-center flex-wrap gap-2 mb-4">
        <div>
            <h2 class="fw-bold mb-1">Hồ sơ cá nhân</h2>
            <p class="text-muted mb-0">Thông tin hồ sơ được quản lý đồng bộ với bộ phận quản lý nhân viên.</p>
        </div>
        <a class="btn btn-outline-secondary" href="${pageContext.request.contextPath}/dashboard">
            <i class="bi bi-arrow-left me-1"></i>Quay lại tổng quan
        </a>
    </div>

    <c:if test="${not empty sessionScope.profileMessage}">
        <div class="alert alert-info alert-dismissible fade show" role="alert">
            <c:out value="${sessionScope.profileMessage}"/>
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Đóng"></button>
        </div>
        <c:remove var="profileMessage" scope="session"/>
    </c:if>

    <div class="row g-4">
        <div class="col-lg-4">
            <div class="card border-0 shadow-sm">
                <div class="card-body text-center p-4">
                    <c:choose>
                        <c:when test="${not empty employee.avatarContentType}">
                            <img class="profile-avatar mb-3" src="${pageContext.request.contextPath}/employee-avatar?self=1&amp;v=${employee.id}" alt="Ảnh đại diện nhân viên">
                        </c:when>
                        <c:otherwise>
                            <div class="profile-avatar-placeholder mb-3"><i class="bi bi-person-circle"></i></div>
                        </c:otherwise>
                    </c:choose>
                    <h4 class="fw-bold mb-1"><c:out value="${employee.name}"/></h4>
                    <span class="badge text-bg-primary"><c:out value="${employee.position}"/></span>
                    <p class="small text-muted mt-3 mb-3">Thông tin cá nhân chỉ xem tại đây. Bạn có thể tự cập nhật ảnh đại diện.</p>
                    <form action="${pageContext.request.contextPath}/profile" method="post" enctype="multipart/form-data">
                        <label for="avatarFile" class="form-label fw-semibold text-start w-100">Ảnh đại diện</label>
                        <input id="avatarFile" class="form-control mb-2" type="file" name="avatarFile" accept=".jpg,.jpeg,.png,.gif,image/jpeg,image/png,image/gif" required>
                        <small class="text-muted d-block text-start mb-3">JPG, PNG hoặc GIF; tối đa 5 MB.</small>
                        <button type="submit" class="btn btn-primary w-100 fw-bold">
                            <i class="bi bi-cloud-arrow-up me-1"></i>Lưu ảnh đại diện
                        </button>
                    </form>
                </div>
            </div>
        </div>

        <div class="col-lg-8">
            <div class="card border-0 shadow-sm">
                <div class="card-header bg-white py-3">
                    <h5 class="fw-bold mb-0"><i class="bi bi-person-vcard me-2 text-primary"></i>Thông tin nhân viên</h5>
                </div>
                <div class="card-body p-4">
                    <div class="row g-3">
                        <div class="col-md-6"><label class="form-label fw-semibold">Họ</label><div class="profile-value"><c:out value="${employee.familyName}"/></div></div>
                        <div class="col-md-6"><label class="form-label fw-semibold">Tên</label><div class="profile-value"><c:out value="${employee.givenName}"/></div></div>
                        <div class="col-md-6"><label class="form-label fw-semibold">Ngày sinh</label><div class="profile-value"><c:out value="${employee.dateOfBirth}"/></div></div>
                        <div class="col-md-6"><label class="form-label fw-semibold">Số điện thoại</label><div class="profile-value"><c:out value="${employee.phone}"/></div></div>
                        <div class="col-md-6"><label class="form-label fw-semibold">Số CCCD</label><div class="profile-value"><c:out value="${employee.identityNumber}"/></div></div>
                        <div class="col-md-6"><label class="form-label fw-semibold">Khu vực</label><div class="profile-value"><c:out value="${employee.region}"/></div></div>
                        <div class="col-12"><label class="form-label fw-semibold">Địa chỉ thường trú</label><div class="profile-value"><c:out value="${employee.permanentAddress}"/></div></div>
                        <div class="col-md-6"><label class="form-label fw-semibold">Tên ngân hàng</label><div class="profile-value"><c:out value="${employee.bankName}"/></div></div>
                        <div class="col-md-6"><label class="form-label fw-semibold">Số tài khoản ngân hàng</label><div class="profile-value"><c:out value="${employee.bankAccountNumber}"/></div></div>
                        <div class="col-md-6"><label class="form-label fw-semibold">Email</label><div class="profile-value"><c:out value="${employee.email}"/></div></div>
                        <div class="col-md-6"><label class="form-label fw-semibold">Chức vụ</label><div class="profile-value"><c:out value="${employee.position}"/></div></div>
                    </div>
                    <div class="alert alert-secondary mt-4 mb-0 small">
                        <i class="bi bi-info-circle me-1"></i>Muốn thay đổi thông tin cá nhân khác, vui lòng liên hệ quản trị viên. Những thay đổi do quản trị viên lưu sẽ xuất hiện tại hồ sơ này.
                    </div>
                </div>
            </div>
        </div>
    </div>
</main>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>

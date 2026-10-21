<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quản Lý Nhân Viên</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    <style>
        .nav-pills .nav-link:hover {
            background-color: rgba(255, 255, 255, 0.1);
        }
        .nav-pills .nav-link.active {
            background-color: #0d6efd !important;
        }
    </style>
    <script>(function(){try{var t=localStorage.getItem("taskmanager-theme");document.documentElement.setAttribute("data-theme",t==="light"?"light":"dark");}catch(e){document.documentElement.setAttribute("data-theme","dark");}})();</script>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/taskmanager-theme.css">
    <script defer src="${pageContext.request.contextPath}/assets/taskmanager-theme.js"></script>
</head>
<body class="bg-light">

<!-- Thanh Navbar trên cùng với nút 3 gạch -->
<nav class="navbar navbar-dark bg-dark mb-4 shadow-sm py-2">
    <div class="container-fluid px-3">
        <!-- Nút 3 gạch mở Menu dọc -->
        <button class="btn btn-outline-light border-0 fs-4 me-2" type="button" 
                data-bs-toggle="offcanvas" data-bs-target="#sidebarMenu" aria-controls="sidebarMenu">
            <i class="bi bi-list"></i>
        </button>

        <a class="navbar-brand fw-bold me-auto" href="${pageContext.request.contextPath}/dashboard">
            <i class="bi bi-kanban me-2 text-primary"></i>Task Manager
        </a>
    </div>
</nav>

<!-- Sidebar hàng dọc trượt từ mép trái ra khi bấm nút 3 gạch -->
<div class="offcanvas offcanvas-start bg-dark text-white d-flex flex-column" tabindex="-1" id="sidebarMenu" aria-labelledby="sidebarMenuLabel" style="width: 280px;">
    <div class="offcanvas-header border-bottom border-secondary py-3">
        <h5 class="offcanvas-title fw-bold text-primary" id="sidebarMenuLabel">
            <i class="bi bi-kanban me-2"></i>Task Manager
        </h5>
        <button type="button" class="btn-close btn-close-white" data-bs-dismiss="offcanvas" aria-label="Close"></button>
    </div>
    
    <div class="offcanvas-body p-0 pt-3 d-flex flex-column">
        <div class="nav flex-column nav-pills px-3 gap-2">
            <a class="nav-link text-white py-2 px-3 rounded d-flex align-items-center gap-3 fs-6" 
               href="${pageContext.request.contextPath}/dashboard">
                <i class="bi bi-speedometer2 fs-5 text-info"></i> Tổng Quan
            </a>
            
            <a class="nav-link active text-white py-2 px-3 rounded d-flex align-items-center gap-3 fs-6" 
               href="${pageContext.request.contextPath}/employees">
                <i class="bi bi-people fs-5 text-warning"></i> Nhân Viên
            </a>
            
            <a class="nav-link text-white py-2 px-3 rounded d-flex align-items-center gap-3 fs-6" 
               href="${pageContext.request.contextPath}/projects">
                <i class="bi bi-folder2 fs-5 text-primary"></i> Dự Án
            </a>
            
            <a class="nav-link text-white py-2 px-3 rounded d-flex align-items-center gap-3 fs-6" 
               href="${pageContext.request.contextPath}/tasks">
                <i class="bi bi-check2-square fs-5 text-success"></i> Công Việc
            </a>
            
            <a class="nav-link text-white py-2 px-3 rounded d-flex align-items-center gap-3 fs-6" 
               href="${pageContext.request.contextPath}/assign">
                <i class="bi bi-person-check fs-5 text-danger"></i> Phân Công
            </a>
        </div>

        <!-- Khối thông tin tài khoản & nút Đăng Xuất ở đáy Sidebar -->
        <div class="mt-auto p-3 border-top border-secondary">
            <div class="d-flex align-items-center mb-2">
                <i class="bi bi-person-circle fs-3 me-2 text-info"></i>
                <div class="overflow-hidden">
                    <div class="fw-bold text-truncate" style="max-width: 170px;">
                        ${not empty sessionScope.user.fullname ? sessionScope.user.fullname : 'Quản Lý'}
                    </div>
                    <span class="badge ${sessionScope.user.role == 'ADMIN' ? 'bg-danger' : 'bg-primary'}">
                        ${sessionScope.user.role == 'ADMIN' ? 'Quản Lý' : 'Nhân Viên'}
                    </span>
                </div>
            </div>
            <a href="${pageContext.request.contextPath}/logout" class="btn btn-outline-danger btn-sm w-100 mt-2">
                <i class="bi bi-box-arrow-right me-1"></i> Đăng Xuất
            </a>
        </div>
    </div>
</div>

<div class="container pb-5">
    <div class="row g-4">
        <!-- Form Thêm / Cập nhật Nhân Viên -->
        <div class="col-lg-4">
            <div class="card shadow-sm border-0">
                <div class="card-header ${not empty employee ? 'bg-warning text-dark' : 'bg-primary text-white'} py-3">
                    <h5 class="fw-bold mb-0">
                        <i class="bi ${not empty employee ? 'bi-pencil-square' : 'bi-person-plus'} me-2"></i>
                        ${not empty employee ? 'Cập Nhật Nhân Viên' : 'Thêm Nhân Viên Mới'}
                    </h5>
                </div>
                <div class="card-body p-4">
                    <c:if test="${not empty formError}"><div class="alert alert-danger"><c:out value="${formError}"/></div></c:if>
                    <form action="${pageContext.request.contextPath}/employees" method="POST">
                        <input type="hidden" name="id" value="${employee.id}">
                        <div class="row g-3">
                            <div class="col-md-6">
                                <label class="form-label fw-bold">Họ</label>
                                <input type="text" name="familyName" class="form-control" value="${employee.familyName}" placeholder="VD: Nguyễn Văn" required>
                            </div>
                            <div class="col-md-6">
                                <label class="form-label fw-bold">Tên</label>
                                <input type="text" name="givenName" class="form-control" value="${employee.givenName}" placeholder="VD: An" required>
                            </div>
                            <div class="col-12">
                                <label class="form-label fw-bold">Email</label>
                                <input type="email" name="email" class="form-control" value="${employee.email}" placeholder="an.nv@company.com" required>
                            </div>
                            <div class="col-md-6">
                                <label class="form-label fw-bold">Ngày sinh</label>
                                <input type="date" name="dateOfBirth" class="form-control" value="${employee.dateOfBirth}">
                            </div>
                            <div class="col-md-6">
                                <label class="form-label fw-bold">Số điện thoại</label>
                                <input type="tel" name="phone" class="form-control" value="${employee.phone}" placeholder="0901234567">
                            </div>
                            <div class="col-md-6">
                                <label class="form-label fw-bold">Số CCCD</label>
                                <input type="text" name="identityNumber" class="form-control" value="${employee.identityNumber}" maxlength="30">
                            </div>
                            <div class="col-md-6">
                                <label class="form-label fw-bold">Khu vực</label>
                                <input type="text" name="region" class="form-control" value="${employee.region}" placeholder="Tỉnh / thành phố">
                            </div>
                            <div class="col-12">
                                <label class="form-label fw-bold">Địa chỉ thường trú</label>
                                <textarea name="permanentAddress" class="form-control" rows="2" maxlength="500"><c:out value="${employee.permanentAddress}"/></textarea>
                            </div>
                            <div class="col-12">
                                <label class="form-label fw-bold">Vị trí / Chức vụ</label>
                                <input type="text" name="position" class="form-control" value="${employee.position}" placeholder="Backend Developer, Kế toán, QA Lead..." required>
                            </div>
                            <div class="col-md-6">
                                <label class="form-label fw-bold">Tên ngân hàng</label>
                                <input type="text" name="bankName" class="form-control" value="${employee.bankName}" placeholder="Tên ngân hàng">
                            </div>
                            <div class="col-md-6">
                                <label class="form-label fw-bold">Số tài khoản ngân hàng</label>
                                <input type="text" name="bankAccountNumber" class="form-control" value="${employee.bankAccountNumber}" maxlength="50">
                            </div>
                        </div>
                        <div class="d-flex gap-2 mt-4">
                            <button type="submit" class="btn btn-primary fw-bold w-100">
                                <i class="bi bi-save me-1"></i> Lưu thông tin nhân viên
                            </button>
                            <c:if test="${not empty employee}">
                                <a href="${pageContext.request.contextPath}/employees" class="btn btn-outline-secondary">Hủy</a>
                            </c:if>
                        </div>
                    </form>
                </div>
            </div>
        </div>

        <!-- Bảng Danh Sách Nhân Viên -->
        <div class="col-lg-8">
            <div class="card shadow-sm border-0">
                <div class="card-header bg-white py-3 d-flex justify-content-between align-items-center">
                    <div>
                        <h5 class="fw-bold mb-0 text-dark">Danh Sách Nhân Viên</h5>
                        <span class="badge bg-secondary">${employeeList.size()} nhân viên</span>
                    </div>
                    <form action="${pageContext.request.contextPath}/employees" method="get" class="d-flex gap-2" role="search">
                        <input type="search" name="keyword" class="form-control form-control-sm" style="min-width:180px"
                               value="${searchKeyword}" placeholder="Tìm tên, email, chức vụ..." aria-label="Tìm nhân viên">
                        <button type="submit" class="btn btn-primary btn-sm"><i class="bi bi-search"></i></button>
                        <c:if test="${not empty searchKeyword}">
                            <a href="${pageContext.request.contextPath}/employees" class="btn btn-outline-secondary btn-sm">Xóa lọc</a>
                        </c:if>
                    </form>
                </div>
                <div class="table-responsive">
                    <table class="table table-hover align-middle mb-0">
                        <thead class="table-light">
                            <tr>
                                <th>#ID</th>
                                <th>Họ Tên</th>
                                <th>Liên Hệ</th>
                                <th>Chức Vụ</th>
                                <th class="text-center">Thao Tác</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="e" items="${employeeList}" varStatus="employeeRow">
                                <tr>
                                    <td><strong>#${employeeRow.index + 1}</strong></td>
                                    <td class="fw-bold text-primary">${e.name}</td>
                                    <td>
                                        <div><i class="bi bi-envelope me-1 text-muted"></i>${e.email}</div>
                                        <small class="text-muted"><i class="bi bi-telephone me-1"></i>${e.phone}</small>
                                    </td>
                                    <td><span class="badge bg-light text-dark border">${e.position}</span></td>
                                    <td class="text-center">
                                        <div class="d-inline-flex flex-wrap gap-1">
                                            <!-- Nút Sửa -->
                                            <a href="${pageContext.request.contextPath}/employees?action=edit&id=${e.id}" 
                                               class="btn btn-outline-warning btn-sm" title="Sửa thông tin">
                                                <i class="bi bi-pencil-square"></i> Sửa
                                            </a>

                                            <a href="${pageContext.request.contextPath}/employees?action=detail&id=${e.id}"
                                               class="btn btn-outline-primary btn-sm" title="Xem chi tiết nhân viên">
                                                <i class="bi bi-eye"></i> Chi tiết
                                            </a>

                                            <!-- Nút Xóa có hộp thoại xác nhận -->
                                            <a href="${pageContext.request.contextPath}/employees?action=delete&id=${e.id}" 
                                               onclick="return confirm('Bạn có chắc chắn muốn xóa nhân viên [${e.name}] không?')" 
                                               class="btn btn-outline-danger btn-sm" title="Xóa nhân viên">
                                                <i class="bi bi-trash"></i> Xóa
                                            </a>
                                        </div>
                                    </td>
                                </tr>
                            </c:forEach>
                            <c:if test="${empty employeeList}">
                                <tr>
                                    <td colspan="5" class="text-center py-4 text-muted">Không tìm thấy nhân viên phù hợp.</td>
                                </tr>
                            </c:if>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>
</div>

<c:if test="${showDetailModal and not empty employeeDetail}">
<div class="modal fade" id="employeeDetailModal" tabindex="-1" aria-labelledby="employeeDetailModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-lg modal-dialog-centered modal-dialog-scrollable">
        <div class="modal-content border-0 shadow">
            <div class="modal-header bg-primary text-white">
                <h5 class="modal-title fw-bold" id="employeeDetailModalLabel"><i class="bi bi-person-vcard me-2"></i>Chi tiết nhân viên</h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Đóng"></button>
            </div>
            <div class="modal-body p-4">
                <div class="text-center mb-4">
                    <c:choose>
                        <c:when test="${not empty employeeDetail.avatarContentType}">
                            <img src="${pageContext.request.contextPath}/employee-avatar?id=${employeeDetail.id}" alt="Ảnh đại diện" class="rounded-circle border shadow-sm" style="width:140px;height:140px;object-fit:cover">
                        </c:when>
                        <c:otherwise>
                            <div class="rounded-circle bg-light border d-inline-flex align-items-center justify-content-center text-secondary" style="width:140px;height:140px;font-size:4rem"><i class="bi bi-person-circle"></i></div>
                        </c:otherwise>
                    </c:choose>
                    <h4 class="fw-bold mt-3 mb-1"><c:out value="${employeeDetail.name}"/></h4>
                    <span class="badge text-bg-primary"><c:out value="${employeeDetail.position}"/></span>
                </div>
                <div class="row g-3">
                    <div class="col-md-6"><div class="small text-muted">Họ</div><div class="fw-semibold"><c:out value="${employeeDetail.familyName}"/></div></div>
                    <div class="col-md-6"><div class="small text-muted">Tên</div><div class="fw-semibold"><c:out value="${employeeDetail.givenName}"/></div></div>
                    <div class="col-md-6"><div class="small text-muted">Ngày sinh</div><div class="fw-semibold"><c:out value="${employeeDetail.dateOfBirth}"/></div></div>
                    <div class="col-md-6"><div class="small text-muted">Số điện thoại</div><div class="fw-semibold"><c:out value="${employeeDetail.phone}"/></div></div>
                    <div class="col-md-6"><div class="small text-muted">Email</div><div class="fw-semibold"><c:out value="${employeeDetail.email}"/></div></div>
                    <div class="col-md-6"><div class="small text-muted">Số CCCD</div><div class="fw-semibold"><c:out value="${employeeDetail.identityNumber}"/></div></div>
                    <div class="col-md-6"><div class="small text-muted">Khu vực</div><div class="fw-semibold"><c:out value="${employeeDetail.region}"/></div></div>
                    <div class="col-12"><div class="small text-muted">Địa chỉ thường trú</div><div class="fw-semibold text-break"><c:out value="${employeeDetail.permanentAddress}"/></div></div>
                    <div class="col-md-6"><div class="small text-muted">Tên ngân hàng</div><div class="fw-semibold"><c:out value="${employeeDetail.bankName}"/></div></div>
                    <div class="col-md-6"><div class="small text-muted">Số tài khoản ngân hàng</div><div class="fw-semibold"><c:out value="${employeeDetail.bankAccountNumber}"/></div></div>
                </div>
            </div>
            <div class="modal-footer">
                <a class="btn btn-primary" href="${pageContext.request.contextPath}/employees?action=edit&id=${employeeDetail.id}"><i class="bi bi-pencil-square me-1"></i>Sửa thông tin</a>
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal" onclick="window.location.href='${pageContext.request.contextPath}/employees'">Đóng</button>
            </div>
        </div>
    </div>
</div>
<script>
document.addEventListener("DOMContentLoaded", function () {
    const modal = document.getElementById("employeeDetailModal");
    if (modal) new bootstrap.Modal(modal).show();
});
</script>
</c:if>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
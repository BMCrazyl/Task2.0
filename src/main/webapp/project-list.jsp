<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quản Lý Dự Án</title>
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

<!-- Navbar có nút 3 gạch -->
<nav class="navbar navbar-dark bg-dark mb-4 shadow-sm py-2">
    <div class="container-fluid px-3">
        <button class="btn btn-outline-light border-0 fs-4 me-2" type="button" 
                data-bs-toggle="offcanvas" data-bs-target="#sidebarMenu" aria-controls="sidebarMenu">
            <i class="bi bi-list"></i>
        </button>
        <a class="navbar-brand fw-bold me-auto" href="${pageContext.request.contextPath}/dashboard">
            <i class="bi bi-kanban me-2 text-primary"></i>Task Manager
        </a>
    </div>
</nav>

<!-- Sidebar trượt trái -->
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
            <a class="nav-link text-white py-2 px-3 rounded d-flex align-items-center gap-3 fs-6" 
               href="${pageContext.request.contextPath}/employees">
                <i class="bi bi-people fs-5 text-warning"></i> Nhân Viên
            </a>
            <a class="nav-link active text-white py-2 px-3 rounded d-flex align-items-center gap-3 fs-6" 
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
        <!-- Form Thêm / Sửa Dự án -->
        <div class="col-lg-4">
            <div class="card shadow-sm border-0">
                <div class="card-header ${not empty project ? 'bg-warning text-dark' : 'bg-primary text-white'} py-3">
                    <h5 class="fw-bold mb-0">
                        <i class="bi ${not empty project ? 'bi-pencil-square' : 'bi-folder-plus'} me-2"></i>
                        ${not empty project ? 'Cập Nhật Dự Án' : 'Thêm Dự Án Mới'}
                    </h5>
                </div>
                <div class="card-body p-4">
                    <form action="${pageContext.request.contextPath}/projects" method="POST">
                        <input type="hidden" name="id" value="${project.id}">

                        <div class="mb-3">
                            <label class="form-label fw-bold">Tên dự án</label>
                            <input type="text" name="projectName" class="form-control" 
                                   value="${project.projectName}" placeholder="VD: Hệ Thống Đặt Chỗ" required>
                        </div>
                        <div class="mb-3">
                            <label class="form-label fw-bold">Ngày bắt đầu</label>
                            <input type="date" name="startDate" class="form-control" value="${project.startDate}" required>
                        </div>
                        <div class="mb-3">
                            <label class="form-label fw-bold">Ngày kết thúc</label>
                            <input type="date" name="endDate" class="form-control" value="${project.endDate}" required>
                        </div>
                        <div class="mb-4">
                            <label class="form-label fw-bold">Mô tả dự án</label>
                            <textarea name="description" class="form-control" rows="3" 
                                      placeholder="Mục tiêu và phạm vi dự án...">${project.description}</textarea>
                        </div>
                        
                        <div class="d-flex gap-2">
                            <button type="submit" class="btn ${not empty project ? 'btn-warning fw-bold' : 'btn-primary fw-bold'} w-100">
                                <i class="bi bi-save me-1"></i> ${not empty project ? 'Lưu Cập Nhật' : 'Lưu Dự Án'}
                            </button>
                            <c:if test="${not empty project}">
                                <a href="${pageContext.request.contextPath}/projects" class="btn btn-outline-secondary">Hủy</a>
                            </c:if>
                        </div>
                    </form>
                </div>
            </div>
        </div>

        <!-- Bảng danh sách dự án -->
        <div class="col-lg-8">
            <div class="card shadow-sm border-0">
                <div class="card-header bg-white py-3 d-flex justify-content-between align-items-center">
                    <div>
                        <h5 class="fw-bold mb-0 text-dark">Danh Sách Dự Án</h5>
                        <span class="badge bg-secondary">${projectList.size()} dự án</span>
                    </div>
                    <form action="${pageContext.request.contextPath}/projects" method="get" class="d-flex gap-2">
                        <input type="search" name="keyword" class="form-control form-control-sm" style="min-width:180px"
                               value="${searchKeyword}" placeholder="Tìm tên, mô tả, ngày...">
                        <button type="submit" class="btn btn-primary btn-sm"><i class="bi bi-search"></i></button>
                        <c:if test="${not empty searchKeyword}"><a href="${pageContext.request.contextPath}/projects" class="btn btn-outline-secondary btn-sm">Xóa lọc</a></c:if>
                    </form>
                </div>
                <div class="table-responsive">
                    <table class="table table-hover align-middle mb-0">
                        <thead class="table-light">
                            <tr>
                                <th>#ID</th>
                                <th>Tên Dự Án</th>
                                <th>Thời Gian</th>
                                <th>Mô Tả</th>
                                <th class="text-center">Thao Tác</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="p" items="${projectList}" varStatus="projectRow">
                                <tr>
                                    <td><strong>#${projectRow.index + 1}</strong></td>
                                    <td>
                                        <a href="${pageContext.request.contextPath}/projects?action=viewTasks&id=${p.id}" 
                                           class="fw-bold text-decoration-none text-primary" title="Bấm để xem công việc">
                                            ${p.projectName}
                                        </a>
                                    </td>
                                    <td>
                                        <small class="d-block text-muted">Bắt đầu: ${p.startDate}</small>
                                        <small class="d-block text-danger">Kết thúc: ${p.endDate}</small>
                                    </td>
                                    <td><small class="text-secondary">${p.description}</small></td>
                                    <td class="text-center">
                                        <div class="d-inline-flex gap-1">
                                            <!-- Nút Xem Công Việc của Dự Án -->
                                            <a href="${pageContext.request.contextPath}/projects?action=viewTasks&id=${p.id}" 
                                               class="btn btn-outline-info btn-sm text-dark" title="Xem danh sách công việc">
                                                <i class="bi bi-eye"></i> Việc
                                            </a>
                                            <!-- Nút Sửa -->
                                            <a href="${pageContext.request.contextPath}/projects?action=edit&id=${p.id}" 
                                               class="btn btn-outline-warning btn-sm" title="Sửa thông tin dự án">
                                                <i class="bi bi-pencil-square"></i> Sửa
                                            </a>
                                            <!-- Nút Xóa -->
                                            <a href="${pageContext.request.contextPath}/projects?action=delete&id=${p.id}" 
                                               onclick="return confirm('Bạn có chắc muốn xóa dự án này? Toàn bộ công việc thuộc dự án cũng sẽ bị xóa!')" 
                                               class="btn btn-outline-danger btn-sm" title="Xóa dự án">
                                                <i class="bi bi-trash"></i>
                                            </a>
                                        </div>
                                    </td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- Lịch sử dự án hoàn thành -->
<div class="container pb-5">
    <div class="card shadow-sm border-0">
        <div class="card-header bg-dark text-white py-3 d-flex flex-wrap justify-content-between align-items-center gap-2">
            <div><h5 class="fw-bold mb-0"><i class="bi bi-archive me-2"></i>Lịch Sử Dự Án Đã Hoàn Thành</h5>
            <small>Dự án được lưu khi toàn bộ công việc đã hoàn thành.</small></div>
            <span class="badge bg-secondary">${projectHistory.size()} dự án</span>
        </div>
        <div class="table-responsive"><table class="table table-hover align-middle mb-0">
            <thead class="table-light"><tr><th>#</th><th>Tên dự án</th><th>Thời gian</th><th>Ngày lưu</th><th>Mô tả</th><th>Thao tác</th></tr></thead>
            <tbody>
                <c:forEach var="archivedProject" items="${projectHistory}" varStatus="historyRow">
                    <tr><td>#${historyRow.index + 1}</td><td class="fw-bold">${archivedProject.projectName}</td>
                    <td><small class="d-block">Bắt đầu: ${archivedProject.startDate}</small><small class="d-block">Kết thúc: ${archivedProject.endDate}</small></td>
                    <td>${archivedProject.archivedAt}</td><td><small class="text-muted">${archivedProject.description}</small></td>
                    <td><div class="d-inline-flex gap-1">
                        <a href="${pageContext.request.contextPath}/projects?action=viewTasks&id=${archivedProject.id}" class="btn btn-outline-info btn-sm"><i class="bi bi-eye"></i> Xem</a>
                        <a href="${pageContext.request.contextPath}/projects?action=deleteHistory&id=${archivedProject.id}" class="btn btn-outline-danger btn-sm"
                           onclick="return confirm('Xóa vĩnh viễn dự án này cùng các công việc và lịch sử chấm công liên quan? Không thể hoàn tác.');">
                           <i class="bi bi-trash"></i> Xóa lịch sử</a>
                    </div></td></tr>
                </c:forEach>
                <c:if test="${empty projectHistory}"><tr><td colspan="6" class="text-center text-muted py-4">Chưa có dự án nào hoàn thành toàn bộ công việc.</td></tr></c:if>
            </tbody>
        </table></div>
    </div>
</div>

<!-- Modal hiển thị danh sách công việc và người phụ trách -->
<div class="modal fade" id="tasksModal" tabindex="-1" aria-labelledby="tasksModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-lg modal-dialog-centered">
        <div class="modal-content border-0 shadow">
            <div class="modal-header bg-primary text-white">
                <h5 class="modal-title fw-bold" id="tasksModalLabel">
                    <i class="bi bi-folder-check me-2"></i>Dự Án: ${selectedProject.projectName}
                </h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body p-0">
                <div class="table-responsive">
                    <table class="table table-hover align-middle mb-0">
                        <thead class="table-light">
                            <tr>
                                <th>#ID</th>
                                <th>Tên Công Việc</th>
                                <th>Người Phụ Trách</th>
                                <th>Hạn Chót</th>
                                <th>Mức Ưu Tiên</th>
                                <th>Trạng Thái</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:choose>
                                <c:when test="${not empty projectTasks}">
                                    <c:forEach var="task" items="${projectTasks}" varStatus="projectTaskRow">
                                        <tr>
                                            <td><strong>#${projectTaskRow.index + 1}</strong></td>
                                            <td class="fw-bold">${task.taskName}</td>
                                            <td>
                                                <c:choose>
                                                    <c:when test="${task.employeeName != 'Chưa phân công'}">
                                                        <span class="badge bg-info text-dark">
                                                            <i class="bi bi-person-fill me-1"></i>${task.employeeName}
                                                        </span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="badge bg-light text-muted border">
                                                            <i class="bi bi-person me-1"></i>Chưa phân công
                                                        </span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td>${task.deadline}</td>
                                            <td>
                                                <span class="badge ${(task.priority == 'Cao') ? 'bg-danger' : ((task.priority == 'Trung bình' or task.priority == 'Trung binh') ? 'bg-warning text-dark' : ((task.priority == 'Thấp' or task.priority == 'Thap') ? 'bg-success' : 'bg-secondary'))}">
                                                    ${task.priority}
                                                </span>
                                            </td>
                                            <td>
                                                <span class="badge ${(task.status == 'Hoàn thành' or task.status == 'Hoan thanh') ? 'bg-success' : ((task.status == 'Đang thực hiện' or task.status == 'Dang thuc hien') ? 'bg-primary' : 'bg-secondary')}">
                                                    ${task.status}
                                                </span>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </c:when>
                                <c:otherwise>
                                    <tr>
                                        <td colspan="6" class="text-center py-4 text-muted">
                                            Dự án này hiện chưa có công việc nào.
                                        </td>
                                    </tr>
                                </c:otherwise>
                            </c:choose>
                        </tbody>
                    </table>
                </div>
                <div class="border-top p-3">
                    <h6 class="fw-bold mb-3"><i class="bi bi-file-earmark-check me-2 text-primary"></i>Báo cáo công việc của dự án</h6>
                    <div class="table-responsive">
                        <table class="table table-sm table-hover align-middle mb-0">
                            <thead class="table-light"><tr><th>Tệp báo cáo</th><th>Công việc</th><th>Nhân viên</th><th>Ngày gửi</th><th>Trạng thái</th><th>Tải xuống</th></tr></thead>
                            <tbody>
                                <c:forEach var="report" items="${projectReports}">
                                    <tr>
                                        <td><i class="bi bi-file-earmark me-1"></i>${report.originalFileName}</td>
                                        <td>${report.taskName}</td><td>${report.employeeName}</td><td>${report.submittedAt}</td>
                                        <td><span class="badge ${report.reviewStatus == 'Đã tiếp nhận' ? 'bg-success' : 'bg-warning text-dark'}">${report.reviewStatus}</span>
                                            <c:if test="${not empty report.receivedBy}"><small class="d-block text-muted">${report.receivedBy} · ${report.receivedAt}</small></c:if>
                                        </td>
                                        <td><c:if test="${sessionScope.user.role == 'ADMIN'}"><a class="btn btn-sm btn-outline-primary" href="${pageContext.request.contextPath}/reports?action=download&id=${report.id}"><i class="bi bi-download"></i></a></c:if></td>
                                    </tr>
                                </c:forEach>
                                <c:if test="${empty projectReports}"><tr><td colspan="6" class="text-center text-muted py-3">Dự án này chưa có tệp báo cáo.</td></tr></c:if>
                            </tbody>
                        </table>
                    </div>
                    <c:if test="${sessionScope.user.role == 'ADMIN'}">
                        <div class="text-end mt-2"><a class="btn btn-sm btn-primary" href="${pageContext.request.contextPath}/reports"><i class="bi bi-inbox me-1"></i>Mở hộp thư báo cáo</a></div>
                    </c:if>
                </div>
            </div>
            <div class="modal-footer bg-light">
                <button type="button" class="btn btn-secondary btn-sm" data-bs-dismiss="modal">Đóng</button>
            </div>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>

<!-- Tự động mở Modal khi có tham số viewTasks -->
<c:if test="${showTaskModal}">
<script>
    document.addEventListener("DOMContentLoaded", function() {
        var myModal = new bootstrap.Modal(document.getElementById('tasksModal'));
        myModal.show();
    });
</script>
</c:if>

</body>
</html>
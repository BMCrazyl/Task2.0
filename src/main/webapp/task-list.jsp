<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quản Lý Công Việc</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
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
<div class="offcanvas offcanvas-start bg-dark text-white" tabindex="-1" id="sidebarMenu" aria-labelledby="sidebarMenuLabel" style="width: 280px;">
    <div class="offcanvas-header border-bottom border-secondary py-3">
        <h5 class="offcanvas-title fw-bold text-primary" id="sidebarMenuLabel">
            <i class="bi bi-kanban me-2"></i>Task Manager
        </h5>
        <button type="button" class="btn-close btn-close-white" data-bs-dismiss="offcanvas" aria-label="Close"></button>
    </div>
    
    <div class="offcanvas-body p-0 pt-3">
        <div class="nav flex-column nav-pills px-3 gap-2">
            <a class="nav-link text-white py-2 px-3 rounded d-flex align-items-center gap-3 fs-6" 
               href="${pageContext.request.contextPath}/dashboard">
                <i class="bi bi-speedometer2 fs-5 text-info"></i> Tổng Quan
            </a>
            
            <a class="nav-link text-white py-2 px-3 rounded d-flex align-items-center gap-3 fs-6" 
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
    </div>
</div>

<div class="container pb-5">
    <c:if test="${not empty sessionScope.taskMessage}">
        <div class="alert alert-info alert-dismissible fade show" role="alert">
            <i class="bi bi-info-circle me-2"></i><c:out value="${sessionScope.taskMessage}"/>
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Đóng"></button>
        </div>
        <c:remove var="taskMessage" scope="session"/>
    </c:if>
    <div class="row g-4">
        <!-- Khung Form Thêm / Sửa Công Việc -->
        <div class="col-lg-4">
            <div class="card shadow-sm border-0">
                <div class="card-header ${not empty task ? 'bg-warning text-dark' : 'bg-primary text-white'} py-3">
                    <h5 class="fw-bold mb-0">
                        <i class="bi ${not empty task ? 'bi-pencil-square' : 'bi-file-earmark-plus'} me-2"></i>
                        ${not empty task ? 'Cập Nhật Công Việc' : 'Thêm Công Việc Mới'}
                    </h5>
                </div>
                <div class="card-body p-4">
                    <form action="${pageContext.request.contextPath}/tasks" method="POST">
                        <!-- ID ẩn nhận diện khi sửa -->
                        <input type="hidden" name="id" value="${task.id}">

                        <div class="mb-3">
                            <label class="form-label fw-bold">Tên công việc</label>
                            <input type="text" name="taskName" class="form-control" 
                                   value="${task.taskName}" placeholder="VD: Lập trình API Đăng nhập" required>
                        </div>
                        <div class="mb-3">
                            <label class="form-label fw-bold">Thuộc Dự án</label>
                            <select name="projectId" class="form-select" required>
                                <c:forEach var="p" items="${projectList}">
                                    <option value="${p.id}" ${task.projectId == p.id ? 'selected' : ''}>
                                        ${p.projectName}
                                    </option>
                                </c:forEach>
                            </select>
                        </div>
                        <div class="mb-3">
                            <label class="form-label fw-bold">Hạn chót (Deadline)</label>
                            <input type="date" name="deadline" class="form-control" value="${task.deadline}" required>
                        </div>
                        <div class="mb-3">
                            <label class="form-label fw-bold">Mức độ ưu tiên</label>
                            <select name="priority" class="form-select">
                                <option value="Thấp" ${task.priority == 'Thấp' ? 'selected' : ''}>Thấp</option>
                                <option value="Trung bình" ${empty task || task.priority == 'Trung bình' ? 'selected' : ''}>Trung bình</option>
                                <option value="Cao" ${task.priority == 'Cao' ? 'selected' : ''}>Cao</option>
                            </select>
                        </div>
                        <div class="mb-3">
                            <label class="form-label fw-bold">Trạng thái công việc</label>
                            <select name="status" class="form-select">
                                <option value="Chưa bắt đầu" ${empty task || task.status == 'Chưa bắt đầu' ? 'selected' : ''}>Chưa bắt đầu</option>
                                <option value="Đang thực hiện" ${task.status == 'Đang thực hiện' ? 'selected' : ''}>Đang thực hiện</option>
                                <option value="Hoàn thành" ${task.status == 'Hoàn thành' ? 'selected' : ''}>Hoàn thành</option>
                            </select>
                        </div>
                        <div class="mb-4">
                            <label class="form-label fw-bold">Mô tả công việc</label>
                            <textarea name="description" class="form-control" rows="3" 
                                      placeholder="Chi tiết yêu cầu kỹ thuật...">${task.description}</textarea>
                        </div>
                        
                        <div class="d-flex gap-2">
                            <button type="submit" class="btn ${not empty task ? 'btn-warning fw-bold' : 'btn-primary fw-bold'} w-100">
                                <i class="bi bi-save me-1"></i> ${not empty task ? 'Lưu Cập Nhật' : 'Tạo Công Việc'}
                            </button>
                            <c:if test="${not empty task}">
                                <a href="${pageContext.request.contextPath}/tasks" class="btn btn-outline-secondary">Hủy</a>
                            </c:if>
                        </div>
                    </form>
                </div>
            </div>
        </div>

        <!-- Bảng danh sách công việc -->
        <div class="col-lg-8">
            <div class="card shadow-sm border-0">
                <div class="card-header bg-white py-3 d-flex justify-content-between align-items-center">
                    <div>
                        <h5 class="fw-bold mb-0 text-dark">Danh Sách Công Việc</h5>
                        <span class="badge bg-secondary">${taskList.size()} công việc</span>
                    </div>
                    <form action="${pageContext.request.contextPath}/tasks" method="get" class="d-flex gap-2">
                        <input type="search" name="keyword" class="form-control form-control-sm" style="min-width:180px"
                               value="${searchKeyword}" placeholder="Tìm công việc, dự án, trạng thái...">
                        <button type="submit" class="btn btn-primary btn-sm"><i class="bi bi-search"></i></button>
                        <c:if test="${not empty searchKeyword}"><a href="${pageContext.request.contextPath}/tasks" class="btn btn-outline-secondary btn-sm">Xóa lọc</a></c:if>
                    </form>
                </div>
                <div class="table-responsive">
                    <table class="table table-hover align-middle mb-0">
                        <thead class="table-light">
                            <tr>
                                <th>Tên Task</th>
                                <th>Dự Án</th>
                                <th>Hạn Chót</th>
                                <th>Ưu Tiên</th>
                                <th>Trạng Thái</th>
                                <th class="text-center">Thao Tác</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="t" items="${taskList}">
                                <tr>
                                    <td>
                                        <div class="fw-bold text-primary">${t.taskName}</div>
                                        <small class="text-muted">${t.description}</small>
                                    </td>
                                    <td><span class="badge bg-secondary">${t.projectName}</span></td>
                                    <td>${t.deadline}</td>
                                    <td>
                                        <span class="badge ${t.priority == 'Cao' ? 'bg-danger' : ((t.priority == 'Trung bình' or t.priority == 'Trung binh') ? 'bg-warning text-dark' : ((t.priority == 'Thấp' or t.priority == 'Thap') ? 'bg-success' : 'bg-secondary'))}">
                                            ${t.priority}
                                        </span>
                                    </td>
                                    <td>
                                        <span class="badge ${(t.status == 'Hoàn thành' or t.status == 'Hoan thanh') ? 'bg-success' : ((t.status == 'Đang thực hiện' or t.status == 'Dang thuc hien') ? 'bg-primary' : ((t.status == 'Chưa bắt đầu' or t.status == 'Chua bat dau') ? 'bg-secondary' : 'bg-secondary'))}">
                                            ${t.status}
                                        </span>
                                    </td>
                                    <td class="text-center">
                                        <div class="task-actions">
                                            <button type="button" class="btn btn-outline-info btn-sm task-detail-button"
                                                    data-bs-toggle="modal" data-bs-target="#taskDetailModal"
                                                    data-task-id="${t.id}"
                                                    data-task-name="<c:out value='${t.taskName}'/>"
                                                    data-task-description="<c:out value='${t.description}'/>"
                                                    data-project-name="<c:out value='${t.projectName}'/>"
                                                    data-task-deadline="<c:out value='${t.deadline}'/>"
                                                    data-task-priority="<c:out value='${t.priority}'/>"
                                                    data-task-status="<c:out value='${t.status}'/>"
                                                    data-employee-id="${t.employeeId}"
                                                    data-employee-name="<c:out value='${t.employeeName}'/>"
                                                    title="Xem chi tiết công việc">
                                                <i class="bi bi-eye me-1"></i>Chi tiết
                                            </button>
                                            <a href="${pageContext.request.contextPath}/tasks?action=edit&id=${t.id}"
                                               class="btn btn-outline-warning btn-sm" title="Sửa công việc">
                                                <i class="bi bi-pencil-square me-1"></i>Sửa
                                            </a>
                                            <c:if test="${sessionScope.user.role == 'ADMIN'}">
                                                <form action="${pageContext.request.contextPath}/tasks" method="post" class="d-inline"
                                                      onsubmit="return confirm('Bạn chắc chắn muốn xóa công việc này? Phân công, lịch sử chấm công và báo cáo gắn với công việc có thể bị xóa theo.');">
                                                    <input type="hidden" name="action" value="delete">
                                                    <input type="hidden" name="id" value="${t.id}">
                                                    <input type="hidden" name="keyword" value="<c:out value='${searchKeyword}'/>">
                                                    <button type="submit" class="btn btn-outline-danger btn-sm" title="Xóa công việc">
                                                        <i class="bi bi-trash3 me-1"></i>Xóa
                                                    </button>
                                                </form>
                                            </c:if>
                                        </div>
                                    </td>
                                </tr>
                            </c:forEach>
                            <c:if test="${empty taskList}">
                                <tr>
                                    <td colspan="6" class="text-center py-4 text-muted">Không có công việc đang mở. Công việc hoàn thành được lưu trong lịch sử chấm công/dự án.</td>
                                </tr>
                            </c:if>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- Chi tiết công việc: dữ liệu điền ở phía trình duyệt, không thay đổi luồng lưu/sửa -->
<div class="modal fade" id="taskDetailModal" tabindex="-1" aria-labelledby="taskDetailModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered modal-lg">
        <div class="modal-content task-detail-modal">
            <div class="modal-header align-items-start">
                <div class="pe-3">
                    <div class="small text-muted text-uppercase fw-bold mb-1"><i class="bi bi-card-text me-1"></i>Chi tiết công việc</div>
                    <h5 class="modal-title fw-bold mb-0" id="taskDetailModalLabel">Thông tin công việc</h5>
                </div>
                <button type="button" class="btn-close ms-auto" data-bs-dismiss="modal" aria-label="Đóng"></button>
            </div>
            <div class="modal-body p-4">
                <div class="task-detail-grid">
                    <section class="task-detail-cell">
                        <span class="task-detail-label">Dự án</span>
                        <div class="task-detail-value"><i class="bi bi-folder2-open text-primary me-2"></i><span id="taskDetailProject">—</span></div>
                    </section>
                    <section class="task-detail-cell">
                        <span class="task-detail-label">Người đảm nhận</span>
                        <div class="d-flex align-items-center gap-3">
                            <img id="taskDetailAvatar" class="task-detail-avatar d-none" alt="Ảnh đại diện nhân viên">
                            <div id="taskDetailAvatarFallback" class="task-detail-avatar-placeholder"><i class="bi bi-person-fill"></i></div>
                            <div class="min-w-0">
                                <div id="taskDetailEmployee" class="task-detail-value">Chưa phân công</div>
                                <small id="taskDetailEmployeeCaption" class="text-muted">Nhân viên được giao công việc</small>
                            </div>
                        </div>
                    </section>
                    <section class="task-detail-cell">
                        <span class="task-detail-label">Hạn chót</span>
                        <div class="task-detail-value"><i class="bi bi-calendar-event text-info me-2"></i><span id="taskDetailDeadline">—</span></div>
                    </section>
                    <section class="task-detail-cell">
                        <span class="task-detail-label">Mức độ ưu tiên</span>
                        <div><span id="taskDetailPriority" class="badge bg-secondary">—</span></div>
                    </section>
                    <section class="task-detail-cell">
                        <span class="task-detail-label">Trạng thái</span>
                        <div><span id="taskDetailStatus" class="badge bg-secondary">—</span></div>
                    </section>
                    <section class="task-detail-cell task-detail-description-cell">
                        <span class="task-detail-label">Mô tả công việc</span>
                        <div id="taskDetailDescription" class="task-detail-description">Chưa có mô tả.</div>
                    </section>
                </div>
            </div>
            <div class="modal-footer">
                <a id="taskDetailEditLink" class="btn btn-outline-warning" href="#">
                    <i class="bi bi-pencil-square me-1"></i>Sửa công việc
                </a>
                <button type="button" class="btn btn-primary" data-bs-dismiss="modal">Đóng</button>
            </div>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script>
(function () {
    "use strict";
    var avatarBaseUrl = "${pageContext.request.contextPath}/employee-avatar?id=";
    var modal = document.getElementById("taskDetailModal");
    if (!modal) return;

    modal.addEventListener("show.bs.modal", function (event) {
        var button = event.relatedTarget;
        if (!button) return;
        var data = button.dataset;
        document.getElementById("taskDetailModalLabel").textContent = data.taskName || "Thông tin công việc";
        document.getElementById("taskDetailProject").textContent = data.projectName || "Chưa xác định";
        document.getElementById("taskDetailEmployee").textContent = data.employeeName || "Chưa phân công";
        document.getElementById("taskDetailDeadline").textContent = data.taskDeadline || "Chưa có hạn chót";
        document.getElementById("taskDetailDescription").textContent = data.taskDescription || "Chưa có mô tả.";
        var priority = document.getElementById("taskDetailPriority");
        priority.textContent = data.taskPriority || "Chưa xác định";
        priority.className = "badge " + (data.taskPriority === "Cao" ? "bg-danger" : (data.taskPriority === "Trung bình" || data.taskPriority === "Trung binh" ? "bg-warning text-dark" : (data.taskPriority === "Thấp" || data.taskPriority === "Thap" ? "bg-success" : "bg-secondary")));
        var status = document.getElementById("taskDetailStatus");
        status.textContent = data.taskStatus || "Chưa xác định";
        status.className = "badge " + ((data.taskStatus === "Hoàn thành" || data.taskStatus === "Hoan thanh") ? "bg-success" : ((data.taskStatus === "Đang thực hiện" || data.taskStatus === "Dang thuc hien") ? "bg-primary" : "bg-secondary"));

        var avatar = document.getElementById("taskDetailAvatar");
        var fallback = document.getElementById("taskDetailAvatarFallback");
        var employeeId = Number(data.employeeId || 0);
        avatar.onerror = function () {
            avatar.classList.add("d-none");
            fallback.classList.remove("d-none");
        };
        avatar.onload = function () {
            avatar.classList.remove("d-none");
            fallback.classList.add("d-none");
        };
        if (employeeId > 0) {
            avatar.src = avatarBaseUrl + encodeURIComponent(employeeId);
            document.getElementById("taskDetailEmployeeCaption").textContent = "Nhân viên được giao công việc";
        } else {
            avatar.removeAttribute("src");
            avatar.classList.add("d-none");
            fallback.classList.remove("d-none");
            document.getElementById("taskDetailEmployeeCaption").textContent = "Công việc hiện chưa được phân công";
        }
        document.getElementById("taskDetailEditLink").href =
            "${pageContext.request.contextPath}/tasks?action=edit&id=" + encodeURIComponent(data.taskId || "");
    });
})();
</script>
</body>
</html>
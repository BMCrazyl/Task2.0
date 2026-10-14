<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Hệ Thống Phân Công Công Việc</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    <style>
        .summary-card { cursor: pointer; font: inherit; color: inherit; transition: transform .12s ease, box-shadow .12s ease; }
        .summary-card:hover { transform: translateY(-2px); box-shadow: 0 .35rem 1rem rgba(0,0,0,.10) !important; }
        .summary-card:focus-visible { outline: 3px solid #86b7fe; outline-offset: 3px; }
        .nav-pills .nav-link:hover {
            background-color: rgba(255, 255, 255, 0.1);
        }
        .nav-pills .nav-link.active {
            background-color: #0d6efd !important;
        }
    </style>
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
            <a class="nav-link active text-white py-2 px-3 rounded d-flex align-items-center gap-3 fs-6" 
               href="${pageContext.request.contextPath}/dashboard">
                <i class="bi bi-speedometer2 fs-5 text-info"></i> Tổng Quan
            </a>
            
            <!-- Chỉ Quản Lý (ADMIN) mới thấy các trang quản lý và phân công -->
            <c:if test="${sessionScope.user.role == 'ADMIN'}">
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
                
                <a class="nav-link text-white py-2 px-3 rounded d-flex align-items-center gap-3 fs-6"
                   href="${pageContext.request.contextPath}/reports">
                    <i class="bi bi-file-earmark-check fs-5 text-info"></i> Báo Cáo Nhân Viên
                </a>
            </c:if>
        </div>

            <c:if test="${sessionScope.user.role == 'EMPLOYEE'}">
                <a class="nav-link text-white py-2 px-3 rounded d-flex align-items-center gap-3 fs-6"
                   href="${pageContext.request.contextPath}/attendance">
                    <i class="bi bi-calendar2-check fs-5 text-success"></i> Chấm công công việc
                </a>
            </c:if>

        <!-- Khối thông tin tài khoản & nút Đăng Xuất ở đáy Sidebar -->
        <div class="mt-auto p-3 border-top border-secondary">
            <div class="d-flex align-items-center mb-2">
                <c:choose>
                    <c:when test="${sessionScope.user.role == 'EMPLOYEE' and not empty currentEmployee.avatarContentType}">
                        <a href="${pageContext.request.contextPath}/profile" class="me-2 flex-shrink-0" aria-label="Mở hồ sơ cá nhân">
                            <img src="${pageContext.request.contextPath}/employee-avatar?self=1" alt="Ảnh đại diện"
                                 class="rounded-circle border border-info" style="width:36px;height:36px;object-fit:cover">
                        </a>
                    </c:when>
                    <c:when test="${sessionScope.user.role == 'EMPLOYEE'}">
                        <a href="${pageContext.request.contextPath}/profile" class="me-2 flex-shrink-0 text-info fs-3" aria-label="Mở hồ sơ cá nhân">
                            <i class="bi bi-person-circle"></i>
                        </a>
                    </c:when>
                    <c:otherwise>
                        <i class="bi bi-person-circle fs-3 me-2 text-info"></i>
                    </c:otherwise>
                </c:choose>
                <div class="overflow-hidden">
                    <div class="fw-bold text-truncate" style="max-width: 170px;">
                        <c:choose>
                            <c:when test="${sessionScope.user.role == 'EMPLOYEE'}">
                                <a href="${pageContext.request.contextPath}/profile" class="text-white text-decoration-none" title="Xem hồ sơ cá nhân">
                                    ${not empty sessionScope.user.fullname ? sessionScope.user.fullname : 'Nhân Viên'}
                                </a>
                            </c:when>
                            <c:otherwise>
                                ${not empty sessionScope.user.fullname ? sessionScope.user.fullname : 'Người Dùng'}
                            </c:otherwise>
                        </c:choose>
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

    <!-- Các thẻ thống kê có thể bấm để xem danh sách chi tiết -->
    <div class="row g-3 mb-4">
        <div class="col-md-4">
            <button type="button" class="card summary-card shadow-sm border-0 border-start border-success border-4 p-3 bg-white w-100 text-start"
                    data-bs-toggle="modal" data-bs-target="#completedDetailsModal" aria-label="Xem chi tiết công việc hoàn thành">
                <div class="d-flex justify-content-between align-items-center">
                    <div><span class="text-muted text-uppercase fw-semibold small">Công việc Hoàn thành</span>
                        <h2 class="fw-bold text-success mb-0">${completedCount}</h2><small class="text-muted">Bấm để xem chi tiết</small></div>
                    <div class="bg-success-subtle text-success p-3 rounded-circle"><i class="bi bi-check2-all fs-2"></i></div>
                </div>
            </button>
        </div>
        <div class="col-md-4">
            <button type="button" class="card summary-card shadow-sm border-0 border-start border-primary border-4 p-3 bg-white w-100 text-start"
                    data-bs-toggle="modal" data-bs-target="#inProgressDetailsModal" aria-label="Xem chi tiết công việc đang thực hiện">
                <div class="d-flex justify-content-between align-items-center">
                    <div><span class="text-muted text-uppercase fw-semibold small">Đang thực hiện</span>
                        <h2 class="fw-bold text-primary mb-0">${inProgressCount}</h2><small class="text-muted">Bấm để xem chi tiết</small></div>
                    <div class="bg-primary-subtle text-primary p-3 rounded-circle"><i class="bi bi-hourglass-split fs-2"></i></div>
                </div>
            </button>
        </div>
        <div class="col-md-4">
            <button type="button" class="card summary-card shadow-sm border-0 border-start border-danger border-4 p-3 bg-white w-100 text-start"
                    data-bs-toggle="modal" data-bs-target="#overdueDetailsModal" aria-label="Xem chi tiết công việc quá hạn">
                <div class="d-flex justify-content-between align-items-center">
                    <div><span class="text-muted text-uppercase fw-semibold small">Đã quá hạn</span>
                        <h2 class="fw-bold text-danger mb-0">${overdueTasks != null ? overdueTasks : 0}</h2><small class="text-muted">Bấm để xem chi tiết</small></div>
                    <div class="bg-danger-subtle text-danger p-3 rounded-circle"><i class="bi bi-calendar-x fs-2"></i></div>
                </div>
            </button>
        </div>
    </div>

    <!-- Khối tìm kiếm lọc đa tiêu chí -->
    <div class="card border-0 shadow-sm mb-4">
        <div class="card-body p-3">
            <form action="${pageContext.request.contextPath}/dashboard" method="GET" class="row g-2">
                <!-- Chỉ Admin mới có ô tìm theo tên nhân viên -->
                <c:if test="${sessionScope.user.role == 'ADMIN'}">
                    <div class="col-md-4">
                        <input type="text" name="empName" class="form-control" placeholder="Tìm theo tên nhân viên..." value="${param.empName}">
                    </div>
                </c:if>
                
                <!-- Nhân viên thì ô dự án tự động giãn rộng 8 cột -->
                <div class="${sessionScope.user.role == 'ADMIN' ? 'col-md-4' : 'col-md-8'}">
                    <input type="text" name="projectName" class="form-control" placeholder="Tìm theo tên dự án..." value="${param.projectName}">
                </div>
                
                <div class="col-md-3">
                    <select name="status" class="form-select">
                        <option value="">-- Tất cả --</option>
                        <option value="Chưa bắt đầu" ${param.status == 'Chưa bắt đầu' ? 'selected' : ''}>Chưa bắt đầu</option>
                        <option value="Đang thực hiện" ${param.status == 'Đang thực hiện' ? 'selected' : ''}>Đang thực hiện</option>
                        <option value="Hoàn thành" ${param.status == 'Hoàn thành' ? 'selected' : ''}>Hoàn thành</option>
                    </select>
                </div>
                <div class="col-md-1">
                    <button type="submit" class="btn btn-primary w-100"><i class="bi bi-search"></i></button>
                </div>
            </form>
        </div>
    </div>

    <!-- Danh sách hiển thị -->
    <div class="card border-0 shadow-sm">
        <div class="card-header bg-white py-3 d-flex justify-content-between align-items-center">
            <h5 class="fw-bold mb-0 text-dark">
                ${sessionScope.user.role == 'ADMIN' ? 'Tiến Độ Công Việc Toàn Bộ' : 'Công Việc Được Giao Cho Tôi'}
            </h5>
            <!-- Chỉ Quản Lý mới thấy nút Phân công mới -->
            <c:if test="${sessionScope.user.role == 'ADMIN'}">
                <a href="${pageContext.request.contextPath}/assign" class="btn btn-primary btn-sm">
                    <i class="bi bi-plus-lg me-1"></i>Phân công mới
                </a>
            </c:if>
        </div>
        <div class="table-responsive">
            <table class="table table-hover align-middle mb-0">
                <thead class="table-light">
                    <tr>
                        <th>#</th>
                        <th>Công Việc</th>
                        <th>Dự Án</th>
                        <th>Người Phụ Trách</th>
                        <th>Hạn Chót</th>
                        <th>Mức Ưu Tiên</th>
                        <th>Trạng Thái</th>
                    </tr>
                </thead>
                <tbody>
                    <c:choose>
                        <c:when test="${not empty taskList}">
                            <c:forEach var="t" items="${taskList}" varStatus="rowStatus">
                                <tr>
                                    <td><strong>#${rowStatus.index + 1}</strong></td>
                                    <td>
                                        <div class="fw-bold">${t.taskName}</div>
                                        <small class="text-muted">${t.description}</small>
                                    </td>
                                    <td><span class="badge bg-secondary">${t.projectName}</span></td>
                                    <td>
                                        <c:set var="name" value="${not empty t.employeeName ? t.employeeName : t.assignedEmployee}" />
                                        <c:choose>
                                            <c:when test="${not empty name and name != '' and name != 'Chưa phân công'}">
                                                <span class="badge bg-info text-dark">
                                                    <i class="bi bi-person-fill me-1"></i>${name}
                                                </span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="badge bg-light text-muted border">
                                                    <i class="bi bi-person me-1"></i>Chưa phân công
                                                </span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td>${t.deadline}</td>
                                    <td>
                                        <span class="badge ${t.priority == 'Cao' ? 'bg-danger' : ((t.priority == 'Trung bình' or t.priority == 'Trung binh') ? 'bg-warning text-dark' : ((t.priority == 'Thấp' or t.priority == 'Thap') ? 'bg-success' : 'bg-secondary'))}">
                                            ${t.priority}
                                        </span>
                                    </td>
                                    <td>
                                        <span class="badge ${t.status == 'Hoàn thành' ? 'bg-success' : (t.status == 'Đang thực hiện' ? 'bg-primary' : 'bg-secondary')}">
                                            ${t.status}
                                        </span>
                                    </td>
                                </tr>
                            </c:forEach>
                        </c:when>
                        <c:otherwise>
                            <tr>
                                <td colspan="7" class="text-center py-4 text-muted">Không tìm thấy bản ghi nào.</td>
                            </tr>
                        </c:otherwise>
                    </c:choose>
                </tbody>
            </table>
        </div>
    </div>
</div>


<!-- Chi tiết công việc hoàn thành -->
<div class="modal fade" id="completedDetailsModal" tabindex="-1" aria-labelledby="completedDetailsModalLabel" aria-hidden="true">
 <div class="modal-dialog modal-xl modal-dialog-scrollable"><div class="modal-content">
  <div class="modal-header bg-success-subtle"><div><h5 class="modal-title fw-bold" id="completedDetailsModalLabel">Chi tiết công việc hoàn thành</h5><small class="text-muted">${completedCount} công việc</small></div><button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Đóng"></button></div>
  <div class="modal-body p-0"><div class="table-responsive"><table class="table table-hover align-middle mb-0">
   <thead class="table-light"><tr><th>#</th><th>Nhân viên</th><th>Công việc</th><th>Dự án</th><th>Hạn chót</th><th>Trạng thái</th></tr></thead><tbody>
    <c:forEach var="detail" items="${completedDetails}" varStatus="completedRow"><tr><td>#${completedRow.index + 1}</td><td>${not empty detail.employeeName ? detail.employeeName : 'Chưa phân công'}</td><td><div class="fw-semibold">${detail.taskName}</div><small class="text-muted">${detail.description}</small></td><td>${detail.projectName}</td><td>${detail.deadline}</td><td><span class="badge bg-success">Hoàn thành</span></td></tr></c:forEach>
    <c:if test="${empty completedDetails}"><tr><td colspan="6" class="text-center text-muted py-4">Chưa có công việc hoàn thành.</td></tr></c:if>
   </tbody></table></div></div>
  <div class="modal-footer"><button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Đóng</button></div>
 </div></div>
</div>

<!-- Chi tiết công việc đang thực hiện -->
<div class="modal fade" id="inProgressDetailsModal" tabindex="-1" aria-labelledby="inProgressDetailsModalLabel" aria-hidden="true">
 <div class="modal-dialog modal-xl modal-dialog-scrollable"><div class="modal-content">
  <div class="modal-header bg-primary-subtle"><div><h5 class="modal-title fw-bold" id="inProgressDetailsModalLabel">Chi tiết công việc đang thực hiện</h5><small class="text-muted">${inProgressCount} công việc</small></div><button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Đóng"></button></div>
  <div class="modal-body p-0"><div class="table-responsive"><table class="table table-hover align-middle mb-0">
   <thead class="table-light"><tr><th>#</th><th>Nhân viên</th><th>Công việc</th><th>Dự án</th><th>Hạn chót</th><th>Ưu tiên</th><th>Trạng thái</th></tr></thead><tbody>
    <c:forEach var="detail" items="${inProgressDetails}" varStatus="progressRow"><tr><td>#${progressRow.index + 1}</td><td>${not empty detail.employeeName ? detail.employeeName : 'Chưa phân công'}</td><td><div class="fw-semibold">${detail.taskName}</div><small class="text-muted">${detail.description}</small></td><td>${detail.projectName}</td><td>${detail.deadline}</td><td><span class="badge ${detail.priority == 'Cao' ? 'bg-danger' : ((detail.priority == 'Trung bình' or detail.priority == 'Trung binh') ? 'bg-warning text-dark' : ((detail.priority == 'Thấp' or detail.priority == 'Thap') ? 'bg-success' : 'bg-secondary'))}">${detail.priority}</span></td><td><span class="badge bg-primary">${detail.status}</span></td></tr></c:forEach>
    <c:if test="${empty inProgressDetails}"><tr><td colspan="7" class="text-center text-muted py-4">Không có công việc đang thực hiện.</td></tr></c:if>
   </tbody></table></div></div>
  <div class="modal-footer"><button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Đóng</button></div>
 </div></div>
</div>

<!-- Chi tiết công việc quá hạn -->
<div class="modal fade" id="overdueDetailsModal" tabindex="-1" aria-labelledby="overdueDetailsModalLabel" aria-hidden="true">
 <div class="modal-dialog modal-xl modal-dialog-scrollable"><div class="modal-content">
  <div class="modal-header bg-danger-subtle"><div><h5 class="modal-title fw-bold" id="overdueDetailsModalLabel">Chi tiết công việc quá hạn</h5><small class="text-muted">${overdueTasks != null ? overdueTasks : 0} công việc</small></div><button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Đóng"></button></div>
  <div class="modal-body p-0"><div class="table-responsive"><table class="table table-hover align-middle mb-0">
   <thead class="table-light"><tr><th>#</th><th>Nhân viên</th><th>Công việc</th><th>Dự án</th><th>Hạn chót</th><th>Trạng thái</th></tr></thead><tbody>
    <c:forEach var="detail" items="${overdueDetails}" varStatus="overdueRow"><tr><td>#${overdueRow.index + 1}</td><td>${not empty detail.employeeName ? detail.employeeName : 'Chưa phân công'}</td><td><div class="fw-semibold">${detail.taskName}</div><small class="text-muted">${detail.description}</small></td><td>${detail.projectName}</td><td class="text-danger fw-semibold">${detail.deadline}</td><td><span class="badge bg-danger">Quá hạn</span><div><small class="text-muted">Trạng thái: ${detail.status}</small></div></td></tr></c:forEach>
    <c:if test="${empty overdueDetails}"><tr><td colspan="6" class="text-center text-muted py-4">Không có công việc quá hạn.</td></tr></c:if>
   </tbody></table></div></div>
  <div class="modal-footer"><button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Đóng</button></div>
 </div></div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Chấm công công việc | Task Manager</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    <script>(function(){try{var t=localStorage.getItem("taskmanager-theme");document.documentElement.setAttribute("data-theme",t==="light"?"light":"dark");}catch(e){document.documentElement.setAttribute("data-theme","dark");}})();</script>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/taskmanager-theme.css">
    <script defer src="${pageContext.request.contextPath}/assets/taskmanager-theme.js"></script>
</head>
<body class="bg-light">
<nav class="navbar navbar-dark bg-dark shadow-sm">
    <div class="container">
        <a class="navbar-brand fw-bold" href="${pageContext.request.contextPath}/dashboard">
            <i class="bi bi-kanban me-2 text-info"></i>Task Manager
        </a>
        <span class="text-white-50">Xin chào, ${sessionScope.user.fullname}</span>
    </div>
</nav>
<main class="container py-4">
    <div class="d-flex flex-wrap justify-content-between align-items-center mb-4 gap-2">
        <div>
            <h2 class="fw-bold mb-1">Chấm công công việc</h2>
            <p class="text-muted mb-0">Xác nhận hoàn thành công việc được giao. Trạng thái sẽ đồng bộ sang bảng quản lý.</p>
        </div>
        <a class="btn btn-outline-secondary" href="${pageContext.request.contextPath}/dashboard">
            <i class="bi bi-arrow-left me-1"></i>Quay lại tổng quan
        </a>
    </div>

    <c:if test="${not empty sessionScope.attendanceMessage}">
        <div class="alert alert-info alert-dismissible fade show" role="alert">
            ${sessionScope.attendanceMessage}
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Đóng"></button>
        </div>
        <c:remove var="attendanceMessage" scope="session"/>
    </c:if>

    <div class="card border-0 shadow-sm">
        <div class="card-header bg-white py-3 d-flex justify-content-between align-items-center">
            <h5 class="fw-bold mb-0">Công việc được giao</h5>
            <span class="badge text-bg-primary">${taskList.size()} công việc</span>
        </div>
        <div class="table-responsive">
            <table class="table table-hover align-middle mb-0">
                <thead class="table-light">
                    <tr>
                        <th>Công việc</th><th>Dự án</th><th>Hạn chót</th>
                        <th>Ưu tiên</th><th>Trạng thái</th><th>Thời điểm chấm công</th><th>Thao tác</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="t" items="${taskList}">
                        <tr>
                            <td>
                                <div class="fw-semibold">${t.taskName}</div>
                                <small class="text-muted">${t.description}</small>
                            </td>
                            <td>${t.projectName}</td>
                            <td>${t.deadline}</td>
                            <td><span class="badge ${(t.priority == 'Cao') ? 'text-bg-danger' : ((t.priority == 'Trung bình' or t.priority == 'Trung binh') ? 'text-bg-warning' : ((t.priority == 'Thấp' or t.priority == 'Thap') ? 'text-bg-success' : 'text-bg-secondary'))}">${t.priority}</span></td>
                            <td>
                                <span class="badge ${(t.status == 'Hoàn thành' or t.status == 'Hoan thanh') ? 'text-bg-success' : ((t.status == 'Đang thực hiện' or t.status == 'Dang thuc hien') ? 'text-bg-primary' : 'text-bg-secondary')}">${t.status}</span>
                            </td>
                            <td>${not empty t.checkedAt ? t.checkedAt : 'Chưa chấm công'}</td>
                            <td>
                                <c:choose>
                                    <c:when test="${t.status == 'Hoàn thành' or t.status == 'Hoan thanh'}">
                                        <button class="btn btn-sm btn-success" disabled><i class="bi bi-check2-circle me-1"></i>Đã hoàn thành</button>
                                    </c:when>
                                    <c:otherwise>
                                        <form method="post" action="${pageContext.request.contextPath}/attendance" class="d-inline"
                                              onsubmit="return confirm('Xác nhận bạn đã hoàn thành công việc này?');">
                                            <input type="hidden" name="taskId" value="${t.id}">
                                            <button class="btn btn-sm btn-primary mb-1" type="submit">
                                                <i class="bi bi-calendar2-check me-1"></i>Chấm công hoàn thành
                                            </button>
                                        </form>
                                    </c:otherwise>
                                </c:choose>
                                <form method="post" action="${pageContext.request.contextPath}/attendance" enctype="multipart/form-data" class="mt-2 border rounded p-2 bg-light">
                                    <input type="hidden" name="action" value="uploadReport">
                                    <input type="hidden" name="taskId" value="${t.id}">
                                    <label class="form-label small fw-semibold mb-1"><i class="bi bi-paperclip me-1"></i>Gửi file báo cáo</label>
                                    <input class="form-control form-control-sm mb-2" type="file" name="reportFile"
                                           accept=".pdf,.doc,.docx,.xls,.xlsx,.csv,.txt,.png,.jpg,.jpeg,.zip" required>
                                    <button class="btn btn-sm btn-outline-primary w-100" type="submit">
                                        <i class="bi bi-cloud-arrow-up me-1"></i>Gửi báo cáo
                                    </button>
                                    <small class="text-muted d-block mt-1">Tối đa 10 MB; báo cáo gắn với công việc và dự án.</small>
                                </form>
                            </td>
                        </tr>
                    </c:forEach>
                    <c:if test="${empty taskList}">
                        <tr><td colspan="7" class="text-center py-5 text-muted">
                            Bạn chưa được phân công công việc nào.
                        </td></tr>
                    </c:if>
                </tbody>
            </table>
        </div>
    </div>
    <p class="small text-muted mt-3"><i class="bi bi-info-circle me-1"></i>Chấm công ở đây là xác nhận hoàn thành nhiệm vụ, không phải ghi nhận giờ vào/ra ca làm việc.</p>
</main>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>

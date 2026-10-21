<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi"><head>
<meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1">
<title>Tiếp nhận báo cáo | Task Manager</title>
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    <script>(function(){try{var t=localStorage.getItem("taskmanager-theme");document.documentElement.setAttribute("data-theme",t==="light"?"light":"dark");}catch(e){document.documentElement.setAttribute("data-theme","dark");}})();</script>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/taskmanager-theme.css">
    <script defer src="${pageContext.request.contextPath}/assets/taskmanager-theme.js"></script>
</head><body class="bg-light">
<nav class="navbar navbar-dark bg-dark"><div class="container">
<a class="navbar-brand fw-bold" href="${pageContext.request.contextPath}/dashboard"><i class="bi bi-kanban me-2 text-info"></i>Task Manager</a>
<a class="btn btn-outline-light btn-sm" href="${pageContext.request.contextPath}/dashboard">Quay lại tổng quan</a>
</div></nav>
<main class="container py-4">
<div class="d-flex flex-wrap justify-content-between align-items-center gap-2 mb-4">
<div><h2 class="fw-bold mb-1">Báo cáo từ nhân viên</h2><p class="text-muted mb-0">Xem, tải tệp và xác nhận đã tiếp nhận báo cáo.</p></div>
<span class="badge text-bg-primary fs-6">${reportList.size()} báo cáo</span>
</div>
<c:if test="${not empty sessionScope.reportMessage}"><div class="alert alert-info">${sessionScope.reportMessage}</div><c:remove var="reportMessage" scope="session"/></c:if>
<form method="get" action="${pageContext.request.contextPath}/reports" class="card card-body border-0 shadow-sm mb-3">
<div class="input-group"><input class="form-control" type="search" name="keyword" value="${searchKeyword}" placeholder="Tìm theo dự án, công việc, nhân viên hoặc tên tệp...">
<button class="btn btn-primary" type="submit"><i class="bi bi-search me-1"></i>Tìm kiếm</button>
<a class="btn btn-outline-secondary" href="${pageContext.request.contextPath}/reports">Xóa lọc</a></div>
</form>
<div class="card border-0 shadow-sm"><div class="table-responsive"><table class="table table-hover align-middle mb-0">
<thead class="table-light"><tr><th>Tệp báo cáo</th><th>Dự án / Công việc</th><th>Nhân viên</th><th>Ngày gửi</th><th>Trạng thái</th><th>Thao tác</th></tr></thead>
<tbody>
<c:forEach var="r" items="${reportList}">
<tr>
<td><i class="bi bi-file-earmark-text text-primary me-2"></i><strong>${r.originalFileName}</strong><small class="d-block text-muted">${r.fileSize} bytes</small></td>
<td><strong>${r.projectName}</strong><small class="d-block text-muted">${r.taskName}</small></td>
<td>${r.employeeName}</td><td>${r.submittedAt}</td>
<td><span class="badge ${r.reviewStatus == 'Đã tiếp nhận' ? 'text-bg-success' : 'text-bg-warning'}">${r.reviewStatus}</span>
<c:if test="${not empty r.receivedBy}"><small class="d-block text-muted">Bởi ${r.receivedBy} · ${r.receivedAt}</small></c:if></td>
<td><div class="d-flex flex-wrap gap-2">
<a class="btn btn-sm btn-outline-primary" href="${pageContext.request.contextPath}/reports?action=download&id=${r.id}"><i class="bi bi-download me-1"></i>Tải file</a>
<c:if test="${r.reviewStatus != 'Đã tiếp nhận'}"><form method="post" action="${pageContext.request.contextPath}/reports" onsubmit="return confirm('Xác nhận đã tiếp nhận báo cáo này?');">
<input type="hidden" name="id" value="${r.id}"><button class="btn btn-sm btn-success" type="submit"><i class="bi bi-check2-circle me-1"></i>Tiếp nhận</button></form></c:if>
</div></td>
</tr>
</c:forEach>
<c:if test="${empty reportList}"><tr><td colspan="6" class="text-center text-muted py-5">Chưa có báo cáo nào phù hợp.</td></tr></c:if>
</tbody></table></div></div>
</main></body></html>

<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Phân Công Công Việc</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    <style>
        .nav-pills .nav-link:hover {
            background-color: rgba(255, 255, 255, 0.1);
        }
        .nav-pills .nav-link.active {
            background-color: #0d6efd !important;
        }
        .autocomplete-menu {
            position: absolute;
            top: 4.35rem;
            left: 0;
            right: 0;
            z-index: 1080;
            max-height: 240px;
            overflow-y: auto;
            width: 100%;
            background: #fff;
            border: 1px solid #ced4da;
            border-radius: .5rem;
            box-shadow: 0 .5rem 1rem rgba(0,0,0,.12);
            padding: .25rem;
        }
        .autocomplete-option {
            display: block;
            width: 100%;
            padding: .55rem .75rem;
            border: 0;
            border-radius: .35rem;
            background: transparent;
            text-align: left;
            color: #212529;
        }
        .autocomplete-option:hover, .autocomplete-option:focus {
            background: #e7f1ff;
            outline: none;
        }
        .autocomplete-empty { padding: .65rem .75rem; color: #6c757d; }
        #taskSelect:disabled { background-color: #e9ecef; }
    </style>
    <script>(function(){try{var t=localStorage.getItem("taskmanager-theme");document.documentElement.setAttribute("data-theme",t==="light"?"light":"dark");}catch(e){document.documentElement.setAttribute("data-theme","dark");}})();</script>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/taskmanager-theme.css">
    <script defer src="${pageContext.request.contextPath}/assets/taskmanager-theme.js"></script>
</head>
<body class="bg-light">

<!-- Navbar với nút 3 gạch nằm sát mép trái -->
<nav class="navbar navbar-dark bg-dark mb-4 shadow-sm py-2">
    <div class="container-fluid px-3">
        <button class="btn btn-outline-light border-0 fs-4 me-2" type="button" 
                data-bs-toggle="offcanvas" data-bs-target="#sidebarMenu" aria-controls="sidebarMenu" title="Mở danh mục">
            <i class="bi bi-list"></i>
        </button>

        <a class="navbar-brand fw-bold me-auto" href="${pageContext.request.contextPath}/dashboard">
            <i class="bi bi-kanban me-2 text-primary"></i>Task Manager
        </a>
    </div>
</nav>

<!-- Sidebar danh sách hàng dọc trượt ra từ bên trái -->
<div class="offcanvas offcanvas-start bg-dark text-white" tabindex="-1" id="sidebarMenu" aria-labelledby="sidebarMenuLabel" style="width: 270px;">
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
            
            <a class="nav-link active text-white py-2 px-3 rounded d-flex align-items-center gap-3 fs-6" 
               href="${pageContext.request.contextPath}/assign">
                <i class="bi bi-person-check fs-5"></i> Phân Công
            </a>
        </div>
    </div>
</div>

<div class="container pb-5">
    <div class="row justify-content-center">
        <div class="col-md-6">
            <div class="card shadow-sm border-0">
                <div class="card-header bg-primary text-white py-3">
                    <h5 class="fw-bold mb-0">
                        <i class="bi bi-person-check me-2"></i>Phân Công Việc Cho Nhân Viên
                    </h5>
                </div>
                <div class="card-body p-4">
                    <form action="${pageContext.request.contextPath}/assign" method="POST">
                        <div class="mb-3 position-relative">
                            <label class="form-label fw-bold" for="projectSearch">Dự án</label>
                            <input type="search" id="projectSearch" class="form-control"
                                   placeholder="Nhập tên dự án để tìm..." autocomplete="off" aria-autocomplete="list" aria-expanded="false" required>
                            <input type="hidden" id="projectId" name="projectId">
                            <div id="projectSuggestions" class="autocomplete-menu d-none" role="listbox" aria-label="Danh sách dự án">
                                <c:forEach var="p" items="${projectList}">
                                    <button type="button" class="autocomplete-option project-option" data-id="${p.id}" role="option">${p.projectName}</button>
                                </c:forEach>
                                <c:if test="${empty projectList}"><div class="autocomplete-empty">Chưa có dự án đang hoạt động.</div></c:if>
                            </div>
                            <small class="text-muted">Nhập để lọc dự án; để trống ô tìm kiếm sẽ hiện tất cả dự án.</small>
                        </div>

                        <div class="mb-3">
                            <label class="form-label fw-bold" for="taskSelect">Công việc</label>
                            <select name="taskId" id="taskSelect" class="form-select" required disabled>
                                <option value="">-- Chọn dự án trước --</option>
                                <c:forEach var="t" items="${taskList}">
                                    <option value="${t.id}" data-project-id="${t.projectId}">${t.taskName}</option>
                                </c:forEach>
                            </select>
                            <small id="taskHelp" class="text-muted">Chọn dự án để xem các công việc đang mở thuộc dự án đó.</small>
                        </div>

                        <div class="mb-3 position-relative">
                            <label class="form-label fw-bold" for="employeeSearch">Nhân viên được phân công</label>
                            <input type="search" id="employeeSearch" class="form-control"
                                   placeholder="Nhập tên, email hoặc chức vụ để tìm..." autocomplete="off" aria-autocomplete="list" aria-expanded="false" required>
                            <input type="hidden" id="employeeId" name="employeeId">
                            <div id="employeeSuggestions" class="autocomplete-menu d-none" role="listbox" aria-label="Danh sách nhân viên">
                                <c:forEach var="e" items="${employeeList}">
                                    <button type="button" class="autocomplete-option employee-option" data-id="${e.id}" role="option">
                                        <span class="option-label">${e.name} - ${e.position}</span>
                                        <span class="d-none">${e.email} ${e.phone} ${e.position}</span>
                                    </button>
                                </c:forEach>
                                <c:if test="${empty employeeList}"><div class="autocomplete-empty">Chưa có hồ sơ nhân viên.</div></c:if>
                            </div>
                            <small class="text-muted">Để trống ô tìm kiếm sẽ hiện tất cả nhân viên; hãy chọn một nhân viên từ gợi ý.</small>
                        </div>
                        <div class="mb-4">
                            <label class="form-label fw-bold">Ngày phân công</label>
                            <input type="date" name="assignedDate" class="form-control" required>
                        </div>

                        <div class="d-flex gap-2">
                            <button type="submit" class="btn btn-primary w-100 fw-bold py-2">
                                <i class="bi bi-check-circle me-1"></i> Xác Nhận Phân Công
                            </button>
                            <a href="${pageContext.request.contextPath}/dashboard" class="btn btn-outline-secondary px-4 d-flex align-items-center">
                                Quay lại
                            </a>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script>
document.addEventListener("DOMContentLoaded", function () {
    const form = document.querySelector('form[action$="/assign"]');
    const projectSearch = document.getElementById("projectSearch");
    const projectIdInput = document.getElementById("projectId");
    const projectMenu = document.getElementById("projectSuggestions");
    const taskSelect = document.getElementById("taskSelect");
    const taskHelp = document.getElementById("taskHelp");
    const employeeSearch = document.getElementById("employeeSearch");
    const employeeIdInput = document.getElementById("employeeId");
    const employeeMenu = document.getElementById("employeeSuggestions");

    function normalize(value) {
        return (value || "").normalize("NFD").replace(/[\u0300-\u036f]/g, "").toLocaleLowerCase("vi").trim();
    }

    function openMenu(input, menu) {
        menu.classList.remove("d-none");
        input.setAttribute("aria-expanded", "true");
        filterOptions(input, menu);
    }

    function closeMenu(input, menu) {
        menu.classList.add("d-none");
        input.setAttribute("aria-expanded", "false");
    }

    function filterOptions(input, menu) {
        const query = normalize(input.value);
        const options = Array.from(menu.querySelectorAll(".autocomplete-option"));
        let visibleCount = 0;
        options.forEach(function (option) {
            const visible = query === "" || normalize(option.textContent).includes(query);
            option.classList.toggle("d-none", !visible);
            if (visible) visibleCount++;
        });
        const empty = menu.querySelector(".autocomplete-empty");
        if (empty) empty.classList.toggle("d-none", visibleCount > 0);
        menu.classList.remove("d-none");
    }

    function refreshTasks() {
        const projectId = projectIdInput.value;
        const options = Array.from(taskSelect.querySelectorAll("option[data-project-id]"));
        let matchCount = 0;
        options.forEach(function (option) {
            const visible = projectId !== "" && option.dataset.projectId === projectId;
            option.hidden = !visible;
            if (visible) matchCount++;
        });
        taskSelect.value = "";
        taskSelect.disabled = projectId === "" || matchCount === 0;
        taskSelect.options[0].textContent = projectId === ""
            ? "-- Chọn dự án trước --"
            : (matchCount === 0 ? "-- Dự án chưa có công việc đang mở --" : "-- Chọn công việc --");
        taskHelp.textContent = projectId === ""
            ? "Chọn dự án để xem các công việc đang mở thuộc dự án đó."
            : (matchCount === 0 ? "Dự án này hiện không có công việc đang mở để phân công." : "Danh sách chỉ hiển thị công việc thuộc dự án đã chọn.");
    }

    projectSearch.addEventListener("focus", function () { openMenu(projectSearch, projectMenu); });
    projectSearch.addEventListener("input", function () {
        projectIdInput.value = "";
        projectSearch.setCustomValidity("");
        refreshTasks();
        filterOptions(projectSearch, projectMenu);
    });
    projectMenu.addEventListener("click", function (event) {
        const option = event.target.closest(".project-option");
        if (!option) return;
        projectIdInput.value = option.dataset.id;
        projectSearch.value = option.textContent.trim();
        projectSearch.setCustomValidity("");
        closeMenu(projectSearch, projectMenu);
        refreshTasks();
    });

    employeeSearch.addEventListener("focus", function () { openMenu(employeeSearch, employeeMenu); });
    employeeSearch.addEventListener("input", function () {
        employeeIdInput.value = "";
        employeeSearch.setCustomValidity("");
        filterOptions(employeeSearch, employeeMenu);
    });
    employeeMenu.addEventListener("click", function (event) {
        const option = event.target.closest(".employee-option");
        if (!option) return;
        employeeIdInput.value = option.dataset.id;
        const label = option.querySelector(".option-label");
        employeeSearch.value = label ? label.textContent.trim() : option.textContent.trim();
        employeeSearch.setCustomValidity("");
        closeMenu(employeeSearch, employeeMenu);
    });

    document.addEventListener("click", function (event) {
        if (!projectMenu.contains(event.target) && event.target !== projectSearch) closeMenu(projectSearch, projectMenu);
        if (!employeeMenu.contains(event.target) && event.target !== employeeSearch) closeMenu(employeeSearch, employeeMenu);
    });

    form.addEventListener("submit", function (event) {
        if (!projectIdInput.value) {
            event.preventDefault();
            projectSearch.setCustomValidity("Vui lòng chọn dự án từ danh sách gợi ý.");
            projectSearch.reportValidity();
            return;
        }
        if (!taskSelect.value) {
            event.preventDefault();
            taskSelect.setCustomValidity("Vui lòng chọn một công việc thuộc dự án đã chọn.");
            taskSelect.reportValidity();
            return;
        }
        taskSelect.setCustomValidity("");
        if (!employeeIdInput.value) {
            event.preventDefault();
            employeeSearch.setCustomValidity("Vui lòng chọn nhân viên từ danh sách gợi ý.");
            employeeSearch.reportValidity();
        }
    });

    taskSelect.addEventListener("change", function () { taskSelect.setCustomValidity(""); });
    refreshTasks();
});
</script>
</body>
</html>
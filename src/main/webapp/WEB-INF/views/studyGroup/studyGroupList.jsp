<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
<%
    response.setHeader("Cache-Control","no-store");
    response.setHeader("Pragma","no-cache");
    response.setDateHeader("Expires",0);
    if (request.getProtocol().equals("HTTP/1.1"))
        response.setHeader("Cache-Control", "no-cache");
%>

<c:set var="root" value="${pageContext.request.contextPath }"/>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>내 스터디 > 스터디 > 공부 > All's</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    <link rel="stylesheet" href="${root}/resources/css/common.css?after">
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.5.1/jquery.min.js"></script>
    <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
    <script type="text/javascript" src="${root}/resources/js/common.js" charset="UTF-8" defer></script>
    <script>

        //검색 버튼
        function searchPosts() {
            let searchKeyword = document.getElementById('searchInput').value;
            let searchOption = document.getElementById('searchOption').value;

            location.href = "${root}/studyGroup/studyGroupList?searchKeyword=" + searchKeyword + "&searchOption=" + searchOption;
        }

        document.addEventListener("DOMContentLoaded", function () {
            var searchInput = document.getElementById("searchInput");
            searchInput.addEventListener("keypress", function (event) {
                if (event.key === "Enter") {
                    event.preventDefault();
                    searchPosts(); // 검색 함수 호출
                }
            });
        });


    </script>
</head>
<body>
<jsp:include page="../include/header.jsp"/>
<!-- 중앙 컨테이너 -->
<div id="container">
    <section class="mainContainer">
        <!-- 메뉴 영역 -->
        <nav>
            <jsp:include page="../include/navbar.jsp"/>
        </nav>
        <!-- 본문 영역 -->
        <main>
            <!--모바일 메뉴 영역-->
            <div class="m-menu-area" style="display: none;">
                <jsp:include page="../include/navbar.jsp"/>
            </div>
            <!--각 페이지의 콘텐츠-->
            <div id="content">
                <h1>내 스터디</h1>

                <!--본문 콘텐츠-->
                <div class="maxcontent">
                    <div class="list-title flex-between">
                        <h3>가입 스터디(<c:out value="${myStudies.size()}"/>)</h3>
                        <fieldset class="search-box flex-row">
                            <select id="searchOption" name="searchCnd" title="검색 조건 선택">
                                <option value="all-post">전체</option>
                                <option value="title-post">제목</option>
                                <option value="title-content">제목+내용</option>
                            </select>
                            <p class="search-field">
                                <input id="searchInput" type="text" name="searchWrd" placeholder="검색어를 입력해주세요">
                                <button onclick="searchPosts()">
                                    <span class="hide">검색</span>
                                    <i class="bi bi-search"></i>
                                </button>
                            </p>
                        </fieldset>
                    </div>
                    <div class="boardContent flex-colum">
                        <c:choose>
                            <c:when test="${myStudies.size() == 0}">
                                <div class="no-studies">
                                    가입한 스터디가 없습니다!
                                </div>
                            </c:when>
                            <c:otherwise>
                                <c:forEach items="${myStudies}" var="study">
                                    <div class="board-listBoarder flex-between"
                                         <c:if test='${study.status == "REJECTED"} && ${study.status == "PENDING"}'>disabled</c:if>
                                            <c:if test='${study.status == "ACCEPTED"}'>
                                                onclick="location.href='${root}/studyGroup/studyGroupMain?studyIdx=${study.studyIdx}'"
                                            </c:if>
                                    >
                                        <div class="studygroup-item">
                                            <!-- 스터디 목록 -->
                                            <div class="imgtitle flex-row">
                                                <c:if test="${study.image != null}">
                                                    <div class="studygroup-profile-s">
                                                        <img src="${root}${study.image}">
                                                    </div>
                                                </c:if>
                                                <c:if test="${study.image == null}">
                                                    <div class="studygroup-profile-s">
                                                        <img src="${root}/resources/images/studyGroup.png">
                                                    </div>
                                                </c:if>
                                                <div class="board-item flex-columleft">
                                                    <p class="board-title">${study.studyTitle}</p>
                                                    <p class="board-content">${study.description}</p>
                                                </div>
                                            </div>
                                            <!-- 운영중인 스터디일 경우 -->
                                            <c:if test="${study.role == 'LEADER'}">
                                                <div class="status-text">
                                                    <p class="operate secondary-default">
                                                        <a href="${root}/studyGroup/studyGroupManagerInfo?studyIdx=${study.studyIdx}">
                                                            운영
                                                        </a>
                                                    </p>
                                                </div>
                                            </c:if>
                                            <!-- 승인 대기 중인 스터디일 경우 -->
                                            <c:if test="${study.status == 'PENDING'}">
                                                <div class="status-text">
                                                    <p class="pending">가입 승인 중</p>
                                                </div>
                                            </c:if>
                                            <!-- 승인 거절된 스터디일 경우 -->
                                            <c:if test="${study.status == 'REJECTED'}">
                                                <div class="status-text">
                                                    <p class="rejected">승인 거절됨</p>
                                                </div>
                                            </c:if>
                                        </div>
                                    </div>
                                </c:forEach>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>
                <div class="board-bottom">
                    <button class="primary-default" onclick="location.href='${root}/studyGroup/studyGroupCreate'">스터디 만들기</button>
                </div>

                <%--본문 콘텐츠 끝--%>
        </main>
    </section>
</div>
<jsp:include page="../include/footer.jsp"/>
<jsp:include page="../include/timer.jsp"/>
</body>
</html>
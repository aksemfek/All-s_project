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
    <title>스터디그룹 메인 > 내 스터디 > 스터디 > 공부 > All's</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    <link rel="stylesheet" href="${root}/resources/css/common.css">
    <link rel="stylesheet" href="${root}/resources/css/slider.css">
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.5.1/jquery.min.js"></script>
    <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
    <script type="text/javascript" src="${root}/resources/js/common.js" charset="UTF-8" defer></script>
    <script src="${root}/resources/js/fullcalendar/core/index.global.js"></script>
    <script src="${root}/resources/js/fullcalendar/daygrid/index.global.js"></script>
    <script src="${root}/resources/js/fullcalendar/list/index.global.js"></script>

    <script>
        function openChatWindow(studyIdx) {
            window.open('${root}/studyGroup/chat?studyIdx=' + studyIdx, 'ChatWindow', 'width=500,height=750,resizable=no');
        }
        document.addEventListener('DOMContentLoaded', function () {
            let eventsData = [];
            const studyIdx = ${study.studyIdx};
            let monthCalendar, dayCalendar;

            // 캘린더 렌더링 함수
            function renderCalendars() {
                const monthCalendarEl = document.getElementById('monthCalendar');
                monthCalendar = new FullCalendar.Calendar(monthCalendarEl, {
                    initialView: 'dayGridMonth',
                    headerToolbar: { left: 'title', center: '', right: 'prev,next today' },
                    events: eventsData,
                    editable: false,
                    selectable: false,
                    eventClick: false,
                    locale: 'ko',
                    height: 'auto' // 높이를 자동으로 조절
                });
                monthCalendar.render();

                const dayCalendarEl = document.getElementById('dayCalendar');
                dayCalendar = new FullCalendar.Calendar(dayCalendarEl, {
                    initialView: 'listDay',
                    headerToolbar: { left: '', center: 'title', right: '' },
                    events: eventsData,
                    editable: false,
                    selectable: false,
                    eventClick: false,
                    locale: 'ko',
                    height: 'auto'
                });
                dayCalendar.render();
            }

            // 초기 렌더링 및 이벤트 리스너 등록
            $.ajax({
                url: "${root}/calendar/teamEvents/" + studyIdx,
                type: "GET",
                headers: {
                    "${_csrf.headerName}": "${_csrf.token}"
                },
                success: function (response) {
                    eventsData = response.map(event => ({
                        id: event.teamScheduleIdx,
                        title: event.title,
                        start: event.start,
                        end: event.end,
                        allDay: event.allDay === 1,
                        color: event.backgroundColor,
                    }));

                    renderCalendars(); // 캘린더 렌더링

                    // 캘린더가 변경될 때마다 다시 렌더링 (변수 범위 수정)
                    monthCalendar.on('datesSet', renderCalendars);
                    dayCalendar.on('datesSet', renderCalendars);
                },
                error: function (jqXHR, textStatus, errorThrown) {
                    console.error('Error fetching events:', errorThrown);
                    alert('이벤트를 불러오는 중 오류가 발생했습니다.');
                }
            });

            // 멤버 상태 업데이트 함수
            function updateMemberStatus() {
                $.ajax({
                    url: "${root}/studyGroup/getMemberStatus/" + studyIdx,
                    type: "GET",
                    headers: {
                        "${_csrf.headerName}": "${_csrf.token}"
                    },
                    success: function (response) {
                        response.forEach(member => {
                            console.log('Member status response:', response); // 응답 데이터 로그
                            const memberElement = $(`#member_${member.userIdx}`);
                            const statusElement = memberElement.find('.status');
                            statusElement.removeClass('ACTIVE STUDYING RESTING NOT_LOGGED_IN');
                            statusElement.addClass(member.status);
                            switch (member.status) {
                                case 'ACTIVE':
                                    statusElement.text('접속중');
                                    break;
                                case 'STUDYING':
                                    statusElement.text('공부중');
                                    break;
                                case 'RESTING':
                                    statusElement.text('쉬는중');
                                    break;
                                case 'NOT_LOGGED_IN':
                                    statusElement.text('미접속');
                                    break;
                            }
                        });
                    },
                    error: function (jqXHR, textStatus, errorThrown) {
                        console.error('Error fetching member status:', errorThrown);
                    }
                });
            }

            // 초기 상태 업데이트 호출
            updateMemberStatus();
            // 주기적으로 멤버 상태 업데이트
            setInterval(updateMemberStatus, 20000); // 20초마다 업데이트


        });


        // 숫자 계산
        function formatTime(seconds) {
            const h = Math.floor(seconds / 3600);
            const m = Math.floor((seconds % 3600) / 60);
            const s = seconds % 60;
            const hDisplay = h > 0 ? h + '시간 ' : '';
            const mDisplay = m > 0 ? m + '분 ' : '';
            const sDisplay = s > 0 ? s + '초' : '';
            return hDisplay + mDisplay + sDisplay;
        }

    </script>
</head>
<body>
<jsp:include page="../include/header.jsp" />
<!-- 중앙 컨테이너 -->
<div id="container">
    <section class="mainContainer">
        <!-- 메뉴 영역 -->
        <nav>
            <jsp:include page="../include/navbar.jsp" />
        </nav>
        <!-- 본문 영역 -->
        <main>
            <!--모바일 메뉴 영역-->
            <div class="m-menu-area" style="display: none;">
                <jsp:include page="../include/navbar.jsp" />
            </div>
            <!--각 페이지의 콘텐츠-->

            <div id="content">
                <h1>내 스터디</h1>
                <%--본문 콘텐츠--%>
                <div class="maxcontent">
                    <section class="group-header flex-between">
                        <div class="profile-header">
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
                            <div class="group-title">
                                <h2>${study.descriptionTitle}</h2>
                                <p>${study.description}</p>
                            </div>
                        </div>
                        <div class="profile-link">
                            <c:if test="${study.role != 'MEMBER'}">
                                <a class="manager-page" href="${root}/studyGroup/studyGroupManagerInfo?studyIdx=${study.studyIdx}"><i class="bi bi-gear"></i>관리</a>
                            </c:if>
                            <button class="primary-default" onclick="openChatWindow(${study.studyIdx})">채팅 </button>
                        </div>
                    </section>
                    <section class="group-main">
                        <div class="group-content">
                            <h2>이달의 스터디 왕</h2>
                            <div class="group-lank">
                                <div class="lank-phase">
                                    <div class="lank-floor">
                                        <div class="">
                                            <p class="podiumId">
                                                ${rankedMembers[1].userName}
                                            </p>
                                            <p><c:set var="totalTime" value="${rankedMembers[1].totalStudyTime}"/>
                                                <script>
                                                    document.write(formatTime(${totalTime}));
                                                </script>
                                            </p>
                                        </div>
                                        <div class="records lank-second">
                                            <p class="lanking">2</p>
                                        </div>
                                    </div>
                                    <div class="lank-floor">
                                        <div class="">
                                            <p class="podiumId">
                                                ${rankedMembers[0].userName}
                                            </p>
                                            <p><c:set var="totalTime" value="${rankedMembers[0].totalStudyTime}"/>
                                                <script>
                                                    document.write(formatTime(${totalTime}));
                                                </script>
                                            </p>
                                        </div>
                                        <div class="records lank-first">
                                            <p class="lanking">1</p>
                                        </div>
                                    </div>
                                    <div class="lank-floor">
                                        <div class="">
                                            <p class="podiumId">
                                                ${rankedMembers[2].userName}
                                            </p>
                                            <p><c:set var="totalTime" value="${rankedMembers[2].totalStudyTime}"/>
                                                <script>
                                                    document.write(formatTime(${totalTime}));
                                                </script>
                                            </p>
                                        </div>
                                        <div class="records lank-third">
                                            <p class="lanking">3</p>
                                        </div>
                                    </div>
                                </div>
                                <div class="lank-list">
                                    <c:forEach var="member" items="${rankedMembers}" varStatus="status">
                                        <c:if test="${status.count <= 5}">
                                            <div class="lank-item">
                                                <div class="lanking-circle">
                                                    <div class="circle-number ${status.count <= 3 ? 'top3' : ''}">
                                                            ${status.count}
                                                    </div>
                                                </div>
                                                <p class="lank-id">${member.userName}</p>
                                                <p class="lank-time"><c:set var="totalTime" value="${member.totalStudyTime}"/>
                                                    <script>
                                                        document.write(formatTime(${totalTime}));
                                                    </script>
                                                </p>
                                            </div>
                                        </c:if>
                                    </c:forEach>
                                </div>
                            </div>
                            <!--캘린더-->
                            <h2>스터디 일정</h2>
                            <div class="group-calender">
                                <div class="calendar-area">
                                    <div id="monthCalendar"></div>
                                    <div id="dayCalendar"></div>
                                </div>
                            </div>
                        </div>
                        <div class="group-member">
                            <h3>그룹 멤버</h3>
                            <div class="group-memberList">
                                <c:forEach var="member" items="${members}">
                                    <c:if test="${member.status == 'ACCEPTED'}">
                                        <div class="group-memberItem" id="member_${member.userIdx}">
                                            <div class="profile-imgGroup">
                                                <div class="profile-img">
                                                    <img src="${root}/resources/images/user.png" alt="프로필 이미지">
                                                </div>
                                                <div class="study-status ACTIVE ${member.activityStatus}"><span class="status">${member.activityStatus == 'ACTIVE' ? '접속중' : (member.activityStatus == 'STUDYING' ? '공부중' : (member.activityStatus == 'RESTING' ? '쉬는중' : '미접속'))}</span></div>
                                            </div>
                                            <p class="memberId">${member.userName}</p>
                                        </div>
                                    </c:if>
                                </c:forEach>
                            </div>
                        </div>
                    </section>
                </div>
            </div>
            <%--콘텐츠 끝--%>
        </main>
    </section>
</div>
<!--푸터-->
<jsp:include page="../include/timer.jsp" />
<jsp:include page="../include/footer.jsp" />
</body>
</html>

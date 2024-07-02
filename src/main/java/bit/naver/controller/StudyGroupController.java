package bit.naver.controller;

import bit.naver.entity.*;
import bit.naver.mapper.NotificationMapper;
import bit.naver.mapper.StudyGroupMapper;
import bit.naver.mapper.StudyRecruitMapper;
import bit.naver.mapper.UsersMapper;
import bit.naver.service.StudyService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.*;

import javax.servlet.http.HttpSession;
import java.security.Principal;
import java.time.LocalDateTime;
import java.util.*;

@Controller
@RequestMapping("/studyGroup")
public class StudyGroupController {

    @Autowired
    private StudyGroupMapper studyGroupMapper;

    @Autowired
    private StudyRecruitMapper studyRecruitMapper;

    @Autowired
    private NotificationMapper notificationMapper;

    @Autowired
    private UsersMapper usersMapper;

    @Autowired
    private StudyService studyService;

    private static final Logger logger = LoggerFactory.getLogger(StudyGroupController.class);

    // 스터디 관리 페이지로 이동
    @GetMapping("/studyGroupManagerInfo")
    public String getStudyGroupManagerInfo(Model model, @RequestParam("studyIdx") Long studyIdx) {
        StudyGroup studyGroup = studyGroupMapper.getStudyById(studyIdx);

        // category, gender, age 값을 모델에 추가
        model.addAttribute("studyGroup", studyGroup);
        model.addAttribute("category", studyGroup.getCategory());
        model.addAttribute("gender", studyGroup.getGender());
        model.addAttribute("age", studyGroup.getAge());

        logger.info("Category: " + studyGroup.getCategory());
        logger.info("Gender: " + studyGroup.getGender());
        logger.info("Age: " + studyGroup.getAge());

        return "studyGroup/studyGroupManagerInfo";
    }

    // 스터디 리스트 조회 페이지로 이동
    @RequestMapping("/studyGroupList")
    public String getMyStudies(Model model, HttpSession session,
                               @RequestParam(value = "searchKeyword", required = false) String searchKeyword,
                               @RequestParam(value = "searchOption", required = false) String searchOption) {
        // 세션에서 현재 사용자 정보 가져오기 (예: 로그인한 사용자 정보)
        Users user = (Users) session.getAttribute("userVo");
        Long userIdx = user.getUserIdx();

        // DB에서 해당 사용자가 참여 중인 모든 스터디 목록 조회 (승인된 스터디와 승인 대기 중인 스터디 포함)
        List<StudyList> myStudies = studyGroupMapper.getAllMyStudies(userIdx, searchKeyword, searchOption);

        // 모델에 검색어와 검색 옵션을 추가
        model.addAttribute("searchKeyword", searchKeyword);
        model.addAttribute("searchOption", searchOption);
        model.addAttribute("userIdx", userIdx);
        // 모델에 사용자 스터디 목록 추가
        model.addAttribute("myStudies", myStudies);

        return "studyGroup/studyGroupList";
    }

    // 스터디 생성 폼을 위한 GET 요청 처리
    @GetMapping("/studyGroupCreate")
    public String getStudyGroupCreate(Model model) {
        model.addAttribute("studyGroup", new StudyGroup());
        return "studyGroup/studyGroupCreate";
    }

    @RequestMapping("/studyGroupMain")
    public String getStudyGroupMain(@RequestParam("studyIdx") Long studyIdx, Model model, HttpSession session) {
        Users user = (Users) session.getAttribute("userVo");
        Long userIdx = user.getUserIdx();

        StudyGroup study = studyGroupMapper.getStudyById(studyIdx);
        List<StudyMembers> members = studyGroupMapper.getStudyMembers(studyIdx);

        // studyGroup의 role 설정
        for (StudyMembers member : members) {
            if (member.getUserIdx().equals(userIdx)) {
                study.setRole(member.getRole());
                break;
            }
        }
        session.setAttribute("studyIdx", studyIdx); // 세션에 studyIdx 저장

        model.addAttribute("study", study);
        model.addAttribute("members", members);
        return "studyGroup/studyGroupMain"; // 스터디 상세 정보를 보여줄 JSP 페이지
    }

    // 스터디 생성을 위한 POST 요청 처리
    @PostMapping("/studyGroupCreate")
    public String insertCreateStudyGroup(@ModelAttribute("studyGroup") StudyGroup study, BindingResult result, HttpSession session, Principal principal) {
        if (result.hasErrors()) {
            return "studyGroup/studyGroupCreate";
        }

        Users user = (Users) session.getAttribute("userVo");
        Long userIdx = user.getUserIdx();

        // 여기서 studyLeaderIdx를 user의 username에서 가져오는 로직
        // 예시로 구현하면 아래와 같이 userRepository.findByUsername(user.getUsername()).getUserIdx()를 호출
        study.setStudyLeaderIdx(userIdx);
        study.setStartDate(new Date());
        study.setEndDate(new Date());
        study.setStatus(StudyStatus.RECRUITING);
        study.setCreatedAt(new Date());

        studyGroupMapper.insertStudy(study);

        // StudyMembers 테이블에 스터디 리더로 데이터 삽입
        StudyMembers studyMember = new StudyMembers();
        studyMember.setStudyIdx(studyGroupMapper.findStudyIdx(userIdx));
        studyMember.setUserIdx(userIdx);
        studyMember.setRole("LEADER");
        studyMember.setStatus("ACCEPTED");
        studyMember.setCreatedAt(LocalDateTime.now());
        studyMember.setUpdatedAt(LocalDateTime.now());

        studyGroupMapper.insertStudyMember(studyMember);

        return "redirect:/studyGroup/studyGroupList";
    }

    // 채팅
    @RequestMapping("/chat")
    public String chat(HttpSession session, Principal principal) {

        Users user = (Users) session.getAttribute("userVo");
        System.out.println(user.toString());
        return "studyGroup/chat";
    }

    // 스터디 멤버 관리 페이지로 이동
    @GetMapping("/studyGroupManagerMember")
    public String getStudyGroupManagerMember(Model model, @RequestParam("studyIdx") Long studyIdx) {
        logger.info("Accessing studyGroupManagerMember for studyIdx: {}", studyIdx);

        // 스터디 ID를 통해 스터디 정보를 가져옴
        StudyGroup studyGroup = studyGroupMapper.getStudyById(studyIdx);
        List<StudyMembers> members = studyGroupMapper.getStudyMembers(studyIdx);

        logger.info("StudyGroup: {}", studyGroup);

        // 디버깅을 위한 로그 추가
        for (StudyMembers member : members) {
            System.out.println("Member: " + member.getUserName() + ", Status: " + member.getStatus() + ", JoinReason: " + member.getJoinReason());
        }

        model.addAttribute("studyGroup", studyGroup);
        model.addAttribute("members", members);
        return "studyGroup/studyGroupManagerMember";
    }

    @PostMapping("/removeMember")
    @ResponseBody
    public Map<String, Object> removeMember(@RequestParam("studyIdx") Long studyIdx, @RequestParam("userIdx") Long userIdx) {
        Map<String, Object> response = new HashMap<>();
        try {
            studyGroupMapper.removeMember(studyIdx, userIdx);
            response.put("success", true);
        } catch (Exception e) {
            response.put("success", false);
            response.put("message", e.getMessage());
        }
        return response;
    }

    @PostMapping("/approveMember")
    @ResponseBody
    public Map<String, Object> approveMember(@RequestParam("studyIdx") Long studyIdx, @RequestParam("userIdx") Long userIdx) {
        Map<String, Object> response = new HashMap<>();
        try {
            studyGroupMapper.approveMember(studyIdx, userIdx);
            response.put("success", true);
            response.put("message", "가입 승인이 완료되었습니다.");
        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "가입 승인에 실패했습니다: " + e.getMessage());
        }
        return response;
    }

    @PostMapping("/rejectMember")
    @ResponseBody
    public Map<String, Object> rejectMember(@RequestParam("studyIdx") Long studyIdx, @RequestParam("userIdx") Long userIdx) {
        Map<String, Object> response = new HashMap<>();
        try {
            studyGroupMapper.updateMemberStatus(studyIdx, userIdx, "REJECTED");
            response.put("success", true);
            response.put("message", "가입 승인을 거절하였습니다.");
        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "가입 승인 거절에 실패했습니다: " + e.getMessage());
        }
        return response;
    }

    // 스터디 관리 - 일정
    @GetMapping("/studyGroupManagerSchedule")
    public String getStudyGroupManagerSchedule(@RequestParam("studyIdx") Long studyIdx, Model model) {
        StudyGroup studyGroup = studyGroupMapper.getStudyById(studyIdx);
        model.addAttribute("studyGroup", studyGroup);
        return "studyGroup/studyGroupManagerSchedule";
    }

    // 스터디 관리 페이지로 이동
    @GetMapping("/studyGroupManagerManagement")
    public String getStudyGroupManagerManagement(Model model, @RequestParam("studyIdx") Long studyIdx) {
        // 스터디 ID를 통해 스터디 정보를 가져옴
        StudyGroup studyGroup = studyGroupMapper.getStudyById(studyIdx);
        model.addAttribute("studyGroup", studyGroup);
        return "studyGroup/studyGroupManagerManagement";
    }

    @PostMapping("/deleteStudyGroup")
    @ResponseBody
    public Map<String, Object> deleteStudyGroup(@RequestParam("studyIdx") Long studyIdx) {
        Map<String, Object> response = new HashMap<>();
        try {
            // 종속 레코드 삭제
            studyGroupMapper.deleteTeamCalendarsByStudyIdx(studyIdx);
            studyGroupMapper.deleteStudyMembersByStudyIdx(studyIdx);

            // 부모 레코드 삭제
            studyGroupMapper.deleteStudy(studyIdx);
            response.put("success", true);
            response.put("message", "스터디가 성공적으로 삭제되었습니다.");
        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "스터디 삭제에 실패했습니다: " + e.getMessage());
        }
        return response;
    }

    @RequestMapping("/recruitReadForm")
    public String getRecruitReadForm(@RequestParam("studyIdx") Long studyIdx, Model model, HttpSession session) {
        Users user = (Users) session.getAttribute("userVo");
        Long userIdx = user.getUserIdx();

        StudyGroup study = studyGroupMapper.getStudyById(studyIdx);
        boolean isMember = studyGroupMapper.isMember(studyIdx, userIdx);

        model.addAttribute("study", study);
        model.addAttribute("isMember", isMember);

        return "studyRecruit/recruitReadForm";
    }

    @PostMapping("/updateStudyGroup")
    public String updateStudyGroup(@ModelAttribute StudyGroup studyGroup) {
        studyGroupMapper.updateStudy(studyGroup);

        // 수정된 내용 콘솔에 출력
        System.out.println("Updated Study Group:");
        System.out.println("Description Title: " + studyGroup.getDescriptionTitle());
        System.out.println("Description: " + studyGroup.getDescription());
        System.out.println("Category: " + studyGroup.getCategory());
        System.out.println("Age: " + studyGroup.getAge());
        System.out.println("Gender: " + studyGroup.getGender());
        System.out.println("Study Online: " + studyGroup.isStudyOnline());

        return "redirect:/studyGroup/studyGroupManagerInfo?studyIdx=" + studyGroup.getStudyIdx();
    }

    // 알림 정보
    @ResponseBody
    @PostMapping("getAlarmInfo")
    public List<NotificationEntity> getAlarmInfo(HttpSession session) {
        Users user = (Users) session.getAttribute("userVo");


        List<NotificationEntity> data = notificationMapper.getAlarmInfo(user.getUserIdx());

        return data;
    }

    @GetMapping("/studyGroupMain/members/{studyIdx}")
    @ResponseBody
    public ResponseEntity<List<StudyMemberStatus>> getStudyGroupMemberStatus(@PathVariable Long studyIdx, HttpSession session) {
        Users user = (Users) session.getAttribute("userVo");
        Long userIdx = user.getUserIdx();

        // 현재 사용자가 스터디 멤버인지 확인
        StudyMembers member = studyGroupMapper.getStudyMember(studyIdx, userIdx);
        if (member == null || !member.getStatus().equals("ACCEPTED")) { // ACCEPTED 상태인지 확인
            return ResponseEntity.ok(Collections.emptyList()); // 멤버가 아니면 빈 리스트 반환
        }

        // 스터디 멤버들의 activity_status 조회
        List<StudyMembers> members = studyGroupMapper.getStudyMembers(studyIdx);
        List<StudyMemberStatus> memberStatusList = new ArrayList<>();
        for (StudyMembers studyMember : members) {
            Users memberUser = usersMapper.findById(studyMember.getUserIdx());
            if (memberUser != null) {
                StudyMemberStatus status = new StudyMemberStatus();
                status.setUserIdx(memberUser.getUserIdx());
                status.setUsername(memberUser.getUsername());
                status.setName(memberUser.getName());
                status.setActivityStatus(memberUser.getActivityStatus().getValue());
                status.setProfile_image(memberUser.getProfileImage());
                memberStatusList.add(status);
            }
        }

        return ResponseEntity.ok(memberStatusList);
    }

}
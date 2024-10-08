package bit.naver.entity;

import lombok.Data;

@Data
public class CommentsEntity {

    private Long commentIdx;
    private Long userIdx;
    private Long referenceIdx;
    private String content;
    private String createdAt;

    private String name;
    private String TOTALCOUNT;

}

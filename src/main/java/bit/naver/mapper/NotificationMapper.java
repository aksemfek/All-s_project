package bit.naver.mapper;

import bit.naver.entity.NotificationEntity;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface NotificationMapper {

    void createNotification(NotificationEntity notification);

    void createReferenceNotification(NotificationEntity notification);

    List<NotificationEntity> getAlarmInfo(Long userIdx);

    void deleteNotification(@Param("notificationIdx") Long notificationIdx);

}

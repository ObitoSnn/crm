package com.obitosnn.crm.workbench.dao;

import com.obitosnn.crm.workbench.domain.Activity;

import java.util.List;
import java.util.Map;

/**
 * @Author ObitoSnn
 * @Description:
 * @Date 2021/1/26 13:55
 */
public interface ActivityDao {

    Integer insertActivity(Activity activity);

    Long selectActivityTotal(Map<String, Object> map);

    List<Activity> selectActivityList(Map<String, Object> map);

    Integer deleteByIds(String[] ids);

    Activity selectActivityById(String id);

    Integer updateActivity(Activity activity);

    Activity selectActivityDetailById(String id);

    List<Activity> selectActivityListByClueId(String clueId);

    List<Activity> selectNotBindActivityListByClueId(String clueId);

    List<Activity> selectNotBindActivityListByName(Map<String, String> map);

    List<String> selectActivityName(String name);

    List<Activity> getActivityByName(String activityName);

    List<Activity> selectActivityListByContactsId(String contactsId);

    List<Activity> selectNotBindActivityListByContactsId(String contactsId);

    List<Activity> selectNotBindActivityListByContactsIdAndName(Map<String, String> map);

}

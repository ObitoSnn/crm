package com.obitosnn.crm.workbench.dao;


import com.obitosnn.crm.workbench.domain.Clue;

import java.util.List;
import java.util.Map;

public interface ClueDao {

    Integer insertClue(Clue clue);

    Long selectTotal(Map<String, Object> map);

    List<Clue> selectAllClueByMap(Map<String, Object> map);

    Clue getClueDetailById(String id);

}

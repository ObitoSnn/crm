package com.obitosnn.crm.workbench.web.controller;

import com.obitosnn.crm.exception.FailToSaveException;
import com.obitosnn.crm.settings.domain.User;
import com.obitosnn.crm.settings.service.UserService;
import com.obitosnn.crm.util.DateTimeUtil;
import com.obitosnn.crm.util.UUIDUtil;
import com.obitosnn.crm.workbench.domain.Activity;
import com.obitosnn.crm.workbench.domain.Contacts;
import com.obitosnn.crm.workbench.domain.Tran;
import com.obitosnn.crm.workbench.service.ActivityService;
import com.obitosnn.crm.workbench.service.ContactsService;
import com.obitosnn.crm.workbench.service.CustomerService;
import com.obitosnn.crm.workbench.service.TranService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.servlet.ModelAndView;

import javax.servlet.http.HttpServletRequest;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * @Author ObitoSnn
 * @Date 2021/2/7 11:52
 */
@Controller
@RequestMapping(value = {"/workbench/transaction"})
public class TranController {
    @Autowired
    private TranService tranService;
    @Autowired
    private UserService userService;
    @Autowired
    private CustomerService customerService;
    @Autowired
    private ActivityService activityService;
    @Autowired
    private ContactsService contactsService;

    @RequestMapping(value = {"/add"})
    public ModelAndView add() {
        ModelAndView mv = new ModelAndView();
        List<User> uList = userService.getUserList();
        mv.addObject("uList", uList);
        mv.setViewName("forward:/pages/workbench/transaction/save.jsp");
        return mv;
    }

    @RequestMapping(value = {"/getCustomerName"})
    @ResponseBody
    public List<String> getCustomerName(String name) {
        return customerService.getCustomerName(name);
    }

    @RequestMapping(value = {"/getActivityByName"})
    @ResponseBody
    public List<Activity> getActivityByName(String activityName) {
        return activityService.getActivityByName(activityName);
    }

    @RequestMapping(value = {"/getContactByName"})
    @ResponseBody
    public List<Contacts> getContactByName(String contactName) {
        return contactsService.getContactByName(contactName);
    }

    @RequestMapping(value = {"/saveTran"})
    @ResponseBody
    public Map<String, Object> saveTran(HttpServletRequest request, Tran tran, String customerName) throws Exception {
        Map<String, Object> map = new HashMap<String, Object>();
        String createBy = ((User) request.getSession().getAttribute("user")).getName();
        tran.setId(UUIDUtil.getUUID());
        tran.setCreateBy(createBy);
        tran.setCreateTime(DateTimeUtil.getSysTime());
        boolean success = false;
        try {
            success = tranService.saveTran(tran, customerName);
        } catch (FailToSaveException e) {
            e.printStackTrace();
            throw new Exception(e.getMessage());
        }
        map.put("success", success);
        return map;
    }

}

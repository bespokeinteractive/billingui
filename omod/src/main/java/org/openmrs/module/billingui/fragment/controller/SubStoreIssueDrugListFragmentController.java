package org.openmrs.module.billingui.fragment.controller;

import org.apache.commons.lang.StringUtils;
import org.openmrs.Role;
import org.openmrs.api.context.Context;
import org.openmrs.module.hospitalcore.model.InventoryStore;
import org.openmrs.module.hospitalcore.model.InventoryStoreDrugPatient;
import org.openmrs.module.hospitalcore.model.InventoryStoreRoleRelation;
import org.openmrs.module.inventory.InventoryService;
import org.openmrs.module.inventory.util.PagingUtil;
import org.openmrs.module.inventory.util.RequestUtil;
import org.openmrs.ui.framework.SimpleObject;
import org.openmrs.ui.framework.UiUtils;
import org.springframework.web.bind.annotation.RequestParam;

import javax.servlet.http.HttpServletRequest;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

/**
 * @author Stanslaus Odhiambo
 *         Created on 4/17/2016.
 *         Functional Class to pull the list of unpaid for drug orders from pharmacy that are to be paid for
 */

public class SubStoreIssueDrugListFragmentController {
    /**
     * default handler for POST and GET methods
     */
    public void controller() {

    }

    /**
     * @param pageSize
     * @param currentPage
     * @param issueName
     * @param fromDate
     * @param toDate
     * @param receiptId
     * @param request
     * @param uiUtils
     * @return
     */
    public List<SimpleObject> getOrderList(
            @RequestParam(value = "pageSize", required = false) Integer pageSize,
            @RequestParam(value = "currentPage", required = false) Integer currentPage,
            @RequestParam(value = "issueName", required = false) String issueName,
            @RequestParam(value = "fromDate", required = false) String fromDate,
            @RequestParam(value = "toDate", required = false) String toDate,
            @RequestParam(value = "receiptId", required = false) Integer receiptId,
            HttpServletRequest request, UiUtils uiUtils) {
        SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy");
        InventoryService inventoryService = (InventoryService) Context.getService(InventoryService.class);
        List<Role> role = new ArrayList<Role>(Context.getAuthenticatedUser().getAllRoles());
        InventoryStoreRoleRelation srl = null;
        Role rl = null;
        for (Role r : role) {
            if (inventoryService.getStoreRoleByName(r.toString()) != null) {
                srl = inventoryService.getStoreRoleByName(r.toString());
                rl = r;
            }
        }
        InventoryStore store = null;
        if (srl != null) {
            store = inventoryService.getStoreById(srl.getStoreid());

        }
        int total = inventoryService.countStoreDrugPatient(store.getId(), issueName, fromDate, toDate);
        String temp = "";

        if (issueName != null) {
            if (StringUtils.isBlank(temp)) {
                temp = "?issueName=" + issueName;
            } else {
                temp += "&issueName=" + issueName;
            }
        }
        if (!StringUtils.isBlank(fromDate)) {
            if (StringUtils.isBlank(temp)) {
                temp = "?fromDate=" + fromDate;
            } else {
                temp += "&fromDate=" + fromDate;
            }
        }
        if (!StringUtils.isBlank(toDate)) {
            if (StringUtils.isBlank(temp)) {
                temp = "?toDate=" + toDate;
            } else {
                temp += "&toDate=" + toDate;
            }
        }
        if (receiptId != null) {
            if (StringUtils.isBlank(temp)) {
                temp = "?receiptId=" + receiptId;
            } else {
                temp += "&receiptId=" + receiptId;
            }
        }
        PagingUtil pagingUtil = new PagingUtil(RequestUtil.getCurrentLink(request) + temp, pageSize, currentPage, total);
        if (StringUtils.isBlank(fromDate)) {
            fromDate = sdf.format(new Date());
        }
        List<InventoryStoreDrugPatient> listIssue = inventoryService.listStoreDrugPatient(store.getId(), receiptId, issueName, fromDate, toDate, pagingUtil.getStartPos(), pagingUtil.getPageSize());
        for (InventoryStoreDrugPatient in : listIssue) {
            String created = sdf.format(in.getCreatedOn());
            String changed = sdf.format(new Date());
            int value = changed.compareTo(created);
            in.setValues(value);
            in = inventoryService.saveStoreDrugPatient(in);
        }
        return SimpleObject.fromCollection(listIssue, uiUtils, "id", "identifier", "patient.patientId","patient.givenName", "patient.familyName", "patient.middleName",
                "patient.age", "patient.gender", "createdOn");
    }
}

package org.openmrs.module.billingui.page.controller;

import org.apache.commons.collections.CollectionUtils;
import org.apache.commons.lang.StringUtils;
import org.openmrs.*;
import org.openmrs.api.PatientService;
import org.openmrs.api.context.Context;
import org.openmrs.module.billingui.includable.billcalculator.BillCalculatorForBDService;
import org.openmrs.module.hospitalcore.BillingConstants;
import org.openmrs.module.hospitalcore.BillingService;
import org.openmrs.module.hospitalcore.HospitalCoreService;
import org.openmrs.module.hospitalcore.IpdService;
import org.openmrs.module.hospitalcore.model.*;
import org.openmrs.module.hospitalcore.util.*;
import org.openmrs.ui.framework.UiUtils;
import org.openmrs.ui.framework.page.PageModel;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestParam;

import javax.servlet.http.HttpServletRequest;
import java.math.BigDecimal;
import java.text.SimpleDateFormat;
import java.util.*;

/**
 * @author Stanslaus Odhiambo
 *         Created on 1/25/2016.
 */
public class PatientServiceBillForBDPageController {

    public String get(PageModel model, @RequestParam("patientId") Integer patientId,
                      @RequestParam(value = "billId", required = false) Integer billId,
                      @RequestParam(value = "billType", required = false) Integer billType,
                      @RequestParam(value = "pageSize", required = false) Integer pageSize,
                      @RequestParam(value = "currentPage", required = false) Integer currentPage,
                      @RequestParam(value = "encounterId", required = false) Integer encounterId,
                      @RequestParam(value = "typeOfPatient", required = false) String typeOfPatient,
                      @RequestParam(value = "admissionLogId", required = false) Integer admissionLogId,
                      @RequestParam(value = "requestForDischargeStatus", required = false) Integer requestForDischargeStatus,
                      @RequestParam(value = "itemID", required = false) Integer itemID,
                      @RequestParam(value = "voidStatus", required = false) Boolean voidStatus,
                      @RequestParam(value = "selectedCategory", required = false) Integer selectedCategory,
                      HttpServletRequest request, UiUtils uiUtils) {

        Map<String, Object> redirectParams = new HashMap<String, Object>();
        redirectParams.put("encounterId", encounterId);
        redirectParams.put("patientId", patientId);
        redirectParams.put("billId", billId);
        redirectParams.put("billType", billType);
        if (StringUtils.isNotBlank(typeOfPatient)) {
            model.addAttribute("requestForDischargeStatus", requestForDischargeStatus);
            return "redirect:" + uiUtils.pageLink("billingui", "billListForIndoorPatient", redirectParams);

        } else {
            return "redirect:" + uiUtils.pageLink("billingui", "billableServiceBillListForBD", redirectParams);
        }

    }


    public String post(@RequestParam("patientId") Integer patientId,
                       @RequestParam(value = "billId", required = false) Integer billId,
                       @RequestParam(value = "encounterId", required = false) Integer encounterId,
                       @RequestParam(value = "admissionLogId", required = false) Integer admissionLogId,
                       @RequestParam(value = "waiverAmount", required = false) BigDecimal waiverAmount,
                       @RequestParam(value = "paymentMode", required = false) String paymentMode,
                       @RequestParam(value = "adDays", required = false) Integer admittedDays,
                       @RequestParam(value = "rebateAmount", required = false) BigDecimal rebateAmount,
                       @RequestParam(value = "comment", required = false) String comment,
                       @RequestParam(value = "patientCategory", required = false) String patientCategory,
                       @RequestParam(value = "voidedAmount", required = false) BigDecimal voidedAmount,
                       HttpServletRequest request, UiUtils uiUtils) {
        if (encounterId != null) {
            BillingService billingService = Context.getService(BillingService.class);
            IpdService ipdService = Context.getService(IpdService.class);
            PatientService patientService = Context.getPatientService();
            Patient patient = patientService.getPatient(patientId);

            PatientServiceBill bill = new PatientServiceBill();

            bill.setCreatedDate(new Date());
            bill.setPatient(patient);
            bill.setCreator(Context.getAuthenticatedUser());

            PatientServiceBillItem item;
            Money totalAmount = new Money(BigDecimal.ZERO);
            Money mUnitPrice;
            Money itemAmount;
            BigDecimal totalActualAmount = new BigDecimal(0);

            List<IndoorPatientServiceBill> bills = billingService.getIndoorPatientServiceBillByEncounter(Context.getEncounterService().getEncounter(encounterId));
            for (IndoorPatientServiceBill ipsb : bills) {

                for (IndoorPatientServiceBillItem ipsbi : ipsb.getBillItems()) {
                    mUnitPrice = new Money(ipsbi.getUnitPrice());
                    itemAmount = mUnitPrice.times(ipsbi.getQuantity());
                    totalAmount = totalAmount.plus(itemAmount);
                    item = new PatientServiceBillItem();
                    item.setCreatedDate(new Date());
                    item.setName(ipsbi.getName());
                    item.setPatientServiceBill(bill);
                    item.setQuantity(ipsbi.getQuantity());
                    item.setService(ipsbi.getService());
                    item.setVoidedby(ipsbi.getVoidedby());
                    if (ipsbi.getVoidedby() != null) {
                        item.setVoided(true);
                        item.setVoidedDate(new Date());
                    }
//						item.setVoided(ipsbi.getVoided());
//		                item.setVoidedDate(ipsbi.getVoidedDate());
                    item.setUnitPrice(ipsbi.getUnitPrice());
                    item.setAmount(ipsbi.getAmount());
                    item.setOrder(ipsbi.getOrder());
                    item.setActualAmount(ipsbi.getActualAmount());

                    if (patientCategory.equals("EXEMPTED PATIENT")) {
                        totalActualAmount = BigDecimal.ZERO;
                    } else {
                        totalActualAmount = totalActualAmount.add(item.getActualAmount());
                    }
                    bill.addBillItem(item);
                }
            }
            bill.setAmount(totalAmount.getAmount());
            bill.setReceipt(billingService.createReceipt());
            bill.setFreeBill(0);
            //bill.setActualAmount(totalActualAmount.subtract(waiverAmount));

            if (voidedAmount != null) {
                totalActualAmount = totalActualAmount.subtract(voidedAmount);
            }
            bill.setActualAmount(totalActualAmount);
            if (waiverAmount != null) {
                bill.setWaiverAmount(waiverAmount);
            } else {
                BigDecimal wavAmt = new BigDecimal(0);
                bill.setWaiverAmount(wavAmt);
            }
            bill.setEncounter(Context.getEncounterService().getEncounter(encounterId));
            bill.setPaymentMode(paymentMode);
            bill.setAdmittedDays(admittedDays);
            bill.setRebateAmount(rebateAmount);
            bill.setPatientCategory(patientCategory);
            bill.setComment(comment);

            HospitalCoreService hcs = Context.getService(HospitalCoreService.class);
            List<PersonAttribute> pas = hcs.getPersonAttributes(patientId);
            String patientSubCategory = null;
            for (PersonAttribute pa : pas) {
                PersonAttributeType attributeType = pa.getAttributeType();
                PersonAttributeType personAttributePCT = hcs.getPersonAttributeTypeByName("Paying Category Type");
                PersonAttributeType personAttributeNPCT = hcs.getPersonAttributeTypeByName("Non-Paying Category Type");
                PersonAttributeType personAttributeSSCT = hcs.getPersonAttributeTypeByName("Special Scheme Category Type");
                if (attributeType.getPersonAttributeTypeId() == personAttributePCT.getPersonAttributeTypeId()) {
                    patientSubCategory = pa.getValue();
                } else if (attributeType.getPersonAttributeTypeId() == personAttributeNPCT.getPersonAttributeTypeId()) {
                    patientSubCategory = pa.getValue();
                } else if (attributeType.getPersonAttributeTypeId() == personAttributeSSCT.getPersonAttributeTypeId()) {
                    patientSubCategory = pa.getValue();
                }
            }

            bill.setPatientSubCategory(patientSubCategory);

            bill = billingService.savePatientServiceBill(bill);

            if (bill != null) {
                for (IndoorPatientServiceBill ipsb : bills) {
                    billingService.deleteIndoorPatientServiceBill(ipsb);
                }
                IpdPatientAdmissionLog ipdPatientAdmissionLog = ipdService.getIpdPatientAdmissionLog(admissionLogId);
                ipdPatientAdmissionLog.setBillingStatus(1);
                IpdPatientAdmitted ipdPatientAdmitted = ipdService.getAdmittedByAdmissionLogId(ipdPatientAdmissionLog);
                ipdPatientAdmitted.setBillingStatus(1);
                ipdService.saveIpdPatientAdmissionLog(ipdPatientAdmissionLog);
                ipdService.saveIpdPatientAdmitted(ipdPatientAdmitted);
            }
            return "redirect:/module/billing/indoorPatientServiceBill.list?patientId=" + patientId + "&billId=" + bill.getPatientServiceBillId() + "&encounterId=" + encounterId + "&admissionLogId=" + admissionLogId;
        } else {
            BillingService billingService = (BillingService) Context.getService(BillingService.class);
            PatientServiceBill patientServiceBill = billingService.getPatientServiceBillById(billId);
            if (patientServiceBill != null && !patientServiceBill.getPrinted() && patientServiceBill.getEncounter() == null) {
                patientServiceBill.setPrinted(true);
                Map<String, String> attributes = PatientUtils.getAttributes(patientServiceBill.getPatient());

                BillCalculatorForBDService calculator = new BillCalculatorForBDService();

                // 3-june-2013 New Requirement #1632 Orders from dashboard must be appear in billing queue.User must be able to generate bills from this queue
                if (patientServiceBill.getFreeBill().equals(1)) {
                    String billType = "free";
                    patientServiceBill.setFreeBill(calculator.isFreeBill(billType));
                } else if (patientServiceBill.getFreeBill().equals(2)) {
                    String billType = "mixed";
                    patientServiceBill.setFreeBill(2);
                } else {
                    String billType = "paid";
                    patientServiceBill.setFreeBill(calculator.isFreeBill(billType));
                }

                billingService.saveBillEncounterAndOrder(patientServiceBill);
            }
//			return "redirect:/module/billing/patientServiceBillForBD.list?patientId=" + patientId;
            return "redirect:/module/billing/billingqueue.form";
        }
    }
}

package org.openmrs.module.billingui.page.controller;

import org.apache.commons.collections.CollectionUtils;
import org.openmrs.*;
import org.openmrs.api.context.Context;
import org.openmrs.module.billingui.includable.billcalculator.BillCalculatorForBDService;
import org.openmrs.module.hospitalcore.BillingConstants;
import org.openmrs.module.hospitalcore.BillingService;
import org.openmrs.module.hospitalcore.IpdService;
import org.openmrs.module.hospitalcore.model.IndoorPatientServiceBill;
import org.openmrs.module.hospitalcore.model.IpdPatientAdmissionLog;
import org.openmrs.module.hospitalcore.model.IpdPatientAdmitted;
import org.openmrs.module.hospitalcore.model.PatientServiceBill;
import org.openmrs.module.hospitalcore.util.ConceptAnswerComparator;
import org.openmrs.module.hospitalcore.util.PagingUtil;
import org.openmrs.module.hospitalcore.util.PatientUtils;
import org.openmrs.module.hospitalcore.util.RequestUtil;
import org.openmrs.ui.framework.UiUtils;
import org.openmrs.ui.framework.page.PageModel;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestParam;

import javax.servlet.http.HttpServletRequest;
import java.text.SimpleDateFormat;
import java.util.*;

/**
 * @author Stanslaus Odhiambo
 * Created on 1/25/2016.
 */
public class PatientServiceBillForBDPageController {

    public String get(PageModel model, @RequestParam("patientId") Integer patientId,
                      @RequestParam(value = "billId", required = false) Integer billId,
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
        long admitMili = 0;
        BillingService billingService = Context.getService(BillingService.class);

        Patient patient = Context.getPatientService().getPatient(patientId);
        Map<String, String> attributes = PatientUtils.getAttributes(patient);

        BillCalculatorForBDService calculator = new BillCalculatorForBDService();
        IpdService ipdService = Context.getService(IpdService.class);
        IpdPatientAdmissionLog ipdPatientAdmissionLog = ipdService.getIpdPatientAdmissionLog(admissionLogId);
        IpdPatientAdmitted ipdPatientAdmitted = ipdService.getAdmittedByAdmissionLogId(ipdPatientAdmissionLog);

        // 13/2/2015 PatientCategory storing
        if (selectedCategory != null) {
            BillingService billingService3 = Context.getService(BillingService.class);
            billingService3.updatePatientCategory(selectedCategory, Context.getEncounterService().getEncounter(encounterId), patient);
        }

        if (itemID != null) {
            BillingService billingService2 = Context.getService(BillingService.class);
            String voidedBy = voidStatus ? Context.getAuthenticatedUser().getUsername() : null;
            Date voidedDate = voidStatus ? new Date() : null;
            billingService2.updateVoidBillItems(voidStatus, voidedBy, voidedDate, itemID);
        }

        if (patient != null) {

            int total = billingService.countListPatientServiceBillByPatient(patient);

            PagingUtil pagingUtil = new PagingUtil(RequestUtil.getCurrentLink(request), pageSize, currentPage, total,
                    patientId);

            model.addAttribute("age", patient.getAge());

            Concept category = Context.getConceptService().getConceptByName("Patient Category");
            List<ConceptAnswer> categoryList = (category != null ? new ArrayList<ConceptAnswer>(category.getAnswers()) : null);
            if (CollectionUtils.isNotEmpty(categoryList)) {
                Collections.sort(categoryList, new ConceptAnswerComparator());
            }

            Integer nhifCatId = Context.getConceptService().getConceptByName("NHIF PATIENT").getConceptId();
            Integer generalCatId = Context.getConceptService().getConceptByName("GENERAL PATIENT").getConceptId();
            Integer exemptedCatId = Context.getConceptService().getConceptByName("EXEMPTED PATIENT").getConceptId();
            Integer ChildCatId = Context.getConceptService().getConceptByName("CHILD LESS THAN 5 YEARS").getConceptId();
            model.addAttribute("nhifCatId", nhifCatId);
            model.addAttribute("generalCatId", generalCatId);
            model.addAttribute("exemptedCatId", exemptedCatId);
            model.addAttribute("ChildCatId", ChildCatId);
            model.addAttribute("categoryList", categoryList);

            model.addAttribute("category", patient.getAttribute(14));
            model.addAttribute("fileNumber", patient.getAttribute(43));

            if (patient.getGender().equals("M")) {
                model.addAttribute("gender", "Male");
            }
            if (patient.getGender().equals("F")) {
                model.addAttribute("gender", "Female");
            }


            if (typeOfPatient != null) {
                if (encounterId != null) {
                    if (ipdPatientAdmitted.getAdmittedWard() != null) {
                        model.addAttribute("ward", ipdPatientAdmitted.getAdmittedWard());
                    }
                    if (ipdPatientAdmitted.getBed() != null) {
                        model.addAttribute("bed", ipdPatientAdmitted.getBed());
                    }
                    PersonAttribute fileNumber = patient.getAttribute(43);
                    if (fileNumber != null) {
                        model.addAttribute("fileNumber", fileNumber.getValue());
                    }
                    if (ipdPatientAdmitted.getUser().getGivenName() != null) {
                        model.addAttribute("doctor", ipdPatientAdmitted.getIpdAdmittedUser().getGivenName());
                    }
                    if (ipdPatientAdmitted.getPatientAdmittedLogTransferFrom() != null) {
                        IpdPatientAdmissionLog ipdPatientAdmissionLog1 = ipdService.getIpdPatientAdmissionLog(ipdPatientAdmitted.getPatientAdmissionLog().getId());
                        model.addAttribute("admissionDate", ipdPatientAdmissionLog1.getAdmissionDate());
                        admitMili = ipdPatientAdmissionLog1.getAdmissionDate().getTime();
                    } else {
                        if (ipdPatientAdmitted.getAdmissionDate() != null) {
                            model.addAttribute("admissionDate", ipdPatientAdmitted.getAdmissionDate());
                            admitMili = ipdPatientAdmitted.getAdmissionDate().getTime();

                        }
                    }

                    SimpleDateFormat formatter = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
                    model.addAttribute("curDate", formatter.format(new Date()));

                    Calendar c2 = Calendar.getInstance();
                    Date eDt = new Date(new Date().getTime());
                    c2.setTime(eDt);
                    c2.set(Calendar.HOUR_OF_DAY, 23);
                    c2.set(Calendar.MINUTE, 59);
                    c2.set(Calendar.SECOND, 59);
                    // Put it back in the Date object

                    long admittedDays = (c2.getTime().getTime() - admitMili) / (3600000 * 24);

                    if (admittedDays < 1) {
                        admittedDays = 1;
                    }

                    model.addAttribute("admittedDays", admittedDays);


                    List<IndoorPatientServiceBill> indpsb = billingService.getSelectedCategory(Context.getEncounterService().getEncounter(encounterId), patient);
                    Iterator it = indpsb.listIterator();
                    while (it.hasNext()) {
                        IndoorPatientServiceBill ipsb = (IndoorPatientServiceBill) it.next();
                        selectedCategory = ipsb.getSelectedCategory();
                    }
                    if (selectedCategory == null) {
                        selectedCategory = 0;
                    }

                    model.addAttribute("selectedCategory", selectedCategory);

                }
            }
            model.addAttribute("pagingUtil", pagingUtil);
            model.addAttribute("patient", patient);
            model.addAttribute("listBill",
                    billingService.listPatientServiceBillByPatient(pagingUtil.getStartPos(), pagingUtil.getPageSize(), patient));
            model.addAttribute("address", patient.getPersonAddress().getAddress1() + ", " + patient.getPersonAddress().getCityVillage());
        }


        User user = Context.getAuthenticatedUser();

        model.addAttribute("canEdit", user.hasPrivilege(BillingConstants.PRIV_EDIT_BILL_ONCE_PRINTED));
        if (billId != null) {
            PatientServiceBill bill = billingService.getPatientServiceBillById(billId);


            if (bill.getFreeBill().equals(1)) {
                String billType = "free";
                bill.setFreeBill(calculator.isFreeBill(billType));
            } else if (bill.getFreeBill().equals(2)) {
                String billType = "mixed";
                bill.setFreeBill(2);
            } else {
                String billType = "paid";
                bill.setFreeBill(calculator.isFreeBill(billType));
            }
            model.addAttribute("dateTime", bill.getCreatedDate());
            model.addAttribute("paymentMode", bill.getPaymentMode());
            model.addAttribute("cashier", bill.getCreator().getGivenName());
            model.addAttribute("bill", bill);
        }


        if (typeOfPatient != null) {
            if (encounterId != null) {
                List<IndoorPatientServiceBill> bills = billingService.getIndoorPatientServiceBillByEncounter(Context.getEncounterService().getEncounter(encounterId));
                model.addAttribute("billList", bills);
            }
            model.addAttribute("requestForDischargeStatus", requestForDischargeStatus);
            return "redirect:" + uiUtils.pageLink("billingui", "billListForIndoorPatient");

        } else {
            return "redirect:" + uiUtils.pageLink("billingui", "billableServiceBillListForBD");
        }

    }
}

package org.openmrs.module.billingui.page.controller;

import org.apache.commons.lang.math.NumberUtils;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.openmrs.Concept;
import org.openmrs.Order;
import org.openmrs.Patient;
import org.openmrs.api.context.Context;
import org.openmrs.module.billingui.includable.billcalculator.BillCalculatorForBDService;
import org.openmrs.module.hospitalcore.BillingService;
import org.openmrs.module.hospitalcore.model.BillableService;
import org.openmrs.module.hospitalcore.model.PatientServiceBill;
import org.openmrs.module.hospitalcore.model.PatientServiceBillItem;
import org.openmrs.module.hospitalcore.util.HospitalCoreUtils;
import org.openmrs.module.hospitalcore.util.Money;
import org.openmrs.module.hospitalcore.util.PatientUtils;
import org.openmrs.ui.framework.page.PageModel;
import org.springframework.ui.Model;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.RequestParam;

import javax.servlet.http.HttpServletRequest;
import java.math.BigDecimal;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * @author Stanslaus Odhiambo
 *         Created on 2/8/2016.
 *         This class controlls the editing of a patient bill
 */
public class EditPatientServiceBillForBDPageController {
    private Log logger = LogFactory.getLog(getClass());

    public void get(PageModel model, @RequestParam("billId") Integer billId, @RequestParam("patientId") Integer patientId) {

        Patient patient = Context.getPatientService().getPatient(patientId);
        Map<String, String> attributes = PatientUtils.getAttributes(patient);

        BillingService billingService = Context.getService(BillingService.class);
        List<BillableService> services = billingService.getAllServices();
        Map<Integer, BillableService> mapServices = new HashMap<Integer, BillableService>();
        for (BillableService ser : services) {
            mapServices.put(ser.getConceptId(), ser);
        }
        Integer conceptId = Integer.valueOf(Context.getAdministrationService().getGlobalProperty(
                "billing.rootServiceConceptId"));
        Concept concept = Context.getConceptService().getConcept(conceptId);
        model.addAttribute("tabs", billingService.traversTab(concept, mapServices, 1));
        model.addAttribute("patientId", patientId);

        PatientServiceBill bill = billingService.getPatientServiceBillById(billId);
        model.addAttribute("freeBill", bill.getFreeBill());
        model.addAttribute("waiverAm", bill.getWaiverAmount());
        model.addAttribute("bill", bill);
        model.addAttribute("patient", patient);
        model.addAttribute("category", patient.getAttribute(14));
        model.addAttribute("fileNumber", patient.getAttribute(43));
        model.addAttribute("age", patient.getAge());

        if (patient.getGender().equals("M")) {
            model.addAttribute("gender", "Male");
        }
        if (patient.getGender().equals("F")) {
            model.addAttribute("gender", "Female");
        }

    }


    public String post(Model model, Object command, BindingResult bindingResult, HttpServletRequest request,
                           @RequestParam("cons") Integer[] cons, @RequestParam("patientId") Integer patientId,
                           @RequestParam("billId") Integer billId, @RequestParam("action") String action,
                           @RequestParam(value = "description", required = false) String description,
                           @RequestParam(value = "waiverAmountEdit", required = false) BigDecimal waiverAmount,
                           @RequestParam(value = "waiverNumber", required = false) String waiverNumber) {

        validate(cons, bindingResult, request);
        if (bindingResult.hasErrors()) {
            model.addAttribute("errors", bindingResult.getAllErrors());
            return "module/billing/main/patientServiceBillEdit";
        }
        BillingService billingService = Context.getService(BillingService.class);

        PatientServiceBill bill = billingService.getPatientServiceBillById(billId);
        // Get the BillCalculator to calculate the rate of bill item the patient
        // has to pay
        Patient patient = Context.getPatientService().getPatient(patientId);
        Map<String, String> attributes = PatientUtils.getAttributes(patient);

        BillCalculatorForBDService calculator = new BillCalculatorForBDService();

        if (!"".equals(description))
            bill.setDescription(description);

        if ("void".equalsIgnoreCase(action)) {
            bill.setVoided(true);
            bill.setVoidedDate(new Date());
            for (PatientServiceBillItem item : bill.getBillItems()) {
                item.setVoided(true);
                item.setVoidedDate(new Date());
				/*ghanshyam 7-sept-2012 these 5 lines of code written only due to voided item is being updated in "billing_patient_service_bill_item" table
				  but not being updated in "orders" table */
                Order ord = item.getOrder();
                if (ord != null) {
                    ord.setVoided(true);
                    ord.setDateVoided(new Date());
                }
                item.setOrder(ord);
            }
            billingService.savePatientServiceBill(bill);
            //ghanshyam 7-sept-2012 Support #343 [Billing][3.2.7-SNAPSHOT]No Queue to be generated from Old bill
            return "redirect:/module/billing/patientServiceBillEditForBD.list?patientId=" + patientId;
        }

        // void old items and reset amount
        Map<Integer, PatientServiceBillItem> mapOldItems = new HashMap<Integer, PatientServiceBillItem>();
        for (PatientServiceBillItem item : bill.getBillItems()) {
            item.setVoided(true);
            item.setVoidedDate(new Date());
            //ghanshyam-kesav 16-08-2012 Bug #323 [BILLING] When a bill with a lab\radiology order is edited the order is re-sent
            Order ord = item.getOrder();
			/*ghanshyam 18-08-2012 [Billing - Bug #337] [3.2.7 snap shot][billing(DDU,DDU SDMX,Tanda,mohali)]error in edit bill.
			  the problem was while we are editing the bill of other than lab and radiology.
			*/
            if (ord != null) {
                ord.setVoided(true);
                ord.setDateVoided(new Date());
            }
            item.setOrder(ord);
            mapOldItems.put(item.getPatientServiceBillItemId(), item);
        }
        bill.setAmount(BigDecimal.ZERO);
        bill.setPrinted(false);

        PatientServiceBillItem item;
        int quantity = 0;
        Money itemAmount;
        Money mUnitPrice;
        Money totalAmount = new Money(BigDecimal.ZERO);
        BigDecimal totalActualAmount = new BigDecimal(0);
        BigDecimal unitPrice;
        String name;
        BillableService service;

        for (int conceptId : cons) {

            unitPrice = NumberUtils.createBigDecimal(request.getParameter(conceptId + "_unitPrice"));
            quantity = NumberUtils.createInteger(request.getParameter(conceptId + "_qty"));
            name = request.getParameter(conceptId + "_name");
            service = billingService.getServiceByConceptId(conceptId);

            mUnitPrice = new Money(unitPrice);
            itemAmount = mUnitPrice.times(quantity);
            totalAmount = totalAmount.plus(itemAmount);

            String sItemId = request.getParameter(conceptId + "_itemId");

            if (sItemId == null) {
                item = new PatientServiceBillItem();

                // Get the ratio for each bill item
                Map<String, Object> parameters = HospitalCoreUtils.buildParameters("patient", patient, "attributes",
                        attributes, "billItem", item);
                BigDecimal rate;
                //ghanshyam 25-02-2013 New Requirement #966[Billing]Add Paid Bill/Add Free Bill for Bangladesh module
                //ghanshyam 3-june-2013 New Requirement #1632 Orders from dashboard must be appear in billing queue.User must be able to generate bills from this queue
                if (bill.getFreeBill().equals(1)) {
                    String billType = "free";
                    rate = calculator.getRate(parameters, billType);
                } else if (bill.getFreeBill().equals(2)) {
                    String billType = "mixed";
                    PatientServiceBillItem patientServiceBillItem = billingService
                            .getPatientServiceBillItem(billId, name);
                    String psbi= patientServiceBillItem.getActualAmount().toString();
                    if (psbi.equals("0.00")) {
                        rate = new BigDecimal(0);
                    } else {
                        rate = new BigDecimal(1);
                    }
                    item.setActualAmount(item.getAmount().multiply(rate));
                }else {
                    String billType = "paid";
                    rate = calculator.getRate(parameters, billType);
                }

                item.setAmount(itemAmount.getAmount());
                item.setActualAmount(item.getAmount().multiply(rate));
                totalActualAmount = totalActualAmount.add(item.getActualAmount());
                item.setCreatedDate(new Date());
                item.setName(name);
                item.setPatientServiceBill(bill);
                item.setQuantity(quantity);
                item.setService(service);
                item.setUnitPrice(unitPrice);
                bill.addBillItem(item);
            } else {

                item = mapOldItems.get(Integer.parseInt(sItemId));

                // Get the ratio for each bill item
                Map<String, Object> parameters = HospitalCoreUtils.buildParameters("patient", patient, "attributes",
                        attributes, "billItem", item);
                BigDecimal rate;
                //ghanshyam 25-02-2013 New Requirement #966[Billing]Add Paid Bill/Add Free Bill for Bangladesh module
                //ghanshyam 3-june-2013 New Requirement #1632 Orders from dashboard must be appear in billing queue.User must be able to generate bills from this queue
                if (bill.getFreeBill().equals(1)) {
                    String billType = "free";
                    rate = calculator.getRate(parameters, billType);
                } else if (bill.getFreeBill().equals(2)) {
                    String billType = "mixed";
                    PatientServiceBillItem patientServiceBillItem = billingService
                            .getPatientServiceBillItem(billId, name);
                    String psbi= patientServiceBillItem.getActualAmount().toString();
                    if (psbi.equals("0.00")) {
                        rate = new BigDecimal(0);
                    } else {
                        rate = new BigDecimal(1);
                    }
                    item.setActualAmount(item.getAmount().multiply(rate));
                }else {
                    String billType = "paid";
                    rate = calculator.getRate(parameters, billType);
                }

                //ghanshyam 5-oct-2012 [Billing - Support #344] [Billing] Edited Quantity and Amount information is lost in database
                if (quantity != item.getQuantity()) {
                    item.setVoided(true);
                    item.setVoidedDate(new Date());
                } else {
                    item.setVoided(false);
                    item.setVoidedDate(null);
                }
                // ghanshyam-kesav 16-08-2012 Bug #323 [BILLING] When a bill with a lab\radiology order is edited the order is re-sent
                Order ord = item.getOrder();
                if (ord != null) {
                    ord.setVoided(false);
                    ord.setDateVoided(null);
                }
                item.setOrder(ord);
                //ghanshyam 5-oct-2012 [Billing - Support #344] [Billing] Edited Quantity and Amount information is lost in database
                if (quantity != item.getQuantity()) {
                    item = new PatientServiceBillItem();
                    item.setService(service);
                    item.setUnitPrice(unitPrice);
                    item.setQuantity(quantity);
                    item.setName(name);
                    item.setCreatedDate(new Date());
                    item.setOrder(ord);
                    bill.addBillItem(item);
                }
                item.setAmount(itemAmount.getAmount());
                item.setActualAmount(item.getAmount().multiply(rate));

                totalActualAmount = totalActualAmount.add(item.getActualAmount());
            }
        }
        bill.setAmount(totalAmount.getAmount());
        bill.setActualAmount(totalActualAmount);
		/*added waiver amount */
        if(waiverAmount != null){
            bill.setWaiverAmount(waiverAmount);
        }
        else {
            BigDecimal wavAmt = new BigDecimal(0);
            bill.setWaiverAmount(wavAmt);
        }

        if(waiverNumber != null && waiverNumber !=""){
            bill.setPatientCategory("Waiver Number - "+waiverNumber);
        }


        // Determine whether the bill is free or not

        //ghanshyam 25-02-2013 New Requirement #966[Billing]Add Paid Bill/Add Free Bill for Bangladesh module
        //ghanshyam 3-june-2013 New Requirement #1632 Orders from dashboard must be appear in billing queue.User must be able to generate bills from this queue
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

        logger.info("Is free bill: " + bill.getFreeBill());

        bill = billingService.savePatientServiceBill(bill);
        //ghanshyam 7-sept-2012 Support #343 [Billing][3.2.7-SNAPSHOT]No Queue to be generated from Old bill

        return "redirect:/module/billing/patientServiceBillEditForBD.list?patientId=" + patientId + "&billId=" + billId;
    }
    private void validate(Integer[] ids, BindingResult binding, HttpServletRequest request) {
        for (int id : ids) {
            try {
                Integer.parseInt(request.getParameter(id + "_qty"));
            }
            catch (Exception e) {
                binding.reject("billing.bill.quantity.invalid", "Quantity is invalid");
                return;
            }
        }
    }

}

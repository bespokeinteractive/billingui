package org.openmrs.module.billingui.page.controller;

import org.openmrs.Concept;
import org.openmrs.Patient;
import org.openmrs.api.context.Context;
import org.openmrs.module.hospitalcore.BillingService;
import org.openmrs.module.hospitalcore.model.BillableService;
import org.openmrs.module.hospitalcore.util.PatientUtils;
import org.openmrs.ui.framework.SimpleObject;
import org.openmrs.ui.framework.UiUtils;
import org.openmrs.ui.framework.page.PageModel;
import org.springframework.web.bind.annotation.RequestParam;

import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * @author Stanslaus Odhiambo
 *         Created on 2/22/2016.
 */
public class BillableServiceBillAddPageController {

    public void get(PageModel pageModel, @RequestParam("patientId") Integer patientId,
                    @RequestParam(value = "comment", required = false) String comment,
                    @RequestParam(value = "billType", required = false) String billType,
                    @RequestParam(value = "encounterId", required = false) Integer encounterId,
                    @RequestParam(value = "typeOfPatient", required = false) String typeOfPatient,
                    UiUtils uiUtils) {
        Patient patient = Context.getPatientService().getPatient(patientId);
        Map<String, String> attributes = PatientUtils.getAttributes(patient);
        BillingService billingService = Context.getService(BillingService.class);
        List<BillableService> services = billingService.getAllServices();
        pageModel.addAttribute("services", services);
        Map<Integer, BillableService> mapServices = new HashMap<Integer, BillableService>();
        for (BillableService ser : services) {
            mapServices.put(ser.getConceptId(), ser);
        }
        Integer conceptId = Integer.valueOf(Context.getAdministrationService().getGlobalProperty(
                "billing.rootServiceConceptId"));
        Concept concept = Context.getConceptService().getConcept(conceptId);
        pageModel.addAttribute("tabs", billingService.traversTab(concept, mapServices, 1));

        pageModel.addAttribute("patientId", patientId);
        pageModel.addAttribute("patient", patient);
        pageModel.addAttribute("attributes",attributes);
        if (patient.getGender().equals("M")) {
            pageModel.addAttribute("gender", "Male");
        }
        if (patient.getGender().equals("F")) {
            pageModel.addAttribute("gender", "Female");
        }
        pageModel.addAttribute("age", patient.getAge());
        pageModel.addAttribute("currentDate",new Date());
        pageModel.addAttribute("category", patient.getAttribute(14));
        pageModel.addAttribute("fileNumber", patient.getAttribute(43));

    }
}

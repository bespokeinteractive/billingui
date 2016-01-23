package org.openmrs.module.billingui.page.controller;

import org.openmrs.Patient;
import org.openmrs.api.context.Context;
import org.openmrs.module.hospitalcore.BillingService;
import org.openmrs.module.hospitalcore.HospitalCoreService;
import org.openmrs.module.hospitalcore.model.BillableService;
import org.openmrs.module.hospitalcore.model.PatientSearch;
import org.openmrs.ui.framework.page.PageModel;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestParam;

import java.util.List;

/**
 * @author Stanslaus Odhiambo
 * Created  on 1/23/2016.
 */
public class ProcedureInvestigationOrderPageController {

    public void get(PageModel model, @RequestParam("patientId") Integer patientId,
                       @RequestParam("encounterId") Integer encounterId,
                       @RequestParam(value = "date", required = false) String dateStr) {
        BillingService billingService = Context.getService(BillingService.class);
        List<BillableService> serviceOrderList = billingService.listOfServiceOrder(patientId,encounterId);
        model.addAttribute("serviceOrderList", serviceOrderList);
        model.addAttribute("serviceOrderSize", serviceOrderList.size());
        model.addAttribute("patientId", patientId);
        model.addAttribute("encounterId", encounterId);
        HospitalCoreService hospitalCoreService = Context.getService(HospitalCoreService.class);
        PatientSearch patientSearch = hospitalCoreService.getPatientByPatientId(patientId);
        Patient patient = Context.getPatientService().getPatient(patientId);
        model.addAttribute("age",patient.getAge());
        model.addAttribute("category",patient.getAttribute(14));
        model.addAttribute("fileNumber",patient.getAttribute(43));
        if(patient.getGender().equals("M"))
        {
            model.addAttribute("gender","Male");
        }
        if(patient.getGender().equals("F"))
        {
            model.addAttribute("gender","Female");
        }

        model.addAttribute("patientSearch", patientSearch);
        model.addAttribute("date", dateStr);
    }
}

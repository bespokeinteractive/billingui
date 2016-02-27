/**
 * Copyright 2013 Society for Health Information Systems Programmes, India (HISP India)
 * <p/>
 * This file is part of Billing module.
 * <p/>
 * Billing module is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * <p/>
 * Billing module is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * <p/>
 * You should have received a copy of the GNU General Public License
 * along with Billing module.  If not, see <http://www.gnu.org/licenses/>.
 * <p/>
 * author: ghanshyam
 * date: 3-june-2013
 * issue no: #1632
 **/

package org.openmrs.module.billingui.page.controller;
import org.apache.commons.lang.StringUtils;
import org.openmrs.Patient;
import org.openmrs.api.PatientService;
import org.openmrs.api.context.Context;
import org.openmrs.module.hospitalcore.BillingService;
import org.openmrs.module.hospitalcore.HospitalCoreService;
import org.openmrs.module.hospitalcore.model.OpdTestOrder;
import org.openmrs.module.hospitalcore.model.PatientSearch;
import org.openmrs.ui.framework.page.PageModel;
import org.springframework.web.bind.annotation.RequestParam;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;

public class ListOfOrderPageController {

    public void get(PageModel model, @RequestParam("patientId") Integer patientId,
                    @RequestParam(value = "date", required = false) String dateStr) {
        BillingService billingService = Context
                .getService(BillingService.class);
        PatientService patientService = Context.getPatientService();
        Patient patient = patientService.getPatient(patientId);
        SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy");
        Date date = null;
        try {
            date = sdf.parse(dateStr);
        } catch (ParseException e) {
            e.printStackTrace();
        }
        List<OpdTestOrder> listOfOrders = billingService.listOfOrder(patientId, date);
        // Add Patient Details on the page where Order ID is clicked
        HospitalCoreService hospitalCoreService = Context.getService(HospitalCoreService.class);
        PatientSearch patientSearch = hospitalCoreService.getPatientByPatientId(patientId);

        model.addAttribute("age", patient.getAge());

        if (patient.getGender().equals("M")) {
            model.addAttribute("gender", "Male");
        }
        if (patient.getGender().equals("F")) {
            model.addAttribute("gender", "Female");
        }
        model.addAttribute("category", patient.getAttribute(14));
        model.addAttribute("previousVisit",hospitalCoreService.getLastVisitTime(patient));

        if (patient.getAttribute(43) == null){
            model.addAttribute("fileNumber", "");
        }
        else if (StringUtils.isNotBlank(patient.getAttribute(43).getValue())){
            model.addAttribute("fileNumber", "(File: "+patient.getAttribute(43)+")");
        }
        else {
            model.addAttribute("fileNumber", "");
        }
        /*
		if(patient.getAttribute(14).getValue() == "Waiver"){
			model.addAttribute("exemption", patient.getAttribute(32));
		}
		else if(patient.getAttribute(14).getValue()!="General" && patient.getAttribute(14).getValue()!="Waiver"){
			model.addAttribute("exemption", patient.getAttribute(36));
		}
		else {
			model.addAttribute("exemption", " ");
		}
		*/

        model.addAttribute("patientSearch", patientSearch);
        model.addAttribute("listOfOrders", listOfOrders);
        model.addAttribute("patientId", patientId);
        model.addAttribute("date", dateStr);
    }
}

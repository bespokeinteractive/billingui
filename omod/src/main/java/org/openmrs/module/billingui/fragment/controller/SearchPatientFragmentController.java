package org.openmrs.module.billingui.fragment.controller;

import org.hibernate.validator.constraints.SafeHtml;
import org.openmrs.Patient;
import org.openmrs.api.context.Context;
import org.openmrs.module.billingui.PatientWrapper;
import org.openmrs.module.hospitalcore.HospitalCoreService;
import org.openmrs.module.hospitalcore.util.HospitalCoreConstants;
import org.openmrs.ui.framework.SimpleObject;
import org.openmrs.ui.framework.UiUtils;
import org.springframework.web.bind.annotation.RequestParam;

import javax.servlet.http.HttpServletRequest;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.regex.Matcher;

/**
 * Created by USER on 2/9/2016.
 */
public class SearchPatientFragmentController {
    /**
     * The controller method handles both the GET and POST requests if none is
     * explicitly defined
     */
    public void controller(){}

    public List<SimpleObject> searchSystemPatient(
            @RequestParam(value = "searchKey", required = false) String phrase,
            @RequestParam(value = "currentPage", required = false) Integer currentPage,
            @RequestParam(value = "pageSize", required = false) Integer pageSize,
            UiUtils uiUtils,
            HttpServletRequest request) {
        String prefix = Context.getAdministrationService().getGlobalProperty(
                HospitalCoreConstants.PROPERTY_IDENTIFIER_PREFIX);
//        model.addAttribute("prefix", prefix);
        if (phrase.contains("-") && !phrase.contains(prefix)) {
            phrase = prefix + phrase;
        }

        String gender = request.getParameter("gender");
        if (gender.equalsIgnoreCase("any"))
            gender = null;
        Integer age = getInt(request.getParameter("age"));
        Integer ageRange = getInt(request.getParameter("ageRange"));
        String relativeName = request.getParameter("relativeName");
        String date = request.getParameter("date");
        Integer dateRange = getInt(request.getParameter("dateRange"));

        HospitalCoreService hcs = (HospitalCoreService) Context
                .getService(HospitalCoreService.class);
        List<Patient> patients = hcs.searchPatient( phrase, gender,  age, ageRange,  date, dateRange, relativeName);
        List<PatientWrapper> wrapperList = patientsWithLastVisit(patients);
        return SimpleObject.fromCollection(wrapperList, uiUtils, "wrapperIdentifier","names", "age", "gender","lastVisitTime");
    }
    private Integer getInt(String value) {
        try {
            Integer number = Integer.parseInt(value);
            return number;
        } catch (Exception e) {
            return 0;
        }
    }
    private List<PatientWrapper> patientsWithLastVisit(List<Patient> patients){
        HospitalCoreService hcs = Context.getService(HospitalCoreService.class);
        List<PatientWrapper> wrappers = new ArrayList<PatientWrapper>();
        for (Patient patient : patients) {
            wrappers.add(new PatientWrapper(patient, hcs.getLastVisitTime(patient)));
        }
        return  wrappers;
    }
}


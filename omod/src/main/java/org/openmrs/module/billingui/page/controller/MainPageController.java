package org.openmrs.module.billingui.page.controller;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.openmrs.Patient;
import org.openmrs.api.context.Context;
import org.openmrs.ui.framework.page.PageModel;
import org.springframework.web.bind.annotation.RequestParam;

import java.util.List;

/**
 * Created by ngarivictor on 1/19/2016.
 */
public class MainPageController {

        private Log log = LogFactory.getLog(this.getClass());

        /*@RequestMapping(method= RequestMethod.GET)*/
        public void get(PageModel model){

            String prefix = Context.getAdministrationService().getGlobalProperty("registration.identifier_prefix");
            model.addAttribute("idPrefix", prefix);

        }
    /*@RequestMapping(method=RequestMethod.POST)*/
    public void submit(PageModel model, @RequestParam("identifier") String identifier){

        String prefix = Context.getAdministrationService().getGlobalProperty("registration.identifier_prefix");
        if( identifier.contains("-") && !identifier.contains(prefix)){
            identifier = prefix+identifier;
        }
        List<Patient> patientsList = Context.getPatientService().getPatients( identifier.trim() );
        model.addAttribute("patients", patientsList);


    }



}

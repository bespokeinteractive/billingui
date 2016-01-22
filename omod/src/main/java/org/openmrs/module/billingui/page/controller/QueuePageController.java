package org.openmrs.module.billingui.page.controller;

import org.openmrs.ui.framework.page.PageModel;

import java.text.SimpleDateFormat;
import java.util.Date;

/**
 * Created by ngarivictor on 1/20/2016.
 */
public class QueuePageController {
    public void get(PageModel model){
        SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy");
        String dateStr = sdf.format(new Date());
        model.addAttribute("currentDate", dateStr);


    }

}

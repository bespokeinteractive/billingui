package org.openmrs.module.billingui.page.controller;

import org.openmrs.ui.framework.page.PageModel;

import java.text.SimpleDateFormat;
import java.util.Date;

/**
 * @author  Stanslaus Odhiambo
 * Created on 1/21/2016.
 */
public class BillingQueuePageController {

    public void get(PageModel pageModel) {
        SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy");
        String dateStr = sdf.format(new Date());
        pageModel.addAttribute("currentDate", dateStr);
    }

}

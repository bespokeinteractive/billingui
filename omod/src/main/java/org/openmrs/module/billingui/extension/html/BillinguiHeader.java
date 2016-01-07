package org.openmrs.module.billingui.extension.html;

import org.openmrs.module.web.extension.LinkExt;

/**
 * Created by HP on 1/7/2016.
 */
public class BillinguiHeader extends LinkExt {
    @Override
    public String getLabel() {
        return "billingui.title";
    }

    @Override
    public String getUrl() {
        return "billingui/cashier.page";
    }

    @Override
    public String getRequiredPrivilege() {
        return "View Locations";
    }
    public MEDIA_TYPE getMediaType() {
        return MEDIA_TYPE.html;
    }
}

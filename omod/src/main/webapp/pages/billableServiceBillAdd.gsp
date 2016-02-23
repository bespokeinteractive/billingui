<%
    ui.decorateWith("appui", "standardEmrPage", [title: "Cashier - Add Patient Bill"])
    ui.includeCss("uicommons", "styleguide/index.css")
    ui.includeCss("billingui", "paging.css")
    ui.includeJavascript("billingui", "paging.js")
    ui.includeJavascript("billingui", "common.js")
    ui.includeJavascript("billingui", "jquery-ui-1.8.2.custom.min.js")
    ui.includeJavascript("billingui", "jquery.PrintArea.js")

%>
<openmrs:require privilege="Add Bill" otherwise="/login.htm"
                 redirect="/module/billing/main.form" />
${tabs }


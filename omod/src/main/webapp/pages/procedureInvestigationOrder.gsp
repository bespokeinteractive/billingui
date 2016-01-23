<%
    ui.decorateWith("appui", "standardEmrPage", [title: "Cashier Module"])
    ui.includeCss("uicommons", "styleguide/index.css")
//    ui.includeJavascript("billingui", "moment.js")
//    ui.includeJavascript("billingui", "jquery.dataTables.min.js")
    def props = ["sno", "orderid", "date", "sentfrom"]
%>
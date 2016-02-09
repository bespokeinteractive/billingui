<%
    ui.decorateWith("appui", "standardEmrPage", [title: "Cashier Module"])
    ui.includeCss("uicommons", "styleguide/index.css")
    ui.includeCss("billingui", "paging.css")
    ui.includeJavascript("billingui", "paging.js")
    ui.includeJavascript("billingui", "common.js")
    ui.includeJavascript("billingui", "jquery-ui-1.8.2.custom.min.js")
    ui.includeJavascript("billingui", "jquery.PrintArea.js")

//    ui.includeJavascript("billingui", "jquery.dataTables.min.js")
    def props = ["sno", "service", "select", "quantity", "pay", "unitprice", "itemtotal"]
%>
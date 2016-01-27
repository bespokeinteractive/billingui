<%
    ui.decorateWith("appui", "standardEmrPage", [title: "Cashier Module"])
    ui.includeCss("uicommons", "styleguide/index.css")
//    ui.includeJavascript("billingui", "moment.js")
//    ui.includeJavascript("billingui", "jquery.dataTables.min.js")
    //    ui.includeJavascript("billingui", "jquery.dataTables.min.js")
    def props = ["sno", "orderid", "date", "sentfrom"]
%>
<script type="text/javascript">
    var breadcrumbs = [
        {icon: "icon-home", link: '/' + OPENMRS_CONTEXT_PATH + '/index.htm'},
        {label: "<a href='#'>Patient Summary (${patientSearch.givenName} &nbsp;${patientSearch.familyName}&nbsp;${(patientSearch.middleName)?.replace(',',' ')})</a>"}
    ]

    jQuery(function () {

        jq('#queueList > tbody > tr').remove();
        var tbody = jq('#queueList > tbody');
        for (index in ${listOfOrders}) {
            var item = ${listOfOrders}[index];
            var row = '<tr>';
            <% props.each {
               if(it == props.last()){
                  def pageLink = ui.pageLink("patientdashboardui", "main") %>
            row += '<td> <a href="${pageLink}?patientId=' + item.patient.id + '&opdId=' + jq("#opd-choice").val() + '"><i class="icon-signin small"></i></a> </td>';
            <% } else {%>
            row += '<td>' + item.${ it } + '</td>';
            <% }
               } %>
            row += '</tr>';
            tbody.append(row);
        }
    });
</script>

<div class="clear"></div>

<div class="container">

    <div class="patient-header new-patient-header">
        <div class="demographics">
            <h1 class="name">
                <span><small>${patientSearch.familyName}</small>,<em>surname</em></span>
                <span><small>${patientSearch.givenName} &nbsp;${(patientSearch.middleName)?.replace(',', ' ')}</small><em>name</em>
                </span>
            </h1>

            <div class="gender-age">
                <span>${gender}</span>
                <span>${age} year(s)</span>
            </div>
            <br>

            <div class="status-container">
                <span class="status active"></span>
                Active Visit
            </div>

            <div class="tag">Outpatient (File Number :${fileNumber})</div>
        </div>

        <div class="identifiers">
            <em>Patient ID</em>
            <span>${patientSearch.identifier}</span>
            <em>Payment Category</em>
            <span>${category}</span>
        </div>

        <div class="identifiers">
            <em>Date/ Time:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</em>
            <span>${date}</span>

        </div>
    </div>

    <div class="dashboard clear">
        <div class="info-container">
            <div class="info-header">
                <i class="icon-calendar"></i>

                <h3>Orders</h3>
            </div>
        </div>
        <br/>
        <table cellpadding="5" cellspacing="0" width="100%" id="queueList" class="tablesorter thickbox">
            <thead>
            <tr align="center">
                <th>S.No</th>
                <th>Order ID</th>
                <th>Date</th>
                <th>Sent From</th>
            </tr>
            </thead>
            <tbody>

            <% if (listOfOrders != null || listOfOrders != "") { %>
            <% listOfOrders.each { queue -> %>
            <tr align="center">
                <td>${queue.opdOrderId}</td>
                <td><a class="button task"
                       href="${ui.pageLink("billingui", "procedureInvestigationOrder", [patientId: queue.patient.patientId, encounterId:queue.encounter.encounterId,date:date])}">
                    <i class="icon-signout"></i>${queue.encounter.encounterId}</a></td>
                <td>${date}</td>
                <td>${queue.fromDept}</td>
            </tr>
            <% } %>

            <% } else { %>
            <tr align="center">
                <td colspan="4">No Orders Found</td>
            </tr>
            <% } %>

            </tbody>
        </table>
    </div>
</div>

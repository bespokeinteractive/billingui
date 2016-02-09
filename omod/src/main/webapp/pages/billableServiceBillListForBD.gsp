<% import org.apache.commons.lang.StringUtils; %>
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
<style>
.form-textbox {
    height: 12px !important;
    font-size: 12px !important;
}

.hidden {
    display: none;
}
</style>
<style>
@media print {
    .donotprint {
        display: none;
    }

    .spacer {
        margin-top: 70px;
        font-family: "Dot Matrix Normal", Arial, Helvetica, sans-serif;
        font-style: normal;
        font-size: 14px;
    }

    .printfont {
        font-family: "Dot Matrix Normal", Arial, Helvetica, sans-serif;
        font-style: normal;
        font-size: 14px;
    }
}
</style>

<script type="text/javascript">
    jQuery(document).ready(
            function () {
                // hide comment
                jQuery("#commentField").hide();
                jQuery("#okButton").hide();
            });
</script>
<script type="text/javascript">
    function showAndHide() {
        jQuery("#commentField").toggle();
        jQuery("#okButton").toggle();
    }
</script>

<script type="text/javascript">
    function validate() {
        if (StringUtils.isBlank(jQuery("#comment").val())) {
            alert("Please enter comment");
            return false;
        }
        else {

            var patientId = ${patient.patientId};
            var billType = "free";
            var comment = jQuery("#comment").val();
            window.location.href = emr.pageLink("billingui", "addPatientServiceBillForBD", {
                "patientId": patientId,
                "billType": billType,
                "comment": comment
            });
        }
    }
</script>


<div class="clear"></div>

<div class="container">

    <div class="patient-header new-patient-header">
        <div class="demographics">
            <h1 class="name">
                <span><small>${patient.familyName}</small>,<em>surname</em></span>
                <span><small>${patient.givenName} &nbsp;${(patient.middleName)?.replace(',', ' ')}</small><em>name</em>
                </span>
            </h1>

            <div class="gender-age">
                <span>${gender}</span>
                <span>${age} year(s)</span>
            </div>
            <br>

            <div class="status-container">
                <span class="status active"></span>
                Date/ Time: ${bill.createdDate}
            </div>

            <div class="tag">Bill ID :${bill.receipt.id} - File Number : ${fileNumber}</div>
        </div>

        <div class="identifiers">
            <em>Patient ID</em>
            <span>${patient.patientIdentifier.identifier}</span>
            <em>Payment Category</em>
            <span>${category}</span>
        </div>
    </div>

    <% if (!patient.dead) { %>
    <p>
        <b>
            <td><input type="button" value="Add Paid Bill"
                       onclick="window.location.href = 'addPatientServiceBillForBD.page?patientId=${patient.patientId}&billType=paid'"/>
            </td>
            <td><input type="button" value="Add Free Bill" style="color: red"
                       onclick="showAndHide();"/></td>
            <td><span id="commentField">Comment <input id="comment"
                                                       name="comment"/></span>
            </td>
            <td><span id="okButton"><input type="button" value="Ok"
                                           onclick="return validate();"/></span></td></b>
    </p>
    <% } %>



    <table width="100%" border="1" cellpadding="5" cellspacing="0" id="myTable" class="tablesorter thickbox">

        <thead>
        <tr>
            <th align="center">Service Name</th>
            <th align="center">Price (KSh)</th>
            <th align="center">Quantity</th>
            <th align="center">Amount</th>
        </tr>
        </thead>
        <tbody>

        <% bill.billItems.each { %>
        <% if (bill.voidedDate == null) { %>
        <% if (it.name != 'INPATIENT DEPOSIT') { %>
        <tr>
            <td>${it.name}</td>
            <td align="right">${it.unitPrice}</td>
            <td align="right">${it.quantity}</td>
            <td class="printfont" height="20" align="right" style="">
                <% if (it.actualAmount != null) { %>
                <% if (it.actualAmount == it.amount) { %>
                <% if (it.voidedDate != null) { %>
                <span style="text-decoration: line-through;">${item.amount}</span>
                <% } else { %>
                ${it.amount}
                <% } %>
                <% } else { %>

                <span style="text-decoration: line-through;">${item.amount}</span>
                <b>${item.actualAmount}</b>
                <% } %>
                <% } else { %>
                ${item.amount}
                <% } %>
            </td>
        </tr>
        <% } %>
        <% } %>
        <% } %>
        <% def initialtotal = 0 %>
        <% bill.billItems.each { %>
        <% if (it.name.equalsIgnoreCase("INPATIENT DEPOSIT")) {
            initialtotal += it.amount
        }
        %>
        <% } %>

        <tr>
            <td colspan="3" align='right'><b>Total</b></td>
            <td align="right">
                <% if (bill.actualAmount != null) { %>
                <% if (bill.actualAmount == bill.amount) { %>
                <% if (bill.voided) { %>
                <span style="text-decoration: line-through;"><b>${bill.amount - initialtotal}</b>
                </span>
                <% } else { %>
                <b>${bill.amount - initialtotal}</b>
                <% } %>
                <% } else { %>
                <span style="text-decoration: line-through;">${bill.amount - initialtotal}</span>
                <% if (bill.voided) { %>
                <span style="text-decoration: line-through;"><b>${bill.actualAmount - initialtotal}</b>
                </span>
                <% } else { %>
                <b>${bill.actualAmount - initialtotal}</b>
                <% } %>
                <% } %>
                <% } else { %>
                ${bill.amount - initialtotal}
                <% } %>
            </td>
        </tr>
        <% bill.billItems.each { %>
        <% if (it.voidedDate == null) { %>
        <% if (it.name.equalsIgnoreCase("INPATIENT DEPOSIT")) { %>
        <tr>
            <td colspan="3" align='right'>Amount Paid as Advance</td>
            <td class="printfont" height="20" align="right" style="">
                <% if (StringUtils.isNotBlank(it.actualAmount)) { %>
                <% if (it.actualAmount == it.amount) { %>
                ${it.amount}
                <% } else { %>
                <span style="text-decoration: line-through;">${it.amount}</span>
                <b>${it.actualAmount}</b>
                <% } %>

                <% } else { %>
                ${it.amount}
                <% } %>
            </td>
        </tr>
        <% } %>
        <% } %>
        <% } %>
        <tr>
            <td colspan="3" align='right'><b>Total Amount Paid as Advance</b></td>
            <td align="right"><b>${initialtotal}</b></td>
        </tr>

        <tr>
            <td colspan="3" align='right'><b>Waiver Amount(If any)</b></td>
            <td align="right"><b>${bill.waiverAmount}</b></td>
        </tr>
        <% if (bill.rebateAmount > 0) { %>
        <tr>
            <td colspan="3" align='right'><b>Rebate Amount</b></td>
            <td align="right"><b>${bill.rebateAmount}</b></td>
        </tr>
        <% } %>

        <tr>
            <td colspan="3" align='right'><b>Net Amount</b></td>
            <td align="right"><b>${bill.actualAmount - bill.waiverAmount - initialtotal}</b></td>
        </tr>
        </tbody>

    </table>

    <form method="POST" id="billForm">
        <center>
            <input type="button" value='Print'
                   onClick="printDiv2();"/>&nbsp;&nbsp;
        </center>
    </form>
</div>

<!-- PRINT DIV -->

<div id="printDiv" class="hidden"
     style="width: 1280px; font-size: 0.8em">
    <style>
    @media print {
        .donotprint {
            display: none;
        }

        .spacer {
            margin-top: 50px;
            font-family: "Dot Matrix Normal", Arial, Helvetica, sans-serif;
            font-style: normal;
            font-size: 14px;
        }

        .printfont {
            font-family: "Dot Matrix Normal", Arial, Helvetica, sans-serif;
            font-style: normal;
            font-size: 14px;
        }
    }
    </style>
    <input type="hidden" id="contextPath" value="openmrs"/>
    <img class="donotprint" src="${ui.resourceLink("billingui", "images/HEADEROPDSLIP.jpg")}" width="981" height="212"/>
    <center><img width="100" height="100" align="center" title="OpenMRS" alt="OpenMRS"
                 src="${ui.resourceLink("billingui", "images/kenya_logo.bmp")}"><center>
        <table class="spacer" style="margin-left: 30px;">
            <tr><h3><center><u><b>${userLocation}</b></u></center></h3>
            </tr>
            <tr><h5><center>CASH RECEIPT</center></h5>
            </tr>

            <tr>
                <td>Receipt No.</td>
                <td>:${bill.receipt.id}</td>
            </tr>
            <tr>
                <td>Date/Time</td>
                <td align="left">:${dateTime}</td>
            </tr>
            <tr>
                <td>Name</td>
                <td colspan="3">:${patient.givenName}&nbsp;${patient.familyName}&nbsp;${(patient.middleName)?.replace(',', ' ')}&nbsp;&nbsp;
                </td>
            </tr>
            <tr>
                <td>Patient ID</td>
                <td colspan="3">:${patient.patientIdentifier}</td>
            </tr>
            <tr>
                <td>Gender</td>
                <td>:${gender}</td>
            </tr>
            <tr>
                <td>Age</td>
                <td>:${age}</td>
            </tr>
            <tr>
                <td>Payment Category</td>
                <td>:${category}</td>
            </tr>
            <tr>
                <td>File Number</td>
                <td>:${fileNumber}</td>
            </tr>
            <% if (bill.voided) { %>
            <tr>
                <td>Bill Description</td>
                <td>:${bill.description}</td>
            </tr>
            <% } %>
        </table>
        <table class="printfont"
               style="margin-left: 30px; margin-top: 10px; font-family: 'Dot Matrix Normal', Arial, Helvetica, sans-serif; font-style: normal;"
               width="80%">
            <thead>
            <th class="printfont"><center>#</center></th>
            <th class="printfont"><center>Service</center></th>
            <th class="printfont"><center>Price (KSh)</center></th>
            <th class="printfont"><center>Quantity</center></th>
            <th class="printfont"><center>Amount</center></th>
            </thead>
            <% bill.billItems.eachWithIndex { item, status -> %>
            <% if (item.voidedDate == null) { %>
            <% if (!item.name.equalsIgnoreCase("INPATIENT DEPOSIT")) { %>
            <tr class='${status % 2 == 0 ? "oddRow" : "evenRow"}'>
                <td>${status}</td>
                <td class="printfont" height="20">${item.name}</td>
                <td class="printfont" height="20"><center>${item.unitPrice}</center></td>
                <td class="printfont" height="20"><center>${item.quantity}</center></td>
                <td class="printfont" height="20"><center>${item.actualAmount}</center></td>
            </tr>
            <% } %>
            <% } %>
            <% } %>


            <tr>
                <td>&nbsp;</td>
                <td align="right" colspan="3"><b>Total</b></td>
                <% if (bill.voided) { %>
                <td align="right"><center><span
                        style="text-decoration: line-through;"><b>${bill.actualAmount - initialtotal}</b></span>
                </center>
                </td>

                <% } else { %>
                <td align="right">${bill.actualAmount - initialtotal}</td>
                <% } %>
            </tr>

            <tr>
                <td>&nbsp;</td>
                <td colspan="3" align='right'><b>Amount Paid as Advance</b></td>
                <td align="right"><b>${initialtotal}</b></td>
            </tr>

            <tr>
                <td>&nbsp;</td>
                <td colspan="3" align='right'><b>Waiver Amount(If any)</b></td>
                <td align="right"><b>${bill.waiverAmount}</b></td>
            </tr>

            <% if (bill.rebateAmount > 0) { %>
            <tr>
                <td>&nbsp;</td>
                <td colspan="3" align='right'><b>Rebate Amount</b></td>
                <td align="right"><b>${bill.rebateAmount}</b></td>
            </tr>
            <% } %>


            <tr>
                <td>&nbsp;</td>
                <td colspan="3" align='right'><b>Net Amount</b></td>
                <td align="right"><b>${bill.actualAmount - bill.waiverAmount - initialtotal}</b></td>
            </tr>

        </table>


        <table class="spacer" style="margin-left: 60px;">
            <!-- 	<tr>
			<td>PAYMENT MODE :</td>
			<td><b>${paymentMode}</b></td>
		</tr> -->
            <tr>
                <td>CASHIER :</td>
                <td><b>${cashier}</b></td>
            </tr>
        </table>

        <br/> <br/> <br/> <br/> <br/> <span
                class="printfont" style="margin-left: 100px;">Signature of Billing Clerk/ Stamp</span>
    </center></center>

    <!-- END PRINT DIV -->
</div>

<script>
    function printDivNoJQuery() {
        var divToPrint = document.getElementById('printDiv');
        var newWin = window
                .open('', '',
                'letf=0,top=0,width=1,height=1,toolbar=0,scrollbars=0,status=0');
        newWin.document.write(divToPrint.innerHTML);
        newWin.print();
        newWin.close();
    }
    function printDiv2() {
        var printer = window.open('', '', 'width=300,height=300');
        printer.document.open("text/html");
        printer.document.write(document.getElementById('printDiv').innerHTML);
        printer.document.close();
        printer.window.close();
        printer.print();
        jQuery("#billForm").submit();
        //alert("Printing ...");
    }
</script>



<% if (listBill != null) { %>
<table class="box" style="position:relative;border:0px;">
    <tr><td>
        <span class="boxHeader"><b>List of Previous Bills</b></span>
    </td></tr>
    <tr><td>
        <table class="box">
            <thead>
            <th><center>#</center></th>
            <th>Bill ID</th>
            <th>Description</th>
            <th>Action</th>
            </thead>
            <% listBill.eachWithIndex { bill, index -> %>
            <tr class='${index % 2 == 0 ? "oddRow" : "evenRow"} '>
                <td align="center" class='<% if (bill.voided) { %>retired <% } %>'>
                    ${index + 1}
                </td>
                <td class='<% if (bill.voided) { %>retired <% } %>'>
                    <% if (bill.voided == false || (bill.printed == true && canEdit == true)) { %>
                    <a href="editPatientServiceBillForBD.page?billId=${bill.patientServiceBillId}&patientId=${
                            patient.patientId}">
                        <b>${bill.receipt.id}</b>,${bill.createdDate}</a>
                </td>
                <% } else { %>
                <b>${bill.receipt.id}</b>,
            ${bill.createdDate}
            <% } %>
                <td>
                    <% if (bill.description != null) { %>
                    ${bill.description}
                    <% } %>
                </td>
                <td class='<% if (bill.voided) { %>retired <% } %>'>
                    <% if (bill.voided) { %>
                    <input type="button" value="View" class="task"
                           onclick="javascript:window.location.href = 'patientServiceVoidedBillViewForBD.page?patientId=${patient.patientId}&billId=${bill.patientServiceBillId}'"/>
                    <% } else { %>
                    <input type="button" value="View" class="task"
                           onclick="javascript:window.location.href = 'patientServiceBillForBD.page?patientId=${patient.patientId}&billId=${bill.patientServiceBillId}'"/>
                    <% } %>
                </td>
            </tr>
            <% } %>
        </table>
    </td></tr>
</table>
<% } %>

<input type="hidden" id="total" value="${bill.actualAmount - bill.waiverAmount}">

<script>
    function printDiv() {
        jQuery("div#printDiv").printArea({
            mode: "iframe"
        });
        jQuery("#billForm").submit();
    }
    jQuery(document).ready(function () {
        jQuery("#totalValue2").html(toWords(jQuery("#total").val()));
    });
</script>



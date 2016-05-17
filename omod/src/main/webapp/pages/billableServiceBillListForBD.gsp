<% import org.apache.commons.lang.StringUtils; %>
<%
    ui.decorateWith("appui", "standardEmrPage", [title: "Service Bills"])
    ui.includeCss("uicommons", "styleguide/index.css")
    ui.includeCss("billingui", "paging.css")

    ui.includeJavascript("billingui", "moment.js")
    ui.includeJavascript("billingui", "paging.js")
    ui.includeJavascript("billingui", "common.js")
    ui.includeJavascript("billingui", "jquery-ui-1.8.2.custom.min.js")
    ui.includeJavascript("billingui", "jquery.PrintArea.js")

//    ui.includeJavascript("billingui", "jquery.dataTables.min.js")
    def props = ["sno", "service", "select", "quantity", "pay", "unitprice", "itemtotal"]
%>

<script type="text/javascript">
    jq(document).ready(function () {
        function strReplace(word) {
            var res = word.replace("[", "");
            res = res.replace("]", "");
            return res;
        }

        jq('#surname').html(strReplace('${patient.names.familyName}') + ',<em>surname</em>');
        jq('#othname').html(strReplace('${patient.names.givenName}') + ' &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; <em>other names</em>');
        jq('#agename').html('${patient.age} years (' + moment('${patient.birthdate}').format('DD,MMM YYYY') + ')');

        jq("#commentField").hide();
        jq("#okButton").hide();

        jq('#initialtotal').text(formatAccounting(jq('#initialtotal').text().trim()));
        jq("#totalValue2").html(toWords(jq("#total").val()));

        jq('.cancel').on('click', function () {
            jq("#commentField").toggle();
            jq("#okButton").toggle();
        });

        jq('.confirm').on('click', function () {
            printDiv2();
        });
    });

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

    function printDiv() {
        jQuery("div#printDiv").printArea({
            mode: "iframe"
        });
        jQuery("#billForm").submit();
    }
    jQuery(document).ready(function () {

    });
</script>

<style>
.form-textbox {
    height: 12px !important;
    font-size: 12px !important;
}

.hidden {
    display: none;
}

.retired {
    text-decoration: line-through;
    color: darkgrey;
}

#breadcrumbs a, #breadcrumbs a:link, #breadcrumbs a:visited {
    text-decoration: none;
}

.new-patient-header .demographics .gender-age {
    font-size: 14px;
    margin-left: -55px;
    margin-top: 12px;
}

.new-patient-header .demographics .gender-age span {
    border-bottom: 1px none #ddd;
}

.new-patient-header .identifiers {
    margin-top: 5px;
}

.tag {
    padding: 2px 10px;
}

.tad {
    background: #666 none repeat scroll 0 0;
    border-radius: 1px;
    color: white;
    display: inline;
    font-size: 0.8em;
    margin-left: 4px;
    padding: 2px 10px;
}

.status-container {
    padding: 5px 10px 5px 5px;
}

.catg {
    color: #363463;
    margin: 35px 10px 0 0;
}

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

.formfactor {
    background: #f3f3f3 none repeat scroll 0 0;
    border: 1px solid #ddd;
    margin-bottom: 5px;
    margin-top: 5px;
    min-height: 38px;
    padding: 5px 10px;
    text-align: left;
    width: auto;
}

.dashboard .info-section {
    margin: 0;
    padding-bottom: 10px;
    padding-top: 10px;
    width: 100%;
}
</style>

<div class="clear"></div>

<div class="container">
    <div class="example">
        <ul id="breadcrumbs">
            <li>
                <a href="${ui.pageLink('referenceapplication', 'home')}">
                    <i class="icon-home small"></i></a>
            </li>
            <li>
                <i class="icon-chevron-right link"></i>
                <a href="${ui.pageLink('billingui', 'billingQueue')}">Billing</a>
            </li>

            <li>
                <i class="icon-chevron-right link"></i>
                Service Bills
            </li>
        </ul>
    </div>

    <div class="patient-header new-patient-header">
        <div class="demographics">
            <h1 class="name">
                <span id="surname">${patient.names.familyName},<em>surname</em></span>
                <span id="othname">${patient.names.givenName} &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;<em>other names</em>
                </span>

                <span class="gender-age">
                    <span>
                        <% if (patient.gender == "F") { %>
                        Female
                        <% } else { %>
                        Male
                        <% } %>
                    </span>
                    <span id="agename">${patient.age} years (15.Oct.1996)</span>

                </span>
            </h1>

            <br/>

            <div id="stacont" class="status-container">
                <span class="status active"></span>
                Visit Status
            </div>

            <div class="tag">Outpatient ${fileNumber}</div>

            <div class="tad">Billing ID: #${bill?.patientServiceBillId}</div>
        </div>

        <div class="identifiers">
            <em>&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;Patient ID</em>
            <span>${patient.getPatientIdentifier()}</span>
            <br>

            <div class="catg">
                <i class="icon-tags small" style="font-size: 16px"></i><small>Category:</small> ${category}
            </div>
        </div>

        <div class="close"></div>
    </div>


    <% if (bill != null) { %>

    <table width="100%" border="1" cellpadding="5" cellspacing="0" id="myTable" class="tablesorter thickbox"
           style="margin-top: 5px">
        <thead>
        <tr>
            <th align="center">Service Name</th>
            <th style="text-align: right;">Price (KSh)</th>
            <th style="text-align: right;">Quantity</th>
            <th style="text-align: right;">Amount</th>
        </tr>
        </thead>
        <tbody>

        <% bill?.billItems.each { %>
        <% if (bill?.voidedDate == null) { %>
        <% if (it.name != "INPATIENT DEPOSIT") { %>
        <tr>
            <td>${it.name}</td>
            <td align="right">${it.unitPrice}</td>
            <td align="right">${it.quantity}</td>
            <td class="printfont" height="20" align="right" style="">
                <% if (it?.actualAmount != null) { %>
                <% if (it?.actualAmount == it.amount) { %>
                <% if (it?.voidedDate != null) { %>
                <span style="text-decoration: line-through;">${it.amount}</span>
                <% } else { %>
                ${it.amount}
                <% } %>
                <% } else { %>

                <span style="text-decoration: line-through;">${it.amount}</span>
                <b>${it?.actualAmount}</b>
                <% } %>
                <% } else { %>
                ${it?.amount}
                <% } %>
            </td>
        </tr>
        <% } %>
        <% } %>
        <% } %>
        <% def initialtotal = 0 %>
        <% bill?.billItems.each { %>
        <% if (it.name.equalsIgnoreCase("INPATIENT DEPOSIT")) {
            initialtotal += it.amount
        }
        %>
        <% } %>

        <tr>
            <td colspan="3" align='right'><b>Total</b></td>
            <td align="right">
                <% if (bill?.actualAmount != null) { %>
                <% if (bill?.actualAmount == bill?.amount) { %>
                <% if (bill?.voided) { %>
                <span style="text-decoration: line-through;"><b>${bill?.amount - initialtotal}</b>
                </span>
                <% } else { %>
                <b>${bill?.amount - initialtotal}</b>
                <% } %>
                <% } else { %>
                <span style="text-decoration: line-through;">${bill?.amount - initialtotal}</span>
                <% if (bill?.voided) { %>
                <span style="text-decoration: line-through;"><b>${bill?.actualAmount - initialtotal}</b>
                </span>
                <% } else { %>
                <b>${bill?.actualAmount - initialtotal}</b>
                <% } %>
                <% } %>
                <% } else { %>
                ${bill?.amount - initialtotal}
                <% } %>
            </td>
        </tr>
        <% bill?.billItems.each { %>
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
            <td colspan="3" align='right'><b>Advance Payment</b></td>
            <td align="right" id="initialtotal">${initialtotal}</td>
        </tr>

        <tr>
            <td colspan="3" align='right'><b>Waiver Amount</b></td>
            <td align="right">${bill?.waiverAmount}</td>
        </tr>
        <% if (bill?.rebateAmount > 0) { %>
        <tr>
            <td colspan="3" align='right'><b>Rebate Amount</b></td>
            <td align="right">${bill?.rebateAmount}</td>
        </tr>
        <% } %>

        <tr>
            <td colspan="3" align='right'><b>Net Amount</b></td>
            <td align="right"><b>${bill?.actualAmount - bill?.waiverAmount - initialtotal}</b></td>
        </tr>
        </tbody>
    <input type="hidden" id="total" value="${bill?.actualAmount - bill?.waiverAmount}">

    </table>

    <% } %>


    <form method="POST" id="billForm">
        <div class="formfactor">

            <% if (!patient.dead) { %>
            <button type="button" class="task"
                    onclick="window.location.href = 'addPatientServiceBillForBD.page?patientId=${patient.patientId}&billType=paid&lastBillId=${bill?.patientServiceBillId}'"
                    style="margin-left: -3px">Add Paid Bill</button>
            <button type="button" class="cancel">Add Free Bill</button>
            <% } %>
            <% if (bill != null) { %>

            <button type="button" class="confirm" style="float: right; margin-right: -5px;">Print Bill</button>

            <% } %>

            <span id="commentField">
                <label for="comment">Comment</label>
                <input id="comment" name="comment"/>
            </span>

            <span id="okButton">
                <input type="button" value="Ok" onclick="return validate();"/>
            </span>
        </div>

    </form>
</div>

<% if (bill != null) { %>

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
                <td>:${bill?.receipt.id}</td>
            </tr>
            <tr>
                <td>Date/Time</td>
                <td align="left">:${dateTime}</td>
            </tr>
            <tr>
                <td>Name</td>
                <td colspan="3">:${patient.givenName}&nbsp;${patient.familyName}&nbsp;${patient.middleName?patient.middleName:''}&nbsp;&nbsp;
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
            <% if (bill?.voided) { %>
            <tr>
                <td>Bill Description</td>
                <td>:${bill?.description}</td>
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
            <% bill?.billItems.eachWithIndex { item, status -> %>
            <% if (item.voidedDate == null) { %>
            <% if (!item.name.equalsIgnoreCase("INPATIENT DEPOSIT")) { %>
            <tr class='${status % 2 == 0 ? "oddRow" : "evenRow"}'>
                <td>${status}</td>
                <td class="printfont" height="20">${item.name}</td>
                <td class="printfont" height="20"><center>${item?.unitPrice}</center></td>
                <td class="printfont" height="20"><center>${item?.quantity}</center></td>
                <td class="printfont" height="20"><center>${item?.actualAmount}</center></td>
            </tr>
            <% } %>
            <% } %>
            <% } %>


            <tr>
                <td>&nbsp;</td>
                <td align="right" colspan="3"><b>Total</b></td>
                <% if (bill?.voided) { %>
                <td align="right"><center><span
                        style="text-decoration: line-through;"><b>${bill?.actualAmount - initialtotal}</b></span>
                </center>
                </td>

                <% } else { %>
                <td align="right">${bill?.actualAmount - initialtotal}</td>
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
                <td align="right"><b>${bill?.waiverAmount}</b></td>
            </tr>

            <% if (bill?.rebateAmount > 0) { %>
            <tr>
                <td>&nbsp;</td>
                <td colspan="3" align='right'><b>Rebate Amount</b></td>
                <td align="right"><b>${bill?.rebateAmount}</b></td>
            </tr>
            <% } %>


            <tr>
                <td>&nbsp;</td>
                <td colspan="3" align='right'><b>Net Amount</b></td>
                <td align="right"><b>${bill?.actualAmount - bill?.waiverAmount - initialtotal}</b></td>
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

<% } %>


<% if (listBill != null) { %>

<div class="dashboard clear">
    <div class="info-section">
        <div class="info-header">
            <i class="icon-calendar"></i>

            <h3>LIST OF PREVIOUS BILLS</h3>
        </div>

        <div class="info-body">
            <table class="box">
                <thead>
                <th style="width: 40px; text-align: center;">#</th>
                <th style="width: 70px">Bill ID</th>
                <th style="width: 200px">Date</th>
                <th>Description</th>
                <th style="width: 100px; text-align: center;">Action</th>
                </thead>

                <% listBill.eachWithIndex { bill, index -> %>
                <tr class='${index % 2 == 0 ? "oddRow" : "evenRow"} '>
                    <td align="center" class='<% if (bill?.voided) { %>retired <% } %>'>
                        ${index + 1}
                    </td>
                    <td class='<% if (bill?.voided) { %>retired <% } %>'>
                        <% if (bill?.voided == false || (bill?.printed == true && canEdit == true)) { %>
                        <a href="editPatientServiceBillForBD.page?billId=${bill?.patientServiceBillId}&patientId=${
                                patient.patientId}">
                            ${bill?.patientServiceBillId}</a>

                        <% } else { %>
                        ${bill?.patientServiceBillId}
                        <% } %>
                    </td>
                    <td class='<% if (bill?.voided) { %>retired <% } %>'>
                        ${bill?.createdDate}
                    </td>
                    <td class='<% if (bill?.voided) { %>retired <% } %>'>
                        <% if (bill?.description != null) { %>
                        ${bill?.description}
                        <% } else { %>
                        N/A
                        <% } %>
                    </td>
                    <td class='<% if (bill?.voided) { %>retired <% } %>' style="text-align: center; ">
                        <% if (bill?.voided) { %>
                        <input type="button" value="View" class="task retired"
                               onclick="javascript:window.location.href = 'patientServiceVoidedBillViewForBD.page?patientId=${patient.patientId}&billId=${bill?.patientServiceBillId}'"/>
                        <% } else { %>
                        <input type="button" value="View" class="task"
                               onclick="javascript:window.location.href = 'patientServiceBillForBD.page?patientId=${patient.patientId}&billId=${bill?.patientServiceBillId}'"/>
                        <% } %>
                    </td>
                </tr>
                <% } %>
            </table>
        </div>
    </div>
</div>
<% } %>

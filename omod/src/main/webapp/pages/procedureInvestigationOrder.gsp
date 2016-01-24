<%
    ui.decorateWith("appui", "standardEmrPage", [title: "Cashier Module"])
    ui.includeCss("uicommons", "styleguide/index.css")
//    ui.includeJavascript("billingui", "moment.js")
//    ui.includeJavascript("billingui", "jquery.dataTables.min.js")
    def props = ["sno", "service", "select", "quantity", "pay", "unitprice", "itemtotal"]
%>
<style>
.form-textbox {
    height: 12px !important;
    font-size: 12px !important;
}
</style>
<script type="text/javascript">
    var jq = jQuery;
    var breadcrumbs = [
        {icon: "icon-home", link: '/' + OPENMRS_CONTEXT_PATH + '/index.htm'},
        {label: "<a href='#'>Patient Summary (${patientSearch.givenName} &nbsp;${patientSearch.familyName}&nbsp;${(patientSearch.middleName).replace(',',' ')})</a>"}
    ]

    jq(function () {
        jq("#waiverCommentDiv").hide();
        jq('.serquncalc').keyup(function () {
            var result = 0;
            jq('#total').attr('value', function () {
                jq('.serpricalc').each(function () {
                    if (jq(this).val() !== '') {
                        result += parseInt(jq(this).val());
                    }
                });
                return result;
            });
        });
        var sos =${serviceOrderSize};
        if (sos == 0) {
            jQuery("#savebill").hide();
        }
        var result = 0;
        jq('#total').attr('value', function () {
            jq('.serpricalc').each(function () {
                if (jq(this).val() !== '') {
                    result += parseInt(jq(this).val());
                }
            });
            return result;
        });
    });
    function loadWaiverCommentDiv() {
        jq("#waiverCommentDiv").show();
    }

    function updatePrice(incon) {
        var con = incon.toString();
        var serqunid = con.concat("servicequantity");
        var serpriid = con.concat("serviceprice");
        var unipriid = con.concat("unitprice");
        //alert(document.getElementById(serqunid).value);
        serqun = jq("#" + serqunid).val();
        unpri = jq("#" + unipriid).val();
        jq("#" + serpriid).val(serqun * unpri);
    }

    function disable(incon) {
        var icon = incon.toString();

        if (jq("#" + icon + "selectservice").attr('checked')) {
            jq("#" + icon + "servicequantity").removeAttr("disabled");
            jq("#" + icon + "serviceprice").removeAttr("disabled");
            jq("#" + icon + "paybill").removeAttr("disabled");

            var totalValue = jq("#total").val();
            var toBeAdded = jq("#" + icon + "serviceprice").val();
            var added = parseInt(totalValue, 10) + parseInt(toBeAdded, 10);
            jq('#total').val(added);
        }
        else {
            jq("#" + icon + "servicequantity").attr("disabled", "disabled");
            jq("#" + icon + "paybill").attr("disabled", "disabled");
            jq("#" + icon + "serviceprice").attr("disabled", "disabled");
            var totalValue = jq("#total").val();
            var toBeMinus = jq("#" + icon + "serviceprice").val();
            var left = totalValue - toBeMinus;
            jq('#total').val(left);
        }

    }

    function payCheckBox(incon) {

        var icon = incon.toString();
        if (jq("#" + icon + "paybill").attr('checked')) {
            jq("#" + icon + "serviceprice").removeAttr("disabled");
            var totalValue = jq("#total").val();
            var toBeAdded = jq("#" + icon + "serviceprice").val();
            var added = parseInt(totalValue, 10) + parseInt(toBeAdded, 10);
            jq('#total').val(added);

        }
        else {
            var totalValue = jq("#total").val();
            var toBeMinus = jq("#" + icon + "serviceprice").val();
            var left = totalValue - toBeMinus;
            jq('#total').val(left);
            jq("#" + icon + "serviceprice").attr("disabled", "disabled");
        }
    }

    function validate(serviceOrderSize) {
        for (var i = 1; i <= serviceOrderSize; i++) {
            var con = i.toString();
            if (jq("#" + con + "selectservice").attr('checked')) {
                var serqunid = con.concat("servicequantity");
                serqun = jq("#" + serqunid).val();
                if (serqun == null || serqun == "") {
                    alert("Please enter quantity");
                    return false;
                }

                if (Number(jq("#total").val()) < Number(jq("#waiverAmount").val())) {
                    alert("Please enter correct Waiver Amount");
                    return false;
                }
                if (isNaN(jq("#waiverAmount").val()) || jq("#waiverAmount").val() < 0) {
                    alert("Please enter correct Waiver Amount");
                    return false;
                }
                if (jq("#waiverAmount").val() > 0 && jq("#waiverComment").val() == "") {
                    alert("Please enter Waiver Number");
                    return false;
                }

                if (serqun != null || quantity != "") {
                    if (isNaN(serqun)) {
                        alert("Please enter quantity in correct format");
                        return false;
                    }
                }
            }
        }
    }






</script>

<div class="clear"></div>

<div class="container">

    <div class="patient-header new-patient-header">
        <div class="demographics">
            <h1 class="name">
                <span><small>${patientSearch.familyName}</small>,<em>surname</em></span>
                <span><small>${patientSearch.givenName} &nbsp;${(patientSearch.middleName).replace(',', ' ')}</small><em>name</em>
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
            <em>Date/ Time:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</em>
            <span>${date}</span>

        </div>
    </div>

    <form id="orderBillingForm"
          action="procedureInvestigationOrder.page?patientId=${patientId}&encounterId=${encounterId}&indCount=${serviceOrderSize}&billType=mixed"
          method="POST"
          onsubmit="javascript:return validate(${serviceOrderSize});">
        <div class="dashboard clear">
            <div class="info-container">
                <div class="info-header">
                    <i class="icon-calendar"></i>

                    <h3>List of Procedures/Investigations</h3>
                </div>
            </div>
            <br/>

            <table cellpadding="5" cellspacing="0" width="100%" id="myTable" class="tablesorter thickbox">
                <thead>
                <tr align="center">
                    <th>S.No</th>
                    <th>Service</th>
                    <th>Select</th>
                    <th>Quantity</th>
                    <th>Pay</th>
                    <th style="text-align: right;">Unit Price</th>
                    <th style="text-align: right;">Item Total</th>
                </tr>
                </thead>
                <tbody>

                <% if (serviceOrderList != null || serviceOrderList != "") { %>
                <% serviceOrderList.eachWithIndex { queue, index -> %>
                <tr align="center">
                    <td>${index + 1}</td>
                    <td><input type="text" class="form-textbox" id="${index}service" name="${index}service"
                               value="${queue.name}" readOnly="true">
                    </td>
                    <td>
                        <input type="checkbox" class="form-textbox" id="${index}selectservice"
                               name="${index}selectservice"
                               checked="checked" value="billed" onclick="disable(${index});">
                    </td>
                    <td>
                        <input type="text" class="form-textbox" id="${index}servicequantity"
                               name="${index}servicequantity" size="7" value=1
                               onkeyup="updatePrice(${index});" class="serquncalc"/>
                    </td>
                    <td>
                        <input type="checkbox" class="form-textbox" id="${index}paybill" name="${index}paybill"
                               checked="checked" value="pay" onclick="payCheckBox(${index});">
                    </td>
                    <td>
                        <input type="text" class="form-textbox" id="${index}unitprice" name="${index}unitprice" size="7"
                               value="${queue.price}" readOnly="true">
                    </td>
                    <td>
                        <input type="text" class="form-textbox" id="${index}serviceprice" name="${index}serviceprice"
                               size="7" value="${queue.price}" readOnly="true" class="serpricalc">
                    </td>
                </tr>
                <% } %>

                <% } else { %>
                <tr align="center">
                    <td colspan="7">No Orders Found</td>
                </tr>
                <% } %>

                </tbody>
                <tr>
                    <td colspan="6" align="right">Total</td>
                    <td align="right"><input type="text" class="form-textbox" id="total" name="total" size="7" value="0"
                                             readOnly="true"/>
                    </td>
                </tr>
                <tr>
                    <td colspan="6" align="right">Waiver Amount</td>
                    <td align="right"><input type="text" id="waiverAmount" name="waiverAmount" size="7"
                                             class="form-textbox"
                                             onblur="loadWaiverCommentDiv();"/></td>
                </tr>
            </table>

            <div align="right" id="waiverCommentDiv" class="form-group">
                Waiver Number/Comment <input type="text" id="waiverComment" name="waiverComment" size="7"
                                             class="form-textbox"/>
            </div>
            <tr>
                <td><input type="button"
                           onclick="javascript:window.location.href = 'billingQueue.page?'"
                           value="Cancel">
                </td>
                <td><input type="submit" id="savebill" name="savebill" float="right"
                           value="Save Bill">
                </td>

            </tr>
        </div>
    </form>
</div>

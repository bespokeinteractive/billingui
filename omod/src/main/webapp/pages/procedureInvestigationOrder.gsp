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
    jQuery(document).ready(function () {
        jQuery("#waiverCommentDiv").hide();
        jQuery('.serquncalc').keyup(function () {
            var result = 0;
            jQuery('#total').attr('value', function () {
                jQuery('.serpricalc').each(function () {
                    if (jQuery(this).val() !== '') {
                        result += parseInt(jQuery(this).val());
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
        jQuery('#total').attr('value', function () {
            jQuery('.serpricalc').each(function () {
                if (jQuery(this).val() !== '') {
                    result += parseInt(jQuery(this).val());
                }
            });
            return result;
        });



        recalculate(sos);

    });

    function recalculate(sos){

        var mytot=0;
        for(i=1;i<=sos;i++){
            if(jQuery("#" + i + "paybill").attr('unchecked') || jQuery("#" + i + "selectservice").attr('unchecked')){
                //do nothing
            }else{
                var servQuantity = parseInt(jQuery("#" + i + "servicequantity").val());
                mytot+=(parseInt(jQuery("#" + i + "serviceprice").val())*servQuantity);
            }
        }
        jQuery("#total").val(mytot);

    }

    ///end of ready


    function loadWaiverCommentDiv() {
        jQuery("#waiverCommentDiv").show();
    }
</script>

<script type="text/javascript">
    function updatePrice(incon) {
        var con = incon.toString();
        var serqunid = con.concat("servicequantity");
        var serpriid = con.concat("serviceprice");
        var unipriid = con.concat("unitprice");
//alert(document.getElementById(serqunid).value);
        serqun = jQuery("#" + serqunid).val();
        unpri = jQuery("#" + unipriid).val();
        jQuery("#" + serpriid).val(serqun * unpri);
    }
</script>

<script type="text/javascript">
    function disable(incon) {
        var icon = incon.toString();

        if (jQuery("#" + icon + "selectservice").attr('checked')) {
            jQuery("#" + icon + "servicequantity").removeAttr("disabled");
            jQuery("#" + icon + "serviceprice").removeAttr("disabled");
            jQuery("#" + icon + "paybill").removeAttr("disabled");

            var totalValue = jQuery("#total").val();
            var toBeAdded = jQuery("#" + icon + "serviceprice").val();
            var added = parseInt(totalValue, 10) + parseInt(toBeAdded, 10);
            jQuery('#total').val(added);
        }
        else {
            jQuery("#" + icon + "servicequantity").attr("disabled", "disabled");
            jQuery("#" + icon + "paybill").attr("disabled", "disabled");
            jQuery("#" + icon + "serviceprice").attr("disabled", "disabled");
            var totalValue = jQuery("#total").val();
            var toBeMinus = jQuery("#" + icon + "serviceprice").val();
            var left = totalValue - toBeMinus;
            jQuery('#total').val(left);
        }

    }


    function payCheckBox(incon) {

        var icon = incon.toString();
        if (jQuery("#" + icon + "paybill").attr('checked')) {
            jQuery("#" + icon + "serviceprice").removeAttr("disabled");
            var totalValue = jQuery("#total").val();
            var toBeAdded = jQuery("#" + icon + "serviceprice").val();
            var added = parseInt(totalValue, 10) + parseInt(toBeAdded, 10);
            jQuery('#total').val(added);

        }
        else {
            var totalValue = jQuery("#total").val();
            var toBeMinus = jQuery("#" + icon + "serviceprice").val();
            var left = totalValue - toBeMinus;
            jQuery('#total').val(left);
            jQuery("#" + icon + "serviceprice").attr("disabled", "disabled");
        }


    }


</script>

<script type="text/javascript">
    function validate(serviceOrderSize) {
        for (var i = 1; i <= serviceOrderSize; i++) {
            var con = i.toString();
            if (jQuery("#" + con + "selectservice").attr('checked')) {
                var serqunid = con.concat("servicequantity");
                serqun = jQuery("#" + serqunid).val();
                if (serqun == null || serqun == "") {
                    alert("Please enter quantity");
                    return false;
                }

                if (Number(jQuery("#total").val()) < Number(jQuery("#waiverAmount").val())) {
                    alert("Please enter correct Waiver Amount");
                    return false;
                }
                if (isNaN(jQuery("#waiverAmount").val()) || jQuery("#waiverAmount").val() < 0) {
                    alert("Please enter correct Waiver Amount");
                    return false;
                }
                if (jQuery("#waiverAmount").val() > 0 && jQuery("#waiverComment").val() == "") {
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
            <em>Date/ Time:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</em>
            <span>${date}</span>

        </div>
    </div>

    <form id="orderBillingForm"
          action="procedureInvestigationOrder.page?patientId=${patientId}&encounterId=${encounterId}&indCount=${serviceOrderSize}&billType=mixed&date=${date}"
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
                    <td><input type="text" class="form-textbox" id="${index + 1}service" name="${index + 1}service"
                               value="${queue.name}" readOnly="true">
                    </td>
                    <td>
                        <input type="checkbox" class="form-textbox" id="${index + 1}selectservice"
                               name="${index + 1}selectservice"
                               checked="checked" value="billed" onclick="disable(${index+ 1});">
                    </td>
                    <td>
                        <input type="text" class="form-textbox" id="${index + 1}servicequantity"
                               name="${index + 1}servicequantity" size="7" value=1
                               onkeyup="updatePrice(${index+ 1});" class="serquncalc"/>
                    </td>
                    <td>
                        <input type="checkbox" class="form-textbox" id="${index + 1}paybill" name="${index + 1}paybill"
                               checked="checked" value="pay" onclick="payCheckBox(${index+ 1});">
                    </td>
                    <td>
                        <input type="text" class="form-textbox" id="${index + 1}unitprice" name="${index + 1}unitprice"
                               size="7"
                               value="${queue.price}" readOnly="true">
                    </td>
                    <td>
                        <input type="text" class="form-textbox" id="${index + 1}serviceprice"
                               name="${index + 1}serviceprice"
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
                <td><input type="button" class="button cancel"
                           onclick="javascript:window.location.href = 'billingQueue.page?'"
                           value="Cancel">
                </td>
                <td>

                    <input type="submit" id="savebill" name="savebill" float="right" class="button confirm"
                           value="Save Bill">
                </td>

            </tr>
        </div>
    </form>
</div>

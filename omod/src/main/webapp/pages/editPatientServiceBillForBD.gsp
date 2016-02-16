<%
    ui.decorateWith("appui", "standardEmrPage", [title: "Cashier : Edit Bill"])
%>
<script>
    jQuery(function () {
        jQuery("#waiverCommentDiv").hide();
        jQuery('.serquncalc').keyup(function () {
            var result = 0;
            jQuery('.serpricalc').each(function () {
                var valueAdd = jQuery(this).val();
                if (valueAdd !== '') {
                    result += parseInt(jQuery(this).val());
                }
            });

            jQuery('#total').attr('value', result);

        });

        var result = 0;
        jQuery('#total').attr('value', function () {
            jQuery('.serpricalc').each(function () {
                if (jQuery(this).val() !== '') {
                    result += parseInt(jQuery(this).val());
                }
            });
            return result;
        });


    });//end of document ready


    function loadWaiverCommentDiv() {
        jQuery("#waiverCommentDiv").show();
    }
    function voidBillItems() {
        jQuery("#action").val("void");
        jQuery("#voidBill").attr("disabled", "disabled");
        jQuery("#voidBill").addClass("disabled");
        return 0;
    }

    function updatePrice(incon) {
        var objRegExp = /^ *[0-9]+ *\$/;
        var con = incon.toString();
        var serqunid = con.concat("servicequantity");
        var serpriid = con.concat("serviceprice");
        var unipriid = con.concat("unitprice");

//alert(document.getElementById(serqunid).value);
        serqun = jQuery("#" + serqunid).val();
        unpri = jQuery("#" + unipriid).val();
        if (!objRegExp.test(serqun) || serqun == '' || serqun <= 0) {
            alert("Please enter valid quantity!!!");
            var ele = document.getElementById(serqunid);
            ele.focus();

        } else {
            jQuery("#" + serpriid).val(serqun * unpri);
        }

    }

    function deleteInput(conceptId, serviceName, servicePrice, qty) {
        alert("Try this one out " + conceptId);
    }

    function submitBillForm() {
        jQuery("#action").val("submit");
        jQuery("#total").focus();
        var waiverNumber = jQuery("#waiverNumber").val();
        var desc = jQuery("#description").val();

        if (desc == '' || desc == null) {
            if (waiverNumber == '' || waiverNumber == null) {
                alert("Please enter Comments/Waiver Number");
                return false;
            }
        }
        if (waiverNumber == '' || waiverNumber == null) {
            if (desc == '' || desc == null) {
                alert("Please enter Comments/Waiver Number");
                return false;
            }
        }
        var ok = true;
        var objRegExp = /^ *[0-9]+ *\$/;
        jQuery(".serquncalc").each(function () {
            var qty = jQuery(this).val();
            if (!objRegExp.test(qty) || qty == '' || qty <= 0) {
                ok = false;
                jQuery(this).focus();
            }
        });
        if (!ok) {
            alert("Please enter valid quantity for bill items!!!");
        } else if (false) {
            //code to check if there is at least one item on the list
            alert("Please select item for billing");
        } else {
            var totalValue = parseInt(jQuery("#total").val());
            var waiver = parseInt(jQuery("#waiverAmount").val());
            if (totalValue <waiver) {
                alert("Please enter correct Waiver Amount");
                return false;
            } else if (isNaN(waiver)) {
                alert("Waiver Amount must be a number");
                return false;
            } else if (waiver < 0) {
                alert("Please enter correct Waiver Amount - greater than zero");
                return false;
            } else {
                jQuery("#savebill").attr("disabled", "disabled");
                jQuery("#billForm").submit();
            }
        }

    }

</script>

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

<form id="billForm"
      action=""
      method="POST">
    <input type="hidden" value="" name="action" id="action"/>

    <div class="dashboard clear">
        <div class="info-container">
            <div class="info-header">
                <i class="icon-calendar"></i>

                <h3>Edit Patient Bill</h3>
            </div>
        </div>
        <br/>

        <table cellpadding="5" cellspacing="0" width="100%" id="myTable" class="tablesorter thickbox">
            <thead>
            <tr align="center">
                <th>S.No</th>
                <th>Service</th>
                <th>Quantity</th>
                <th style="text-align: right;">Unit Price</th>
                <th style="text-align: right;">Item Total</th>
                <th></th>
            </tr>
            </thead>
            <tbody>

            <% if (bill.billItems != null || bill.billItems != "") { %>
            <% bill.billItems.eachWithIndex { queue, index -> %>
            <tr align="center">

                <td>${index + 1}<input name='cons' type='hidden' value='${queue.service.conceptId}'></td>
                <td><input type="text" class="form-textbox" id="${index + 1}service" name="${index + 1}service"
                           value="${queue.name}" readOnly="true">
                </td>
                <td>
                    <input type="text" class="form-textbox serquncalc" id="${index + 1}servicequantity"
                           name="${index + 1}servicequantity" size="7" value="${queue.quantity}"
                           onkeyup="updatePrice(${index+ 1});"/>
                </td>
                <td>
                    <input type="text" class="form-textbox" id="${index + 1}unitprice" name="${index + 1}unitprice"
                           size="7"
                           value="${queue.unitPrice}" readOnly="true">
                </td>
                <td>
                    <input type="text" class="form-textbox serpricalc" id="${index + 1}serviceprice"
                           name="${index + 1}serviceprice"
                           size="7" value="${queue.amount}" readOnly="true">
                </td>
                <td>
                    <a href="#" onclick="deleteInput(${queue.service.conceptId});"><i class="icon-remove small"
                                                                                      style="color:red"></i></a>
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
                <td colspan="4" align="right">Total</td>
                <td align="right"><input type="text" class="form-textbox" id="total" name="total" size="7" value="0.00"
                                         readOnly="true"/>
                </td>
            </tr>
            <tr>
                <td colspan="4" align="right">Waiver Amount</td>
                <input id="freePat" name="freePat" type='hidden' value="${freeBill}" size='5'/>
                <td align="right"><input type="text" id="waiverAmount" name="waiverAmount" size="7"
                                         class="form-textbox" value="${waiverAm}"
                                         onblur="loadWaiverCommentDiv();"/></td>
            </tr>
        </table>


        <div align="right" id="waiverCommentDiv" class="form-group">
            Waiver Number <input type="text" id="waiverNumber" name="waiverNumber" size="7"
                                 class="form-textbox"/>
        </div>


        Comment:  <input type="text" id="description" name="description" class="form-textbox"/>




        <tr>
            <td><input type="button" class="button cancel" value="Cancel" id="submitBill"
                       onclick="javascript:window.location.href = 'billableServiceBillListForBD.page?patientId=${patientId}&billId=${billId}'">
            </td>
            <td><input type="button" class="button cancel" value="Void Bill" id="voidBill" onclick="voidBillItems();">
            </td>
            <td>

                <input type="button" id="savebill" name="savebill" float="right" class="button confirm"
                       value="Save Bill" onclick="submitBillForm()">
            </td>

        </tr>
    </div>
</form>
<%
    ui.decorateWith("appui", "standardEmrPage", [title: "Cashier : Edit Bill"])
%>
<script>
    jQuery(function(){
        jQuery("#waiverCommentDiv").hide();

    });//end of document ready

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

<form id="orderBillingForm"
      action=""
      method="POST">
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
                <td>${index + 1}</td>
                <td><input type="text" class="form-textbox" id="${index + 1}service" name="${index + 1}service"
                           value="${queue.name}" readOnly="true">
                </td>
                <td>
                    <input type="text" class="form-textbox" id="${index + 1}servicequantity"
                           name="${index + 1}servicequantity" size="7" value=1
                           onkeyup="updatePrice(${index+ 1});" class="serquncalc"/>
                </td>
                <td>
                    <input type="text" class="form-textbox" id="${index + 1}unitprice" name="${index + 1}unitprice"
                           size="7"
                           value="${queue.unitPrice}" readOnly="true">
                </td>
                <td>
                    <input type="text" class="form-textbox" id="${index + 1}serviceprice"
                           name="${index + 1}serviceprice"
                           size="7" value="${queue.amount}" readOnly="true" class="serpricalc">
                </td>
                <td>
                    <a href="#" onclick="disable(${index+ 1});"><i class="icon-remove small"></i></a>
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
                <td align="right"><input type="text" class="form-textbox" id="total" name="total" size="7" value="0"
                                         readOnly="true"/>
                </td>
            </tr>
            <tr>
                <td colspan="4" align="right">Waiver Amount</td>
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
            <td><input type="button" class="button cancel" value="Cancel">
            </td>
            <td><input type="button" class="button cancel" value="Void Bill">
            </td>
            <td>

                <input type="submit" id="savebill" name="savebill" float="right" class="button confirm"
                       value="Save Bill">
            </td>

        </tr>
    </div>
</form>
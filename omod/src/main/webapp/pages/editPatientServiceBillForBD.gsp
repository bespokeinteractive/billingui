<%
    ui.decorateWith("appui", "standardEmrPage", [title: "Edit Bills"])
	
	ui.includeJavascript("billingui", "moment.js")
%>
<script>
    jQuery(function () {
		jq('#surname').html(stringReplace('${patient.names.familyName}')+',<em>surname</em>');
		jq('#othname').html(stringReplace('${patient.names.givenName}')+' &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; <em>other names</em>');
		jq('#agename').html('${patient.age} years ('+ moment('${patient.birthdate}').format('DD,MMM YYYY') +')');
		
		jq('.tad').text('Last Visit: '+ moment('${previousVisit}').format('DD.MM.YYYY hh:mm')+' HRS');
		
		jq('#waiverAmountEdit').on('change keyup paste', function () {
			var numb = jq('#waiverAmountEdit').val();
			
			if (!isNaN(parseFloat(numb)) && isFinite(numb) && numb>0){
				jq("#waiverCommentDiv").show();
			}
			else {
				jq("#waiverCommentDiv").hide();
			}
        });
		
		jq('#waiverAmountEdit').on('focus', function () {
			var numb = jq('#waiverAmountEdit').val();
			if (!isNaN(parseFloat(numb)) && isFinite(numb) && numb>0){
				jq('#waiverAmountEdit').val(parseFloat(jq('#waiverAmountEdit').val()))
			}
			else {
				jq("#waiverAmountEdit").val('');
			}
        });
		
		jq('#waiverAmountEdit').on('blur', function () {
			var numb = jq('#waiverAmountEdit').val();
			if (!isNaN(parseFloat(numb)) && isFinite(numb) && numb>0){
				jq('#waiverAmountEdit').val(formatAccounting(numb));
			}
			else {
				jq("#waiverAmountEdit").val('0.00');
			}
        });
		
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
        var serqunid = con.concat("_qty");
        var serpriid = con.concat("_price");
        var unipriid = con.concat("_unitPrice");

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
//        jQuery("#action").val("submit");
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
            var waiver = parseInt(jQuery("#waiverAmountEdit").val());
            if (totalValue < waiver) {
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

<style>
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
	.catg{
		color: #363463;
		margin: 35px 10px 0 0;
	}
	form input[type="text"]{
		background: transparent none repeat scroll 0 0;
	}
	form input[type="text"]:focus{
		outline: 1px none #ddd;
	}
	td a,
	td a:hover{
		cursor: pointer;
		text-decoration: none;
	}
	.align-left{
		width: 200px;
		display: inline-block;
	}
	.align-right{
		float: right;
		width: 720px;
		display: inline-block;
	}
</style>

<div class="clear"></div>

<div class="container">
	<div class="example">
		<ul id="breadcrumbs">
			<li>
				<a href="${ui.pageLink('referenceapplication','home')}">
				<i class="icon-home small"></i></a>
			</li>
			<li>
				<i class="icon-chevron-right link"></i>
				<a href="${ui.pageLink('billingui','billingQueue')}">Billing</a>
			</li>
			
			<li>
				<i class="icon-chevron-right link"></i>
				<a href="${ui.pageLink('billingui','billingQueue')}">Service Bills</a>
			</li>
			
			<li>
				<i class="icon-chevron-right link"></i>
				Edit Bill
			</li>
		</ul>
	</div>
	
	<div class="patient-header new-patient-header">
		<div class="demographics">
			<h1 class="name">
				<span id="surname"></span>
				<span id="othname"></span>
				
				<span class="gender-age">
					<span>
						<% if (patient.gender == "F") { %>
							Female
						<% } else { %>
							Male
						<% } %>
					</span>
					<span id="agename"></span>
					
				</span>
			</h1>
			
			<br/>
			<div id="stacont" class="status-container">
				<span class="status active"></span>
				Visit Status
			</div>
			<div class="tag">Outpatient ${fileNumber}</div>
			<div class="tad">Last Visit</div>
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

	<form id="billForm"
		  action=""
		  method="POST">
		<input type="hidden" value="none" name="action" id="action"/>

		<div class="dashboard clear" style="padding-top: 5px">
			<table cellpadding="5" cellspacing="0" width="100%" id="myTable" class="tablesorter thickbox">
				<thead>
				<tr align="center">
					<th style="width: 40px">S.No</th>
					<th>Service</th>
					<th style="width: 40px">Quantity</th>
					<th style="text-align: right; width: 120px;">Unit Price</th>
					<th style="text-align: right; width: 120px;">Item Total</th>
					<th style="width: 10px"></th>
				</tr>
				</thead>
				<tbody>

				<% if (bill.billItems != null || bill.billItems != "") { %>
				<% bill.billItems.eachWithIndex { queue, index -> %>
				
				<tr align="center">

					<td>${index + 1}<input name='cons' type='hidden' value='${queue.service.conceptId}'></td>
					<td style="text-align: left">
						<input type="text" class="form-textbox" id="${queue.service.conceptId}_name" name="${queue.service.conceptId}_name"
							   value="${queue.name}" readOnly="true" style="border: 1px none #ddd;">
					</td>
					<td>
						<input id="${queue.service.conceptId}_itemId" name="${queue.service.conceptId}_itemId" value="${queue.patientServiceBillItemId}" type='hidden'/>
						<input type="text" class="form-textbox serquncalc" id="${queue.service.conceptId}_qty"
							   name="${queue.service.conceptId}_qty" size="7" value="${queue.quantity}"
							   onkeyup="updatePrice(${queue.service.conceptId});"/>
					</td>
					
					<td>
						<input type="text" class="form-textbox" id="${queue.service.conceptId}_unitPrice" name="${queue.service.conceptId}_unitPrice"
							   size="7"
							   value="${queue.unitPrice}" readOnly="true" style="text-align:right">
					</td>
					
					<td>
						<input type="text" class="form-textbox serpricalc" id="${queue.service.conceptId}_price"
							   name="${queue.service.conceptId}_price"
							   size="7" value="${queue.amount}" readOnly="true" style="text-align:right">
					</td>
					
					<td>
						<a onclick="deleteInput(${queue.service.conceptId});"><i class="icon-remove small"
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
					<td>&nbsp;</td>
					<td colspan="3" align="right"><b>Total</b></td>
					<td align="right"><input type="text" class="form-textbox" id="total" name="total" value="0.00" size="7"
											 readOnly="true" style="text-align:right"/>
					</td>
					<td>&nbsp;</td>
				</tr>
				<tr>
					<td>&nbsp;</td>
					<td colspan="3" align="right"><b>Waiver Amount</b></td>
					<input id="freePat" name="freePat" type='hidden' value="${freeBill}"/>
					<td align="right"><input type="text" id="waiverAmountEdit" name="waiverAmountEdit" size="7"
											 class="form-textbox" value="${waiverAm}"
											 style="text-align:right"/></td>
					<td>&nbsp;</td>
				</tr>
			</table>


			<div id="waiverCommentDiv" class="form-group">
				<div class="align-left">
					<label for="waiverNumber">Waiver Number</label>
					<input type="text" id="waiverNumber" name="waiverNumber" class="form-textbox" style="width: 100%; margin-top: 6px;"/>
				</div>
				
				<div class="align-right">
					<label for="description">Waiver Comment:</label>
					<input type="text" id="description" name="description" class="form-textbox" style="width: 97%;"/>
				</div>
			</div>
			
			<div style="margin-top: 15px;">
				<button class="button cancel" value="Cancel" id="submitBill"
							   onclick="javascript:window.location.href = 'billableServiceBillListForBD.page?patientId=${patientId}&billId=${billId}'">Cancel</button>
				<button class="button cancel" value="Void Bill" id="voidBill" onclick="voidBillItems();">Void Bill</button>
				<button id="savebill" name="savebill" class="button confirm"
						   value="Save Bill" onclick="submitBillForm()" style="float: right; margin-right: 0px;">Save Bill</button>
			</div>
		</div>
	</form>
</div>




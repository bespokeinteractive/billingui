<%
    ui.decorateWith("appui", "standardEmrPage", [title: "Procedures / Investigations Order"])
    ui.includeCss("uicommons", "styleguide/index.css")
    ui.includeJavascript("billingui", "moment.js")
//    ui.includeJavascript("billingui", "jquery.dataTables.min.js")
    def props = ["sno", "service", "select", "quantity", "pay", "unitprice", "itemtotal"]
%>

<script type="text/javascript">
    jQuery(document).ready(function () {
        var sos =${serviceOrderSize};
		
		jq('#surname').html(strReplace('${patient.names.familyName}')+',<em>surname</em>');
		jq('#othname').html(strReplace('${patient.names.givenName}')+' &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; <em>other names</em>');
		jq('#agename').html('${patient.age} years ('+ moment('${patient.birthdate}').format('DD,MMM YYYY') +')');
		
		jq('.tad').text('Last Visit: '+ moment('${previousVisit}').format('DD.MM.YYYY hh:mm')+' HRS');
		
        jQuery("#waiverCommentDiv").hide();
        jQuery('.serquncalc').keyup(function () {
            var result = 0;
            jQuery('.serpricalc').each(function () {
                var valueAdd= jQuery(this).val();
                if (valueAdd !== '') {
                    result += parseInt(jQuery(this).val());
                }
            });

            jQuery('#total').attr('value', result);

        });

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
		
		jq('#waiverAmount').on('change keyup paste', function () {
			var numb = jq('#waiverAmount').val();
			
			if (!isNaN(parseFloat(numb)) && isFinite(numb) && numb>0){
				jq("#waiverCommentDiv").show();
			}
			else {
				jq("#waiverCommentDiv").hide();
			}
        });
		
		jq('#waiverAmount').on('focus', function () {
			var numb = jq('#waiverAmount').val();
			if (!isNaN(parseFloat(numb)) && isFinite(numb) && numb>0){
				jq('#waiverAmount').val(parseFloat(jq('#waiverAmount').val()))
			}
			else {
				jq("#waiverAmount").val('');
			}
        });
		
		jq('#waiverAmount').on('blur', function () {
			var numb = jq('#waiverAmount').val();
			if (!isNaN(parseFloat(numb)) && isFinite(numb) && numb>0){
				jq('#waiverAmount').val(formatAccounting(numb));
			}
			else {
				jq("#waiverAmount").val('0.00');
			}
        });
		
		jq('#waiverAmount').val('0.00');
        recalculate(sos);

    });
	
	function strReplace(word) {
		var res = word.replace("[", "");
		res=res.replace("]","");
		return res;
	}

    function recalculate(sos) {
        var mytot = 0;
        for (i = 1; i <= sos; i++) {
            if (jQuery("#" + i + "paybill").attr('unchecked') || jQuery("#" + i + "selectservice").attr('unchecked')) {
                //do nothing
            } else {
                var servQuantity = parseInt(jQuery("#" + i + "servicequantity").val());
                mytot += (parseInt(jQuery("#" + i + "serviceprice").val()) * servQuantity);
            }
        }
        jQuery("#total").val(formatAccounting(mytot));

    }

    ///end of ready


    function loadWaiverCommentDiv() {
        ///jQuery("#waiverCommentDiv").show();
    }
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
    function disable(incon) {
        var icon = incon.toString();

        if (jQuery("#" + icon + "selectservice").attr('checked')) {
            jQuery("#" + icon + "servicequantity").removeAttr("disabled");
            jQuery("#" + icon + "serviceprice").removeAttr("disabled");
            jQuery("#" + icon + "paybill").removeAttr("disabled");

            var totalValue = jQuery("#total").val();
            var toBeAdded = jQuery("#" + icon + "serviceprice").val();
            var added = parseInt(totalValue, 10) + parseInt(toBeAdded, 10);
            jQuery('#total').val(formatAccounting(added));
        }
        else {
            jQuery("#" + icon + "servicequantity").attr("disabled", "disabled");
            jQuery("#" + icon + "paybill").attr("disabled", "disabled");
            jQuery("#" + icon + "serviceprice").attr("disabled", "disabled");
            var totalValue = jQuery("#total").val();
            var toBeMinus = jQuery("#" + icon + "serviceprice").val();
            var left = totalValue - toBeMinus;
            jQuery('#total').val(formatAccounting(left));
        }

    }

    function payCheckBox(incon) {

        var icon = incon.toString();
        if (jQuery("#" + icon + "paybill").attr('checked')) {
            jQuery("#" + icon + "serviceprice").removeAttr("disabled");
            var totalValue = jQuery("#total").val();
            var toBeAdded = jQuery("#" + icon + "serviceprice").val();
            var added = parseInt(totalValue, 10) + parseInt(toBeAdded, 10);
            jQuery('#total').val(formatAccounting(added));

        }
        else {
            var totalValue = jQuery("#total").val();
            var toBeMinus = jQuery("#" + icon + "serviceprice").val();
            var left = totalValue - toBeMinus;
            jQuery('#total').val(formatAccounting(left));
            jQuery("#" + icon + "serviceprice").attr("disabled", "disabled");
        }
    }
	
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

<style>
	.form-textbox {
		height: 12px !important;
		font-size: 12px !important;
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
	.catg{
		color: #363463;
		margin: 35px 10px 0 0;
	}
	form input, form select, form textarea, form ul.select, .form input, .form select, .form textarea, .form ul.select {
		background: transparent none repeat scroll 0 0;
		border: 1px none #ddd;
	}
	.arcpricalc,
	.serpricalc,
	.rights	{
		text-align: right;
	}
	.hasborder {
		border: 1px solid #ddd;
	}
	form input:focus, form select:focus, form textarea:focus {
		outline: 1px none #ddd!important;
	}
	.ar
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
				<a href="${ui.pageLink('billingui','listOfOrder')}?patientId=${patientId}&date=${date}">Orders</a>
			</li>
			
			<li>
				<i class="icon-chevron-right link"></i>
				Procedure & Investigation
			</li>
		</ul>
	</div>
	
    <div class="patient-header new-patient-header">
        <div class="demographics">
			<h1 class="name">
				<span id="surname">${patient.names.familyName},<em>surname</em></span>
				<span id="othname">${patient.names.givenName} &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;<em>other names</em></span>
				
				<span class="gender-age">
					<span>
						<% if (patient.gender == "F") { %>
							Female
						<% } else { %>
							Male
						<% } %>
						</span>
					<span id="agename">${patient.age} years (15.Oct.1996) </span>
					
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

    <form id="orderBillingForm"
          action="procedureInvestigationOrder.page?patientId=${patientId}&encounterId=${encounterId}&indCount=${serviceOrderSize}&billType=mixed&date=${date}"
          method="POST"
          onsubmit="javascript:return validate(${serviceOrderSize});" style="padding-top: 5px">
        <div class="dashboard clear">
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
                        <input type="text" class="form-textbox serquncalc" id="${index + 1}servicequantity"
                               name="${index + 1}servicequantity" size="7" value=1
                               onkeyup="updatePrice(${index+ 1});" />
                    </td>
                    <td>
                        <input type="checkbox" class="form-textbox" id="${index + 1}paybill" name="${index + 1}paybill"
                               checked="checked" value="pay" onclick="payCheckBox(${index+ 1});">
                    </td>
                    <td>
                        <input type="text" class="form-textbox arcpricalc" id="${index + 1}unitprice" name="${index + 1}unitprice"
                               size="7"
                               value="${queue.price}" readOnly="true">
                    </td>
                    <td>
                        <input type="text" class="form-textbox serpricalc" id="${index + 1}serviceprice"
                               name="${index + 1}serviceprice"
                               size="7" value="${queue.price}" readOnly="true" />
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
                    <td colspan="6" align="right" style="padding-right: 23px">Total</td>
                    <td align="right"><input type="text" class="form-textbox rights" id="total" name="total" size="7" value="0"
                                             readOnly="true"/>
                    </td>
                </tr>
                <tr>
                    <td colspan="6" align="right" style="padding-right: 23px">Waiver Amount</td>
                    <td align="right"><input type="text" id="waiverAmount" name="waiverAmount" size="7"
                                             class="form-textbox rights hasborder" /></td>
                </tr>
            </table>

            <div id="waiverCommentDiv" class="form-group">
                <label for="waiverComment" style="color: rgb(54, 52, 99);">Waiver Number/Comment</label>
				<textarea type="text" id="waiverComment" name="waiverComment" size="7" class="hasborder" style="width: 97.7%; height: 60px;"></textarea>
											
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

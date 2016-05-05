<%
    ui.decorateWith("appui", "standardEmrPage", [title: "Cashier : Drug Order"])
%>
<style>
.retired {
    text-decoration: line-through;
    color: darkgrey;
}
</style>
<script>
    jq(function () {
        var listOfDrugToIssue =
        ${listDrugIssue}.
        listDrugIssue;
        var listNonDispensed =
        ${listOfNotDispensedOrder}.
        listOfNotDispensedOrder;
		
		jq('#waiverAmount').on('keyup', function(){
			if (jq(this).val() > 0){
				jq('#waivComment').show();
			}
			else{
				jq('#waivComment').hide();
			}
		});

        function DrugOrderViewModel() {
            var self = this;
            self.availableOrders = ko.observableArray([]);
            self.nonDispensed = ko.observableArray([]);
            var mappedOrders = jQuery.map(listOfDrugToIssue, function (item) {
                return new DrugOrder(item);
            });
            var mappedNonDispensed = jQuery.map(listNonDispensed, function (item) {
                return new NonDrugOrder(item);
            });

            self.availableOrders(mappedOrders);
            self.nonDispensed(mappedNonDispensed);

            //observable waiver
            self.waiverAmount = ko.observable(0.00);

            //observable comment
            self.comment = ko.observable("");

            //observable drug
            self.flag = ko.observable(${flag});

            // Computed data
            self.totalSurcharge = ko.computed(function () {
                var total = 0;
                for (var i = 0; i < self.availableOrders().length; i++) {
                    total += self.availableOrders()[i].orderTotal();
                }
                return total.toFixed(2);
            });

            self.runningTotal = ko.computed(function () {
                var rTotal = self.totalSurcharge() - self.waiverAmount();
                return rTotal.toFixed(2);
            });


            //submit bill
            self.submitBill = function () {
                var flag = ${flag};                
				
				var printDiv = jQuery("#printDiv").html();
				var printWindow = window.open('', '', 'height=400,width=800');
				
				printWindow.document.write('<html><head><title>Print Drug Order :-Support by KenyaEHRS</title>');
				printWindow.document.write('</head>');
				printWindow.document.write(printDiv);
				printWindow.document.write('</body></html>');
				printWindow.document.close();
				printWindow.print();
				
				if (flag === 0) {
                    jq("#drugBillsForm").submit();
					window.location.href = emr.pageLink("billingui", "billingQueue");
                }
            }

            self.isNonPaying = ko.computed(function () {
                var cat = "${paymentCategory}";
                if (cat == 2) {
                    return true;
                } else {
                    return false;
                }
            });
        }

        function DrugOrder(item) {
            var self = this;
            self.initialBill = ko.observable(item);
            self.orderTotal = ko.computed(function () {
                var quantity = self.initialBill().quantity;
                var price = self.initialBill().transactionDetail.costToPatient;
                return quantity * price;
            });
        }

        function NonDrugOrder(item) {
            var self = this;
            self.initialNonBill = ko.observable(item);
        }

        var orders = new DrugOrderViewModel();
        ko.applyBindings(orders, jq("#dispensedDrugs")[0]);

    });//end of document ready
</script>

<style>
	.name {
		color: #f26522;
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
		padding: 2px 10px;
	}

	.status-container {
		padding: 5px 10px 5px 5px;
	}

	.catg {
		color: #363463;
		margin: 35px 10px 0 0;
	}

	.title {
		border: 1px solid #eee;
		margin: 3px 0;
		padding: 5px;
	}

	.title i {
		font-size: 1.5em;
		padding: 0;
	}

	.title span {
		font-size: 20px;
	}

	.title em {
		border-bottom: 1px solid #ddd;
		color: #888;
		display: inline-block;
		font-size: 0.5em;
		margin-right: 10px;
		text-transform: lowercase;
		width: 200px;
	}	
	table {
		font-size: 14px;
	}
	th:first-child{
		width: 5px;
	}
	#orderBillingTable th:nth-child(3){
		min-width: 105px;
	}
	#orderBillingTable th:nth-child(4){
		min-width: 85px;
	}
	#orderBillingTable th:nth-child(5){
		width: 50px;
	}
	#waivers label{
		display: inline-block;
		padding-left: 10px;
		width: 140px;
	}
</style>

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
                <a href="${ui.pageLink('billingui', 'listOfOrder')}?patientId=${patient.patientId}">Drug Orders</a>
            </li>


            <li>
                <i class="icon-chevron-right link"></i>
                Pharmacy Order
            </li>
        </ul>
    </div>

    <div class="patient-header new-patient-header">
        <div class="demographics">
            <h1 class="name">
                <span id="surname">${familyName},<em>surname</em></span>
                <span id="othname">${givenName} ${middleName} &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;<em>other names</em>
                </span>

                <span class="gender-age">
                    <span>
                        ${gender}
                    </span>
                    <span id="agename">${age} years</span>

                </span>
            </h1>

            <br/>

            <div id="stacont" class="status-container">
                <span class="status active"></span>
                Visit Status
            </div>

            <div class="tag">Outpatient</div>
            <div class="tad">Last Visit: ${ui.formatDatePretty(lastVisit)}</div>
        </div>

        <div class="identifiers">
            <em>&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;Patient ID</em>
            <span>${identifier}</span>
            <br>

            <div class="catg">
                <i class="icon-tags small" style="font-size: 16px"></i><small>Category: </small>${paymentSubCategory}
            </div>
        </div>

        <div class="close"></div>
    </div>
	

	<div class="title">
		<i class="icon-time"></i>
		<span>
			${ui.formatDatePretty(date)}
			<em style="width: 70px;">&nbsp; order date</em>
		</span>
		
		<i class="icon-quote-left"></i>
		<span>
			00${receiptid}
			<em>&nbsp; receipt number</em>
		</span>
	</div>

    <div class="dashboard clear" id="dispensedDrugs">
        <table width="100%" id="orderBillingTable" class="tablesorter thickbox">
            <thead>
				<tr align="center">
					<th>#</th>
					<th>DRUG</th>
					<th>FORMULATION</th>
					<th>FREQUENCY</th>
					<th>#DAYS</th>
					<th>COMMENTS</th>
					<th>EXPIRY</th>
					<th>QNTY</th>
					<th>PRICE</th>
					<th>TOTAL</th>
				</tr>
            </thead>

            <tbody data-bind="foreach: availableOrders, visible: availableOrders().length > 0">
				<tr>
					<td data-bind="text: \$index()+1"></td>
					<td data-bind="text: initialBill().transactionDetail.drug.name"></td>
					<td>
						<span data-bind="text: initialBill().transactionDetail.formulation.name"></span> -
						<span data-bind="text: initialBill().transactionDetail.formulation.dozage"></span>
					</td>
					<td data-bind="text: initialBill().transactionDetail.frequency.name"></td>
					<td data-bind="text: initialBill().transactionDetail.noOfDays"></td>
					<td data-bind="text: initialBill().transactionDetail.comments"></td>
					<td data-bind="text: initialBill().transactionDetail.dateExpiry.substring(0, 11)"></td>
					<td data-bind="text: initialBill().quantity"></td>
					<td data-bind="text: initialBill().transactionDetail.costToPatient.toFixed(2)"></td>
					<td data-bind="text: orderTotal().toFixed(2)"></td>
				</tr>
            </tbody>		
					
			<tbody>
				<tr>
					<td></td>
					
					<td colspan="8">
						<b>TOTAL AMOUNT</b>
					</td>
					
					<td>
						<span data-bind="text: totalSurcharge, css:{'retired': isNonPaying()}"></span>
						<span data-bind="visible: isNonPaying()">0.00</span>
					</td>
				</tr>
				
				<tr>
					<td></td>
					
					<td colspan="8">
						<span data-bind="visible: flag() == 0"><b>TOTAL PAYABLE</b></span>
						<span data-bind="visible: flag() == 1"><b>TOTAL TENDERED</b></span>					
					</td>
					
					<td>
						<span data-bind="text: runningTotal,css:{'retired': isNonPaying()}"></span>
						<span data-bind="visible: isNonPaying()">0.00</span>
					</td>
				</tr>
			</tbody>
        </table>

        <div id="nonDispensedDrugs" data-bind="visible: nonDispensed().length > 0" style="display: none;">
			<div class="title" style="margin-top: 10px;">
				<i class="icon-remove-sign" style="color: #f00"></i>
				<span>
					DRUGS NOT ISSUED
					<em>&nbsp; from pharmacy</em>
				</span>
			</div>
			            
            <table width="100%" id="nonDispensedDrugsTable" class="tablesorter thickbox">
                <thead>
                <tr align="center">
                    <th>#</th>
                    <th>DRUG</th>
                    <th>FORMULATION</th>
                    <th>FREQUENCY</th>
                    <th>#DAYS</th>
                    <th>COMMENTS</th>
                </tr>
                </thead>

                <tbody data-bind="foreach: nonDispensed">
                <tr>
                    <td data-bind="text: \$index()+1"></td>
                    <td data-bind="text: initialNonBill().inventoryDrug.name"></td>
                    <td>
                        <span data-bind="text: initialNonBill().inventoryDrugFormulation.name"></span> -
                        <span data-bind="text: initialNonBill().inventoryDrugFormulation.dozage"></span> -
                    </td>
                    <td data-bind="text: initialNonBill().frequency.name"></td>
                    <td data-bind="text: initialNonBill().noOfDays"></td>
                    <td data-bind="text: initialNonBill().comments"></td>
                </tr>
                </tbody>
            </table>
        </div>        

		<div id='waivers' data-bind="visible: flag() == 0" style="margin-top: 10px">
			<label for="waiverAmount">Waiver Amount:</label> 
			<input id="waiverAmount" data-bind="value: waiverAmount"/><br/>

			<div id="waivComment" style="margin-top: 2px; display: none;">
				<label for="waiverComment">Waiver Comment:</label>
				<textarea type="text" id="waiverComment" name="waiverComment"
										 size="7" class="hasborder" style="height: 60px; width: 83.4%; resize: none;"
										 data-bind="value: comment"></textarea> <br/>
			</div>
		</div>

        <div style="margin: 10px">
            <i class="icon-user small"></i>
			<label style="font-size: 90%; color: rgb(85, 85, 85); display: inline-block; width: 115px;">Cashier: </label>${cashier}<br/>
			
			<i class="icon-user small"></i>
			<label style="font-size: 90%; color: rgb(85, 85, 85); display: inline-block; width: 115px;">Pharmacist: </label>${pharmacist}<br/>
        </div>
		
        <form method="post" id="drugBillsForm" style="padding-top: 10px">
            <input id="patientId" name="patientId" type="hidden" value="${identifier}">
            <input id="receiptid" name="receiptid" type="hidden" value="${receiptid}">
            <input id="flag" name="flag" type="hidden" value="${flag}">

            <textarea name="drugOrder" data-bind="value: ko.toJSON(\$root)" style="display:none;"></textarea>
            <input type="button" class="button cancel"
                   onclick="javascript:window.location.href = 'billingQueue.page?'"
                   value="Cancel">


            <% if (flag == 1) { %>
				<span type="submit" id="savebill" class="button task right" data-bind="click: submitBill, enable: availableOrders().length > 0 ">
					<i class="icon-print small"></i>
					Reprint
				</span>
            <% } else { %>
				<span id="savebill" class="button task right" data-bind="click: submitBill, enable: availableOrders().length > 0 ">
					<i class="icon-save small"></i>
					Finish   
				</span>
            <% } %>

        </form>

        <!-- PRINT DIV -->
        <div id="printDiv" style="display: none;">
            <div style="margin: 10px auto; width: 981px; font-size: 1.0em;font-family:'Dot Matrix Normal',Arial,Helvetica,sans-serif;">

                <table class="spacer" style="margin-left: 60px;">
                    <tr>
                        <h3>
                            <center><b><u>${userLocation}</u> </b></center>
                        </h3>
                    </tr>
                    <tr>
                        <h5><b>
                            <center>CASH RECEIPT : PHARM-${receiptid}</center>
                        </b></h5>
                    </tr>
                </table>
                <br/>
                <br/>

                    <table class="spacer" style="margin-left: 60px;">
                        <tr>
                            <td>Date/Time:</td>
                            <td>:${date}</td>
                </tr>
                    <tr>
                        <td>Name</td>
                        <td>
                            :${givenName}&nbsp;${familyName}&nbsp;${middleName} </td>
                    </tr>
                    <tr>
                        <td>Patient ID</td>
                        <td>:${identifier }</td>
                    </tr>
                    <tr>
                    <tr>
                        <td>Age</td>
                        <td>:
                         ${age}
                        </td>
                    </tr>
                    </tr>
                    <tr>
                        <td>Gender</td>
                        <td>:${gender}</td>
                    </tr>
                    <tr>
                        <td>Payment Category</td>
                        <td>:${paymentSubCategory}</td>
                    </tr>


            </table>
                <table width="100%"  class="tablesorter thickbox">
                    <thead>
                    <tr align="center">
                        <th>S.No</th>
                        <th>Drug</th>
                        <th>Formulation</th>
                        <th>Frequency</th>
                        <th>Days</th>
                        <th>Comments</th>
                        <th>Expiry</th>
                        <th>Quantity</th>
                        <th>Unit Price</th>
                        <th>Item Total</th>
                    </tr>
                    </thead>

                    <tbody data-bind="foreach: availableOrders, visible: availableOrders().length > 0">
						<tr>
							<td data-bind="text: \$index()+1"></td>
							<td data-bind="text: initialBill().transactionDetail.drug.name"></td>
							<td>
								<span data-bind="text: initialBill().transactionDetail.formulation.name"></span> -
								<span data-bind="text: initialBill().transactionDetail.formulation.dozage"></span>
							</td>
							<td data-bind="text: initialBill().transactionDetail.frequency.name"></td>
							<td data-bind="text: initialBill().transactionDetail.noOfDays"></td>
							<td data-bind="text: initialBill().transactionDetail.comments"></td>
							<td data-bind="text: initialBill().transactionDetail.dateExpiry"></td>
							<td data-bind="text: initialBill().quantity"></td>
							<td data-bind="text: initialBill().transactionDetail.costToPatient.toFixed(2)"></td>
							<td data-bind="text: orderTotal().toFixed(2)"></td>
						</tr>
                    </tbody>
                </table>
                


                <div data-bind="visible: nonDispensed().length > 0">
                    <center><h3>Drugs Not Issued</h3></center>
                    <table width="100%"  class="tablesorter thickbox">
                        <thead>
                        <tr align="center">
                            <th>S.No</th>
                            <th>Drug</th>
                            <th>Formulation</th>
                            <th>Frequency</th>
                            <th>Days</th>
                            <th>Comments</th>
                        </tr>
                        </thead>

                        <tbody data-bind="foreach: nonDispensed">
                        <tr>
                            <td data-bind="text: \$index()+1"></td>
                            <td data-bind="text: initialNonBill().inventoryDrug.name"></td>
                            <td>
                                <span data-bind="text: initialNonBill().inventoryDrugFormulation.name"></span> -
                                <span data-bind="text: initialNonBill().inventoryDrugFormulation.dozage"></span> -
                            </td>
                            <td data-bind="text: initialNonBill().frequency.name"></td>
                            <td data-bind="text: initialNonBill().noOfDays"></td>
                            <td data-bind="text: initialNonBill().comments"></td>
                        </tr>
                        </tbody>
                    </table>

                </div>


                

                <div>
                    <div style="float:right;">Total :
                        <span data-bind="text: totalSurcharge, css:{'retired': isNonPaying()}"></span>
                        <span data-bind="visible: isNonPaying()">0.00</span>
                    </div><br/>

                    <div style="float:right;">Amount To Pay :
                        <span data-bind="text: runningTotal,css:{'retired': isNonPaying()}"></span>
                        <span data-bind="visible: isNonPaying()">0.00</span>
                    </div>
                </div>

                <br/><br/><br/><br/><br/><br/>
                <span style="float:left;font-size: 1.5em">Attending Cashier: ${cashier}</span><span
                    style="float:right;font-size: 1.5em">Attending Pharmacist: ${pharmacist}</span>
                <br/><br/><br/><br/><br/><br/>
                <span style="margin-left: 13em;font-size: 1.5em">Signature of Inventory Clerk/ Stamp</span>
            </div>
        </div>
        <!-- END PRINT DIV -->

    </div>

</div>
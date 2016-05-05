<script>
    var toReturn;
    jq(function () {
        var receiptsData = getOrderList();
        jQuery('.date-pick').datepicker({minDate: '-100y', dateFormat: 'dd/mm/yy'});
        jq("#issueName, #receiptId").on("keyup", function () {
            issueList();
        });

        jq("#fromDate-display, #toDate-display").change(function () {
            issueList();
        });
		
		jq('#searchProcessed').change(function(){
			//console.log(jq('#searchProcessed:checked').length);
		});

        function issueList() {
            var receiptId 	= jq("#receiptId").val();
            var issueName 	= jq("#issueName").val();
            var fromDate 	= moment(jq("#fromDate-field").val()).format('DD/MM/YYYY');
            var toDate 		= moment(jq("#toDate-field").val()).format('DD/MM/YYYY');
            toReturn		= getOrderList(issueName, fromDate, toDate, receiptId);
			
            list.drugList(toReturn);
        }
		
        function IssueDrugViewModel() {
            var self = this;
            // Editable data
            self.drugList = ko.observableArray([]);
            var mappedDrugItems = jQuery.map(receiptsData, function (item) {
                return item;
            });

            self.viewDetails = function (item) {
                window.location.replace("detailedReceiptOfDrug.page?receiptId=" + item.id);
            };
            self.drugList(mappedDrugItems);
            self.processDrugOrder = function (item) {
                //redirect to processing page
                var url = '${ui.pageLink("billingui","processDrugOrder")}';
                window.location.href = url + '?orderId=' + item.id + '&patientId=' + item.patient.patientId;
            }
        }

        var list = new IssueDrugViewModel();
        ko.applyBindings(list, jq("#orderList")[0]);
    });

    function getOrderList(issueName, fromDate, toDate, receiptId) {
        jQuery.ajax({
            type: "GET",
            url: '${ui.actionLink("billingui", "subStoreIssueDrugList", "getOrderList")}',
            dataType: "json",
            global: false,
            async: false,
            data: {
                issueName: issueName,
                fromDate: fromDate,
                toDate: toDate,
                receiptId: receiptId
            },
            success: function (data) {
                toReturn = data;
            }
        });
        return toReturn;
    }
</script>

<style>
	.formfactor .zero-col{
		display: inline-block;
		margin-top: 5px;
		overflow: hidden;
		width: 35%;
	}
	.formfactor .other-col{
		display: inline-block;
		margin-top: 5px;
		overflow: hidden;
		width: 21%;
	}
	.formfactor .zero-col input,
	.formfactor .other-col input{
		padding: 0 10px;
		width: 98%;
	}
	#fromDate label,
	#toDate label{
		display: none;
	}
	#fromDate .add-on,
	#toDate .add-on {
		margin-top: 5px;
	}	
	.formfactor .zero-col label,
	.formfactor .other-col label {
		color: #363463;
		cursor: pointer;
		padding-left: 5px;
		margin-bottom: 5px;
	}
	#orderList th:first-child{
		width: 5px;
	}	
	#orderList th:nth-child(2){
		width: 70px;
	}
	#orderList th:nth-child(3){
		width: 220px;
	}
	#orderList th:nth-child(5){
		width: 100px;
	}
	#orderList th:last-child{
		width: 110px;
	}
	#divSeachProcessed{
		margin-right: 20px;
		margin-top: 25px;
	}
	#divSeachProcessed label{
		cursor: pointer;
	}
	#divSeachProcessed input{
		cursor: pointer;
	}
</style>

<h2><b>Manage Issue Drug</b></h2>
					
<span class="button confirm right" style="float: right; margin: 8px 5px 0 0;">
	<i class="icon-refresh small"></i>
	Get Patients
</span>

<div id="divSeachProcessed" class="right">
	<label>
		<input type="checkbox" id="searchProcessed" name="searchProcessed">
		Include Processed
	</label>
</div>

<div class="formfactor onerow">
	<div class="zero-col">
		<label for="issueName">Patient Name</label><br/>
		<input type="text" name="issueName" id="issueName" class=" searchFieldBlur" placeholder="Patient Name"/>
	</div>
	
	<div class="other-col">
		<label for="fromDate-display">From Date:</label><br/>
		${ui.includeFragment("uicommons", "field/datetimepicker", [formFieldName: 'fromDate', id: 'fromDate', label: 'From Date', useTime: false, defaultToday: true, class: ['searchFieldChange', 'date-pick', 'searchFieldBlur']])}
	</div>
	
	<div class="other-col">
		<label for="toDate-display">To Date:</label><br/>
		${ui.includeFragment("uicommons", "field/datetimepicker", [formFieldName: 'toDate', id: 'toDate', label: 'To Date', useTime: false, defaultToday: true, class: ['searchFieldChange', 'date-pick', 'searchFieldBlur']])}
	</div>
	
	<div class="other-col">
		<label for="receiptId">From Date:</label><br/>
		<input type="text" name="receiptId" class="searchFieldChange" id="receiptId" placeholder="Receipt No."/>
	</div>	
</div>

<form method="get" id="form">
    <div id="orderList">
        <table width="100%">
            <thead>
				<tr>
					<th>#</th>
					<th>RECEIPT</th>
					<th>IDENTIFIER</th>
					<th>NAMES</th>
					<th>DATE</th>
					<th>ACTION</th>
				</tr>
            </thead>
            <tbody data-bind="foreach: drugList">
				<tr>
					<td data-bind="text: \$index() + 1"></td>
					<td data-bind="text: id"></td>
					<td data-bind="text: identifier"></td>
					<td>
						<span data-bind="text: patient.givenName"></span>&nbsp;
						<span data-bind="text: patient.familyName"></span>
					</td>
					<td data-bind="text: createdOn.substring(0, 11)"></td>
					<td>
						<a class="remover" href="#" data-bind="click: \$root.processDrugOrder"
						   title="Detail issue drug to this patient">
							<i class="icon-bar-chart small"></i> PROCESS
						</a>
					</td>
				</tr>
            </tbody>
        </table>
    </div>
</form>
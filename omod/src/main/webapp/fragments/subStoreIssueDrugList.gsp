<script>
    var toReturn;
    jq(function () {
        var receiptsData = getOrderList();
        jQuery('.date-pick').datepicker({minDate: '-100y', dateFormat: 'dd/mm/yy'});
        jq(".searchFieldChange").on("change", function () {
            issueList();
        });

        jq(".searchFieldBlur").on("blur", function () {
            issueList();
        });

        function issueList() {
            var receiptId = jq("#receiptId").val();
            var issueName = jq("#issueName").val();
            var fromDate = jq("#fromDate").val();
            var toDate = jq("#toDate").val();
            toReturn= getOrderList(issueName, fromDate, toDate, receiptId);
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

<div class="dashboard clear">
    <div class="info-section">
        <div class="info-header">
            <i class="icon-calendar"></i>

            <h3>Manage Issue Drug</h3>
        </div>
    </div>
</div>

<form method="get" id="form">
    <table>
        <tr>
            <td><input type="text" name="issueName" id="issueName" class=" searchFieldBlur" placeholder="Patient Name"/>
            </td>
            <td><input type="text" id="fromDate" class="date-pick left searchFieldChange searchFieldBlur "
                       readonly="readonly" name="fromDate"
                       title="Double Click to Clear" ondblclick="this.value = '';" placeholder="From Date:"/></td>
            <td><input type="text" id="toDate" class="date-pick left searchFieldChange searchFieldBlur"
                       readonly="readonly" name="toDate"
                       title="Double Click to Clear" ondblclick="this.value = '';" placeholder="To Date:"/></td>
            <td><input type="text" name="receiptId" class="searchFieldChange" id="receiptId" placeholder="Receipt No."/>
            </td>
        </tr>
    </table>
    <br/>

    <div id="orderList">
        <table width="100%" cellpadding="5" cellspacing="0">
            <thead>
            <tr>
                <th>S.No</th>
                <th>Receipt No.</th>
                <th>Patient ID</th>
                <th>Name</th>
                <th>Issue Date:</th>
                <th>Action</th>
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
                <td data-bind="text: createdOn"></td>
                <td>
                    <a class="remover" href="#" data-bind="click: \$root.processDrugOrder"
                       title="Detail issue drug to this patient">
                        <i class="icon-signin  small">View/Print</i>
                    </a>
                </td>
            </tr>
            </tbody>
        </table>
    </div>
</form>
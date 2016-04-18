<%
    ui.decorateWith("appui", "standardEmrPage", [title: "Cashier : Drug Order"])
%>

<script>
    jq(function () {
        var listOfDrugToIssue =
        ${listDrugIssue}.
        listDrugIssue;
        var listNonDispensed =
        ${listOfNotDispensedOrder}.
        listOfNotDispensedOrder;

        function DrugOrderViewModel() {
            var self = this;
            self.availableOrders = ko.observableArray([]);
            var mappedOrders = jQuery.map(listOfDrugToIssue, function (item) {
                return new DrugOrder(item);
            });

            self.availableOrders(mappedOrders);


            // Computed data
            self.totalSurcharge = ko.computed(function () {
                var total = 0;
                for (var i = 0; i < self.availableOrders().length; i++) {
                    total += self.availableOrders()[i].orderTotal();
                }
                return total;
            });

            //observable waiver
            self.waiverAmount = ko.observable(0.00);

            //observable comment
            self.comment = ko.observable("");

            //submit bill
            self.submitBill=function(){
                jq().toastmessage('showErrorToast', "Save Functionality yet to be implemented!");
            }
        }

        function DrugOrder(item) {
            console.log(item);
            var self = this;
            self.initialBill = ko.observable(item);
            self.orderTotal = ko.computed(function () {
                var quantity = self.initialBill().quantity;
                var price = self.initialBill().transactionDetail.costToPatient;
                return quantity * price;
            });
        }

        var orders = new DrugOrderViewModel();
        ko.applyBindings(orders, jq("#dispensedDrugs")[0]);

    });//end of document ready
</script>

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
                <span id="othname">${givenName} ${middleName}  &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;<em>other names</em>
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
                Order Date : ${date}
            </div>

            <div class="tag">Outpatient</div>
        </div>

        <div class="identifiers">
            <em>&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;Patient ID</em>
            <span>${identifier}</span>
            <br>

            <div class="catg">
                <i class="icon-tags small" style="font-size: 16px"></i><small>Category:</small>${paymentSubCategory}
            </div>
        </div>

        <div class="close"></div>
    </div>

    <div class="dashboard clear" id="dispensedDrugs">
        <table width="100%" id="orderBillingTable" class="tablesorter thickbox">
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
                <td data-bind="text: initialBill().transactionDetail.costToPatient"></td>
                <td data-bind="text: orderTotal"></td>

            </tr>

            </tbody>

        </table>
        <br />
        <div>
            <div style="float:right;">Total : <span data-bind="text: totalSurcharge"></span></div>
            Waiver Amount: <input id="waiverAmount" data-bind="value: waiverAmount"/><br/>
            Waiver Comment:<textarea type="text" id="waiverComment" name="waiverComment" size="7" class="hasborder" style="width: 99.4%; height: 60px;" data-bind="value: comment"></textarea><br/>


        </div>

        <form method="post" id="billsForm" style="padding-top: 10px">
            <input id="patientId" type="hidden" value="${identifier}">
            <textarea name="bill" data-bind="value: ko.toJSON(\$root)" style="display:none;" ></textarea>
            <input type="button" class="button cancel"
                   onclick="javascript:window.location.href = 'billingQueue.page?'"
                   value="Cancel">

            <input type="submit" id="savebill" name="savebill" style="float:right;" class="button confirm"
                   value="Finish" data-bind="click: submitBill, enable: availableOrders().length > 0 ">

        </form>

    </div>

</div>
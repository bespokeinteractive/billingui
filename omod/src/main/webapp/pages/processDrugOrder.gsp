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
//observable waiver
            self.waiverAmount = ko.observable(0.00);

            //observable comment
            self.comment = ko.observable("");

            // Computed data
            self.totalSurcharge = ko.computed(function () {
                var total = 0;
                for (var i = 0; i < self.availableOrders().length; i++) {
                    total += self.availableOrders()[i].orderTotal();
                }
                return total;
            });

            self.runningTotal = ko.computed(function () {
                var rTotal = self.totalSurcharge() - self.waiverAmount();
                console.log(rTotal);
                return rTotal;
            });


            //submit bill
            self.submitBill = function () {
                console.log(${receiptid}+',' +${flag });
                var flag =${flag };
                var rId = ${receiptid};
                if (flag === 0) {
                    //process the drug , it hasn't been processed yet
                    jq("#drugBillsForm").submit();

                } else {
                    //drug has been processed, we just do a reprint
                    jq().toastmessage('showErrorToast', "Drug Processed Already- Do a reprint!");
                    var printDiv = jQuery("#printDiv").html();
                    var printWindow = window.open('', '', 'height=400,width=800');
                    printWindow.document.write('<html><head><title>Print Drug Order :-Support by KenyaEHRS</title>');
                    printWindow.document.write('</head>');
                    printWindow.document.write(printDiv);
                    printWindow.document.write('</body></html>');
                    printWindow.document.close();
                    printWindow.print();
                }
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

            <div class="tag">Receipt Id: ${receiptid}</div>
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
        <br/>

        <div>
            <div style="float:right;">Total : <span data-bind="text: totalSurcharge"></span></div><br/>

            <div style="float:right;">Amount To Pay : <span data-bind="text: runningTotal"></span></div>

            <div data-bind="visible: waiverAmount() > 0">
                Waiver Amount: <input id="waiverAmount" data-bind="value: waiverAmount"/><br/>
                Waiver Comment:<textarea type="text" id="waiverComment" name="waiverComment"
                                         size="7" class="hasborder" style="width: 99.4%; height: 60px;"
                                         data-bind="value: comment"></textarea> <br/>
            </div>

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
            <input type="submit" id="savebill" name="savebill" style="float:right;" class="button confirm"
                   value="Reprint" data-bind="click: submitBill, enable: availableOrders().length > 0 ">
            <% } else { %>
            <input type="submit" id="savebill" name="savebill" style="float:right;" class="button confirm"
                   value="Finish" data-bind="click: submitBill, enable: availableOrders().length > 0 ">
            <% } %>

        </form>

    </div>
    <!-- PRINT DIV -->
    <div id="printDiv" style="display: none;">
        <div style="margin: 10px auto; width: 981px; font-size: 1.0em;font-family:'Dot Matrix Normal',Arial,Helvetica,sans-serif;">
            <br/>
            <br/>
            <center style="float:center;font-size: 2.2em">Process Drug</center>
            <br/>
            <br/>
            <span style="float:right;font-size: 1.7em">Date: ${date}</span>
            <br/>
            <br/>
            <table border="1">
                <tr align="center">
                    <th>S.No</th>
                    <th>Category</th>
                    <th>Drug Name</th>
                    <th>Formulation</th>
                    <th>Quantity</th>
                    <th>Transfer Quantity</th>
                </tr>

            </table>

            <br/><br/><br/><br/><br/><br/>
            <span style="float:left;font-size: 1.5em">Signature of sub-store/ Stamp</span><span
                style="float:right;font-size: 1.5em">Signature of inventory clerk/ Stamp</span>
            <br/><br/><br/><br/><br/><br/>
            <span style="margin-left: 13em;font-size: 1.5em">Signature of Medical Superintendent/ Stamp</span>
        </div>
    </div>
    <!-- END PRINT DIV -->

</div>
<%
    ui.decorateWith("appui", "standardEmrPage", [title: "Cashier - Add Patient Bill"])
    ui.includeCss("uicommons", "styleguide/index.css")
    ui.includeCss("billingui", "paging.css")
    ui.includeJavascript("billingui", "paging.js")
    ui.includeJavascript("billingui", "common.js")
    ui.includeJavascript("billingui", "jquery.PrintArea.js")
    ui.includeJavascript("billingui", "knockout-3.4.0.js")

%>
<script>
    var pData;
    jQuery(function () {
        var bill = new BillItemsViewModel();
        pData = getBillableServices();



        // Class to represent a row in the bill addition grid
        function BillItem(quantity, initialBill) {
            var self = this;
            self.quantity = ko.observable(quantity);
            self.initialBill = ko.observable(initialBill);

            self.formattedPrice = ko.computed(function () {
                var price = self.initialBill().price;
                return price ? price.toFixed(2) : "0.00";
            });

            self.itemTotal = ko.computed(function () {
                var price = self.initialBill().price;
                var quantity = self.quantity();
                var runningTotal = price * quantity;
                return runningTotal ? runningTotal : "0.00";
            });
        }

        // Overall viewmodel for this screen, along with initial state
        function BillItemsViewModel() {
            var self = this;

            // Non-editable catalog data - would come from the server
            self.availableServices = pData;


            // Editable data
            self.billItems = ko.observableArray([]);

            // Computed data
            self.totalSurcharge = ko.computed(function () {
                var total = 0;
                for (var i = 0; i < self.billItems().length; i++)
                    total += self.billItems()[i].itemTotal();
                return total;
            });

            //observable waiver
            self.waiverAmount = ko.observable(0.00);

            //observable comment
            self.comment = ko.observable("");

            // Operations
            self.addBillItem = function (availableServices) {
                self.billItems.push(new BillItem("1", availableServices));
            }
            self.removeBillItem = function (item) {
                self.billItems.remove(item);
            }
            self.cancelBillAddition = function(){
                window.location.replace("billableServiceBillListForBD.page?patientId=${patientId}&billId=${lastBillId}")
            }
            self.submitBill = function(){
                if(self.totalSurcharge() < self.waiverAmount()){
                    alert("Please enter correct Waiver Amount");
                }else if(isNaN(self.waiverAmount()) || self.waiverAmount() < 0){
                    alert("Please enter correct Waiver Amount");
                }else{
                    //submit the details to the server
                    jQuery("#billsForm").submit();

                }
            }
        }


        ko.applyBindings(bill, jQuery("#example")[0]);

        jQuery("#service").autocomplete({
            minLength: 3,
            source: function (request, response) {
                jq.getJSON('${ ui.actionLink("billingui", "billableServiceBillAdd", "loadBillableServices") }',
                        {
                            name: request.term
                        }
                ).success(function (data) {

                            var results = [];
                            for (var i in data) {
                                var result = {label: data[i].name, value: data[i]};
                                results.push(result);
                            }
                            response(results);
                        });
            },
            focus: function (event, ui) {
                jQuery("#service").val(ui.item.value.name);
                return false;
            },
            select: function (event, ui) {
                event.preventDefault();
                jQuery("#service").val(ui.item.value.name);
                bill.addBillItem(ui.item.value);
                jq('#service').val('');

            }


        });


    });//end of document ready function


    function getBillableServices() {
        var toReturn;
        jQuery.ajax({
            type: "GET",
            url: "${ui.actionLink('billingui','billableServiceBillAdd','loadBillableServices')}",
            dataType: "json",
            data: ({
                name: "ray"
            }),
            global: false,
            async: false,
            success: function (data) {
                toReturn = data;
            }
        });
        return toReturn;


    }





</script>
<openmrs:require privilege="Add Bill" otherwise="/login.htm"
                 redirect="/module/billing/main.form"/>
<div class="clear"></div>

<div class="container">
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
                Date/ Time: ${currentDate}
            </div>

            <div class="tag">File Number : ${fileNumber}</div>
        </div>

        <div class="identifiers">
            <em>Patient ID</em>
            <span>${patient.patientIdentifier.identifier}</span>
            <em>Payment Category</em>
            <span>${category}</span>
        </div>
    </div>


    <div id="example">
        <label for="service">Add Bill Item by typing:</label>
        <input type="text" id="service" name="service"/>

        <h2>Bill Items (<span data-bind="text: billItems().length"></span>)</h2>
        <table>
            <thead><tr>
                <th>Service Name</th><th>Quantity</th><th>Unit Price</th><th>Item Total</th><th></th>
            </tr></thead>
            <tbody data-bind="foreach: billItems">
            <tr>
                <td data-bind="text: initialBill().name"/></td>
                <td><input data-bind="value: quantity"/></td>
                <td data-bind="text: formattedPrice"></td>
                <td><span data-bind="text: itemTotal().toFixed(2)"></span></td>
                <td><a href="#" data-bind="click: \$root.removeBillItem"><i class="icon-remove small"
                                                                            style="color:red"></i></a></td>
            </tr>
            </tbody>
        </table>

        <h3 data-bind="visible: totalSurcharge() > 0">

            Total surcharge: Kshs. <span data-bind="text: totalSurcharge().toFixed(2)"></span><br />
            Waiver Amount: Kshs. <input data-bind="value: waiverAmount" /> &nbsp;&nbsp;Comments. <input data-bind="value: comment, enable: waiverAmount() > 0" />
        </h3>

        <br /><br />


        <form  method="post" id="billsForm">
            <input id="patientId" type="hidden" value="${patientId}">

            <textarea name="bill" data-bind="value: ko.toJSON(\$root)"></textarea>
            <button data-bind="click: submitBill, enable: billItems().length > 0 ">Save</button>  <button data-bind="click: cancelBillAddition">Cancel</button>
        </form>

    </div>


</div>



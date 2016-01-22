<%
    ui.decorateWith("appui", "standardEmrPage", [title: "Cashier Module"])
    ui.includeJavascript("billingui", "moment.js")
%>
<head>
    <script>
        currentPage = 1;
        var jq = jQuery;
        function loadOpdPatients() {
            alert(this.options[this.selectedIndex].text);
        }

        // get queue
        function getBillingQueue(currentPage) {
            jq("#selection").show(0);
            this.currentPage = currentPage;
            var date = moment(jq("#datetime-field").val()).format('DD/MM/YYYY');
            var searchKey = jQuery("#searchKey").val();
            var pgSize = jQuery("#sizeSelector").val();
            jQuery.ajax({
                type: "GET",
//                url: getContextPath() + "/module/billing/patientsearchbillingqueue.form",
                url: "${ui.actionLink('billingui','opdBillingQueue','getBillingQueue')}",
                dataType: "json",
                data: ({
                    date: date,
                    searchKey: searchKey,
                    searchKey: searchKey,
                    currentPage: currentPage,
                    pgSize: pgSize
                }),
                success: function (data) {

                    console.log(data);
                    jQuery("#billingqueue").show(0);
                    jQuery("#billingqueue").html(data);
                },

            });
        }

        jq(function () {
            jq("#tabs").tabs();
            jq("#selection").hide(0);
            jq("#getOpdPatients").click(function(){
                getBillingQueue(1);
            });

        });
    </script>
</head>

<body>

<div id="tabs">
    <ul>
        <li><a href="#tabs-1">Outdoor Patient Queue</a></li>
        <li><a href="#tabs-2">Indoor Patient Queue</a></li>
        <li><a href="#tabs-3">Billing Ambulance</a></li>
        <li><a href="#tabs-4">Billing Tender</a></li>
        <li><a href="#">Billing Misc Service</a></li>
    </ul>

    <div id="tabs-1">
        <p>

        <h3>Outdoor Patient Queue</h3>
        <article style="margin-bottom: 20px;">
            <table>
                <thead>
                <tr>
                    <th>Get Queue</th>
                </tr>
                </thead>
            </table>
        </article>

        <p class="left">
            ${ui.includeFragment("uicommons", "field/datetimepicker", [formFieldName: 'datetime',id: 'datetime', label: 'Date', useTime: false, defaultToday: true])}
        </p>
        <label for="searchKey">Search patient in Queue:</label>
        <input id="searchKey" type="text" name="searchKey" placeholder="Enter Patient Name/ID:">

        <div>
            <ul style=" margin-top: 5px;margin-left: 39px;margin-bottom: 10px;" class="grid">
                <li>
                    <a class="button confirm" id="getOpdPatients">
                        Get Patients
                    </a>
                </li>
            </ul>
            <section>
                <div>
                    <table cellpadding="5" cellspacing="0" width="100%" id="queueList">
                        <thead>
                        <tr align="center">
                            <th>S.No</th>
                            <th>Patient ID</th>
                            <th>Name</th>
                            <th>Age</th>
                            <th>Gender</th>
                        </tr>
                        </thead>
                        <tbody>

                        <tr align="center">
                            <td colspan="5">No patient found</td>
                        </tr>
                        </tbody>
                    </table>
                </div>
            </section>

            <div id="selection">
                Show
                <select name="sizeSelector" id="sizeSelector" onchange="getBillingQueue(1)">
                    <option value="50" id="1">50</option>
                    <option value="100" id="2" selected>100</option>
                    <option value="150" id="3">150</option>
                    <option value="200" id="4">200</option>
                </select>
                entries
            </div>
        </div>
    </div>

    <div id="tabs-2">
        <p>

        <h3>Inpatient Patient Queue</h3>
        <article id="tables" style="margin-bottom: 15px;">
            <table>
                <thead>
                <tr>
                    <th>Get Queue</th>
                </tr>
                </thead>
            </table>
        </article>
        <label for="username">Search patient in Queue:</label>
        <input id="username" type="text" name="username" placeholder="Enter Patient Name/ID:">

        <div>
            <ul style=" margin-top: 3px; margin-bottom: 10px;margin-left: 1px;" class="grid">
                <li>
                    <a class="button confirm" href="#">
                        Get Patients
                    </a>
                </li>
            </ul>
        </div>
        <section>
            <div>
                <table cellpadding="5" cellspacing="0" width="100%" id="queueList2">
                    <thead>
                    <tr align="center">
                        <th>S.No</th>
                        <th>Admission Date</th>
                        <th>Patient ID</th>
                        <th>Name</th>
                        <th>Age</th>
                        <th>Admission Ward</th>
                        <th>Select Action</th>
                    </tr>
                    </thead>
                    <tbody>
                    <tr align="center">
                        <td>S.No</td>
                        <td>Admission Date</td>
                        <td>Patient ID</td>
                        <td>Name</td>
                        <td>Age</td>
                        <td>Admission Ward</td>

                        <td><button class="button confirm">Add Bill</button>
                            <button class="button confirm">View Bill</button>
                        </td>
                    </tr>
                    <tr align="center">
                        <td colspan="7">No patient found</td>
                    </tr>
                    </tbody>
                </table>
            </div>
        </section>
    </div>

    <div id="tabs-3">
        <div>
            <ul style=" margin-top: 3px; margin-bottom: 20px;margin-left: 1px;" class="grid">
                <li>
                    <a class="button confirm" href="#">
                        Add New Driver
                    </a>
                </li>
            </ul>
        </div>
        <article id="tables3" style="margin-bottom: 10px;">
            <table>
                <thead>
                <tr>
                    <th>Search Driver</th>
                </tr>
                </thead>
            </table>
        </article>
        <label for="username3">Enter Driver's Name:</label>
        <input id="username3" type="text" name="username" placeholder="Name:">

        <div>
            <ul style=" margin-top: 10px; margin-bottom: 15px;margin-left: 1px;" class="grid">
                <li>
                    <button class="button confirm">Search</button>
                    <button class="button confirm">List all</button>
                </li>
            </ul>
        </div>
        <section>
            <div>
                <table cellpadding="5" cellspacing="0" width="100%" id="queueList3">
                    <thead>
                    <tr align="center">
                        <th>Driver Name</th>
                        <th>Description</th>
                    </tr>
                    </thead>
                    <tbody>
                    <tr align="center">
                        <td>Name</td>
                        <td>Description</td>
                    </tr>
                    <tr align="left">
                        <td colspan="7">No Result</td>
                    </tr>
                    </tbody>
                </table>
            </div>
        </section>
    </div>

    <div id="tabs-4">
        <div>
            <ul style=" margin-top: 3px; margin-bottom: 20px;margin-left: 1px;" class="grid">
                <li>
                    <a class="button confirm" href="#">
                        Add New Company
                    </a>
                </li>
            </ul>
        </div>
        <article id="tables4" style="margin-bottom: 10px;">
            <table>
                <thead>
                <tr>
                    <th>Search Company</th>
                </tr>
                </thead>
            </table>
        </article>
        <label for="username4">Enter Company's Name:</label>
        <input id="username4" type="text" name="username" placeholder="Name:">

        <div>
            <ul style=" margin-top: 10px; margin-bottom: 15px;margin-left: 1px;" class="grid">
                <li>
                    <button class="button confirm">Search</button>
                    <button class="button confirm">List all</button>
                </li>
            </ul>
        </div>
        <section>
            <div>
                <table cellpadding="5" cellspacing="0" width="100%" id="queueList4">
                    <thead>
                    <tr align="center">
                        <th>Company Name</th>
                        <th>Description</th>
                    </tr>
                    </thead>
                    <tbody>
                    <tr align="center">
                        <td>Name</td>
                        <td>Description</td>
                    </tr>
                    <tr align="left">
                        <td colspan="7">No Result</td>
                    </tr>
                    </tbody>
                </table>
            </div>
        </section>
    </div>
</div>
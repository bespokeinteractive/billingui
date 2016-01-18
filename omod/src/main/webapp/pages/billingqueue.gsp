<% ui.decorateWith("appui", "standardEmrPage", [title: "Cashier Module"]) %>
<head>
    <script>
        var jq = jQuery;
        jq(function () {
            jq("#tabs").tabs();
        });
    </script>
</head>

<body>

<div id="tabs">
    <ul>
        <li><a href="#tabs-1">Outdoor Patient Queue</a></li>
        <li><a href="#tabs-2">Indoor Patient Queue</a></li>
        <li><a href="#tabs-3">Billing Ambulance</a></li>
        <li><a href="#">Billing Tender</a></li>
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
            ${ui.includeFragment("uicommons", "field/datetimepicker", [id: 'datetime', label: 'Date', formFieldName: 'date picker', useTime: false])}
        </p>
        <label for="username">Search patient in Queue:</label>
        <input id="ipdusername" type="text" name="username" placeholder="Enter Patient Name/ID:">

        <div>
            <ul style=" margin-top: 5px;margin-left: 39px;margin-bottom: 10px;" class="grid">
                <li>
                    <a class="button confirm" href="#">
                        Get Patients
                    </a>
                </li>
            </ul>
            <section>
                <div>
                    <table cellpadding="5" cellspacing="0" width="100%" id="queueList" >
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
                            <td>S.No</td>
                            <td>Patient ID</td>
                            <td>Name</td>
                            <td>Age</td>
                            <td>Gender</td>
                        </tr>
                        <tr align="center">
                            <td colspan="7">No patient found</td>
                        </tr>
                        </tbody>
                    </table>
                </div>
            </section>
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
</div>
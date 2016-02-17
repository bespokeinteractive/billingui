<%
    ui.decorateWith("appui", "standardEmrPage", [title: "Cashier Module"])
	
	ui.includeCss("billingui", "onepcssgrid.css")
    
	ui.includeJavascript("uicommons", "moment.js")
	ui.includeJavascript("billingui", "jquery.dataTables.min.js")
    def props = ["identifier", "fullname", "age", "gender", "patientId", "action"]
%>
<head>
    <link rel="stylesheet" type="text/css" href="https://cdn.datatables.net/1.10.10/css/jquery.dataTables.min.css">
    <script>
        currentPage = 1;
        var pData;
        var jq = jQuery;
        function loadOpdPatients() {
            alert(this.options[this.selectedIndex].text);
        }

        //update the queue table
        function updateQueueTable(data) {
            var date = moment(jq("#datetime-field").val()).format('DD/MM/YYYY');
            jq('#queueList > tbody > tr').remove();
            var tbody = jq('#queueList > tbody');
            for (index in data) {
                var item = data[index];
                var row = '<tr>';
                <% props.each {
               if(it == props.last()){
                  def pageLink = ui.pageLink("billingui", "listOfOrder") %>
                row += '<td> <a href="${pageLink}?patientId=' + item.patientId + '&date=' + date + '"><i class="icon-signin small"></i></a> </td>';
                <% } else {%>
                row += '<td>' + item.${ it } + '</td>';
                <% }
               } %>
                row += '</tr>';
                tbody.append(row);
            }
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
                url: "${ui.actionLink('billingui','opdBillingQueue','getBillingQueue')}",
                dataType: "json",
                data: ({
                    date: date,
                    searchKey: searchKey,
                    currentPage: currentPage,
                    pgSize: pgSize
                }),
                success: function (data) {
                    pData = data;
                    updateQueueTable(data);

//                    jQuery("#billingqueue").show(0);
//                    jQuery("#billingqueue").html(data);
                },

            });
        }

        jq(function () {
            jq("#tabs").tabs();
            jq("#selection").hide(0);
            jq("#getOpdPatients").click(function () {
                getBillingQueue(1);
            });

            var lastValue = '';
            jq("#searchKey").on('change keyup paste mouseup', function () {


                if (jq(this).val() != lastValue) {
                    lastValue = jq(this).val();
                    getBillingQueue(1);
                }

            });

        });
    </script>
	
	<style>
		body {
			margin-top: 20px;
		}

		.col1, .col2, .col3, .col4, .col5, .col6, .col7, .col8, .col9, .col10, .col11, .col12 {
			color: #555;
			text-align: left;
		}

		form input,
		form select{
			margin: 0px;
			display: inline-block;
			min-width: 50px;
			padding: 2px 10px;
			height: 32px !important;
		}
		.info-header span{
			cursor: pointer;
			display: inline-block;
			float: right;
			margin-top: -2px;
			padding-right: 5px;
		}
		.dashboard .info-section {
			margin: 2px 5px 5px;
		}
		.toast-item{
			background-color: #222;
		}

		@media all and (max-width: 768px) {
			.onerow {
				margin: 0 0 100px;
			}
		}
		form .advanced {
			background: #363463 none repeat scroll 0 0;
			border-color: #dddddd;
			border-style: solid;
			border-width: 1px;
			color: #fff;
			cursor: pointer;
			float: right;
			padding: 6px 0;
			text-align: center;
			width: 27%;
		}
		form .advanced i{
			font-size: 22px;
		}
		.col4 label {
			width: 110px;
			display: inline-block;
		}

		.col4 input[type=text] {
			display: inline-block;
			padding: 4px 10px;
		}

		.col4 select {
			padding: 4px 10px;
		}

		form select {
			min-width: 50px;
			display: inline-block;
		}
		.addon{
			display: inline-block;
			float: right;
			margin: 5px 0 0 140px;
			position: absolute;
		}
		.identifiers span {
			border-radius: 50px;
			color: white;
			display: inline;
			font-size: 0.8em;
			letter-spacing: 1px;
			margin: 5px;
		}
		table.dataTable thead th, table.dataTable thead td {
			padding: 5px 10px;
		}
		form input:focus{
			border: 1px solid #00f!important;
		}
		input[type="text"], select {
			 border: 1px solid #aaa;
			 border-radius: 2px!important;
			 box-shadow: none!important;
			 box-sizing: border-box!important;
			 height: 32px;
		 }
		 
		.newdtp{
			width: 166px;
		}
		#lastDayOfVisit label{
			display:none;
		}
		#lastDayOfVisit input{
			width:166px;
		}
		.add-on {
			float: right;
			left: auto;
			margin-left: -29px;
			margin-top: 5px;
			position: absolute;
		}
		.ui-widget-content a {
			color: #007fff;
		}
	</style>

</head>

<body>

<div id="tabs">
    <ul>
        <li><a href="#tabs-1">OPD Queue</a></li>
        <li><a href="#tabs-2">IPD Queue</a></li>
        <li><a href="#tabs-3">Billing Ambulance</a></li>
        <li><a href="#tabs-4">Billing Tender</a></li>
        <li><a href="#">Billing Misc Service</a></li>
        <li><a href="#tabs-5">Search Patient</a></li>
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
            ${ui.includeFragment("uicommons", "field/datetimepicker", [formFieldName: 'datetime', id: 'datetime', label: 'Date', useTime: false, defaultToday: true])}
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
                            <th>Patient ID</th>
                            <th>Given Name</th>
                            <th>Age</th>
                            <th>Gender</th>
                            <th>Patient ID</th>
                            <th>Action</th>
                        </tr>
                        </thead>
                        <tbody>

                        <tr align="center">
                            <td colspan="6">No patient found</td>
                        </tr>
                        </tbody>
                    </table>
                </div>
            </section>

            <div id="selection">
                Show
                <select name="sizeSelector" id="sizeSelector" onchange="getBillingQueue(1)">
                    <option value="10" id="1">10</option>
                    <option value="20" id="2" selected>20</option>
                    <option value="50" id="3">50</option>
                    <option value="100" id="4">100</option>
                    <option value="150" id="5">150</option>
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

    <div id="tabs-5">
        ${ui.includeFragment("billingui", "searchPatient")}
    </div>
</div>
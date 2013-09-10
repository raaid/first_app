baseurl = "http://ticketacular.herokuapp.com/";

function getBarcode() {
	var successCallback = function(data) {
		getResults(data.text);
	};
	
	var fail = function(msg) {
		console.log(msg);
	}
	
	 networkState = navigator.network.connection.type;
	 
	 if (connected()) {	
		window.plugins.barcodeScanner.scan( successCallback, fail);
	 } else {
         navigator.notification.alert("Please ensure you have a connection to the internet.",successNotify,'Eventastic',"OK");
	 }
}

function connected() {
	networkState = navigator.network.connection.type;
	if (networkState != "none") {	
		return true;
	 } else {
	 	return false;
	 }
	
}
function successNotify() {
}

function getResults(code) {

	if (connected()) {
	var dataVars = {};
	dataVars.format = "json";
	
	$.ajax({
		type: "GET",
		url: baseurl + "ticket_instances/" + code + "/redeem",
		data: dataVars,
		success: function(data) {
			obj = JSON.parse(data);
			response = obj.response;
			details = obj.details; 
			
			if (response == "error1") {           
           navigator.notification.alert("Error!\nThis Ticket Has Already Been Redeemed...\n\n"+details,successNotify,'Eventastic',"OK");
			} else if (response == "error2") {
           navigator.notification.alert("Error!\nThis Ticket Has Not Been Successfully Paid For Yet...\n\n"+details,successNotify,'Eventastic',"OK");
			} else if (response == "error3") {
           navigator.notification.alert("Error!\nThis Ticket Is No Longer Valid, As It Has Already Been Processed For A Refund...\n\n"+details,successNotify,'Eventastic',"OK");
			}else if (response == "error4") {
                      navigator.notification.alert("Error!\nThis Ticket ID Is Not A Valid Ticket ID...",successNotify,'Eventastic',"OK");
			} else if (response == "ok") {
           navigator.notification.alert("Success!\nThis Ticket Has Been Redeemed.\n\n"+details,successNotify,'Eventastic',"OK");
			}else{
           navigator.notification.alert("Error!\nThis Ticket ID Is Not A Valid/Registered Ticket ID...",successNotify,'Eventastic',"OK");
			}	
			
		},
		error: function(msg) {
                      navigator.notification.alert("Error!\nThis Ticket ID Is Not A Valid Ticket ID...",successNotify,'Eventastic',"OK");
		}
	});
	} else {
        navigator.notification.alert("Please connect to the internet",successNotify,'Eventastic',"OK");
	}
}

function manualInput() {
	code = document.getElementById("input").value;
	getResults(code);
}

function searchEmail() {
	
	if (connected()) {
	email = document.getElementById('searchInput').value;
	document.getElementById("searchInput").value = "";
	
	var dataVars = {};
	dataVars.format = "json";
	dataVars.email = email;
	
	$.ajax({
		type: "GET",
		url: baseurl + "search_by_email",
		data: dataVars,
		success: function(data) {
			document.getElementById("searchResults").style.display = "block";
			document.getElementById("backbtn").style.display = "block";
		    document.getElementById("scanbtn").style.display = "none";
            document.getElementById("manual").style.display = "none";
            document.getElementById("search").style.display = "none";

			clearDiv('results');

			tickets = [];
			ticketsDetails = [];
			obj = JSON.parse(data);
			if (obj != null) {
				document.getElementById("name").innerHTML = obj[0].name;

				for (i = 1; i < obj.length; i++) {
					if (obj[i].status == "paid") {				
						tickets.push(obj[i].id);
						ticketsDetails.push(obj[i].details);
					}
				}
			
				if (tickets.length > 0) {
			
					container = document.getElementById("results");	
					/* Create results html elements and display */		   
					for(i = 0; i < tickets.length; i++) {
						result = document.createElement("input");
						result.setAttribute("type", "checkbox");
						result.setAttribute("value", tickets[i]);
						result.setAttribute("class", "checkbox");
				
						text = document.createElement("div");
						text.setAttribute("class", "item");
						text.innerHTML = "ID: "+tickets[i]+" - "+ticketsDetails[i];
				
						container.appendChild(result);
						container.appendChild(text);
						br = document.createElement("br");
						container.appendChild(br);
					}
				} else {
					document.getElementById('noresults').style.display = "block";
					document.getElementById('redeemAll').style.display = "none";
				}
			} else {
				document.getElementById('noresults').style.display = "block";
				    document.getElementById("scanbtn").style.display = "none";
    document.getElementById("manual").style.display = "none";
    document.getElementById("search").style.display = "none";	
				document.getElementById('redeemAll').style.display = "none";
			}
		},
		error: function(msg) {
           navigator.notification.alert("err: " + JSON.stringify(msg),successNotify,'Eventastic',"OK");
		}
	});
	} else { 
        navigator.notification.alert("Please connect to the internet",successNotify,'Eventastic',"OK");
	}
}

function redeemAll() {
	$('input:checked').each(function() {
    	getResults($(this).val());
	});
	hideResults();
}

function clearDiv(id) {
	node = document.getElementById(id);

	while (node.firstChild) {
    	node.removeChild(node.firstChild);
	}
}

function hideResults() {
	document.getElementById("searchResults").style.display = "none";
	document.getElementById("backbtn").style.display = "none";
	document.getElementById('noresults').style.display = "none";
	document.getElementById('redeemAll').style.display = "block";	
    document.getElementById("scanbtn").style.display = "block";
    document.getElementById("manual").style.display = "block";
    document.getElementById("search").style.display = "block";	
}
/* uncomment if screen orientation is allowed, will need to change styles to accommodate */
/*
function orientationChange(e) {
	scanbtn = document.getElementById("scanbtn");
	manual = document.getElementById("manual");
	search = document.getElementById("search");

	if(window.orientation == -90 || window.orientation == 90) {
		scanbtn.style.top = "-105px";
		scanbtn.style.left = "0";
		manual.style.left = "0";
		manual.style.marginTop = "80px";
		search.style.left = "0";
		search.style.marginTop = "80px";
	} else {
		scanbtn.style.top = "0";
		scanbtn.style.left = "15px";
		manual.style.left = "15px";
		manual.style.marginTop = "25px";
		search.style.left = "15px";
		search.style.marginTop = "25px";
	}
}
*/
function preventBehavior(e) {
	e.preventDefault();
}


// A custom scroller
function range(variable, min, max) {
    if(variable < min) return min > max ? max : min;
    if(variable > max) return max;
    return variable;
}

var isScrolling = false;
var mouseY = 0;
var cScroll = 0;
if("createTouch" in document) {
    // TODO: Add for mobile browsers
} else {
    content.addEventListener('mousedown', function(evt) {
        isScrolling = true;
        mouseY = evt.pageY;
    }, false);
    content.addEventListener('mousemove', function(evt) {
        if(isScrolling) {
            var dY = evt.pageY - mouseY;
            mouseY = evt.pageY;
            cScroll += dY;

            var firstElementChild = content.getElementsByTagName("*")[0];

            content.style.WebkitTransform = 'translateY(' + range(cScroll, -(firstElementChild.scrollHeight - content.offsetHeight), 0).toString() + 'px)';
        }
    }, false);
    window.addEventListener('mouseup', function(evt) {
        isScrolling = false;
    }, false);
}



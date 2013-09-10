function errorFunction() {
    alert('It seems like Geolocation, which is required for this page, is not enabled in your browser. Please use a browser which supports it.');
}
function successFunction(position) {
    var lat = position.coords.latitude;
    var long = position.coords.longitude;
    alert('Your latitude is :' + lat + ' and longitude is ' + long);
}

// Success callback function
function displayPosition(pos) {

    //Load Google Map
    var latlng = new google.maps.LatLng(pos.coords.latitude, pos.coords.longitude);
    var myOptions = {zoom:15,center:latlng,mapTypeId:google.maps.MapTypeId.HYBRID};
    var map = new google.maps.Map(document.getElementById("map_canvas"), myOptions);

    //Add marker
    var marker = new google.maps.Marker({position:latlng,map:map,title:"You are here"});

}

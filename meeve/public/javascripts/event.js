/*
	Functions for Google map
*/

var map;
var marker = null;		// The red marker on the map, set to null
// var geocoder;

  // Initializes a Google map
  function initialize() {
  	
  	//geocoder = new google.maps.Geocoder();	// Geocoder constructor

    var latlng = new google.maps.LatLng(49.262316,-123.245058); // Initial location of the map
	// Initial map option
    var myOptions = {
      zoom: 15,
      center: latlng,
      mapTypeId: google.maps.MapTypeId.ROADMAP
    };
	// Gets a map and place it within the element
    map = new google.maps.Map(document.getElementById("map_canvas"),
        myOptions);

	google.maps.event.addListener(map, 'click', function(event) {
	   // Clear a marker on the map
	   if (marker != null) {
	   	  marker.setMap(null);
	   }
	   // Place a marker on the map
	   placeMarker(event.latLng);
	});
  };
  
  function placeMarker(location){
  	marker = new google.maps.Marker({
  		position: location,
  		map: map
  	});
	//map.setCenter(location);
  }
  
/*
  function codeAddress() {
    var address = document.getElementById("address").value;
    geocoder.geocode( { 'address': address}, function(results, status) {
      if (status == google.maps.GeocoderStatus.OK) {
        map.setCenter(results[0].geometry.location);
        var marker = new google.maps.Marker({
            map: map, 
            position: results[0].geometry.location
        });
      } else {
        alert("Geocode was not successful for the following reason: " + status);
      }
    });
  }
*/


/*
 	Pop-up Dialog using Google Closure
 */
goog.require('goog.events');
goog.require('goog.events.EventType');
goog.require('goog.ui.Dialog');
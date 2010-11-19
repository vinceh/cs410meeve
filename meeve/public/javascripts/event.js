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
	
	// Get a boundary limit coordinates
    var sw = new google.maps.LatLng(49.239457,-123.265915);
	var ne = new google.maps.LatLng(49.276205,-123.215103);
	var allowedBounds = new google.maps.LatLngBounds(sw, ne);

	// Initial map option
    var myOptions = {
      zoom: 15,
      center: latlng,
      mapTypeId: google.maps.MapTypeId.ROADMAP
    };
	// Gets a map and place it within the element
    map = new google.maps.Map(document.getElementById("map_canvas"),
        myOptions);
	
	// Function that checks if the user trying to go out of bound
	function checkBounds() { 
	    if (allowedBounds.contains(map.getCenter())) {
	        return;
	    }
	
	    var c = map.getCenter();
	    var x = c.lng();
	    var y = c.lat();
	    var maxX = allowedBounds.getNorthEast().lng();
	    var maxY = allowedBounds.getNorthEast().lat();
	    var minX = allowedBounds.getSouthWest().lng();
	    var minY = allowedBounds.getSouthWest().lat();
	
	    if (x < minX) {x = minX;}
	    if (x > maxX) {x = maxX;}
	    if (y < minY) {y = minY;}
	    if (y > maxY) {y = maxY;}
	
	    map.setCenter(new google.maps.LatLng(y, x));
	}

	// Add an eventListener to the drag event
	google.maps.event.addListener(map, 'drag', function() { checkBounds() });

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
/*
	Functions for Google map
*/

var map;
var marker = null;		// The red marker on the map, set to null
// var geocoder;

  function mapNew() {
  	var latlng = new google.maps.LatLng(49.262316,-123.245058); // Initial location of the map (UBC)
  	setMap(latlng, true);
  };
  
  function mapEdit() {
  	var lat = Number($("input#event_marker_lat").val());
	var lng = Number($("input#event_marker_lng").val());
	var latlng = new google.maps.LatLng(lat,lng);
	setMap(latlng, true);
	placeMarker(latlng);
  };
  
  function mapView() {
  	map = null;
  	var lat = Number($("input#marker_lat").val());
	var lng = Number($("input#marker_lng").val());
	var latlng = new google.maps.LatLng(lat,lng);
	setMap(latlng, false);
	placeMarker(latlng);
  }

  // Initializes a Google map
  function setMap(latlng, enable_marker) {
  	
  	//geocoder = new google.maps.Geocoder();	// Geocoder constructor
	
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
	
	if (enable_marker) {
		// Add an eventListener that makes a marker on the map
		google.maps.event.addListener(map, 'click', function(event){
			// Clear a marker on the map
			if (marker != null) {
				marker.setMap(null);
			}
			// Place a marker on the map
			placeMarker(event.latLng);
			
			// Get geographic position of the marker
			getGeoPosition();
		});
	}
  };
  
  // A function to place a marker on the map
  function placeMarker(location){
  	marker = new google.maps.Marker({
  		position: location,
  		map: map
  	});
	//map.setCenter(location);
  };
  
  // A function to get a geographic position of the marker
  function getGeoPosition() {
  	if (marker) {
		var position = marker.getPosition();
		$("input#event_marker_lat").val(position.lat());
		$("input#event_marker_lng").val(position.lng());
	}
  };
  
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
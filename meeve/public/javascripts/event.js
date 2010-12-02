/*
 	Google Closure Requirements
 */
goog.require('goog.events');
goog.require('goog.events.EventType');
goog.require('goog.ui.Dialog');
goog.require('goog.ui.ComboBox');

/*
 * Event Create
 */
$(document).ready(function () {
	$("div#map_canvas").hide();
	$("#repeat_option_field").hide();
	setMapCanvas();
	setPrivacy();
	setRepeat();
});

  function setMapCanvas() {
  	$("#google_map_option").click(function () {
		var cb = $(this)
		if (cb.is(':checked')) {
			$("div#map_canvas").show();
			mapNew();
		}
		else {
			$("div#map_canvas").hide();
			mapDelete();
		};
	});
  };
  
  function setPrivacy() {
  	$("#privacy_option").click(function () {
		var cb = $(this);
		var rof = $("#repeat_option_field");
		if (cb.is(':checked')) {
			rof.show();
		}
		else {
			rof.hide();
			clearRepeatOption();
		}
	})
  };
  
  function clearRepeatOption() {
	$("#repeat_option_binary_hidden").val("");
	$("#repeat_option_end_dt_hidden").val("");
	$("#repeat_option").attr('checked', false);
  };
  
  function setRepeat() {
  	$("#repeat_option").click(function () {
		var cb = $(this);
		if (cb.is(':checked')) {
			var $a = $("#repeat_option_link").find("a");
			$a.click();
		}
		else {
			clearRepeatOption();
		}
	})
  }

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
  	if (lat != 0 && lng != 0) {
		$("input#google_map_option").attr('checked', true);
		$("div#map_canvas").show();
		var latlng = new google.maps.LatLng(lat, lng);
		setMap(latlng, true);
		placeMarker(latlng);
	}
  };
  
  function mapDelete() {
  	$("input#event_marker_lat").val("");
	$("input#event_marker_lng").val("");
  }
  
  function mapView() {
  	map = null;
  	var lat = Number($("input#marker_lat").val());
	var lng = Number($("input#marker_lng").val());
	
	if (lat != 0 && lng != 0) {
		var latlng = new google.maps.LatLng(lat, lng);
		setMap(latlng, false);
		placeMarker(latlng);
	}
	else
	{
		$("#map_canvas").hide();
	}
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
	
	// Set max zoom level
	var maxZoomLevel = 15;	
	google.maps.event.addListener(map, 'zoom_changed', function() {
    	if (map.getZoom() < maxZoomLevel) {
			map.setZoom(maxZoomLevel);
		}
   	});
	
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
 *  Comment box hinted input
 */
(function($){
    $.fn.hintedInput = function(hint) {
        
        this.each(function() {
            $.extend(this,{
                "show_hint":function(){
                    $(this).val(hint).css("color","#9a9a9a");
                    $(this).parent("form").find(".submit").hide();
                    $(this).removeData("changed");
                    $(this).parent("form").find("textarea").trigger("change.dynSiz"); // need to trigger autorezie
                },
                "for_input":function(){
                    $(this).css("color","#000");
                    $(this).parent("form").find(".submit").show();
                },
                "no_input":function(){
                    return $(this).data("changed") == undefined || $.trim($(this).val()) == ""
                }
            }); // extend
            this.show_hint(); // initial state is "hinted"
        }); // each

        this.bind({
            focusin: function(){
                if(this.no_input()) { $(this).val("") }
                this.for_input();
            },
            keypress: function() {
                $(this).data("changed",true);
            },
            focusout: function(){
                if(this.no_input()) { this.show_hint(); }
            },
            "success": function(){
                this.show_hint();
                return false;
            }
        }); // end bind
        
        this.parent("form").bind("ajax:loading",function(e,data,status,xhr) {
            $(this).find("input").attr("disabled",true);
        });
        
        // pass the form's ajax:success event to the input field
        this.parent("form").bind("ajax:complete",function(e,data,status,xhr) {
            $(this).find("input").attr("disabled",false);
            $(this).find("text").trigger("success");
        });

//        this.autoResize();
        
        return this;
    };
})(jQuery);

$(document).ready(function () {
	$("input.comment_field").hintedInput("Write a comment...");
})

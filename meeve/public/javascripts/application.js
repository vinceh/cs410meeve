// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
$(window).load(function () {
	$(".signup_form input").bind({
		  focusin: function(){
          $(this).css("border", "1px solid black");
      },
      focusout: function(){
          $(this).css("border", "1px solid #9a9a9a");
      }
	});
    $("#signup_form input").toggle(
        function () {
            $(this).css("height","15em");
        },
        function () {
            $(this).css("height","");
        }
    );
});

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
            $(this).find("textarea").trigger("success");
        });

        this.autoResize();
        
        return this;
    }
})(jQuery);

$(window).load(function () {
    $(".commentBox").hintedInput("Write a comment...");
});


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
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
    
    // search box javascript
    $(".profile_bar form #search_search_input").val("Search");
    $(".profile_bar form #search_search_input").css("color","gray");
    $(".profile_bar form #search_search_input").bind({
		focusin: function(){
		  $(this).css("color","black");
          if ( $(this).val() == "Search" ) {
      	  	$(this).val("");
      	  }
      },
      	focusout: function(){
      	  if ( !$(this).val() ) {
      	  	$(this).css("color","gray");
      	  	$(this).val("Search");
      	  }
      }
	});
	
	// events feed javascript
//	$("div.event").click(function () {
//		window.location = $(this).find("a").attr("data-remote");
//     	return false;
//	});
});

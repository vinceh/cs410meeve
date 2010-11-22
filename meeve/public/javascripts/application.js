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
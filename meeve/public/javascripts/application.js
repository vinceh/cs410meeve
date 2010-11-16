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
function close_matching() {
	slide_matching();
	setTimeout("$('#who_is_free').show();", 400);
};

function slide_matching() {
	$("#matching_results").animate({
		marginLeft: parseInt($("#matching_results").css('marginLeft'),10) == 0 ?
			$("#matching_results").outerWidth() :
			0
	});
};

// JavaScript Document for SimpleDownload

$(document).ready(function(){
	
	// Slider teaser
	$('.flexslider.teaser').flexslider({
		animation: "slide",
		animation: "fade",
		controlNav: false
	});

	// Slider testimonial
	$('.flexslider.testimonial').flexslider({
		animation: "slide",
		controlNav: false,
		slideshowSpeed: 20000,
	});

	// Header Navigation
	$('.scroll').click(function(){
		var mark = $(this).attr('id');
		var position = $('.'+mark).offset().top;
		$('html, body').animate({scrollTop:position - 90}, 'slow');
		return false;
		});

	// Scroll to Top Button
	$(window).scroll(function(){
		if ($(this).scrollTop() > 100) {
			$('.scrollup').fadeIn();
			} else {
			$('.scrollup').fadeOut();
		}
	});

	$('.scrollup').click(function(){
		$("html, body").animate({ scrollTop: 0 }, 'slow');
		return false;
	});

	$('.brand').click(function(){
		$("html, body").animate({ scrollTop: 0 }, 'slow');
		return false;
	});

	// Download Button Image Fade
	$("img.a").hover(
		function() {
			$(this).stop().animate({"opacity": "0"}, "slow");
		},
		function() {
			$(this).stop().animate({"opacity": "1"}, "slow");
	});
	
	// Screenshots
	$('.screenshots').magnificPopup({
		delegate: 'a', // child items selector, by clicking on it popup will open
		type: 'image'
	});
	
	
	// Newsletter validate and send
	var emailReg = /^[a-zA-Z0-9._-]+@([a-zA-Z0-9.-]+\.)+[a-zA-Z0-9.-]{2,4}$/;

	// Validate
	function validateEmail(email,regex){
		if (!regex.test(email.val()))
			{
				email.addClass('validation-error',500);
				$('form').addClass('validation-error',500);
				return false;
			}
			else
			{
				email.removeClass('validation-error',500);
				$('form').removeClass('validation-error',500);
				return true;
			}
	}

	// Check and Send
	$('#send').click(function(){
		// result of action
		var result=true;

		//Get the data from all the fields
		var email = $('input[name=email]');

		// validate of name input
		if(!validateEmail(email,emailReg)) result=false;

		if(result==false) return false;

		var data = 'email=' + email.val();

		//start the ajax
		$.ajax({
			//this is the php file that processes the data and send mail
			url: "subscribe-newsletter.php", 
			//POST method is used
			type: "POST",
			//pass the data     
			data: data,   
			//Do not cache the page
			cache: false,
			//success
			success: function(data) {
				$('#newsletter-box').html('<h3>Thanks <span class="normal">for subscribe!</span></h3>');
			}
		});

		return false;

	});
	
	// Highlight Input Field
	$('input[name=email]').blur(function(){
		validateEmail($(this),emailReg); 
	});


});
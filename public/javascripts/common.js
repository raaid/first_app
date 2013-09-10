(function($){




/*				  Image Hover 				*/


$(document).ready(function(){
	$('.image_wrapper').append('<div class="image_shader"></div>');
	$('.image_wrapper').hover(function(){
		var padd = 10, wid = 21;
		if($(this).find('.image_more_info.small').length > 0) {
			padd = 8; wid = 16;
		}
		$(this).find('.image_more_info a img').stop(true).animate({padding:padd+'px', width:(wid)+'px'}, 200, function(){
			$(this).animate({width:wid+'px'}, 200);
			});
		$(this).find('.image_shader').stop(true).animate({opacity: 0.6}, 200);
		$(this).find('.image_socials a').each(function(index){
			var del = index*100;
			$(this).find('span').delay(del).animate({top : 0}, 200);
		});
		$(this).find('.image_read_more_wrapper').animate({opacity : 1}, 400);
	}, function(){
		$(this).find('.image_more_info a img').stop(true).animate({padding:'0px', width:'0px'}, 100);
		$(this).find('.image_shader').stop(true).animate({opacity: 0}, 200);
		$(this).find('.image_socials a span').stop(true).animate({top : '40px'}, 200);
		$(this).find('.image_read_more_wrapper').stop(true).animate({opacity: 0}, 200);
	});
	
	
});

/*		Image Hover - products		*/
$(document).ready(function(){
	$('.products_sidebar a').each(function(index){
			$(this).hover(function(){
			$('.image_wrapper.prod').eq(index).trigger('mouseenter');
		
		}, function(){
			$('.image_wrapper.prod').eq(index).trigger('mouseleave');
		
		});
	});
});


/*					Header Menu					*/

$(document).ready(function(){

	$('.header_menu li').hover(function(){
		if (jQuery.support.opacity == true){
			$(this).find('.header_submenu_arrow').css('display','block').stop(true, true).animate({opacity : '0.8', top : '+=30'}, 200);
			} else {
			$(this).find('.header_submenu_arrow').css('display','block').stop(true, true).animate({opacity : '1', top : '+=30'}, 200);
			}
		
		$(this).data('hoverOn','true');
		if($(this).children('ul').length != 0) {
			$(this).children('a').addClass('hover');
		} else {
			$(this).children('a').addClass('hover_single');
		}
		$(this).children('ul').css('display','block').stop(true, true).animate({opacity : '1' , top : '+=30'}, 200);
		
		
			
	}, function() {
		$(this).find('.header_submenu_arrow').css('display','none').stop(true, true).animate({opacity : '0', top : '-=30'}, 200);

		$(this).data('hoverOn','false');
		if($(this).children('ul').length != 0) {
			
			var $this = $(this);
			$(this).children('ul').css('display','none').stop(true, true).animate({opacity : '0', top : '-=30'}, 200, function(){
				if($this.data('hoverOn') == 'false') $this.children('a').removeClass('hover');
			});
		} else {
				if($(this).children('ul').length != 0) {
					$(this).children('a').removeClass('hover');
			} else {
				$(this).children('a').removeClass('hover_single');
				}
		}
			
			
	});
	
	$('.header_menu li a').hover(function(){
		$(this).stop(true).animate({backgroundColor : '#e84c3d'},300);
		},function(){
		$(this).stop(true).animate({backgroundColor : 'transparent'},300);
	});


	
});


	var responsive_menu = false;
	$(document).ready(function(){
		var window_width = $(window).width();
		if (window_width < 752) {
			responsive_menu = true;
		}
		else {
			responsive_menu = false;
		}
	})
	$(window).resize(function(){
		var window_width = $(window).width();
		if (window_width < 752) {
			responsive_menu = true;
			if($('.header_wrap').hasClass('sticky')){
				$('.header_wrap').removeClass('sticky');
			}
		}
		else {
			responsive_menu = false;
		}
	})
	$(window).scroll(function(){
		if(!responsive_menu){
			var wind_scr = $(window).scrollTop();
			if(wind_scr < 200){
				if($('.header_wrap').data('sticky') == true){
					$('.header_wrap').data('sticky', false);
					$('.header_wrap').stop(true).animate({opacity : 0}, 150, function(){
						$(this).removeClass('sticky');
						$('.header_wrap').stop(true).animate({opacity : 1}, 300);
					});
				}
			}
			else {
				if($('.header_wrap').data('sticky') == false || typeof $('.header_wrap').data('sticky') == 'undefined'){
					$('.header_wrap').data('sticky', true);
					$('.header_wrap').stop(true).animate({opacity : 0},150,function(){
						$(this).addClass('sticky');
						$('.header_wrap.sticky').stop(true).animate({opacity : 1}, 300);
					});
				}
			}
		}
	});







/*		Header Responsive Menu		*/

$(document).ready(function(){
	$('.responsive_menu select').change(function(){
		var href = $(this).val();
		window.location = href;
	
	});

});






/*						Bubbles						*/

$(document).ready(function(){
	
	if (!lessThenIe8)
	{

		$('.pop_up_bubble').delay(1000).each(function(index) {
			var btop = parseInt($(this).attr('data-top')), 
				bleft = parseInt($(this).attr('data-left')), 
				b2radius = parseInt($(this).attr('data-radius'));
				seq = index*50;
				
			$(this).css({'top':(btop+b2radius/2)+'px', 'left':(bleft+b2radius/2)+'px'});

			
			$(this).delay(seq).animate({top:(btop-3)+'px', left:(bleft-3)+'px', width:(b2radius+6)+'px', height:(b2radius+6)+'px'}, 200, function(){
				$(this).animate({top:btop+'px', left:bleft+'px', width:b2radius+'px', height:b2radius+'px'}, 200);	
			});
			
			$(this).hover(function(){
				if($(this).hasClass('black')) {
					$(this).removeClass('black').addClass('red');
				} else {
					$(this).removeClass('red').addClass('black');
				};
				
				$(this).stop(true).animate({top:(btop-3)+'px', left:(bleft-3)+'px', width:(b2radius+6)+'px', height:(b2radius+6)+'px'}, 200);
			}, function(){
				
			$(this).animate({top:btop+'px', left:bleft+'px', width:b2radius+'px', height:b2radius+'px'}, 200);
			
			});
			
			
		});
	
	}
});


/*					Product Page Statistics				*/



$(document).ready(function(){

  
   $('.statistics_bar').delay(800).each(function(index) {
		var ppwidth = parseInt($(this).attr('data-width')), 
			seq = index*150;
		$(this).delay(seq).animate({width:(ppwidth)+'%'}, 800);
		
	});
 



});

/*				Product Page Order Boxes				*/

$(document).ready(function(){
	$('.product_select').each(function(){
		var $this = $(this);
		$this.hide();
		var selected = $this.find('option[value='+$this.val()+']').html();
		var html = '<div class="select_menu" data-name="'+$this.attr('name')+'">'+
					'<span>'+selected+'</span>'+
					'<a href="" class="drop_button"></a>'+
					'<ul style="display:none">';
					$this.find('option').each(function(){
						html += '<li><a href="#" data-value="'+$(this).attr('value')+'">'+$(this).html()+'</a></li>';
					});
		html +=
						'</ul>'+
					'<div class="clear"></div><!-- clear -->'+
					'</div><!-- select_menu -->';
		$(html).insertAfter($this);
	});
	
	$('.select_menu').hover(function(){
		$(this).data('hover',true);
	}, function(){
		$(this).data('hover', false);
	});
	
	
	$('.drop_button').click(function(e){
		e.preventDefault();
		var $parent = $(this).parent();
		if(!$parent.hasClass('active')) {
			$parent.addClass('active').find('ul').show();
		}
		else {
			$parent.removeClass('active').find('ul').hide();
		}
	});
	
	$('.select_menu ul a').click(function(e){
		e.preventDefault();
		var $parent = $(this).parent().parent().parent();
		var $select = $('select[name='+$parent.attr('data-name')+']');
		$select.val($(this).attr('data-value'));
		$parent.find('span').html($(this).html());
		$parent.removeClass('active').find('ul').hide();
	});
	
	$('body').click(function(){
		$('.select_menu.active').each(function(){
			if(!$(this).data('hover')) {
				$(this).removeClass('active').find('ul').hide();
			}
		});
	});



});

/*				Product Page Zoom Module			*/

$(document).ready(function(){
$('.image_more_info.small a').click(function(e){
	e.preventDefault();
	var imghtml = $(this).parent().parent().find('.content_image').clone();
	var imgsrc = $(this).parent().parent().find('.content_image').attr('src');
	var $parent	= $(this).parent().parent().parent().parent().parent();
	
	
	
	if ($parent.find('.zoom_wrap img.content_image').length > 1){
		$parent.find('.zoom_wrap img.content_image:first').stop(true);
		$parent.find('.zoom_wrap img.content_image:last').remove();
	}


	$parent.find('.zoom_wrap').append(imghtml).find('img.content_image:last').animate({opacity:1}, 370, function(){
		$(this).wrap('<span style="display:inline-block"></span>').css('display', 'block').parent().zoom();
		});
	$parent.find('.zoom_wrap img.content_image:first').animate({opacity:0}, 370, function(){
		$(this).parent().remove();
		});
		
	$parent.find('.image_more_info.big a').attr('href', imgsrc);
	
	

	});
	


});

 /* 					Accordion 					*/
 $(document).ready(function(){
 
 if ($('.acc-content').length > 0)  {

	 var $container = $('.acc-content'),
	  $trigger   = $('.acc-trigger');

	 $container.hide();
	 $trigger.prepend('<span class="acc-arrow"></span>').first().addClass('active').next().show();

	 var fullWidth = $container.outerWidth(true);
	 $trigger.css('width', fullWidth-75);
	 $container.css('width', fullWidth-75);
	 
	 $trigger.click(function(e) {
	  if( $(this).next().is(':hidden') ) {
	   $(this).parent().find('.acc-trigger').removeClass('active').next().slideUp(300);
	   $(this).toggleClass('active').next().slideDown(300);
	  }
	  e.preventDefault();
	  
	 });
	}

});

/*						Tabs						*/
$(document).ready(function(){
	$(".tabs .tabs-nav a").click(function(e){
		e.preventDefault();
		if(!$(this).hasClass('active')) {
			$(this).parent().parent().find('a').removeClass("active");
			$(this).addClass('active');
			
			var $containter = $(this).parent().parent().parent().find('.tabs-container'),
				tabId = $(this).attr('href');
				
			$containter.children('.tab-content').stop(true, true).hide();
			$containter.find(tabId).fadeIn();
		}
  });
	$(".tabs").find("a:first").trigger("click");

});


/* 					Input focus					*/

 $(document).ready(function(){
 $('input.input_field').each(function() {
 	var temp;
 	$(this).focus(function(){
		temp = $(this).attr('value');
		$(this).attr('value', '');
	});
	$(this).focusout(function(){
		if ($(this).attr('value') == '') {
			$(this).attr('value', temp);
		}
	
	});
 });
	

});

/* 					Textarea focus					*/

 $(document).ready(function(){
 $('textarea.textarea_field').each(function() {
 	var tmp;
 	$(this).focus(function(){
		tmp = $(this).html();
		$(this).html('');
	});
	$(this).focusout(function(){
		if ($(this).html() == '') {
			$(this).html(tmp);			
		}

	});
 });
	

});

//			Button Color Animate			

$(document).ready(function(){
	$('.button_hover_effect').hover(function(){
			var hoverClr = $(this).attr('data-hovercolor');
			$(this).stop(true).animate({'background-color': hoverClr}, 300);
	
		}, function(){
			var bgClr = $(this).attr('data-hoveroutcolor');
			$(this).stop(true).animate({'background-color': bgClr}, 300);
		});
		
		
	$('.static_banner_item_button_hover_effect').hover(function(){
			var hoverClr = $(this).attr('data-hovercolor');
			var bgClr = $(this).attr('data-hoveroutcolor');
			$(this).stop(true).animate({'background-color': hoverClr, 'color': bgClr}, 300);
	
		}, function(){
			var hoverClr = $(this).attr('data-hovercolor');
			var bgClr = $(this).attr('data-hoveroutcolor');
			$(this).stop(true).animate({'background-color': bgClr, 'color': hoverClr}, 300);
		});
	

});

//			Button Color Animate - Socials			

$(document).ready(function(){
	$('.footer_socials').each(function(){
		
		
	 	$(this).hover(function(){
			$(this).stop(true).animate({backgroundColor: '#e84c3d'}, 300);
			
		}, function(){
			$(this).stop(true).animate({backgroundColor: '#243030'}, 300);
		});
	
	});

});

//			Header Socials hover

$(document).ready(function(){
	$('.supheader_wrap ul li').find('a').hover(function(){
		$(this).stop(true).animate({opacity : 1}, 200);
	}, function(){
		$(this).animate({opacity:0.7}, 200);
	});
});



})(jQuery);
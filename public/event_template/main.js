$(document).ready(function() {
	
	// auto header resizing
	setMainHeaderSize();
	
	if($(".tab_content")) {
	
		// social box tabs
		
		//Default Action
		$(".tab_content").hide(); //Hide all content
		$("ul.tabs li:first").addClass("active").show(); //Activate first tab
		$(".tab_content:first").show(); //Show first tab content
		
		//On Click Event
		$("ul.tabs li").click(function() {
			$("ul.tabs li").removeClass("active"); //Remove any "active" class
			$(this).addClass("active"); //Add "active" class to selected tab
			$(".tab_content").hide(); //Hide all tab content
			var activeTab = $(this).find("a").attr("href"); //Find the rel attribute value to identify the active tab + content
			$(activeTab).fadeIn(); //Fade in the active content
			return false;
		});
	
	//Default Action
		$(".releasetab_content").hide(); //Hide all content
		$("ul.releasetabs li:first").addClass("active").show(); //Activate first tab
		$(".releasetab_content:first").show(); //Show first tab content
		
		//On Click Event
		$("ul.releasetabs li").click(function() {
			$("ul.releasetabs li").removeClass("active"); //Remove any "active" class
			$(this).addClass("active"); //Add "active" class to selected tab
			$(".releasetab_content").hide(); //Hide all tab content
			var releaseactiveTab = $(this).find("a").attr("href"); //Find the rel attribute value to identify the active tab + content
			$(releaseactiveTab).fadeIn(); //Fade in the active content
			return false;
		});


	} // end if tabs

});

// mailing list placeholder behaviours

function fieldFocus(element, text)
{
	if(text == element.value) {
		element.value = "";
	}
}

function fieldBlur(element, text)
{
	if("" == element.value) {
		element.value = text;
	}
}

// auto header resizing

window.onresize = function() {
    setMainHeaderSize();
}

function setMainHeaderSize() {
	var myWidth = 0, myHeight = 0;
	if( typeof( window.innerWidth ) == 'number' ) {
			//Non-IE
		 myWidth = window.innerWidth;
		 myHeight = window.innerHeight;
	} else if( document.documentElement && ( document.documentElement.clientWidth || document.documentElement.clientHeight ) ) {
			//IE 6+ in 'standards compliant mode'
			myWidth = document.documentElement.clientWidth;
			myHeight = document.documentElement.clientHeight;
	} else if( document.body && ( document.body.clientWidth || document.body.clientHeight ) ) {
			//IE 4 compatible
			myWidth = document.body.clientWidth;
			myHeight = document.body.clientHeight;
	}
	
	var new_image_height = myHeight - 125;
    
    if(new_image_height > 600) {
    	new_image_height = 600;
    } else if(new_image_height < 450) {
    	new_image_height = 450;
    }
    
    var header = document.getElementById('header_big');

	if(header != null) {
		header.style.height = new_image_height + "px";
	}
	
	var headlines = document.getElementById('header_content_headlines');
	
	if(headlines != null) {
		var head_height = headlines.offsetHeight;
		headlines.style.marginTop = "-" + ((head_height/2)+10+10) + "px";
	}
	
	var announcement = document.getElementById('header_content_announcement');
	
	if(announcement != null) {
		var a_head_height = announcement.offsetHeight;
		announcement.style.marginTop = "-" + ((a_head_height/2)+10+10) + "px";
	}
	
	var stream = document.getElementById('header_content_stream');
	
	if(announcement != null) {
		var s_head_height = announcement.offsetHeight;
		announcement.style.marginTop = "-" + ((s_head_height/2)+10+10) + "px";
	}
	
	var stream = document.getElementById('header_content_video');
	
	if(announcement != null) {
		var v_head_height = announcement.offsetHeight;
		announcement.style.marginTop = "-" + ((v_head_height/2)+10+10) + "px";
	}
	
	var videoplayer = document.getElementById('videoplayer');
	
	if(videoplayer != null) {
		videoplayer.style.height = (new_image_height - 50) + "px";
	}
	
	var videoplayerembed = document.getElementById('videoplayerembed');
	
	if(videoplayerembed != null) {
		videoplayerembed.style.height = (new_image_height - 50 ) + "px";
	}
	
}

function showFeature(featureNum) {
	var feature = document.getElementById('feature_image_' + featureNum);
	feature.setAttribute("class", "selected");
}

function hideFeature(featureNum) {
	var feature = document.getElementById('feature_image_' + featureNum);
	feature.setAttribute("class", "");
}

var artistdroptimer = 0;
var artistdroptimer2 = 0;

function showArtistDropDown() {
	window.clearTimeout(artistdroptimer);
	window.clearTimeout(artistdroptimer2);
	var artistdropdownlist = document.getElementById('artistdropdownlist');
	artistdropdownlist.setAttribute("class", "active");
	
	var artistdropdown = document.getElementById('artistdropdown');
	artistdropdown.setAttribute("class", "active");
	
	var nav = document.getElementById('nav');
	var main_width = window.innerWidth;
	var displacement = (main_width - nav.offsetWidth) / 2;
	artistdropdown.style.left = displacement + "px";
}

function hideArtistDropDown() {
	window.clearTimeout(artistdroptimer);
	artistdroptimer = window.setTimeout("realHideArtistDropDown()", 500);
}

function realHideArtistDropDown() {
	var artistdropdownlist = document.getElementById('artistdropdownlist');
	artistdropdownlist.setAttribute("class", "");
	
	artistdroptimer2 = window.setTimeout("hideArtistDropDownPt2()", 300);
}

function hideArtistDropDownPt2() {
	var artistdropdown = document.getElementById('artistdropdown');
	artistdropdown.setAttribute("class", "");
}
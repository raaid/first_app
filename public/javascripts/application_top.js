$(function() {
				$('.close').bind('click', function(){
					$(this).parent().show().fadeOut(500);
				});
			});
            function loginscript(){

                $('#contactPanel').hide();
                $('#searchPanel').hide();
                $('#loginPanel').toggle(500);
                document.getElementById('lights').className = 'animate';
                document.getElementById('lights2').className = 'animate';
            }
            function closelogin(){
                location.reload();
            }
            function showlogin(){
                 $('#loginbuttonsselect').hide();
                 $('#registershow').hide();
                 $('#resetpassword').hide();
                 $('#loginshow').show();
                 document.getElementById('lights3').className = 'animate';
            }
            function showreset(){
                $('#loginbuttonsselect').hide();
                $('#registershow').hide();
                $('#resetpassword').show();
                $('#loginshow').hide();
                document.getElementById('lights5').className = 'animate';
            }
             function showregister(){
                 $('#loginbuttonsselect').hide();
                 $('#registershow').show();
                 $('#resetpassword').hide();
                 $('#loginshow').hide();
                 document.getElementById('lights4').className = 'animate';
            }
            function showSearch(){
               // lightup1();
                //lightup2();
                //lightup3();
                $('#searchPanel').toggle(500);
                $('#contactPanel').hide();
                $('#loginPanel').hide();
            }
            function showContact(){
                //document.getElementById('lightsContact').className = 'animate';
                $('#contactPanel').toggle(500);
                $('#searchPanel').hide();
                $('#loginPanel').hide();
            }

function flash_notice(text) {
  $(document).ready(function() {
    $("#flashNoticeText").html(text);
    $("#flashnotice").show();
    $("#flashnotice").animate({top: "-4px"}, 1000 );
  })
}
$(document).ready(function() {
  $("#flashnotice").hide();
  $("#flashnotice").animate({top: "-20px"}, 0 );
});

function hideflashnotice(){
  $("#flashnotice").animate({top: "-100px"}, 1000 );
}
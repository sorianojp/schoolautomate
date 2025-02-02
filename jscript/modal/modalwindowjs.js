$(document).ready(function() {	
						   
	

	//select all the a tag with name equal to modal
	$('a[name=modal]').click(function(e) {	
		//Cancel the link behavior
		e.preventDefault();
		
		//Get the A tag
		//var id = "#dialog";  //$(this).attr('href');
		var id = $(this).attr('href');
		
		
		//Get the screen height and width
		var maskHeight = $(document).height();
		var maskWidth = $(window).width();
	
		//Set heigth and width to mask to fill up the whole screen
		$('#mask').css({'width':maskWidth,'height':maskHeight});
		
		//transition effect		
		$('#mask').fadeIn(1);	
		//$('#mask').fadeTo("fast",0.6);
		$('#mask').fadeTo(0,0.5);
	
		//Get the window height and width
		var winH = $(window).height();
		var winW = $(window).width();
              
		//Set the popup window to center
		$(id).css('top',  winH/2-$(id).height()/2);
		$(id).css('left', winW/2-$(id).width()/2);
		
		/*$('#dialog').css('top',  winH/2-$('#dialog').height()/2);
		$('#dialog').css('left', winW/2-$('#dialog').width()/2);*/
	
		//transition effect
		$(id).fadeIn(2); 
		//$('#dialog').fadeIn(2000); 
	
	});
	
	
	
	
	
	//if close button is clicked
	$('.window .close').click(function (e) {
		//Cancel the link behavior
		e.preventDefault();
		
		$('#mask').hide();
		$('.window').hide();
	});		
	
	//if mask is clicked
	$('#mask').click(function () {
		$(this).show();
		$('.window').show();
	});			

	$(window).resize(function () {
	 
 		var box = $('#boxes .window');
 
        //Get the screen height and width
        var maskHeight = $(document).height();
        var maskWidth = $(window).width();
      
        //Set height and width to mask to fill up the whole screen
        $('#mask').css({'width':maskWidth,'height':maskHeight});
               
        //Get the window height and width
        var winH = $(window).height();
        var winW = $(window).width();

        //Set the popup window to center
        box.css('top',  winH/2 - box.height()/2);
        box.css('left', winW/2 - box.width()/2);
			 
	});
	
});
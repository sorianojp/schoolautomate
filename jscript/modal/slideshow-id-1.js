// JavaScript Document
    $(function(){
      $("#slideshow").slideshow({
	  pauseSeconds: 15,
	  width: 733,
      height: 238,
	  caption: false //modified to have no description
	  });
      $("#slideshow2").slideshow({
        pauseSeconds: 8,
		width: 733,
        height: 238,
        caption: false
      });
    });
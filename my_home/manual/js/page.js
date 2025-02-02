showpage = function (page,isparent)
{
    if(isparent){
    $('#book #pagewrapper').hide();
    }
    $('#book #pagecontainer div').css('visibility','hidden');
    $('#book #pagecontainer div'+page).css({'visibility':'visible'});
    if(isparent){
    $('#book #pagewrapper').fadeIn('slow');
    }
    

};
hidenavchildren = function()
{
      $('#book .subnav ul li ul.child').css({'visibility':'hidden','display':'none'});
}

// INITIALIZE ---------------------------------------------
$(document).ready(function(){
    $(window).scroll(function() {
        
        if($(window).height()>675){
        $('#book #pagewrapper').css('top', $(this).scrollTop() + "px");
        }
    });


    $('#book #pagecontainer div').css('visibility','hidden');
    $('#book #pagewrapper').hide();
    $('.booknav .nav:visible').hide();
    hidenavchildren();
    var activepage = '#0';
    isparent = true;

    showpage(activepage,isparent);


    //-- intercept nav link clicks --
    $('.subnav h1 a[alt=cover]').click(function(event){
        $('#book #pagewrapper').css('background','url("bookcover.gif") center no-repeat')
        showpage(activepage,isparent);
        hidenavchildren();
        $('#book #pagewrapper').css('top', $(this).scrollTop() + "px");
      event.preventDefault()
    });

    $('.subnav ul li a').click(function(event){

        isparent = false // <-- initial
        if ($(this).attr('class')=='parent')
        {
            if ($(this).siblings('ul').css('visibility')=='visible')
            {
                hidenavchildren();
            }
            else
            {
                hidenavchildren();
                $(this).siblings().css({'visibility':'visible','display':'inherit'}).hide().show('fast');
            }
            $('#book #pagewrapper').css('top', $(this).scrollTop() + "px");
            isparent = true;
        }


        $('#book #pagewrapper').css('background','url("pagewrapper_background.gif") center no-repeat')
         //parse link
         var link = $(this).attr('href');
         delim = (link.search('_'));
         
         if (delim>=0)
         {
            getpage = link.substring(0,delim);
            showpage(getpage,isparent);

            $('#pagecontainer div'+getpage +' .title').css({'background':'none','border':'none'});

            $('#'+link.substring(1,link.length)).css({'border':'1px dashed rgb(190,190,190)','background':'rgb(230,230,230)','border-bottom':'2px solid rgb(100,180,250)'});
            $('#book .subnav').localScroll({
                target:'#pagecontainer div' + getpage
            });

         }
         else
         {
             showpage(link,isparent);
         }

         

         event.preventDefault();


    });

    //--- book swapping ---
    $('.booktitle').mouseover(function(){
        $(this).css('cursor','pointer');
    });
    $('.booktitle').click(function(){

        $('#book #pagewrapper').css('background','url("bookcover.gif") center no-repeat')
        showpage(activepage,isparent);
        hidenavchildren();
        $('#book #pagewrapper').css('top', $(this).scrollTop() + "px");

        bookid = $(this).attr('id');
        selectedid = '#'+bookid+'_nav';

        if ($(selectedid).is(':hidden'))
            {
                if ($('.booknav .nav').is(':visible'))
                {
                $('.booknav .nav:visible').slideUp('fast',function(){
                    $(selectedid).slideDown('fast');
                    });
                }
                else
                {
                    $(selectedid).slideDown('fast');
                }
            }
            else
                {
                   $(selectedid).slideUp('fast')
                }
    });

    //-- highlight serious offenses ---
    $('table#tableofoffenses tr td:contains("C"):nth-child(4)').css('color','red');
    $('table#tableofoffenses tr td:contains("D"):nth-child(4)').css('color','red');
    $('table#tableofoffenses tr td:contains("E"):nth-child(4)').css('color','red');
    $('table#tableofoffenses tr td:contains("F"):nth-child(4)').css('color','red');
    $('table#tableofoffenses tr td:contains("J"):nth-child(4)').css('color','red');

    
});
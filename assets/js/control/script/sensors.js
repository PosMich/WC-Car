$(function(){

    var alpha;
    var beta;
    var gamma;
    //Slider Funtions
    /*$(function() {
        $( "#slider" ).slider({ 
            max: 75 , 
            min: -75, 
            step: 0.01
        });
    });

    $(function() {
        $( "#slider-vertical" ).slider({
            orientation: "vertical",
            min: -90,
            max: 0,
            step: 0.01
        });
    });*/


console.log("Breite: " + $('#direction').width());

    //Get Device Orientation values
    window.addEventListener("deviceorientation",  lagebestimmung, false);

    function lagebestimmung(event) {

        var beta = Math.round(event.beta);
        var gamma = Math.round(event.gamma);



        if(orientation == -90){
            $("#gGamma").html(Math.round((1-(1/90)*gamma)*100)/100);
            $("#gBeta").html(Math.round(-((1/75)*beta)*100)/100);
            $("#wBeta").html(-beta);
            //$("#wGamma").html(-gamma);

            //$("#gBeta").html(-beta);
            //$("#gGamma").html(-gamma);
            //$("#slider").slider("value" , -beta);
            //$("#slider-vertical").slider("value" , -gamma);

            $('#notify').fadeOut('fast');
            $('#dialog').dialog('close');
            $("#orient").html(orientation);

            //Animating thumb to display the direction
            $("#thumbDirection").css({left:(((Math.round(-((1/75)*beta)*100)/100)+1)*($('#direction').width()/2))});

            //Animating thumb to display speed
            $("#thumbForward").css({top:((Math.round(((1/90)*gamma)*100)/100)*($('#forward').height()/2))});
            $("#wGamma").html(((Math.round(((1/90)*gamma)*100)/100)*($('#forward').height()/2)));


            /*$('#notify').fadeIn('fast').bind('touchstart', function(e) {
                e.preventDefault();
            });
            $("#orient").html(orientation);

            //Dialog for wrong orientation
            $('#dialog').dialog('open');*/

        }

        else if(orientation == 90){
            //$("#gBeta").html(beta);

            //Getting values and animating thumb to display speed
            //Query because of degree behavior at this orientation 
            if (gamma < 0) {
                $("#gGamma").html(Math.round((1+(1/90)*gamma)*100)/100);
                $("#thumbForward").css({top:((Math.round(-((1/90)*gamma)*100)/100)*($('#forward').height()/2))});
            } else {
                $("#gGamma").html(Math.round((1+(1/90)*gamma)*100-400)/100);
                $("#thumbForward").css({top:((Math.round(-((1/90)*gamma)*100+400)/100)*($('#forward').height()/2))});
            }
            
            $("#gBeta").html(Math.round(((1/75)*beta)*100)/100);
            $("#wBeta").html(-beta);
            //$("#wGamma").html(gamma);

            //$("#gGamma").html(gamma);
            //$("#slider").slider("value" , beta);
            //$("#slider-vertical").slider("value" , gamma);

            $('#notify').fadeOut('fast');
            $('#dialog').dialog('close');
            $("#orient").html(orientation);

            //Animating thumb to display the direction
            $("#thumbDirection").css({left:(((Math.round(((1/75)*beta)*100)/100)+1)*($('#direction').width()/2))});
        }

        //Portrait Mode 
        else if (orientation == 0 || orientation ==180) {
            $('#notify').fadeIn('fast').bind('touchstart', function(e) {
                e.preventDefault();
            });
            $("#orient").html(orientation);


            //Dialog for wrong orientation
            $('#dialog').dialog('open');
        }  
    };


    //Attach Slider
    $('#slider').slider({
    change: function(event, ui) { 
        console.log(ui.value); 
        } 
    });


    $(function() {
        $( "#dialog" ).dialog({
            minHeight: 400,
            minWidth: 800,
            modal: false,
            autoOpen: false
        });
    });

});

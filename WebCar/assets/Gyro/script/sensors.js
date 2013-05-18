$(function(){

    var alpha;
    var beta;
    var gamma;
    //Slider Funtions
    $(function() {
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
    });


    //Get Device Orientation values
    window.addEventListener("deviceorientation",  lagebestimmung, false);

    function lagebestimmung(event) {

        var alpha = Math.round(event.alpha);
        var beta = Math.round(event.beta);
        var gamma = Math.round(event.gamma);

        console.log window.orientation

        if(window.orientation == -90){
            $("#gGamma").html(Math.round((1-(1/90)*gamma)*100)/100);
            $("#gBeta").html(Math.round(-((1/75)*beta)*100)/100);

            //$("#gBeta").html(-beta);
            //$("#gGamma").html(-gamma);
            $("#slider").slider("value" , -beta);
            $("#slider-vertical").slider("value" , -gamma);

            $('#notify').fadeOut('fast');
            $('#dialog').dialog('close');
            $("#orient").html(orientation);

        }

        else if(window.orientation == 90){
            //$("#gBeta").html(beta);
            $("#gGamma").html(Math.round((1+(1/90)*gamma)*100)/100);
            $("#gBeta").html(Math.round(((1/75)*beta)*100)/100);

            //$("#gGamma").html(gamma);
            $("#slider").slider("value" , beta);
            $("#slider-vertical").slider("value" , gamma);

            $('#notify').fadeOut('fast');
            $('#dialog').dialog('close');
            $("#orient").html(orientation);

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

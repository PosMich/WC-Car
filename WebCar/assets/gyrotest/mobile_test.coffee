$((
    # default vars
    mid = 25     
    b_min = 30
    b_max = 30 
    g_min = 30
    g_max = 30
    g_calib = -50
    b_calib = 0

    # alpha, beta, gamma
    a = 0
    b = 0
    g = 0

    # dom accessors
    x_dom = $('.x')
    y_dom = $('.y')
    z_dom = $('.z')
    a_dom = $('.a')
    b_dom = $('.b')
    g_dom = $('.g')

    fwdbwd = $('.fbwd_clr')
    fb_text = $('.fbwd_text')
    rl = $('.rl_clr') 
    rl_text = $('.rl_text')

    # select default precision
    precision = 1
    precision = Math.pow 10,precision

    # round helper
    round = (val) ->
        Math.round(val * precision) / precision
        
    window.ondeviceorientation = (event) ->
        a = round event.alpha
        b = round event.beta
        g = round event.gamma

        calc()
        return

    # simple calibration    
    $('.calib').click (e) ->
        e.preventDefault()
        g_calib = g
        b_calib = b
        return

    # calculate position  
    calc = ->
        switch true
            when (b < b_calib)
                rl.css "left", mid + (mid / b_min) * (b - b_calib)
            when (b is b_calib)
                rl.css "left", mid + "px"
            when (b > b_calib)
                rl.css "left", mid + (mid / b_max) * (b - b_calib)
            else
                rl.css "left", "80px"
        rl.text b
        
        switch true
            when (g < g_calib)
                fwdbwd.css "top", mid + (mid / g_min) * (g - g_calib) * (-1)
            when (g is g_calib)
                fwdbwd.css "top", mid + "px"
            when (g > g_calib)
                fwdbwd.css "top", mid + (mid / g_max) * (g - g_calib) * (-1)
            else
                fwdbwd.css "top", "80px"
        fb_text.text g
        
        a_dom.text a
        b_dom.text b
        g_dom.text g
        
        return
)())
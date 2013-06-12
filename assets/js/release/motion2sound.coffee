class Motion2Sound
    constructor: ->
        @debug = false
        @TAG = "Motion2Sound"

        # boundaries --> drive left */
        @minFreqLeft = 1000
        @maxFreqLeft = 9000

        # boundaries --> drive right */
        @minFreqRight = 11000
        @maxFreqRight = 20000

        # boundaries --> drive backward */
        @minFreqBwd = 90
        @maxFreqBwd = 490

        # boundaries --> drive forward */
        @minFreqFwd = 510
        @maxFreqFwd = 910

        # drive straight Frequency */
        @straightFreq = 10000

        # stop Frequency */
        @stopFreq = 500

        # init AudioContext

        @context = new webkitAudioContext()
        @oscillator = @context.createOscillator()
        @oscillator.type = 0
        @setFreq 0
        @playSound()

    setFreq: (val) ->
        @oscillator.frequency.value = val

    stopSound: ->
        @oscillator.disconnect()

    playSound: ->
        @oscillator.connect @context.destination
        @oscillator.noteOn && @oscillator.noteOn(0)


    debugOut: (txt) ->
        console.log(@TAG+": "+txt) if @debug

    drive: (left2right, bwd2fwd) ->
        @debugOut "l2r: "+left2right+" |b2f: "+bwd2fwd

        b2f = @getFreqbwd2fwd bwd2fwd
        l2r = @getFreqlft2rght left2right

        @debugOut "bwd2fwd: "+b2f
        @debugOut "left2right: "+l2r

        @setFreq l2r+b2f

    getFreqlft2rght: (l2r) ->
        if l2r>0
            # keep in boundaries */
            l2r = 1 if l2r>1

            # drive right */
            return (@minFreqRight+l2r*parseInt((@maxFreqRight-@minFreqRight)))/1000*1000;

        else if l2r<0
            # keep in boundaries */
            l2r = -1 if l2r<-1

            # drive left */
            return (@maxFreqLeft+l2r*parseInt((@maxFreqLeft-@minFreqLeft)))/1000*1000;
        else
            # drive straight */
            return @straightFreq;

    getFreqbwd2fwd: (b2f) ->
        if (b2f > 0)
            # keep in boundaries */
            b2f = 1 if b2f>1

            # drive forward */
            return parseInt((@minFreqFwd+b2f*(@maxFreqFwd-@minFreqFwd)));

        else if b2f<0
            # keep in boundaries */
            b2f = -1 if b2f<-1

            # drive backward */
            return parseInt((@maxFreqBwd+b2f*(@maxFreqBwd-@minFreqBwd)));
        else
            # stop */
            return @stopFreq

    stop: ->
        @stopSound()
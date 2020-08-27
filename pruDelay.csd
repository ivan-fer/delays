<CsoundSynthesizer>
<CsOptions>
-odac
</CsOptions>
<CsInstruments>

	sr = 44100
	ksmps = 16
	nchnls = 2
	0dbfs = 1


	gaDelay init 0   ; delay
	garevL init 0    ; reverb
	garevR init 0

; returns '1' just in the k-cycle a certain key 
; has been pressed (kdown) or released (kup)
opcode KeyAction, kk, k
	kascii xin            ;ascii code of the key (e.g. 32 for space)

	key, k0 sensekey
	knew changed key
	printk2 key
	kdown = (key == kascii && knew == 1 && k0 == 1 ? 1 : 0)
	kup = (key == kascii && knew == 1 && k0 == 0 ? 1 : 0)
   xout kdown, kup
endop

	alwayson "PlayNote"
	alwayson "Delay"
	alwayson "Reverb"

instr PlayNote
	ktrig, k0 KeyAction 32             ; detecta la barra espaciadora.
	
	if (ktrig == 1) then
		event "i", "Sound", 0, .8
	endif

endin 


instr Sound
	isendToReverb = .4
	iamp = .52

		kenv expseg .001, .1, 1, p3 - .2, 1, .1, .001
		kamp = iamp * kenv
		kfreq = 443
	asig poscil kamp, kfreq
		outs asig, asig

	gaDelay += asig
	garevL += asig * isendToReverb
	garevR += asig * isendToReverb
endin


instr Delay
	asnd = gaDelay * .5
	adel init 0
	ifb = .51
	isendToReverb = .2

	adel delay asnd + (adel * ifb), .4
		outs adel, adel

	gaDelay = 0
	garevL += adel * isendToReverb
	garevR += adel * isendToReverb
endin


instr Reverb
	aL, aR reverbsc garevL, garevR, 0.65, 12000, sr, 0.5, 1
		outs aL, aR
	clear garevL, garevR
endin


</CsInstruments>
<CsScore>
f0 16

</CsScore>
</CsoundSynthesizer>
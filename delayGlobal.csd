<CsoundSynthesizer>
<CsOptions>
-odac
</CsOptions>
<CsInstruments>
; el delay es generado por un instrumento aparte que siempre
; est� prendido. De este modo, act�a como un efecto global.
; La desventaja es que no se puede trabajar a�n individualmente con cada delay.

	sr = 44100
	ksmps = 16
	nchnls = 2
	0dbfs = 1

	garevL init 0    ; reverb
	garevR init 0
	gaDelay init 0   ; delay

	alwayson "PlayNote"
	alwayson "DelayPingPong"
	alwayson "Reverb"


; returns '1' just in the k-cycle a certain key 
; has been pressed (kdown) or released (kup)
opcode KeyAction, kk, k
	kascii xin            ;ascii code of the key (e.g. 32 for space)
	key, k0 sensekey
	knew changed key
	kdown = (key == kascii && knew == 1 && k0 == 1 ? 1 : 0)
	kup = (key == kascii && knew == 1 && k0 == 0 ? 1 : 0)
   xout kdown, kup
endop


instr PlayNote
	ktrig, k0 KeyAction 32             ; detecta la barra espaciadora.
	kfreq randomi 7.00, 11.00, 2.043
	kdlt rspline .5, 1.571, 1.96, 3.074

	if (ktrig == 1) then
		event "i", "Sound", 0, .8, kfreq
	endif

endin 


instr Sound
	isdur = p3
	ifreq = cpsoct(p4)
	itoRev = .1

		kenv expseg .001, .06, 1, isdur - .2, 1, .1, .001, 1, .001
		kfreq = ifreq
		amod poscil 20, 5
	asig1 poscil kenv * amod * .01,  kfreq
	asig clip asig1, 0, .7

		outs asig, asig

	gaDelay = asig
	garevL += asig * itoRev
	garevR += asig * itoRev
endin


instr DelayPingPong
	ifb = .71                    ; feedback, entre 0 y 1
	asnd = gaDelay * ifb         ; audio de entrada
	adlt randomh 333, 1010, .5   ; tiempo en milisegundos del delay
	imaxdel = 5000
	itoRev = .3                  ; enviar al reverb

	adelL init 0
	adelR init 0
	afirstDel vdelay asnd, adlt, imaxdel                   ; primer delay -- hacia la derecha
	adelL vdelay asnd + (adelL * ifb), adlt * 2, imaxdel   ; delay izquierdo
	adelR vdelay asnd + (adelR * ifb), adlt * 2, imaxdel   ; delay derecho
	adeldelR vdelay adelR, adlt, imaxdel                   ; retraso el delay derecho para poder intercalar los dos delays

			aresL dcblock2 adelL
			aresR dcblock2 afirstDel + adeldelR
		outs aresL, aresR
	gaDelay = 0
	garevL += aresL * itoRev
	garevR += aresR * itoRev
endin


instr +Reverb
	aL, aR reverbsc garevL, garevR, 0.65, 12000, sr, 0.5, 1
		outs aL, aR
	clear garevL, garevR
endin

</CsInstruments>
<CsScore>

</CsScore>
</CsoundSynthesizer>

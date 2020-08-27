<CsoundSynthesizer>
<CsOptions>
-odac
</CsOptions>
<CsInstruments>
; este delay llama al generador del sonido
; De este modo se permite trabajar individualmente en cada delay
; incluso en el sonido directo.
; Esta es la version que me ofrece m�s independencia para cada delay

	sr = 44100
	ksmps = 16
	nchnls = 2
	0dbfs = 1

	garevL init 0    ; reverb
	garevR init 0

	alwayson "PlayNote"
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

	knmid rspline 55, 80, 2.043, 4.381

	kdlt rspline .1, 1.571, 1.96, 3.074
	kfb rspline .1, .98, 2.05, 7.2
	kfb = (kfb <= .98 ? kfb : .98)
	
	schedkwhen ktrig, 2, 0, "DelayPingPong", 0, 600, int(knmid), kdlt, kfb
endin 

; este delay no est� siempre prendido, lo hace cuando se apreta la barra espaciadora.
; Y el delay es el que llama al sonido generador
instr DelayPingPong
	idur = .8
	ifreq = p4
	idlt = p5

	ifb = p6
	kamp init ifb
	print idlt ; CHEQUEO TEMPORAL

	; Modificaci�n de altura en los delays
	kdfreq init (ifreq + 1)

	; Sonido directo ==============================
	schedule "Sound", 0, idur, 1, ifreq, .5
	; Primer Delay a la derecha ===================
	schedule "Sound", idlt, idur, kamp, kdfreq, 1
	; Delay Izquierdo =============================
	kdltl init (1 / (idlt * 2))
	kcpsl metro kdltl
	if kcpsl == 1 && kamp > .001 then
		kamp = ifb * kamp
		kdfreq += 1
		schedkwhen kcpsl, 0, 0, "Sound", idlt * 2, idur, kamp, kdfreq, 0
	endif
	; Delay Derecho ===============================
	kdltr init (1 / (idlt * 2))
	kcpst metro kdltr
	kcpsr delayk kcpst, idlt
	if kcpsr == 1 && kamp > .001 then
		kamp = ifb * kamp
		kdfreq += 1
		schedkwhen kcpsr, 0, 0, "Sound", idlt * 2, idur, kamp, kdfreq, 1
	endif
	
	; Cuando los delays son muy bajos en amplitud, apago el instrumento
	if kamp <= .001 then
		printks2 "se apaga\n", 1 ; CHEQUEO TEMPORAL
		turnoff
	endif
endin


instr Sound
	isdur = p3
	iamp = p4
	ifreq = cpsmidinn(p5)
	ipan = p6
	itoRev = .01

	; Generador ===================================
		kenv expseg .001, .1, 1, isdur - .2, .73, .1, .001
		kfreq = ifreq
		amod poscil 20, 5
	asig1 poscil iamp * kenv * amod * .02,  kfreq
	asig clip asig1, 0, .7
		
			aL = asig * (1 - ipan)
			aR = asig * ipan
		outs aL, aR

	garevL += aL * itoRev
	garevR += aR * itoRev
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

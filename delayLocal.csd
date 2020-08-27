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

; Desplaza la altura de la señal de entrada
opcode PitchShifter, a, ak
	ain, kdp xin
	fsig pvsanal ain, 1024, 256, 1024, 1
	ftps pvshift fsig, kdp, 0
	atps pvsynth ftps      
	xout atps
endop


instr PlayNote
	ktrig, k0 KeyAction 32             ; detecta la barra espaciadora.

	knmid rspline 40, 80, 2.043, 4.381

	kdlt rspline .5, 1.571, 1.96, 3.074
	kfb rspline .1, .99, 2.05, 7.2
	kfb = (kfb < 1 ? kfb : .995)
	
	if (ktrig == 1) then
		event "i", "Sound", 0, 40, .8, knmid, kdlt, kfb
	endif

endin 


instr Sound
	isdur = p4            ; esta es la duración del generador (pero no es la duración de todo el evento, que contiene los delays)
	ifreq = cpsmidinn(p5)
	idlt = p6
	ifb = p7
	itoRev = .1

	print idlt
	print ifb

	; Generador ===================================
		kenv expseg .001, .06, 1, isdur - .2, 1, .1, .001, 1, .001
		kfreq = ifreq
		amod poscil 20, 5
	asig1 poscil kenv * amod * .01,  kfreq
	asig clip asig1, 0, .7

	; Delays ======================================
	; de este modo puedo hacer manipulaciones a los delays individuales en cada instancia
	adelL init 0
	adelRtemp init 0
	afirstDel delay asig * ifb, idlt                     ; primer delay -- hacia la derecha
	adelL delay asig + (adelL * ifb), idlt * 2           ; delay izquierdo
	adelRtemp delay asig + (adelRtemp * ifb), idlt * 2
	adelR delay adelRtemp, idlt                          ; retraso el delay derecho para poder intercalar los dos delays

	; Pitch Shifter ===============================
	; desplazamiento de la altura en los delays
		kshift linseg ifreq, p3, ifreq + 1001
	afirst PitchShifter afirstDel, kshift
	aL PitchShifter adelL, kshift
	aR PitchShifter adelR, kshift

			kglbEnv expseg .001, .01, 1, p3 - .11, 1, .1, .001   ; aseguro que no hayan clips si el delay se sigue escuchando
			aresL = (asig + aL) * kglbEnv
			aresR = (asig + afirst + aR) * kglbEnv
		outs aresL, aresR

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
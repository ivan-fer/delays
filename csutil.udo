
; contiene varias utilidades sin categorizar aún.

;=====================================================================================================
; Escalador lineal. Autor: joachim heintz sept 2010
; ival - incoming value 
; iinim - minimum range of input value 
; iinmax - maximum range of input value 
; ioutmin - minimum range of output value 
; ioutmax - maximum range of output value

;scales the incoming value ival in the range between iinmin and iinmax 
; linear to the range between ioutmin and ioutmax
opcode Scalei, i, iiiii
	ival, iinmin, iinmax, ioutmin, ioutmax xin
	ires = (((ioutmax - ioutmin) / (iinmax - iinmin)) * (ival - iinmin)) + ioutmin
	xout ires
endop

;scales the incoming value kval in the range between kinmin and kinmax 
;linear to the range between koutmin and koutmax
opcode Scalek, k, kkkkk
	kval, kinmin, kinmax, koutmin, koutmax xin
	kres = (((koutmax - koutmin) / (kinmax - kinmin)) * (kval - kinmin)) + koutmin
	xout kres
endop
  
;scales the incoming value aval in the range between ainmin and ainmax 
;linear to the range between aoutmin and aoutmax
opcode Scalea, a, akkkk
	aval, kinmin, kinmax, koutmin, koutmax xin
	ares = (((koutmax - koutmin) / (kinmax - kinmin)) * (aval - kinmin)) + koutmin
	xout ares
endop
;=====================================================================================================
; detecta teclas
; joachim heintz 2010
;key - first output of a sensekey opcode 
;kd - second output of a sensekey opcode 
;kascii - ascii code of the key you want to check (for instance 32 for the space bar) 
;kdown - returns '1' in the k-cycle kascii has been pressed 
;kup - returns '1' in the k-cycle kascii has been released
opcode KeyOnce, kk, kkk
;returns '1' just in the k-cycle a certain key has been pressed (kdown) or released (kup)
	key, kd, kascii    xin ;sensekey output and ascii code of the key (e.g. 32 for space)
	knew      changed   key
	kdown     =         (key == kascii && knew == 1 && kd == 1 ? 1 : 0)
	kup       =         (key == kascii && knew == 1 && kd == 0 ? 1 : 0)
          xout      kdown, kup
endop

opcode KeyStay, k, kkk
;returns 1 as long as a certain key is pressed. make sure that automatic key repeats are disabled on your computer
	key, kd, kascii    xin ;sensekey output and ascii code of the key (e.g. 32 for space)
	kprev     init      0 ;previous key value
	kout      =         (key == kascii || (key == -1 && kprev == kascii) ? 1 : 0)
	kprev     =         (key > 0 ? key : kprev)
	kprev     =         (kprev == key && kd == 0 ? 0 : kprev)
          xout      kout
endop
;=====================================================================================================























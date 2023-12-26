.segment "INTHDR"

.asciiz "BOILERPLATE-SNES    " 	; 21 characters
.byte %00110000 		; FastROM
.byte %00000010			; ROM / SRAM / Battery
.byte $14			; ROM size (32k x 128 banks, log2)
.byte $05			; RAM size (32k x 1 bank, log2)
.byte $01			; Region (North America)
.byte $ff			; Developer ID
.byte $01			; Version number

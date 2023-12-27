; Place a 16 byte header on each ROM bank to ensure they are created and in the correct location
.segment "BANK80"
	.byte $80, $01, $02, $03, $04, $05, $06, $07, $08, $09, $0a, $0b, $0c, $0d, $0e, $0f
.segment "BANK81"
	.byte $81, $01, $02, $03, $04, $05, $06, $07, $08, $09, $0a, $0b, $0c, $0d, $0e, $0f

.segment "INTHDR"
	.asciiz "BOILERPLATE-SNES    " 	; 21 characters
	.byte %00110000 		; FastROM
	.byte %00000010			; ROM / SRAM / Battery
	.byte $16			; ROM size (32k x 128 banks, log2)
	.byte $0f			; RAM size (32k x 1 bank, log2)
	.byte $01			; Region (North America)
	.byte $ff			; Developer ID
	.byte $01			; Version number

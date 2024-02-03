.include "intro.inc"
.include "registers.inc"

.segment "INTRO"

INTRO:
	LDA #$01
	STA BGMODE	; Set Mode 1 PPU, standard BG3 priority, 8x8 character size

	LDA #$00
	STA BG12NBA	; Set BG1/2 tiles to $0000

	LDA #$30
	STA BG1SC	; One 32x32 BG1 tilemap, starting at $3000

	LDA #$34
	STA BG2SC	; One 32x32 BG2 tilemap, starting at $3400

	LDA #$04
	STA BG34NBA	; Set BG3/4 tiles to $4000 (there is no BG4 in Mode 1)

	LDA #$38
	STA BG3SC	; One 32x32 BG3 tilemap, starting at $3800

	LDA #$03
	STA OBJSEL	; Set SPR1/2 tiles to $6000/7000, 8x8 and 16x16 sprites

	JMP INTRO	; TODO

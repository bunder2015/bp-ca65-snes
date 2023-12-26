.p816
.include "registers.inc"

.segment "VECCODE"
; 65816 native vector code
COPN:
	; We don't use this vector because there is no co-processor
	RTI

BRKN:
	; TODO
	RTI

ABORTN:
	; This is unused on the SNES, but we can jump to the reset vector
	JMP RESETE

NMIN:
	; TODO
	RTI

RESETN:
	; This shouldn't happen in 16-bit native mode, but we can jump to the 8-bit reset vector
	JMP RESETE

IRQN:
	; TODO
	RTI

; 6502 emulation vector code
COPE:
	; We don't use this vector because we switch to native mode on startup
	RTI

BRKE:
	; This shouldn't happen in 8-bit emulation mode, but we can jump to the IRQ vector
	JMP IRQE

ABORTE:
	; This is unused on the SNES, but we can jump to the reset vector
	JMP RESETE

NMIE:
	; We don't use this vector because we switch to native mode on startup
	RTI

RESETE:
	SEI		; Disable interrupts
	STZ HDMAEN	; Disable horizontal DMA
	STZ MDMAEN	; Disable DMA
	STZ APUIO0	; Disable APU
	STZ APUIO1
	STZ APUIO2
	STZ APUIO3
	LDA #$80
	STA INIDISP	; Disable display

	CLC		; Clear carry bit
	XCE		; Use carry bit to switch from 6502 emulation mode to 65816 native mode
	REP #$38	; Disable decimal mode, set accumulator to 16-bit, set index registers to 16-bit

	LDA #$0000
	TCD		; Reset direct-page register

	LDA #$01ff
	TCS		; Reset stack pointer register

	; TODO - clear memory and all those other useful things

IRQE:
	; We don't use this vector because we switch to native mode on startup
	RTI

.segment "VECTORSN"
.addr COPN
.addr BRKN
.addr ABORTN
.addr NMIN
.addr RESETN
.addr IRQN

.segment "VECTORSE"
.addr COPE
.addr BRKE
.addr ABORTE
.addr NMIE
.addr RESETE
.addr IRQE

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
	SEI		; Disable interrupts
	PHP		; Push processor flags to stack
	REP #$30	; Set accumulator and index registers to 16-bit
	PHA
	PHX
	PHY		; Push AXY to stack

	PHB		; Push data bank to stack
	PHK		; Push program bank to stack
	PLB		; Pull new data bank from stack

	LDA RDNMI	; Acknowledge NMI

	; TODO

	REP #$30	; Set accumulator and index registers to 16-bit
	PLB		; Pull data bank from stack
	PLY
	PLX
	PLA		; Pull AXY from stack
	PLP		; Pull processor flags from stack

	RTI		; Return to code

RESETN:
	; This shouldn't happen in 16-bit native mode, but we can jump to the 8-bit reset vector
	JMP RESETE

IRQN:
	SEI		; Disable interrupts
	PHP		; Push processor flags to stack
	REP #$30	; Set accumulator and index registers to 16-bit
	PHA
	PHX
	PHY		; Push AXY to stack

	PHB		; Push data bank to stack
	PHK		; Push program bank to stack
	PLB		; Pull new data bank from stack

	LDA TIMEUP	; Acknowledge IRQ

	; TODO

	REP #$30	; Set accumulator and index registers to 16-bit
	PLB		; Pull data bank from stack
	PLY
	PLX
	PLA		; Pull AXY from stack
	PLP		; Pull processor flags from stack

	RTI		; Return to code

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
	SEI		; Disable IRQ
	CLC		; Clear carry bit
	XCE		; Use carry bit to switch from 6502 emulation mode to 65816 native mode
	REP #$FF
	SEP #$24	; Disable decimal mode, set accumulator to 8-bit, set index registers to 16-bit
	STZ NMITIMEN	; Disable NMI, timer IRQ, auto joypad read
	STZ HDMAEN	; Disable horizontal DMA
	STZ MDMAEN	; Disable DMA
	STZ APUIO0
	STZ APUIO1
	STZ APUIO2
	STZ APUIO3	; Clear APU IO ports
	LDA #$80
	STA INIDISP	; Disable rendering (enable F-blank)

	LDA #$01
	STA MEMSEL	; Enable FastROM speed
	JML @L_RESETE	; Perform a long-jump to use FastROM bank
@L_RESETE:
	REP #$20	; Set accumulator to 16-bit
	LDA #$0000
	TCD		; Set direct-page (aka zero-page) register
	LDA #$01FF
	TCS		; Set stack pointer register
	SEP #$20	; Set accumulator back to 8-bit

	STZ WMADDL
	STZ WMADDM
	STZ WMADDH	; Set WRAM destination address for DMA transfer ($000000 means 7E0000)

	LDA #$08
	STA DMAP0	; Fixed address source

	LDA #WMDATA & $FF
	STA BBAD0	; B-bus address

	LDA #.BANKBYTE(@RESET_BYTE)
	STA A1B0
	LDX #.LOWORD(@RESET_BYTE)
	STX A1T0L	; Set source address to the 24-bit address of RESET_BYTE

	STZ DAS0L
	STZ DAS0H	; Transfer size = 64k

	LDA #$01
	STA MDMAEN	; Copy 64k to $7E0000-$7EFFFF

	LDA #$01
	STA WMADDH	; Change WMADDH for the next 64k ($010000 means $7F0000)

	LDA #$01
	STA MDMAEN	; Copy 64k to $7F0000-$7FFFFF

@TODO:
	; TODO - clear PPU memory and all those other useful things
	JMP @TODO

@RESET_BYTE:
	.BYTE $00

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

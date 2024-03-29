.include "registers.inc"
.include "intro.inc"

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
	PHP		; Push processor flags to stack
	PHA
	PHX
	PHY		; Push AXY to stack
	PHB		; Push data bank to stack
	PHK		; Push program bank to stack
	PLB		; Pull new data bank from stack
	REP #$FF
	SEP #$24	; Disable decimal mode, set accumulator to 8-bit, set index registers to 16-bit


	LDA RDNMI	; Acknowledge NMI

	; TODO

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
	PHP		; Push processor flags to stack
	PHA
	PHX
	PHY		; Push AXY to stack
	PHB		; Push data bank to stack
	PHK		; Push program bank to stack
	PLB		; Pull new data bank from stack
	REP #$FF
	SEP #$24	; Disable decimal mode, set accumulator to 8-bit, set index registers to 16-bit

	LDA TIMEUP	; Acknowledge IRQ

	; TODO

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
	STA BBAD0	; B-bus address $2180

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

	STZ CGADD	; Set CGRAM destination address for DMA transfer

	LDA #$0A
	STA DMAP0	; Fixed address source, write destination address twice before incrementing

	LDA #CGDATA & $FF
	STA BBAD0	; B-bus address $2122

	LDA #.BANKBYTE(@RESET_BYTE)
	STA A1B0
	LDX #.LOWORD(@RESET_BYTE)
	STX A1T0L	; Set source address to the 24-bit address of RESET_BYTE

	STZ DAS0L
	LDA #$02
	STA DAS0H	; Transfer size = 512b

	LDA #$01
	STA MDMAEN	; Copy 512b to CGRAM

	STZ OAMADDL
	STZ OAMADDH	; Set OAM destination address for DMA transfer

	LDA #$0A
	STA DMAP0	; Fixed address source, write destination address twice before incrementing

	LDA #OAMDATA & $FF
	STA BBAD0	; B-bus address $2104

	LDA #.BANKBYTE(@RESET_BYTE)
	STA A1B0
	LDX #.LOWORD(@RESET_BYTE)
	STX A1T0L	; Set source address to the 24-bit address of RESET_BYTE

	STZ DAS0L
	LDA #$02
	STA DAS0H	; Transfer size = 512b

	LDA #$01
	STA MDMAEN	; Copy 512b to OAM

	LDA #$01
	STA OAMADDH	; Switch to last 32 bytes of OAM

	LDA #$08
	STA DMAP0	; Fixed address, write once

	LDA #$20
	STA DAS0L
	STZ DAS0H	; Transfer size = 32b

	LDA #$01
	STA MDMAEN	; Copy 32b to OAM

	STZ VMADDL
	STZ VMADDH	; Set VRAM destination address for DMA transfer

	LDA #$80
	STA VMAIN	; Set VRAM to increment after every word written

	LDA #$09
	STA DMAP0	; Fixed address source, write whole word before incrementing

	LDA #VMDATAL & $FF
	STA BBAD0	; B-bus address $2119

	LDA #.BANKBYTE(@RESET_BYTE)
	STA A1B0
	LDX #.LOWORD(@RESET_BYTE)
	STX A1T0L	; Set source address to the 24-bit address of RESET_BYTE

	STZ DAS0L
	STZ DAS0H	; Transfer size = 64k

	LDA #$01
	STA MDMAEN	; Copy 64k to VRAM

	JML INTRO	; Jump to intro code

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

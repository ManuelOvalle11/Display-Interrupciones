//*****************************************************************************
// Universidad del Valle de Guatemala
// IE2023: Programación de microcontroladores
// Autor: Manuel Ovalle 
// Proyecto: Interrupciones 
// Hardware: ATMEGA328P
// Creado: 30/01/2024
//*****************************************************************************
// Encabezado
//*****************************************************************************

.include "M328PDEF.inc"
.cseg //Indica inicio del código
.org 0x00 //Indica el RESET
	JMP Main
.org 0x0008 // Vector de ISR : PCINT1
	JMP ISR_PCINT1
.org 0x0020
	JMP ISR_TIMER_OVF0
Main:
//*****************************************************************************
// Formato Base
//*****************************************************************************
LDI R16, LOW(RAMEND) 
OUT SPL, R16
LDI R17, HIGH(RAMEND)
OUT SPH, R17
//*****************************************************************************
// MCU
//*****************************************************************************
Setup:
	LDI R16, (1 << CLKPCE)
	STS CLKPR, R16 // Habilitamos el prescalar
	LDI R16, 0b0000_0001
	STS CLKPR, R16 // Frecuencia 4MGHz

	LDI R16, 0b0000_0101
	OUT PORTC, R16

	LDI R16, 0b0001_0000
	OUT DDRC, R16	// Entradas y salidas PORTC 

	LDI R16, 0b1111_1111 
	OUT DDRD, R16	// Entradas y salidas PORTD 

	LDI R16, 0b0010_1111
	OUT DDRB, R16	// Entradas y salidas PORTB 


	LDI R16, (1 << PCIE1)
	STS PCICR, R16 //Configurar PCIE1

	LDI R16, (1 << PCINT8) | (1 << PCINT10)
	STS PCMSK1, R16 //Habilitar

	LDI R16, (1 << TOIE0)
	STS TIMSK0, R16 

CALL Timer_0		//Timer

	SEI //  Interruciones globales 


	//					0		1	2		3	4		5	6		7	8	9		A	B		C	D		E	F	
	Tabla_Display: .DB 0x3F, 0x30, 0x5B, 0x4F, 0x66, 0x6D, 0x7D, 0x7, 0x7F, 0x6F, 0x77, 0x7C, 0x39, 0x5E, 0x79, 0x71
	LDI ZH, HIGH(Tabla_Display << 1)
	LDI ZL, LOW(Tabla_Display << 1)
	LPM R19, Z
	MOV R24, ZL		//Decenas 
	MOV R25, ZL		//Unidades

	SBI PORTC, PC1	//Permite leer Unidades
	SBI PORTC, PC3	//Permite leer Decenas

	SBRS R19, 0
	CBI	PORTD, PD2
	SBRC R19, 0
	SBI PORTD, PD2
	SBRS R19, 1
	CBI	PORTD, PD3
	SBRC R19, 1
	SBI PORTD, PD3
	SBRS R19, 2
	CBI	PORTD, PD4
	SBRC R19, 2
	SBI PORTD, PD4
	SBRS R19, 3
	CBI	PORTD, PD5
	SBRC R19, 3
	SBI PORTD, PD5
	SBRS R19, 4
	CBI	PORTD, PD6
	SBRC R19, 4
	SBI PORTD, PD6
	SBRS R19, 5
	CBI	PORTD, PD7
	SBRC R19, 5
	SBI PORTD, PD7
	SBRS R19, 6
	CBI	PORTC, PC4
	SBRC R19, 6
	SBI PORTC, PC4

	// Limpieza general de registros a utilizar
	CLR R17
	CLR R18
	CLR R19
	CLR R21
	CLR R22
	CLR R23
	CLR R26
	CLR R27

	// Registro para utilizar XOR 
	LDI R23, 0b1111_1111

Loop:

	RJMP Loop

//*****************************************************************************
// SubRutinas
//*****************************************************************************
Timer_0:
	OUT TCCR0A, R16 //Modo normal

	LDI R16, (1 << CS02) 
	OUT TCCR0B, R16

	LDI R16, 178
	OUT TCNT0, R16
	RET

//*****************************************************************************

reset:
	CLR R17
	RJMP leds

//*****************************************************************************

Incrementar: //Incrementa el contador binario
	INC R17
	CPI R17, 0x10
	BREQ unload
	RJMP leds
unload:		//Limite superior
	CLR R17
	RJMP leds

//*****************************************************************************

Decrementar: //Decrementa el contador binario
	DEC R17
	CPI R17, 0xFF
	BREQ load
	RJMP leds
load:		// Limite inferior 
	LDI R17, 0x0F
	RJMP leds

//*****************************************************************************

leds: //LEDS 
	SBRS R17, 0
	CBI	PORTB, PB0
	SBRC R17, 0
	SBI PORTB, PB0
	SBRS R17, 1
	CBI	PORTB, PB1
	SBRC R17, 1
	SBI PORTB, PB1
	SBRS R17, 2
	CBI	PORTB, PB2
	SBRC R17, 2
	SBI PORTB, PB2
	SBRS R17, 3
	CBI	PORTB, PB3
	SBRC R17, 3
	SBI PORTB, PB3
	RET

//*****************************************************************************

//Interrupcion botones leds 

ISR_PCINT1:
	IN R18, PINC

	SBRS R18, PC0	//botón 2
	CALL Incrementar

	SBRS R18, PC2	//botón 1
	CALL Decrementar
	RETI

//*****************************************************************************

Display:	// Display de 7 segmentos 

	SBRS R19, 0
	CBI	PORTD, PD2
	SBRC R19, 0
	SBI PORTD, PD2
	SBRS R19, 1
	CBI	PORTD, PD3
	SBRC R19, 1
	SBI PORTD, PD3
	SBRS R19, 2
	CBI	PORTD, PD4
	SBRC R19, 2
	SBI PORTD, PD4
	SBRS R19, 3
	CBI	PORTD, PD5
	SBRC R19, 3
	SBI PORTD, PD5
	SBRS R19, 4
	CBI	PORTD, PD6
	SBRC R19, 4
	SBI PORTD, PD6
	SBRS R19, 5
	CBI	PORTD, PD7
	SBRC R19, 5
	SBI PORTD, PD7
	SBRS R19, 6
	CBI	PORTC, PC4
	SBRC R19, 6
	SBI PORTC, PC4

	RET

//*****************************************************************************
//Interrupcion para incrementar el display
ISR_TIMER_OVF0:

LDI R16, 178
OUT TCNT0, R16
Call Display_count
RETI

//*****************************************************************************
Display_count: //Revisa que debe de aumentar 
	SBIS PORTC, PC3
	RJMP Decenas
	RJMP Unidades


Unidades:	//Setup para unidades 
	CBI PORTC, PC3
	SBI PORTC, PC1
	MOV ZL, R25
	LPM R19, Z
	RJMP Incrementar_Unidades

Incrementar_Unidades:	//Delay unidades
	CPI R22, 60
	BREQ Incremento_Unidades
	INC R22
	RJMP Display

Incremento_Unidades:	//Incremento de unidades 
	CLR R22

	INC R25
	MOV ZL, R25
	LPM R19, Z
	CPI R19, 0x77
	BREQ Reset_Unidades
	RJMP Display

	Reset_Unidades: //Limite de 9 a 0
	LDI R25, LOW(Tabla_Display << 1)
	MOV ZL, R25
	LPM R19, Z
	INC R26
	RJMP Display
//*****************************************************************************
Decenas:	//Setup para decenas 
	SBI PORTC, PC3
	CBI PORTC, PC1
	MOV ZL, R24
	LPM R19, Z
	EOR R19, R23	//XOR para display catodo
	RJMP Incrementar_Decenas

Incrementar_Decenas:
	CPI R26, 1	//Revisa Z
	BREQ Incremento_Decenas
	RJMP Display

Incremento_Decenas:	//Incrementa decenas 
	CLR R26
	INC R24
	MOV ZL, R24
	LPM R19, Z
	CPI R19, 0x77
	BREQ Reset_Decenas
	EOR R19, R23
	RJMP Display

Reset_Decenas: //Limite de 9 a 0
	LDI R24, LOW(Tabla_Display << 1)
	MOV ZL, R24
	LPM R19, Z
	EOR R19, R23
	RJMP Display
//*****************************************************************************
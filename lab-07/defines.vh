/* verilator lint_off UNUSED */
/* verilator lint_off UNDRIVEN */
/* verilator lint_off UNOPTFLAT */
/* In order to disable implicit declaration of wires */
`ifndef DEFINES

`define DEFINES

`default_nettype none

/* SREG flags */
`define FLAGS_C 3'd0
`define FLAGS_Z 3'd1
`define FLAGS_N 3'd2
`define FLAGS_V 3'd3
`define FLAGS_S 3'd4
`define FLAGS_H 3'd5
`define FLAGS_T 3'd6
`define FLAGS_I 3'd7

/* Indirect registers */
`define XL 5'd26
`define XH 5'd27
`define YL 5'd28
`define YH 5'd29
`define ZL 5'd30
`define ZH 5'd31

/* IO addresses */
`define SREG 6'h3F
`define SPH 6'h3E
`define SPL 6'h3D
`define TIMSK 6'h26
`define TIFR 6'h25
`define TCCR0A 6'h19
`define TCCR0B 6'h18
`define TCNT0 6'h17
`define OCR0A 6'h16
`define OCR0B 6'h15
`define PUEB 6'h07
`define PORTB 6'h06
`define DDRB 6'h05
`define PINB 6'h04
`define PUEA 6'h03
`define PORTA 6'h02
`define DDRA 6'h01
`define PINA 6'h00

/* Interrupt flags */
`define OCF0B 3'd2
`define OCF0A 3'd1
`define TOV0 3'd0

/* Timer modes */
`define INVALID      6'd0
`define NORMAL       6'd1
`define CTC          6'd2
`define FAST_PWM_MAX 6'd3
`define FAST_PWM_OCR 6'd4

/* Interrupt vectors for ISRs */
`define TIM0_COMPA_ISR 10'h09
`define TIM0_COMPB_ISR 10'h0A
`define TIM0_OVF_ISR 10'h0B

/* States for FSM */
`define STATE_IF 1
`define STATE_ID 2
`define STATE_EX 3
`define STATE_MEM 4
`define STATE_WB 5
`define STATE_RESET 0
`define STATE_COUNT 6

/* Opcode types deduced by decoder */
`define TYPE_NOP 0
`define TYPE_UNKNOWN 1
`define TYPE_LD_X 2
`define TYPE_LD_X_POSTINC 3
`define TYPE_LD_X_PREDEC 4
`define TYPE_LD_Y 5
`define TYPE_LD_Y_POSTINC 6
`define TYPE_LD_Y_PREDEC 7
`define TYPE_LD_Z 8
`define TYPE_LD_Z_POSTINC 9
`define TYPE_LD_Z_PREDEC 10
`define TYPE_LDS 11
`define TYPE_ST_X 12
`define TYPE_ST_X_POSTINC 13
`define TYPE_ST_X_PREDEC 14
`define TYPE_ST_Y 15
`define TYPE_ST_Y_POSTINC 16
`define TYPE_ST_Y_PREDEC 17
`define TYPE_ST_Z 18
`define TYPE_ST_Z_POSTINC 19
`define TYPE_ST_Z_PREDEC 20
`define TYPE_STS 21
`define TYPE_LDI 22
`define TYPE_MOV 23
`define TYPE_BRBS 24
`define TYPE_BRBC 25
`define TYPE_RJMP 26
`define TYPE_RCALL 27
`define TYPE_RET 28
`define TYPE_POP 29
`define TYPE_PUSH 30
`define TYPE_IN 31
`define TYPE_OUT 32
`define TYPE_SBI 33
`define TYPE_CBI 34
`define TYPE_INC 35
`define TYPE_DEC 36
`define TYPE_ADD 37
`define TYPE_ADC 38
`define TYPE_SUB 39
`define TYPE_SUBI 40
`define TYPE_SBC 41
`define TYPE_SBCI 42
`define TYPE_CP 43
`define TYPE_CPI 44
`define TYPE_NEG 45
`define TYPE_AND 46
`define TYPE_ANDI 47
`define TYPE_OR 48
`define TYPE_ORI 49
`define TYPE_EOR 50
`define TYPE_WDR 51
`define TYPE_SEI 52
`define TYPE_CLI 53
`define TYPE_CALL_ISR 54
`define TYPE_RETI 55
`define OPCODE_COUNT 6

/* Opcode groups */
`define GROUP_ALU 0
`define GROUP_ALU_ONE_OP 1
`define GROUP_ALU_TWO_OP 2
`define GROUP_ALU_AUX 3
`define GROUP_ALU_IMD 4
`define GROUP_REGISTER 5
`define GROUP_LOAD_INDIRECT 6
`define GROUP_LOAD_DIRECT 7
`define GROUP_LOAD 8
`define GROUP_STORE_INDIRECT 9
`define GROUP_STORE_DIRECT 10
`define GROUP_STORE 11
`define GROUP_STACK 12
`define GROUP_MEMORY 13
`define GROUP_CONTROL_FLOW 14
`define GROUP_IO_READ 15
`define GROUP_IO_WRITE 16
`define GROUP_TWO_CYCLE_MEM 17
`define GROUP_TWO_CYCLE_WB 18
`define GROUP_TWO_CYCLE_ID 19
//`define GROUP_TWO_CYCLE_EX 20
//`define GROUP_TWO_CYCLE_IF 21
`define GROUP_COUNT 20

/* Operations permitted by ALU */
`define OPSEL_NONE 0
`define OPSEL_ADD 1
`define OPSEL_ADC 2
`define OPSEL_SUB 3
`define OPSEL_AND 4
`define OPSEL_XOR 5
`define OPSEL_OR 6
`define OPSEL_NEG 7
`define OPSEL_COUNT 3

/* Control signals */
`define CONTROL_MEM_READ 0
`define CONTROL_MEM_WRITE 1
`define CONTROL_REG_RR_READ 2
`define CONTROL_REG_RR_WRITE 3
`define CONTROL_REG_RD_READ 4
`define CONTROL_REG_RD_WRITE 5
`define CONTROL_IO_READ 6
`define CONTROL_IO_WRITE 7
`define CONTROL_PREINC 8
`define CONTROL_POSTDEC 9
`define SIGNAL_COUNT 10

`endif

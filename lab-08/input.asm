    TCCR0A      equ 0x19
    TCCR0B      equ 0x18
    TIMSK       equ 0x26
    DDRA        equ 0x01
    PORTA       equ 0x02
 
    rjmp        main            ; Adresa 0x0000
    reti                        ; Adresa 0x0001
    reti                        ; Adresa 0x0002
    reti                        ; Adresa 0x0003
    reti                        ; Adresa 0x0004
    reti                        ; Adresa 0x0005
    reti                        ; Adresa 0x0006
    reti                        ; Adresa 0x0007
    reti                        ; Adresa 0x0008
    reti                        ; Adresa 0x0009
    reti                        ; Adresa 0x000A
    rjmp        TIM0_OVF_ISR    ; Adresa 0x000B
    reti                        ; Adresa 0x000C
    reti                        ; Adresa 0x000D
    reti                        ; Adresa 0x000E
    reti                        ; Adresa 0x000F
    reti                        ; Adresa 0x0010
 
TIM0_OVF_ISR:
    ; ldi         R16, 2
    ; out         DDRA, R16
    sbi           DDRA, 0
    sbi           PORTA, 0
    nop
    nop
    nop
    cbi           DDRA, 0
    cbi           PORTA, 0

    reti
 
main:
    ; Pornim Timer/Counter0.
    ldi         R16, 0b00000000 ; COM0A = 0 (normal port operation, OC0A disconnected)
                                ; COM0B = 0 (normal port operation, OC0B disconnected)
                                ; WGM0[1:0] = 0 (normal mode operation)
    out         TCCR0A, R16
 
    ldi         R16, 0b00000001 ; WGM0[2] = 0 (normal mode operation)
                                ; CS0 = 1 (clkT = clkIO/1, no prescaling)
    out         TCCR0B, R16
 
    ; Activăm întreruperea de overflow pentru Timer/Counter0.
    ldi         R16, 0b00000001 ; TOIE0 = 1 (Timer/Counter0 overflow interrupt enabled)
    out         TIMSK, R16
 
    ; Activăm întreruperile global.
    sei
 
    loop:
        rjmp loop
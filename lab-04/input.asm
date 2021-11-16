ldi r16, 5
ldi r17, 15
push r16
push r17
main_loop:
    mov r30, r16
    sub r30, r17
    brbs 1, done
    brbs 2, label2
label1:
    sub r16, r17 
    rjmp main_loop
label2:
    sub r17, r16
    rjmp main_loop
done:
    push r16
    pop r20
    pop r21
    pop r22
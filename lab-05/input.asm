0:ldi 	r16, 5
1:rjmp 	main_function
first_function:
2:ldi 	r17, 15
3:ret
main_function:
4:ldi 	r17, 10
5:rcall first_function
6:ldi 	r18, 20
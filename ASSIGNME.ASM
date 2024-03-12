; Create a calculator to add, subtract, multiply or divide two positive 16-bit numbers.
dosseg
.model small
.data
welcomeMSG db "Welcome to Assembly Calculator!$"
firstMSG db 10,13,"Enter the first number: $"
operationMSG db "Enter an arithmetic operator: $"
secondMSG db 10,13,"Enter the second number: $"
resultMSG db "The result is: $"
remainderMSG db 10,13,"The remainder is: $"
thxMSG db 10,13,"Thanks for using me:)$"
errorMSG db "**Error: Can't divide by zero!$"
error1MSG db 10,13,"**Error: Invalid number!$"
invalidOperatorMSG db "**Error: Invalid operator!$"
outOfRangeMSG db "**Error: Number is out of range!$"
.code

main:
mov ax,@data
mov ds,ax

mov ah,9
mov dx,offset welcomeMSG
int 21h

mov ah,9
mov dx,offset firstMSG
int 21h

mov bx,0  ;to store the first multi-digit number

; Read the first number:
loop1:
mov ah,1
int 21h

cmp al,13
jnz cont
jmp out1

cont:
; Check if it's a number (between 30h and 39h)
cmp al,30h
jb error1
cmp al,39h
ja error1

mov ah,0  ;so it won't affect 16-bit addition
mov si,ax ;to store the digit (in al)
sub si,30h

mov ax,bx
mov di,10
mov dx,0 ; it should be cleared befor mul/div operation (to store the result with ax)
mul di
cmp dx,0
jne outOfRange1
add ax,si
mov bx,ax

jmp loop1

out1:
; Read operation (+,-,* or /)
mov ah,9
mov dx,offset operationMSG
int 21h
mov ah,1
int 21h
mov bp,ax ;to store the operation (in al)

; Read second number:
mov ah,9
mov dx,offset secondMSG
int 21h

mov cx,0  ;to store the second multi-digit number

; To read the number:
loop2:
mov ah,1
int 21h

cmp al,13
jnz cont2
jmp out2

cont2:
; Check if it's a number (between 30h and 39h)
cmp al,30h
jb error1
cmp al,39h
ja error1

mov ah,0  ;so it won't affect 16-bit addition
mov si,ax ;to store the digit (in al)
sub si,30h

mov ax,cx
mov di,10
mov dx,0 ;it should be cleared befor mul/div operation (to store the result with ax)
mul di
cmp dx,0
je ad
outOfRange1:
jmp outOfRange2
ad:
add ax,si
mov cx,ax  

jmp loop2

;;;;;;;;;;;;;
jmp out2
; go to "invalid number" error (fix relative jump out of range)
error1:
jmp error2
;;;;;;;;;;;;;

out2:
; Calculate the result:
; Addition
mov ax,bp  ;the operation is in al
cmp al,'+'
jne subtraction
mov dx,0 ;use it to store carry
add bx,cx 
adc dx,0 ;to store the carry
cmp dx,0
je cont3
outOfRange2:
jmp outOfRange 

subtraction:
mov ax,bp  ;the operation is in al
cmp al,'-'
jne multiplication
cmp bx,cx
jb negative ;if the result is negative
sub bx,cx   ;if not
jmp cont3

negative:
sub cx,bx
mov bx,cx
mov cl,'-' ;flag to indicate the result is negative
jmp cont3

multiplication:
mov ax,bp  ;the operation is in al
cmp al,'*'
jne division
mov ax,bx
mov dx,0
mul cx 
cmp dx,0
jne outOfRange
mov bx,ax
jmp cont3

division:
mov ax,bp  ;the operation is in al
cmp al,'/'
jne invalidOperator
mov ax,bx
cmp cx,0  ;handle division by zero
je error
mov dx,0
div cx
mov bx,ax
mov bp,dx  ;to store the remainder in division
mov cl,'/' ;flag to indicate a division operation

; Show the result
cont3:
mov ah,9
mov dx,offset resultMSG
int 21h

; Push the result to stack:
mov ch,0  ;a counter to store the number of digits
loop3:
mov dx,0 ;to store the digit/remainder
mov ax,bx
mov si,10
div si
mov bx,ax
push dx  ;we're only interested in dl (the remainder/digit)
inc ch   ;increase the counter
cmp ax,0
jnz loop3

; Check if the result is negative
cmp cl,'-'
jne loop4
mov ah,2
mov dl,'-'
int 21h

;;;;;;;;;;;;;;
jmp loop4
outOfRange:
mov ah,9
mov dx,offset outOfRangeMSG
int 21h
jmp exit

; go to "invalid number" error (fix relative jump out of range)
error2:
jmp error3

; "division by zero" error and go to exit (fix relative jump out of range)
error:
mov ah,9
mov dx,offset errorMSG
int 21h
jmp exit

invalidOperator:
mov ah,9
mov dx,offset invalidOperatorMSG
int 21h
jmp exit

;;;;;;;;;;;;;;

; Pop the result from stack:
loop4:
pop ax   ;our digit is in al
mov ah,2
mov dl,al
add dl,30h
int 21h
dec ch
cmp ch,0
jnz loop4

; Show the remainder of division if exists:
cmp cl,'/'
jne exit
mov bx,bp ;move the remainder to bx
mov ah,9
mov dx,offset remainderMSG
int 21h

; Push the remainder to stack:
mov ch,0  ;a counter to store the number of digits
loop5:
mov dx,0 ;to store the digit/remainder
mov ax,bx
mov si,10
div si
mov bx,ax
push dx  ;we're only interested in dl (the remainder/digit)
inc ch   ;increase the counter
cmp ax,0
jnz loop5

; Pop the remainder from stack:
loop6:
pop ax   ;our digit is in al
mov ah,2
mov dl,al
add dl,30h
int 21h
dec ch
cmp ch,0
jnz loop6
jmp exit

error3:
mov ah,9
mov dx,offset error1MSG
int 21h

exit:
mov ah,9
mov dx,offset thxMSG
int 21h

mov ah,4ch
int 21h
end main
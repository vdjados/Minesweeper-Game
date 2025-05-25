include 'console_lib.asm'

section '.bss' writable
    prompt1 db 'Введите ширину поля: ', 0
    prompt2 db 'Введите высоту поля: ', 0
    msg rb 255
    width_str rb 255
    height_str rb 255
    mock_str db "I am here!", 0

set_configuration:
    mov rsi, prompt1
    call print_str
   
    mov rax, 0
    mov rdi, 0
    mov rsi, width_str
    mov rdx, 255
    syscall

   xor rdx, rdx
   xor rax, rax
.loop:
   mov al, [width_str+rdx]
   cmp rax, 0
   je .next
   inc rdx
   jmp .loop
.next:
   mov rsi, width_str
   call str_number
   mov [width], al
   
    ; Здесь заканчивается обработка ширины и начинается высота

   mov rsi, prompt2
   call print_str

    mov rax, 0
    mov rdi, 0
    mov rsi, height_str
    mov rdx, 255
    syscall

    xor rdx, rdx
    xor rax, rax
.loop1:
   mov al, [height_str+rdx]
   cmp rax, 0
   je .next1
   inc rdx
   jmp .loop1
.next1:
   mov rsi, height_str

   call str_number
   mov [height], al

ret
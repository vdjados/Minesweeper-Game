format ELF64
public _start
include 'configure.asm'
include 'drawer.asm'
include 'field_generator.asm'
include 'field_processor.asm'

section '.data' writable
    field_symbol db '#'
    bomb_symbol db '*'
    flag_symbol db '^'
    wrong_flag_symbol db '@'
    win_msg db "Поздравляем! Вы выиграли!", 0
    loose_msg db "Вы проиграли. Попробуйте ещё раз!", 0
section '.bss' writable
    width db 9
    height db 4
    game_field rb 10000;
    cursor_pos_x db 1
    cursor_pos_y db 1
section '.text' executable
_start:
    call set_configuration
    call generate_field
    

    jmp .start_game

	.exit:
    
    call exit

.start_game:

    mov [cursor_pos_x], 1
    mov [cursor_pos_y], 1


    call initscr
    call noecho
    call cbreak
    
    .loop:
        jmp .check_win
        .not_win:

        ; Отрисовка поля
        call draw_field
        
        ; Обновляем экран
        call refresh
        
        ; Ждём нажатия клавиши
        call getch
        
        ; В rax теперь код нажатой клавиши
        cmp rax, 'q'    ; Сравниваем с 'q' (ASCII код)
        je .end_game        ; Если q - выходим
        
        ; Тут можно обработать другие клавиши
        cmp rax, 'w'
        je .move_up

        cmp rax, 's'
        je .move_down
        
        cmp rax, 'a'
        je .move_left
        
        cmp rax, 'd'
        je .move_right

        cmp rax, 'e'
        je .open_cell

        cmp rax, 'r'
        je .set_flag
        
        jmp .loop       ; Если не q - продолжаем цикл

    .move_up:
        cmp [cursor_pos_y], 0
        je .loop

        dec [cursor_pos_y]
        jmp .loop

    .move_down:
        xor r9, r9
        mov r9b, [height]
        dec r9b
        cmp r9b, [cursor_pos_y]
        je .loop

        inc [cursor_pos_y]
        jmp .loop

    .move_left:
        cmp [cursor_pos_x], 0
        je .loop

        dec [cursor_pos_x]
        jmp .loop

    .move_right:
        xor r9, r9
        mov r9b, [width]
        dec r9b
        cmp r9b, [cursor_pos_x]
        je .loop

        inc [cursor_pos_x]
        jmp .loop
    
    .open_cell:
        push r8
        push rax
        push rdi
        push rdx
        xor rax, rax
        mov al, [cursor_pos_y]
        
        ; Вычисляем позицию в одномерном массиве: position = y * width + x
        movzx r8, byte [width]   ; r8 = width (расширяем до 64 бит без знака)
        mul r8                   ; rax = y * width
        xor rdx, rdx
        mov dl, [cursor_pos_x]
        add rax, rdx            ; rax = y * width + x
        
        ; Теперь в rax индекс в массиве game_field
        ; Проверяем, является ли ячейка закрытой (#)
        mov r9b, byte [game_field + rax]

        cmp r9b, [field_symbol]
        je .show_number               ; если не #, пропускаем
        
        cmp r9b, [bomb_symbol]
        je .opened_bomb

        jmp .not_open

        .opened_bomb:
            pop rdx
            pop rdi
            pop rax
            pop r8
            jmp .end_game

        .show_number:
            ; Если ячейка закрыта, заменяем её на временное значение (например, '0')
            ; Позже здесь будет вызов функции подсчёта бомб
            xor r8, r8
            call count_bombs
            add r8, '0'
            mov byte [game_field + rax], r8b
        .not_open:
        pop rdx
        pop rdi
        pop rax
        pop r8

        jmp .loop

    .set_flag:
        

        push r8
        push rax
        push rdi
        push rdx
        xor rax, rax
        mov al, [cursor_pos_y]
        
        ; Вычисляем позицию в одномерном массиве: position = y * width + x
        movzx r8, byte [width]   ; r8 = width (расширяем до 64 бит без знака)
        mul r8                   ; rax = y * width
        xor rdx, rdx
        mov dl, [cursor_pos_x]
        add rax, rdx            ; rax = y * width + x
        
        mov r9b, byte [game_field + rax]

        cmp r9b, [bomb_symbol]
        je .set_flag_to_bomb       

        cmp r9b, [field_symbol]
        je .set_wrong_flag 

        cmp r9b, [flag_symbol]
        je .delete_flag_symbol 

        cmp r9b, [wrong_flag_symbol]
        je .delete_wrong_flag_symbol


        jmp .skip_flag

        .set_flag_to_bomb:
            ; Если ячейка закрыта, заменяем её на временное значение (например, '0')
            ; Позже здесь будет вызов функции подсчёта бомб
            mov r8b, [flag_symbol]
            mov byte [game_field + rax], r8b
            jmp .skip_flag

        .set_wrong_flag:
            mov r8b, [wrong_flag_symbol]
            mov byte [game_field + rax], r8b
            jmp .skip_flag

        .delete_flag_symbol:
            mov r8b, [bomb_symbol]
            mov byte [game_field + rax], r8b
            jmp .skip_flag

        .delete_wrong_flag_symbol:
            mov r8b, [field_symbol]
            mov byte [game_field + rax], r8b
            jmp .skip_flag
        .skip_flag:
        
        pop rdx
        pop rdi
        pop rax
        pop r8



        jmp .loop

    .end_game:
    
    ; Завершение работы
    call endwin
    mov rsi, loose_msg
    call print_str
    call new_line
    jmp .exit

.check_win:
    push rax
    push rdx
    push rbx
    push r8
    push r9
    xor rbx, rbx
    xor r9, r9
    .loop_win_1:
        cmp bl, [height]
        je .next1
        xor rdx, rdx
        .loop_win_2:

            cmp dl, [width]
            je .next
            

            xor r8, r8
            mov r8b, [game_field + r9]
            cmp [wrong_flag_symbol], r8b
            je .continue_without_win

            cmp [field_symbol], r8b
            je .continue_without_win

            cmp [bomb_symbol], r8b
            je .continue_without_win

            inc rdx
            inc r9
            jmp .loop_win_2

        .next:

        inc rbx

        jmp .loop_win_1

    .next1:

    .win:
        pop r9
        pop r8
        pop rbx
        pop rdx
        pop rax

        call endwin
        mov rsi, win_msg
        call print_str
        call new_line
        jmp .exit

    .continue_without_win:
    pop r9
    pop r8
    pop rbx
    pop rdx
    pop rax
    
    jmp .not_win
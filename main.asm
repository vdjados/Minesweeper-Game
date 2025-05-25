format ELF64
public _start
include 'configure.asm'
include 'drawer.asm'
include 'field_generator.asm'

section '.data' writable
    field_symbol db '#'
    bomb_symbol db '*'
    flag_symbol db '^'
    wrong_flag_symbol db '@'
section '.bss' writable
    width db 9
    height db 4
    game_field rb 256  ;
    cursor_pos_x db 1
    cursor_pos_y db 1
section '.text' executable
_start:
    call set_configuration
    call generate_field
    
    add [width], 1

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
        dec [cursor_pos_y]
        jmp .loop

    .move_down:
        inc [cursor_pos_y]
        jmp .loop

    .move_left:
        dec [cursor_pos_x]
        jmp .loop

    .move_right:
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
        cmp r9b, [bomb_symbol]
        jne .show_number               ; если не #, пропускаем
        
            pop rdx
            pop rdi
            pop rax
            pop r8
            jmp .end_game

        .show_number:
            ; Если ячейка закрыта, заменяем её на временное значение (например, '0')
            ; Позже здесь будет вызов функции подсчёта бомб
            mov byte [game_field + rax], '0'
        
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
        
        ; Теперь в rax индекс в массиве game_field
        ; Проверяем, является ли ячейка закрытой (#)
        mov r9b, byte [game_field + rax]
        cmp r9b, [bomb_symbol]
        je .set_flag_to_bomb               ; если не #, пропускаем
        cmp r9b, [field_symbol]
        je .set_wrong_flag  

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

        .skip_flag:
        
        pop rdx
        pop rdi
        pop rax
        pop r8



        jmp .loop

    .end_game:
    
    ; Завершение работы
    call endwin

    jmp .exit
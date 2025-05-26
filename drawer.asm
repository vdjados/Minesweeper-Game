extrn initscr
extrn start_color
extrn init_pair
extrn move
extrn addch
extrn exit
extrn refresh
extrn getch
extrn endwin
extrn stdscr
extrn noecho
extrn cbreak
extrn COLOR_PAIR
extrn attron
extrn clear


draw_field:
    ;call clear
    ; Инициализация цветов
    call start_color

    mov rdi, 0
    mov rsi, 0
    call move    

    mov rdi, 1    ; номер пары (от 1 до 255)
    mov rsi, 4    ; цвет текста (например, BLUE = 4)
    mov rdx, 2    ; цвет фона (например, BLACK = 0)
    call init_pair

    mov rdi, 2    ; номер пары (от 1 до 255)
    mov rsi, 3    ; цвет текста (например, BLUE = 4)
    mov rdx, 1   ; цвет фона (например, BLACK = 0)
    call init_pair

    xor rbx, rbx
    xor r8, r8
    xor r9, r9
    .loop1:
        cmp bl, [height]
        je .next1
        xor rdx, rdx
        .loop:

            cmp dl, [width]
            je .next

            push rdx
            xor r8, r8
            mov r8b, [cursor_pos_x]
            cmp rdx, r8
            jne .default
            mov r8b, [cursor_pos_y]
            cmp rbx, r8
            jne .default

                mov rdi, 1        ; номер пары, которую создали
                jmp .setcolor

            .default:
                mov rdi, 2        ; номер пары, которую создали

            .setcolor:
            call COLOR_PAIR   ; преобразует номер пары в атрибут
            mov rdi, rax      ; помещаем атрибут в rdi
            call attron       ; включаем атрибут
            

            xor rdi, rdi

            xor r8, r8
            mov r8b, [game_field + r9]
            cmp [bomb_symbol], r8b
            je .print_field

            xor r8, r8
            mov r8b, [game_field + r9]
            cmp [wrong_flag_symbol], r8b
            je .print_flag

            movzx rdi, byte [game_field + r9]
            jmp .make_print

            .print_field:
                xor rdi, rdi
                movzx rdi, byte [field_symbol]  ; явно читаем 1 байт
                jmp .make_print
            
            .print_flag:
                xor rdi, rdi
                movzx rdi, byte [flag_symbol]  ; явно читаем 1 байт
                jmp .make_print

            .make_print:
            call addch

            pop rdx
            inc rdx
            inc r9
            jmp .loop
        .next:

        inc rbx
        mov rdi, rbx
        mov rsi, 0
        call move

        jmp .loop1

    .next1:

    ret

draw_opened_field:
    ;call clear
    ; Инициализация цветов
    call start_color

    mov rdi, 0
    mov rsi, 0
    call move    

    mov rdi, 1    ; номер пары (от 1 до 255)
    mov rsi, 4    ; цвет текста (например, BLUE = 4)
    mov rdx, 2    ; цвет фона (например, BLACK = 0)
    call init_pair

    mov rdi, 2    ; номер пары (от 1 до 255)
    mov rsi, 3    ; цвет текста (например, BLUE = 4)
    mov rdx, 1    ; цвет фона (например, BLACK = 0)
    call init_pair

    xor rbx, rbx
    xor r8, r8
    xor r9, r9
    .loop1:
        cmp bl, [height]
        je .next1
        xor rdx, rdx
        .loop:

            cmp dl, [width]
            je .next

            push rdx
            mov r8b, [cursor_pos_x]
            cmp rdx, r8
            jne .default
            mov r8b, [cursor_pos_y]
            cmp rbx, r8
            jne .default

                mov rdi, 1        ; номер пары, которую создали
                jmp .setcolor

            .default:
                mov rdi, 2        ; номер пары, которую создали

            .setcolor:
            call COLOR_PAIR   ; преобразует номер пары в атрибут
            mov rdi, rax      ; помещаем атрибут в rdi
            call attron       ; включаем атрибут
            
            xor rdi, rdi
            movzx rdi, byte [game_field + r9]  ; явно читаем 1 байт

            call addch

            pop rdx
            inc rdx
            inc r9
            jmp .loop
        .next:

        inc rbx
        mov rdi, rbx
        mov rsi, 0
        call move

        jmp .loop1

    .next1:

    ret
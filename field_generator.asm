include 'random_generator.asm'
generate_field:

    push rax
    xor rbx, rbx
    xor rax, rax
    xor r9, r9
    .loop1:
        cmp bl, [height]
        je .next1
        xor rdx, rdx
        .loop:

            
            cmp dl, [width]
            je .next

            call generate_number
            cmp dl, 15
            jbe .bomb
            
            .empty:
                mov al, [field_symbol]  ; загружаем символ в AL (8-битный регистр)
                jmp .save

            .bomb:
                mov al, [bomb_symbol]  ; загружаем символ в AL (8-битный регистр)
            
            .save:

                mov [game_field + r9], al    ; сохраняем AL в game_field

            inc rdx
            inc r9
            jmp .loop
        .next:


        inc rbx
        jmp .loop1

    .next1:
    pop rax
    ret

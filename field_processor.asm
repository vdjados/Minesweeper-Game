count_bombs:
    push r9
    push rax
    xor r8, r8

    mov al, [cursor_pos_y] 
    movzx r8, byte [width]   ; r8 = width (расширяем до 64 бит без знака)
    mul r8                   ; rax = y * width
    xor rdx, rdx
    mov dl, [cursor_pos_x]
    add rax, rdx            ; rax = y * width + x
    
    xor r8, r8

    xor r9, r9  ; left
    cmp [cursor_pos_x], 0
    je .no_bomb_1
    dec rax
    mov r9b, byte [game_field + rax] ;
    inc rax
    cmp r9b, [bomb_symbol]
    jne .no_bomb_1
    inc r8
    .no_bomb_1:

    xor r9, r9  ;   right
    mov r9b, [width]
    dec r9b
    cmp [cursor_pos_x], r9b
    je .no_bomb_2
    inc rax
    xor r9, r9
    mov r9b, byte [game_field + rax] ;
    dec rax
    cmp r9b, [bomb_symbol]
    jne .no_bomb_2
    inc r8
    .no_bomb_2:

    xor r9, r9  ;   up
    cmp [cursor_pos_y], 0
    je .no_bomb_3
    push rdi
    movzx rdi, [width]
    sub rax, rdi
    pop rdi
    mov r9b, byte [game_field + rax] ;
    push rdi
    movzx rdi, [width]
    add rax, rdi
    pop rdi
    cmp r9b, [bomb_symbol]
    jne .no_bomb_3
    inc r8
    .no_bomb_3:

    xor r9, r9  ;   down
    mov r9b, [height]
    dec r9b
    cmp [cursor_pos_y], r9b
    je .no_bomb_4
    push rdi
    movzx rdi, [width]
    add rax, rdi
    pop rdi
    xor r9, r9
    mov r9b, byte [game_field + rax] ;
    push rdi
    movzx rdi, [width]
    sub rax, rdi
    pop rdi
    cmp r9b, [bomb_symbol]
    jne .no_bomb_4
    inc r8
    .no_bomb_4:

    xor r9, r9  ; left-up
    cmp [cursor_pos_x], 0
    je .no_bomb_5
    cmp [cursor_pos_y], 0
    je .no_bomb_5
    dec rax
    push rdi
    movzx rdi, [width]
    sub rax, rdi
    pop rdi
    mov r9b, byte [game_field + rax] ;
    inc rax
    push rdi
    movzx rdi, [width]
    add rax, rdi
    pop rdi
    cmp r9b, [bomb_symbol]
    jne .no_bomb_5
    inc r8
    .no_bomb_5:

    xor r9, r9  ; left-down
    mov r9b, [height]
    dec r9b
    cmp [cursor_pos_x], 0
    je .no_bomb_6
    cmp [cursor_pos_y], r9b
    je .no_bomb_6
    dec rax
    push rdi
    movzx rdi, [width]
    add rax, rdi
    pop rdi
    mov r9b, byte [game_field + rax] ;
    inc rax
    push rdi
    movzx rdi, [width]
    sub rax, rdi
    pop rdi
    cmp r9b, [bomb_symbol]
    jne .no_bomb_6
    inc r8
    .no_bomb_6:

    xor r9, r9  ;   right-up
    mov r9b, [width]
    dec r9b
    cmp [cursor_pos_x], r9b
    je .no_bomb_7
    cmp [cursor_pos_y], 0
    je .no_bomb_7
    inc rax
    push rdi
    movzx rdi, [width]
    sub rax, rdi
    pop rdi
    xor r9, r9
    mov r9b, byte [game_field + rax] ;
    dec rax
    push rdi
    movzx rdi, [width]
    add rax, rdi
    pop rdi
    cmp r9b, [bomb_symbol]
    jne .no_bomb_7
    inc r8
    .no_bomb_7:

    xor r9, r9  ;   right-down
    mov r9b, [width]
    dec r9b
    cmp [cursor_pos_x], r9b
    je .no_bomb_8
    mov r9b, [height]
    dec r9b
    cmp [cursor_pos_y], r9b
    je .no_bomb_8
    inc rax
    push rdi
    movzx rdi, [width]
    add rax, rdi
    pop rdi
    xor r9, r9
    mov r9b, byte [game_field + rax] ;
    dec rax
    push rdi
    movzx rdi, [width]
    sub rax, rdi
    pop rdi
    cmp r9b, [bomb_symbol]
    jne .no_bomb_8
    inc r8
    .no_bomb_8:

    pop rax
    pop r9
    ret

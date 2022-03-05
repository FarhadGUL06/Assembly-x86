section .text
    global rotp

;; void rotp(char *ciphertext, char *plaintext, char *key, int len);
rotp:
    ;; DO NOT MODIFY
    push    ebp
    mov     ebp, esp
    pusha

    mov     edx, [ebp + 8]  ; ciphertext
    mov     esi, [ebp + 12] ; plaintext
    mov     edi, [ebp + 16] ; key
    mov     ecx, [ebp + 20] ; len
    ;; DO NOT MODIFY

    ;; TODO: Implment rotp
    ;; FREESTYLE STARTS HERE
    mov eax, 0
    while_loop:
    cmp eax, ecx
    je end_loop
    operatie:
        ; Calculez pozitia de pus
        ; eax - contor
        sub ecx, eax
        mov bl, [edi - 1 + ecx] ;key + len - i -1
        add ecx, eax
        xor bl, [esi + eax] ;xor cu plaintext + i
        ; Am luat bl pentru ca cu ebx suprascria memoria lui reftext
        mov [edx + eax], bl
        inc eax
        jmp while_loop
    end_loop:
        xor eax, eax
    ;; FREESTYLE ENDS HERE
    ;; DO NOT MODIFY
    popa
    leave
    ret
    ;; DO NOT MODIFY
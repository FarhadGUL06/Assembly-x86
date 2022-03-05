global expression
global term
global factor

section .text

; `factor(char *p, int *i)`
;   Evaluates "(expression)" or "number" expressions 
; @params:
;   p -> the string to be parsed
;   i -> current position in the string
; @returns:
;   the result of the parsed expression
factor:
    push ebp
    mov ebp, esp
    mov ecx, [esp + 8] ; *p - sirul
    mov edx, [esp + 12]  ; *i - pointer pozitie
    ; Punem valoarea lui ebx pe stiva pentru a putea folosi registrul
    push ebx
    ; Initializam rezultatul
    mov eax, 0
    verificare: 
        ; Verific daca este cifra
        mov edi, [edx]
        cmp [ecx+edi], byte 48 ; 48 = '0'
        jge mai_mare_0
        jmp continuare_factor

    mai_mare_0:
        ; O cifra se incadreaza de la 0 la 9
        cmp [ecx+edi], byte 57 ; 57 = '9'
        jle mai_mic_9
        jmp continuare_factor
    
    mai_mic_9:
        ; Salvam eax
        push eax
        ; Cifra curenta in eax
        xor eax, eax
        mov al, [ecx+edi]
        sub al, '0'
        mov ebx, eax
        ; Numarul curent in eax
        pop eax
        ; Inmultim cu 10 si adunam cifra curenta
        mov esi, 10
        ; Salvam adresa pozitiei
        push edx
        xor edx, edx
        mul esi
        xor edx, edx
        add eax, ebx
        ; Repunem adresa pozitiei si o actualizam
        pop edx
        inc dword edi
        mov [edx], edi
        jmp verificare

    continuare_factor:
        ; Verificam daca avem paranteza
        mov edi, [edx]
        cmp [ecx+edi], byte 40 ; 40 = '('
        je paranteza
        jmp final_factor

    paranteza:
        ; Daca avem paranteze, rezolvam ce e inauntru
        inc dword edi
        mov [edx], edi
        push edx
        push ecx
        call expression
        add esp, 8
        ; Actualizam pozitia
        mov edi, [edx]
        inc dword edi
        mov [edx], edi
        jmp final_factor

    final_factor:
    ; Repunem valoarea in ebx
    pop ebx
    ; Avem rezultatul in eax
    leave
    ret

; `term(char *p, int *i)`
;   Evaluates "factor" * "factor" or "factor" / "factor" expressions 
; @params:
;   p -> the string to be parsed
;   i -> current position in the string
; @returns:
;   the result of the parsed expression
term:
    push ebp
    mov ebp, esp
    mov ecx, [esp + 8] ; *p - sirul
    mov edx, [esp + 12]  ; *i - pointer pozitie
    ; Punem valoarea lui ebx pe stiva pentru a putea folosi registrul
    push ebx
    ; Punem adresa sirului pe stiva
    push ecx
    ; Apelam functia factor
    push edx
    push ecx
    call factor
    add esp, 8
    ; Salvam rezultatul functiei in rez
    ; Refacem sirul
    pop ecx
    ; Salvam eax
    push eax
    ; Salvam pozitia curenta in [pozitie]
    mov eax, [edx]
    ;mov [pozitie], eax
    mov edi, eax
    pop eax
    verificare_term_prod:
        mov edi, [edx]
        cmp [ecx+edi], byte 42 ; 42 = '*'
        je in_loop
        jmp verificare_term_imp

    verificare_term_imp:
        mov edi, [edx]
        cmp [ecx+edi], byte 47 ; 47 = '/'
        je in_loop
        jmp final_term
    
    in_loop:
        cmp [ecx+edi], byte 42 ; '*'
        je inmultire
        cmp [ecx+edi], byte 47 ; '/'
        je impartire
        jmp verificare_term_prod

    inmultire:
        ; Cazul de inmultire
        ; Salvam rezultatul
        push eax
        ; Punem noua pozitie in edx
        inc dword edi
        mov eax, edi
        mov [edx], eax
        ; Apelam functia de rezultat
        push edx
        push ecx
        call factor
        add esp, 8
        ; Punem rezultatul inapoi
        pop edi
        ; In edi avem primul termen
        ; In eax avem al doilea termen
        ; Salvam adresa pozitiei
        push edx
        xor edx, edx
        mul edi
        xor edx, edx
        ; Recuperam adresa pozitiei
        pop edx
        jmp verificare_term_prod

    impartire:
        ; Cazul de impartire
        ; Salvam rezultatul
        push eax
        ; Punem noua pozitie in edx
        inc dword edi
        mov eax, edi
        mov [edx], eax
        ; Apelam functia de rezultat
        push edx
        push ecx
        call factor
        add esp, 8
        ; Punem rezultatul inapoi
        pop edi
        ; Interschimbam valorile
        xchg eax, edi
        ; In eax avem deimpartitul
        ; In edi avem impartitorul
        ; Salvam adresa pozitiei
        push edx
        xor edx, edx
        cdq
        idiv edi
        xor edx, edx
        ; Recuperam adresa pozitiei
        pop edx
        jmp verificare_term_prod

    final_term:
    ; Repunem valoarea in ebx
    pop ebx
    ; Avem in eax rezultatul
    leave
    ret

; `expression(char *p, int *i)`
;Evaluates "term" + "term" or "term" - "term" expressions 
; @params:
;   p -> the string to be parsed
;   i -> current position in the string
; @returns:
;   the result of the parsed expression
expression:
    push ebp
    mov ebp, esp
    mov ecx, [ebp + 8] ; *p - sirul
    mov edx, [ebp + 12]  ; *i - pointer pozitie
    ; Punem valoarea lui ebx pe stiva pentru a putea folosi registrul
    push ebx
    ; Punem adresa sirului pe stiva
    push ecx
    ; Apelam functia term
    push edx
    push ecx
    call term
    add esp, 8
    ; Salvam rezultatul functiei in rez
    ; Refacem sirul
    pop ecx
    verificare_term_add:
        mov ebx, [edx]
        cmp [ecx+ebx], byte 43 ; 43 = '+'
        je in_loop_expr
        jmp verificare_term_sub

    verificare_term_sub:
        cmp [ecx+ebx], byte 45 ; 45 = '-'
        je in_loop_expr
        jmp final_expr
    
    in_loop_expr:
        ; Verificam ce operatie avem de facut
        cmp [ecx+ebx], byte 43 ; '+'
        je adunare
        cmp [ecx+ebx], byte 45 ; '-'
        je scadere
        jmp verificare_term_add

    adunare:
        ; Cazul de adunare
        ; Salvam rezultatul
        push eax 
        inc dword ebx
        mov eax, ebx
        mov [edx], eax
        ; Apelam functia de rezultat
        push edx
        push ecx
        call term
        add esp, 8
        ; Recuperam rezultatul in edi
        pop edi
        add eax, edi
        jmp verificare_term_add

    scadere:
        ; Cazul de scadere
        ; Salvam rezultatul
        push eax
        ; Crestem pozitia si o salvam
        inc dword ebx
        mov eax, ebx
        mov [edx], eax
        ; Apelam functia de rezultat
        push edx
        push ecx
        call term
        add esp, 8
        ; Recuperam rezultatul
        pop edi
        xchg eax, edi
        sub eax, edi
        jmp verificare_term_add

    final_expr: 
    ; Repunem valoarea in ebx
    pop ebx
    ; Avem in eax rezultatul
    leave
    ret

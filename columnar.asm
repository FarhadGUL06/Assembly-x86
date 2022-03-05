section .data
    extern len_cheie, len_haystack
    nr_linii dd 0
    increment dd 0
    coloana dd 0
    total dd 0
    restul dd 0
    curent_line dd 0
    global vector
    vector: times 100 dd 0

section .text
    global columnar_transposition

;; void columnar_transposition(int key[], char *haystack, char *ciphertext);
columnar_transposition:
    ;; DO NOT MODIFY
    push    ebp
    mov     ebp, esp
    pusha 

    mov edi, [ebp + 8]   ;key
    mov esi, [ebp + 12]  ;haystack
    mov ebx, [ebp + 16]  ;ciphertext
    ;; DO NOT MODIFY

    ;; TODO: Implment columnar_transposition
    ;; FREESTYLE STARTS HERE

    ; In edi am cheile - cresc din 4 - [edi+4] - al doilea
    ; Calculez cate linii voi avea in matrice
    ; [nr_linii] - numarul de linii
    ; [restul] - elemente ramase (indica si cate coloane am de [nr_linii] elemente)

    mov eax, dword [len_haystack]
    sub eax, 1
    mov edx, dword [len_haystack+4]
    mov ecx, dword [len_cheie]
    div ecx
    mov [restul], edx
    inc dword [restul]
    cmp edx, 0
    mov [nr_linii], eax
    je inca_o_linie
    ja inca_o_linie
    
    dupa_adaugare:
    ; Setam elementele de inceput
    mov [total], dword 0
    mov [coloana], dword 0
    mov [increment], dword 0
    mov [curent_line], dword 0
    mov eax, [len_cheie]
    add [total], eax
    sub [total], edx
    mov edx, [len_haystack]
    add [total], edx
    dec dword [total]
    
    ; Luam coloana curenta (prin [edi + 4* [coloana]])
    ; [coloana] - coloana curenta
    ; Formula de punere - v[increment] = v[ increment + nr_linii * coloana curenta]
    ; [edi + 4 * coloana] = indicii ordinii de parcurgere a coloanelor

    ; Trecem direct la generarea vectorului
    jmp while_construire
    ante_while_construire:
        mov ecx, [increment]
        mov [vector+ecx], dword 48
        inc dword [increment]

    while_construire:
        ; Nu depasim maximul posibil
        ; [total] = [nr_linii] * [len_cheie] (maximul posibil)
        mov edx, [increment]
        cmp edx, [total]
        je finalizare_construire
        jg finalizare_construire

    coloane_intregi:
        ; Verificam daca mai avem coloane cu fix [nr_linii] elemente
        mov edx, [restul]
        cmp edx, 0 
        ; constructia1 - daca am [nr_linii] elemente pe coloana
        jg constructie_vector1
        ; constructia2 - daca am [nr_linii]-1 elemente pe coloana
        jmp constructie_vector2
    
    constructie_vector1:
        ; Calculez coloana curenta
        mov edx, [curent_line]
        ; Calculez pozitie din cheie in eax
        mov eax, [len_cheie]
        mul edx
        ; eax - rezultatul
        mov edx, [curent_line]
        cmp edx, [nr_linii]
        ; Parcurgem coloana curenta pe linii
        jl punere_coloana
        ; Daca am terminat o coloana
        ; Resetam linia curenta
        mov [curent_line], dword 0
        ; Scadem o coloana din nr de coloane cu [nr_linii] elemente
        dec dword [restul]
        ; Trecem la coloana urmatoare
        inc dword [coloana]
        jmp while_construire

    punere_coloana:
        ; Generam coloana curenta in vector
        mov ecx, [increment]
        mov edx, [coloana]
        add edx, eax
        mov dl, [esi+edx]
        ; Atasam elementul
        mov [vector+ecx],byte  dl
        inc dword [curent_line]
        inc dword [increment]
        jmp constructie_vector1

    constructie_vector2:
        ; Calculez coloana curenta
        mov edx, [curent_line]
        ; Calculez pozitie din cheie in eax
        mov eax, [len_cheie]
        mul edx
        mov edx, [curent_line]
        mov ecx, [nr_linii]
        dec ecx
        cmp edx, ecx
        ; Parcurgem coloana curenta pe linii
        jl punere_coloana2
        ; Daca am terminat o coloana
        ; Resetam linia curenta
        mov [curent_line], dword 0
        ; Trecem la coloana urmatoare
        inc dword [coloana]
        ; Atasam un 0 pe pozitiile unde nu avem elemente din plaintext
        jmp ante_while_construire

    punere_coloana2:
        ; Generam coloana curenta in vector
        mov ecx, [increment]
        mov edx, [coloana]
        add edx, eax
        mov dl, [esi+edx]
        ; Atasam elementul
        mov [vector+ecx], byte dl
        inc dword [curent_line]
        inc dword [increment]
        jmp constructie_vector2

    finalizare_construire:
        ; Am terminat de montat vectorul
        mov [coloana], dword 0
        mov [curent_line], dword 0

    ;; Mai jos introducem vectorul obtinut conform indicilor din cheie

    mov [increment], dword 0

    while_punere:
        ; Cat timp avem de pus
        mov edx, [increment]
        cmp edx, [len_haystack]
        je finalizare
        jg finalizare
        ; Setam pozitia pe linii 0
        mov [curent_line], dword 0
    
    calcul_pozitie_rez:
        ; Calculez coloana curenta de pus
        mov ecx, [coloana]
        mov ecx, [edi+4*ecx]
        ; Calculez pozitie din cheie in eax
        mov eax, [nr_linii]
        mul ecx

    while_poz_in_nr_linii:
        ; Calculam pozitia din vector curenta
        mov ecx, [curent_line]
        mov edx, eax
        add edx, ecx
        ; Verificam daca mai avem de parcurs pe linie (pe coloana curenta)
        cmp ecx, [nr_linii]
        jb este_sub
        ; Daca am terminat o coloana, trecem la urmatoarea
        add [coloana], dword 1
        jmp while_punere

    este_sub:
        ; Suntem pe coloana curenta
        ; edx - pozitie in sirul principal de pus
        ; eax - pozitia de inceput neincrementata a sirului de pus
        ; increment - pozitia in vectorul curent
        ; Verificam daca am terminat
        mov eax, [increment]
        cmp eax, [len_haystack]
        je finalizare
        ; Verificam daca exista caracterul curent
        mov ecx, [vector+edx]
        cmp cl, byte 48
        je omitere
        ; Punem vectorul in ebx
        mov [ebx+eax], cl
        ; Incrementam pozitia pe linie din coloana curenta
        add [curent_line], dword 1
        add [increment], dword 1
        jmp calcul_pozitie_rez

    omitere:
        ; Omitem caracterul curent (nu exista)
        add [coloana], dword 1
        mov [curent_line], dword 0
        jmp calcul_pozitie_rez

    inca_o_linie:
        ; Avem un rest, deci o linie in plus
        add [nr_linii], dword 1
        jmp dupa_adaugare

    finalizare:
        ; Punem pe 0 toate variabilele   
        mov [curent_line], dword 0
        mov [nr_linii], dword 0
        mov [increment], dword 0
        mov [coloana], dword 0
        mov [total], dword 0
        mov [restul], dword 0
        mov eax, [vector]
        xor eax, eax

    ;; FREESTYLE ENDS HERE
    ;; DO NOT MODIFY
    popa
    leave
    ret
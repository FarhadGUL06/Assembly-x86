;; defining constants, you can use these as immediate values in your code
CACHE_LINES  EQU 100
CACHE_LINE_SIZE EQU 8
OFFSET_BITS  EQU 3
TAG_BITS EQU 29 ; 32 - OFFSET_BITS

section .data
    tag dd 0
    offset dd 0 
    increment dd 0
    pozitie_edx dd 0

section .text
    global load

;; void load(char* reg, char** tags, char cache[CACHE_LINES][CACHE_LINE_SIZE], char* address, int to_replace);
load:
    ;; DO NOT MODIFY
    push ebp
    mov ebp, esp
    pusha

    mov eax, [ebp + 8]  ; address of reg
    mov ebx, [ebp + 12] ; tags
    mov ecx, [ebp + 16] ; cache
    mov edx, [ebp + 20] ; address
    mov edi, [ebp + 24] ; to_replace (index of the cache line that needs to be replaced in case of a cache MISS)
    ;; DO NOT MODIFY

    ;; TODO: Implment load
    ;; FREESTYLE STARTS HERE

    ; Afisez valoarea in reg - [eax]
    ; Construiesc cache in ecx pe linia ceruta (daca nu exista deja in cache)
    ; Tagul pe linia din cache - 0 sau adresa (32 - 3 = 29 biti)
    ; edi - to_replace - linia din cache
    ; Pun in [eax] valoarea din cache[to_replace][offset]

    
    ; Calculam offsetul (ultimii 3 biti)
    ; Punem adresa lui [edx] in eax
    lea eax, [edx]
    ; Shiftam cu 29 de biti la stanga (stim ca maximul este 32)
    ; In acest punct se obtine un octet cu primii 3 biti egali cu offset
    shl eax, TAG_BITS
    ; Shiftam la dreapta cu 29 de biti pentru a obtine offset-ul de doar 3 biti
    shr eax, TAG_BITS
    ; Salvam in [offset] rezultatul obtinut
    mov [offset], eax

    ; Calculam tagul (primii 29 biti)
    ; Punem adresa lui [edx] in eax
    lea eax, [edx] ; la fel ca mov eax, edx
    ; Shiftam la dreapta cu 3 biti (se pierd ultimii 3 biti)
    shr eax, OFFSET_BITS
    ; Punem in [tag] rezultatul obtinut
    mov [tag], eax

    while_tags:
        ; Parcurgem vectorul de taguri
        mov eax, [increment]
        cmp eax, CACHE_LINES
        jb verificare_tags
        je negasit_tag
        ja negasit_tag
        jmp while_tags
    
    verificare_tags:
        ; Verificam daca exista tagul pe pozitia [increment]
        mov edx, [increment]
        mov eax, [ebx+edx]
        cmp eax, [tag]
        je gasit_tag
        add [increment], dword 1
        jmp while_tags
    
    gasit_tag:
        ; Am gasit tagul in vectorul de tags pe pozitia [increment]
        mov eax, CACHE_LINE_SIZE
        mov ebx, [increment]
        mul ebx
        ; Avem rezultatul in eax
        mov ebx, eax
        mov eax, [ebp + 8]  ; address of reg
        ; Punem in registru valoarea din cache[to_replace][offset]
        add ebx, [offset]
        mov ebx, [ecx+ebx]
        mov [eax], ebx
        jmp finalizare_tags

    negasit_tag:
        ; Atasam tagul pe pozitia [ebx + to_replace]
        mov eax, [tag]
        mov [ebx+edi], eax
        ; Resetam contorul si montam cache
        mov [increment], dword 0
        jmp cache_tag_negasit

    cache_tag_negasit:
        ; In cazul in care tagul nu a fost gasit
        mov ecx, [ebp + 16] ; cache
        mov edx, [ebp + 20] ; address
        mov eax, [increment]
        ; Implementam in cache adresa
        cmp eax, 0
        je stabilire_inceput
        mov eax, [increment]
        cmp eax, 8
        jb punere_cache 
        jmp oprire_punere

    stabilire_inceput:
        ; Aici trebuie sa gasim pozitia de inceput
        ; Poate fi mai mica sau egala cu pozitia curenta
        ; Conditie: divizibilitate cu 8 a pozitiei
        ; Stabilim inceputul in [pozitie_edx]     
        mov ebx, [pozitie_edx]
        lea eax, [edx+ebx]
        ; Shiftez maxim la stanga si apoi la dreapta
        ; Pentru a pastra valoarea ultimilor 3 biti
        ; Un numar este divizibil cu 8 <=> are ultimii 3 biti setati pe 0
        shl eax, 29
        shr eax, 29
        ; Comparam restul obtinut cu 0 (numarul format din ultimii 3 biti)
        cmp eax, 0
        je punere_cache
        ; Daca avem rest, scadem pozitia de inceput si recalculam
        sub [pozitie_edx], dword 1
        jmp stabilire_inceput

    punere_cache:
        ; Punem in [ecx+ CACHE_LINE_SIZE * edi] octetii pe rand
        ; Defazarea pentru inceputul octetilor este [pozitie_edx]
        mov edx, [ebp + 20] ; address
        mov eax, CACHE_LINE_SIZE
        mov ebx, edi
        mul ebx
        add eax, [increment]
        ; Restabilim adresa 
        mov edx, [ebp + 20] ; address    
        mov ebx, [increment]
        add ebx, dword [pozitie_edx]
        mov ebx, [edx+ebx]
        ; Restabilim cache
        mov ecx, [ebp + 16] ; cache
        ; Efectuam mutarea
        mov [ecx+eax], ebx
        add [increment], dword 1
        jmp cache_tag_negasit

    oprire_punere:
        ; Acum montam registrul corespunzator
        mov eax, CACHE_LINE_SIZE
        mov ebx, edi
        mul ebx
        ; Avem rezultatul in eax
        mov ebx, eax
        mov eax, [ebp + 8]  ; address of reg
        ; Punem in registru valoarea din cache[to_replace][offset]
        add ebx, [offset]
        mov ebx, [ecx+ebx]
        mov [eax], ebx
        jmp finalizare_tags

    finalizare_tags:
        ; Resetam valorile pentru urmatorul test
        mov [increment], dword 0
        mov [pozitie_edx], dword 0
        xor eax, eax

    ;; FREESTYLE ENDS HERE
    ;; DO NOT MODIFY
    popa
    leave
    ret
    ;; DO NOT MODIFY



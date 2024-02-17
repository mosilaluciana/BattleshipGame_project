.386
.model flat, stdcall
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;includem biblioteci, si declaram ce functii vrem sa importam
includelib msvcrt.lib
extern exit: proc
extern malloc: proc
extern memset: proc

extern printf: proc
extern scanf: proc
extern srand: proc
extern rand: proc
extern time: proc
includelib canvas.lib
extern BeginDrawing: proc
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;declaram simbolul start ca public - de acolo incepe executia
public start
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;sectiunile programului, date, respectiv cod
.data
;aici declaram date
    ;0  1  2 ;3  4  5  6  7  8 
m DB 0, 0, 0, 0, 0, 0, 0, 0, 0 ; ;0
  DB 0, 0, 0, 0, 0, 0, 0, 0, 0 ; 1
  DB 0, 0, 0, 0, 0, 0, 0, 0, 0 ; 2
  DB 0, 0, 0, 0, 0, 0, 0, 0, 0 ; 3
  DB 0, 0, 0, 0, 0, 0, 0, 0, 0 ; 4
  DB 0, 0, 0, 0, 0, 0, 0, 0, 0 ; 4
  DB 0, 0, 0, 0, 0, 0, 0, 0, 0 ; 5

barca1_x DD 300
barca1_y DD 100

barca2_x DD 300
barca2_y DD 100

barca3_x DD 300
barca3_y DD 100

barca4_x DD 300
barca4_y DD 100

barca5_x DD 300
barca5_y DD 100

barca6_x DD 300
barca6_y DD 100


ok_barca_1 DB 0
ok_barca_2 DB 0
ok_barca_3 DB 0
ok_barca_4 DB 0
ok_barca_5 DB 0
ok_barca_6 DB 0


counter_nedescoperite DD 6
counter_ratari  DD 0
counter_scufundate DD 0

q DD 0

coord_x EQU 300
coord_y EQU 100
lungime EQU 600
latime EQU 500
capacitate EQU 100

punct_x DD ?
punct_y DD ?


format_afisare DB "%d %d", 13, 10, 0


window_title DB "JOC VAPORASE",0
area_width EQU 1000
area_height EQU 700
area DD 0

counter DD 0 ; numara evenimentele de tip timer

arg1 EQU 8
arg2 EQU 12
arg3 EQU 16
arg4 EQU 20

symbol_width EQU 10
symbol_height EQU 20
include digits.inc
include letters.inc

.code

; procedura make_text afiseaza o litera sau o cifra la coordonatele date
; arg1 - simbolul de afisat (litera sau cifra)
; arg2 - pointer la vectorul de pixeli
; arg3 - pos_x
; arg4 - pos_y

make_text proc
	push ebp
	mov ebp, esp
	pusha
	
	mov eax, [ebp+arg1] ; citim simbolul de afisat
	cmp eax, 'A'
	jl make_digit
	cmp eax, 'Z'
	jg make_digit
	sub eax, 'A'
	lea esi, letters
	jmp draw_text
make_digit:
	cmp eax, '0'
	jl make_space
	cmp eax, '9'
	jg make_space
	sub eax, '0'
	lea esi, digits
	jmp draw_text
make_space:	
	mov eax, 26 ; de la 0 pana la 25 sunt litere, 26 e space
	lea esi, letters
	
draw_text:
	mov ebx, symbol_width
	mul ebx
	mov ebx, symbol_height
	mul ebx
	add esi, eax
	mov ecx, symbol_height
bucla_simbol_linii:
	mov edi, [ebp+arg2] ; pointer la matricea de pixeli
	mov eax, [ebp+arg4] ; pointer la coord y
	add eax, symbol_height
	sub eax, ecx
	mov ebx, area_width
	mul ebx
	add eax, [ebp+arg3] ; pointer la coord x
	shl eax, 2 ; inmultim cu 4, avem un DWORD per pixel
	add edi, eax
	push ecx
	mov ecx, symbol_width
bucla_simbol_coloane:
	cmp byte ptr [esi], 0
	je simbol_pixel_alb
	mov dword ptr [edi], 0
	jmp simbol_pixel_next
simbol_pixel_alb:
	mov dword ptr [edi], 0FFFFFFh
simbol_pixel_next:
	inc esi
	add edi, 4
	loop bucla_simbol_coloane
	pop ecx
	loop bucla_simbol_linii
	popa
	mov esp, ebp
	pop ebp
	ret
make_text endp

; un macro ca sa apelam mai usor desenarea simbolului
make_text_macro macro symbol, drawArea, x, y
	push y
	push x
	push drawArea
	push symbol
	call make_text
	add esp, 16
endm


linie_orizontala macro lungime, x, y, culoare 
local bucla_linie
    mov eax, y ; EAX = y
    mov ebx, area_width
	mul ebx; EAX= y * area_width 
	add eax, x ; EAX= y*area_width + x
	shl eax, 2; EAX =(y * area_width + x) * 4
	add eax, area
	
     mov ecx, lungime 
	 
bucla_linie:
	mov dword ptr[eax], culoare
   add eax, 4
   loop bucla_linie
endm
  
 
linie_verticala macro lungime, x, y, culoare 
local bucla_linie
    mov eax, y ; EAX = y
    mov ebx, area_width
	mul ebx; EAX= y * area_width 
	add eax, x ; EAX= y*area_width + x
	shl eax, 2; EAX =(y * area_width + x) * 4
	add eax, area
	
     mov ecx, lungime 
bucla_linie:
	mov dword ptr[eax], culoare
   add eax, area_width * 4
   loop bucla_linie
endm

  
patrat macro latura, x, y, culoare

	mov eax, y ; EAX = y
    mov ebx, area_width
	mul ebx; EAX= y * area_width 
	add eax, x ; EAX= y*area_width + x
	shl eax, 2; EAX =(y * area_width + x) * 4
	add eax, area
	
	linie_verticala latura, x, y, culoare
	linie_orizontala latura, x, y, culoare
	linie_verticala latura, x+latura, y, culoare
	linie_orizontala latura, x, y+latura, culoare
  
endm


colorare_patrat macro latura, x, y, culoare

local bucla, bucla1
    mov eax, y ; EAX = y
    mov ebx, area_width
	mul ebx; EAX= y * area_width 
	add eax, x ; EAX= y*area_width + x
	shl eax, 2; EAX =(y * area_width + x) * 4
	add eax, area
	
	mov ebx, eax	
	mov edx, 0
bucla1:	

	  mov ecx, latura 
bucla:
      mov dword ptr[eax], culoare
	  add eax, 4
	  loop bucla  
	  inc edx
	  
	  add ebx, area_width * 4
	  mov eax, ebx
	  
      cmp edx, latura
	  jne bucla1

endm

sfarsit_joc macro
    make_text_macro 'S', area, 20, 20
	make_text_macro 'F', area, 30, 20
	make_text_macro 'A', area, 40, 20
	make_text_macro 'R', area, 50, 20
	make_text_macro 'S', area, 60, 20
	make_text_macro 'I', area, 70, 20
	make_text_macro 'T', area, 80, 20
	make_text_macro 'U', area, 90, 20
	make_text_macro 'L', area, 100, 20
    make_text_macro 'J', area, 120, 20
	make_text_macro 'O', area, 130, 20
	make_text_macro 'C', area, 140, 20
	make_text_macro 'U', area, 150, 20
	make_text_macro 'L', area, 160, 20
    make_text_macro 'U', area, 170, 20
	make_text_macro 'I', area, 180, 20
endm

ratari macro counter_ratari
    
	
	mov ebx, 10
	mov eax, counter_ratari
	
	;cifra unitatilor
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_macro edx, area, 130, 180
	
	;cifra zecilor
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_macro edx, area, 120, 180

	
endm

vaporase_scufundate macro counter_scufundate    
	
	mov ebx, 10
	mov eax, counter_scufundate
	
	;cifra unitatilor
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_macro edx, area, 130, 330
	
	;cifra zecilor
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_macro edx, area, 120, 330
endm

vaporase_nedescoperite macro counter_nedescoperite 
local final

	mov ebx, 10
	mov eax, counter_nedescoperite
	
	;cifra unitatilor
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_macro edx, area, 130, 470
	
	;cifra zecilor
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_macro edx, area, 120, 470

	cmp counter_nedescoperite, 0
    jne final
	sfarsit_joc
	
final:	
endm


comparare macro x, y, barca_x, barca_y, q , ok_barca

local final, loviri
   
	mov eax, x 
    cmp eax, barca_x
	jne final
	
	mov eax, y
	cmp eax, barca_y
	jne final

	
	;ok_barca = 1 nu mai incrementeaza patratelul unde se afla barca   
	; a mai fost trecut prin zona si sare la eticheta loviri
	cmp ok_barca, 1
	je loviri
	
	inc counter_scufundate
	vaporase_scufundate counter_scufundate
	
	dec counter_nedescoperite
	vaporase_nedescoperite counter_nedescoperite
	
	mov ok_barca, 1

loviri:
    mov q, 1
    colorare_patrat capacitate, x, y, 0FF0000h ; rosu
final:
  
endm


           ; coord click ului   
zona_click macro  x, y, counter_ratari, counter_nedescoperite, counter_scufundate 
                           
local fail_patrat
    
	cmp counter_nedescoperite, 0
	je fail_patrat
	
    ;verifica daca click-ul a fost in interiorul grilei		
	mov eax, x
	cmp eax, coord_x
	jl fail_patrat
	cmp eax, coord_x + lungime-1
	jg fail_patrat
  
	mov eax, y
	cmp eax, coord_y                                         
	jl fail_patrat
	cmp eax, coord_y + latime-1
	jg fail_patrat	
	
   
    ;calculeaza coltul din stanga  pt coord click-ului x si y
    mov edx, 0
	mov ecx, 100 
	mov eax, 0
	mov eax, x ; muta valoarea data in eax
	div ecx   ; imparte nr din eax la 100
	          ;se retine in eax catul si in  edx restul
	mul ecx
	mov ebx, eax
   
    mov edx, 0
	mov ecx, 100 
	mov eax, 0
	mov eax, y ; muta valoarea data in eax
	div ecx   ; imparte nr din eax la 100
	          ;se retine in eax catul si in  edx restul
	mul ecx
	mov ecx, eax
	
	
	mov punct_x,ebx
	mov punct_y,ecx
	
	mov q, 0
	
	comparare punct_x, punct_y, barca1_x, barca1_y, q, ok_barca_1 
	cmp q, 0
	jne fail_patrat	
	
	comparare punct_x, punct_y, barca2_x, barca2_y, q, ok_barca_2
    cmp q, 0
	jne fail_patrat
	
	comparare punct_x, punct_y, barca3_x, barca3_y, q, ok_barca_3 
	cmp q, 0
	jne fail_patrat
	
	comparare punct_x, punct_y, barca4_x, barca4_y, q, ok_barca_4 
	cmp q, 0
	jne fail_patrat	
	
	comparare punct_x, punct_y, barca5_x, barca5_y, q, ok_barca_5 
	cmp q, 0
	jne fail_patrat	
	comparare punct_x, punct_y, barca6_x, barca6_y, q, ok_barca_6 
	cmp q, 0
	jne fail_patrat

	
	mov eax, punct_x
    mov ebx, 100
    div ebx	
	mov esi, eax

	mov eax, punct_y 
	mov ebx, 100
	div ebx
	mov ebx, 9 
	mul ebx
    mov ebx, eax

    cmp m[esi][ebx], 1
    je fail_patrat
	
	mov m[esi][ebx], 1
	
	inc counter_ratari
    ratari counter_ratari
	colorare_patrat capacitate, punct_x, punct_y, 0FFh ; albastru
    
fail_patrat:
endm

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; functia de desenare - se apeleaza la fiecare click
; sau la fiecare interval de 200ms in care nu s-a dat click
; arg1 - evt (0 - initializare, 1 - click, 2 - s-a scurs intervalul fara click)
; arg2 - x
; arg3 - y
draw proc
	push ebp
	mov ebp, esp
	pusha
	
	mov eax, [ebp+arg1]
	cmp eax, 1
	jz evt_click
	cmp eax, 2
	jz evt_timer ; nu s-a efectuat click pe nimic
	
	;mai jos e codul care intializeaza fereastra cu pixeli albi
	mov eax, area_width
	mov ebx, area_height
	mul ebx
	shl eax, 2
	push eax
	push 255
	push area
	call memset
	add esp, 12
	jmp afisare_litere
	
evt_click:
		 
		 ;  coord click ului          marimea zonei unde se coloreaza
   zona_click [ebp+arg2], [ebp+arg3], counter_ratari, counter_nedescoperite, counter_scufundate  


  
jmp afisare_litere
	
	
		evt_timer:
			inc counter
	
afisare_litere:
	
	ratari counter_ratari
	vaporase_nedescoperite counter_nedescoperite 
	vaporase_scufundate counter_scufundate 
	
	
	
	;scriem un mesaj
	make_text_macro 'V', area, 410, 10
	make_text_macro 'A', area, 420, 10
	make_text_macro 'P', area, 430, 10
	make_text_macro 'O', area, 440, 10
	make_text_macro 'R', area, 450, 10
	make_text_macro 'A', area, 460, 10
	make_text_macro 'S', area, 470, 10
	make_text_macro 'E', area, 480, 10
	
	make_text_macro 'M', area, 710, 670
	make_text_macro 'O', area, 720, 670
	make_text_macro 'S', area, 730, 670
	make_text_macro 'I', area, 740, 670
	make_text_macro 'L', area, 750, 670
	make_text_macro 'A', area, 760, 670
	make_text_macro ' ', area, 770, 670
	make_text_macro 'L', area, 780, 670
	make_text_macro 'U', area, 790, 670
	make_text_macro 'C', area, 800, 670
	make_text_macro 'I', area, 810, 670
	make_text_macro 'A', area, 820, 670
	make_text_macro 'N', area, 830, 670
	make_text_macro 'A', area, 840, 670
	
; coord_x = 300
; coord_y = 100   GRILA
; lungime = 600
; latime = 500

	linie_orizontala 600, 300, 100, 0  
	linie_verticala  500, 300, 100, 0  
	linie_orizontala 600, 300, 600, 0 
	linie_verticala  500, 900, 100, 0 
   
	linie_verticala  500, 400, 100, 0
	linie_verticala  500, 500, 100, 0
	linie_verticala  500, 600, 100, 0
	linie_verticala  500, 700, 100, 0
	linie_verticala  500, 800, 100, 0
	
	linie_orizontala 600, 300, 200, 0 
	linie_orizontala 600, 300, 300, 0
	linie_orizontala 600, 300, 400, 0
	linie_orizontala 600, 300, 500, 0


	
	
	make_text_macro 'R', area, 100, 130
	make_text_macro 'A', area, 110, 130
	make_text_macro 'T', area, 120, 130
	make_text_macro 'A', area, 130, 130
	make_text_macro 'R', area, 140, 130
	make_text_macro 'I', area, 150, 130
	                patrat 60, 100, 160, 0FF0000h
	
	
	make_text_macro 'V', area, 30, 280
	make_text_macro 'A', area, 40, 280
	make_text_macro 'P', area, 50, 280
	make_text_macro 'O', area, 60, 280
	make_text_macro 'R', area, 70, 280
	make_text_macro 'A', area, 80, 280
	make_text_macro 'S', area, 90, 280
	make_text_macro 'E', area, 100, 280
	make_text_macro ' ', area, 110, 280
    make_text_macro 'S', area, 120, 280
	make_text_macro 'C', area, 130,280
	make_text_macro 'U', area, 140, 280
	make_text_macro 'F', area, 150, 280
	make_text_macro 'U', area, 160, 280
	make_text_macro 'N', area, 170, 280
	make_text_macro 'D', area, 180, 280
	make_text_macro 'A', area, 190, 280
	make_text_macro 'T', area, 200, 280
	make_text_macro 'E', area, 210, 280
					patrat 60, 100, 310, 0FF00h
	
	make_text_macro 'V', area, 30, 420
	make_text_macro 'A', area, 40, 420
	make_text_macro 'P', area, 50, 420
	make_text_macro 'O', area, 60, 420
	make_text_macro 'R', area, 70, 420
	make_text_macro 'A', area, 80, 420
	make_text_macro 'S', area, 90, 420
	make_text_macro 'E', area, 100, 420
	make_text_macro ' ', area, 110, 420
	make_text_macro 'N', area, 120, 420
	make_text_macro 'E', area, 130, 420
	make_text_macro 'D', area, 140, 420
	make_text_macro 'E', area, 150, 420
	make_text_macro 'S', area, 160, 420
	make_text_macro 'C', area, 170, 420
	make_text_macro 'O', area, 180, 420
	make_text_macro 'P', area, 190, 420
	make_text_macro 'E', area, 200, 420
	make_text_macro 'R', area, 210, 420
	make_text_macro 'I', area, 220, 420
	make_text_macro 'T', area, 230, 420
	make_text_macro 'E', area, 240, 420
					patrat 60, 100, 450, 0FFh



	
final_draw:
	popa
	mov esp, ebp
	pop ebp
	ret
draw endp

random macro barca_x, barca_y
 local repeta
 
repeta:
    ; pt lungime (poate sa fie 300, 400, 500, 600, 700, 800)
	call rand; eax <- nr. random
	mov ebx, 6
	div ebx; edx <- eax % 6
	add edx, 3
    
	mov esi, edx ;pentru parcurgerea liniilor
   
   ;pt latime (poate sa fie 100, 200, 300, 400, 500)
	 
	call rand; eax <- nr. random
	mov ebx, 5
	div ebx; edx <- eax % 5
	add edx, 1
	mov ecx, edx
	
	mov eax, edx
	mov ebx, 9  
    mul ebx
	mov ebx, eax  ;pentru parcurgerea coloanelor	
	
	
	; verifica daca cele doua numere au mai fost alese, prin repetat
	cmp m[esi][ebx], 1
	je repeta
	
	mov m[esi][ebx], 1

	mov eax, esi ; in esi a fost salvat x
	mov ebx, 100
	mul ebx; eax <- rezultatul
	
	mov barca_x, eax
   
   	mov eax, ecx  ; in ecx a fost salvat y
	mov ebx, 100
	mul ebx; eax <- rezultatul
	
	mov barca_y, eax
   	
endm


start:
    ; generarea vaporaselor
	
	push ebx

    push 0
    call time                ; EAX=time(0)
    add esp, 4
	
    push eax                
    call srand               ; srand(time(0))
    add esp, 4
	
	random barca1_x, barca1_y
	random barca2_x, barca2_y
	random barca3_x, barca3_y
	random barca4_x, barca4_y
    random barca5_x, barca5_y
    random barca6_x, barca6_y	
	
	; push barca1_y
	; push barca1_x
	; push offset format_afisare
    ; call printf
	; add esp, 12
	; push barca2_y
	; push barca2_x
	; push offset format_afisare
    ; call printf
	; add esp, 12
	; push barca3_y
	; push barca3_x
	; push offset format_afisare
    ; call printf
	; add esp, 12
	; push barca4_y
	; push barca4_x
	; push offset format_afisare
    ; call printf
	; add esp, 12
	; push barca5_y
	; push barca5_x
	; push offset format_afisare
    ; call printf
	; add esp, 12
	; push barca6_y
	; push barca6_x
	; push offset format_afisare
    ; call printf
	; add esp, 12
	
	
	;alocam memorie pentru zona de desenat
	mov eax, area_width
	mov ebx, area_height
	mul ebx
	shl eax, 2
	push eax
	call malloc
	add esp, 4
	mov area, eax
	;apelam functia de desenare a ferestrei
	; typedef void (*DrawFunc)(int evt, int x, int y);
	; void __cdecl BeginDrawing(const char *title, int width, int height, unsigned int *area, DrawFunc draw);
	push offset draw
	push area
	push area_height
	push area_width
	push offset window_title
	call BeginDrawing
	add esp, 20
	
	;terminarea programului
	push 0
	call exit
end start

 ; author: Erik Matovic

print MACRO text
    mov ax, seg data        ; adress of DATA SEGMENT into AX register
    mov ds, ax              ; move segment address into data segment
    mov ah, 9
    mov dx, offset text
    int 21h    
ENDM
print_new_line MACRO
    mov dl, 10
    mov ah, 02h
    int 21h
    mov dl, 13
    mov ah, 02h
    int 21h
ENDM
file_open MACRO file
    mov ah, 3dh                 ; MS DOS service for a opening file
    mov al, 0                   ; al = 0 is for read only
    mov dx, offset file
    int 21h
    jc open_error
ENDM
file_read MACRO
    mov bx, file_handle         ; MS-DOS is expectint file_handle in BX register
    mov cx, 1                   ; buffsize
    mov dx, offset buffer       ; save relative address of buffer into dx
    mov ah, 3fh                 ; read from file using a file_handle
    int 21h
    ;jc read_error
ENDM
move_file_ptr MACRO low, high, move
	mov ah, 42h                 ; MS-DOS service for moving file pointer
    mov al, move                   ; al = move means file pointer from 0(start), 1(current), 2(end)
	mov bx, file_handle         ;
	mov cx, low                 ; offset, low
	mov dx, high                ; offset, high
	int 21h 
    ;jnc ENDM
    ;jmp file_ptr_error
ENDM
file_print MACRO file
    mov ax, seg file
    mov ds, ax
    mov dx, offset file
    mov ah, 09h
    int 21h
ENDM

file_close MACRO 
    mov ah, 3eh                 ; MS DOS service for closing a file
    mov bx, file_handle
    int 21h
ENDM
cursor MACRO x, y
    mov dh, x
    mov dl, y
    mov ah, 02h
    int 10h                     ; interupt for video BIOS
ENDM
clean_screen MACRO
    mov ax, 0003h
    int 10h 
ENDM
keyboard_input MACRO
    mov ah, 00h
    int 16h 
ENDM
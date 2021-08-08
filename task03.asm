;   Task as external procedure.
;   author: Erik Matovic.

model compact

.STACK 100h

include macro.asm

DATA    SEGMENT
;fname           DB      20 DUP(?), 0        ;'_64.TXT',0
fname           DB      '_64.txt', 0
file_msg        DB      '_64.txt', '$'
path_msg        DB      'Path to the file: ', '$'
offset_address  DB      82h
file_handle     DW      0      ; the file handle - the number that DOS assigns to the open file
length_high     DW      0      ; max lenght of a file
counter         DW      0      ; count number of changes
file_ptr        DW      0      ; current file pointer
reverse_flag    DW      0      ; flag when switch is '-r'
pagging_flag    DW      0      ; flag when switch is '-p'
page_constant   DW      1660   ; pagging after 1840 character is displayed
buffer          DB      ?, '$'
counter_msg     DB      'Number of changes: $'
open_err_msg    DB      'Error while opening a file.$'
read_err_msg    DB      'Error while reading a file.$'
file_move_msg   DB      'Error while moving a file ptr.$'
bad_switch_msg  DB      'Wrong switch entered!$'
info_txt        DB      'Changes little letters to upper. Prints number of changes.$'
help_txt        DB      'Switch -h is for help print.$'
pagging_txt     DB      'Switch -p is for pagging.$'
reverse_txt     DB      'Switch -r is for reverse print.$'
rp_txt          DB      'Switch -rp is for reverse pagging.$'
author_txt      DB      'Erik Matovic.$'
DATA    ENDS

PUBLIC task03 
CODE    SEGMENT
    assume  CS:CODE, DS:DATA   ; assume directive tells the assembler what segment register are going to be used to access a segment
TASK03 PROC FAR
    mov dx, 81h                ; load arguments into dx 
    mov bx, dx                 
    mov dl, ds:[82h]           ; assign dl address 82h from data segment
    cmp dl, '-'                ; check if first char of argument is '-'
    jz switch_argument         ; argument is equal to '-'
    ;jmp get_file
    jmp task
switch_argument:
    mov dl, ds:[83h]           ; assign dl address 83h from data segment
    cmp dl, 'h'                ; check if second char of argument is 'h'
    jnz check_r
    jmp help_info               ; program switch is '-h' for help
check_r:
    cmp dl, 'r'                ; check if second char of argument is 'r'
    jnz check_p
    jmp reverse                 ; program lists output in reverse order
check_p:
    cmp dl, 'p'                ; check if second char of argument is 'p'
    jz go_for_pagging          ; program waits for user input if screen is full
    jmp bad_switch
go_for_pagging:
    jmp pagging
get_file:
    mov ax, seg data
    mov ds, ax
    mov dl, 81h                ; ptr at first char
    mov bl, byte ptr dl
    cmp byte ptr bl, 0D
    jnz read_char
    jmp switch_task
read_char:
    mov fname, byte ptr dl
    add dl, 1
    jmp get_file
help_info:
    mov dl, ds:[84h]           ; assign dl address 84h from data segment
    cmp dl, 0Dh                ; check if third char of an argument is empty
    jz help_print
    jmp bad_switch             ; if not, it is a wrong switch
help_print:    
    print info_txt
    print_new_line
    print help_txt
    print_new_line
    print pagging_txt
    print_new_line
    print reverse_txt
    print_new_line
    print rp_txt
    print_new_line
    print author_txt
    print_new_line
    jmp exit_task03
reverse:
    mov dl, ds:[84h]           ; assign dl address 84h from data segment to check for p as pagging
    cmp dl, 'p'                ; check if third char of argument is 'p'
    jnz set_reverse
    jmp set_reverse_pagging
set_reverse:
    mov ax, seg data
    mov ds, ax
    mov reverse_flag, 1
    jmp switch_task
pagging:
    mov ax, seg data
    mov ds, ax
    mov pagging_flag, 1
    jmp switch_task
bad_switch:
    print bad_switch_msg
    print_new_line   
    jmp exit_task03
set_reverse_pagging:
    mov ax, seg data
    mov ds, ax
    mov reverse_flag, 1
    mov pagging_flag, 1
    jmp switch_task
task:
    ;add bl, byte ptr ds:[81h]
	;mov byte ptr [bx], 0
    mov ax, seg data
    mov ds, ax
switch_task:
    file_open fname
    mov file_handle, ax        ; save file_handle 
    move_file_ptr 0, 0, 2      ; go to the end of an file and get size of an file   
    cmp reverse_flag, 1
    jz reverse_setup
    mov length_high, ax        ; save length of an file into length_high 
    add length_high, 1         ; increment to work correctly with last character
    mov file_ptr, dx
    move_file_ptr 0, 0, 0      ; set file pointer to the start
    jmp reading
reverse_setup:            
    mov file_ptr, ax           ; save length of an file into file_ptr 
    mov length_high, -2        ; set length_high to work correctly with last character
    jmp reading
open_error:
    print_new_line
    print open_err_msg
    jmp exit_task03
read_error:
    file_close
    print_new_line
    print read_err_msg
    jmp exit_task03
file_ptr_error:
    file_close
    print_new_line
    print file_move_msg
    jmp exit_task03
reading:
    cmp pagging_flag, 0
    jz reading_no_pagging
    mov dx, 0
    mov ax, file_ptr
    mov bx, page_constant
    div bx
    cmp dx, 0
    jz user_input
    jmp reading_no_pagging
user_input:
    keyboard_input
    print path_msg
    print file_msg
    print_new_line
reading_no_pagging:
    file_read
    cmp reverse_flag, 0       ; not reverse
    jz standard_reading
    jmp reverse_reading
standard_reading:
    add file_ptr, 1
reading_setup:
    mov dx, length_high
    cmp file_ptr, dx
    jz program_end
    mov al, buffer
    cmp al, 65                 ; ASCII value 65 is 'A', so ignore all char less than 65
    jb uppercase
    cmp al, 122                ; ASCII value 122 is 'z', so ignore all char greater than 122
    ja uppercase
    sub al, 'A'
    cmp al, 'Z'-'A'            ; check if letter is upercase
    jbe uppercase
    sub buffer, 32             ; convert letter to lowercase
    add counter, 1             ; increment counter
uppercase:
    print buffer               ; print letter
    move_file_ptr 0, file_ptr, 0              ; update file pointer for next reading
    jmp reading
program_end:
    file_close
    print_new_line
    print counter_msg
    mov ax, counter
    call print_number ;counter
    jmp exit_task03      
reverse_reading:
    sub file_ptr, 1
    jmp reading_setup
exit_task03:
    mov ax, 4c00h              ; service for program exit
    int 21h
    RET
    ENDP           
print_number PROC ;number
    ;mov ax, number      
    mov cx, 0                   ; initilize count
    mov dx, 0 
get_digits: 
    cmp ax, 0               ; if ax is zero  
    je number_print        
    mov bx, 10              ; initilize bx to 10, because of dividing     
    div bx                  ; extract the last digit 
    push dx                 ; push dx in the stack 
    inc cx                  ; increment the count   
    xor dx, dx              ; set dx to 0
    jmp get_digits 
number_print:   
    cmp cx, 0               ; check if count is greater than zero
    je exit_procedure                 
    pop dx                  ; pop the top of stack  
    add dx,48               ; add 48 to represent the ASCII value of digits
    mov ah,02h 
    int 21h                 ; interuppt to print a character 
    dec cx                  ; decrease the count 
    jmp number_print 
exit_procedure:
    RET
    ENDP                  
CODE ENDS                            
END TASK03

;   Changes little letters to upper. Prints number of changes.
;   Switch -h is for help print.
;   author: Erik Matovic.

;model compact

include macro.asm 

EXTRN TASK03:FAR                 

CODE    SEGMENT                  
    assume  CS:CODE
start:
    clean_screen
    cursor 0, 0        
    call TASK03
exit:
    mov ax, 4c00h              ; service for program exit
    int 21h                    ; interuput
CODE ENDS                            
END start

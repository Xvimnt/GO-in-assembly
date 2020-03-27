printStr macro aString
    mov ah,9h
    lea dx,aString
    int 21h
endm

printChar macro var
    mov ah,2h
    mov dl, var
    int 21h
    mov ah,0
endm

getFinalCount macro
    local lp, wtCnt,contLp
    mov x,0
    mov y,0
    mov si,0
    lp:
        cmp table[si],2
        jne wtCnt
        inc x
        jmp contLp
        wtCnt:
        cmp table[si],1
        jne contLp
        inc y
        contLp:
        inc si
        cmp si,64
        jl lp
    add x,'0'
    add y,'0'
    mov al,x
    mov ah,y
    mov blackCount[19], al
    mov whiteCount[20], ah
endm

getDate MACRO
    MOV AH, 2AH ;
    INT 21H

    MOV x, DL
    MOV y, DH

    MOV AL, x
    AAM ;AX SE CONVIERTE A BCD
    ADD AL, '0'
    MOV finalDate[1], AL
    ADD AH, '0'
    MOV finalDate[0], AH

    MOV AL, y
    AAM
    ADD AL, '0'
    MOV finalDate[4], AL
    ADD AH, '0'
    MOV finalDate[3], AH

ENDM

getHour macro
    mov ah,2ch
    int 21h

    mov x,ch
    mov y,cl

    mov al,x
    aam
    add al,'0'
    mov finalHour[1],al
    add ah,'0'
    mov finalHour[0],ah

    mov al,y
    aam
    add al,'0'
    mov finalHour[4],al
    add ah,'0'
    mov finalHour[3],ah

    mov x,dh
    mov al,x
    aam
    add al,'0'
    mov finalHour[7],al
    add ah,'0'
    mov finalHour[6],ah
endm

readChar macro var
    mov ah,1h
    int 21h
    mov var,al
endm

begin macro
    mov ax, @data
    mov ds,ax
endm

cmpString macro slots
    mov cx,slots   ;Determinamos la cantidad de datos a leer/comparar
    mov AX,DS  ;mueve el segmento datos a AX
    mov ES,AX  ;Mueve los datos al segmento extra
endm

readString macro bufVar
    mov ah, 0Ah ;SERVICE TO CAPTURE STRING FROM KEYBOARD.
    mov dx, offset bufVar
    int 21h 
endm

exit macro
    mov   ax,4c00h; Function (Quit with exit code (EXIT))
    int   21h; Interruption DOS Functions
endm

saveRowAndCol macro
    lea si,buff + 2 
    mov cl,[si]
    mov selectedCol,cl
    inc si
    mov cl,[si]
    mov selectedRow,cl
endm

calculateIndex macro
    ;cambiando el index de la tabla
    sub selectedCol, 97
    sub selectedRow, '0'
    ;para ir en modo decresivo
    mov cl, 8
    sub cl, selectedRow
    mov selectedRow, cl
    mov al, 8
    mul selectedRow
    ;calculando el inidice con la fila y la columna
    mov cl,al
    add cl,selectedCol
    ;guardando el index
    mov ch,0
    mov si,cx
endm


verifyRowAndCol macro
    local invalidMovement, makeMov
    ;viendo si el movimiento es lexicamente aceptable
    cmp selectedCol, 'a'
    jl invalidMovement
    cmp selectedCol, 'h'
    jg invalidMovement
    cmp selectedRow, '1'
    jl invalidMovement
    cmp selectedRow, '8'
    jg invalidMovement
    jmp makeMov
    invalidMovement:
        printStr invalidMov
        switchTurn
    makeMov:
endm

switchReservedWords macro
    local beginTurn, exitL, saveState,exitF
    compareReservedWord showStr
    je mkReport
    compareReservedWord pass
    je beginTurn
    compareReservedWord extStr
    je exitF
    compareReservedWord savStr
    je saveState
    ;si no es reservada me pone la ficha
    jmp validateMov
    ;saveRowAndCol
    beginTurn:
    inc passTurn
    cmp passTurn, 2
    je exitL
    neg turn
    switchTurn
    exitL:
    mov flag,1
    mkReport:
    call writeReport
    exitF:
    exit
    saveState:
      printStr saveMsg
      ;just to display the string
      readString fileName
      fixString
      createFile 
      switchTurn

endm

compareReservedWord macro name
    cmpString 5
    lea si,buff + 2  ;cargamos en si la cadena que contiene vec
    lea di,name ;cargamos en di la cadena que contiene vec2
    repe cmpsb 
endm

putPiece macro piece
    local blackPiece, goToD
    ;viendo en que turno estamos
    cmp turn,1
    je blackPiece
    ;poniendo una ficha blanca
    mov table[si],1
    jmp goToD
    ;poniendo una ficha negra
    blackPiece:
    mov table[si],2
    goToD:
    ;si tiene enemigos adyacentes buscar si siguen libres
    ;searchEnemies
    mov passTurn,0
endm


isValidMov macro
    ;;BUSCAR ENEMIGOS RESPECTO AL TURNO
    ;-1 = BLANCAS , 1=NEGRAS
    ;FICHAS 0 = VACIO, 1 = BLANCA, 2= NEGRA
    ;si es 1 turno, marcar solo a 1
    ;si es -1 turno, marcar solo a 2
    ;si son diferentes son enemigas
    cmp turn,1
    je movOneToCh
    mov ch,2
    jmp VALIDATE_EMPTY
    movOneToCh:
    mov ch,1
    VALIDATE_EMPTY:
    ;ver si esta vacio
    cmp table[si],0
    jne ISINVALIDFLAG

    VALIDATE_SUICIDE:
    ;ver si no es sucidio
    ;;Validar esquinas
    ;esquinas 56,63,0,7
    ESQ3:
    cmp si,56
    jne ESQ4
    cmp table[57],ch
    jne ISVALIDFLAG
    cmp table[48],ch
    jne ISVALIDFLAG
    jmp ISINVALIDFLAG
    ESQ4:
    cmp si,63
    jne ESQ1
    
    cmp table[55],ch
    jne ISVALIDFLAG
    cmp table[62],ch
    jne ISVALIDFLAG
    jmp ISINVALIDFLAG
    ESQ1:
    cmp si,0
    jne ESQ2
    cmp table[8],ch
    jne ISVALIDFLAG
    cmp table[1],ch
    jne ISVALIDFLAG
    jmp ISINVALIDFLAG
    ESQ2:
    cmp si,7
    jne VALIDATE_BORDS
    cmp table[15],ch
    jne ISVALIDFLAG
    cmp table[6],ch
    jne ISVALIDFLAG
    
    ISINVALIDFLAG:
    jmp ISINVALID
    ISVALIDFLAG:
    jmp ISVALID
    ;Validar los bordes
    VALIDATE_BORDS:
    cmp si,55
    jl VALIDATEABOVE
    cmp table[SI + 1],ch
    jne ISVALID
    cmp table[SI - 1],ch
    jne ISVALID
    cmp table[SI - 8],ch
    jne ISVALID
    jmp ISINVALID
    VALIDATEABOVE:
    cmp si,8
    jg VALIDATE4POS
    cmp table[SI + 1],ch
    jne ISVALID
    cmp table[SI - 1],ch
    jne ISVALID
    cmp table[SI + 8],ch
    jne ISVALID
    jmp ISINVALID
    VALIDATE4POS:
    cmp table[SI + 1],ch
    jne ISVALID
    cmp table[SI - 1],ch
    jne ISVALID
    cmp table[SI + 8],ch
    jne ISVALID
    cmp table[SI - 8],ch
    jne ISVALID
    ISINVALID:
    printStr invalidTryAgain
    switchTurn
    ISVALID:
endm

switchTurn macro
    local readBlack, readSt
    cmp turn,1
    je readBlack
    ;leyendo color blanco
    printStr whiteTurn
    jmp readSt
    ;leyendo negro
    readBlack:
    printStr blackTurn
    ;leyendo la entrada
    readSt:
    readString buff  
    jmp saveIndex
endm

fixString macro
    lea si, fileName + 1 ;NUMBER OF CHARACTERS ENTERED.
    mov cl, [ si ] ;MOVE LENGTH TO CL.
    mov ch, 0      ;CLEAR CH TO USE CX. 
    inc cx ;TO REACH CHR(13).
    add si, cx ;NOW SI POINTS TO CHR(13).
    mov al, 0
    mov [ si ], al ;REPLACE CHR(13) BY '0'.  
endm

readGame macro
    ;leyendo tabla
    mov bx, index
    mov cx, 64
    lea dx, table
    mov ah,3fh
    int 21h
    ;leyendo turno
    mov bx, index
    mov cx, 1
    lea dx, turn
    neg turn
    closeFile
endm

closeFile macro
    mov bx, index
    mov ah,3eh
    int 21h
endm

openFile macro 
 mov ah,3dh
 mov al,0
 lea dx,fileName[2]
 int 21h
 mov index,ax
endm

writeGame macro
    ;en index ira mi manejador del archivo
    mov index,ax
    mov ah,40h
    mov bx,index
    lea dx, table
    mov cx,64
    int 21h
    ;guardar el turno
    mov ah,40h
    mov bx,index
    lea dx,turn
    mov cx,1
    int 21h
endm

createfile macro 
    mov ah,3ch
    mov cx,0
    lea dx, fileName[2]
    int 21h
    writeGame
    closeFile
endm
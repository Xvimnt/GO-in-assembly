INCLUDE Macros.asm
.model small
.stack 100h

.data
   finalDate db "00/00/2020 "
   finalHour db "00:00:00</h1>",13
   blackCount db "<h3>Fichas Negras: 0 </h3>";19 
   whiteCount db "<h3>Fichas Blancas: 0 </h3>";20 
   blackWinner db "<h1>El ganador es: Piezas negras</h1>"
   WhiteWinner db "<h1>El ganador es: Piezas blancas</h1>"
   ;Reporte primero en la pos 1009 meter la tabla
   htmlReport db "<!DOCTYPE html>"
            db'<html lang="es">' ,13
            db  "<head>"    ,13
            db   "<title>201700831</title>",13
            db   '<meta charset="UTF-8">'  ,13
            db   '<STYLE type="text/css">',13
            db    "#capa1{",13
            db      " position:absolute;",13
            db      "z-index:1;",13
            db       "background-color:#FFFFFF;",13
            db       "top:25px;",13
            db      "left:25px;",13
            db      "width:10px;",13
            db      "height:12px;",13
            db     "}",13
            db     "#capa2{",13
            db       "position:absolute;",13
            db       "z-index:0;",13
            db     "}",13
            db      "TABLE{",13
            db       "table-layout: fixed;",13
            db      "width: 250px;",13
            db     "}",13
            db     "TD, TR {",13
            db       "width: 45px;",13
            db       "height: 44PX;",13
            db      " word-wrap: break-word;",13
            db     "}",13
            db     "#capa{",13    
            db       "width: 46px;",13
            db       "height: 42px;",13
            db       "top: 0px;",13
            db      "left: 0px;",13
            db    "}",13
            db     "#foot{position: fixed; top: 420px;}",13
            db    "</STYLE>" ,13
            db "</head>" ,13
            db "<body>",13
            db   '<div id="capa2" style="position:absolute; width:300px;',13
            db    'height:100px; top: 0px; left: 0px">',13
            db   '<img src="tablero.jpg" width="440" height="440">',13
            db    "</div>"        ,13
            db   '<div id="capa1">',13
            db     "<TABLE>"

   htmlReport2   db     "</TABLE>"  ,13
            db   "</div>",13
            db   '<div id="foot">',13
            db    "<h1>"

   htmlReport3 db  "</div>",13
               db "</body>" ,13
               db "</html>$"
      html_r  db "<TR>",13
      html_rc db "</TR>",13
      html_re db "<TD></TD>",13 ; 11
      html_white db '<TD> <img id="capa" src="whitePiece.png">',13
      html_black db '<TD> <img id="capa" src="blackPiece.png">',13
      html_cont db 3874 dup ('$')
      hmtl_name db 'estadoTablero.html$',0

   ;Variables para el tablero
   ;1 = Ficha blanca, 2 = Ficha negra
   table db 0, 0, 0, 0, 0, 0, 0, 0
         db 0, 0, 0, 0, 0, 0, 0, 0
         db 0, 0, 0, 0, 0, 0, 0, 0
         db 0, 0, 0, 0, 0, 0, 0, 0
         db 0, 0, 0, 0, 0, 0, 0, 0
         db 0, 0, 0, 0, 0, 0, 0, 0
         db 0, 0, 0, 0, 0, 0, 0, 0
         db 0, 0, 0, 0, 0, 0, 0, 0
   tableBackend db 0, 0, 0, 0, 0, 0, 0, 0
                db 0, 0, 0, 0, 0, 0, 0, 0
                db 0, 0, 0, 0, 0, 0, 0, 0
                db 0, 0, 0, 0, 0, 0, 0, 0
                db 0, 0, 0, 0, 0, 0, 0, 0
                db 0, 0, 0, 0, 0, 0, 0, 0
                db 0, 0, 0, 0, 0, 0, 0, 0
                db 0, 0, 0, 0, 0, 0, 0, 0
   colIndexes  db 32, 32, 32, 32, 'A' 
               db 32, 32, 32, 32, 'B'
               db 32, 32, 32, 32, 'C' 
               db 32, 32, 32, 32, 'D' 
               db 32, 32, 32, 32, 'E' 
               db 32, 32, 32, 32, 'F' 
               db 32, 32, 32, 32, 'G'
               db 32, 32, 32, 32, 'H$'  
   row db 32, 32,'--',32,'$'
   col db '|' ,32 ,32, 32,32,  '$'
   blackPiece db 'FN',32,'--', '$'
   whitePiece db 'FB',32,'--', '$'
   ;variables para manipular el juego
   ;1 para la negra y 0 para la blanca
   turn db 1
   passTurn db 0
   selectedRow db ?
   selectedCol db ?
   isDead db 10,13,'Esta atrapado$'
   ;Comandos especiales
   savStr db 'save',13
   pass db 'pass',13
   extStr db 'exit',13
   showStr db 'show',13
   ;output para el usuario
   htmlMsg db 10,13, 'Se ha generado el reporte html$'
   saveMsg db 10,13,'Ingrese nombre para guardar: $'
   blackTurn db 10,13,'Turno de las negras: $'
   whiteTurn db 10,13, 'Turno de las blancas: $'
   flag db 0
   ;para leer la string del usuario
   buff     db  5        ;MAX NUMBER OF CHARACTERS ALLOWED (25).
            db  ?         ;NUMBER OF CHARACTERS ENTERED BY USER.
            db  5 dup('$') ;CHARACTERS ENTERED BY USER.
   fileName db  10        ;MAX NUMBER OF CHARACTERS ALLOWED (25).
            db  ?         ;NUMBER OF CHARACTERS ENTERED BY USER.
            db  10 dup(0) ;CHARACTERS ENTERED BY USER.
   ;Variables para el menu
   x db ?
   y db ?
   newSpace db 32,'$'
   index dw ?
   newLine db 10, 13, '$'
   exiting db 10,13, '...Cerrando juego...$'
   loadGameSt db 10,13, 'Ingrese nombre de la partida guardada: $'
   invalidTryAgain db 10, 13, 'Movimiento no permitido, intentelo de nuevo$'
   invalidMov db 10,13, 'Movimiento invalido: Solo letras de la "a" a la "h" (minusculas) y numeros del 1 al 8',10,13,'$'
   invalidChoice db 10,13, 'Eleccion invalida: Numero del 1 al 3:', 13,10,'$'
   header db 10, 13, 'UNIVERSIDAD DE SAN CARLOS DE GUATEMALA', 13, 10 , 'FACULTAD DE INGENIERIA', 13, 10
          db  'CIENCIAS Y SISTEMAS', 13, 10 , 'ARQUITECTURA DE COMPUTADORAS Y ENSAMBLADORES 1', 13, 10
          db  'NOMBRE: JAVIER ALEJANDRO MONTERROSO', 13, 10 , 'CARNET: 201700831', 13, 10, 'SECCION: A', 13,10, "$"
   menu db 10,13, '1) Iniciar Juego', 10, 13, '2) Cargar juego', 10,13, '3) Salir', 10,13, '$'
.code
 

finalReport proc
   getFinalCount
   mov ah,40h
   mov bx,index
   lea dx, blackCount
   mov cx,26
   int 21h
   mov ah,40h
   mov bx,index
   lea dx, whiteCount
   mov cx,27
   int 21h
   mov y,al
   cmp x,al
   jl dispBlackWinner
   mov ah,40h
   mov bx,index
   lea dx, WhiteWinner
   mov cx,38
   int 21h
   jmp finalRepWrite
   dispBlackWinner:
   mov ah,40h
   mov bx,index
   lea dx, blackWinner
   mov cx,37
   int 21h
   mov ah,40h
   mov bx,index
   lea dx, htmlReport3
   mov cx,22
   int 21h
   closeFile
   exit
finalReport endp

writeReport proc
   mov ah,3ch
    mov cx,0
    lea dx, hmtl_name
    int 21h
   ;en index ira mi manejador del archivo
    mov index,ax
    mov ah,40h
    mov bx,index
    lea dx, htmlReport
    mov cx,658
    int 21h

    mov si,0
    mov y,0
    doW:
        ;Escribiendo la apertura de uan fila
        mov ah,40h
        mov bx,index
        lea dx,html_r
        mov cx,5
        int 21h
        ;for de 8
        mov x,0
        ;este ciclo escribe columnas
        doWC:
            cmp table[si],0
            jne callBlackHtml
            ;Escribiendo una ficha vacia
            mov ah,40h
            mov bx,index
            lea dx, html_re
            mov cx,10
            int 21h
            jmp finHtml
            callBlackHtml:
            cmp table[si],2
            jne callWhiteHtml
            ;Escribiendo una ficha negra
            mov ah,40h
            mov bx,index
            lea dx, html_black
            mov cx,42
            int 21h
            jmp finHtml
            callWhiteHtml:
            ;Escribiendo una ficha blanca
            mov ah,40h
            mov bx,index
            lea dx, html_white
            mov cx,42
            int 21h
            finHtml:
            inc si
            inc x
            cmp x,8
            jl doWC
        ;Escribiendo la cerradura de uan fila
        mov ah,40h
        mov bx,index
        lea dx, html_rc
        mov cx,6
        int 21h
        inc y
        cmp y,8
        jl doW
   ;Escribiendo el final
      mov ah,40h
      mov bx,index
      lea dx, htmlReport2
      mov cx,36
      int 21h
   ;escribiendo la fecha
   getDate
   mov ah,40h
   mov bx,index
   lea dx, finalDate
   mov cx,11
   int 21h
   ;escribiendo la hora
   getHour
   mov ah,40h
   mov bx,index
   lea dx, finalHour
   mov cx,14
   int 21h
   ;si la flag es 1 meterle el recuento
   cmp flag,0
   je finalRepWrite
   ;se escribe el reporte final y finaliza
   call finalReport
   finalRepWrite:
   mov ah,40h
   mov bx,index
   lea dx, htmlReport3
   mov cx,22
   int 21h
   closeFile
   neg turn
call PLAY
writeReport endp

DISPLAY_MENU  proc

initialMenu:
   begin
   printStr header

   printStr menu

switchUserInput:
   readChar x; Lee un digito ingresado y lo carga a x
   cmp x, '1'
   jl tryAgain
   cmp x, '3'
   jg tryAgain
   cmp x,'1'
   je PLAY
   cmp x,'2'
   je LOAD
   printStr exiting
   exit

tryAgain:
   printStr invalidChoice
   jmp switchUserInput

DISPLAY_MENU  endp;

LOAD proc
   printStr loadGameSt
   readString fileName
   fixString
   openFile 
   readGame
LOAD endp


PLAY proc

   jmp displayTable
   makeReport:
      call writeReport
      switchTurn
   saveIndex:
      ;Busca si se ingreso alguna palabra reservada
      switchReservedWords
      validateMov:
         saveRowAndCol
         verifyRowAndCol
         calculateIndex
         ;antes de poner ver si esta vacio
         isValidMov
         putPiece
      jmp displayTable
   
   finalRow:
      printStr colIndexes
      neg turn
      switchTurn

   displayTable:
      mov ch, 9
      mov si, 0
      printStr newLine
      printStr newLine

   printRow:
      ;imprimir las 9 filas y empezar nuevo turno
      ;sentencia 
      dec ch
      cmp ch, 0
      je finalRow
      ;imprimiendo numeros
      printStr newSpace
      mov x, ch
      add x ,'0'
      printStr x
      printStr newSpace
      ;imprimiendo fila
      mov cl, 8
      again:
         mov bh, table[si]
         ;imprimiendo fila respecto al valor
         cmp bh, 1
         je switchWhite
         cmp bh, 2
         je switchBlack
         ;si no es negra ni blanca sigue a imprimir vacio
         printStr row
         afterSwitch:
            inc si
            dec cl 
            JNZ  again
      printStr newLine

   printColumn:
      printStr newSpace
      printStr newSpace
      printStr newSpace
      printStr newSpace      
      mov cl, 8
      againCol:
         dec cl 
         printStr col
         JNZ  againCol
      printStr newLine
   jmp printRow

   switchWhite:
      printStr whitePiece
      jmp afterSwitch

   switchBlack:
      printStr blackPiece
      jmp afterSwitch
      
PLAY endp

end DISPLAY_MENU
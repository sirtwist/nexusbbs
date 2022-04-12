{$A+,B-,D-,E+,F-,G-,I-,L+,N-,O-,R-,S+,V+,X+}
{$M 16384,0,655360}
Unit Mouse; { Mouse routines }
Interface
Const
  { For Which Pressed calls }
  LeftB   = $1;
  RightB  = $2;
  MiddleB = $4;
Var
  MouseInstalled: boolean;

{ออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
Procedure GetMousePos(Var X,Y,button: word);
Procedure HideMouseCursor;
Procedure SetMouseCursor(C: char);
Procedure SetMousePos(X,Y: word);
Procedure SetMouseWindow(X1,Y1,X2,Y2: word);
Procedure ShowMouseCursor;
Procedure QueryBtnUp(button: word; var status,times,x,y: word);
Procedure QueryBtnDn(button: word; var status,times,x,y: word);
{ฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ}
Function InitMouse: word;
Function MousePressed: boolean;
Function WhichPressed: word;
{ออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}

Implementation
Const
  MIO = $33; { Mouse Services }

Function MousePressed: boolean; Assembler;
Asm
  Mov Ax, 0003h
  Int MIO
  cmp Bx, 00h { Result is in BX, will be non zero if mouse pressed }
  Je  @No
  mov al, true
  Jmp @End
 @No:
  mov al, false
 @End:
End;

Function WhichPressed: word; Assembler;
Asm
  Mov Ax, 0003h
  Int MIO
  mov ax, bx
End;

Function InitMouse: word; Assembler;
Asm
  Mov ax, 0000h
  Int MIO
  { Result in AX }
End;

Procedure ShowMouseCursor; Assembler;
Asm
  Mov Ax, 0001h
  Int MIO
End;

Procedure HideMouseCursor; Assembler;
Asm
  Mov Ax, 0002h
  Int MIO
End;

Procedure GetMousePos(Var X,Y,Button: word); Assembler;
Asm
  Mov Ax, 0003h
  Int MIO
  { Store the results }
  Les di, button; mov [ES:DI], bx
  Les di, x; mov [ES:DI], cx
  Les di, y; mov [ES:DI], dx
End;

Procedure SetMousePos(X,Y: word); Assembler;
Asm
  Mov Ax, 0004h
  Mov Cx, X
  Mov Dx, Y
  Int MIO
End;

Procedure QueryBtnDn(button: word; var status,times,x,y: word); Assembler;
Asm
  Mov Ax, 0005h
  Mov bx, button
  Int MIO

  { Store what's returned }
  Les di, Status; Mov [ES:DI],ax
  Les di, Times; Mov [ES:DI],bx
  Les di, X; Mov [ES:DI],cx
  Les di, Y; Mov [ES:DI],dx
End;

procedure QueryBtnUp(button: word; var status,times,x,y: word); Assembler;
Asm
  Mov Ax, 0006h
  Mov bx, button
  Int MIO

  { Store what's returned }
  Les di, Status; Mov [ES:DI],ax
  Les di, Times; Mov [ES:DI],bx
  Les di, X; Mov [ES:DI],cx
  Les di, Y; Mov [ES:DI],dx
End;

Procedure SetMouseWindow(X1,Y1,X2,Y2: word); Assembler;
Asm
  { Set X positions }
  Mov ax, 0007h
  Mov cx, x1
  Mov dx, x2
  Int MIO

  { Set Y positions }
  Mov Ax, 0008h
  Mov cx, y1
  Mov dx, y2
  Int MIO
End;

Procedure SetMouseCursor(C: char); Assembler;
asm
  mov  ax, 000Ah
  mov  bx, 0000h
  mov  cx, 7700h
  push ax { Save AX }
  mov  ax, 0077h       { Basically: mov dx, 77h and ordchar }
  and  al, c
  mov  dx, ax
  pop  ax { Restore AX }
  int  mio
end;

Begin
  MouseInstalled := (InitMouse <> 0);
End.

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

Function MousePressed: boolean; // Assembler;
begin
End;

Function WhichPressed: word; // Assembler;
begin
End;

Function InitMouse: word; // Assembler;
begin
End;

Procedure ShowMouseCursor; // Assembler;
begin
End;

Procedure HideMouseCursor; // Assembler;
begin
End;

Procedure GetMousePos(Var X,Y,Button: word); // Assembler;
begin
End;

Procedure SetMousePos(X,Y: word); // Assembler;
begin
End;

Procedure QueryBtnDn(button: word; var status,times,x,y: word); // Assembler;
begin
End;

procedure QueryBtnUp(button: word; var status,times,x,y: word); // Assembler;
begin
End;

Procedure SetMouseWindow(X1,Y1,X2,Y2: word); // Assembler;
begin
End;

Procedure SetMouseCursor(C: char); // Assembler;
begin
end;

Begin
  MouseInstalled := False;
End.

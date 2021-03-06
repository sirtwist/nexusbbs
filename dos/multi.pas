unit Multi;
(*
**
** MULTItasker (timeslice) routines for EleBBS
**
** Copyright (c) 1996, 1997, 1998 by Maarten Bekers
**
** Created : 12-Jul-1998
** Last update : 12-Jul-1998
**
**
*)

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)
 INTERFACE
(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)


Const
  MaxLockRetries : Byte = 10;

Type
  Taskers = (NoTasker, DesqView, DoubleDOS, WindowsTask, WindowsNTTask, OS2, NetWare, IsUnix, NoSlicing);

Var
  MultiTasking: Boolean;
  MultiTasker : Taskers;
  MultiVersion: Word;
  MultiVerMaj : Word;
  MultiVerMin : Word;
  VideoSeg    : Word;
  VideoOfs    : Word;

Const
  MultiString: Array [NoTasker..NoSlicing] of String [9] =
    ('DOS', 'DESQview', 'DoubleDOS', 'Windows', 'Windows', 'OS/2', 'NetWare',
     'Unix', 'NoSlicing');

procedure DoSlice;

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)
 IMPLEMENTATION
(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

{$IFDEF VirtualPascal}
uses VpSysLow;
{$ENDIF}

{$IFDEF WINGUI}
uses Windows;
{$ENDIF}

{$IFDEF MSDOS}
  {$DEFINE USEDOS}
{$ENDIF}

{$IFDEF GO32V2}
  {$DEFINE USEDOS}
{$ENDIF}

{$IFDEF USEDOS}
uses Dos;
{$ENDIF}

{$IFDEF FPC}

 {$IFDEF WIN32}
  uses Windows;
 {$ENDIF}

 {$IFDEF ELEUNIX}
  uses Unix;
 {$ENDIF}

{$ENDIF}

{$IFDEF USEDOS}
procedure GiveTimeSlice;
var Regs: Registers;
begin
  Case MultiTasker of
     NoTasker     : begin
                      Intr($28, Regs);
                    end; { DOS }
     DesqView     : begin
                      Regs.AX := $1000;
                      Intr($15, Regs);
                    end; { DV }
     DoubleDos    : begin
                      Regs.AX := $EE01;
                      Intr($21, Regs);
                    end; { DoubleDOS }
     Os2,
     WindowsTask,WindowsNTTask  : begin
                      Regs.AX := $1680;
                      Intr($2F, Regs);
                    end; { WinOs2Wait }
     Netware      : begin
                      Regs.BX := $000A;
                      Intr($7A, regs);
                    end; { Netware }
  end; { case }
end;    { TimeSlice }
{$ENDIF}

{$IFNDEF USEDOS}
procedure GiveTimeSlice;
begin
 {$IFDEF VirtualPascal}
   SysCtrlSleep(1);
 {$ELSE}
   {$IFNDEF ELEUNIX}
     Sleep(10);
   {$ELSE}
     Select(0, nil, nil, nil, 10);
   {$ENDIF}
 {$ENDIF}
end;
{$ENDIF}

{----------------------------------------------------------------------------}

procedure DoSlice;
begin
  {$IFNDEF VirtualPascal}
     GiveTimeSlice;
  {$ELSE}
     SysCtrlSleep(1);
  {$ENDIF}
end; { proc. DoSlice }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

procedure GetMultiTasker;
{$IFDEF USEDOS}
var Regs: Registers;
{$ENDIF}
begin
  MultiTasker := NoTasker;

  {$IFDEF USEDOS}
  {-------------------- Check wether Windows is running -----------------------}
  FillChar(Regs, SizeOf(Registers), 00);
  Regs.AX := $1600;
  Intr($2F, Regs);
  if (Regs.AL <> $00) AND (Regs.AL <> $80) then
    begin
      Regs.AX:= $160A;
      Intr($2F, Regs);
      MultiVersion := Regs.BX;
      MultiVerMaj:= Regs.BH;
      MultiVerMin:= Regs.BL;
      MultiTasker := WindowsTask;
      EXIT;
    end; { if }

  {-------------------- Check wether WindowsNT is running ---------------------}
  Regs.AX := $3306;
  Intr($21, Regs);
  if Regs.BX = $3205 then
    begin
      Regs.AX:= $160A;
      Intr($2F, Regs);
      MultiVersion := Regs.BX;
      MultiVerMaj:= Regs.BH;
      MultiVerMin:= Regs.BL;
      MultiTasker := WindowsNTTask;
      EXIT;
    end; { if }

  {--------------------- Check wether DoubleDOS is running --------------------}
  Regs.AX := $E400;
  Intr($21, Regs);
  if (Regs.AL <> $00) then
    begin
      MultiTasker := DoubleDOS;
      EXIT;
    end; { if }

  {----------------------- Check wether OS/2 is running -----------------------}
  Regs.AX := $3001;
  Intr($21, Regs);
  if (Regs.AL >= 10) AND (Regs.AH >= 10) then
    begin
      MultiTasker := OS2;
      EXIT;
    end; { if }

  {--------------------- Check wether Desqview is running ---------------------}
  Regs.AX := $2B01;
  Regs.CX := $4445;
  Regs.DX := $5351;
  Intr($21, regs);
  if (Regs.AL <> $FF) then
    begin
      MultiTasker := DesqView;
      EXIT;
    end; { if }

  Regs.AX := $7A00;
  Intr($2F, Regs);
  if Regs.AL = $FF then
    begin
      MultiTasker := Netware;
      EXIT;
    end; { if }
  {$ENDIF}

  {$IFDEF WIN32}
    MultiTasker := WindowsTask;
  {$ENDIF}

  {$IFDEF OS2}
    MultiTasker := OS2;
  {$ENDIF}

  {$IFDEF ELEUNIX}
    MultiTasker := IsUnix;
  {$ENDIF}
end; { proc. GetMultiTasker }

begin
  GetMultiTasker;
End.  { Share }

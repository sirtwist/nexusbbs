{$A+,B-,D-,E+,F-,G-,I+,L+,N-,O-,R-,S+,V+,X+}
{$M 16384,0,655360}
Unit Int2; { Copyright 1994, by John Stephenson }
Interface
Uses Dos, crt;
const
  RBR        = $00;          { 3F8 Receive Buffer offset               }
  THR        = $00;          { 3F8 Transmitter Holding offset          }
  IER        = $01;          { 3F9 Interrupt Enable offset             }
  IIR        = $02;          { 3FA Interrupt Identification offset     }
  LCR        = $03;          { 3FB Line Control offset                 }
  MCR        = $04;          { 3FC Modem Control offset                }
  LSR        = $05;          { 3FD Line Status offset                  }
  MSR        = $06;          { 3FE Modem Status offset                 }
  DLL        = $00;          { 3F8 Divisor Latch Low byte              }
  DLH        = $01;          { 3F9 Divisor Latch Hi byte               }
  CMD8259    = $20;          { Interrupt Controller Command offset     }
  IMR8259    = $21;          { Interrupt Controller Mask offset        }
  BufferSize = 2048;         { Ringbuffer 2 KB in total length         }
Const
  I_Timeout : boolean = false;              { Writeport Timeout counter }
  I_IntMasks: Array[1..8] of byte = ($EF,$F7,$EF,$F7,$EF,$F7,$EF,$F7);
  I_IntVect : Array[1..8] of byte = ($0C,$0B,$0C,$0B,$0C,$0B,$0C,$0B);
  I_CombaseAdr : Array[1..8] of word = ($03F8,$02F8,$03E8,$02E8,$03F8,$02F8,$03E8,$02E8);
Var
  I_comport : word;
  I_Combase : Word;         { Hardware Com-port Base Adress }
  I_baud    : word;
Var
  I_OldCom     : Pointer;
  I_Comhp      : word;         { Buffer Head-Pointer           }
  I_Comtp      : word;         { Buffer Tail-Pointer           }
  I_ComBuffEnd : word;         { Buffer End-Address            }
  I_ComBuff    : Array[0..BufferSize] of byte;
  I_OldExitHandler : Pointer;

{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Procedure I_Blockwriteport(var data; lengthdata: word);
Procedure I_CheckAhead(var c : char; var there : boolean);
Procedure I_Hangup;
Procedure I_Initport(Cp : word; Baudrate: Longint; Bits : Byte; Parity : Char; Stop : byte);
Procedure I_LowerDTR;
Procedure I_PortOff;
Procedure I_PurgeInput;
Procedure I_RaiseDTR;
Procedure I_Writeport(st : string);
Procedure I_SetNSI(cp: word; irq: byte); { Set non standard IRQ }
{}
Function I_Carrier : boolean;
Function I_ComExist(cp: byte): boolean;
Function I_DataAvailable : boolean;
Function I_ReadKeyFromPort : char;

{ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ}

Implementation

{$F+}
procedure I_Intproc(Flags,CS,IP,AX,BX,CX,DX,SI,DI,DS,ES,BP: Word); interrupt; assembler;
asm
  push ax                                 { Save registers }
  push bx
  push dx

  mov  bx,I_ComTP                         { ds:bx -> next free slot }
  mov  dx,I_ComBase                       { dx = port base-address }
  in   al,dx                              { RBR -> al }
  mov  byte ptr [bx],al                   { move byte into buffer }
  inc  bx                                 { pointer to next slot }
  cmp  bx,I_ComBuffEnd                    { past the end of the buffer? }
  jle  @L1                                { no }
  mov  bx,Offset I_ComBuff                { yes, so wrap around }

 @L1:
  cmp  bx,I_ComHP                         { TP=HP --> overflow! }
  jz   @L2                                { yes, ignore character }
  mov  I_ComTP,bx                         { no, save the new tail pointer }

 @L2:
  mov  al,20h                             { EOI -> 8259 }
  out  20h,al
  pop  dx                                 { restore registers }
  pop  bx
  pop  ax
End;
{$F-}

Procedure I_SetNSI(cp: word; irq: byte); { Set non standard IRQ }
begin
  I_IntVect[cp] := irq+8;
  I_IntMasks[cp] := not (1 shl irq);
end;

Function I_ComExist(cp: byte): boolean;
Begin
  I_ComExist := I_CombaseAdr[cp] > 0;
End;

Procedure I_ClearpendingInterrupts;
Var N : byte;
Begin
  { While Interrupts are pending repeat }
  While (port[I_Combase+IIR] AND 1) = 0 do begin
    N := port[I_Combase+LSR];           { Read Line Status }
    N := port[I_Combase+MSR];           { Read Modem Status }
    N := port[I_Combase+RBR];           { Read Receive Buffer Register }
    port[CMD8259] := $20;               { End of Interrupt }
  End;
End;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Function I_DataAvailable : boolean; assembler;
{ This Function I_checks whether there are characters in the buffer or not }
Asm
  mov ax,I_comhp
  cmp ax,I_comtp
  jne @Yes
  mov al,false
  jmp @done
 @Yes:
  mov al,true
 @Done:
End;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Function I_ReadKeyFromPort : char;
{ Take a byte out of the ring buffer and return it to the program,     }
{ note that if there isn't one available it will go into an endless    }
{ loop until one appears                                               }
Begin
  { Wait for any key to appear in the buffer }
  While not I_dataavailable do;
  I_ReadKeyFromPort := Char(Mem[DSeg:I_Comhp]);
  Inc(I_Comhp);
  IF I_Comhp > I_ComBuffEnd then I_Comhp := ofs(I_ComBuff);
End;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Function I_Carrier : boolean;
{ To detect carrier on remote port, requires combase to be set to the  }
{ correct com base address                                             }
begin
  I_carrier := port[I_Combase + MSR] and $80 = $80;
end;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Procedure I_PurgeInput;
{ This Procedure I_will effectively empty the buffer by making the head  }
{ and tail the same address                                            }
Begin
  I_Comtp := I_Comhp;
End;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Procedure I_RaiseDTR;
{ To raise the DTR signal bit 0 of the mcr must be changed to on       }
begin
  port[I_combase+mcr] := port[I_combase+mcr] or $1;
end;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Procedure I_LowerDTR;
{ To lower the DTR signal, causing carrier loss, bit 0 must be turned  }
{ off                                                                  }
begin
  port[I_combase+mcr] := port[I_combase+mcr] and not $1;
end;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Procedure I_Hangup;
{ To drop carrier to hangup the phone -- Simple eh? }
Begin
  I_lowerdtr;   { Drop DTR }
  delay(250);
  I_raisedtr;
  { If the modem can't handle DTR drops go back to grade school and use }
  { Hayes compatiable hangups }
  if I_carrier then begin
    I_writeport('+++');
    delay(1000);
    I_writeport('ATH0'#13);
  End;
End;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Procedure I_Writeport(st : string);
{ This Procedure I_takes a string from the parameters and sends each          }
{ character making sure that the com base address is not equal to 0 (not    }
{ Installed)                                                                }
Var
  Count : word;
  loop : byte;
const LoopLimit = 1000; { Time out counter }
Begin
  I_Timeout := false;
  If I_Combase > 0 then
    for loop := 1 to length(st) do begin
      Count := 0;
      Repeat
        inc(Count);
      Until ((port[I_Combase + LSR] and $20) <> 0) or (Count > LoopLimit);
      If Count > LoopLimit then I_Timeout := true
        Else port[I_Combase + THR] := byte(st[loop]);
    End;
End;

{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Procedure I_Writechar(ch : char);
Var
  Count : word;
  loop : byte;
  LoopLimit: word; { Time out counter }
Begin
  looplimit := 1000;
  I_Timeout := false;
  If I_Combase > 0 then begin
    Count := 0;
    Repeat
      inc(Count);
    Until ((port[I_Combase + LSR] and $20) <> 0) or (Count > LoopLimit);
    If Count > LoopLimit then I_Timeout := true
    Else port[I_Combase+THR] := byte(ch);
  end;
End;

Procedure I_Blockwriteport(var data; lengthdata: word); assembler;
{ To dump a variable of anything to the port }
Asm
  les di,Data                 { Get the address }
  mov cx,lengthdata           { Load length of data }
  jcxz @Done                  { If it's a empty go to the end }

 @loop:
  mov al,byte ptr [ES:DI]     { Load data from ES:DI }
  xor ah,ah                   { Set the AH to 0 }
  push ax                     { Push to the stack }
  call int2.I_writechar        { Call the writechar Function I_}
  inc di                      { Increase DI }
  loop @loop                  { Decrease CX and loop }
 @Done:
End;

Procedure I_CheckAhead(var c : char; var there : boolean);
begin
  there := I_dataavailable;
  c := char(I_combuff[I_comtp]);
end;

{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}

Procedure I_Initport(Cp : word; Baudrate: Longint; Bits : Byte; Parity : Char; Stop : byte);
Var
  tempstop,temppar: byte;
  tempbaud: word;
Begin
  if I_combase <> 0 then exit;
  
  I_Comhp       := ofs(I_ComBuff);
  I_Comtp       := I_Comhp;
  I_ComBuffEnd  := I_Comhp+BufferSize;
  FillChar(I_ComBuff, Succ(BufferSize), #0);
  I_Timeout     := false;                          { Reset Timeout-Marker   }
  I_Comport     := Cp;
  I_Combase     := I_CombaseAdr[I_Comport];        { Get Comport baseadress }
  I_ClearpendingInterrupts;

  GetIntVec(I_IntVect[I_Comport],I_OldCom);        { Capture the interrupt  }
  SetIntVec(I_IntVect[I_Comport],@I_Intproc);      { Set the interrupt      }

  if stop = 1 then tempstop := $0                  { Decode the stopbits    }
    else tempstop := $04;
  case upcase(Parity) of                           { Decode parity          }
    'S' : tempPar := $38;
    'O' : tempPar := $08;
    'M' : tempPar := $28;
    'E' : tempPar := $18;
    'N' : tempPar := $00;
  end;

  I_baud := baudrate;
  If I_Baud <= 19200 then Case I_Baud of
    110     : tempbaud := $417;
    150     : tempbaud := $300;
    300     : tempbaud := $180;
    600     : tempbaud := $C0;
    1200    : tempbaud := $60;
    2400    : tempbaud := $30;
    4800    : tempbaud := $18;
    9600    : tempbaud := $0C;
    19200   : tempbaud := $06;
    else tempbaud := $06;
  End
  else if I_baud = 38400  then Tempbaud := $03  { 001_____ }
  else if I_baud = 57600  then Tempbaud := $02  { 010_____ }
  else if I_baud = 115200 then Tempbaud := $01  { 100_____ }
  else tempbaud := $03;                         { Default to 38400 }

  asm cli; end;
  port[I_Combase+LCR] := $80;                   { Adress Divisor Latch   }
  port[I_Combase+DLH] := Hi(tempbaud);          { Set Baud rate          }
  port[I_Combase+DLL] := Lo(tempbaud);
  port[I_Combase+LCR] := $00 or temppar         { Setup Parity           }
                             or (Bits - 5)      { Setup databits         }
                             or tempstop;       { Setup stopbits         }
  port[I_Combase+MCR] := $0B;                   { Set RTS, DTR           }
  port[I_Combase+IER] := $01;                   { Enable Data-Available Interrupts }
  port[IMR8259] := port[IMR8259] AND I_IntMasks[I_Comport]; { Enable Com-Interrups}
  asm sti; end;
End;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
{ Must be compiled with far calls so that it can be properly used if the }
{ segment varies!                                                        }
{$F+}
Procedure I_PortOff;
Begin
  Exitproc := I_OldExitHandler;           { Exit Procedure to disable inits }
  If (I_Combase = 0) then Exit;
  Asm Cli; End;                           { CLI                             }
{ port[Combase + MCR] := $00;             { Disable Interrupts, Reset MCR   }
  port[IMR8259] := port[IMR8259] or $18;  { Disable Interrupt Level 3 and 4 }
  port[I_Combase + IER] := $00;           { Disable 8250-Interrupts         }
  I_ClearpendingInterrupts;               { Clean up                        }
  I_Combase := 0;                         { Reset Combase                   }
  SetIntVec(I_IntVect[I_Comport], I_OldCom);  { Reset old IV                    }
  Asm Sti; End;                           { STI                             }
End;
{$F-}


{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Begin
  { Findout the base addresses }
  { Init the buffer }
  I_Comhp      := ofs(I_ComBuff);
  I_Comtp      := I_Comhp;
  I_ComBuffEnd := I_Comhp + BufferSize;
  { Combase address must be zero -- uninitialized }
  I_Combase    := 0;
  { Set up the exit procedures }
  I_OldExitHandler := Exitproc;
  Exitproc     := @I_PortOff;
End.

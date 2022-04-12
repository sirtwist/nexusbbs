{$D-,E+,I+,L+,R-,S+,V+,X+}
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

procedure I_Intproc(Flags,CS,IP,AX,BX,CX,DX,SI,DI,DS,ES,BP: Word); // interrupt; assembler;
begin
end;

Procedure I_SetNSI(cp: word; irq: byte); { Set non standard IRQ }
begin
end;

Function I_ComExist(cp: byte): boolean;
begin
End;

Procedure I_ClearpendingInterrupts;
Begin
  { While Interrupts are pending repeat }
End;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Function I_DataAvailable : boolean; // assembler;
{ This Function I_checks whether there are characters in the buffer or not }

begin
End;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Function I_ReadKeyFromPort : char;
{ Take a byte out of the ring buffer and return it to the program,     }
{ note that if there isn't one available it will go into an endless    }
{ loop until one appears                                               }
Begin
End;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Function I_Carrier : boolean;
{ To detect carrier on remote port, requires combase to be set to the  }
{ correct com base address                                             }
begin
  
end;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Procedure I_PurgeInput;
{ This Procedure I_will effectively empty the buffer by making the head  }
{ and tail the same address                                            }
Begin
End;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Procedure I_RaiseDTR;
{ To raise the DTR signal bit 0 of the mcr must be changed to on       }
begin
end;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Procedure I_LowerDTR;
{ To lower the DTR signal, causing carrier loss, bit 0 must be turned  }
{ off                                                                  }
begin
end;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Procedure I_Hangup;
{ To drop carrier to hangup the phone -- Simple eh? }
Begin
End;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Procedure I_Writeport(st : string);
{ This Procedure I_takes a string from the parameters and sends each          }
{ character making sure that the com base address is not equal to 0 (not    }
{ Installed)                                                                }
Begin
End;

{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Procedure I_Writechar(ch : char);
Begin
End;

Procedure I_Blockwriteport(var data; lengthdata: word); // assembler;
{ To dump a variable of anything to the port }
begin
End;

Procedure I_CheckAhead(var c : char; var there : boolean);
begin
end;

{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}

Procedure I_Initport(Cp : word; Baudrate: Longint; Bits : Byte; Parity : Char; Stop : byte);
Begin
End;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
{ Must be compiled with far calls so that it can be properly used if the }
{ segment varies!                                                        }

Procedure I_PortOff;
Begin
End;



{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
End.

{---

                        Next Epoch matriX User System

                                Version 1.00

        Copyright 1995 Intuitive Vision Software.  All Rights Reserved.

                       Written by George A. Roberts IV

                                                                          ---}

{$A+,B+,D-,E+,F+,I+,L+,N-,O+,R-,S+,V-}
UNIT tmpcom;

INTERFACE

USES Dos,int2;


{This variable is TRUE if the interrupt driver has been installed, or FALSE
if it hasn't.  It's used to prevent installing twice or deinstalling when not
installed.}

CONST
  com_installed:boolean = FALSE;
  com_type:byte=0;               { 0 : Not installed           }
                                 { 1 : Fossil                  }
                                 { 2 : Digiboard               }
                                 { 3 : Interrupt               }
var
  fosport:byte;
  regs:registers;
  writebuffer:string[255];
  bufptr:integer;

Function  CommPeek: Char;
Procedure CommStartBreak;
Procedure CommStopBreak;
Function CommSendNW(Ch: Char): Boolean;   {Comm send char - no wait}
procedure com_flush_rx;
procedure com_flush_tx;
procedure com_purge_tx;
function com_carrier:boolean;
function com_rx:char;
function com_tx_ready:boolean;
function com_tx_empty:boolean;
function com_rx_empty:boolean;
procedure com_tx (ch: Char);
procedure com_tx_string (st: String);
procedure com_lower_dtr;
procedure com_raise_dtr;
procedure com_set_speed(speed:longint);
procedure com_startup(ctype:byte; portnum:word; speed:longint; var error:word);
procedure com_deinstall;
function FossilID: string;
function ivFossilPresent: BOOLEAN;



implementation

type
    F_IdentPtr = ^F_IdentStr;
    F_IdentStr = array[1..255] of byte;
    F_InfoBlock = record { len = 69 }
                    size:     word;        { Size of the infoblock }
                    majver:   byte;        { Version (high byte) }
                    minver:   byte;        { ...     (low byte) }
                    ident:    F_identptr;  { Pointer to asciiz ID of driver }
                    ibufr:    word;        { Input buffer size }
                    ifree:    word;        { Input buffer free }
                    obufr:    word;        { Output buffer size }
                    ofree:    word;        { Output buffer free }
                    swidth:   byte;        { Width of screen (in chars) }
                    sheight:  byte;        { Height of screen }
                    baud:     byte;        { Actual baud rate (computer-modem)}
                  end;

var
  exit_save:pointer;
  F_Info:F_infoblock;


Function  CommPeek: Char;
var there:boolean;
    c:char;
  Begin
  c:=#0;
  if (com_type=1) then begin
       Regs.Ah := $0c;
       Regs.Dx := fosport;
       Intr($14,Regs);
       C:= Chr(Regs.Al);
  End;
  if (com_type=3) then begin
        I_CheckAhead(C,there);
        if not(there) then C:=#0;
  end;
  commpeek:=c;
  end;

{Procedure I_SetNSI(cp: word; irq: byte);} { Set non standard IRQ }


  procedure F_GetDrvInfo;
  begin
  if (com_type=1) then begin
    regs.ah := $1b;
    regs.cx := sizeof(F_InfoBlock);
    regs.dx := Fosport;
    regs.es := Seg(F_Info);
    regs.di := Ofs(F_Info);
    intr($14,regs);
  end;
  end;

Function CommSendNW(Ch: Char): Boolean;   {Comm send char - no wait}
  Begin
  if (com_type=1) then begin
       Regs.Ah := $0B;
       Regs.Dx := fosport;
       Regs.Al := Ord(Ch);
       Intr($14, Regs);
       If Regs.Ax = 0 Then CommSendNw := False Else CommSendNw := True;
       End;
  End;

function FossilID: string;
  var
    InfoRec: F_IdentStr;
    X: integer;
    s: string;
  begin
  if (com_type=1) then begin
    F_GetDrvInfo;
    InfoRec := F_Info.ident^;
    X := 1;
    s := '';
    while InfoRec[X] <> 0 do begin
      s := s + chr(InfoRec[X]);
      inc(X);
    end;
    FossilID := s;
  end;
  if (com_type=2) then FossilID:='ivDigiboard Driver 1.00';
  if (com_type=3) then FossilID:='ivInterrupt Driver 1.00';
  end;

  { flush (empty) the receive buffer. }
function ivFossilPresent:BOOLEAN;
begin
  if(com_type=1) then begin
  regs.ah:=$04;
  regs.dx:=$FF;
  intr($14,regs);
  if (regs.ax=$1954) then ivFossilPresent:=TRUE else ivFossilPresent:=FALSE;
  end;
  if (com_type=3) then begin
        ivFossilPresent:=i_comexist(fosport+1);
  end;
end;

procedure com_flush_rx;
var ch:char;
begin
  if (com_type=1) then begin
    regs.dx:=fosport;
    regs.ah:=$0A;
    intr($14,regs);
    exit;
  end;
  if (com_type=2) then begin
          regs.dx:=fosport;
          regs.ah:=$10;
          intr($14,regs);
  end;
  if (com_type=3) then begin
          i_purgeinput;
  end;
end;

  { flush (empty) transmit buffer. }

Procedure CommStartBreak;
  Begin
  if (com_type=1) then begin
  Regs.Ah := $1a;
  Regs.Dx := fosport;
  Regs.AL := 1;
  Intr($14,Regs);
  end;
  End;


Procedure CommStopBreak;
  Begin
  if (com_type=1) then begin
  Regs.Ah := $1a;
  Regs.Dx := fosport;
  Regs.AL := 0;
  Intr($14,Regs);
  end;
  End;

procedure com_flush_tx;
begin
  if (com_type=3) then exit;
  if (com_type=1) then begin
    regs.dx:=fosport;
    regs.ah:=$08;
    intr($14,regs);
    exit;
  end;
  regs.dx:=fosport;
  regs.ah:=$11;
  intr($14,regs);
end;

  { purge (empty) transmit buffer. }
procedure com_purge_tx;
begin
  if (com_type=3) then exit;
  if (com_type=1) then begin
    regs.dx:=fosport;
    regs.ah:=$09;
    intr($14,regs);
    exit;
  end;
  regs.dx:=fosport;
  regs.ah:=$11;
  intr($14,regs);
end;

  { this function returns TRUE if a carrier is present. }
function com_carrier:boolean;
begin
  com_carrier:=FALSE;
  if (com_type=1) or (com_type=2) then begin
    regs.dx:=fosport;
    regs.ah:=$03;
    intr($14,regs);
    if (regs.ax and $0080) = 0 then
      com_carrier:=FALSE
    else
      com_carrier:=TRUE;
  end;
  if (com_type=3) then com_carrier:=i_carrier;
end;

procedure com_tx_forcesend;
begin
    if (com_type=1) and (bufptr>0) then begin

        regs.ah := $19;
        regs.dx := fosport;
        regs.cx := length(writebuffer);
        regs.es := seg(writebuffer[1]);
        regs.di := ofs(writebuffer[1]);
        intr($14, regs);
        writebuffer:='';
        bufptr:=0;
    end;
end;

  { get a character from the receive buffer.
    If the buffer is empty, return NULL (#0). }
function com_rx:char;
begin
{  com_tx_forcesend; }
  if (com_rx_empty) then com_rx:=#0 else
    begin
    if (com_type=1) or (com_type=2) then begin
      regs.dx:=fosport;
      regs.ah:=$02;
      intr($14,regs);
      com_rx:=chr(regs.al);
    end;
    if (com_type=3) then begin
      com_rx:=i_readkeyfromport;
    end;
  end;
end;

  { this function returns TRUE if com_tx can accept a character. }
function com_tx_ready: Boolean;
begin
  if (com_type=1) then begin
    com_tx_ready:=TRUE;
    exit;
  end;
  if (com_type=2) then begin
  regs.dx:=fosport;
  regs.ah:=$03;
  intr($14,regs);
  com_tx_ready:=false;
  if ((regs.ah shr 5) and $01)=1 then com_tx_ready:=TRUE;
  end;
  if (com_type=3) then begin
  
  end;
end;

  { this function returns TRUE if the transmit buffer is empty. }
function com_tx_empty:boolean;
begin
  if (com_type=1) then begin
    regs.dx:=fosport;
    regs.ah:=$03;
    intr($14,regs);
    com_tx_empty:=((regs.ax and $4000) <> 0);
  end;
end;

  { this function returns TRUE if the receive buffer is empty. }
function com_rx_empty:boolean;
begin
  com_rx_empty:=TRUE;
  if (com_type=1) then begin
    regs.dx:=fosport;
    regs.ah:=$0C;
    intr($14,regs);
    com_rx_empty:=(regs.ax = $FFFF);
  end;
  if (com_type=2) then begin
          regs.dx:=fosport;
          regs.ah:=$08;
          intr($14,regs);
          com_rx_empty:=FALSE;
          if (regs.ah=$FF) then com_rx_empty:=TRUE;
  end;
  if (com_type=3) then begin
        com_rx_empty:=not(I_DataAvailable);
  end;
end;


  { send a character.  Waits until the transmit buffer isn't full,
    then puts the character into it.  The interrupt driver will
    send the character once the character is at the head of the
    transmit queue and a transmit interrupt occurs. }
procedure com_tx(ch:char);
var result:word;
begin
    if (com_type=1) then begin
{        inc(bufptr);
        writebuffer:=writebuffer+ch;

        if (bufptr=255) then begin

        regs.ah := $19;
        regs.dx := fosport;
        regs.cx := length(writebuffer);
        regs.es := seg(writebuffer[1]);
        regs.di := ofs(writebuffer[1]);
        intr($14, regs);
        writebuffer:='';
        bufptr:=0;
        end;}

    regs.dx:=fosport;
    regs.al:=ord(ch);
    regs.ah:=$0B;
    intr($14,regs);

    end;
    if (com_type=2) then begin
    regs.dx:=fosport;
    regs.al:=ord(ch);
    regs.ah:=$01;
    intr($14,regs);
    end;
    if (com_type=3) then begin
    i_writeport(ch);
    end;
end;

{ send a whole string }
procedure com_tx_string(st:string);
var i:byte;
    result:word;
begin
  if (com_type=1) or (com_type=2) then begin
  for i:=1 to length(st) do com_tx(st[i]);
  end;
  if (com_type=3) then i_writeport(st);
end;

  { lower (deactivate) the DTR line.  Causes most modems to hang up. }
procedure com_lower_dtr;
begin
  if (com_type=1) then begin
    regs.dx:=fosport;
    regs.al:=$00;
    regs.ah:=$06;
    intr($14,regs);
    exit;
  end;
  if (com_type=2) then begin
  regs.dx:=fosport;
  regs.ah:=$0B;
  intr($14,regs);
  end;
  if (com_type=3) then begin
  i_lowerdtr;
  end;
end;

  { raise (activate) the DTR line. }
procedure com_raise_dtr;
begin
  if (com_type=1) then begin
    regs.dx:=fosport;
    regs.al:=$01;
    regs.ah:=$06;
    intr($14,regs);
    exit;
  end;
  if (com_type=2) then begin
  regs.dx:=fosport;
  regs.ah:=$05;
  regs.al:=$01;
  regs.bl:=$01;
  intr($14,regs);
  end;
  if (com_type=3) then i_raisedtr;
end;

  { set the baud rate.  Accepts any speed between 2 and 65535.  However,
    I am not sure that extremely high speeds (those above 19200) will
    always work, since the baud rate divisor will be six or less, where a
    difference of one can represent a difference in baud rate of
    3840 bits per second or more. }
procedure com_set_speed (speed: longint);
var divisor:word;
    temp:byte;
begin
  if (com_type=1) then begin
    if (speed <= 19200) then
    case speed of
      300:temp:=$40;
      600:temp:=$60;
      1200:temp:=$80;
      2400:temp:=$A0;
      4800:temp:=$C0;
      9600:temp:=$E0;
      19200:temp:=$0;
      else temp:=$0;
    end
    else if speed = 38400  then temp := $20  { 001_____ }
    else if speed = 57600  then temp := $40  { 010_____ }
    else if speed = 76800  then temp := $60  { 011_____ }
    else if speed = 115200 then temp := $80  { 100_____ }
    else temp := $20;                   { Default to 38400 }
    inc(temp,3);
    regs.ah:=$00;
    regs.al:=temp;
    regs.dx:=fosport;
    intr($14,regs);
  end;
end;

  { Install the communications driver.  Portnum should be 1..max_port.
    Error codes returned are:

      0 - No error
      1 - Invalid port number
      2 - UART for that port is not present
      3 - Already installed, new installation ignored }

procedure com_install_db(portnum:word; speed:longint; var error:word);
begin
  if (com_installed) then exit;
  error:=0;
  com_type:=2;
  fosport:=portnum-1;
  regs.dx:=fosport;
  regs.ah:=$04;
  regs.al:=0;
  regs.bh:=0;
  regs.bl:=0;
  regs.ch:=3;
  case (speed div 10) of
        5:regs.cl:=$0D;
        11:regs.cl:=$00;
        15:regs.cl:=$01;
        20:regs.cl:=$10;
        30:regs.cl:=$02;
        60:regs.cl:=$03;
        120:regs.cl:=$04;
        180:regs.cl:=$11;
        240:regs.cl:=$05;
        480:regs.cl:=$06;
        960:regs.cl:=$07;
        1920:regs.cl:=$08;
        3840:regs.cl:=$09;
        5760:regs.cl:=$0A;
        7680:regs.cl:=$0B;
        11520:regs.cl:=$0C;
  end;
  intr($14,regs);
  if (regs.ah=$FF) then error:=1 else
  com_installed:=TRUE;
end;

procedure com_install(portnum:word; var error:word; dofossil:boolean);
begin
  if (com_installed) then exit;
    com_type:=0;
    fosport:=portnum-1;
    regs.dx:=fosport;
    regs.ah:=$04;
    intr($14,regs);
    error:=0;
    if (regs.ax = $1954) then begin
      com_type:=1;
      regs.dx:=fosport;
      regs.al:=$00;
      regs.ah:=$00;
      intr($14,regs);
      com_installed:=TRUE;
    end else error:=1;
end;


  { Deinstall the interrupt driver completely.  It doesn't change
    the baud rate or mess with DTR; it tries to leave the interrupt
    vectors and enables and everything else as it was when the driver
    was installed.

    This procedure MUST be called by the exit procedure of this
    module before the program exits to DOS, or the interrupt driver
    will still be attached to its vector -- the next communications
    interrupt that came along would jump to the interrupt driver which
    is no longer protected and may have been written over. }
procedure com_deinstall;
begin
  if (com_type=1) then begin
    com_type:=0;
    regs.dx:=fosport;
    regs.ah:=$05;
    intr($14,regs);
    com_installed:=FALSE;
  end;
  if (com_type=3) then begin
    i_portoff;
  end;
  com_installed:=FALSE;
end;

procedure com_startup(ctype:byte; portnum:word; speed:longint; var error:word);
begin
case ctype of
        1:begin
                com_install(portnum,error,TRUE);
                com_set_speed(speed);
          end;
        2:com_install_db(portnum,speed,error);
        3:begin
                if (com_installed) then exit;
                i_initport(portnum,speed,8,'N',1);
                fosport:=portnum-1;
                com_type:=3;
                com_installed:=TRUE;
                error:=0;
          end;
end;
end;

  { This procedure is called when the program exits for any reason.  It
    deinstalls the interrupt driver.}
{$F+} procedure exit_procedure; {$F-}
begin
  com_deinstall;
  exitproc:=exit_save;
end;

  { This installs the exit procedure. }
begin
  exit_save:=exitproc;
  exitproc:=@exit_procedure;
  bufptr:=0;
  writebuffer:='';
end.


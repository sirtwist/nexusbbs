Unit Ansi1; (* Ho ho ho -Santa Clause) *)

Interface

Uses crt;

const POSReq:boolean=FALSE;

Procedure ClearANSI;
Procedure Display_ANSI(ch:Char);
{ Displays ch following ANSI Graphics protocol }

{---------------------------------------------------------------------- -----}
{ Useful information For porting this thing over to other computers:

  Change background Text color        Change foreground Text color
  TextBackground(0) = black           TextColor(0) = black
  TextBackground(1) = blue            TextColor(1) = blue
  TextBackground(2) = green           TextColor(2) = green
  TextBackground(3) = cyan            TextColor(3) = cyan
  TextBackground(4) = red             TextColor(4) = red
  TextBackground(5) = Magenta         TextColor(5) = magenta
  TextBackground(6) = brown           TextColor(6) = brown
  TextBackground(7) = light grey      TextColor(7) = white
                                      TextColor(8) = grey
  Delete(s,i,c);                      TextColor(9) = bright blue
    Delete c Characters from          TextColor(10)= bright green
    String s starting at i            TextColor(11)= bright cyan
  Val(s,v,c);                         TextColor(12)= bright red
    convert String s to numeric       TextColor(13)= bright magenta
    value v. code=0 if ok.            TextColor(14)= bright yellow
  Length(s)                           TextColor(15)= bright white
    length of String s
}

Implementation

uses common;

CONST
  ANSI_St   :String ='' ;  {stores ANSI escape sequence if receiving ANSI}
  ANSI_SCPL :Integer=-1 ;  {stores the saved cursor position line}
  ANSI_SCPC :Integer=-1;  {   "    "    "      "       "    column}
  ANSI_FG   :Integer=7;  {stores current foreground}
  ANSI_BG   :Integer=0;  {stores current background}
  ANSI_C:boolean=FALSE;
  ANSI_I:boolean=FALSE;
  ANSI_B:boolean=FALSE;
  ANSI_R:Boolean=FALSE ;  {stores current attribute options}

var
p,x,y : Integer;

Procedure ClearANSI;
begin
ANSI_C:=FALSE;
end;

Procedure Display_ANSI(ch:Char);
{ Displays ch following ANSI Graphics protocal }

  procedure gotoxy2(x,y:byte);
  begin
  gotoxy(x,y);
  end;

  Procedure TABULATE;
  Var x:Integer;
  begin
    x:=WhereX;
    if x<80 then
      Repeat
        Inc(x);
      Until (x MOD 8)=0;
    if x=80 then x:=1;
    GotoXY2(x,WhereY);
    if x=1 then WriteLN;
  end;

  Procedure BACKSPACE;
  Var x:Integer;
  begin
    if WhereX>1 then
      Write(^H);
{    else
      if WhereY>1 then begin
        GotoXY2(80,WhereY-1);
        Write(' ');
        GotoXY2(80,WhereY-1);
      end;}
  end;

  Procedure TTY(ch:Char);
  Var x:Integer;
  begin
    if ANSI_C then begin
      if ANSI_I then ANSI_FG:=ANSI_FG or 8;
      if ANSI_B then ANSI_FG:=ANSI_FG or 16;
      if ANSI_R then begin
        x:=ANSI_FG;
        ANSI_FG:=ANSI_BG;
        ANSI_BG:=x;
      end;
      ANSI_C:=False;
{      if (testcode) then write(ansi_Fg,',',ansi_bg); }
    end;
    if (okcolor) then begin
          TextColor(ANSI_FG);
          TextBackground(ANSI_BG);
    end;
    lastco:=curco;
    curco:=textattr;
    Case Ch of
      ^G: begin
            Sound(2000);
            Delay(75);
            NoSound;
          end;
      ^H: Backspace;
      ^I: Tabulate;
      ^J: begin
            TextBackground(0);
            lastco:=curco;
            curco:=textattr;
            Write(^J);
          end;
      ^K: begin
                GotoXY2(1,1);
          end;
      ^L: begin
            TextBackground(0);
            lastco:=curco;
            curco:=textattr;
            ClrScr;
          end;
      ^M: begin
            TextBackground(0);
            lastco:=curco;
            curco:=textattr;
            Write(^M);
          end;
      else Write(Ch);
    end;
  end;

  Procedure ANSIWrite(S:String);
  Var x:Integer;
  begin
    For x:=1 to Length(S) do
      TTY(S[x]);
  end;

  Function Param:Integer;   {returns -1 if no more parameters}
  Var S:String;
      x,XX:Integer;
      B:Boolean;
  begin
    B:=False;
    For x:=3 to Length(ANSI_St) DO
      if ANSI_St[x] in ['0'..'9'] then B:=True;
    if not B then
      Param:=-1
    else begin
      S:='';
      x:=3;
      if ANSI_St[3]=';' then begin
        Param:=0;
        Delete(ANSI_St,3,1);
        Exit;
      end;
      Repeat
        S:=S+ANSI_St[x];
        x:=x+1;
      Until (NOT (ANSI_St[x] in ['0'..'9'])) or (Length(S)>3) or (x>Length(ANSI_St));
      if Length(S)>3 then begin
        ANSIWrite(ANSI_St+Ch);
        ANSI_St:='';
        Param:=-1;
        Exit;
      end;
      Delete(ANSI_St,3,Length(S));
      if ANSI_St[3]=';' then Delete(ANSI_St,3,1);
      Val(S,x,XX);
      Param:=x;
    end;
  end;

begin
{$IFDEF Linux}
  write(Ch);
{$ELSE}
  if not(ansi_c) then begin
  ANSI_FG:=curco and 7;
  if (curco and 8)<>0 then inc(ANSI_FG,8);
  if (curco and 128)<>0 then inc(ANSI_FG,16);
  ANSI_BG:=((curco shr 4) and 7);
  end;
  if (Ch<>#27) and (ANSI_St='') then begin
    TTY(Ch);
    Exit;
  end;
  if Ch=#27 then begin
    if ANSI_St<>'' then begin
      ANSIWrite(ANSI_St+#27);
      ANSI_St:='';
    end else ANSI_St:=#27;
    Exit;
  end;
  if ANSI_St=#27 then begin
    if Ch='[' then
      ANSI_St:=#27+'['
    else begin
      ANSIWrite(ANSI_St+Ch);
      ANSI_St:='';
    end;
    Exit;
  end;
  if (Ch='[') and (ANSI_St<>'') then begin
    ANSIWrite(ANSI_St+'[');
    ANSI_St:='';
    Exit;
  end;
  if not (Ch in ['0'..'9',';','A'..'D','f','h','H','J','K','m','n','s','u','=','?']) then begin
    ANSIWrite(ANSI_St+Ch);
    ANSI_St:='';
    Exit;
  end;
  if Ch in ['A'..'D','f','H','J','K','m','n','s','u','h','l'] then begin
    Case Ch of
    'h': begin
                ANSI_St:='';
         end;
    'l': begin
                ANSI_St:='';
         end;
    'A': begin
           p:=Param;
           if p=-1 then p:=1;
           if WhereY-p<1 then begin
             GotoXY2(WhereX,1);
           end else begin
             GotoXY2(WhereX,WhereY-p);
           end;
         end;
    'B': begin
           p:=Param;
           if p=-1 then p:=1;
           if WhereY+p>24 then begin
             GotoXY2(WhereX,24);
           end else begin
             GotoXY2(WhereX,WhereY+p);
           end;
         end;
    'C': begin
           p:=Param;
           if p=-1 then p:=1;
           if WhereX+p>80 then begin
             GotoXY2(80,WhereY);
           end else begin
             GotoXY2(WhereX+p,WhereY);
           end;
         end;
    'D': begin
           p:=Param;
           if p=-1 then p:=1;
           if WhereX-p<1 then begin
             GotoXY2(1,WhereY);
           end else begin
             GotoXY2(WhereX-p,WhereY);
           end;
         end;
'H','f': begin
           Y:=Param;
           x:=Param;
           if Y<1 then Y:=1;
           if x<1 then x:=1;
           if (x>80) or (x<1) or (Y>25) or (Y<1) then begin
             ANSI_St:='';
             Exit;
           end;
           GotoXY2(x,Y);
         end;
    'n': begin
           p:=Param;
           if (p=6) then begin
           POSReq:=TRUE;
           end;
         end;
    'J': begin
           p:=Param;
           if p=2 then begin
             TextBackground(0);
             lastco:=curco;
             curco:=textattr;
             ClrScr;
           end;
           if p=0 then begin
             x:=WhereX;
             Y:=WhereY;
             Window(1,y,80,24);
             TextBackground(0);
             lastco:=curco;
             curco:=textattr;
             ClrScr;
             Window(1,1,80,24);
             GotoXY2(x,Y);
           end;
           if p=1 then begin
             x:=WhereX;
             Y:=WhereY;
             Window(1,1,80,WhereY);
             TextBackground(0);
             lastco:=curco;
             curco:=textattr;
             ClrScr;
             Window(1,1,80,24);
             GotoXY2(x,Y);
           end;
         end;
    'K': begin
           TextBackground(0);
             lastco:=curco;
           curco:=textattr;
           ClrEol;
         end;
    'm': begin
           if ANSI_St=#27+'[' then begin
             ANSI_FG:=7;
             ANSI_BG:=0;
             ANSI_I:=False;
             ANSI_B:=False;
             ANSI_R:=False;
           end;
           Repeat
             p:=Param;
             Case p of
               -1:;
                0:begin
                    ANSI_FG:=7;
                    ANSI_BG:=0;
                    ANSI_I:=False;
                    ANSI_R:=False;
                    ANSI_B:=False;
                    ANSI_C:=TRUE;
                  end;
                1:ANSI_I:=True;
                5:ANSI_B:=True;
                7:ANSI_R:=True;
               30:ANSI_FG:=0;
               31:ANSI_FG:=4;
               32:ANSI_FG:=2;
               33:ANSI_FG:=6;
               34:ANSI_FG:=1;
               35:ANSI_FG:=5;
               36:ANSI_FG:=3;
               37:ANSI_FG:=7;
               40:ANSI_BG:=0;
               41:ANSI_BG:=4;
               42:ANSI_BG:=2;
               43:ANSI_BG:=6;
               44:ANSI_BG:=1;
               45:ANSI_BG:=5;
               46:ANSI_BG:=3;
               47:ANSI_BG:=7;
             end;
             if ((p>=30) and (p<=47)) or (p=1) or (p=5) or (p=7) or (p=0) then
                        ANSI_C:=True;
           Until p=-1;
           if not(okcolor) then begin
                if (ANSI_BG<>0) then begin
                        ANSI_FG:=0;
                        ANSI_BG:=7;
                end else begin
                        ANSI_FG:=7;
                        ANSI_BG:=0;
                end;
           end;
         end;
    's': begin
           ANSI_SCPL:=WhereY;
           ANSI_SCPC:=WhereX;
         end;
    'u': begin
           if ANSI_SCPL>-1 then GotoXY2(ANSI_SCPC,ANSI_SCPL);
           ANSI_SCPL:=-1;
           ANSI_SCPC:=-1;
         end;
    end;
    ANSI_St:='';
    Exit;
  end;
  if Ch in ['0'..'9',';'] then
    ANSI_St:=ANSI_St+Ch;
  if Length(ANSI_St)>50 then begin
    ANSIWrite(ANSI_St);
    ANSI_St:='';
    Exit;
  end;
{$ENDIF}
end;


END.

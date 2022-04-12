{$A+,B+,D-,E+,F+,I+,L+,N-,O+,R-,S+,V-}
unit mail9;

interface

uses
  crt, dos, 
  common, mail0;

procedure mbasechange(var done:boolean; mstr:astr);

implementation

USES TagUnit,MkString;

procedure mbasechange(var done:boolean; mstr:astr);
var s:astr;
    i:integer;
    listing:boolean;

procedure mbaselist;
var s,os:astr;
    b,b2,i,onlin,nd:integer;
    UTAG:^TagRecordOBJ;
    d1,abort,next,acc,showtitles:boolean;

  procedure titles;
  begin
    if (showtitles) then begin
      if (okansi) then begin
        sprompt(gstring(700));
        sprompt(gstring(701));
        sprompt(gstring(702));
      end else begin
        sprompt(gstring(703));
        sprompt(gstring(704));
        sprompt(gstring(705));
      end;
      showtitles:=FALSE;
    end;
  end;

  procedure shortlist;
  var ii,x,x2,y2,x3:integer;
      c:char;
      bool:boolean;
      cf:file of boolean;
  begin
    showtitles:=true;
    mpausescr:=TRUE;
    printingfile:=TRUE;
    abort:=FALSE;
    assign(cf,adrv(systat^.gfilepath)+'MCONF'+chr(mconf+64)+'.IDX');
    {$I-} reset(cf); {$I+}
    ii:=ioresult;
    if (ii<>0) then begin
        abort:=TRUE;
    end else begin
        bool:=FALSE;
        b:=0;
        while not(bool) and (b<=numboards) do begin
                seek(cf,b);
                read(cf,bool);
                if not(bool) then inc(b);
        end;
    end;
    while (b<=numboards) and (not abort) and not(hangup) do begin
      acc:=(mbaseac(b)); { fbaseac will load memuboard }
      if ((mbunhidden in memboard.mbstat) or (acc)) then begin
        titles;
        curtagged:=UTAG^.IsTagged(memboard.baseid);
        inc(nd);
        if (acc) then begin
                curbnum:=b;
        end else begin
                curbnum:=-1;
        end;
        sprompt(gstring(706));
        if (mabort) then begin
                abort:=TRUE;
        end else begin
                if (lil=0) then showtitles:=TRUE;
        end;
        if (not empty) then wkey(abort,next);
      end;
      bool:=FALSE;
      inc(b);
      while not(bool) and (b<=numboards) do begin
                seek(cf,b);
                read(cf,bool);
                if not(bool) then inc(b);
      end;
    end;
    if not(abort) then close(cf);
    curbnum:=-2;
    mpausescr:=FALSE;
    mabort:=FALSE;
    printingfile:=FALSE;
  end;

begin
  nl;
  abort:=FALSE;
  onlin:=0; s:=''; b:=0; nd:=0;
  new(UTAG);
  UTAG^.Init(adrv(systat^.userpath)+hexlong(thisuser.userid)+'\'+hexlong(thisuser.userid)+'.NMT');
  UTAG^.MaxBases:=Numboards;
  if (UTAG=NIL) then begin
        sprint('%120%Unable to allocate memory to display message bases.');
        exit;
  end;
  shortlist;
  UTAG^.Done;
  dispose(UTAG);
  if (nd=0) then sprompt('%150%No message bases available.');
end;

begin
  listing:=FALSE;
  if mstr<>'' then
    case mstr[1] of
      '+':begin
            i:=board;
            if (board>=numboards) then i:=numboards else begin
              while not(inmconf(i)) do begin
                inc(i);
              end;
              repeat
                inc(i);
                if (mbaseac(i)) then changeboard(i);
              until (board=i) or (i>numboards);
              end;
            if (board<>i) then sprint('|LF|Highest accessible message base.')
              else lastcommandovr:=TRUE;
          end;
      '-':begin
            i:=board;
            if board<=0 then i:=0 else begin
              while not(inmconf(i)) do begin
                dec(i);
              end;
              repeat
                dec(i);
                if (mbaseac(i)) then changeboard(i);
              until (board=i) or (i<0);
              end;
            if (board<>i) then sprint('|LF|Lowest accessible message base.')
              else lastcommandovr:=TRUE;
          end;
      'L':begin
                listing:=TRUE;
                mbaselist;
          end;
    else
          begin
            if (mbaseac(value(mstr))) then changeboard(value(mstr)) else
            sprint('%150%You do not have access to that base.');
            if pos(';',mstr)>0 then begin
              s:=copy(mstr,pos(';',mstr)+1,length(mstr));
              curmenu:=value(s);
              newmenutoload:=TRUE;
              done:=TRUE;
            end;
            lastcommandovr:=TRUE;
          end;
    end
  else begin
    if (novice in thisuser.ac) then mbaselist else nl;
    s:='?';
    repeat
      sprompt(gstring(36));
      scaninput(s,'?Q'^M,TRUE);
      i:=value(s);
      if (s='?') then begin mbaselist;
      end else begin
        if (((i>=1) and (i<=numboards)) or ((i=0) and (copy(s,1,1)='0'))) and
                (i<>board) and (s<>'') and (s<>'Q') then changeboard(i);
        end;
    until (s<>'?') or (hangup);
    lastcommandovr:=TRUE;
  end;
  setc(7 or (0 shl 4));
  loadboard(board);
end;

end.

{$A+,B+,D-,E+,F+,I+,L+,N-,O+,R-,S+,V-}
unit file11;

interface

uses
  crt,dos,
  myio3,
  common;

function cansee(f:Fheaderrec):boolean;
procedure fbasechange(var done:boolean; mstr:astr);

implementation

uses file0, file1,tagunit,mkstring;

function cansee(f:Fheaderrec):boolean;
begin
  cansee:=(((not (ffnotval in f.fileflags)) or (aacs(systat^.seeunval))) and
        aacs(f.access));
end;


procedure fbasechange(var done:boolean; mstr:astr);
var s:astr;
    i:integer;
    firstbase,lastbase,changenum:integer;

procedure fbaselist;
var s,os:astr;
    nd,b,b2,i:integer;
    UTAG:^TagRecordOBJ;
    d1,abort,next,acc,showtitles:boolean;

  procedure stitles;
  begin
    if (showtitles) then begin
      if (okansi) then begin
        sprompt(gstring(515));
        sprompt(gstring(516));
        sprompt(gstring(517));
      end else begin
        sprompt(gstring(518));
        sprompt(gstring(519));
        sprompt(gstring(520));
      end;
      showtitles:=FALSE;
    end;
  end;

  procedure shortlist;
  var x2,y2,x3,x,currentline:integer;
      gotkey:boolean;
      c:char;
      bool:boolean;
      cf:file of boolean;
  begin
    showtitles:=true;
    mpausescr:=TRUE;
    printingfile:=TRUE;
    abort:=FALSE;
    assign(cf,adrv(systat^.gfilepath)+'FCONF'+chr(fconf+64)+'.IDX');
    {$I-} reset(cf); {$I+}
    if (ioresult<>0) then begin
        abort:=TRUE;
    end else begin
        bool:=FALSE;
        b:=0;
        while not(bool) and (b<=maxulb) do begin
                seek(cf,b);
                read(cf,bool);
                if not(bool) then inc(b);
        end;
    end;
    while (b<=maxulb) and (not abort) and not(hangup) do begin
      acc:=(fbaseac(b)); { fbaseac will load memuboard }
      if ((fbunhidden in memuboard.fbstat) or (acc)) then begin
        stitles;
        curtagged:=UTAG^.IsTagged(memuboard.baseid);
        inc(nd);
        if (acc) then begin
                curbnum:=b;
        end else begin
                curbnum:=-1;
        end;
        sprompt(gstring(521));
        if (mabort) then begin
                abort:=TRUE;
        end else begin
                if (lil=0) then showtitles:=TRUE;
        end;
        if (not empty) then wkey(abort,next);
      end;
      bool:=FALSE;
      inc(b);
      while not(bool) and (b<=maxulb) do begin
                seek(cf,b);
                read(cf,bool);
                if not(bool) then inc(b);
      end;
    end;
    close(cf);
    curbnum:=-2;
    mpausescr:=FALSE;
    mabort:=FALSE;
    printingfile:=FALSE;
  end;

begin
  nl;
  abort:=FALSE;
  s:=''; b:=0; nd:=0;
  new(UTAG);
  if (UTAG=NIL) then begin
        sprint('%120%Unable to allocate memory to display file bases.');
        exit;
  end;
  UTAG^.Init(adrv(systat^.userpath)+hexlong(thisuser.userid)+'\'+hexlong(thisuser.userid)+'.NFT');
  UTAG^.MaxBases:=Maxulb;
  shortlist;
  UTAG^.Done;
  dispose(UTAG);
  if (nd=0) then sprompt('%120%No File Areas Are Available.');
end;

begin
  if (mstr<>'') then
    case mstr[1] of
      '+':begin
            i:=fileboard;
            if (fileboard>=maxulb) then i:=0 else begin
              while not(infconf(i)) do begin
                inc(i);
              end;
              repeat
                inc(i);
                if (fbaseac(i)) then changefileboard(i);
              until ((fileboard=i) or (i>maxulb));
              end;
            if (fileboard<>i) then sprint('|LF|Highest Accessible File Base.')
              else lastcommandovr:=TRUE;
          end;
      '-':begin
            i:=fileboard;
            if (fileboard<=0) then i:=maxulb else begin
              while not(infconf(i)) do begin
                dec(i);
              end;
              repeat
                dec(i);
                if (fbaseac(i)) then changefileboard(i);
              until ((fileboard=i) or (i<=0));
              end;
            if (fileboard<>i) then sprint('|LF|Lowest Accessible File Base.')
              else lastcommandovr:=TRUE;
          end;
      'L':fbaselist;
    else
          begin
            if (fbaseac(value(mstr))) then changefileboard(value(mstr)) else
                sprint('%150%You do not have access to that base.');
            if (pos(';',mstr)>0) then begin
              s:=copy(mstr,pos(';',mstr)+1,length(mstr));
              curmenu:=value(s);
              newmenutoload:=TRUE;
              done:=TRUE;
            end;
            lastcommandovr:=TRUE;
          end;
    end
  else begin
    if (novice in thisuser.ac) then fbaselist else nl;
    s:='?';
    repeat
      sprompt(gstring(66));
      scaninput(s,'?Q'^M,TRUE);
      i:=value(s);
      if (s='?') then begin fbaselist; end else begin
      if (((i>=1) and (i<=maxulb)) or ((i=0) and (copy(s,1,1)='0'))) and
           (i<>fileboard) and (s<>'') and (s<>'Q') then changefileboard(i);
      end;
    until (s<>'?') or (hangup);
    lastcommandovr:=TRUE;
  end;
  loaduboard(fileboard);
  setc(7 or (0 shl 4));
end;

end.

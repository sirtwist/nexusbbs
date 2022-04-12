unit nxwave4;

interface

uses crt,dos,ivmodem,nxwave2,tagunit,mulaware;

procedure getbases;

implementation

uses mkstring;

function yn2:boolean;
var c:char;
    s:string;
begin
  if (ivcarrier) then begin
    s:=allcaps(GString(99));
    if (length(s)<2) then s:='YN';
    s:=s+^M;
    repeat
      while not(ivKeypressed) do begin timeslice; end;
      c:=upcase(ivreadchar);
    until (pos(c,s)<>0) or not(ivcarrier);
    if (dyny) and (c<>s[2]) then c:=s[1];
    if (dyny=False) and (c<>s[1]) then c:=s[2];
    if (c=s[1]) then begin
      if dyny=false then begin
      ivwrite(gstring(103));
      ivwrite(gstring(100));
      end;
      yn2:=TRUE;
    end else begin
      if dyny=true then begin
      ivwrite(gstring(101));
      ivwrite(gstring(102));
      end;
      yn2:=FALSE;
    end;
    if not(ivcarrier) then yn2:=FALSE;
  end;
  dyny:=FALSE;
end;

procedure scaninput(var s:string; allowed:string; lfeed:boolean);
  var os:string;
      i:integer;
      c:char;
      gotcmd:boolean;
  begin
    gotcmd:=FALSE; s:='';
    repeat
        c:=#0;
        while not(ivKeypressed) do begin timeslice; end;
        c:=ivreadchar;
        c:=upcase(c);
      os:=s;
      if ((pos(c,allowed)<>0) and (s='')) then begin gotcmd:=TRUE; s:=c; end
      else
      if (pos(c,'0123456789')<>0) then begin
	if (length(s)<5) then s:=s+c;
      end
      else
      if ((s<>'') and (c=^H)) then s:=copy(s,1,length(s)-1)
      else
      if (c=^X) then begin
        for i:=1 to length(s) do ivwrite(^H);
	s:=''; os:='';
      end
      else
      if (c=#13) then gotcmd:=TRUE;

      if (length(s)<length(os)) then ivwrite(^H);
      if (length(s)>length(os)) then ivwrite(copy(s,length(s),1));
    until ((gotcmd) or not(ivcarrier));
    if (lfeed) then ivwriteln('');;
  end;

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
ivwriteln('|CLS|%010%ÚÄ%090%ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß%010%Ä¿');
ivwriteln('%010%³%151% ##  %010%³%151% Message Base                                                          %010%³');
ivwriteln('%010%ÀÄÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÄÙ');
      showtitles:=FALSE;
    end;
  end;

  procedure shortlist;
  var x:integer;
      c:char;
      abort:boolean;
  begin
    showtitles:=true;
    abort:=FALSE;
    b:=0;
    while (b<=numboards) and (not abort) and (ivcarrier) do begin
      seek(bf,b);
      read(bf,memboard);
      acc:=aacs(memboard.acs);
      if ((mbunhidden in memboard.mbstat) or (acc)) then begin
        titles;
        if (acc) then begin
          b2:=b;
          if (UTAG^.IsTagged(memboard.baseid)) then s:='%120%T' else s:=' ';
          s:=s+'%150%'+mrn(cstr(b2),5);
        end else
          s:='%140% -----';
        s:=s+'%140%    '+memboard.name;
        inc(nd);
        if (b<=numboards) then ivwriteln(s);
        if (linenum=thisuser.pagelen-1) then begin
                dyny:=TRUE;
                if not(pynq(gstring(25))) then abort:=TRUE else linenum:=0;
{                ynq('%030%Continue? %150%');
                if not(yn2) then begin
                        abort:=TRUE;
                        for x:=1 to length('%030%Continue? %150%') do ivwrite(^H' '^H);
                end else linenum:=0;                                       }
        end;
        if (linenum=0) then showtitles:=TRUE;
      end;
      inc(b);
    end;
  end;

begin
  ivwriteln('');
  onlin:=0; s:=''; b:=0; nd:=0;
  new(UTAG);
  UTAG^.Init(adrv(systat.userpath)+hexlong(thisuser.userid)+'\'+hexlong(thisuser.userid)+'.NWT');
  UTAG^.MaxBases:=Numboards;
  if (UTAG=NIL) then begin
        ivwriteln('%120%Unable to allocate memory to display message bases.');
        exit;
  end;
  shortlist;
  UTAG^.Done;
  dispose(UTAG);
  if (nd=0) then ivwriteln('%150%No Message Bases Available.');
end;

begin
  listing:=TRUE;
  mbaselist;
end;

procedure getbases;
var s:string;
    x5,i:integer;
    done:boolean;
    UTAG:^TagRecordOBJ;

begin
  assign(bf,systat.gfilepath+'MBASES.DAT');
  {$I-} reset(bf); {$I+}
  if (ioresult<>0) then begin
                writeln('Error reading message bases!');
                exit;
  end;
  numboards:=filesize(bf)-1;
  mbasechange(done,'L');
  new(UTAG);
  if (UTAG=NIL) then begin
      ivwriteln('%120%Unable to access tag records.');
      exit;
  end;
  UTAG^.Init(adrv(systat.userpath)+hexlong(thisuser.userid)+'\'+hexlong(thisuser.userid)+'.NWT');
  UTAG^.MaxBases:=Numboards;
  done:=FALSE;
  repeat
    ivwrite('%030%Tag Message Bases [%150%?%030%=Help] : %150%'); scaninput(s,'LAU?Q',TRUE);
    if (s='Q') then done:=TRUE;
    if (s='?') then begin
        ivwriteln('');
        ivwriteln('%080%[%150%L%080%] %030%Re-list Message Bases');
        ivwriteln('%080%[%150%#%080%] %030%Toggle base scan on/off for this base number');
        ivwriteln('%080%[%150%A%080%] %030%Set all bases to be scanned');
        ivwriteln('%080%[%150%U%080%] %030%Set all bases NOT to be scanned');
        ivwriteln('%080%[%150%Q%080%] %030%Quit Message Base tagging');
        ivwriteln('');
	end;
    if (s='L') then begin
        UTAG^.Done;
        dispose(UTAG);
        mbasechange(done,'L');
        new(UTAG);
        if (UTAG=NIL) then begin
            ivwriteln('%120%Unable to access tag records.');
            exit;
        end;
        UTAG^.Init(adrv(systat.userpath)+hexlong(thisuser.userid)+'\'+hexlong(thisuser.userid)+'.NWT');
        UTAG^.MaxBases:=Numboards;
    end;
    i:=value(s);
    if ((i>0) and (i<=numboards) and (s<>'')) or ((i=0) and (s='0')) then begin
    seek(bf,i);
    read(bf,memboard);
    if (aacs(memboard.acs)) then begin
        if (memboard.tagtype=2) and not(aacs(systat.untagmandatory)) then begin
                ivwrite('|LF|%120%This is a mandatory base!|LF||LF|');
        end else begin
        ivwriteln('');
        if (UTAG^.IsTagged(memboard.baseid)) then begin
          ivwriteln('%030%Untagging: %150%'+memboard.name);
          UTAG^.Removetag(memboard.baseid);
	end else begin
          ivwriteln('%030%Tagging  : %150%'+memboard.name);
          UTAG^.Addtag(memboard.baseid);
	end;
        ivwriteln('');
        end;
      end;
    end;
    if (s='A') then begin
            ivwrite('%120%Tagging: %150%');
            for i:=0 to numboards do begin
            seek(bf,i);
            read(bf,memboard);
            if (aacs(memboard.acs)) then begin { loads memboard }
                ivwrite(cstr(i));
                UTAG^.AddTag(memboard.baseid);
                for x5:=1 to length(cstr(i)) do begin
                        ivwrite(^H' '^H);
                end;
            end;
            end;
            ivwriteln('%140%All Message Bases Tagged.');
            ivwriteln('');
    end;
    if (s='U') then begin
            ivwrite('%120%Untagging: %150%');
            for i:=0 to numboards do begin
            seek(bf,i);
            read(bf,memboard);
            if (aacs(memboard.acs)) then begin { loads memboard }
                if (memboard.tagtype<>2) then begin
                ivwrite(cstr(i));
                UTAG^.RemoveTag(Memboard.baseid);
                for x5:=1 to length(cstr(i)) do begin
                        ivwrite(^H' '^H);
                end;
                end;
            end;
            end;
            ivwriteln('%140%All Message Bases UnTagged.');
            ivwriteln('');
    end;
  until (done) or not(ivcarrier);
  UTAG^.SortTags(adrv(systat.gfilepath)+'USER'+cstrn(cnode)+'.TWT',1);
  UTAG^.Done;
  dispose(UTAG);
  close(bf);
end;

end.

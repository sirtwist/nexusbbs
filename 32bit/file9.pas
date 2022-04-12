{$A+,B+,D-,E+,F+,I+,L+,N-,O+,R-,S+,V-}
unit file9;

interface

uses
  crt, dos, 
  myio3,
  common;

function info:astr;
procedure dir(cd,x:astr; expanded:boolean);
procedure dirf(expanded:boolean);
procedure setdirs;
procedure pointdate;
procedure yourfileinfo;

implementation

uses file0,file1, file2,file11,tagunit,mkstring;

function align2(s:astr):astr;
begin
  if pos('.',s)=0 then s:=mln(s,12)
    else s:=mln(copy(s,1,pos('.',s)-1),8)+' '+mln(copy(s,pos('.',s)+1,3),3);
  align2:=s;
end;

function info:astr;
var pm:char;
    i:integer;
    s:astr;
    dt:datetime;

  function ti(i:integer):astr;
  var s:astr;
  begin
    ti:=tch(cstr(i));
  end;

begin
  s:=dirinfo.name;
  if (dirinfo.attr and directory)=directory then
        s:=mln(mln(' ',8)+'<DIR>',22)+' '+s else
        s:=mrn(cstrl(dirinfo.size),22)+' '+s;
  unpacktime(dirinfo.time,dt);
  with dt do begin
    if hour<13 then pm:='a' else begin pm:='p'; hour:=hour-12; end;
    s:=ti(month)+'/'+ti(day)+'/'+ti(year-1900)+'  '+
       ti(hour)+':'+ti(min)+pm+s;
  end;
  info:=s;
end;

procedure dir(cd,x:astr; expanded:boolean);
var abort,next,nofiles:boolean;
    s:astr;
    onlin:integer;
    dfs:longint;
    totsize:longint;
    numfiles:integer;

function addcomma(s1:string):string;
var x1,cn:integer;
    s2:string;
begin
s2:='';
cn:=0;
for x1:=length(s1) downto 1 do begin
        s2:=s1[x1]+s2;
        inc(cn);
        if (cn=3) and (x1<>1) then begin
                s2:=','+s2;
                cn:=0;
        end;
end;
addcomma:=s2;
end;

begin
  if (copy(cd,length(cd),1)<>'\') then cd:=cd+'\';
  abort:=FALSE;
  if (fso) then begin
    sprint(' Directory of '+copy(cd,1,length(cd)-1));
    nl;
  end;
  cd:=cd+x;
  totsize:=0;
  s:=''; onlin:=0; numfiles:=0; nofiles:=TRUE;
  ffile(cd);
  while (found) and (not abort) do begin
    if (not (dirinfo.attr and directory=directory)) or (fso) then
      if (not (dirinfo.attr and volumeid=volumeid)) then
        if ((not (dirinfo.attr and dos.hidden=dos.hidden)) or (usernum=1)) then
          if ((dirinfo.attr and dos.hidden=dos.hidden) and
             (not (dirinfo.attr and directory=directory))) or
             (not (dirinfo.attr and dos.hidden=dos.hidden)) then begin
            nofiles:=FALSE;
            if (expanded) then sprint(info)
            else begin
              inc(onlin);
              s:=s+mln(dirinfo.name,12);
              if onlin<>5 then s:=s+'    ' else begin
                sprint(s);
                s:=''; onlin:=0;
              end;
            end;
            inc(numfiles);
            inc(totsize,dirinfo.size);
          end;
    nfile;
  end;
  if (not found) and (onlin in [1..5]) then sprint(s);
  dfs:=freek(exdrv(cd));
  if (nofiles) then s:='File not found'
    else s:=mrn(addcomma(cstr(numfiles)),16)+' File(s)'+mrn(addcomma(cstrl(totsize)),15)+' bytes';
  sprint(s);
  if not(nofiles) then
  sprint(mrn(addcomma(cstrl(dfs*1024)),39)+' bytes free');
end;

procedure dirf(expanded:boolean);
var fspec:astr;
    abort,next,all:boolean;
begin
  nl;
  print('Raw directory.');
  fspec:='';
  gfn(fspec); abort:=FALSE; next:=FALSE;
  nl;
  loaduboard(fileboard);
  dir(adrv(memuboard.dlpath),fspec,expanded);
end;

procedure setdirs;
var s:astr;
    i,x5:integer;
    done:boolean;
    UTAG:^TagRecordOBJ;

begin
  if (novice in thisuser.ac) then begin fbasechange(done,'L'); end;
  done:=FALSE;
  new(UTAG);
  if (UTAG=NIL) then begin
      sprint('%120%Unable to access tag records.');
      exit;
  end;
  UTAG^.Init(adrv(systat^.userpath)+hexlong(thisuser.userid)+'\'+hexlong(thisuser.userid)+'.NFT');
  UTAG^.MaxBases:=Maxulb;
  repeat
    sprompt('%030%Tag File Bases [%150%?%030%=Help] : %150%'); input(s,3);
    if (s='Q') then done:=TRUE;
    if (s='?') then begin
        nl;
        sprint('%080%[%150%L%080%] %030%Re-list File Bases');
        sprint('%080%[%150%#%080%] %030%Toggle base scan on/off for this base number');
        sprint('%080%[%150%A%080%] %030%Set all bases to be scanned');
        sprint('%080%[%150%U%080%] %030%Set all bases NOT to be scanned');
        sprint('%080%[%150%Q%080%] %030%Quit File Base tagging');
        nl;
        end;
    if (s='L') then begin
        UTAG^.Done;
        dispose(UTAG);
        fbasechange(done,'L');
        new(UTAG);
        if (UTAG=NIL) then begin
            sprint('%120%Unable to access tag records.');
            exit;
        end;
        UTAG^.Init(adrv(systat^.userpath)+hexlong(thisuser.userid)+'\'+hexlong(thisuser.userid)+'.NFT');
        Utag^.MaxBases:=Maxulb;
    end;
    i:=value(s);
    if ((i>0) and (i<=maxulb) and (s<>'')) or ((i=0) and (s='0')) then begin
    if (infconf(i)) then
    if (fbaseac(i)) then begin
        if (memuboard.tagtype=2) and not(aacs(systat^.untagmandatory)) then begin
                sprompt('|LF|%120%This is a mandatory base!|LF||LF|');
        end else begin
	nl;
        if (UTAG^.IsTagged(memuboard.baseid)) then begin
          sprint('%030%Untagging: %150%'+memuboard.name);
          UTAG^.Removetag(memuboard.baseid);
	end else begin
          sprint('%030%Tagging  : %150%'+memuboard.name);
          UTAG^.Addtag(memuboard.baseid);
	end;
	nl;
        end;
      end;
    end;
    if (s='A') then begin
            sprompt('%120%Tagging: %150%');
            for i:=0 to maxulb do
            if (infconf(i)) then
            if (fbaseac(i)) then begin
                sprompt(cstr(i));
                UTAG^.AddTag(memuboard.baseid);
                for x5:=1 to length(cstr(i)) do begin
                        prompt(^H' '^H);
                end;
            end;
            sprint('%140%All File Bases Tagged.');
            nl;
    end;
    if (s='U') then begin
            sprompt('%120%Untagging: %150%');
            for i:=0 to maxulb do
            if (infconf(i)) then
            if (fbaseac(i)) then begin{ loads memuboard }
                if (memuboard.tagtype<>2) then begin
                sprompt(cstr(i));
                UTAG^.RemoveTag(Memuboard.baseid);
                for x5:=1 to length(cstr(i)) do begin
                    prompt(^H' '^H);
                end;
                end;
            end;
            sprint('%140%All File Bases Untagged.');
            nl;
    end;
  until (done) or (hangup);
  loaduboard(fileboard);
  setc(7 or (0 shl 4));
  lastcommandovr:=TRUE;
  UTAG^.SortTags(adrv(systat^.gfilepath)+'USER'+cstrn(cnode)+'.TFT',2);
  UTAG^.Done;
  dispose(UTAG);
end;

procedure pointdate;
var s:astr;
begin
  sprompt('|LF|%030%Scan for New Files since : %150%');
  s:=newdate;
  getbirth(s,true);
  if (length(s)=10) then newdate:=s;
end;

procedure yourfileinfo;
begin
   lil:=0;
   printf('FILEINFO');
   if (nofile) then begin
        nl;
        sprint('File Info Screen not found.');
        sl1('!','FILEINFO.* not found.');
   end;
end;

end.

{$A+,B+,D-,E+,F+,I+,L+,N-,O+,R-,S+,V-}
unit sysop11;

interface

uses
  crt, dos, misc1, miscx,
  menus2,
  common;

procedure chuser;
procedure showlogs;

implementation

procedure chuser;
var s:astr;
    i:integer;
begin
  sprompt('%030%Change to which user? %150%');
  finduser(s,i);
  if (i>=1) then begin
    thisuser.sl:=realsl;

    reset(uf);
    seek(uf,usernum); write(uf,thisuser);
    seek(uf,i); read(uf,thisuser);
    close(uf);

    realsl:=thisuser.sl;
    usernum:=i;
    choptime:=0.0; extratime:=0.0; freetime:=0.0;

    if (spd<>'KB') then sl1('u','Changed to '+nam);
    topscr;
  end;
end;

procedure showlogs;
var x:integer;
    S: string;
begin
  cls;
  sprompt('%030%Show logs for which node [%150%ENTER%030%=Quit] : %150%');
  defaultst:=cstr(cnode);
  inputdef(s,3,'u');
  x:=value(s);
  if (x=0) then exit;
  sprint('%080%ÄÄÄ[%150%Nexus Logs - Node '+cstr(x)+'%080%]ÄÄÄ');
  nl;
  printf(systat^.trappath+'nex'+cstrn(x)+'.log');
  if (nofile) then begin nl; print('NEX'+cstrn(x)+'.LOG : File not found.'); end;
  
  if (useron) then begin
    sl1('*','Viewed Nexus logs for node '+cstr(x));
  end;
end;

end.

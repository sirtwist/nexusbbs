{$A+,B+,D-,E+,F+,I+,L+,N-,O+,R-,S+,V-}
unit execbat;

interface

uses
  crt, dos, 
  common,
  myio3;

var
  sx,sy:integer;
  savtw:boolean;

procedure execbatch(var ok:boolean; showit:boolean;
                    bfn,tfn,dir,batline:astr; oklevel:integer);
{procedure pexecbatch(showit:boolean; bfn,tfn,dir,batline:astr;
                     var retlevel:integer);}
procedure shel(s:astr);
procedure shel1;
procedure shel2;

implementation

procedure execbatch(var ok:boolean;     { result                     }
                    showit:boolean;     { show working on user side  }
                    bfn:astr;           { .BAT filename              }
                    tfn:astr;           { temporary testing file     }
                    dir:astr;           { directory takes place in   }
                    batline:astr;       { .BAT file line to execute  }
                    oklevel:integer);   { DOS errorlevel for success }
var bfp:text;
    odir,todev:astr;
    i,rcode:integer;
    si:boolean;
begin
  si:=TRUE;
  case shelling of
        1:si:=systat^.showlocaloutput;
        2:si:=systat^.showlocaloutput2;
  end;
  todev:=' >nul';
  if ((showit) and (incom)) then
    todev:=' >'+systat^.remdevice+' <'+systat^.remdevice
  else
    if ((wantout) and (si)) then todev:=''; {' >con';}

  getdir(0,odir);
  dir:=fexpand(dir);
  while copy(dir,length(dir),1)='\' do dir:=copy(dir,1,length(dir)-1);
  assign(bfp,bfn);
  rewrite(bfp);
  writeln(bfp,'@echo off');
  writeln(bfp,chr(exdrv(dir)+64)+':');
  writeln(bfp,'cd '+dir);
  writeln(bfp,batline+todev);
  writeln(bfp,':done');
  writeln(bfp,'cd \');
  writeln(bfp,chr(exdrv(odir)+64)+':');
  writeln(bfp,'cd '+odir);
  writeln(bfp,'exit');
  close(bfp);
  
  if ((wantout) and (si)) then begin
    tc(15); textbackground(1); clreol; write(batline); clreol;
    tc(7); textbackground(0); writeln;
  end;
  {if (todev=' >con') then todev:='' else todev:=' >nul';}

  rcode:=oklevel;

  shelldos(FALSE,bfn+todev,rcode);
  
  if (exist(bfn)) then {$I-} erase(bfp); {$I+}
  chdir(start_dir);
  if (oklevel<>-1) then ok:=(rcode=oklevel) else ok:=TRUE;
end;

(* procedure pexecbatch(showit:boolean;     { show working on user side  }
                     bfn:astr;           { .BAT filename              }
                     tfn:astr;           { UNUSED -----------         }
                     dir:astr;           { directory takes place in   }
                     batline:astr;       { .BAT file line to execute  }
                 var retlevel:integer);  { DOS errorlevel returned    }
var tfp,bfp:text;
    odir,todev:astr;
    si:boolean;
begin
  si:=TRUE;
  case shelling of
        1:si:=systat^.showlocaloutput;
        2:si:=systat^.showlocaloutput2;
  end;
  todev:=' >nul';
  if (showit) and (incom) then
    todev:=' >'+systat^.remdevice+' <'+systat^.remdevice
  else
    if ((wantout) and (si)) then todev:='';{ >con';}

  getdir(0,odir);
  dir:=fexpand(dir);
  while copy(dir,length(dir),1)='\' do dir:=copy(dir,1,length(dir)-1);
  assign(bfp,bfn);
  rewrite(bfp);
  writeln(bfp,'@echo off');
  writeln(bfp,chr(exdrv(dir)+64)+':');
  writeln(bfp,'cd '+dir);
  writeln(bfp,batline+todev);
  writeln(bfp,'cd \');
  writeln(bfp,':done');
  writeln(bfp,chr(exdrv(odir)+64)+':');
  writeln(bfp,'cd '+odir);
  writeln(bfp,'exit');
  close(bfp);

  if ((wantout) and (si)) then begin
    tc(15); textbackground(1); clreol; write(batline); clreol;
    tc(7); textbackground(0); writeln;
  end;
  {if (todev=' >con') then todev:='' else todev:=' >nul';}

  shelldos(FALSE,bfn+todev,retlevel);

  if (exist(bfn)) then {$I-} erase(bfp); {$I+}
  chdir(start_dir);
end; *)

procedure shel(s:astr);
var si:boolean;
begin
    sx:=wherex; sy:=wherey;
    si:=TRUE;
    case shelling of
        1:si:=systat^.showlocaloutput;
        2:si:=systat^.showlocaloutput2;
    end;
    savescreen(w,1,1,80,24);
    if (s<>'') and (si) then begin
        clrscr;
        textbackground(1); tc(15); clreol;
        write(copy(s,1,79));
        textbackground(0); tc(7);
    end;
end;

procedure shel1;
begin
  shel('');
end;

procedure shel2;
begin
  window(1,1,80,24);
  clrscr;
  removewindow(w);
  window(1,1,80,24);
  if (sy=25) then begin
          writeln;
          sy:=24;
  end;
  gotoxy(sx,sy);
  topscr;
end;

end.

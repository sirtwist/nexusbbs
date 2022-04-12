{$O+}
unit fbm3;

interface

uses dos,crt,myio,misc,fbcommon,cdrom3,mkmisc,mkstring,editdesc,spawno,
        procs2,nxfs2,sysop20,fbm2;

var ox,oy,x1,x2,y1,y2:integer;
    restscr:windowrec;

procedure clearscreen;
procedure restorescreen;
procedure arcbatch(var ok:integer;      { result                     }
                    dir:astr;           { directory takes place in   }
                    batline:astr);     { .BAT file line to execute  }
function showblocks(l2:longint):STRING;

implementation

uses fbm4;

procedure clearscreen;
begin
  x1:=lo(windmin)+1;
  y1:=hi(windmin)+1;
  x2:=lo(windmax)+1;
  y2:=lo(windmax)+1;
  ox:=wherex;
  oy:=wherey;
  savescreen(restscr,1,1,80,25);
  window(1,1,80,25);
  clrscr;
end;

procedure restorescreen;
begin
  removewindow(restscr);
  window(x1,y1,x2,y2);
  gotoxy(ox,oy);
end;

procedure arcbatch(var ok:integer;      { result                     }
                    dir:astr;           { directory takes place in   }
                    batline:astr);     { .BAT file line to execute  }
var odir:string;
    rcode:integer;
begin
  getdir(0,odir);
  dir:=fexpand(dir);
  bslash(FALSE,dir);
  {$I-} chdir(chr(exdrv(dir)+64)+':'); {$I+}
  if (ioresult<>0) then exit;
  {$I-} chdir(dir); {$I+}
  if (ioresult<>0) then exit;


  shelldos(batline,rcode);


  {$I-} chdir('\'); {$I+}
  if (ioresult<>0) then begin end;
  {$I-} chdir(chr(exdrv(odir)+64)+':'); {$I+}
  if (ioresult<>0) then begin end;
  {$I-} chdir(odir); {$I+}
  if (ioresult<>0) then begin end;

  ok:=rcode;
end;

  function showblocks(l2:longint):STRING;
  var tstr,tstr2:string;
      ti:integer;
  begin
  if (l2>1024) then begin
        tstr:=cstr(l2 div 1024);
        tstr2:=cstr(trunc(((l2 mod 1024)/1024)*100));
        while (length(tstr2)<2) do tstr2:='0'+tstr2;
        ti:=value(copy(tstr2,1,1));
        if (ti>4) then inc(ti);
        if (ti=10) then begin
                tstr:=cstr((l2 div 1024)+1);
                ti:=0;
        end;
        showblocks:=tstr+'.'+cstr(ti)+'M';
  end else begin
        showblocks:=cstr(l2)+'k';
  end;
  end;

end.

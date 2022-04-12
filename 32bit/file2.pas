{$A+,B+,D-,E+,F+,I+,L+,N-,O+,R-,S+,V-}
unit file2;

interface

uses
  crt, dos, 
  execbat, common;

procedure copyfile(var ok,nospace:boolean; showprog:boolean;
                   srcname,destname:astr);
procedure movefile(var ok,nospace:boolean; showprog:boolean;
                   srcname,destname:astr);

implementation

procedure copyfile(var ok,nospace:boolean; showprog:boolean;
                   srcname,destname:astr);
var buffer:array[1..16384] of byte;
    totread,fs,dfs:longint;
    nrec,i,x,x2:integer;
    src,dest:file;

  procedure dodate;
  var r:registers;
      od,ot,ha:integer;
  begin
    srcname:=srcname+#0;
    destname:=destname+#0;
    with r do begin
      ax:=$3d00; ds:=seg(srcname[1]); dx:=ofs(srcname[1]); msdos(dos.registers(r));
      ha:=ax; bx:=ha; ax:=$5700; msdos(dos.registers(r));
      od:=dx; ot:=cx; bx:=ha; ax:=$3e00; msdos(dos.registers(r));
      ax:=$3d02; ds:=seg(destname[1]); dx:=ofs(destname[1]); msdos(dos.registers(r));
      ha:=ax; bx:=ha; ax:=$5701; cx:=ot; dx:=od; msdos(dos.registers(r));
      ax:=$3e00; bx:=ha; msdos(dos.registers(r));
    end;
  end;

begin
  ok:=TRUE; nospace:=FALSE;
  assign(src,srcname);
  filemode:=64;
  {$I-} reset(src,1); {$I+}
  if (ioresult<>0) then begin ok:=FALSE; exit; end;
  dfs:=freek(exdrv(destname));
  fs:=trunc(filesize(src)/1024.0)+1;
  if (fs>=dfs) then begin
    close(src);
    nospace:=TRUE; ok:=FALSE;
    exit;
  end else begin
    fs:=filesize(src);
    assign(dest,destname);
    filemode:=66;
    {$I-} rewrite(dest,1); {$I+}
    if (ioresult<>0) then begin ok:=FALSE; exit; end;
    if (showprog) then begin
      sprompt('%150%0% %120%');
      setc(9 or (0 shl 4));
    end;
    x:=1;
    totread:=0;
    repeat
      filemode:=64;
      blockread(src,buffer,16384,nrec);
      filemode:=66;
      blockwrite(dest,buffer,nrec);
      totread:=totread+nrec;
      if (showprog) then begin
        for x2:=x to 10 do begin
        if (totread>=((fs div 10)*x2)) then begin
                prompt('²');
                inc(x);
                end;
        end;
      end;
      until (nrec<16384);
      if (showprog) then begin
      sprint('%150% 100%');
      end;
    filemode:=66;
    close(dest);
    filemode:=64;
    close(src);
    filemode:=66;
    dodate;
  end;
end;

function substall(src,old,anew:astr):astr;
var p:integer;
begin
  p:=1;
  while p>0 do begin
    p:=pos(old,src);
    if p>0 then begin
      insert(anew,src,p+length(old));
      delete(src,p,length(old));
    end;
  end;
  substall:=src;
end;

procedure movline(var src:astr; s1,s2:astr);
begin
  src:=substall(src,'@F',s1);
  src:=substall(src,'@I',s2);
end;

procedure movefile(var ok,nospace:boolean; showprog:boolean;
                   srcname,destname:astr);
var dfs,dft:integer;
    f:file;
    s,s1,s2,s3,opath:astr;
begin
  ok:=TRUE; nospace:=FALSE;

  getdir(0,opath);
  assign(f,srcname);
  filemode:=64;
  {$I-} reset(f,1); {$I+}
  if (ioresult=0) then begin
  dft:=trunc(filesize(f)/1024.0)+1; close(f);
  end;

  dfs:=freek(exdrv(destname));
  copyfile(ok,nospace,showprog,srcname,destname);
  if ((ok) and (not nospace)) then begin
    filemode:=17;
    {$I-} erase(f); {$I+}
    if (ioresult<>0) then begin
    sl1('!','Error Removing File '+srcname);
    end;
  end;
  chdir(opath);
  filemode:=66;
end;

end.

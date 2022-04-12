unit fbcommon;

interface

uses misc;
{$I BUILD4.INC}

const dlpath:string='';
      dlpath2:string='';
      cbase:integer=-1;
      nbase:integer=-1;
      line2:string='';
      cd1:boolean=FALSE;
      cd2:boolean=FALSE;
      writerecno:integer=-1;

var ff:file of ulrec;
    f:ulrec;
    cdavail:array[1..26] of word;

function align(fn:astr):astr;

implementation

function align(fn:astr):astr;
var f,e,t:astr; c,c1:integer;
begin
  c:=pos('.',fn);
  if (c=0) then begin
    f:=fn; e:='   ';
  end else begin
    f:=copy(fn,1,c-1); e:=copy(fn,c+1,3);
  end;
  f:=mln(f,8);
  e:=mln(e,3);
  c:=pos('*',f); if (c<>0) then for c1:=c to 8 do f[c1]:='?';
  c:=pos('*',e); if (c<>0) then for c1:=c to 3 do e[c1]:='?';
  c:=pos(' ',f); if (c<>0) then for c1:=c to 8 do f[c1]:=' ';
  c:=pos(' ',e); if (c<>0) then for c1:=c to 3 do e[c1]:=' ';
  align:=f+'.'+e;
end;

end.

(*    APS - Archive Processing System
 *    Copyright 1993 by Intuitive Vision Software.  All rights reserved.
 *
 *    APS produces a listing of files contained in an archive file.
 *    Archive formats supported by APS include:
 *
 *      ARC - Developed by System Enhancement Associates
 *           and enhanced by PKWARE (PKARC & PKPAK)
 *           and NoGate Consulting (PAK)
 *      LZH - Developed by Haruyasu Yoshizaki
 *      ZIP - Developed by PKWARE
 *      ZOO - Developed by Rahul Dhesi
 *
 *    Version history:
 *
 *    0.10 04/11/93 Pre-Beta Release.
 *)

{$A+,B+,D-,E+,F+,I+,L+,N-,O+,R-,S+,V-}
unit file4;

interface

uses
  crt, dos,
  common;

procedure lfi(fn:string; var abort,next:boolean);
procedure lfii;

implementation

uses file0, file14, archive2;

function substall(src,old,anew:string):string;
var p:integer;
    newstr:string;
begin
  newstr:='';
  p:=1;
  while p>0 do begin
    p:=pos(allcaps(old),allcaps(src));
    if (p>0) then begin
      newstr:=newstr+copy(src,1,p-1)+anew;
      src:=copy(src,p+length(old),length(src));
    end;
  end;
  if (src<>'') then newstr:=newstr+src;
  substall:=newstr;
end;

procedure lfi(fn:string; var abort,next:boolean);
Var fp:file;
    rcode : integer;
    showfn,temp  : string;
begin
        showfn:=stripname(fn);
        temp:=adrv(systat^.utilpath)+'NXAVIEW.EXE '+fn;
        currentswap:=modemr^.swaparchiver;
        rcode:=0;
        shelldos(FALSE,temp+' '+newtemp+'APSSHELL.$$$',rcode);
        currentswap:=0;
        printingfile:=TRUE;
        mpausescr:=TRUE;
        pfl(newtemp+'APSSHELL.$$$',abort,next,TRUE);
        if (nofile) then print('Unable to display file contents.');
        if not(abort) then nl;
        mpausescr:=FALSE;
        printingfile:=FALSE;
        assign(fp,newtemp+'APSSHELL.$$$');
        {$I-} erase(fp); {$I+}
        if (ioresult<>0) then begin end;
end;

procedure lfii;
var fn:astr;
    instr:string;
    x,y,pl,rn,which:integer;
    c:char;
    orn,olrn:integer;                  { last record # for recno/nrecno        }
    olfn:string;                     { last filename for recno/nrecno        }
    abort,next,lastarc,isgif:boolean;
begin
  sprompt(gstring(500));
  instr:=gstring(502);
  if (length(instr)<4) then instr:='VNQ?';
  instr:=instr+^M;
  fn:='';
  gfn(fn); abort:=FALSE; next:=FALSE;
  recno(fn,pl,rn);
  if (baddlpath) then exit;
  abort:=FALSE; next:=FALSE; lastarc:=fALSE;
  while ((rn<>0) and (not abort)) do begin
    cls;
    NXF.Seekfile(rn);
    NXF.Readheader;
    lfi(adrv(memuboard.dlpath)+NXF.Fheader.filename,abort,next);
    abort:=FALSE;
    if not(next) then
    repeat
    lil:=0;
    sprompt(gstring(501));
    onek(c,instr);
    which:=pos(c,instr);
    case which of
        3:begin
                abort:=TRUE;
                next:=FALSE;
          end;
        2,5:nrecno(fn,pl,rn);
        4:begin
                sprompt(gstring(503));
                sprompt(gstring(504));
                sprompt(gstring(505));
                if (fso) then
                sprompt(gstring(506));
                sprompt(gstring(507));
            end;
    end;
    until (which<>4);
    next:=FALSE;
  end;
end;

end.

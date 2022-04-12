{----------------------------------------------------------------------------}
{ Next Epoch matriX User System - Nexus BBS Software                         }
{                                                                            }
{ All material contained herein is (c) Copyright 1995-96 Intuitive Vision    }
{ Software.  All Rights Reserved.                                            }
{                                                                            }
{ MODULE     :  FILE25.PAS (File System Listing Unit)                        }
{ AUTHOR     :  George A. Roberts IV                                         }
{                                                                            }
{----------------------------------------------------------------------------}
{ Intuitive Vision Software is a Division of Intuitive Vision Computer       }
{ Services.  Nexus, Next Epoch matriX User System, and ivOMS are Trademarks  }
{ of Intuitive Vision Software.                                              }
{----------------------------------------------------------------------------}

{$A+,B+,D-,E+,F+,I+,L+,N-,O+,R-,S+,V-}
unit file25;

interface

uses
  crt, dos, file0, file1, file2, file4, file8, file9, file11,
  common;

function browse(tempbase:integer;fname:astr;dta,ts:astr;newf:byte;var quit:boolean):boolean;
function isflagged(s:string;fb:integer):boolean;

implementation

uses archive1, file6, myio3, file12;

    
function isulr:boolean;
begin
  isulr:=((systat^.uldlratio) and (not systat^.fileptratio));
end;

function isflagged(s:string;fb:integer):boolean;
var batchf:file of flaggedrec;
    batch:flaggedrec;
begin
  assign(batchf,adrv(systat^.temppath)+'FLAG'+cstrn(cnode)+'.DAT');
  filemode:=64;
  {$I-} reset(batchf); {$I+}
  if (ioresult<>0) then begin
        isflagged:=FALSE;
        exit;
  end else begin
        while not(eof(batchf)) do begin
                read(batchf,batch);
                if ((allcaps(s)=allcaps(stripname(batch.filename))) and
                        (fb=batch.filebase)) then begin
                                isflagged:=TRUE;
                                close(batchf);
                                exit;
                        end;
        end;
  close(batchf);
  end;
  isflagged:=FALSE;
end;

function u_daynum2(dt:string):longint;
var d,m,y,c,h,min,s,count:integer;
    t:longint;
begin
  t:=0;
  m:=value(copy(dt,1,2));
  d:=value(copy(dt,4,2));
  y:=value(copy(dt,7,4));
  h:=0;
  min:=0;
  s:=0;
  count:=1;                           
  for c:=1970 to y-1 do
    if (leapyear(c)) then t:=t+(366*86400) else t:=t+(365*86400);
  t:=t+((daycount(m,y)+(d-1))*86400);
  u_daynum2:=t;
  if y<1970 then u_daynum2:=0;
end;

function browse(tempbase:integer;fname:astr;dta,ts:astr;newf:byte;var quit:boolean):boolean;
var newfile,found,display,titleshown,showingtitle2,showingtitle,next,showfile,ok,sr,done1,done,abort:boolean;
    oldboard:integer;
    lines:array[1..3] of string;
    batchf:file of flaggedrec;
    batch:flaggedrec;
    dd,dd2:string;
    filenum:array[1..20] of integer;
    c:char;
    i8,i9,flf,numadd,x,x2,numnew,perpage:integer;
    num:byte;
    li:longint;
    i2,i,lasttopp,pl:integer;
    nlines:integer;
    s,s1,s2,s3:string;
    lrg:boolean;

  procedure getpause;
  var x,x2,i:integer;
      s2:string;
      down:boolean;
  begin
    repeat
    skipcommand:=FALSE;
    nl;
    sprompt(gstring(403));
    if (newf<>0) then begin
    s:=allcaps(gstring(405))+^M;
    end else begin
    s:=allcaps(gstring(404))+^M;
    end;
    semaphore:=TRUE;
    scaninput(s2,s,TRUE);
    until not(skipcommand) or (hangup);
    if (showingtitle) then bnp:=FALSE;
    if not(hangup) then
    if (value(s2)<>0) and (s2<>'') then begin
            if (value(s2)>=1) and (value(s2)<=pl) then topp:=value(s2)
                 else topp:=lasttopp;
            newfile:=TRUE;
            if (topp=1) then begin
                showingtitle:=TRUE;
                bnp:=FALSE;
            end else begin
                showingtitle2:=TRUE;
            end;
    end else
    if (s2<>'') then
    case (pos(s2[1],s)) of
          1:begin
            infilelist:=TRUE;
            dlflag:=TRUE;
            fflag:=FALSE;
            idl;
            infilelist:=false;
            fiscan(pl);
            topp:=lasttopp;
            newfile:=TRUE;
            if (topp=1) then begin
                showingtitle:=TRUE;
                bnp:=FALSE;
            end else begin
                showingtitle2:=TRUE;
            end;
          end;
         2:begin
            down:=TRUE;
  if (not intime(timer,modemr^.dllowtime[getdow+1],modemr^.dlhitime[getdow+1])) then 
  begin
        printf('DLHOURS');
        down:=FALSE;
  end;
  if (answerbaud<modemr^.minimumbaud) then
    if (not intime(timer,modemr^.lockbegin_dltime[getdow+1],modemr^.lockend_dltime[getdow+1])) then begin
      printf('LOCKHRS');
      down:=FALSE;
      end;
            if (down) then begin
            repeat             
            sprompt(gstring(418));
            inputdef(s,20,'LN');
            if (s<>'') then
            if (s[1]='?') then begin
              sprompt(gstring(445));
              sprompt(gstring(446));
              sprompt(gstring(447));
              sprompt(gstring(448));
              sprompt(gstring(449));
            end;
            until (copy(s,1,1)<>'?') or (hangup);
              done1:=FALSE; numadd:=0;
              x:=0;      s2:='';
              s3:=s;
              lrg:=FALSE;
              if (s<>'') then
                repeat
                repeat
                  inc(x);
                  s2:=s2+s[x];
                until (s[x+1]=',') or (s[x+1]='-') or (x+1>length(s));
                if (s[x+1]=',') or (x+1>length(s)) then begin
                  s:=copy(s,x+2,length(s)-x+1);
                  if (lrg) then begin
                        i2:=value(s2);
                        for x:=i to i2 do begin
                        if ((x>=1) and (x<=NXF.Numfiles)) then begin
                                inc(numadd); filenum[numadd]:=x;
                        end; 
                        end;
                        lrg:=FALSE;
                  end else
                  if ((value(s2)>=1) and (value(s2)<=NXF.Numfiles)) then begin
                    inc(numadd); filenum[numadd]:=value(s2);
                  end; 
                end else begin
                  s:=copy(s,x+2,length(s)-x+1);
                  i:=value(s2);
                  lrg:=TRUE;
                end;

                x:=0;
                s2:='';
                if (s='') then done1:=TRUE;
            until (done1) or (numadd=20);
            done1:=FALSE;
            x:=0;
            nl;
            if ((not done1) and (numadd<>0)) then begin
              nl;
              for i:=1 to numadd do begin
                  NXF.Seekfile(filenum[i]);
                  NXF.ReadHeader;
                  done1:=false;
                  assign(batchf,adrv(systat^.temppath)+'FLAG'+cstrn(cnode)+'.DAT');
                  {$I-} reset(batchf); {$I+}
                  if (ioresult=0) then begin
                  i2:=1;
                  while (i2<=numbatchfiles) and not(eof(batchf)) do begin
                       read(batchf,batch);
                       if (allcaps(adrv(memuboard.dlpath)+sqoutsp(NXF.Fheader.filename))=
                                allcaps(batch.filename))
                                then begin
                                        done1:=TRUE;
                                end;
                  end;
                  close(batchf);
                  end;
                  if not(done1) then begin
        flf:=ymbadd(adrv(memuboard.dlpath)+NXF.Fheader.filename);
        case flf of
               -1:begin
                  sprint('%150%'+NXF.Fheader.filename+' %030%has been requested.');
                  inc(x);
                  end;
                0:begin
                  sprint('%030%Flagged File: %150%'+NXF.Fheader.filename);
                  end;
                else begin
                sprint('%150%'+NXF.Fheader.filename+' %030%- '+showflagfile(flf));
                end;
        end;
                  end else begin
                        sprint('%150%'+NXF.Fheader.filename+' %030%is already flagged.');
                        inc(x);
                  end;
                 end;
              end;
            numadd:=numadd-x;
            if (numadd<0) then numadd:=0;
            if (numadd>0) then begin
            nl;
            sprint('%030%Flagged: %150%'+cstr(numadd)+' %030%Total Flagged: %150%'+cstr(numbatchfiles));
            end;
            if (s3<>'') then pausescr;
            end;
            setc(7 or (0 shl 4));
            topp:=lasttopp;
            newfile:=TRUE;
            bnp:=TRUE;
            if (topp=1) then begin
                showingtitle:=TRUE;
                bnp:=FALSE;
            end else begin
                showingtitle2:=TRUE;
            end;
         end;
       3:begin
          sprompt(gstring(420));
          input(s,4);
          if ((value(s)>=1) and (value(s)<=pl)) then begin
                nl;
                NXF.Seekfile(value(s));
                NXF.Readheader;
                if (cansee(NXF.Fheader)) then begin
                cls;
                fileinfo2(FALSE,abort,next);
                pausescr;
                end;
                topp:=lasttopp;
            newfile:=TRUE;
                cls;
          end;
            if (topp=1) then begin
                showingtitle:=TRUE;
                bnp:=FALSE;
            end else begin
                showingtitle2:=TRUE;
            end;
        end;
      4:begin
                done:=TRUE;
                if not(newf=0) then abort:=true;
        end;
     5:begin
                sprompt(gstring(430));
                sprompt(gstring(431));
                sprompt(gstring(432));
                sprompt(gstring(433));
                sprompt(gstring(434));
                if(newf<>0) then begin
                case newf of
                        1:sprompt(gstring(435));
                        2:sprompt(gstring(436));
                end;
                end;
                sprompt(gstring(437));
                sprompt(gstring(438));
                topp:=lasttopp;
            newfile:=TRUE;
            if (topp=1) then begin
                showingtitle:=TRUE;
                bnp:=FALSE;
            end else begin
                showingtitle2:=TRUE;
            end;
        end;
      6:if (newf<>0) then begin
                done:=TRUE;
        end else begin
          nl;
          if (topp>pl) then done:=TRUE else begin
          dec(lil);
          nl;
            if (topp=1) then begin
                showingtitle:=TRUE;
                bnp:=FALSE;
            end else begin
                showingtitle2:=TRUE;
            end;
          end;
          bnp:=TRUE;
        end;
      7:begin
          nl;
          if (topp>pl) then done:=TRUE else begin
          dec(lil);
          nl;
            if (topp=1) then begin
                showingtitle:=TRUE;
                bnp:=FALSE;
            end else begin
                showingtitle2:=TRUE;
            end;
          end;
          bnp:=TRUE;
        end;
      end;
  end;

  function numdesclines:integer;
  var i:integer;
      s3:string;
  begin
  i:=1;
  NXF.DescStartup;
  s3:='';
  while (s3<>#1+'EOF'+#1) do begin
        s3:=NXF.GetDescLine;
        if (s3=#1+'EOF'+#1) then begin end else inc(i);
  end;
  if (pos('|FLDESC|',allcaps(lines[1]))=0) then inc(i);
  if (lines[3]<>'') then inc(i);
  numdesclines:=i;
  end;

  function numdesclines2:integer;
  var i:integer;
      s3:string;
  begin
  i:=0;
  NXF.DescStartup;
  s3:='';
  while (s3<>#1+'EOF'+#1) do begin
        s3:=NXF.GetDescLine;
        if (s3=#1+'EOF'+#1) then begin end else inc(i);
  end;
  numdesclines2:=i;
  end;

begin
if (tempbase<>-1) then begin
oldboard:=fileboard;
changefileboard(tempbase);
if (tempbase<>fileboard) then begin
        loaduboard(fileboard);
        exit;
end;
if not(fbaseac(tempbase)) then begin
        sprompt('%120%You do not have access to this base.');
        pausescr;
        exit;
end;
end;
lasttopp:=1;
topp:=1;
abort:=FALSE;
done:=FALSE;
showingtitle:=FALSE;
showingtitle2:=FALSE;
titleshown:=FALSE;
listing_files:=TRUE;
newfile:=TRUE;
found:=FALSE;
display:=FALSE;
lines[1]:=gstring(377);
lines[2]:=gstring(378);
lines[3]:=gstring(379);
curdesc:=1;
if (newf=2) and (ts<>'') then fsearchtext:=ts;
perpage:=thisuser.pagelen - (getnumstringlines(gstring(403))+1);
  fiscan(pl);  { loads memuboard }
  numnew:=0;
  if (pl=0) then begin
  if (newf=1) then sprompt(gstring(54));
  if (newf=0) then begin
        sprompt(gstring(402));
        end;
  listing_files:=FALSE;
  browse:=FALSE;
  exit;
  end;
  topp:=1;
  lasttopp:=1;
  repeat
           if (newfile) then begin
           found:=FALSE;
           display:=FALSE;
           while not(found) and (topp<=pl) do begin
           NXF.Seekfile(topp);
           NXF.Readheader;
           totaldesclines:=numdesclines;
           nlines:=numdesclines2;
           case newf of
                0:begin
                        if (cansee(NXF.Fheader)) then begin
                                found:=TRUE;
                                if (totaldesclines<=perpage-lil) or ((showingtitle) or (showingtitle2))
                                then display:=TRUE;
                        end;
                  end;
                1:begin
                        if ((cansee(NXF.Fheader)) and ((NXF.Fheader.Uploadeddate>=u_daynum(newdate)) or
                        (ffnotval in NXF.Fheader.fileflags))) then begin
                                found:=TRUE;
                                if (totaldesclines<=perpage-lil) or ((showingtitle) or (showingtitle2))
                                then display:=TRUE;
                        end;
                  end;
                2:begin
                        ok:=false;
                        sr:=fit(align(fname),align(NXF.Fheader.filename));
                        if (cansee(NXF.Fheader) and (sr)) then begin
                        NXF.DescStartup;
                        s:=NXF.GetDescLine;
                        if (ts='') then ok:=TRUE else
                        ok:=(((pos(allcaps(ts),allcaps(s))<>0) or
                                (pos(allcaps(ts),allcaps(NXF.Fheader.filename))<>0)) and
                                (NXF.Fheader.uploadeddate>=u_daynum(dta)));
                        if (not ok) and (NXF.Fheader.uploadeddate>=u_daynum(dta)) then
                                        i:=2;
                                        s:='';
                                while (s<>#1+'EOF'+#1) and (i<=syst.ndesclines) and (not ok) do begin
                                s:=NXF.GetDescLine;
                                if pos(allcaps(ts),allcaps(s))<>0 then ok:=TRUE;
                                inc(i);
                                end;
                        end;
                        if (ok) then begin
                                found:=TRUE;
                                if (totaldesclines<=perpage-lil) or ((showingtitle) or (showingtitle2))
                                then display:=TRUE;
                        end;
                  end;
           end;
           if not(found) then inc(topp);
           end;
           end;
           if (display) then begin
           if not(titleshown) then begin
                showingtitle:=TRUE;
                titleshown:=TRUE;
           end;
           if (showingtitle) then begin
                sprompt(gstring(390));
                sprompt(gstring(391));
                sprompt(gstring(392));
                sprompt(gstring(393));
                showingtitle:=FALSE;
           end;
           if (showingtitle2) then begin
                sprompt(gstring(394));
                sprompt(gstring(395));
                sprompt(gstring(396));
                sprompt(gstring(397));
                showingtitle2:=FALSE;
           end;
                if (newf<>0) then inc(numnew);
                if (newfile) then begin
                        NXF.DescStartup;
                        sprompt(lines[1]);
                        newfile:=FALSE;
                end else begin
                        if (curdesc>nlines) then begin
                                sprompt(lines[3]);
                                curdesc:=1;
                                newfile:=TRUE;
                                inc(topp);
                        end else
                        begin
                        sprompt(lines[2])
                        end;
                end;
                if ((lil>=perpage) or (topp>pl)) and
                    (((newf<>0) and (numnew>0)) or (newf=0)) then begin
                      getpause;
                      lasttopp:=topp;
                end;
           end else begin
                if ((totaldesclines>perpage-lil) or (topp>pl)) and
                    (((newf<>0) and (numnew>0)) or (newf=0)) then begin
                        getpause;
                        lasttopp:=topp;
                end;
           end;
           if ((newf<>0) and (numnew=0)) then begin
                wkey(abort,next);
                if (topp>pl) then done:=TRUE;
           end;
   until (done) or (abort) or (hangup);
   quit:=abort;
   if (newf<>0) then begin
        if (numnew=0) then browse:=FALSE else browse:=TRUE;
   end else browse:=TRUE;
fsearchtext:='';
listing_files:=FALSE;
end;

end.

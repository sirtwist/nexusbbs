{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
{                        Next Epoch matriX User System                       }
{                                                                            }
{                            Module: MENUS2.PAS                              }
{                                                                            }
{                                                                            }
{ All Material Contained Herein Is Copyright 1995 Intuitive Vision Software. }
{                            All Rights Reserved.                            }
{                                                                            }
{                       Written By George A. Roberts IV                      }
{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
{$A+,B+,D-,E+,F+,I+,L+,N-,O+,R-,S+,V-}
unit menus2;

interface

uses
  crt, dos, 
  file4,
  common;

var menur:menurec;
    mf:file of menurec;
    cmdr:array[1..50] of commandrec; { command information                }
    noc:integer;                  { # of commands on menu                 }
    globcmds:byte;
    globc:array[1..20] of commandrec;
    menustack:array[1..8] of word;{ menu stack                     }
    menustackptr:byte;            { menu stack pointer                    }

procedure readin(t:boolean);
procedure readingl;
procedure showcmds;
function oksecurity(i:integer; var cmdnothid:boolean):boolean;
procedure genericmenu(t:integer);
procedure showthismenu;

implementation

procedure readin(t:boolean);
var s,lcmdlistentry:astr;
    mdf:file of commandrec;
    x,e1,e2,i,j:integer;
    b:boolean;
    langname:string;
begin
  cmdlist:='';
  noc:=0;
  assign(mf,adrv(systat^.gfilepath)+menufname+'.NXM');
  {$I-} reset(mf); {$I+}
  if (ioresult<>0) then begin
        sl1('!','Error reading '+menufname+'.NXM.  Hanging up...');
        print('Critical error:  Disconnecting...');
        hangup2:=TRUE;
  end;
  if (hangup) then exit;
  if (curmenu-1<=filesize(mf)-1) then seek(mf,curmenu-1)
        else begin
                sl1('!','Menu #'+cstr(curmenu)+' not defined.');
                print('Menu is not available!  Please let your Sysop know!');
                print('Critical error:  Disconnecting...');
                hangup2:=TRUE;
        end;
  if (not hangup) then begin
    read(mf,menur);
    assign(mdf,adrv(systat^.menupath)+menur.mnufile+'.MNU');
    {$I-} reset(mdf); {$I+}
    if (ioresult<>0) then begin
        sl1('!','.MNU file does not exist. Fallback...');
        curmenu:=menur.fallback;
        sl1('t',cstr(curmenu));
        if (curmenu-1<=filesize(mf)-1) then seek(mf,curmenu-1)
        else begin
                sl1('!','Menu Not Defined.');
                print('Critical error:  Disconnecting...');
                hangup2:=TRUE;
        end;
        read(mf,menur);
        assign(mdf,adrv(systat^.menupath)+menur.mnufile+'.MNU');
        {$I-} reset(mdf); {$I+}
        if (ioresult<>0) then begin
                sl1('!','Fallback menu (*.MNU) does not exist.  Hanging up...');
                print('Critical error: Disconnecting...');
                hangup2:=TRUE;
         end;
    end;
    if (hangup) then exit;
    repeat
      inc(noc);
      read(mdf,cmdr[noc]);
    until (eof(mdf));
{    if (curmenu in [ }
    close(mdf);
    close(mf);

    if (t) and (noloadglobal in menur.menuflags) then t:=FALSE;

    if (t) then begin
    for x:=1 to globcmds do begin
      inc(noc);
      with cmdr[noc] do begin
        ldesc:=globc[x].ldesc;
        sdesc:=globc[x].sdesc;
        ckeys:=globc[x].ckeys;
        acs:=globc[x].acs;
        cmdkeys:=globc[x].cmdkeys;
        mstring:=globc[x].mstring;
        commandflags:=globc[x].commandflags;
      end;
    end;
    end;


    mqarea:=FALSE; fqarea:=FALSE;
    lcmdlistentry:=''; j:=0;
    for i:=1 to noc do begin
      if (cmdr[i].ckeys<>lcmdlistentry) then begin
        b:=(aacs(cmdr[i].acs));
        if (b) then inc(j);
        if (b) then begin
          if (not(autoexec in cmdr[i].commandflags) and
          not(titleline in cmdr[i].commandflags)) then begin
            if (j<>1) then cmdlist:=cmdlist+',';
            cmdlist:=cmdlist+cmdr[i].ckeys;
          end else dec(j);
        end;
        lcmdlistentry:=cmdr[i].ckeys;
      end;
      if (cmdr[i].cmdkeys='68') then mqarea:=TRUE;
      if (cmdr[i].cmdkeys='38') then fqarea:=TRUE;
    end;
  end;
end;

procedure readingl;
var filv:text;
    s,lcmdlistentry:astr;
    mdf:file of commandrec;
    x,e1,e2,i,j:integer;
    b:boolean;
begin
  cmdlist:='';
  globcmds:=0;
  assign(mf,adrv(systat^.gfilepath)+menufname+'.NXM');
  {$I-} reset(mf); {$I+}
  if (ioresult<>0) then begin
        sl1('!','Error Reading '+menufname+'.NXM.  Hanging up...');
        print('Critical Error:  Disconnecting...');
        hangup2:=TRUE;
  end;
  if (hangup) then exit;
  if (curmenu-1<=filesize(mf)-1) then seek(mf,curmenu-1)
        else begin
                sl1('!','Menu #'+cstr(curmenu)+' Not Defined.');
                print('Critical Error:  Disconnecting...');
                hangup2:=TRUE;
        end;
  if (not hangup) then begin
    read(mf,menur);
    assign(mdf,adrv(systat^.menupath)+menur.mnufile+'.MNU');
    {$I-} reset(mdf); {$I+}
    if (ioresult<>0) then begin
        sl1('!','.MNU file does not exist. Fallback...');
        curmenu:=menur.fallback;
        if (curmenu-1<=filesize(mf)-1) then seek(mf,curmenu-1)
        else begin
                sl1('!','Menu Not Defined.');
                print('Critical Error:  Disconnecting...');
                hangup2:=TRUE;
        end;
        read(mf,menur);
        assign(mdf,adrv(systat^.menupath)+menur.mnufile+'.MNU');
        {$I-} reset(mdf); {$I+}
        if (ioresult<>0) then begin
                sl1('!','Fallback .MNU does not exist.  Hanging Up...');
                print('Critical Error: Disconnecting...');
                hangup2:=TRUE;
         end;
    end;
    if (hangup) then exit;
    repeat
      inc(globcmds);
      read(mdf,globc[globcmds]);
    until (eof(mdf) or (globcmds=20));
    close(mdf);
    close(mf);
    
    mqarea:=FALSE; fqarea:=FALSE;
    lcmdlistentry:=''; j:=0;
    for i:=1 to globcmds do begin
      if (globc[i].ckeys<>lcmdlistentry) then begin
        b:=(aacs(globc[i].acs));
        if (b) then inc(j);
        if (b) then begin
          if (not(autoexec in globc[i].commandflags) and
          not(titleline in globc[i].commandflags)) then begin
            if (j<>1) then cmdlist:=cmdlist+',';
            cmdlist:=cmdlist+globc[i].ckeys;
          end else dec(j);
        end;
        lcmdlistentry:=globc[i].ckeys;
      end;
      if (globc[i].cmdkeys='68') then mqarea:=TRUE;
      if (globc[i].cmdkeys='38') then fqarea:=TRUE;
    end;
  end;
end;

procedure showcmds;
var i,j,numrows:integer;
    s,s1:astr;
    abort,next:boolean;

  function sfl(b:boolean; c:char):char;
  begin
    if (b) then sfl:=c else sfl:='-';
  end;

begin
  abort:=FALSE; next:=FALSE;
  if (noc<>0) then begin
          sprint(#3#4+'旼컴쩡컴컴컴컴컴쩡컴컫컴컴컴컴컴쩡컴쩡컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커');
          sprint(#3#4+'|'#3#0+'Num'+'|'+#3#5+' Command   '+'|'+#3#0+'Flag'+'|'+
                   #3#9+' Access   '+'|'+#3#0+'Cmd'+'|'+#3#7+mln(' Command String',40)+'|');
          sprint(#3#4+'읕컴좔컴컴컴컴컴좔컴컨컴컴컴컴컴좔컴좔컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸');
          wkey(abort,next);
          i:=1;                                               
while (i<=noc) and (not abort) and (not hangup) do begin
            sprint(#3#0+' '+mrn(cstr(i),3)+'  '+#3#5+mlnnomci(cmdr[i].ckeys,10)+'  '+
                     #3#0+sfl(hidden in cmdr[i].commandflags,'H')+#3#0+
                     sfl(unhidden in cmdr[i].commandflags,'U')+'   '+
                     #3#9+mlnnomci(cmdr[i].acs,9)+' '+
                     #3#0+mlnnomci(cmdr[i].cmdkeys,3)+'  '+
                     mln(cmdr[i].mstring,39));
                     wkey(abort,next);
            inc(i);
    end;
  end
  else print('No Commands In This Menu.');
end;

function oksecurity(i:integer; var cmdnothid:boolean):boolean;
begin
  oksecurity:=FALSE;
  if (unhidden in cmdr[i].commandflags) then cmdnothid:=TRUE;
  if (not aacs(cmdr[i].acs)) then exit;
  oksecurity:=TRUE;
end;

procedure genericmenu(t:integer);
var glin:array [1..maxmenucmds] of astr;
    s,s1:astr;
    c2:char;
    gcolors:array [1..3] of byte;
    onlin,i,j,colsiz,numcols,numglin,maxright:integer;
    abort,next,b,cmdnothid:boolean;


function getc2(c:byte):string;
var s,s1:string;
    x,f1,b1:integer;

function getfore(b2:byte) : integer;
var
   i2 : integer;
begin
i2 := b2 and 7;
if (b2 and 8)=8 then inc(i2,8);
if (b2 and 128)=128 then inc(i2,16);
getfore := i2;
end;


function getback(b2:byte) : integer;
var
  i2 : integer;

begin
i2 := ((b2 shr 4) and 7);
getback := i2;
end;


begin
  s:='';
  f1:=getfore(c);
  s1:=cstr(f1);
  b1:=getback(c);
  if (length(s1)<2) then
        for x:=1 to (2-(length(s1))) do begin
                s1:='0'+s1;
        end;
  s:='%'+s1+cstr(b1)+'%';
  getc2:=s;
end;


  function gencolored(keys,desc:astr; acc:boolean):astr;
  begin
    s:=desc;
    j:=pos(allcaps(keys),allcaps(desc));
    if (j<>0) then begin
      insert(getc2(gcolors[3]),desc,j+length(keys)+1);
      insert(getc2(gcolors[1]),desc,j+length(keys));
      if (acc) then insert(getc2(gcolors[2]),desc,j);
      if (j<>1) then
        insert(getc2(gcolors[1]),desc,j-1);
    end;
    gencolored:=getc2(gcolors[3])+desc;
  end;

  function semicmd(s:string; x:integer):string;
  var i,p:integer;
  begin
    i:=1;
    while (i<x) and (s<>'') do begin
      p:=pos(';',s);
      if (p<>0) then s:=copy(s,p+1,length(s)-p) else s:='';
      inc(i);
    end;
    while (pos(';',s)<>0) do s:=copy(s,1,pos(';',s)-1);
    semicmd:=s;
  end;

  procedure newgcolors(s:string);
  var s4:byte;
  begin
    s4:=ord(s[1]); gcolors[1]:=s4;
    s4:=ord(s[2]); gcolors[2]:=s4;
    s4:=ord(s[3]); gcolors[3]:=s4;
  end;

  procedure gen_tuto;
  var i,j:integer;
      b:boolean;
  begin
    numglin:=0; maxright:=0; glin[1]:='';
    for i:=1 to noc do begin
      b:=oksecurity(i,cmdnothid);
      if (((b) or (unhidden in cmdr[i].commandflags)) and
          (not (hidden in cmdr[i].commandflags))) then
        if (titleline in cmdr[i].commandflags) then begin
          inc(numglin); glin[numglin]:=cmdr[i].ldesc;
          if (glin[numglin]='') then glin[numglin]:=' ';
          j:=lennmci(glin[numglin]); if (j>maxright) then maxright:=j;
          if (cmdr[i].mstring<>'') then newgcolors(cmdr[i].mstring);
        end else
          if (cmdr[i].ldesc<>'') then begin
            inc(numglin);
            glin[numglin]:=gencolored(cmdr[i].ckeys,cmdr[i].ldesc,b);
            j:=lennmci(glin[numglin]); if (j>maxright) then maxright:=j;
          end;
    end;
  end;

  procedure stripc(var s1:astr);
  var s:astr;
      i:integer;
  begin
    s:=''; i:=1;
    while (i<=length(s1)) do begin
      if (s1[i]=#3) then inc(i) else s:=s+s1[i];
      inc(i);
    end;
    s1:=s;
  end;

  procedure fixit(var s:astr; len:integer);
  var s3:astr;
  begin
    s3:=s;
    s3:=common.stripcolor(s3);
    if (length(s3)<len) then
      s:=s+copy('                                        ',1,len-length(s3))
    else
      if (length(s3)>len) then s:=s3;
  end;

  procedure gen_norm;
  var s1:astr;
      i,j:integer;
      b:boolean;
  begin
    s1:=''; onlin:=0; numglin:=1; maxright:=0; glin[1]:='';
    for i:=1 to noc do begin
      b:=oksecurity(i,cmdnothid);
      if (((b) or (unhidden in cmdr[i].commandflags)) and
          (not (hidden in cmdr[i].commandflags))) then begin
        if (titleline in cmdr[i].commandflags) then begin
          if (onlin<>0) then inc(numglin);
          glin[numglin]:=#2+cmdr[i].ldesc;
          inc(numglin); glin[numglin]:='';
          onlin:=0;
          if (cmdr[i].mstring<>'') then newgcolors(cmdr[i].mstring);
        end else begin
          if (cmdr[i].sdesc<>'') then begin
            inc(onlin); s1:=gencolored(cmdr[i].ckeys,cmdr[i].sdesc,b);
            if (onlin<>numcols) then fixit(s1,colsiz);
            glin[numglin]:=glin[numglin]+s1;
          end;
          if (onlin=numcols) then begin
            j:=lennmci(glin[numglin]); if (j>maxright) then maxright:=j;
            inc(numglin); glin[numglin]:=''; onlin:=0;
          end;
        end;
      end;
    end;
    if (onlin=0) then dec(numglin);
  end;

  function tcentered(c:integer; s:astr):astr;
  const spacestr='                                               ';
  begin
    c:=(c div 2)-(lennmci(s) div 2);
    if (c<1) then c:=0;
    tcentered:=copy(spacestr,1,c)+s;
  end;

  procedure dotitles;
  var i:integer;
      b:boolean;
  begin
    b:=FALSE;
    if (menur.mnuheader<>'') then begin
        printf(adrv(systat^.afilepath)+menur.mnuheader);
        wkey(abort,next);
        end;
    if ((nofile) or (menur.mnuheader='')) then begin
    for i:=1 to 3 do
      if (menur.menuname[i]<>'') then begin
        if (not b) then begin nl; b:=TRUE; end;
        if (dontcenter in menur.menuflags) then begin
          sprint(menur.menuname[i]);
          wkey(abort,next);
        end else begin
          sprint(tcentered(maxright,menur.menuname[i]));
          wkey(abort,next);
        end;
      end;
    end;
    nl;
  end;

begin
  for i:=1 to 3 do gcolors[i]:=menur.gcol[i];
  numcols:=menur.gencols;
  case numcols of
    2:colsiz:=39; 3:colsiz:=25; 4:colsiz:=19;
    5:colsiz:=16; 6:colsiz:=12; 7:colsiz:=11;
  end;
  if (numcols*colsiz>=80) then
    numcols:=80 div colsiz;
  abort:=FALSE; next:=FALSE;
  if (t=2) then gen_norm else gen_tuto;
  dotitles;
  i:=1;
  while (i<=numglin) and not(abort) do begin
    if (glin[i]<>'') then
      if (glin[i][1]<>#2) then begin
        sprint(glin[i]);
        wkey2(c2,abort,next);
        if (pos(upcase(c2),allcaps(smlist))<>0) then begin
                abort:=TRUE;
                mc:=upcase(c2);
                end;
      end else begin
        sprint(tcentered(maxright,copy(glin[i],2,length(glin[i])-1)));
        wkey2(c2,abort,next);
        if (pos(upcase(c2),allcaps(smlist))<>0) then begin
                abort:=TRUE;
                mc:=upcase(c2);
                end;
      end;
   inc(i);
   end;
   nl;
end;

procedure showthismenu;
var s:astr;
    i:integer;
begin
  smlist:='';
  if (onekey in thisuser.ac) then begin
  for i:=1 to noc do
    if (aacs(cmdr[i].acs)) then if (cmdr[i].ckeys[0]=#1) then
      begin
        smlist:=smlist+cmdr[i].ckeys;
      end;
  end;

  if (clrscrbefore in menur.menuflags) and (chelplevel<>1) then begin
      cls;
  end;
  case chelplevel of
    2:begin
        displayingmenu:=TRUE;
        nofile:=TRUE; s:=menur.directive;
        if (s<>'') then begin
          if (pos('|SL|',s)<>0) then
            printf(substall(s,'|SL|',cstr(thisuser.sl)));
          if (nofile) then printf(substall(s,'|SL|',''));
        end;
        displayingmenu:=FALSE;
      end;
    3:begin
        displayingmenu:=TRUE;
        nofile:=TRUE; s:=menur.tutorial;
        if (s<>'') then begin
          if (pos('|SL|',s)<>0) then
            printf(substall(s,'|SL|',cstr(thisuser.sl)));
          if (nofile) then printf(substall(s,'|SL|',''));
        end;
        displayingmenu:=FALSE;
      end;
    4:begin
      if (chelplevel=4) then genericmenu(chelplevel);
        displayingmenu:=TRUE;
        nofile:=TRUE; s:=menur.directive;
        if (s<>'') then begin
          if (pos('|SL|',s)<>0) then
            printf(substall(s,'|SL|',cstr(thisuser.sl)));
          if (nofile) then printf(substall(s,'|SL|',''));
        end;
        displayingmenu:=FALSE;
      end;
  end;
  if ((nofile) and (chelplevel in [2,3])) then genericmenu(chelplevel);
end;

end.

PROGRAM NX2FBBS;

uses unixdate,regunit,spawno,myio,STRNTTT5,miscttt5,strings,dos,crt,IVST,
     nxfs2,misc;

{$I nexus.inc}

const adate:boolean=FALSE;
      asize:boolean=FALSE;
      number:boolean=FALSE;
      column:integer=14;
      outputpath:string='';

var
   maindir  : string;
   ver      : string;
   NexusDir,outname : string;
   NFile    : file of matrixrec;
   NRec     : matrixrec;
   Ffile    : file of ULrec;
   F        : ULrec;
   a        : text;
   x,curbase:integer;
   totalall : longint;
   total    : longint;
   nowf     : longint;
   totalf   : longint;
   w2,oldwind:windowrec;
   NXF: nxFILEOBJ;
   systf: file of systemrec;
   syst : systemrec;
   oldx,oldy:integer;

procedure title;
begin
drawwindow2(1,1,78,5,1,3,0,11,'');
gotoxy(3,2);
textcolor(15);
textbackground(3);
write('nx2FBBS v',ver,' - FILES.BBS Creator for Nexus Bulletin Board System');
gotoxy(3,3);
write('(c) Copyright 1996-2001 George A. Roberts IV.  All rights reserved.');
gotoxy(3,4);
write('(c) Copyright 1994-95 Internet Pro''s Network LLC.  All rights reserved.');
end;


function mln(s:string; l:integer):string;
var i,i2:integer;
    s2:string;
begin
  s2:='';
  while (length(s)<l) do s:=s+' ';
  if (length(s)>l) then s:=copy(s,1,l);
  mln:=s;
end;

function bslash(b:boolean; s:string):string;
begin
  if (b) then begin
    while (copy(s,length(s)-1,2)='\\') do s:=copy(s,1,length(s)-2);
    if (copy(s,length(s),1)<>'\') then s:=s+'\';
  end else
    while (copy(s,length(s),1)='\') do s:=copy(s,1,length(s)-1);
  bslash:=s;
end;


function stripcolor(o:string):string;
var s,s2:string;
    count,i:integer;
    lc:boolean;
begin
  s2:=o;
  s:='';
  count:=0;
  i:=1;
  while (i<=length(o)-4) do begin
       if (o[i]='%') and (o[i+4]='%') and (o[i+1] in ['0'..'9']) and
                (o[i+2] in ['0'..'9']) and (o[i+3] in ['0'..'9']) then inc(i,4) else
			s:=s+o[i];
       inc(i);
  end;
  if (length(o)>4) {and (i<length(o))} then begin
    if not((o[length(o)-4]='%') and (o[length(o)]='%') and (o[length(o)-3] in ['0'..'9'])
        and (o[length(o)-2] in ['0'..'9']) and (o[length(o)-1] in ['0'..'9'])) then begin
        for count:=i to (length(o)) do begin
                s:=s+(o[count]);
        end;
    end;
  end else begin
  s:=s2;
  end;
  stripcolor:=s;
end;



procedure adfile;
  var
   x : string;
   r : integer;
   z : string;
  cnt: integer;
   t : longint;
begin


str(NXF.Fheader.NumDownloads,z);

x := stripch(' ',NXF.Fheader.filename);
write(a,padleft(x,12,' '));

if (asize) then begin
write(a,'  ');

t := NXF.Fheader.Filesize;
str(t,x);
write(a,padright(x,7,' '));
end;

if (adate) then begin
write(a,'  ');

write(a,copy(unixtime2str(NXF.Fheader.FileDate),1,8)+' ');
end;

write(a,' ');
NXF.DescStartup;
x:=NXF.GetDescLine;
if (x=#1+'EOF'+#1) then writeln('No description provided.') else
begin
        writeln(a,x);
        x:=NXF.GetDescLine;
        cnt:=2;
        while (x<>#1+'EOF'+#1) and (cnt<=syst.ndesclines) do begin
                writeln(a,mln(' ',column-3)+': ',x);
                x:=NXF.GetDescLine;
                inc(cnt);
        end;
end;
end;

procedure addtolist;
var
  now   : integer;
  total : longint;

begin
   total:=0;
   NXF.Init(nrec.filepath+f.filename+'.NFD',syst.nkeywords,syst.ndesclines);
   total := NXF.Numfiles;
   now := 1;

   if (number) then outname:='FILES.'+cstrnfile(nowf) else outname:='FILES.BBS';
   if (outputpath='') then begin
      assign(a,f.dlpath+outname);
   end else begin
      assign(a,outputpath+outname);
   end;
   rewrite(a);

   if (total > 0) then begin
     repeat
     NXF.Seekfile(now);
     NXF.ReadHeader;
     adfile;
     inc(now);
     until (now > total);
   end;

 NXF.Done;
 close(a);

end;

procedure opensystem;
begin
getdir(0,maindir);
maindir := bslash(false,maindir);

nexusdir:=allcaps(getenv('NEXUS'));
if copy(nexusdir,length(nexusdir),1)<>'\' then nexusdir:=nexusdir+'\';
assign(NFile,NexusDir+'MATRIX.DAT');
{$I-} reset(NFile); {$I+}
if (IOResult <> 0) then begin
          displaybox('Error reading '+nexusdir+'MATRIX.DAT!',3000);
          halt;
end;
read(NFile,Nrec);
close(nFile);

assign(fFile,nRec.gfilepath+'FBASES.DAT');
{$I-} reset(fFile); {$I+}
if (IOResult <> 0) then begin
          displaybox('Error reading '+nrec.gfilepath+'FBASES.DAT!',3000);
          halt;
end;
assign(systf,nrec.gfilepath+'SYSTEM.DAT');
{$I-} reset(systf); {$I+}
if (ioresult<>0) then begin
        displaybox('Error reading '+nrec.gfilepath+'SYSTEM.DAT!',3000);
end;
read(systf,syst);
close(systf);
end;

procedure helpscreen;
begin
clrscr;
title;
gotoxy(1,8);
textcolor(7);
textbackground(0);
writeln('Syntax:  NX2FBBS [options]');
writeln;
writeln('Options:');
writeln;
writeln('         -S          Add the file size to the listing');
writeln('         -D          Add the file date to the listing');
writeln('         -N          Number file extensions according to filebase #');
writeln('         -C[#]       Column number to start extended desc (default=14)');
writeln('         -P[path]    Path to write ALL FILES.BBS files to');
halt;
end;

procedure getparams;
var s2:string;
    x:integer;
begin
x:=1;
asize:=FALSE;
adate:=FALSE;
while (x<=paramcount) do begin
        s2:=paramstr(x);
        if (s2[1]='-') or (s2[1]='/') then
        case upcase(s2[2]) of
                'S':asize:=TRUE;
                'D':adate:=TRUE;
                'N':number:=TRUE;
                'C':column:=value(copy(s2,3,length(s2)));
                'P':outputpath:=bslash(TRUE,copy(s2,3,length(s2)));
                '?':helpscreen;
        end;
        if (s2[1]='?') then helpscreen;
        inc(x);
end;
end;


begin
totalall := 0;
ver := '1.01';
FileMode:=66;
getparams;
cursoron(FALSE);
oldx:=wherex;
oldy:=wherey;
savescreen(oldwind,1,1,80,25);
textcolor(7);
textbackground(0);
clrscr;
for x:=1 to 24 do writeln('같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같�');
title;
opensystem;
totalf := filesize(ffile);
setwindow(w2,2,10,77,17,3,0,8,'Processing...',TRUE);
repeat
seek(ffile,nowf);
read(ffile,f);
if not(f.cdrom) then begin
 gotoxy(2,2);
 textcolor(3);
 write('Current Filebase   : ');
 gotoxy(23,2);
 textcolor(15);
 write(mln(stripcolor(f.name),50));

 gotoxy(2,3);
 textcolor(3);
 write('Nexus File Database: ');
 gotoxy(23,3);
 textcolor(15);
 write(mln(nrec.filepath+f.filename+'.NFD',50));

 gotoxy(2,5);
 textcolor(3);
 write('Creating FILES.xxx : ');
 gotoxy(23,5);
 textcolor(15);
 if (number) then outname:='FILES.'+cstrnfile(nowf) else outname:='FILES.BBS';
 if (outputpath='') then begin
 write(mln(f.dlpath+outname,50));
 end else begin
 write(mln(outputpath+outname,50));
 end;
 addtolist;
end;

nowf := nowf + 1;
until nowf = totalf;

removewindow(w2);
removewindow(oldwind);
if oldy=25 then writeln;
gotoxy(1,oldy);
textcolor(7);
textbackground(0);
cursoron(TRUE);

end.

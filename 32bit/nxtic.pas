{$A+,B+,D-,E+,F+,G+,I+,L-,N-,O-,R+,S+,V-}
{$M 65000,0,100000}      { Memory Allocation Sizes }
program nxTIC;

uses dos,crt,myio,misc,nxfs2,mkstring,fbcommon,mkmisc;

type ticfilerec=
     RECORD
        area:string[60];
        filename:string[30];
        description:array[1..40] of string[60];
     END;

const ticpath:string='C:\TICS\';
      startdir:string='C:\NEXUS';

var systatf:file of matrixrec;
    ticrec:ticfilerec;
    NXF:nxFILEOBJ;

procedure title;
begin
writeln('nxTIC v0.99-alpha - TIC file processor for Nexus Bulletin Board System');
writeln('(c) Copyright 2000-01 George A. Roberts IV. All rights reserved.');
writeln('Written by George A. Roberts IV. Supplemental code by Robert Todd.');
writeln;
end;

procedure startup;
begin
startdir:=getenv('NEXUS');
if (startdir[length(startdir)]='\') then startdir:=copy(startdir,1,length(startdir)-1);
if (startdir='') then begin
        writeln('ERROR: You must set your NEXUS environment variable before running nxTIC!');
        halt;
end;
assign(systatf,startdir+'\MATRIX.DAT');
{$I-} reset(systatf); {$I+}
if (ioresult<>0) then begin
        writeln('Error reading '+startdir+'\MATRIX.DAT');
        halt;
end;
read(systatf,systat);
close(systatf);
assign(systemf,adrv(systat.gfilepath)+'SYSTEM.DAT');
{$I-} reset(systemf); {$I+}
if (ioresult<>0) then begin
      writeln('Error reading '+adrv(systat.gfilepath)+'SYSTEM.DAT');
      halt;
end;
read(systemf,syst);
close(systemf);
end;

function getfbpath(tic:string):string;
var found:boolean;
begin
found:=FALSE;
assign(ulf,adrv(systat.gfilepath)+'FBASES.DAT');
{$I-} reset(ulf); {$I+}
if (ioresult<>0) then begin
        writeln('Error reading '+adrv(systat.gfilepath)+'FBASES.DAT');
        halt;
end;
while not(eof(ulf)) and not(found) do begin
        read(ulf,memuboard);
        if (allcaps(memuboard.ticarea)=allcaps(tic)) then found:=TRUE;
end;
if (found) then begin
        if (fbdirdlpath in memuboard.fbstat) then begin
                getfbpath:=memuboard.dlpath+memuboard.filename+'.NFD';
        end else begin
                getfbpath:=adrv(systat.filepath)+memuboard.filename+'.NFD';
        end;
end else getfbpath:='';
end;

procedure cf(var ok:byte; var nospace:boolean; showprog:boolean;
                   srcname,destname:astr);
var buffer:array[1..16384] of byte;
    totread,fs,dfs:longint;
    nrec,i,x,x2,x3:integer;
    b:byte;
    src,dest:file;
    cont:boolean;

  procedure dodate;
  var tm:longint;
  begin
    getftime(src,tm);
    setftime(dest,tm);
  end;

  function getresponse:byte;
  var w4:windowrec;
      x4:integer;
      current:byte;
      c:char;
      choices:array[1..3] of string[30];
      dn:boolean;
  begin
  choices[1]:='Replace Existing File';
  choices[2]:='Delete Source File   ';
  choices[3]:='Abort Move           ';
  setwindow(w4,20,10,60,16,3,0,8,destname,TRUE);
  for x4:=1 to 3 do begin
        gotoxy(2,x4+1);
        textcolor(7);
        textbackground(0);
        write(choices[x4]);
  end;
  dn:=FALSE;
  current:=1;
  repeat
        gotoxy(2,current+1);
        textcolor(15);
        textbackground(1);
        write(choices[current]);
        while not(keypressed) do begin end;
        c:=readkey;
        case c of
                #0:begin
                        c:=readkey;
                        case c of
                                #72:begin
                                gotoxy(2,current+1);
                                textcolor(7);
                                textbackground(0);
                                write(choices[current]);
                                dec(current);
                                if (current=0) then current:=3;
                                end;
                                #80:begin
                                gotoxy(2,current+1);
                                textcolor(7);
                                textbackground(0);
                                write(choices[current]);
                                inc(current);
                                if (current=4) then current:=1;
                                end;
                        end;
                   end;
                #13:begin
                    getresponse:=current;
                    dn:=TRUE;
                end;
       end;
  until (dn);
  removewindow(w4);
  textcolor(7);
  textbackground(0);
  end;




begin
  ok:=0; nospace:=FALSE;
  assign(src,srcname);
  filemode:=64;
  {$I-} reset(src,1); {$I+}
  if (ioresult<>0) then begin ok:=1;
  displaybox('File: '+srcname+' - Error!',2000);
  exit; end;
  dfs:=freek(exdrv(destname));
  fs:=trunc(filesize(src)/1024.0)+1;
  if (fs>=dfs) then begin
    close(src);
    nospace:=TRUE; ok:=1;
    exit;
  end else begin
    cont:=TRUE;
    fs:=filesize(src);
    assign(dest,destname);
    filemode:=66;
    if (exist(destname)) then begin
        { 1: replace
          2: delete source
          3: quit }
          b:=getresponse;
          case b of
                1:begin
                  cont:=TRUE;
                  end;
                2:begin
                  close(src);
                  cont:=FALSE;
                  ok:=2;
                  end;
                3:begin
                  close(src);
                  cont:=FALSE;
                  ok:=3;
                  end;
          end;
    end;
    if (cont) then begin
    {$I-} rewrite(dest,1); {$I+}
    if (ioresult<>0) then begin ok:=4; exit; end;
    write('Move file : ');
    write('0% ');
    for i:=1 to 40 do write('°');
    write(' 100%');

    x:=1;
    totread:=0;
    repeat
      filemode:=64;
      blockread(src,buffer,16384,nrec);
      filemode:=66;
      blockwrite(dest,buffer,nrec);
      totread:=totread+nrec;
      if (showprog) then begin
        for x2:=x to 40 do begin
        if (totread>=((fs div 40)*x2)) then begin
                gotoxy(15+x,wherey);
                write('Û');
                inc(x);
                end;
        end;
      end;
      until (nrec<16384);
    dodate;
    filemode:=66;
    close(dest);
    filemode:=64;
    close(src);
    filemode:=66;
    {$I-} erase(src); {$I+}
    if (ioresult<>0) then begin
      writeln;
      writeln('Error removing file: '+srcname);
    end;
    writeln;
    end;
  end;
end;


procedure processtics;
var sr:searchrec;
    tf:text;
    count,xx,fpacked:longint;
    fbp,s,s2:string;
    dline,pl,x3,rn,cn:integer;
    ok:byte;
    fi:file;
    dt:datetime;
    showdesc,ex,nospace:boolean;
    rfpts:real;

        procedure ptic;
        var ss,key:string;
            ld:boolean;
        begin
        dline:=1;
        ld:=false;
        while not(eof(tf)) do begin
                readln(tf,ss);
                key:=extractword(ss,1);
                if (allcaps(key)='AREA') then begin
                        ticrec.area:=copy(ss,pos(' ',ss)+1,length(ss));
                end;
                if (allcaps(key)='FILE') then begin
                        ticrec.filename:=copy(ss,pos(' ',ss)+1,length(ss));
                end;
                if (allcaps(key)='DESC') then begin
                        if (dline<=40) then begin
                        ticrec.description[dline]:=copy(ss,pos(' ',ss)+1,length(ss));
                        inc(dline);
                        end;
                end;
                if (allcaps(key)='LDESC') then begin
                        if not(ld) then begin
                                ld:=TRUE;
                                dline:=1;
                        end;
                        if (dline<=40) then begin
                        ticrec.description[dline]:=copy(ss,pos(' ',ss)+1,length(ss));
                        inc(dline);
                        end;
                end;
        end;
        dec(dline);
        end;

begin
findfirst(ticpath+'*.TIC',anyfile,sr);
count:=0;
while (doserror=0) do begin
        inc(count);
        assign(tf,ticpath+sr.name);
        {$I-} reset(tf); {$I+}
        if (ioresult<>0) then begin
                writeln('Error reading '+ticpath+sr.name);
        end else begin
                writeln('Processing '+ticpath+sr.name+' ...');
                writeln;
                ptic;
                close(tf);
                fbp:=getfbpath(ticrec.area);
                if (fbp='') then begin
                        writeln('Fileecho  : '+ticrec.area);
                        writeln('** No matching filebase found');
                        for xx:=1 to 40 do begin
                        if (ticrec.description[xx]<>'') then 
                        writeln(ticrec.description[xx]);
                        end;
                end else begin
                        NXF.Init(fbp,syst.nkeywords,syst.ndesclines);
                        writeln('Fileecho  : '+ticrec.area);
                        writeln('Filebase  : '+stripcolor(memuboard.name));
                        writeln;
                        pl:=NXF.Numfiles;
                        showdesc:=TRUE;
                        for xx:=1 to 40 do begin
                              if (ticrec.description[xx]<>'') then begin
                                    if (showdesc) then begin
                                          write('Descript  : ');
                                          showdesc:=FALSE;
                                    end else write('          : ');
                                    writeln(ticrec.description[xx]);
                              end;
                        end;
                        rn:=0; cn:=1;
                        while (cn<=pl) and (rn=0) do begin
                            NXF.Seekfile(cn);
                            NXF.ReadHeader;
                            if fit(align(ticrec.filename),align(NXF.Fheader.filename)) then rn:=cn;
                            inc(cn);
                        end;
                        if (rn=0) then begin
                        cf(ok,nospace,TRUE,ticpath+ticrec.filename,memuboard.dlpath+ticrec.filename);
                        ex:=exist(memuboard.dlpath+ticrec.filename);
                        if (ex) then begin
                        assign(fi,memuboard.dlpath+ticrec.filename);
        {$I-} reset(fi,1); {$I+}
        if (ioresult<>0) then begin
                NXF.Fheader.Filesize:=0;
                NXF.Fheader.FileDate:=0;
        end else begin
                NXF.Fheader.Filesize:=(filesize(fi));
                GetFTime(fi,fpacked);
                UnpackTime(fpacked,dt);
                NXF.Fheader.FileDate:=DTToUnixDate(dt);
                close(fi);
        end;
        NXF.Fheader.FheaderID[1]:=#1;
        NXF.Fheader.FheaderID[2]:='N';
        NXF.Fheader.FheaderID[3]:='E';
        NXF.Fheader.FheaderID[4]:='X';
        NXF.Fheader.FheaderID[5]:='U';
        NXF.Fheader.FheaderID[6]:='S';
        NXF.Fheader.FheaderID[7]:=#1;
        NXF.Fheader.filename:=allcaps(ticrec.filename);
        NXF.Fheader.magicname:='';
        NXF.Fheader.uploadedby:=caps(systat.sysopname);
        NXF.Fheader.UploadedDate:=u_daynum(datelong+'  '+time);
        NXF.Fheader.NumDownloads:=0;
        NXF.Fheader.LastDLDate:=NXF.Fheader.UploadedDate;
        NXF.Fheader.Access:='';
        NXF.Fheader.AccessKey:='';

        fillchar(NXF.Fheader.Reserved,sizeof(NXF.Fheader.Reserved),#0);

        rfpts:=trunc(NXF.Fheader.Filesize/1024.0)/systat.fileptcompbasesize;
        NXF.Fheader.filepoints:=round(rfpts);
        if (NXF.Fheader.filepoints<1) then NXF.Fheader.filepoints:=1;

        NXF.Fheader.FileFlags:=[];
        if (not systat.validateallfiles) then NXF.Fheader.FileFlags:=NXF.Fheader.FileFlags+[ffnotval];

        if not(ex) then NXF.Fheader.FileFlags:=NXF.Fheader.FileFlags+[ffisrequest];
        if (rn=0) then begin
              NXF.AddNewFile(NXF.Fheader);
        end else begin
              NXF.seekfile(rn);
              NXF.RewriteHeader(NXF.Fheader);
        end;
        for xx:=1 to dline do begin
                NXF.AddDescLine(ticrec.description[xx]);
        end;
        writeln('Added     : '+ticrec.filename);
        end;
        end;
        end;
        end;
        findnext(sr);
end;
if (count=0) then begin
        writeln('No files to process.');
end;
end;

begin
title;          
startup;
processtics;
end.

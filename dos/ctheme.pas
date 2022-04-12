program ctheme;

uses dos,crt,myio,misc;

type theader=
     RECORD
        name:string[80];
        createdby:string[80];
        copyright:string[80];
        url:string[250];
        email:string[100];
        date:longint;
        vmajor:integer;
        vminor:integer;
        s1size:integer;
        s2size:integer;
        reserved:array[1..1394] of byte;
    END;

var f1,f2:file;
    buffer:array[1..4000] of byte;
    p,pfn:string;
    th:theader;
    s:string;
    nr:longint;
    numread:integer;

begin
writeln('WFC Theme Creator v1.01 for Nexus Bulletin Board System');
writeln('(c) Copyright 2001 George A. Roberts IV. All rights reserved.');
writeln;
if (paramcount<1) then begin
        writeln('CTHEME [path to datafiles]');
        writeln;
        writeln('[path to datafiles] is the path where your .BIN and .SCI files that you');
        writeln('are packing are located.');
        halt;
end else begin
        p:=paramstr(1);
end;
  writeln('Packed filename (8 characters, created in current directory):');
  infield_inp_fgrd:=15;
  infield_inp_bkgd:=1;
  infield_out_fgrd:=3;
  infield_out_bkgd:=0;
  infield_allcaps:=TRUE;
  infield_numbers_only:=FALSE;
  infield_putatend:=TRUE;
  infield_clear:=TRUE;
  infield_insert:=FALSE;
  infield_maxshow:=60;
  infielde(pfn,8);
  if (pfn='') then begin
        halt;
  end;
  infield_allcaps:=FALSE;
  writeln;
  writeln('Name of theme:');
  infielde(s,80);
  th.name:=s;
  s:='';
  writeln;
  writeln('Created by:');
  infielde(s,80);
  th.createdby:=s;
  s:='';
  writeln;
  writeln('Copyright:');
  infielde(s,80);
  th.copyright:=s;
  s:='';
  writeln;
  writeln('Website URL:');
  infielde(s,250);
  th.url:=s;
  s:='';
  writeln;
  writeln('Email address:');
  infielde(s,100);
  th.email:=s;
  s:='';
  th.date:=u_daynum(datelong+' '+time);
  th.vmajor:=1;
  th.vminor:=1;
  fillchar(th.reserved,sizeof(th.reserved),#0);
  writeln;
  writeln('Creating Theme Package...');
  p:=bslash(TRUE,p);
  assign(f1,pfn+'.TPK');
  rewrite(f1,1);
  writeln('Determining size of first WFC screen instructions...');
  assign(f2,p+'NEXUS1.SCI');
  {$I-} reset(f2,1); {$I+}
  if (ioresult<>0) then begin
        writeln('Error reading '+p+'NEXUS1.SCI!');
        halt;
  end;
  nr:=filesize(f2);
  close(f2);
  th.s1size:=nr;
  writeln('Determining size of second WFC screen instructions...');
  assign(f2,p+'NEXUS2.SCI');
  {$I-} reset(f2,1); {$I+}
  if (ioresult<>0) then begin
        writeln('Error reading '+p+'NEXUS2.SCI!');
        halt;
  end;
  nr:=filesize(f2);
  close(f2);
  th.s2size:=nr;
  blockwrite(f1,th,sizeof(th));
  writeln('Opening first WFC screen...');
  assign(f2,p+'NEXUS.BIN');
  {$I-} reset(f2,1); {$I+}
  if (ioresult<>0) then begin
        writeln('Error reading '+p+'NEXUS.BIN!');
        halt;
  end;
  blockread(f2,buffer,4000,numread);
  if (numread<>4000) then begin
        writeln('Error reading '+p+'NEXUS.BIN! Filesize too small!');
        halt;
  end;
  writeln('Writing first WFC screen...');
  blockwrite(f1,buffer,4000);
  close(f2);
  writeln('Opening second WFC screen...');
  assign(f2,p+'NEXUS2.BIN');
  {$I-} reset(f2,1); {$I+}
  if (ioresult<>0) then begin
        writeln('Error reading '+p+'NEXUS2.BIN!');
        halt;
  end;
  blockread(f2,buffer,4000,numread);
  if (numread<>4000) then begin
        writeln('Error reading '+p+'NEXUS2.BIN! Filesize too small!');
        halt;
  end;
  writeln('Writing first WFC screen...');
  blockwrite(f1,buffer,4000);
  close(f2);
  writeln('Opening first WFC screen instructions...');
  assign(f2,p+'NEXUS1.SCI');
  {$I-} reset(f2,1); {$I+}
  if (ioresult<>0) then begin
        writeln('Error reading '+p+'NEXUS1.SCI!');
        halt;
  end;
  nr:=filesize(f2);
  blockread(f2,buffer,nr,numread);
  writeln('Writing first WFC screen instructions...');
  blockwrite(f1,buffer,numread);
  close(f2);
  writeln('Opening second WFC screen instructions...');
  assign(f2,p+'NEXUS2.SCI');
  {$I-} reset(f2,1); {$I+}
  if (ioresult<>0) then begin
        writeln('Error reading '+p+'NEXUS2.SCI!');
        halt;
  end;
  nr:=filesize(f2);
  blockread(f2,buffer,nr,numread);
  writeln('Writing second WFC screen instructions...');
  blockwrite(f1,buffer,numread);
  close(f2);
  close(f1);
  writeln('Finished!');
end.

{$M 20000,0,40000}      { Memory Allocation Sizes }
program utheme;

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
    silent,list:boolean;

  procedure gettheme;
  type fnptr=^fnlist;
       fnlist=RECORD
        p:fnptr;
        n:fnptr;
        name:string[8];
       end;
  var firstlp,lp,lp2:listptr;
      firstfn,fn,fn2:fnptr;
      sr:searchrec;
      xxx,xx,x,cur,top,count:integer;
      rt:returntype;
      th2:theader;
      ff:file;
      first:boolean;
      w2:windowrec;
      nn:integer;

  begin
  first:=TRUE;
  count:=0;
  pfn:=bslash(TRUE,pfn);
  findfirst(pfn+'*.TPK',anyfile,sr);
  while (doserror=0) do begin
  inc(count);
  assign(ff,pfn+sr.name);
  {$I-} reset(ff,1); {$I+}
  if (ioresult=0) then begin
                if (first) then begin
                                new(lp);
                                new(fn);
                                blockread(ff,th2,sizeof(th2),nn);
                                lp^.p:=NIL;
                                lp^.list:=mln(th2.name,60)+' '+mrn(sr.name,12);
                                fn^.p:=NIL;
                                fn^.name:=copy(sr.name,1,pos('.',sr.name)-1);
                                firstfn:=fn;
                                firstlp:=lp;
                                first:=FALSE;
                end else begin
                                blockread(ff,th2,sizeof(th2),nn);
                                new(lp2);
                                new(fn2);
                                fn2^.p:=fn;
                                fn^.n:=fn2;
                                fn2^.name:=copy(sr.name,1,pos('.',sr.name)-1);
                                fn:=fn2;
                                lp2^.p:=lp;
                                lp^.n:=lp2;
                                lp2^.list:=mln(th2.name,60)+' '+mrn(sr.name,12);
                                lp:=lp2;
                end;
                close(ff);
    end;
    findnext(sr);
    end;
    if (count>0) then begin
                                lp^.n:=NIL;
                                fn^.n:=NIL;
                                top:=1;
                                cur:=1;
                                for x:=1 to 100 do rt.data[x]:=-1;
                                x:=0;
                                lp:=firstlp;
                                fn:=firstfn;
                                listbox_f10:=FALSE;
                                listbox_tag:=FALSE;
                                listbox_insert:=FALSE;
                                listbox_delete:=FALSE;
                                listbox_move:=FALSE;
                                listbox(w2,rt,top,cur,lp,1,8,78,21,3,0,8,'Select Theme','WFC Theme Manager',TRUE);
                                case rt.kind of
                                        1:begin
                                                xxx:=rt.data[1];
                                                for xx:=1 to (xxx-1) do begin
                                                        fn:=fn^.n;
                                                end;
                                                rt.data[100]:=-1;
                                                pfn:=pfn+fn^.name+'.TPK';
                                        end;
                                        else pfn:='';
                                end;
                                listbox_tag:=TRUE;
                                listbox_insert:=TRUE;
                                listbox_delete:=TRUE;
                                listbox_move:=TRUE;
                                                lp:=firstlp;
                                                while (lp<>NIL) do begin
                                                        lp2:=lp^.n;
                                                        dispose(lp);
                                                        lp:=lp2;
                                                end;
                                                fn:=firstfn;
                                                while (fn<>NIL) do begin
                                                        fn2:=fn^.n;
                                                        dispose(fn);
                                                        fn:=fn2;
                                                end;
                                removewindow(w2);
        end else pfn:='';
  end;


begin
silent:=FALSE;
if (paramcount<2) then begin
  writeln('WFC Theme Unpacker v1.01 for Nexus Bulletin Board System');
  writeln('(c) Copyright 2001 George A. Roberts IV. All rights reserved.');
  writeln;
        writeln('UTHEME [path\filename to package] [path to unpack to]');
        writeln;
        writeln('[path\filename to package] is the location of your .TPK file');
        writeln;
        writeln('[path to unpack to] is the directory where you want the files');
        writeln('unpacked to');
        halt;
end else begin
        pfn:=paramstr(1);
        p:=paramstr(2);
        silent:=(allcaps(paramstr(3)) = 'SILENT');
        list:=(allcaps(copy(paramstr(1),1,1)) = '*');
        if (list) then begin
                silent:=TRUE;
                pfn:=copy(pfn,2,length(pfn));
        end;
end;
if (list) then begin
        gettheme;
        if (pfn='') then halt;
end;
if not(silent) then begin
  writeln('WFC Theme Unpacker v1.01 for Nexus Bulletin Board System');
  writeln('(c) Copyright 2001 George A. Roberts IV. All rights reserved.');
  writeln;
end;
if not(silent) then begin
  writeln('Unpacking Theme Package...');
end;
  p:=bslash(TRUE,p);
  assign(f1,pfn);
  {$I-} reset(f1,1); {$I+}
  if (ioresult<>0) then begin
        if not(silent) then writeln('Error opening '+pfn) else begin
        displaybox('Error opening '+pfn,2000);
        end;
        halt;
  end;
  if not(silent) then writeln('Reading header...');
  blockread(f1,th,sizeof(th),numread);
  if (th.vmajor<>1) or (th.vminor<>1) then begin
        if not(silent) then writeln('Error: Incorrect .TPK version!') else
        displaybox('Incorrect TPK version: '+cstr(th.vmajor)+'.'+cstr(th.vminor),2000);
        halt;
  end;
  if not(silent) then writeln('Extracting first WFC Screen...');
  blockread(f1,buffer,4000,numread);
  assign(f2,p+'NEXUS.BIN');
  rewrite(f2,1);
  blockwrite(f2,buffer,4000);
  close(f2);
  if not(silent) then writeln('Extracting second WFC Screen...');
  blockread(f1,buffer,4000,numread);
  assign(f2,p+'NEXUS2.BIN');
  rewrite(f2,1);
  blockwrite(f2,buffer,4000);
  close(f2);
  if not(silent) then writeln('Extracting first WFC Screen Instructions...');
  blockread(f1,buffer,th.s1size,numread);
  assign(f2,p+'NEXUS1.SCI');
  rewrite(f2,1);
  blockwrite(f2,buffer,th.s1size);
  close(f2);
  if not(silent) then writeln('Extracting second WFC Screen Instructions...');
  blockread(f1,buffer,th.s2size,numread);
  assign(f2,p+'NEXUS2.SCI');
  rewrite(f2,1);
  blockwrite(f2,buffer,th.s2size);
  close(f2);
  close(f1);
  if not(silent) then writeln('Finished.');
end.

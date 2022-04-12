{$A+,B+,D-,E+,F+,I+,L+,N-,O+,R-,S+,V-}

unit sysop20;

interface

uses
  crt,dos,myio,misc,fbcommon;

procedure sort(bnum:integer;c1:char; global,cdrom,ascnd,ps:boolean);

implementation

const spin:array[1..4] of char=('/','-','\','|');
      wh:byte=1;

TYPE readblock=Array[0..0] of byte;

var totfils,totbases:longint;
    bubblesortend:integer;
    sortt:char;
    isascend:boolean;
    readptr:^readblock;
    readptr2:^readblock;
    pf:file;

procedure seekfile(x:integer);
begin
seek(pf,((x - 1) * (sizeof(Fheaderrec) + (syst.nkeywords * sizeof(FKeywordREC)) +
         (syst.ndesclines * sizeof(FDescREC)))));
end;

procedure getmemory(x:integer);
begin
case x of
        1:begin
                getmem(readptr,(sizeof(Fheaderrec) + (syst.nkeywords * sizeof(FKeywordREC)) +
                         (syst.ndesclines * sizeof(FDescREC))));
          end;
        2:begin
                getmem(readptr2,(sizeof(Fheaderrec) + (syst.nkeywords * sizeof(FKeywordREC)) +
                         (syst.ndesclines * sizeof(FDescREC))));
          end;
end;
end;

procedure disposememory(x:integer);
begin
case x of
        1:begin
                freemem(readptr,(sizeof(Fheaderrec) + (syst.nkeywords * sizeof(FKeywordREC)) +
                         (syst.ndesclines * sizeof(FDescREC))));
          end;
        2:begin
                freemem(readptr2,(sizeof(Fheaderrec) + (syst.nkeywords * sizeof(FKeywordREC)) +
                         (syst.ndesclines * sizeof(FDescREC))));
          end;
end;
end;

function recsize:longint;
begin
recsize:=sizeof(Fheaderrec) + (syst.nkeywords * sizeof(FKeywordREC)) +
                         (syst.ndesclines * sizeof(FDescREC));
end;

procedure switch(a,b:integer);
begin
  getmemory(1);
  getmemory(2);
  seekfile(a); blockread(pf,readptr^,recsize);
  seekfile(b); blockread(pf,readptr2^,recsize);
  seekfile(b); blockwrite(pf,readptr^,recsize);
  seekfile(a); blockwrite(pf,readptr2^,recsize);
  disposememory(1);
  disposememory(2);
end;

function greater(islesser,isequ:boolean; r1,r2:integer):boolean;
var f1,f2:fheaderrec;
    b,c:boolean;

  procedure figure1;
  begin
    case sortt of
      'D':if (isequ) then b:=(f1.uploadeddate<=f2.uploadeddate)
                     else b:=(f1.uploadeddate<f2.uploadeddate);
      'E':if (isequ) then b:=(copy(align(f1.filename),10,3)<=copy(align(f2.filename),10,3))
                     else b:=(copy(align(f1.filename),10,3)<copy(align(f2.filename),10,3));
      'F':if (isequ) then b:=(f1.filepoints<=f2.filepoints)
                     else b:=(f1.filepoints<f2.filepoints);
      'N':if (isequ) then b:=(f1.filename<=f2.filename)
                     else b:=(f1.filename<f2.filename);
      'S':if (isequ) then b:=(f1.filesize<=f2.filesize)
                     else b:=(f1.filesize<f2.filesize);
      'T':if (isequ) then b:=(f1.NumDownloads<=f2.NumDownloads)
                     else b:=(f1.NumDownloads<f2.NumDownloads);
    end;
  end;

  procedure figure2;
  begin
    case sortt of
      'D':if (isequ) then b:=(f1.uploadeddate>=f2.uploadeddate)
                     else b:=(f1.uploadeddate>f2.uploadeddate);
      'E':if (isequ) then b:=(copy(align(f1.filename),10,3)>=copy(align(f2.filename),10,3))
                     else b:=(copy(align(f1.filename),10,3)>copy(align(f2.filename),10,3));
      'F':if (isequ) then b:=(f1.filepoints>=f2.filepoints)
                     else b:=(f1.filepoints>f2.filepoints);
      'N':if (isequ) then b:=(f1.filename>=f2.filename)
                     else b:=(f1.filename>f2.filename);
      'S':if (isequ) then b:=(f1.filesize>=f2.filesize)
                     else b:=(f1.filesize>f2.filesize);
      'T':if (isequ) then b:=(f1.NumDownloads>=f2.NumDownloads)
                     else b:=(f1.NumDownloads>f2.NumDownloads);
    end;
  end;

begin
  getmemory(1);
  getmemory(2);
  if (r1<r2) then begin
    seekfile(r1); blockread(pf,readptr^,recsize);
    move(readptr^[0],f1,sizeof(fheaderrec));
    seekfile(r2); blockread(pf,readptr2^,recsize);
    move(readptr2^[0],f2,sizeof(fheaderrec));
  end else begin
    seekfile(r2); blockread(pf,readptr2^,recsize);
    move(readptr2^[0],f2,sizeof(fheaderrec));
    seekfile(r1); blockread(pf,readptr^,recsize);
    move(readptr^[0],f1,sizeof(fheaderrec));
  end;
  disposememory(1);
  disposememory(2);

  if (isascend) then islesser:=not islesser;
  if (islesser) then figure1 else figure2;
  greater:=b;
end;

(*                                                                           *
 *  While I personally think labels are stupid as *@#((#@!#$, and they look  *
 *  like *#$@*, I kept them in for lack of a better idea!                    *
 *)
procedure mainsort(pl:integer);
label 10,20,30,40,50,60,70,80;
const maxsortrec=2000;   (* maximum size of directory which can be processed *)
var hold,pass:array[1..maxsortrec] of integer;
    a,b,c,d,e,f,x:integer;
begin
  a:=pl; b:=0; c:=0; d:=1; e:=1; f:=0;
10:
  if (a-e<9) then goto 70;
  b:=e; c:=a;
20:
    write(^H' '^H);
    if (wh=5) then wh:=1;
    write(spin[wh]);
    inc(wh);
  if (greater(TRUE,FALSE,b,c)) then begin
    switch(c,b);
    goto 60;
  end;
30:
  dec(c);
  if (c>b) then goto 20;
  inc(c);
40:
  inc(d);
  if (b-e<a-c) then begin
    hold[d]:=c; pass[d]:=a;
    a:=b;
    goto 10;
  end;
  hold[d]:=e; pass[d]:=b;
  e:=c;
  goto 10;
50:
    write(^H' '^H);
    if (wh=5) then wh:=1;
    write(spin[wh]);
    inc(wh);
  if (greater(FALSE,FALSE,c,b)) then begin
    switch(c,b);
    goto 30;
  end;
60:
  inc(b);
  if (c>b) then goto 50;
  inc(c);
  goto 40;
70:
  if (a-e+1=1) then goto 80;
  for b:=e+1 to a do begin
    write(^H' '^H);
    if (wh=5) then wh:=1;
    write(spin[wh]);
    inc(wh);
    for c:=e to (b-1) do begin
      f:=b-c+e-1;
      if (greater(TRUE,FALSE,f,f+1)) then begin
        x:=f+1;
        switch(f,x);
      end;
    end;
    end;
80:
  e:=hold[d]; a:=pass[d];
  dec(d);
  if (d=0) then exit;
  goto 10;
end;

procedure flipit(pl:integer);
var i:integer;
begin
  for i:=1 to (pl div 2) do begin
    write(^H' '^H);
    if (wh=5) then wh:=1;
    write(spin[wh]);
    inc(wh);
  switch(i,(pl-i)+1);
  end;
  write(^H' '^H);
end;

procedure bubblesort(pl:integer);
var i,j,numdone:integer;
    foundit:boolean;
begin
  if (bubblesortend>pl) then bubblesortend:=pl;  { should never happen, but...}
  numdone:=0;
  repeat
    i:=(bubblesortend+1)-numdone;
    foundit:=FALSE;
    while ((i<=pl) and (not foundit)) do begin
                write(^H' '^H);
                if (wh=5) then wh:=1;
                write(spin[wh]);
                inc(wh);
                if (greater(FALSE,TRUE,1,i)) then begin
                        foundit:=TRUE;
                end else inc(i);
    end;
    getmemory(1);
    getmemory(2);
    seekfile(1); blockread(pf,readptr^,recsize);

    for j:=1 to i-2 do begin
      seekfile(j+1); blockread(pf,readptr2^,recsize);
      seekfile(j); blockwrite(pf,readptr2^,recsize);
    end;

    seekfile(i-1); blockwrite(pf,readptr^,recsize);
    disposememory(1);
    disposememory(2);
    inc(numdone);
  until ((numdone>=bubblesortend));
  write(^H' '^H);
end;

function analysis(pl:integer):integer;
var i,j:integer;
    c1,c2:boolean;
begin
  analysis:=1;
  c1:=TRUE; c2:=TRUE;
  for i:=1 to pl-1 do begin
    if (not greater(TRUE,TRUE,i,i+1)) then c1:=FALSE;    { a }
    if (not greater(FALSE,TRUE,i,i+1)) then c2:=FALSE;   { d }
  end;
  if (c1) then analysis:=2;     { list is backwards, so flip it }
  if (c2) then analysis:=0;     { list is already sorted }
  if ((not c1) and (not c2)) then begin
    c1:=FALSE; j:=0;
    i:=pl-1;
    while ((i>=1) and (not c1)) do begin
      if (not greater(FALSE,TRUE,i,i+1)) then begin c1:=TRUE; j:=i; end;
      dec(i);
    end;
    if ((c1) and (j/pl<0.15)) then begin
      analysis:=3;
      bubblesortend:=j;
    end;
  end;
end;

procedure sortfiles(b:integer; var abort,next:boolean);
var s:string;
    pl,sortt:integer;
    nofile:boolean;
begin
    if (fbdirdlpath in memuboard.fbstat) then begin
                assign(pf,adrv(memuboard.dlpath)+memuboard.filename+'.NFD');
    end else begin
                assign(pf,adrv(systat.filepath)+memuboard.filename+'.NFD');
    end;
    filemode:=66;
    nofile:=FALSE;
    {$I-} reset(pf,1); {$I+}
    if (ioresult=0) then begin
    pl:=(filesize(pf) div (sizeof(Fheaderrec) + (syst.nkeywords * sizeof(FKeywordREC)) +
                (syst.ndesclines * sizeof(FDescREC))));
    end else begin
        pl:=0;
        nofile:=TRUE;
    end;
    textcolor(7);
    textbackground(0);
    write('Sorting ');
    textcolor(3);
    write(mln(cstr(b),5));
    textcolor(7);
    write(' - ');
    cwrite(mln(memuboard.name,32));
    textcolor(7);
    write(' [',mln(cstr(pl)+' Files',10),']... ');
    wh:=1;
    abort:=FALSE; next:=FALSE;
    sortt:=analysis(pl);
    case sortt of
      0:;
      1:mainsort(pl);
      2:flipit(pl);
      3:bubblesort(pl);
    end;
    case sortt of
        0:begin
                s:='Not Needed';
                write(^H' '^H);
          end;
        1:begin
                s:='Sorted';
                write(^H' '^H);
          end;
        2:s:='Flipped';
        3:s:='BubbleSort';
    end;
    textcolor(3);
    writeln(s);
    if not(nofile) then close(pf);
    if (sortt<>0) then begin
    inc(totfils,pl);
    inc(totbases);
    end;
end;


{
  Sort Type:   D - Date
               B - Brief Description
               N - Filename
               E - Extention
               F - File Points
               S - Size
               T - Times Downloaded

  Sort Order:  A - Ascending
               D - Descending

}



procedure sort(bnum:integer;c1:char; global,cdrom,ascnd,ps:boolean);
var sortstart,sortend,tooktime:datetimerec;
    i:integer;
    c:char;
    s,s2:string;
    abort,next,savepause:boolean;

        function showsort(ch8:char):string;
        begin
               case ch8 of
                'D':showsort:='Date';
                'N':showsort:='Filename';
                'E':showsort:='Extension';
                'F':showsort:='Filepoints';
                'S':showsort:='Size';
                'T':showsort:='Times DLed';
               end;
        end;

        function showorder(ab:boolean):string;
        begin
        if (ab) then showorder:='Ascending' else showorder:='Descending';
        end;

begin
  assign(ulf,adrv(systat.gfilepath)+'FBASES.DAT');
  filemode:=66; 
  {$I-} reset(ulf); {$I+}
  if ioresult<>0 then begin
                displaybox('Error reading in filebase information.',3000);
                exit;
        end;
  maxulb:=filesize(ulf)-1;
  if (bnum>maxulb) then exit;
  seek(ulf,bnum);
  read(ulf,memuboard);
  sortt:=c1;
  isascend:=ascnd;


  if (global) then begin
  if (cdrom) then s2:='All filebases' else
  s2:='All filebases - No CD';
  end
  else s2:='Filebase #'+cstr(bnum);
  setwindow2(w,1,6,79,24,3,0,8,s2,'Sort by '+showsort(c1)+' ('+showorder(ascnd)+')',FALSE);
  window(3,8,77,22);

  totfils:=0; totbases:=0;

  getdatetime(sortstart);
  abort:=FALSE; next:=FALSE;
  if (not global) then
    sortfiles(bnum,abort,next)
  else begin
    i:=0;
    abort:=FALSE;
    next:=FALSE;
    while (i<=maxulb) and not(abort) do begin
      seek(ulf,i);
      read(ulf,memuboard);
      if not(cdrom) then begin
            if not(memuboard.cdrom) then
                      sortfiles(i,abort,next);
      end else sortfiles(i,abort,next);
      if (keypressed) then begin
        c:=readkey;
        case upcase(c) of
                'A',#32,^C,#27:abort:=TRUE;
        end;
      end;
      inc(i);
    end;
  end;
  getdatetime(sortend);
  timediff(tooktime,sortstart,sortend);
  
  writeln;
  textcolor(7);
  write('Files: ');
  textcolor(3);
  write(cstr(totfils));
  textcolor(7);
  write(' Bases: ');
  textcolor(3);
  write(cstr(totbases));
  textcolor(7);
  write(' Time : ');
  textcolor(3);
  writeln(longtim(tooktime)+'.');
  if (ps) then begin
                           window(1,1,80,25);
                           textcolor(14);
                           textbackground(0);
                           gotoxy(1,25);
                           clreol;
                           write('Press any key to continue.');
  while not(keypressed) do begin end;
  c:=readkey;
  end;
  removewindow(w);
                           window(1,1,80,25);
                           textcolor(14);
                           textbackground(0);
                           gotoxy(1,25);
                           clreol;
  close(ulf);
end;

end.

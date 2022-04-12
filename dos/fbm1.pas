{$O+}
unit fbm1;

interface

uses dos,crt,myio,misc,fbcommon,cdrom3,mkmisc,mkstring,editdesc,spawno,
        procs2,nxfs2,sysop20,fbm2,fbm3;

procedure fblistbox(var wind:windowrec;var ti,si:integer; TLX,TLY,BRX,BRY,tcolr,bcolr,
        boxtype:integer;title,title2:string;shadow:boolean);
procedure cleanuptemp;

implementation

uses fbm4;

procedure cleanuptemp;
var f:file;
begin
if (indexopen) then begin
        close(tff);
        indexopen:=FALSE;
end;
{$I-} erase(tff); {$I+}
if (ioresult<>0) then begin end;
if (index2open) then begin
        close(tff2);
        index2open:=FALSE;
end;
{$I-} erase(tff2); {$I+}
if (ioresult<>0) then begin end;
end;



procedure fblistbox(var wind:windowrec;var ti,si:integer; TLX,TLY,BRX,BRY,tcolr,bcolr,
        boxtype:integer;title,title2:string;shadow:boolean);
var total,x,current,top,height:integer;
    c:char;
    s:string;
    done:boolean;
    w2:windowrec;
    ii4,ii5:integer;
    temps:string[2];
    gl,cd,nofiles:boolean;
    tempx,cur2,top2:integer;
    lastscroll,fnd:integer;


    function getdescription:boolean;
    var f2,f3:text;
        x3:integer;
        s3:string;
    begin
    window(1,1,80,25);
    textcolor(14);
    textbackground(0);
    gotoxy(1,25);
    clreol;
    write('Esc');
    textcolor(7);
    write('=Exit ');
    textcolor(14);
    write('F10');
    textcolor(7);
    write('=Save');
    if (exist('FILE_ID.DIZ')) then begin
    assign(f3,'FILE_ID.DIZ');
    {$I-} reset(f3); {$I+}
    if (ioresult=0) then begin
            assign(f2,adrv(systat.temppath)+'FILETMP');
            rewrite(f2);
            x3:=1;
            while not(eof(f3)) and (x3<=syst.ndesclines) do begin
                readln(f3,s3);
                writeln(f2,s3);
            end;
            close(f2);
            close(f3);
    end;
    end;
    getdescription:=editdescription(syst.ndesclines);
    cursoron(FALSE);
    end;


    function getdescription2:boolean;
    var f2,f3:text;
        x3:integer;
        s3:string;
    begin
    window(1,1,80,25);
    textcolor(14);
    textbackground(0);
    gotoxy(1,25);
    clreol;
    write('Esc');
    textcolor(7);
    write('=Exit ');
    textcolor(14);
    write('F10');
    textcolor(7);
    write('=Save');
    assign(f2,adrv(systat.temppath)+'FILETMP');
    rewrite(f2);
    NXF.DescStartup;
    s3:=NXF.GetDescLine;
    while (s3<>#1+'EOF'+#1) do begin
                writeln(f2,mln(s3,45));
                s3:=NXF.GetDescLine;
    end;
    close(f2);
    getdescription2:=editdescription(syst.ndesclines);
    NXF.DescStartup;
    assign(f2,adrv(systat.temppath)+'FILETMP');
    {$I-} reset(f2); {$I+}
    if (ioresult=0) then begin
        for x3:=1 to syst.ndesclines do NXF.SetDescLine(#1+'EOF'+#1,x3);
        x3:=1;
        getdescription2:=TRUE;
        while not(eof(f2)) and (x3<=syst.ndesclines) do begin
                readln(f2,s3);
                NXF.SetDescLine(copy(s3,1,45),x3);
                inc(x3);
        end;
        close(f2);
        {$I-} erase(f2); {$I+}
        if (ioresult<>0) then begin end;
    end;
    cursoron(FALSE);
    end;

procedure recomment(tp:byte);
var savwin:windowrec;
    x,x3,ox,oy,x1,y1,x2,y2:integer;
    result:integer;
    oldnum:integer;
    oldf:ulrec;

  function commentfile(filen:string;cnum:integer):integer;
  var ecode:integer;
  begin
  textcolor(7);
  textbackground(0);
  arcbatch(ecode,'.',adrv(systat.utilpath)+'NXAPS.EXE 4 c '+adrv(curf.dlpath)+filen+' '+systat.filearccomment[cnum]);
  commentfile:=ecode;
  end;

  procedure savecursettings;
  begin
  savescreen(savwin,1,1,80,25);
  ox:=wherex;
  oy:=wherey;
  x1:=Lo(windmin)+1;
  y1:=Hi(windmin)+1;
  x2:=lo(windmax)+1;
  y2:=hi(windmax)+1;
  window(1,1,80,25);
  end;

  procedure restorecursettings;
  begin
     removewindow(savwin);
     window(x1,y1,x2,y2);
     gotoxy(ox,oy);
  end;

begin
oldf:=curf;
oldnum:=curread;
case tp of
        1:if not(curf.cdrom) then begin
          if (curf.cmttype<>0) then begin
          NXF.Seekfile(current);
          NXF.Readheader;
          savecursettings;
          window(1,1,80,24);
          clrscr;
          textcolor(15);
          textbackground(1);
                                          gotoxy(1,1);
                                          clreol;
                                          gotoxy(1,2);
                                          clreol;
                                          gotoxy(1,3);
                                          clreol;
                                          gotoxy(1,1);
          writeln('Commenting file '+adrv(curf.dlpath)+NXF.Fheader.filename+' with '+
                systat.filearccomment[curf.cmttype]);
          window(1,4,80,24);

          result:=commentfile(NXF.Fheader.filename,curf.cmttype);
          restorecursettings;
          case result of
                0:begin
                  end;
                1:displaybox('Error commenting file.',3000);
                4:displaybox('This file is AV protected.',3000);
          end;
          window(x1,y1,x2,y2);
          gotoxy(ox,oy);
end else begin
        displaybox('This filebase is not set to comment files.',3000);
end;
          end else begin
                displaybox('This base is on CD-ROM.',3000);
          end;
        2:if not(curf.cdrom) then begin         { All files this base }
          if (curf.cmttype<>0) then begin
          savecursettings;
          clrscr;
          window(1,1,80,24);
          for x:=1 to NXF.Numfiles do begin
          NXF.Seekfile(x);
          NXF.Readheader;
          textcolor(15);
          textbackground(1);
                                          gotoxy(1,1);
                                          clreol;
                                          gotoxy(1,2);
                                          clreol;
                                          gotoxy(1,3);
                                          clreol;
                                          gotoxy(1,1);
          writeln('Commenting file '+adrv(curf.dlpath)+NXF.Fheader.filename+' with '+
                systat.filearccomment[curf.cmttype]);
          textcolor(7);
          textbackground(0);
          window(1,4,80,24);
          result:=commentfile(NXF.Fheader.filename,curf.cmttype);
          case result of
                0:begin
                  end;
                1:begin
                                                                window(1,1,80,24);
                                                                textcolor(15);
                                                                textbackground(1);
                                                                gotoxy(1,3);
                                                                clreol;
                  writeln('Error commenting file...');
                  textcolor(7);
                  textbackground(0);
                  end;
                4:begin
                                                                window(1,1,80,24);
                                                                textcolor(15);
                                                                textbackground(1);
                                                                gotoxy(1,3);
                                                                clreol;
                  writeln('This file is AV protected...');
                  textcolor(7);
                  textbackground(0);
                  end;
          end;
          end;
          restorecursettings;
          window(x1,y1,x2,y2);
          gotoxy(ox,oy);
end else begin
        displaybox('This filebase is not set to comment files.',3000);
end;
          end else begin
                displaybox('This base is on CD-ROM.',3000);
          end;
        3:begin         { All files all bases - NO CD ROMS! }
          x3:=0;
          loadfilebase(x3,1);
          savecursettings;
          clrscr;
          window(1,1,80,24);
          while (x3<>-1) do begin
          if not(curf.cdrom) then begin
          if (curf.cmttype<>0) then begin
          for x:=1 to NXF.Numfiles do begin
          NXF.Seekfile(x);
          NXF.Readheader;
          textcolor(15);
          textbackground(1);
                                          gotoxy(1,1);
                                          clreol;
                                          gotoxy(1,2);
                                          clreol;
                                          gotoxy(1,3);
                                          clreol;
                                          gotoxy(1,1);
          hback:=1;
          cwrite('File base : '+curf.name+#13+#10);
          hback:=255;
          clreol;
          writeln('Commenting file '+adrv(curf.dlpath)+NXF.Fheader.filename+' with '+
                systat.filearccomment[curf.cmttype]);
          textcolor(7);
          textbackground(0);
          window(1,4,80,24);
          result:=commentfile(NXF.Fheader.filename,curf.cmttype);
          case result of
                0:begin
                  end;
                1:begin
                                                                window(1,1,80,24);
                                                                textcolor(15);
                                                                textbackground(1);
                                                                gotoxy(1,3);
                                                                clreol;
                  writeln('Error commenting file...');
                  textcolor(7);
                  textbackground(0);
                  end;
                4:begin
                                                                window(1,1,80,24);
                                                                textcolor(15);
                                                                textbackground(1);
                                                                gotoxy(1,3);
                                                                clreol;
                  writeln('This file is AV protected...');
                  textcolor(7);
                  textbackground(0);
                  end;
          end;
          end;
          end;
          end;
          inc(x3);
          loadfilebase(x3,1);
          end;
        curread:=oldnum;
        curf:=oldf;
        if (fbdirdlpath in curf.fbstat) then begin
                        NXF.Init(adrv(curf.dlpath)+curf.filename+'.NFD', syst.nkeywords,syst.ndesclines);
        end else begin
                        NXF.Init(adrv(systat.filepath)+curf.filename+'.NFD', syst.nkeywords,syst.ndesclines);
        end;
        nofiles:=FALSE;
        total:=NXF.Numfiles;
        if (total=0) then nofiles:=TRUE;
        if (current>total) then current:=total;
          restorecursettings;
          window(x1,y1,x2,y2);
          gotoxy(ox,oy);
          end;
   end;
end;

        procedure getcommenttype;
        var cho:array[1..3] of string;
            w3:windowrec;
            ch3:char;
            cur:integer;
            d3:boolean;
        begin
        setwindow(w3,20,10,60,16,3,0,8,'Comment Method',TRUE);
        cho[1]:='Comment this file only              ';
        cho[2]:='Comment all files in this file base ';
        cho[3]:='Comment all files in all file bases ';
        for cur:=1 to 3 do begin
                textcolor(7);
                textbackground(0);
                gotoxy(2,cur+1);
                write(cho[cur]);
        end;
        cur:=1;
        d3:=FALSE;
        repeat
        gotoxy(2,cur+1);
        textcolor(15);
        textbackground(1);
        write(cho[cur]);
        while not(keypressed) do begin end;
        ch3:=readkey;
        case ch3 of
                #0:begin
                        ch3:=readkey;
                        checkkey(ch3);
                        case ch3 of
                                #72:begin
                                        gotoxy(2,cur+1);
                                        textcolor(7);
                                        textbackground(0);
                                        write(cho[cur]);
                                        dec(cur);
                                        if (cur=0) then cur:=3;
                                    end;
                                #80:begin
                                        gotoxy(2,cur+1);
                                        textcolor(7);
                                        textbackground(0);
                                        write(cho[cur]);
                                        inc(cur);
                                        if (cur=4) then cur:=1;
                                    end;
                        end;
                   end;
                #13:begin
                        removewindow(w3);
                        textcolor(7);
                        textbackground(0);
                        recomment(cur);
                        d3:=TRUE;
                    end;
                #27:begin
                        d3:=TRUE;
                        removewindow(w3);
                    end;
        end;
        until (d3);
        end;

    procedure updatefile;
    var mtf:file;
        fsize:longint;
        ask1,ask2:boolean;
        fpacked:longint;
        dt:datetime;
    begin
    ask1:=FALSE;
    ask2:=FALSE;
    assign(mtf,adrv(curf.dlpath)+NXF.Fheader.Filename);
    {$I-} reset(mtf,1); {$I+}
    if (ioresult<>0) then begin
        ask1:=TRUE;
    end else begin
        fsize:=filesize(mtf);
        if (NXF.Fheader.FileSize<>fsize) then begin
        ask1:=TRUE;
        end;
        GetFTime(mtf,fpacked);
        UnpackTime(fpacked,dt);
        if (NXF.Fheader.FileDate<>DTToUnixDate(dt)) then begin
                ask2:=TRUE;
        end;
        close(mtf);
    end;
    if (ask1) or (ask2) then begin
                if (ask1) then NXF.Fheader.FileSize:=fsize;
                if (ask2) then NXF.Fheader.FileDate:=DTToUnixDate(dt);
                NXF.ReWriteHeader(NXF.Fheader);
    end;
    end;


procedure global(tp:byte;spec:string;g:globalpass);
var savwin,savwin2:windowrec;
    s3:string;
    x,x3,ox,oy,x1,y1,x2,y2:integer;
    result:integer;
    tmpf:file;
    tt:text;
    fpacked:longint;
    dt:datetime;
    oldnum:integer;
    oldf:ulrec;


  function updatedesc(filen:string):integer;
  var ecode:integer;
  begin
  textcolor(7);
  textbackground(0);
  {$I-} mkdir('.\~FBMTMP'); {$I+}
  if (ioresult<>0) then exit;
  arcbatch(ecode,'.\~FBMTMP',adrv(systat.utilpath)+'NXAPS.EXE 4 e '+adrv(curf.dlpath)+filen+' FILE_ID.DIZ');
  updatedesc:=ecode;
  end;

  procedure cleanupdir;
  begin
  purgedir('.\~FBMTMP');
  {$I-} rmdir('.\~FBMTMP'); {$I+}
  if (ioresult<>0) then exit;
  end;

  procedure savecursettings;
  begin
  savescreen(savwin,1,1,80,25);
  ox:=wherex;
  oy:=wherey;
  x1:=Lo(windmin)+1;
  y1:=Hi(windmin)+1;
  x2:=lo(windmax)+1;
  y2:=hi(windmax)+1;
  window(1,1,80,25);
  end;

  procedure restorecursettings;
  begin
     removewindow(savwin);
     window(x1,y1,x2,y2);
     gotoxy(ox,oy);
  end;


procedure fixspec;
var i:integer;
    fn,fn2,fn3:string;
begin
  fn:=spec;
  if (pos('.',fn)=0) then fn:=fn+'.';
  if (pos('*',fn)<>0) then begin
      fn2:=align(fn);
      fn3:=copy(fn2,10,3);
      fn2:=copy(fn2,1,8);
      if (pos('*',fn2)<>0) then begin
          while (pos(' ',fn2)<>0) do begin
                fn2[pos(' ',fn2)]:='?';
          end;
          fn2[pos('*',fn2)]:='?';
      end;
      if (pos('*',fn3)<>0) then begin
          while (pos(' ',fn3)<>0) do begin
                fn3[pos(' ',fn3)]:='?';
          end;
          fn3[pos('*',fn3)]:='?';
      end;
      fn2:=sqoutsp(fn2);
      fn3:=sqoutsp(fn3);
      fn:=fn2+'.'+fn3;
  end;
  spec:=fn;
end;

function align(fn:string):string;
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

begin
oldf:=curf;
oldnum:=curread;
fixspec;
case tp of
        1:begin
               NXF.Seekfile(current);
               NXF.Readheader;
               if (fit(align(spec),align(nxf.fheader.filename))) then begin
                        if (g[2]=1) then begin
                                   assign(tmpf,adrv(curf.dlpath)+NXF.Fheader.Filename);
                                   {$I-} reset(tmpf,1); {$I+}
                                   if (ioresult<>0) then begin
                                            NXF.Fheader.Filesize:=0;
                                            NXF.Fheader.FileFlags:=NXF.Fheader.FileFlags+[ffisrequest];
                                   end else begin
                                            if (ffisrequest in NXF.Fheader.FileFlags) then
                                                    NXF.Fheader.FileFlags:=NXF.Fheader.FileFlags-[ffisrequest];
                                            NXF.Fheader.Filesize:=filesize(tmpf);
                                            GetFTime(tmpf,fpacked);
                                            UnpackTime(fpacked,dt);
                                            NXF.Fheader.FileDate:=DTToUnixDate(dt);
                                            close(tmpf);
                                   end;
                        end;
                        if (g[3]=1) then begin
                                NXF.Fheader.FileFlags:=NXF.Fheader.Fileflags+[ffnotval];
                        end;
                        if (g[3]=2) then begin
                                NXF.Fheader.FileFlags:=NXF.Fheader.Fileflags-[ffnotval];
                        end;
                        if (g[4]=1) then begin
                                NXF.Fheader.FileFlags:=NXF.Fheader.Fileflags+[ffisrequest];
                        end;
                        if (g[4]=2) then begin
                                NXF.Fheader.FileFlags:=NXF.Fheader.Fileflags-[ffisrequest];
                        end;
                        if (g[5]=1) then begin
                                NXF.Fheader.FileFlags:=NXF.Fheader.Fileflags+[ffresumelater];
                        end;
                        if (g[5]=2) then begin
                                NXF.Fheader.FileFlags:=NXF.Fheader.Fileflags-[ffresumelater];
                        end;
                        if (g[6]=1) then begin
                                NXF.Fheader.FileFlags:=NXF.Fheader.Fileflags+[ffisfree];
                        end;
                        if (g[6]=2) then begin
                                NXF.Fheader.FileFlags:=NXF.Fheader.Fileflags-[ffisfree];
                        end;
                        if (g[7]=1) then begin
                                NXF.Fheader.FileFlags:=NXF.Fheader.Fileflags+[ffchecksecurity];
                        end;
                        if (g[7]=2) then begin
                                NXF.Fheader.FileFlags:=NXF.Fheader.Fileflags-[ffchecksecurity];
                        end;
                        if (g[8]=1) then begin
                                NXF.Fheader.FileFlags:=NXF.Fheader.Fileflags+[ffishatched];
                        end;
                        if (g[8]=2) then begin
                                NXF.Fheader.FileFlags:=NXF.Fheader.Fileflags-[ffishatched];
                        end;
                        if (g[9]=1) then begin
                                NXF.Fheader.FileFlags:=NXF.Fheader.Fileflags+[ffhidden];
                        end;
                        if (g[9]=2) then begin
                                NXF.Fheader.FileFlags:=NXF.Fheader.Fileflags-[ffhidden];
                        end;
                        NXF.Rewriteheader(NXF.Fheader);
                        if (g[1]=1) then begin
                                          savecursettings;
                                          clrscr;
                                          window(1,1,80,24);
                                          textcolor(15);
                                          textbackground(1);
                                          gotoxy(1,1);
                                          clreol;
                                          gotoxy(1,1);
                                          writeln('Updating Desc: '+adrv(curf.dlpath)+NXF.Fheader.filename);
                                          window(1,2,80,24);
                                          result:=updatedesc(NXF.Fheader.filename);
                                          restorecursettings;
                                          case result of
                                                0:begin
                                                  assign(tt,'.\~FBMTMP\FILE_ID.DIZ');
                                                  {$I-} reset(tt); {$I+}
                                                  if (ioresult=0) then begin
                                                        NXF.DescStartup;
                                                        for x3:=1 to syst.ndesclines do NXF.SetDescLine(#1+'EOF'+#1,x3);
                                                        x3:=1;
                                                        while not(eof(tt)) and (x3<=syst.ndesclines) do begin
                                                                readln(tt,s3);
                                                                NXF.SetDescLine(copy(s3,1,45),x3);
                                                                inc(x3);
                                                        end;
                                                        close(tt);
                                                 end;
                                                 end;
                                                1:displaybox('Error extracting FILE_ID.DIZ ...',3000);
                                          end;
                                          cleanupdir;
                                          window(x1,y1,x2,y2);
                                          gotoxy(ox,oy);
                        end;
                 end;
          end;
        2:begin
                displaybox2(savwin2,'Updating files...');
                for x:=1 to NXF.Numfiles do begin
                NXF.Seekfile(x);
                NXF.Readheader;
                if (fit(align(spec),align(nxf.fheader.filename))) then begin
                        if (g[2]=1) then begin
                                   assign(tmpf,adrv(curf.dlpath)+NXF.Fheader.Filename);
                                   {$I-} reset(tmpf,1); {$I+}
                                   if (ioresult<>0) then begin
                                            NXF.Fheader.Filesize:=0;
                                            NXF.Fheader.FileFlags:=NXF.Fheader.FileFlags+[ffisrequest];
                                   end else begin
                                            if (ffisrequest in NXF.Fheader.FileFlags) then
                                                    NXF.Fheader.FileFlags:=NXF.Fheader.FileFlags-[ffisrequest];
                                            NXF.Fheader.Filesize:=filesize(tmpf);
                                            GetFTime(tmpf,fpacked);
                                            UnpackTime(fpacked,dt);
                                            NXF.Fheader.FileDate:=DTToUnixDate(dt);
                                            close(tmpf);
                                   end;
                        end;
                        if (g[3]=1) then begin
                                NXF.Fheader.FileFlags:=NXF.Fheader.Fileflags+[ffnotval];
                        end;
                        if (g[3]=2) then begin
                                NXF.Fheader.FileFlags:=NXF.Fheader.Fileflags-[ffnotval];
                        end;
                        if (g[4]=1) then begin
                                NXF.Fheader.FileFlags:=NXF.Fheader.Fileflags+[ffisrequest];
                        end;
                        if (g[4]=2) then begin
                                NXF.Fheader.FileFlags:=NXF.Fheader.Fileflags-[ffisrequest];
                        end;
                        if (g[5]=1) then begin
                                NXF.Fheader.FileFlags:=NXF.Fheader.Fileflags+[ffresumelater];
                        end;
                        if (g[5]=2) then begin
                                NXF.Fheader.FileFlags:=NXF.Fheader.Fileflags-[ffresumelater];
                        end;
                        if (g[6]=1) then begin
                                NXF.Fheader.FileFlags:=NXF.Fheader.Fileflags+[ffisfree];
                        end;
                        if (g[6]=2) then begin
                                NXF.Fheader.FileFlags:=NXF.Fheader.Fileflags-[ffisfree];
                        end;
                        if (g[7]=1) then begin
                                NXF.Fheader.FileFlags:=NXF.Fheader.Fileflags+[ffchecksecurity];
                        end;
                        if (g[7]=2) then begin
                                NXF.Fheader.FileFlags:=NXF.Fheader.Fileflags-[ffchecksecurity];
                        end;
                        if (g[8]=1) then begin
                                NXF.Fheader.FileFlags:=NXF.Fheader.Fileflags+[ffishatched];
                        end;
                        if (g[8]=2) then begin
                                NXF.Fheader.FileFlags:=NXF.Fheader.Fileflags-[ffishatched];
                        end;
                        if (g[9]=1) then begin
                                NXF.Fheader.FileFlags:=NXF.Fheader.Fileflags+[ffhidden];
                        end;
                        if (g[9]=2) then begin
                                NXF.Fheader.FileFlags:=NXF.Fheader.Fileflags-[ffhidden];
                        end;
                        NXF.RewriteHeader(NXF.Fheader);
                        if (g[1]=1) then begin
                                          savecursettings;
                                          clrscr;
                                          window(1,1,80,24);
                                          textcolor(15);
                                          textbackground(1);
                                          gotoxy(1,1);
                                          clreol;
                                          gotoxy(1,1);
                                          writeln('Updating Desc: '+adrv(curf.dlpath)+NXF.Fheader.filename);
                                          window(1,2,80,24);
                                          result:=updatedesc(NXF.Fheader.filename);
                                          restorecursettings;
                                          case result of
                                                0:begin
                                                  assign(tt,'.\~FBMTMP\FILE_ID.DIZ');
                                                  {$I-} reset(tt); {$I+}
                                                  if (ioresult=0) then begin
                                                        NXF.DescStartup;
                                                        for x3:=1 to syst.ndesclines do NXF.SetDescLine(#1+'EOF'+#1,x3);
                                                        x3:=1;
                                                        while not(eof(tt)) and (x3<=syst.ndesclines) do begin
                                                                readln(tt,s3);
                                                                NXF.SetDescLine(copy(s3,1,45),x3);
                                                                inc(x3);
                                                        end;
                                                        close(tt);
                                                 end;
                                                 end;
                                                1:displaybox('Error extracting FILE_ID.DIZ ...',3000);
                                          end;
                                          cleanupdir;
                                          window(x1,y1,x2,y2);
                                          gotoxy(ox,oy);
                        end;
                 end;
              end;
              removewindow(savwin2);
          end;
        3:begin         { All files all bases - NO CD ROMS! }
          x3:=0;
          loadfilebase(x3,1);
          while (x3<>-1) do begin
                window(1,1,80,25);
                gotoxy(1,25);
                textcolor(7);
                textbackground(0);
                clreol;
                cwrite('Processing: '+curf.name);
                window(1,1,80,24);
                displaybox2(savwin2,'Updating files...');
                for x:=1 to NXF.Numfiles do begin
                NXF.Seekfile(x);
                NXF.Readheader;
                if (fit(align(spec),align(nxf.fheader.filename))) then begin
                        if (g[2]=1) then begin
                                   assign(tmpf,adrv(curf.dlpath)+NXF.Fheader.Filename);
                                   {$I-} reset(tmpf,1); {$I+}
                                   if (ioresult<>0) then begin
                                            NXF.Fheader.Filesize:=0;
                                            NXF.Fheader.FileFlags:=NXF.Fheader.FileFlags+[ffisrequest];
                                   end else begin
                                            if (ffisrequest in NXF.Fheader.FileFlags) then
                                                    NXF.Fheader.FileFlags:=NXF.Fheader.FileFlags-[ffisrequest];
                                            NXF.Fheader.Filesize:=filesize(tmpf);
                                            GetFTime(tmpf,fpacked);
                                            UnpackTime(fpacked,dt);
                                            NXF.Fheader.FileDate:=DTToUnixDate(dt);
                                            close(tmpf);
                                   end;
                        end;
                        if (g[3]=1) then begin
                                NXF.Fheader.FileFlags:=NXF.Fheader.Fileflags+[ffnotval];
                        end;
                        if (g[3]=2) then begin
                                NXF.Fheader.FileFlags:=NXF.Fheader.Fileflags-[ffnotval];
                        end;
                        if (g[4]=1) then begin
                                NXF.Fheader.FileFlags:=NXF.Fheader.Fileflags+[ffisrequest];
                        end;
                        if (g[4]=2) then begin
                                NXF.Fheader.FileFlags:=NXF.Fheader.Fileflags-[ffisrequest];
                        end;
                        if (g[5]=1) then begin
                                NXF.Fheader.FileFlags:=NXF.Fheader.Fileflags+[ffresumelater];
                        end;
                        if (g[5]=2) then begin
                                NXF.Fheader.FileFlags:=NXF.Fheader.Fileflags-[ffresumelater];
                        end;
                        if (g[6]=1) then begin
                                NXF.Fheader.FileFlags:=NXF.Fheader.Fileflags+[ffisfree];
                        end;
                        if (g[6]=2) then begin
                                NXF.Fheader.FileFlags:=NXF.Fheader.Fileflags-[ffisfree];
                        end;
                        if (g[7]=1) then begin
                                NXF.Fheader.FileFlags:=NXF.Fheader.Fileflags+[ffchecksecurity];
                        end;
                        if (g[7]=2) then begin
                                NXF.Fheader.FileFlags:=NXF.Fheader.Fileflags-[ffchecksecurity];
                        end;
                        if (g[8]=1) then begin
                                NXF.Fheader.FileFlags:=NXF.Fheader.Fileflags+[ffishatched];
                        end;
                        if (g[8]=2) then begin
                                NXF.Fheader.FileFlags:=NXF.Fheader.Fileflags-[ffishatched];
                        end;
                        if (g[9]=1) then begin
                                NXF.Fheader.FileFlags:=NXF.Fheader.Fileflags+[ffhidden];
                        end;
                        if (g[9]=2) then begin
                                NXF.Fheader.FileFlags:=NXF.Fheader.Fileflags-[ffhidden];
                        end;
                        NXF.Rewriteheader(NXF.Fheader);
                        if (g[1]=1) then begin
                                          savecursettings;
                                          clrscr;
                                          window(1,1,80,24);
                                          textcolor(15);
                                          textbackground(1);
                                          gotoxy(1,1);
                                          clreol;
                                          gotoxy(1,1);
                                          writeln('Updating Desc: '+adrv(curf.dlpath)+NXF.Fheader.filename);
                                          window(1,2,80,24);
                                          result:=updatedesc(NXF.Fheader.filename);
                                          restorecursettings;
                                          case result of
                                                0:begin
                                                  assign(tt,'.\~FBMTMP\FILE_ID.DIZ');
                                                  {$I-} reset(tt); {$I+}
                                                  if (ioresult=0) then begin
                                                        NXF.DescStartup;
                                                        for x3:=1 to syst.ndesclines do NXF.SetDescLine(#1+'EOF'+#1,x3);
                                                        x3:=1;
                                                        while not(eof(tt)) and (x3<=syst.ndesclines) do begin
                                                                readln(tt,s3);
                                                                NXF.SetDescLine(copy(s3,1,45),x3);
                                                                inc(x3);
                                                        end;
                                                        close(tt);
                                                 end;
                                                 end;
                                                1:displaybox('Error extracting FILE_ID.DIZ ...',3000);
                                          end;
                                          cleanupdir;
                                          window(x1,y1,x2,y2);
                                          gotoxy(ox,oy);
                        end;
                    end;
                  end;
                  inc(x3);
                  loadfilebase(x3,1);
                  removewindow(savwin2);
          end;
          curread:=oldnum;
          curf:=oldf;
          if (fbdirdlpath in curf.fbstat) then begin
                  NXF.Init(adrv(curf.dlpath)+curf.filename+'.NFD', syst.nkeywords,syst.ndesclines);
          end else begin
                  NXF.Init(adrv(systat.filepath)+curf.filename+'.NFD', syst.nkeywords,syst.ndesclines);
          end;
          nofiles:=FALSE;
          total:=NXF.Numfiles;
          if (total=0) then nofiles:=TRUE;
          if (current>total) then current:=total;
          end;
   end;
end;

        procedure getglobalareas(g:globalpass);
        var cho:array[1..4] of string;
            w3,w4:windowrec;
            ch3:char;
            cur:integer;
            d3:boolean;
            spec:string;
        begin
        spec:='*.*';
        setwindow(w3,20,9,60,16,3,0,8,'Global Changes',TRUE);
        cho[1]:='Files to update: '+mln(spec,18);
        cho[2]:='Update this file only               ';
        cho[3]:='Update all files in this file base  ';
        cho[4]:='Update all files in all file bases  ';
        for cur:=1 to 4 do begin
                textcolor(7);
                textbackground(0);
                gotoxy(2,cur+1);
                write(cho[cur]);
        end;
        cur:=1;
        d3:=FALSE;
        repeat
        gotoxy(2,cur+1);
        textcolor(15);
        textbackground(1);
        write(cho[cur]);
        while not(keypressed) do begin end;
        ch3:=readkey;
        case ch3 of
                #0:begin
                        ch3:=readkey;
                        checkkey(ch3);
                        case ch3 of
                                #72:begin
                                        gotoxy(2,cur+1);
                                        textcolor(7);
                                        textbackground(0);
                                        write(cho[cur]);
                                        dec(cur);
                                        if (cur=0) then cur:=4;
                                    end;
                                #80:begin
                                        gotoxy(2,cur+1);
                                        textcolor(7);
                                        textbackground(0);
                                        write(cho[cur]);
                                        inc(cur);
                                        if (cur=5) then cur:=1;
                                    end;
                        end;
                   end;
                #13:begin
                        if (cur=1) then begin
                                        gotoxy(2,cur+1);
                                        textcolor(7);
                                        textbackground(0);
                                        write(cho[cur]);
                        setwindow4(w3,20,9,60,16,8,0,8,'Global Changes','',TRUE);
                          setwindow(w4,23,12,58,14,3,0,8,'',TRUE);
  gotoxy(2,1);
  textcolor(7);
  textbackground(0);
  write('Files to update : ');
  gotoxy(20,1);
  infield_inp_fgrd:=15;
  infield_inp_bkgd:=1;
  infield_out_fgrd:=3;
  infield_out_bkgd:=0;
  infield_allcaps:=TRUE;
  infield_numbers_only:=FALSE;
  infield_escape_zero:=FALSE;
  infield_escape_blank:=TRUE;
  infield_putatend:=TRUE;
  infield_insert:=TRUE;
  infield_clear:=TRUE;
  s:=spec;
  infielde(s,12);
  infield_escape_blank:=FALSE;
  infield_putatend:=FALSE;
  infield_insert:=TRUE;
  removewindow(w4);
  if (s<>'') and (s<>spec) then begin
        spec:=s;
        cho[1]:='Files to update: '+mln(spec,18);
  end;
                        setwindow5(w3,20,9,60,16,3,0,8,'Global Changes','',TRUE);
                        window(21,10,59,15);
                        end else begin
                        removewindow(w3);
                        textcolor(7);
                        textbackground(0);
                        global(cur-1,spec,g);
                        d3:=TRUE;
                        end;
                    end;
                #27:begin
                        d3:=TRUE;
                        removewindow(w3);
                    end;
        end;
        until (d3);
        end;

        procedure getglobal;
        var cho:array[1..9] of string[24];
            cur:byte;
            w3:windowrec;
            c:char;
            g:globalpass;
            fhid,funv,foff,fres,ffre,fsec,fhat,info,desc:byte;
            done,chg,process:boolean;

            function disp(b:byte):string;
            begin
                case b of
                        0:disp:='      ';
                        1:disp:='Update';
                end;
            end;

            function disp2(b:byte):string;
            begin
                case b of
                        0:disp2:='   ';
                        1:disp2:='On';
                        2:disp2:='Off';
                end;
            end;


        begin
        funv:=0;
        foff:=0;
        fres:=0;
        ffre:=0;
        fsec:=0;
        fhat:=0;
        info:=0;
        desc:=0;
        fhid:=0;
        process:=FALSE;
        chg:=FALSE;
        done:=FALSE;
        cho[1]:='Update Description    :';
        cho[2]:='File information      :';
        cho[3]:='Flags - Unvalidated   :';
        cho[4]:='        Offline       :';
        cho[5]:='        Resume        :';
        cho[6]:='        Free          :';
        cho[7]:='        Check Security:';
        cho[8]:='        Hatched       :';
        cho[9]:='        Hidden        :';
        setwindow(w3,24,9,57,21,3,0,8,'Global Changes',TRUE);
        textcolor(7);
        textbackground(0);
        for cur:=1 to 9 do begin
                gotoxy(2,cur+1);
                write(cho[cur]);
        end;
        textcolor(3);
        textbackground(0);
        gotoxy(26,2);
        write(disp(desc));
        gotoxy(26,3);
        write(disp(info));
        gotoxy(26,4);
        write(disp2(funv));
        gotoxy(26,5);
        write(disp2(foff));
        gotoxy(26,6);
        write(disp2(fres));
        gotoxy(26,7);
        write(disp2(ffre));
        gotoxy(26,8);
        write(disp2(fsec));
        gotoxy(26,9);
        write(disp2(fhat));
        gotoxy(26,10);
        write(disp2(fhid));
        cur:=1;
        repeat
        gotoxy(2,cur+1);
        textcolor(15);
        textbackground(1);
        write(cho[cur]);
        while not(keypressed) do begin end;
        c:=readkey;
        case c of
                #0:begin
                        c:=readkey;
                        case c of
                                #68:begin
        g[1]:=desc;
        g[2]:=info;
        g[3]:=funv;
        g[4]:=foff;
        g[5]:=fres;
        g[6]:=ffre;
        g[7]:=fsec;
        g[8]:=fhat;
        g[9]:=fhid;
        chg:=FALSE;
        for cur:=1 to 9 do begin
                if (g[cur]<>0) then chg:=TRUE;
        end;
                                        if (chg) then process:=TRUE else process:=FALSE;
                                    end;
                                #72:begin
                                        gotoxy(2,cur+1);
                                        textcolor(7);
                                        textbackground(0);
                                        write(cho[cur]);
                                        dec(cur);
                                        if (cur=0) then cur:=9;
                                    end;
                                #80:begin
                                        gotoxy(2,cur+1);
                                        textcolor(7);
                                        textbackground(0);
                                        write(cho[cur]);
                                        inc(cur);
                                        if (cur=10) then cur:=1;
                                    end;
                        end;
                   end;
               #13:begin
                        gotoxy(2,cur+1);
                        textcolor(7);
                        textbackground(0);
                        write(cho[cur]);
                        case cur of
                                1:begin
                                        if (desc=0) then desc:=1 else desc:=0;
                                        textcolor(3);
                                        textbackground(0);
                                        gotoxy(26,2);
                                        write(disp(desc));
                                        chg:=TRUE;
                                  end;
                                2:begin
                                        if (info=0) then info:=1 else info:=0;
                                        textcolor(3);
                                        textbackground(0);
                                        gotoxy(26,3);
                                        write(disp(info));
                                        chg:=TRUE;
                                  end;
                                3:begin
                                        inc(funv);
                                        if (funv=3) then funv:=0;
                                        textcolor(3);
                                        textbackground(0);
                                        gotoxy(26,4);
                                        write(disp2(funv));
                                        chg:=TRUE;
                                  end;
                                4:begin
                                        inc(foff);
                                        if (foff=3) then foff:=0;
                                        textcolor(3);
                                        textbackground(0);
                                        gotoxy(26,5);
                                        write(disp2(foff));
                                        chg:=TRUE;
                                  end;
                                5:begin
                                        inc(fres);
                                        if (fres=3) then fres:=0;
                                        textcolor(3);
                                        textbackground(0);
                                        gotoxy(26,6);
                                        write(disp2(fres));
                                        chg:=TRUE;
                                  end;
                                6:begin
                                        inc(ffre);
                                        if (ffre=3) then ffre:=0;
                                        textcolor(3);
                                        textbackground(0);
                                        gotoxy(26,7);
                                        write(disp2(ffre));
                                        chg:=TRUE;
                                  end;
                                7:begin
                                        inc(fsec);
                                        if (fsec=3) then fsec:=0;
                                        textcolor(3);
                                        textbackground(0);
                                        gotoxy(26,8);
                                        write(disp2(fsec));
                                        chg:=TRUE;
                                  end;
                                8:begin
                                        inc(fhat);
                                        if (fhat=3) then fhat:=0;
                                        textcolor(3);
                                        textbackground(0);
                                        gotoxy(26,9);
                                        write(disp2(fhat));
                                        chg:=TRUE;
                                  end;
                                9:begin
                                        inc(fhid);
                                        if (fhid=3) then fhid:=0;
                                        textcolor(3);
                                        textbackground(0);
                                        gotoxy(26,10);
                                        write(disp2(fhid));
                                        chg:=TRUE;
                                  end;
                        end;
                   end;
               #27:begin
                        if (chg) then begin
        g[1]:=desc;
        g[2]:=info;
        g[3]:=funv;
        g[4]:=foff;
        g[5]:=fres;
        g[6]:=ffre;
        g[7]:=fsec;
        g[8]:=fhat;
        g[9]:=fhid;
        chg:=FALSE;
        for cur:=1 to 9 do begin
                if (g[cur]<>0) then chg:=TRUE;
        end;
                                if (chg) then begin
                                if (pynqbox('Process changes? ')) then process:=TRUE
                                else done:=TRUE;
                                end else done:=TRUE;
                        end else begin
                                done:=TRUE;
                        end;
                   end;
        end;
        until (done) or (process);
        removewindow(w3);
        if (process) then begin
                getglobalareas(g);
        end;
        end;
        
procedure cvtfiles(tp:byte;spec:string);
var savwin:windowrec;
    x,x3,ox,oy,x1,y1,x2,y2:integer;
    result:integer;
    fconv,oused,nused,saved,tl:longint;
    tmpf:file;
    fpacked:longint;
    dt:datetime;
    oldnum:integer;
    oldf:ulrec;

procedure showsavings;
var w10:windowrec;
    c:char;
begin
        window(1,1,80,25);
        textcolor(14);
        textbackground(0);
        gotoxy(1,25);
        clreol;
        write('Press any key to continue...');
        setwindow(w10,20,10,60,17,3,0,8,'Conversion Results',TRUE);
        gotoxy(2,2);
        cwrite('%070%Files processed: %030%'+cstr(fconv));
        gotoxy(2,3);
        cwrite('%070%Original Size  : %030%'+cstr(oused)+' ('+showblocks(oused div 1024)+')');
        gotoxy(2,4);
        cwrite('%070%New Size       : %030%'+cstr(nused)+' ('+showblocks(nused div 1024)+')');
        gotoxy(2,5);
        if (saved<0) then begin
        saved:=abs(saved);
        cwrite('%070%Loss of Space  : %030%'+cstr(saved)+' ('+showblocks(saved div 1024)+')');
        end else begin
        cwrite('%070%Space Savings  : %030%'+cstr(saved)+' ('+showblocks(saved div 1024)+')');
        end;
        while not(keypressed) do begin end;
        while (keypressed) do begin
        c:=readkey;
        end;
        removewindow(w10);
        window(1,1,80,25);
        textcolor(14);
        textbackground(0);
        gotoxy(1,25);
        clreol;
end;

        function getarctype(i:integer):string;
        var af:file of archiverrec;
            a:archiverrec;
        begin
        assign(af,adrv(systat.gfilepath)+'ARCHIVER.DAT');
        {$I-} reset(af); {$I+}
        if (ioresult<>0) then begin
                getarctype:='Error';
                exit;
        end;
        if (i>filesize(af)-1) then begin
                getarctype:='Error';
                close(af);
                exit;
        end;
        seek(af,i);
        read(af,a);
        if (a.active) then getarctype:=a.name;
        close(af);
        end;

        function isarcokay(i:integer):boolean;
        var af:file of archiverrec;
            a:archiverrec;
        begin
        assign(af,adrv(systat.gfilepath)+'ARCHIVER.DAT');
        {$I-} reset(af); {$I+}
        if (ioresult<>0) then begin
                isarcokay:=FALSE;
                exit;
        end;
        if (i>filesize(af)-1) then begin
                isarcokay:=FALSE;
                close(af);
                exit;
        end;
        seek(af,i);
        read(af,a);
        close(af);
        if (a.active) and (a.compress<>'') then isarcokay:=TRUE else
        isarcokay:=FALSE;
        end;

  function convertfile(filen:string;cnum:integer):integer;
  var ecode:integer;
  begin
  textcolor(7);
  textbackground(0);
  {$I-} mkdir('.\~FBMTMP'); {$I+}
  if (ioresult<>0) then exit;
  arcbatch(ecode,'.\~FBMTMP',adrv(systat.utilpath)+'NXAPS.EXE 4 x '+adrv(curf.dlpath)+filen+' '+cstr(cnum));
  {$I-} rmdir('.\~FBMTMP'); {$I+}
  if (ioresult<>0) then exit;
  convertfile:=ecode;
  end;

  procedure savecursettings;
  begin
  savescreen(savwin,1,1,80,25);
  ox:=wherex;
  oy:=wherey;
  x1:=Lo(windmin)+1;
  y1:=Hi(windmin)+1;
  x2:=lo(windmax)+1;
  y2:=hi(windmax)+1;
  window(1,1,80,25);
  end;

  procedure restorecursettings;
  begin
     removewindow(savwin);
     window(x1,y1,x2,y2);
     gotoxy(ox,oy);
  end;

function getarcext(b:byte):string;
var af:file of archiverrec;
    a:archiverrec;
begin
  assign(af,adrv(systat.gfilepath)+'ARCHIVER.DAT');
  {$I-} reset(af); {$I+}
  if (ioresult<>0) then begin
  getarcext:='';
  exit;
  end;
  if (b>filesize(af)) then begin
        getarcext:='';
        close(af);
  exit;
  end;
  seek(af,b);
  read(af,a);
  getarcext:=a.extension;
  close(af);
end;

procedure fixspec;
var i:integer;
    fn,fn2,fn3:string;
begin
  fn:=spec;
  if (pos('.',fn)=0) then fn:=fn+'.';
  if (pos('*',fn)<>0) then begin
      fn2:=align(fn);
      fn3:=copy(fn2,10,3);
      fn2:=copy(fn2,1,8);
      if (pos('*',fn2)<>0) then begin
          while (pos(' ',fn2)<>0) do begin
                fn2[pos(' ',fn2)]:='?';
          end;
          fn2[pos('*',fn2)]:='?';
      end;
      if (pos('*',fn3)<>0) then begin
          while (pos(' ',fn3)<>0) do begin
                fn3[pos(' ',fn3)]:='?';
          end;
          fn3[pos('*',fn3)]:='?';
      end;
      fn2:=sqoutsp(fn2);
      fn3:=sqoutsp(fn3);
      fn:=fn2+'.'+fn3;
  end;
  spec:=fn;
end;

function align(fn:string):string;
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

begin
oused:=0;
nused:=0;
saved:=0;
fconv:=0;
oldf:=curf;
oldnum:=curread;
fixspec;
case tp of
        1:if not(curf.cdrom) then begin
                if (curf.arctype<>0) then begin
                        if (isarcokay(curf.arctype)) then begin
                                  NXF.Seekfile(current);
                                  NXF.Readheader;
                                  if (fit(align(spec),align(nxf.fheader.filename))) then begin
                                          savecursettings;
                                          clrscr;
                                          window(1,1,80,24);
                                          textcolor(15);
                                          textbackground(1);
                                          gotoxy(1,1);
                                          clreol;
                                          gotoxy(1,2);
                                          clreol;
                                          gotoxy(1,3);
                                          clreol;
                                          gotoxy(1,1);
                                          writeln('Converting: '+adrv(curf.dlpath)+NXF.Fheader.filename+' ('+
                                                  getarctype(curf.arctype)+')');
                                          window(1,4,80,24);
                                          result:=convertfile(NXF.Fheader.filename,curf.arctype);
                                          restorecursettings;
                                          case result of
                                                0:begin
                                                        inc(fconv);
                                                        oused:=oused+NXF.Fheader.Filesize;
                                                        NXF.Fheader.Filename:=copy(NXF.Fheader.Filename,1,
                                                                pos('.',NXF.Fheader.Filename)-1)+'.'+getarcext(curf.arctype);
                                                        assign(tmpf,adrv(curf.dlpath)+NXF.Fheader.Filename);
                                                        {$I-} reset(tmpf,1); {$I+}
                                                        if (ioresult<>0) then begin
                                                                NXF.Fheader.Filesize:=0;
                                                                NXF.Fheader.FileFlags:=NXF.Fheader.FileFlags+[ffisrequest];
                                                        end else begin
                                                                saved:=saved+(NXF.Fheader.Filesize-filesize(tmpf));
                                                                NXF.Fheader.Filesize:=filesize(tmpf);
                                                                nused:=nused+filesize(tmpf);
                                                                GetFTime(tmpf,fpacked);
                                                                UnpackTime(fpacked,dt);
                                                                NXF.Fheader.FileDate:=DTToUnixDate(dt);
                                                                close(tmpf);
                                                        end;
                                                        NXF.Rewriteheader(NXF.Fheader);
                                                  end;
                                                1:displaybox('Error converting file.',3000);
                                                3:begin
                                                  displaybox('No conversion necessary.',3000);
                                                  end;
                                                4:displaybox('This file is AV protected.',3000);
                                          end;
                                          window(x1,y1,x2,y2);
                                          gotoxy(ox,oy);
                                  end;
                        end else begin
                                displaybox('Cannot convert to '+getarctype(curf.arctype),3000);
                        end;
                end else begin
                        displaybox('This filebase is not set to convert files.',3000);
                end;
          end else begin
                displaybox('This base is on CD-ROM.',3000);
          end;
        2:if not(curf.cdrom) then begin         { All files this base }
                if (curf.arctype<>0) then begin
                        if (isarcokay(curf.arctype)) then begin
                                  savecursettings;
                                  clrscr;
                                  window(1,1,80,24);
                                  for x:=1 to NXF.Numfiles do begin
                                          NXF.Seekfile(x);
                                          NXF.Readheader;
                                          if (fit(align(spec),align(nxf.fheader.filename))) then begin
                                                  window(1,1,80,24);
                                                  textcolor(15);
                                                  textbackground(1);
                                                  gotoxy(1,1);
                                                  clreol;
                                                  gotoxy(1,2);
                                                  clreol;
                                                  gotoxy(1,3);
                                                  clreol;
                                                  gotoxy(1,1);
                                                  writeln('Converting: '+adrv(curf.dlpath)+NXF.Fheader.filename+' ('+
                                                        getarctype(curf.arctype)+')');
                                                  window(1,4,80,24);
                                                  textcolor(7);
                                                  textbackground(0);
                                                  clrscr;
                                                  result:=convertfile(NXF.Fheader.filename,curf.arctype);
                                                  case result of
                                                        0:begin
                                                                inc(fconv);
                                                                oused:=oused+NXF.Fheader.Filesize;
                                                                NXF.Fheader.Filename:=copy(NXF.Fheader.Filename,1,
                                                                        pos('.',NXF.Fheader.Filename)-1)+'.'+
                                                                        getarcext(curf.arctype);
                                                                assign(tmpf,adrv(curf.dlpath)+NXF.Fheader.Filename);
                                                                {$I-} reset(tmpf,1); {$I+}
                                                                if (ioresult<>0) then begin
                                                                        NXF.Fheader.Filesize:=0;
                                                                        NXF.Fheader.FileFlags:=NXF.Fheader.FileFlags+
                                                                                [ffisrequest];
                                                                end else begin
                                                                        saved:=saved+(NXF.Fheader.Filesize-filesize(tmpf));
                                                                        NXF.Fheader.Filesize:=filesize(tmpf);
                                                                        nused:=nused+filesize(tmpf);
                                                                        GetFTime(tmpf,fpacked);
                                                                        UnpackTime(fpacked,dt);
                                                                        NXF.Fheader.FileDate:=DTToUnixDate(dt);
                                                                        close(tmpf);
                                                                end;
                                                                NXF.Rewriteheader(NXF.Fheader);
                                                          end;
                                                        1:begin
                                                                window(1,1,80,24);
                                                                textcolor(15);
                                                                textbackground(1);
                                                                gotoxy(1,3);
                                                                clreol;
                                                                writeln('Error converting file...');
                                                                delay(500);
                                                                textcolor(7);
                                                                textbackground(0);
                                                          end;
                                                        3:begin
                                                                window(1,1,80,24);
                                                                textcolor(15);
                                                                textbackground(1);
                                                                gotoxy(1,3);
                                                                clreol;
                                                                writeln('No conversion necessary...');
                                                                delay(500);
                                                                textcolor(7);
                                                                textbackground(0);
                                                          end;
                                                        4:begin
                                                                window(1,1,80,24);
                                                                textcolor(15);
                                                                textbackground(1);
                                                                gotoxy(1,3);
                                                                clreol;
                                                                writeln('This file is AV protected...');
                                                                delay(00);
                                                                textcolor(7);
                                                                textbackground(0);
                                                          end;
                                                  end;
                                          end;
                                  end;
                                  restorecursettings;
                                  window(x1,y1,x2,y2);
                                  gotoxy(ox,oy);
                        end else begin
                                  displaybox('Cannot convert to '+getarctype(curf.arctype),3000);
                        end;
                end else begin
                        displaybox('This filebase is not set to convert files.',3000);
                end;
          end else begin
                displaybox('This base is on CD-ROM.',3000);
          end;
        3:begin         { All files all bases - NO CD ROMS! }
          x3:=0;
          loadfilebase(x3,1);
          savecursettings;
          clrscr;
          window(1,1,80,24);
          while (x3<>-1) do begin
                  if not(curf.cdrom) then begin
                          if (curf.arctype<>0) then begin
                                  if (isarcokay(curf.arctype)) then begin
                                          for x:=1 to NXF.Numfiles do begin
                                                  NXF.Seekfile(x);
                                                  NXF.Readheader;
                                                  if (fit(align(spec),align(nxf.fheader.filename))) then begin
                                                          window(1,1,80,24);
                                                          textcolor(15);
                                                          textbackground(1);
                                                          gotoxy(1,1);
                                                          clreol;
                                                          hback:=1;
                                                          gotoxy(1,2);
                                                          clreol;
                                                          gotoxy(1,3);
                                                          clreol;
                                                          gotoxy(1,1);
                                                          cwrite('File base : '+curf.name+#13+#10);
                                                          hback:=255;
                                                          clreol;
                                                          writeln('Converting: '+adrv(curf.dlpath)+NXF.Fheader.filename+' ('+
                                                                getarctype(curf.arctype)+')');
                                                          textcolor(7);
                                                          textbackground(0);
                                                          window(1,4,80,24);
                                                          clrscr;
                                                          result:=convertfile(NXF.Fheader.filename,curf.arctype);
                                                          case result of
                                                                0:begin
                                                                        inc(fconv);
                                                                        oused:=oused+NXF.Fheader.Filesize;
                                                                        NXF.Fheader.Filename:=copy(NXF.Fheader.Filename,1,
                                                                                pos('.',NXF.Fheader.Filename)-1)+'.'+
                                                                                getarcext(curf.arctype);
                                                                        assign(tmpf,adrv(curf.dlpath)+NXF.Fheader.Filename);
                                                                        {$I-} reset(tmpf,1); {$I+}
                                                                        if (ioresult<>0) then begin
                                                                                NXF.Fheader.Filesize:=0;
                                                                                NXF.Fheader.FileFlags:=NXF.Fheader.FileFlags+
                                                                                        [ffisrequest];
                                                                        end else begin
                                                                                saved:=saved+(NXF.Fheader.Filesize-
                                                                                        filesize(tmpf));
                                                                                NXF.Fheader.Filesize:=filesize(tmpf);
                                                                                nused:=nused+filesize(tmpf);
                                                                                GetFTime(tmpf,fpacked);
                                                                                UnpackTime(fpacked,dt);
                                                                                NXF.Fheader.FileDate:=DTToUnixDate(dt);
                                                                                close(tmpf);
                                                                        end;
                                                                        NXF.Rewriteheader(NXF.Fheader);
                                                                  end;
                                                                1:begin
                                                                        window(1,1,80,24);
                                                                        textcolor(15);
                                                                        textbackground(1);
                                                                        gotoxy(1,3);
                                                                        clreol;
                                                                        writeln('Error converting file...');
                                                                        delay(500);
                                                                        textcolor(7);
                                                                        textbackground(0);
                                                                  end;
                                                                3:begin
                                                                        window(1,1,80,24);
                                                                        textcolor(15);
                                                                        textbackground(1);
                                                                        gotoxy(1,3);
                                                                        clreol;
                                                                        writeln('No conversion necessary...');
                                                                        delay(500);
                                                                        textcolor(7);
                                                                        textbackground(0);
                                                                  end;
                                                                4:begin
                                                                        window(1,1,80,24);
                                                                        textcolor(15);
                                                                        textbackground(1);
                                                                        gotoxy(1,3);
                                                                        clreol;
                                                                        writeln('This file is AV protected...');
                                                                        delay(500);
                                                                        textcolor(7);
                                                                        textbackground(0);
                                                                  end;
                                                          end;
                                                  end;
                                          end;
                                  end;
                          end;
                  end;
                  inc(x3);
                  loadfilebase(x3,1);
          end;
          curread:=oldnum;
          curf:=oldf;
          if (fbdirdlpath in curf.fbstat) then begin
                  NXF.Init(adrv(curf.dlpath)+curf.filename+'.NFD', syst.nkeywords,syst.ndesclines);
          end else begin
                  NXF.Init(adrv(systat.filepath)+curf.filename+'.NFD', syst.nkeywords,syst.ndesclines);
          end;
          nofiles:=FALSE;
          total:=NXF.Numfiles;
          if (total=0) then nofiles:=TRUE;
          if (current>total) then current:=total;
          restorecursettings;
          window(x1,y1,x2,y2);
          gotoxy(ox,oy);
          end;
   end;
   showsavings;
end;

        procedure getconverttype;
        var cho:array[1..4] of string;
            w3,w4:windowrec;
            ch3:char;
            cur:integer;
            d3:boolean;
            spec:string;
        begin
        spec:='*.*';
        setwindow(w3,20,9,60,16,3,0,8,'Conversion Method',TRUE);
        cho[1]:='Files to convert: '+mln(spec,17);
        cho[2]:='Convert this file only              ';
        cho[3]:='Convert all files in this file base ';
        cho[4]:='Convert all files in all file bases ';
        for cur:=1 to 4 do begin
                textcolor(7);
                textbackground(0);
                gotoxy(2,cur+1);
                write(cho[cur]);
        end;
        cur:=1;
        d3:=FALSE;
        repeat
        gotoxy(2,cur+1);
        textcolor(15);
        textbackground(1);
        write(cho[cur]);
        while not(keypressed) do begin end;
        ch3:=readkey;
        case ch3 of
                #0:begin
                        ch3:=readkey;
                        checkkey(ch3);
                        case ch3 of
                                #72:begin
                                        gotoxy(2,cur+1);
                                        textcolor(7);
                                        textbackground(0);
                                        write(cho[cur]);
                                        dec(cur);
                                        if (cur=0) then cur:=4;
                                    end;
                                #80:begin
                                        gotoxy(2,cur+1);
                                        textcolor(7);
                                        textbackground(0);
                                        write(cho[cur]);
                                        inc(cur);
                                        if (cur=5) then cur:=1;
                                    end;
                        end;
                   end;
                #13:begin
                        if (cur=1) then begin
                                        gotoxy(2,cur+1);
                                        textcolor(7);
                                        textbackground(0);
                                        write(cho[cur]);
                        setwindow4(w3,20,9,60,16,8,0,8,'Conversion Method','',TRUE);
                          setwindow(w4,23,12,58,14,3,0,8,'',TRUE);
  gotoxy(2,1);
  textcolor(7);
  textbackground(0);
  write('Files to convert: ');
  gotoxy(20,1);
  infield_inp_fgrd:=15;
  infield_inp_bkgd:=1;
  infield_out_fgrd:=3;
  infield_out_bkgd:=0;
  infield_allcaps:=TRUE;
  infield_numbers_only:=FALSE;
  infield_escape_zero:=FALSE;
  infield_escape_blank:=TRUE;
  infield_putatend:=TRUE;
  infield_insert:=TRUE;
  infield_clear:=TRUE;
  s:=spec;
  infielde(s,12);
  infield_escape_blank:=FALSE;
  infield_putatend:=FALSE;
  infield_insert:=TRUE;
  removewindow(w4);
  if (s<>'') and (s<>spec) then begin
        spec:=s;
        cho[1]:='Files to convert: '+mln(spec,17);
  end;
                        setwindow5(w3,20,9,60,16,3,0,8,'Conversion Method','',TRUE);
                        window(21,10,59,15);
                        end else begin
                        removewindow(w3);
                        textcolor(7);
                        textbackground(0);
                        cvtfiles(cur-1,spec);
                        d3:=TRUE;
                        end;
                    end;
                #27:begin
                        d3:=TRUE;
                        removewindow(w3);
                    end;
        end;
        until (d3);
        end;

procedure addfiles(okglobal:boolean);
var w3:windowrec;
    scantype:byte;
    oldf:ulrec;
    oldnum,tempx:integer;
    cdroms:boolean;

        procedure getscantype;
        var cho:array[1..6] of string;
            x3:integer;
            ch3:char;
            cur:integer;
            d3:boolean;
        begin
        setwindow(w3,16,7,64,16,3,0,8,'Add Files Method',TRUE);
        cho[1]:='Always use FILE_ID.DIZ; Skip files without  ';
        cho[2]:='Always use FILE_ID.DIZ; <No Desc> without   ';
        cho[3]:='Always use FILE_ID.DIZ; Move files without  ';
        cho[4]:='Always use FILE_ID.DIZ; Prompt files without';
        cho[5]:='Always prompt for description               ';
        cho[6]:='Single specific file only                   ';
        for x3:=1 to 6 do begin
                if (x3 in [3,6]) then textcolor(8) else textcolor(7);
                textbackground(0);
                gotoxy(2,x3+1);
                write(cho[x3]);
        end;
        cur:=1;
        d3:=FALSE;
        scantype:=0;
        repeat
        gotoxy(2,cur+1);
        textcolor(15);
        textbackground(1);
        write(cho[cur]);
        while not(keypressed) do begin end;
        ch3:=readkey;
        case ch3 of
                #0:begin
                        ch3:=readkey;
                        checkkey(ch3);
                        case ch3 of
                                #72:begin
                                        gotoxy(2,cur+1);
                                        if (cur in [3,6]) then begin
                                        textcolor(8);
                                        end else begin
                                        textcolor(7);
                                        end;
                                        textbackground(0);
                                        write(cho[cur]);
                                        dec(cur);
                                        if (cur=0) then cur:=6;
                                    end;
                                #80:begin
                                        gotoxy(2,cur+1);
                                        if (cur in [3,6]) then begin
                                        textcolor(8);
                                        end else begin
                                        textcolor(7);
                                        end;
                                        textbackground(0);
                                        write(cho[cur]);
                                        inc(cur);
                                        if (cur=7) then cur:=1;
                                    end;
                        end;
                   end;
                #13:begin
                        if not(cur in [3,6]) then begin
                        scantype:=cur;
                        d3:=TRUE;
                        end;
                    end;
                #27:d3:=TRUE;
        end;
        until (d3);
        removewindow(w3);
        end;

function alreadyexists(filen:string):boolean;
var found:boolean;
    nf:tindexrec;
begin
if (nofiles) then begin
        alreadyexists:=FALSE;
        exit;
end;
found:=FALSE;
seek(tff,0);
while not(eof(tff)) and not(found) do begin
read(tff,nf);
if allcaps(filen)=allcaps(nf.filename) then begin
        found:=TRUE;
end;
end;
alreadyexists:=found;
end;


function checkfileid(filen:string):boolean;
var ecode:integer;
begin
arcbatch(ecode,'.',adrv(systat.utilpath)+'NXAPS.EXE 4 f '+adrv(curf.dlpath)+filen);
if (ecode=0) then begin
arcbatch(ecode,'.',adrv(systat.utilpath)+'NXAPS.EXE 4 e '+adrv(curf.dlpath)+filen+' FILE_ID.DIZ');
if exist('FILE_ID.DIZ') then begin
        checkfileid:=TRUE;
end else checkfileid:=FALSE;
end else checkfileid:=FALSE;
end;

procedure importfileid;
var tf:text;
    s2:string;
    x3:integer;
begin
assign(tf,'FILE_ID.DIZ');
{$I-} reset(tf); {$I+}
if (ioresult<>0) then begin
        NXF.AddDescLine('<No description provided>');
        exit;
end;
x3:=1;
while not(eof(tf)) and (x3<syst.ndesclines+1) do begin
        readln(tf,s2);
        NXF.Adddescline(copy(s2,1,45));
        inc(x3);
end;
close(tf);
end;

procedure importfileid2;
var tf:text;
    s2:string;
    x3:integer;
begin
assign(tf,adrv(systat.temppath)+'FILETMP');
{$I-} reset(tf); {$I+}
if (ioresult<>0) then begin
        NXF.AddDescLine('<No description provided>');
        exit;
end;
x3:=1;
while not(eof(tf)) and (x3<syst.ndesclines+1) do begin
        readln(tf,s2);
        NXF.Adddescline(copy(s2,1,45));
        inc(x3);
end;
close(tf);
{$I-} erase(tf); {$I+}
if (ioresult<>0) then begin end;
end;

Procedure NewRecord(fh:fheaderrec);
begin
fh.FheaderID[1]:=#1;
fh.FheaderID[2]:='N';
fh.FheaderID[3]:='E';
fh.FheaderID[4]:='X';
fh.FheaderID[5]:='U';
fh.FheaderID[6]:='S';
fh.FheaderID[7]:=#1;
fh.MagicName:='';
fh.NumDownloads:=0;
fh.Access:='';
fh.AccessKey:='';
fillchar(fh.reserved,sizeof(fh.reserved),#0);
NXF.AddNewFile(fh);
end;


function manualdesc(isfile:boolean;fn:string):byte;
var tf:text;
    w8,w9:windowrec;
    ch8:char;
    cho8:array[1..3] of string[30];
    cur8:integer;
    d8:boolean;
    blankdiz:boolean;

        procedure showdiz(tt:byte);
        var x8:integer;
            s3:string;
            ff:text;
        begin
                case tt of
                        0:assign(ff,adrv(systat.temppath)+'FILETMP');
                        1:assign(ff,'FILE_ID.DIZ');
                end;
                {$I-} reset(ff); {$I+}
                if (ioresult=0) then begin
                        x8:=1;
                        while not(eof(ff)) and (x8<=5) do begin
                                gotoxy(2,x8+1);
                                inc(x8);
                                readln(ff,s3);
                                write(s3);
                        end;
                        close(ff);
                end;
        end;

begin
cho8[1]:='Skip File         ';
cho8[2]:='Delete File       ';
cho8[3]:='Edit Description  ';
setwindow(w8,56,6,78,12,3,0,8,'Import File',TRUE);
setwindow(w9,2,6,50,14,3,0,8,'Current Description for '+fn,TRUE);
if (isfile) then begin
blankdiz:=FALSE;
showdiz(1);
end else blankdiz:=TRUE;
window(57,7,78,11);
textcolor(7);
textbackground(0);
for cur8:=1 to 3 do begin
        gotoxy(2,cur8+1);
        write(cho8[cur8]);
end;
d8:=FALSE;
cur8:=1;
repeat
window(1,1,80,25);
gotoxy(1,25);
textcolor(14);
textbackground(0);
clreol;
write('Esc');
textcolor(7);
write('=Skip File ');
textcolor(14);
write('Enter');
textcolor(7);
write('=Select Option ');
textcolor(14);
write('F10');
textcolor(7);
write('=Save Description');
window(57,7,78,11);
gotoxy(2,cur8+1);
textcolor(15);
textbackground(1);
write(cho8[cur8]);
while not(keypressed) do begin end;
ch8:=readkey;
case ch8 of
        #0:begin
                ch8:=readkey;
                checkkey(ch8);
                case ch8 of
                        #68:begin
                                d8:=TRUE;
{                                if (blankdiz) then begin
                                f.description[1]:='<No description provided>';
                                end; }
                                manualdesc:=0;
                            end;
                        #72:begin
                                gotoxy(2,cur8+1);
                                textcolor(7);
                                textbackground(0);
                                write(cho8[cur8]);
                                dec(cur8);
                                if (cur8=0) then cur8:=3;
                            end;
                        #80:begin
                                gotoxy(2,cur8+1);
                                textcolor(7);
                                textbackground(0);
                                write(cho8[cur8]);
                                inc(cur8);
                                if (cur8>3) then cur8:=1;
                            end;
                end;
           end;
       #13:begin
                case cur8 of
                      1:begin
                                manualdesc:=1;
                                d8:=TRUE;
                          end;
                      2:begin
                                manualdesc:=3;
                                d8:=TRUE;
                          end;
                      3:begin
setwindow4(w8,56,6,78,12,8,0,8,'Import File','',TRUE);
setwindow4(w9,2,6,50,14,8,0,8,'Current Description for '+fn,'',TRUE);
                                if (getdescription) then begin
                                        if (blankdiz) then blankdiz:=FALSE;
                                end;
setwindow5(w8,56,6,78,12,3,0,8,'Import File','',TRUE);
setwindow5(w9,2,6,50,14,3,0,8,'Current Description for '+fn,'',TRUE);
                                window(3,7,49,13);
                                showdiz(0);
                                window(57,7,78,11);
                          end;
                end;
           end;
       #27:begin
                d8:=TRUE;
                manualdesc:=2;
           end;
end;
until (d8);
removewindow(w8);
removewindow(w9);
end;


function multifiles(tp:byte):boolean;
var sr:searchrec;
    aborted,ok:boolean;
    ok2:integer;
    f3:file;
    s3:string;
    fileidfound:boolean;
    cleared:boolean;
    fpacked:longint;
    dt:datetime;

        procedure getpoints;
        var rfpts:real;
        begin
                 rfpts:=(NXF.Fheader.filesize div 1024)/systat.fileptcompbasesize;
                 NXF.Fheader.filepoints:=round(rfpts);
                 if (NXF.Fheader.filepoints=0) then NXF.Fheader.filepoints:=1;
        end;

begin
cleared:=FALSE;
aborted:=FALSE;
if existdir(adrv(systat.temppath)+'~FBMGR') then begin
        {$I-} rmdir(adrv(systat.temppath)+'~FBMGR'); {$I+}
        if (ioresult<>0) then begin
                displaybox('Error removing existing temporary directory!',3000);
                exit;
        end;
end;
findfirst(adrv(curf.dlpath)+'*.*',anyfile,sr);
while (doserror=0) and not(aborted) do begin
if (sr.attr and directory<>directory) and (sr.attr and volumeid<>volumeid) then
        if not(alreadyexists(sr.name)) then begin
                if (showfilename) and not(cleared) then begin
                        gotoxy(25,22);
                        textcolor(3);
                        textbackground(0);
                        write(mln(allcaps(adrv(curf.dlpath)+sr.name),50));
                end;
                if (tp in [1,2,4,5]) then begin
                        {$I-} mkdir(adrv(systat.temppath)+'~FBMGR'); {$I+}
                        if (ioresult=0) then begin
                                chdir(adrv(systat.temppath)+'~FBMGR');
                                if not(cleared) then begin
                                        clearscreen;
                                        cleared:=TRUE;
                                end;
                                textcolor(15);
                                textbackground(1);
                                clreol;
                                hback:=1;
                                cwrite('File base : '+curf.name+#13+#10);
                                hback:=255;
                                textcolor(15);
                                textbackground(1);
                                clreol;
                                writeln('Filename  : '+allcaps(adrv(curf.dlpath)+sr.name));
                                textcolor(7);
                                textbackground(0);
                                if (checkfileid(sr.name)) then begin
                                        if (nofiles) then begin
                                                nofiles:=FALSE;
                                                current:=1;
                                        end;
                                        NXF.Fheader.filename:=allcaps(sr.name);
                                        NXF.Fheader.Fileflags:=[];
                                        assign(f3,adrv(curf.dlpath)+sr.name);
                                        {$I-} reset(f3,1); {$I+}
                                        if (ioresult<>0) then begin
                                                NXF.Fheader.Filesize:=0;
                                                NXF.Fheader.FileFlags:=NXF.Fheader.FileFlags+[ffisrequest];
                                        end else begin
                                                NXF.Fheader.Filesize:=filesize(f3);
                                                GetFTime(f3,fpacked);
                                                UnpackTime(fpacked,dt);
                                                NXF.Fheader.FileDate:=DTToUnixDate(dt);
                                                close(f3);
                                        end;
                                        getpoints;
                                        NXF.Fheader.UploadedBy:=systat.sysopname;
                                        NXF.Fheader.UploadedDate:=u_daynum(datelong+'  '+time);
                                        NXF.Fheader.LastDLDate:=NXF.Fheader.UploadedDate;
                                        NewRecord(NXF.Fheader);
                                        importfileid;
                                        total:=NXF.Numfiles;
                                end else begin
                                        if (tp=4) then begin
                                                if (nofiles) then begin
                                                        nofiles:=FALSE;
                                                        current:=1;
                                                end;
                                                NXF.Fheader.filename:=allcaps(sr.name);
                                                assign(f3,adrv(curf.dlpath)+sr.name);
                                                {$I-} reset(f3,1); {$I+}
                                                if (ioresult<>0) then begin
                                                        NXF.Fheader.Filesize:=0;
                                                        NXF.Fheader.FileFlags:=NXF.Fheader.FileFlags+[ffisrequest];
                                                end else begin
                                                        NXF.Fheader.Filesize:=filesize(f3);
                                                        GetFTime(f3,fpacked);
                                                        UnpackTime(fpacked,dt);
                                                        NXF.Fheader.FileDate:=DTToUnixDate(dt);
                                                        close(f3);
                                                end;
                                                getpoints;
                                                NXF.Fheader.UploadedBy:=systat.sysopname;
                                                NXF.Fheader.UploadedDate:=u_daynum(datelong+'  '+time);
                                                NXF.Fheader.LastDLDate:=NXF.Fheader.UploadedDate;
                                                NewRecord(NXF.Fheader);
                                                NXF.AddDescLine('<No description provided>');
                                                Total:=NXF.Numfiles;
                                        end else
                                        if (tp=2) then begin
                                                if (cleared) then begin
                                                        cleared:=FALSE;
                                                        restorescreen;
                                                end;
                                                ok2:=manualdesc(FALSE,allcaps(sr.name));
                                                if (ok2=0) then begin
                                                        if (nofiles) then begin
                                                                nofiles:=FALSE;
                                                                current:=1;
                                                        end;
                                                        NXF.Fheader.filename:=allcaps(sr.name);
                                                        assign(f3,adrv(curf.dlpath)+sr.name);
                                                        {$I-} reset(f3,1); {$I+}
                                                        if (ioresult<>0) then begin
                                                                NXF.Fheader.Filesize:=0;
                                                                NXF.Fheader.FileFlags:=NXF.Fheader.FileFlags+[ffisrequest];
                                                        end else begin
                                                                NXF.Fheader.Filesize:=filesize(f3);
                                                                GetFTime(f3,fpacked);
                                                                UnpackTime(fpacked,dt);
                                                                NXF.Fheader.FileDate:=DTToUnixDate(dt);
                                                                close(f3);
                                                        end;
                                                        getpoints;
                                                        NXF.Fheader.UploadedBy:=systat.sysopname;
                                                        NXF.Fheader.UploadedDate:=u_daynum(datelong+'  '+time);
                                                        NXF.Fheader.LastDLDate:=NXF.Fheader.UploadedDate;
                                                        NewRecord(NXF.Fheader);
                                                        importfileid2;
                                                        Total:=NXF.Numfiles;
                                                end;
                                                if (ok2=3) then begin
                                                        assign(f3,adrv(curf.dlpath)+sr.name);
                                                        {$I-} erase(f3); {$I+}
                                                        if (ioresult<>0) then begin
                                                                displaybox('Error deleting '+adrv(curf.dlpath)+sr.name,2000);
                                                        end;
                                                end;
                                                if (ok2=2) then aborted:=TRUE;
                                        end;
                                end;
                                purgedir(adrv(systat.temppath)+'~FBMGR');
                                rmdir(adrv(systat.temppath)+'~FBMGR');
                        end;
                end else begin
                        {$I-} mkdir(adrv(systat.temppath)+'~FBMGR'); {$I+}
                        if (ioresult=0) then begin
                                chdir(adrv(systat.temppath)+'~FBMGR');
                                fillchar(f,sizeof(f),#0);
                                if not(cleared) then begin
                                        clearscreen;
                                        cleared:=TRUE;
                                end;
                                fileidfound:=checkfileid(sr.name);
                                if (cleared) then begin
                                        restorescreen;
                                        cleared:=FALSE;
                                end;
                                if (showfilename) and not(cleared) then begin
                                        gotoxy(25,22);
                                        textcolor(3);
                                        textbackground(0);
                                        write(mln(allcaps(adrv(curf.dlpath)+sr.name),50));
                                end;
                                        NXF.Fheader.filename:=allcaps(sr.name);
                                if (fileidfound) then begin
                                        importfileid;
                                end; 
                                       if (fileidfound) then
                                        ok2:=manualdesc(TRUE,allcaps(sr.name))
                                        else
                                        ok2:=manualdesc(FALSE,allcaps(sr.name));
                                        if (ok2=0) then begin
                                        if (nofiles) then begin
                                                nofiles:=FALSE;
                                                current:=1;
                                        end;
                                        assign(f3,adrv(curf.dlpath)+sr.name);
                                        {$I-} reset(f3,1); {$I+}
                                        if (ioresult<>0) then begin
                                                NXF.Fheader.Filesize:=0;
                                                NXF.Fheader.FileFlags:=NXF.Fheader.FileFlags+[ffisrequest];
                                        end else begin
                                                NXF.Fheader.Filesize:=filesize(f3);
                                                GetFTime(f3,fpacked);
                                                UnpackTime(fpacked,dt);
                                                NXF.Fheader.FileDate:=DTToUnixDate(dt);
                                                close(f3);
                                        end;
                                        getpoints;
                                        NXF.Fheader.UploadedBy:=systat.sysopname;
                                        NXF.Fheader.UploadedDate:=u_daynum(datelong+'  '+time);
                                        NXF.Fheader.LastDLDate:=NXF.Fheader.UploadedDate;
                                        NewRecord(NXF.Fheader);
                                        importfileid2;
                                        total:=NXF.Numfiles;
                                        end;
                                        if (ok2=3) then begin
                                        assign(f3,adrv(curf.dlpath)+sr.name);
                                        {$I-} erase(f3); {$I+}
                                        if (ioresult<>0) then begin
                                                displaybox('Error deleting '+adrv(curf.dlpath)+sr.name,2000);
                                        end;
                                        end;
                                        if (ok2=2) then aborted:=TRUE;
                                purgedir(adrv(systat.temppath)+'~FBMGR');
                                rmdir(adrv(systat.temppath)+'~FBMGR');
                                  end;
                end;
        end else if (cleared) then begin
                cleared:=FALSE;
                restorescreen;
        end;
        findnext(sr);
end;
if (cleared) then begin
        cleared:=FALSE;
        restorescreen;
end;
multifiles:=aborted;
end;

procedure singlefile;
begin
end;

var tempw:windowrec;

begin
if (okglobal) then begin
        okglobal:=pynqbox('Search all filebases? ');
end;
if (okglobal) then begin
        cdroms:=pynqbox('Search CD-ROM filebases? ');
        okglobal:=FALSE;
        getscantype;
        oldf:=curf;
        oldnum:=curread;
        tempx:=0;
        setwindow(tempw,2,20,77,23,3,0,8,'',TRUE);
        gotoxy(2,1);
        textcolor(15);
        textbackground(0);
        write('Processing filebase:');
        gotoxy(2,2);
        write('Uploading file     :');
        window(1,1,80,25);
        loadfilebase(tempx,1);
        while (tempx<>-1) and not(okglobal) do begin
                gotoxy(25,21);
                cwrite(mln(curf.name,50));
                if (fbdirdlpath in curf.fbstat) then begin
                        NXF.Init(adrv(curf.dlpath)+curf.filename+'.NFD', syst.nkeywords,syst.ndesclines);
                end else begin
                        NXF.Init(adrv(systat.filepath)+curf.filename+'.NFD', syst.nkeywords,syst.ndesclines);
                end;
                nofiles:=FALSE;
                total:=NXF.Numfiles;
                if (total=0) then nofiles:=TRUE;
                if (current>total) then current:=total;
                showfilename:=TRUE;
                case scantype of
                        1:begin
                                okglobal:=multifiles(1);
                          end;
                        2:begin
                                okglobal:=multifiles(4);
                          end;
                        3:begin
                                okglobal:=multifiles(5);
                          end;
                        4:begin
                                okglobal:=multifiles(2);
                          end;
                        5:begin
                                okglobal:=multifiles(3);
                          end;
                        6:begin
                                singlefile;
                          end;
                end;
                inc(tempx);
                loadfilebase(tempx,1);
        end;
        curread:=oldnum;
        curf:=oldf;
        if (fbdirdlpath in curf.fbstat) then begin
                        NXF.Init(adrv(curf.dlpath)+curf.filename+'.NFD', syst.nkeywords,syst.ndesclines);
        end else begin
                        NXF.Init(adrv(systat.filepath)+curf.filename+'.NFD', syst.nkeywords,syst.ndesclines);
        end;
        nofiles:=FALSE;
        total:=NXF.Numfiles;
        if (total=0) then nofiles:=TRUE;
        if (current>total) then current:=total;
        removewindow(tempw);
        showfilename:=FALSE;
end else begin
        getscantype;
        if (fbdirdlpath in curf.fbstat) then begin
                        NXF.Init(adrv(curf.dlpath)+curf.filename+'.NFD', syst.nkeywords,syst.ndesclines);
        end else begin
                        NXF.Init(adrv(systat.filepath)+curf.filename+'.NFD', syst.nkeywords,syst.ndesclines);
        end;
        nofiles:=FALSE;
        total:=NXF.Numfiles;
        if (total=0) then nofiles:=TRUE;
        if (current>total) then current:=total;
        case scantype of
                        1:begin
                                okglobal:=multifiles(1);
                          end;
                        2:begin
                                okglobal:=multifiles(4);
                          end;
                        3:begin
                                okglobal:=multifiles(5);
                          end;
                        4:begin
                                okglobal:=multifiles(2);
                          end;
                        5:begin
                                okglobal:=multifiles(3);
                          end;
                        6:begin
                                singlefile;
                          end;
        end;
end;
end;

procedure delrecord(cr:integer);
var x3:integer;
begin
x3:=cr;
NXF.Deletefile(x3);
total:=NXF.NumFiles;
if (total=0) then begin
        nofiles:=TRUE;
        current:=0;
end;
if (current>total) then current:=total;
end;

procedure movefile(fname:string);
var response:byte;
    tmpstr:string;
    ok2:byte;
    cont:boolean;


function stripname(i:astr):astr;
var i1:astr;
    n:integer;

  function nextn:integer;
  var n:integer;
  begin
    n:=pos(':',i1);
    if (n=0) then n:=pos('\',i1);
    if (n=0) then n:=pos('/',i1);
    nextn:=n;
  end;

begin
  i1:=i;
  while (nextn<>0) do i1:=copy(i1,nextn+1,80);
  stripname:=i1;
end;

procedure cf(var ok:byte; var nospace:boolean; showprog:boolean;
                   srcname,destname:astr);
var buffer:array[1..4096] of byte;
    totread,fs,dfs:longint;
    nrec,i,x,x2,x3,en:integer;
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
  choices[1]:='Replace Existing File ';
  choices[2]:='Delete Source File    ';
  choices[3]:='Abort Move            ';
  setwindow(w4,27,10,53,16,3,0,8,'File Exists',TRUE);
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
                        checkkey(c);
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
  nospace:=FALSE;
  assign(src,srcname);
  filemode:=64;
  if exist(srcname) then begin
  {$I-} reset(src,1); {$I+}
  en:=ioresult;
  if (en<>0) then begin
        ok:=1;
        displaybox('File: '+srcname+' Error #'+cstr(en),5000);
        exit;
  end;
  end else begin
        ok:=5;
        exit;
  end;
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
          if (ok<>0) then b:=ok else
          b:=getresponse;
          ok:=0;
          case b of
                1:begin
                  cont:=TRUE;
                  x3:=1;
                  writerecno:=-1;
                  while (x3<=NXF2.Numfiles) and (writerecno=-1) do begin
                  NXF2.Seekfile(x3);
                  NXF2.Readheader;
                  if (allcaps(NXF2.Fheader.filename)=allcaps(stripname(destname))) then
                        writerecno:=x3;
                  inc(x3);
                  end;
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
    end else if (ok<>0) then ok:=0;
    if (cont) then begin
    {$I-} rewrite(dest,1); {$I+}
    if (ioresult<>0) then begin ok:=4; exit; end;
    window(1,1,80,25);
    gotoxy(1,25);
    clreol;
    gotoxy(1,25);
    textcolor(14);
    textbackground(0);
    write('Moving File: ');
    textcolor(15);
    write('0% ');
    textcolor(14);
    for i:=1 to 20 do write('°');
    textcolor(15);
    write(' 100%');

    x:=1;
    totread:=0;
    repeat
      filemode:=64;
      blockread(src,buffer,sizeof(buffer),nrec);
      filemode:=66;
      blockwrite(dest,buffer,nrec);
      totread:=totread+nrec;
      if (showprog) then begin
        for x2:=x to 20 do begin
        if (totread>=((fs div 20)*x2)) then begin
                gotoxy(16+x,25);
                textcolor(1);
                textbackground(0);
                write('Û');
                inc(x);
                end;
        end;
      end;
      until (nrec<sizeof(buffer));
    filemode:=66;
    dodate;
    close(dest);
    filemode:=64;
    close(src);
    filemode:=66;
    end;
  end;
end;

function substall(src,old,new:astr):astr;
var p:integer;
begin
  p:=1;
  while p>0 do begin
    p:=pos(old,src);
    if p>0 then begin
      insert(new,src,p+length(old));
      delete(src,p,length(old));
    end;
  end;
  substall:=src;
end;

function mf(srcname,destname:astr;ok:byte):byte;
var dfs,dft:integer;
    f:file;
    s,s1,s2,s3,opath:astr;
    nospace:boolean;
begin
  nospace:=FALSE;

  getdir(0,opath);
  assign(f,srcname);
  filemode:=64;
  {$I-} reset(f,1); {$I+}
  if (ioresult=0) then begin
  dft:=trunc(filesize(f)/1024.0)+1; close(f);
  end;
  dfs:=freek(exdrv(destname));
  cf(ok,nospace,TRUE,srcname,destname);
  if (ok=1) then begin
        if (nospace) then
        displaybox('Error moving file: insufficient space!',3000)
        else
        displaybox('Error reading source file!',3000);
  end;
  if (ok=4) then begin
        displaybox('Error creating target file!',3000);
  end;
  if (((ok=0) or (ok=2)) and (not nospace)) then begin
    filemode:=17;
    {$I-} erase(f); {$I+}
    if (ioresult<>0) then begin
    displaybox('Error removing file '+srcname,3000);
    end;
  end;
  chdir(opath);
  filemode:=66;
  mf:=ok;
end;


function alreadyexists(filen:string):boolean;
var found:boolean;
    nf:tindexrec;
begin
if (nofiles) then begin
        alreadyexists:=FALSE;
        exit;
end;
filemode:=66;
found:=FALSE;
seek(tff2,0);
while not(eof(tff2)) and not(found) do begin
read(tff2,nf);
if allcaps(filen)=allcaps(nf.filename) then begin
        found:=TRUE;
end;
end;
alreadyexists:=found;
end;

begin
recordmoved:=FALSE;
writerecno:=-1;
cont:=TRUE;
ok2:=0;
if (alreadyexists(fname)) then begin
        cont:=pynqbox('File already exists in target base.  Overwrite? ');
        if (cont) then ok2:=1;
end;
if (cont) then begin
        if (fbdirdlpath in curf.fbstat) then begin
                NXF2.Init(adrv(movf.dlpath)+movf.filename+'.NFD', syst.nkeywords,syst.ndesclines);
        end else begin
                NXF2.Init(adrv(systat.filepath)+movf.filename+'.NFD', syst.nkeywords,syst.ndesclines);
        end;
        NXF.Seekfile(current);
        NXF.Readheader;
        response:=mf(adrv(curf.dlpath)+NXF.Fheader.filename,adrv(movf.dlpath)+NXF.Fheader.filename,ok2);
        if (response<>0) then if pynqbox('Error moving file.  Move record anyway? ')
                then response:=0;
        if (response=0) then begin
                recordmoved:=TRUE;
                if (writerecno=-1) then
                        NXF2.AddNewfile(NXF.Fheader)
                else
                        NXF2.RewriteHeader(NXF.Fheader);
                NXF.KeywordStartup;
                tmpstr:=NXF.GetKeyword;
                while (tmpstr<>'') do begin
                        NXF2.AddKeyword(tmpstr);
                        tmpstr:=NXF.GetKeyword;
                end;
                NXF.DescStartup;
                tmpstr:=NXF.GetDescLine;
                while (tmpstr<>#1+'EOF'+#1) do begin
                        NXF2.AddDescLine(tmpstr);
                        tmpstr:=NXF.GetDescLine;
                end;
                NXF2.Done;
                delrecord(current);
        end;
end;
end;

procedure editfile;
var curr2,x2:integer;
    choices:array[1..9] of string[20];
    w3:windowrec;
    c2:char;
    autosave,d2,changed:boolean;


    procedure getflags;
    var w10:windowrec;
        cho2:array[1..6] of string[15];
        ch2:char;
        current2:integer;
        done2:boolean;
    begin
    done2:=FALSE;
    cho2[1]:='Unvalidated   :';
    cho2[2]:='Offline       :';
    cho2[3]:='Resume        :';
    cho2[4]:='Free          :';
    cho2[5]:='Check Security:';
    cho2[6]:='Hatched       :';
    setwindow(w10,30,9,52,18,3,0,8,'File Flags',TRUE);
    textcolor(7);
    textbackground(0);
    for current2:=1 to 6 do begin
        gotoxy(2,current2+1);
        write(cho2[current2]);
    end;
    textcolor(3);
    textbackground(0);
    with NXF.Fheader do begin
    gotoxy(18,2);
    write(syn(ffnotval in FileFlags));
    gotoxy(18,3);
    write(syn(ffisrequest in NXF.Fheader.FileFlags));
    gotoxy(18,4);
    write(syn(ffresumelater in NXF.Fheader.FileFlags));
    gotoxy(18,5);
    write(syn(ffisfree in NXF.Fheader.FileFlags));
    gotoxy(18,6);
    write(syn(ffchecksecurity in NXF.Fheader.FileFlags));
    gotoxy(18,7);
    write(syn(ffishatched in NXF.Fheader.FileFlags));
    end;
    current2:=1;
    repeat
    textcolor(15);
    textbackground(1);
    gotoxy(2,current2+1);
    write(cho2[current2]);
    while not(keypressed) do begin end;
    ch2:=readkey;
    case ch2 of
        #0:begin
                ch2:=readkey;
                checkkey(ch2);
                case ch2 of
                        #68:done2:=TRUE;
                        #72:begin
                            textcolor(7);
                            textbackground(0);
                            gotoxy(2,current2+1);
                            write(cho2[current2]);
                            dec(current2);
                            if (current2=0) then current2:=6;
                            end;
                        #80:begin
                            textcolor(7);
                            textbackground(0);
                            gotoxy(2,current2+1);
                            write(cho2[current2]);
                            inc(current2);
                            if (current2=7) then current2:=1;
                            end;
                end;
           end;
       #13:begin
                case current2 of
                        1:begin
                                if (ffnotval in NXF.Fheader.FileFlags) then
                                NXF.Fheader.FileFlags:=NXF.Fheader.FileFlags-[ffnotval] else
                                NXF.Fheader.FileFlags:=NXF.Fheader.FileFlags+[ffnotval];
                                changed:=TRUE;
                                gotoxy(18,current2+1);
                                textcolor(3);
                                textbackground(0);
                                write(syn(ffnotval in NXF.Fheader.FileFlags));
                          end;
                        2:begin
                                if (ffisrequest in NXF.Fheader.FileFlags) then
                                NXF.Fheader.FileFlags:=NXF.Fheader.FileFlags-[ffisrequest] else
                                NXF.Fheader.FileFlags:=NXF.Fheader.FileFlags+[ffisrequest];
                                changed:=TRUE;
                                gotoxy(18,current2+1);
                                textcolor(3);
                                textbackground(0);
                                write(syn(ffisrequest in NXF.Fheader.FileFlags));
                          end;
                        3:begin
                                if (ffresumelater in NXF.Fheader.FileFlags) then
                                NXF.Fheader.FileFlags:=NXF.Fheader.FileFlags-[ffresumelater] else
                                NXF.Fheader.FileFlags:=NXF.Fheader.FileFlags+[ffresumelater];
                                changed:=TRUE;
                                gotoxy(18,current2+1);
                                textcolor(3);
                                textbackground(0);
                                write(syn(ffresumelater in NXF.Fheader.FileFlags));
                          end;
                        4:begin
                                if (ffisfree in NXF.Fheader.FileFlags) then
                                NXF.Fheader.FileFlags:=NXF.Fheader.FileFlags-[ffisfree] else
                                NXF.Fheader.FileFlags:=NXF.Fheader.FileFlags+[ffisfree];
                                changed:=TRUE;
                                gotoxy(18,current2+1);
                                textcolor(3);
                                textbackground(0);
                                write(syn(ffisfree in NXF.Fheader.FileFlags));
                          end;
                        5:begin
                                if (ffchecksecurity in NXF.Fheader.FileFlags) then
                                NXF.Fheader.FileFlags:=NXF.Fheader.FileFlags-[ffchecksecurity] else
                                NXF.Fheader.FileFlags:=NXF.Fheader.FileFlags+[ffchecksecurity];
                                changed:=TRUE;
                                gotoxy(18,current2+1);
                                textcolor(3);
                                textbackground(0);
                                write(syn(ffchecksecurity in NXF.Fheader.FileFlags));
                          end;
                        6:begin
                                if (ffishatched in NXF.Fheader.FileFlags) then
                                NXF.Fheader.FileFlags:=NXF.Fheader.FileFlags-[ffishatched] else
                                NXF.Fheader.FileFlags:=NXF.Fheader.FileFlags+[ffishatched];
                                gotoxy(18,current2+1);
                                changed:=TRUE;
                                textcolor(3);
                                textbackground(0);
                                write(syn(ffishatched in NXF.Fheader.FileFlags));
                          end;
                end;
           end;
       #27:done2:=TRUE;
    end;
    until (done2);
    removewindow(w10);
    end;

    procedure getfileinfo;
    var w10:windowrec;
        cho2:array[1..3] of string[15];
        dt:datetime;
        ch2:char;
        current2:integer;
        done2:boolean;
    begin
    done2:=FALSE;
    cho2[1]:='File Size (Kb):';
    cho2[2]:='Date          :';
    cho2[3]:='Filepoints    :';
    setwindow(w10,23,10,60,16,3,0,8,'File Info',TRUE);
    textcolor(7);
    textbackground(0);
    for current2:=1 to 3 do begin
        gotoxy(2,current2+1);
        write(cho2[current2]);
    end;
    textcolor(8);
    textbackground(0);
    gotoxy(18,2);
    write(mln(cstr(NXF.Fheader.FileSize),10));
    gotoxy(18,3);
    unixtodt(NXF.Fheader.FileDate,dt);
    write(formatteddate(dt,'MM/DD/YYYY HH:II:SS'));
    gotoxy(18,4);
    textcolor(3);
    write(mln(cstr(NXF.Fheader.filepoints),5));
    current2:=1;
    repeat
    textcolor(15);
    textbackground(1);
    gotoxy(2,current2+1);
    write(cho2[current2]);
    while not(keypressed) do begin end;
    ch2:=readkey;
    case ch2 of
        #0:begin
                ch2:=readkey;
                checkkey(ch2);
                case ch2 of
                        #68:done2:=TRUE;
                        #72:begin
                            textcolor(7);
                            textbackground(0);
                            gotoxy(2,current2+1);
                            write(cho2[current2]);
                            dec(current2);
                            if (current2=0) then current2:=3;
                            end;
                        #80:begin
                            textcolor(7);
                            textbackground(0);
                            gotoxy(2,current2+1);
                            write(cho2[current2]);
                            inc(current2);
                            if (current2=4) then current2:=1;
                            end;
                end;
           end;
       #13:begin
                                infield_inp_fgrd:=15;
                                infield_inp_bkgd:=1;
                                infield_out_fgrd:=3;
                                infield_out_bkgd:=0;
                                infield_allcaps:=FALSE;
                                infield_numbers_only:=TRUE;
                                infield_show_colors:=FALSE;
                                infield_maxshow:=0;
                                infield_clear:=TRUE;
                                infield_putatend:=TRUE;
                                gotoxy(2,current2+1);
                                textcolor(7);
                                textbackground(0);
                                write(cho2[current2]);
                                gotoxy(16,current2+1);
                                textcolor(9);
                                textbackground(0);
                                write('>');
                                gotoxy(18,current2+1);
                case current2 of
                       {1:begin
                                infield_allcaps:=TRUE;
                                s:=cstr(NXF.Fheader.FileSize);
                                infielde(s,10);
                                if (value(s)<>NXF.Fheader.FileSize) then begin
                                        changed:=TRUE;
                                        NXF.Fheader.Filesize:=value(s);
                                end;
                                textcolor(3);
                                textbackground(0);
                                gotoxy(18,2);
                                write(mln(cstr(NXF.Fheader.FileSize),10));
                          end;}
                        3:begin
                                infield_allcaps:=TRUE;
                                s:=cstr(NXF.Fheader.filepoints);
                                infielde(s,5);
                                if (value(s)<>NXF.Fheader.filepoints) then begin
                                        changed:=TRUE;
                                        NXF.Fheader.filepoints:=value(s);
                                end;
                          end;
                end;
           end;
       #27:done2:=TRUE;
    end;
    until (done2);
    removewindow(w10);
    end;

    procedure getulinfo;
    var w10:windowrec;
        dt:datetime;
        cho2:array[1..2] of string[15];
        ch2:char;
        current2:integer;
        done2:boolean;
    begin
    done2:=FALSE;
    cho2[1]:='Date File ULed:';
    cho2[2]:='Uploaded By   :';
    setwindow(w10,22,11,61,16,3,0,8,'Upload Info',TRUE);
    textcolor(7);
    textbackground(0);
    for current2:=1 to 2 do begin
        gotoxy(2,current2+1);
        write(cho2[current2]);
    end;
    textcolor(3);
    textbackground(0);
    gotoxy(18,2);
    unixtodt(NXF.Fheader.UploadedDate,dt);
    write(formatteddate(dt,'MM/DD/YYYY HH:II:SS'));
    gotoxy(18,3);
    write(mln(NXF.Fheader.Uploadedby,20));
    current2:=1;
    repeat
    textcolor(15);
    textbackground(1);
    gotoxy(2,current2+1);
    write(cho2[current2]);
    while not(keypressed) do begin end;
    ch2:=readkey;
    case ch2 of
        #0:begin
                ch2:=readkey;
                checkkey(ch2);
                case ch2 of
                        #68:done2:=TRUE;
                        #72:begin
                            textcolor(7);
                            textbackground(0);
                            gotoxy(2,current2+1);
                            write(cho2[current2]);
                            dec(current2);
                            if (current2=0) then current2:=2;
                            end;
                        #80:begin
                            textcolor(7);
                            textbackground(0);
                            gotoxy(2,current2+1);
                            write(cho2[current2]);
                            inc(current2);
                            if (current2=3) then current2:=1;
                            end;
                end;
           end;
       #13:begin
                                infield_inp_fgrd:=15;
                                infield_inp_bkgd:=1;
                                infield_out_fgrd:=3;
                                infield_out_bkgd:=0;
                                infield_allcaps:=FALSE;
                                infield_numbers_only:=TRUE;
                                infield_show_colors:=FALSE;
                                infield_maxshow:=0;
                                infield_clear:=TRUE;
                                infield_putatend:=TRUE;
                                gotoxy(2,current2+1);
                                textcolor(7);
                                textbackground(0);
                                write(cho2[current2]);
                                gotoxy(16,current2+1);
                                textcolor(9);
                                textbackground(0);
                                write('>');
                                gotoxy(18,current2+1);
                case current2 of
                        1:begin
                                unixtodt(NXF.Fheader.UploadedDate,dt);
                                s:=formatteddate(dt,'MM/DD/YYYY HH:II:SS');
                                infield_allcaps:=TRUE;
                                infielde(s,18);
                                if (s<>formatteddate(dt,'MM/DD/YYYY HH:II:SS')) then begin
                                        changed:=TRUE;
                                        NXF.Fheader.UploadedDate:=u_daynum(s);
                                end;
                          end;
                        2:begin
                                infield_allcaps:=TRUE;
                                s:=NXF.Fheader.Uploadedby;
                                infield_maxshow:=20;
                                infielde(s,36);
                                infield_maxshow:=0;
                                if (s<>NXF.Fheader.Uploadedby) then begin
                                        changed:=TRUE;
                                        NXF.Fheader.Uploadedby:=s;
                                end;
                          end;
                end;
           end;
       #27:done2:=TRUE;
    end;
    until (done2);
    removewindow(w10);
    end;

    procedure getdlinfo;
    var w10:windowrec;
        dt:datetime;
        cho2:array[1..2] of string[15];
        ch2:char;
        current2:integer;
        done2:boolean;
    begin
    done2:=FALSE;
    cho2[1]:='Date Last DLed:';
    cho2[2]:='Number of DLs :';
    setwindow(w10,22,11,60,16,3,0,8,'Download Info',TRUE);
    textcolor(7);
    textbackground(0);
    for current2:=1 to 2 do begin
        gotoxy(2,current2+1);
        write(cho2[current2]);
    end;
    textcolor(3);
    textbackground(0);
    gotoxy(18,2);
    unixtodt(NXF.Fheader.LastDLDate,dt);
    write(formatteddate(dt,'MM/DD/YYYY HH:II:SS'));
    gotoxy(18,3);
    write(mln(cstr(NXF.Fheader.NumDownloads),5));
    current2:=1;
    repeat
    textcolor(15);
    textbackground(1);
    gotoxy(2,current2+1);
    write(cho2[current2]);
    while not(keypressed) do begin end;
    ch2:=readkey;
    case ch2 of
        #0:begin
                ch2:=readkey;
                checkkey(ch2);
                case ch2 of
                        #68:done2:=TRUE;
                        #72:begin
                            textcolor(7);
                            textbackground(0);
                            gotoxy(2,current2+1);
                            write(cho2[current2]);
                            dec(current2);
                            if (current2=0) then current2:=2;
                            end;
                        #80:begin
                            textcolor(7);
                            textbackground(0);
                            gotoxy(2,current2+1);
                            write(cho2[current2]);
                            inc(current2);
                            if (current2=3) then current2:=1;
                            end;
                end;
           end;
       #13:begin
                                infield_inp_fgrd:=15;
                                infield_inp_bkgd:=1;
                                infield_out_fgrd:=3;
                                infield_out_bkgd:=0;
                                infield_allcaps:=FALSE;
                                infield_numbers_only:=TRUE;
                                infield_show_colors:=FALSE;
                                infield_maxshow:=0;
                                infield_clear:=TRUE;
                                infield_putatend:=TRUE;
                                gotoxy(2,current2+1);
                                textcolor(7);
                                textbackground(0);
                                write(cho2[current2]);
                                gotoxy(16,current2+1);
                                textcolor(9);
                                textbackground(0);
                                write('>');
                                gotoxy(18,current2+1);
                case current2 of
                        1:begin
                                unixtodt(NXF.Fheader.LastDLDate,dt);
                                s:=formatteddate(dt,'MM/DD/YYYY HH:II:SS');
                                infield_allcaps:=TRUE;
                                infielde(s,18);
                                if (s<>formatteddate(dt,'MM/DD/YYYY HH:II:SS')) then begin
                                        changed:=TRUE;
                                        NXF.Fheader.LastDLDate:=u_daynum(s);
                                end;
                          end;
                        2:begin
                                infield_allcaps:=TRUE;
                                s:=cstr(NXF.Fheader.NumDownloads);
                                infielde(s,5);
                                if (value(s)<>NXF.Fheader.Numdownloads) then begin
                                        changed:=TRUE;
                                        NXF.Fheader.NumDownloads:=value(s);
                                end;
                          end;
                end;
           end;
       #27:done2:=TRUE;
    end;
    until (done2);
    removewindow(w10);
    end;

    procedure getaccessinfo;
    var w10:windowrec;
        cho2:array[1..2] of string[15];
        ch2:char;
        current2:integer;
        done2:boolean;
    begin
    done2:=FALSE;
    cho2[1]:='Access String :';
    cho2[2]:='Access Key    :';
    setwindow(w10,22,11,61,16,3,0,8,'Access Info',TRUE);
    textcolor(7);
    textbackground(0);
    for current2:=1 to 2 do begin
        gotoxy(2,current2+1);
        write(cho2[current2]);
    end;
    textcolor(3);
    textbackground(0);
    gotoxy(18,2);
    write(mln(NXF.Fheader.Access,20));
    current2:=1;
    repeat
    textcolor(15);
    textbackground(1);
    gotoxy(2,current2+1);
    write(cho2[current2]);
    while not(keypressed) do begin end;
    ch2:=readkey;
    case ch2 of
        #0:begin
                ch2:=readkey;
                checkkey(ch2);
                case ch2 of
                        #68:done2:=TRUE;
                        #72:begin
                            textcolor(7);
                            textbackground(0);
                            gotoxy(2,current2+1);
                            write(cho2[current2]);
                            dec(current2);
                            if (current2=0) then current2:=2;
                            end;
                        #80:begin
                            textcolor(7);
                            textbackground(0);
                            gotoxy(2,current2+1);
                            write(cho2[current2]);
                            inc(current2);
                            if (current2=3) then current2:=1;
                            end;
                end;
           end;
       #13:begin
                                infield_inp_fgrd:=15;
                                infield_inp_bkgd:=1;
                                infield_out_fgrd:=3;
                                infield_out_bkgd:=0;
                                infield_allcaps:=FALSE;
                                infield_numbers_only:=FALSE;
                                infield_show_colors:=FALSE;
                                infield_maxshow:=0;
                                infield_clear:=TRUE;
                                infield_putatend:=TRUE;
                                gotoxy(2,current2+1);
                                textcolor(7);
                                textbackground(0);
                                write(cho2[current2]);
                                gotoxy(16,current2+1);
                                textcolor(9);
                                textbackground(0);
                                write('>');
                                gotoxy(18,current2+1);
                case current2 of
                        1:begin
                                infield_allcaps:=TRUE;
                                s:=NXF.Fheader.access;
                                infielde(s,20);
                                if (s<>NXF.Fheader.access) then begin
                                        changed:=TRUE;
                                        NXF.Fheader.access:=s;
                                end;
                          end;
                        2:begin
                                infield_allcaps:=TRUE;
                                s:=NXF.Fheader.accesskey;
                                infielde(s,20);
                                if (s<>NXF.Fheader.accesskey) then begin
                                        changed:=TRUE;
                                        NXF.Fheader.accesskey:=s;
                                end;
                          end;
                end;
           end;
       #27:done2:=TRUE;
    end;
    until (done2);
    removewindow(w10);
    end;

    procedure fileinfo;
    var dt:datetime;
    begin
    gotoxy(20,16);
    textcolor(7);
    textbackground(0);
    write('Size: ');
    textcolor(3);
    write(mln(showblocks(NXF.Fheader.FileSize div 1024),18));
    textcolor(7);
    write(' Date: ');
    textcolor(3);
    unixtodt(NXF.Fheader.FileDate,dt);
    write(mln(formatteddate(dt,'MM/DD/YYYY HH:II:SS'),18));
    gotoxy(20,17);
    textcolor(7);
    textbackground(0);
    write('Pts : ');
    textcolor(3);
    write(mln(cstr(NXF.Fheader.filepoints),18));
    end;

    procedure uploadinfo;
    var dt:datetime;
    begin
    gotoxy(20,18);
    textcolor(7);
    textbackground(0);
    write('Date: ');
    textcolor(3);
    unixtodt(NXF.Fheader.UploadedDate,dt);
    write(mln(formatteddate(dt,'MM/DD/YYYY HH:II:SS'),18));
    textcolor(7);
    write(' By  : ');
    textcolor(3);
    write(mln(NXF.Fheader.UploadedBy,26));
    end;

    procedure dlinfo;
    var dt:datetime;
    begin
    gotoxy(20,19);
    textcolor(7);
    textbackground(0);
    write('Date: ');
    textcolor(3);
    unixtodt(NXF.fheader.lastDLdate,dt);
    write(mln(formatteddate(dt,'MM/DD/YYYY HH:II:SS'),18));
    textcolor(7);
    write(' # DL: ');
    textcolor(3);
    write(mln(cstr(NXF.Fheader.NumDownloads),5));
    end;

    procedure acsinfo;
    begin
    gotoxy(20,20);
    textcolor(7);
    textbackground(0);
    write('ACS : ');
    textcolor(3);
    write(mln(NXF.Fheader.access,18));
    textcolor(7);
    write(' Key : ');
    textcolor(3);
    write(mln(NXF.Fheader.accesskey,20));
    end;

    procedure ffflags;
    var s2:string;
    begin
    gotoxy(20,21);
    textcolor(3);
    textbackground(0);
    clreol;
    s2:='';
    if (ffnotval in NXF.Fheader.Fileflags) then s2:=s2+'Unval ';
    if (ffisrequest in NXF.Fheader.Fileflags) then s2:=s2+'Request ';
    if (ffresumelater in NXF.Fheader.Fileflags) then s2:=s2+'Resume ';
    if (ffisfree in NXF.Fheader.Fileflags) then s2:=s2+'Free ';
    if (ffchecksecurity in NXF.Fheader.Fileflags) then s2:=s2+'Secure ';
    if (ffishatched in NXF.Fheader.Fileflags) then s2:=s2+'Hatched';
    if (s2='') then s2:='None';
    write(s2);
    end;

    procedure showdesc;
    var x3:integer;
        s3:string;
    begin
        gotoxy(20,4);
        textcolor(3);
        textbackground(0);
        for x3:=1 to 10 do begin
                gotoxy(20,3+x3);
                write(mln('',45));
        end;
        x3:=1;
        NXF.DescStartup;
        s3:=NXF.GetDescLine;
        while (s3<>#1+'EOF'+#1) and (x3<=10) do begin
                gotoxy(20,3+x3);
                write(mln(s3,45));
                s3:=NXF.GetDescLine;
                inc(x3);
        end;
    end;

    procedure checkfileinfo;
    var mtf:file;
        s:string;
        fsize:longint;
        ask1,ask2:boolean;
        fpacked:longint;
        dt:datetime;
    begin
    s:='';
    ask1:=FALSE;
    ask2:=FALSE;
    assign(mtf,adrv(curf.dlpath)+NXF.Fheader.Filename);
    {$I-} reset(mtf,1); {$I+}
    if (ioresult<>0) then begin
        ask1:=TRUE;
        s:='Filesize incorrect';
    end else begin
        fsize:=filesize(mtf);
        if (NXF.Fheader.FileSize<>fsize) then begin
        ask1:=TRUE;
        s:='Filesize incorrect';
        end;
        GetFTime(mtf,fpacked);
        UnpackTime(fpacked,dt);
        if (NXF.Fheader.FileDate<>DTToUnixDate(dt)) then begin
                if (s='') then s:='File Date incorrect.' else begin
                        s:=s+' and file date incorrect.';
                end;
                ask2:=TRUE;
        end;
        close(mtf);
    end;
    if (ask1) or (ask2) then begin
        if pynqbox(s+' Update? ') then begin
                if (ask1) then NXF.Fheader.FileSize:=fsize;
                if (ask2) then NXF.Fheader.FileDate:=DTToUnixDate(dt);
                NXF.Rewriteheader(NXF.Fheader);
        end;
    end;
    window(2,2,78,23);
    end;

begin
autosave:=FALSE;
changed:=FALSE;
d2:=FALSE;
choices[1]:='Filename        :';
choices[2]:='Magic Name      :';
choices[3]:='Description     -';
choices[4]:='Keywords        -';
choices[5]:='File Info       -';
choices[6]:='Upload Info     -';
choices[7]:='Download Info   -';
choices[8]:='Access Info     -';
choices[9]:='File Flags      -';
NXF.SeekFile(current);
NXF.ReadHeader;
setwindow2(w3,1,1,79,24,3,0,8,'Edit File #'+cstr(current),'File Base Manager',FALSE);
textcolor(7);
textbackground(0);
x2:=0;
for curr2:=1 to 9 do begin
        inc(x2);
        if (curr2=4) then inc(x2,9);
        if (curr2=5) then inc(x2,1);
        if (curr2=6) then inc(x2,1);
        gotoxy(2,x2+1);
        write(choices[curr2]);
end;
textcolor(3); textbackground(0);
gotoxy(20,2);
write(mln(NXF.Fheader.filename,12));
gotoxy(20,3);
write(mln(NXF.Fheader.magicname,12));
showdesc;
fileinfo;
uploadinfo;
dlinfo;
acsinfo;
ffflags;
curr2:=1;
x2:=1;
if exist(adrv(curf.dlpath)+NXF.Fheader.filename) then checkfileinfo;
repeat
window(1,1,80,25);
textcolor(14);
textbackground(0);
gotoxy(1,25);
clreol;
write('Esc');
textcolor(7);
write('=Exit ');
textcolor(14);
write('F10');
textcolor(7);
write('=Save');
window(2,2,78,23);
gotoxy(2,x2+1);
textcolor(15);
textbackground(1);
write(choices[curr2]);
while not(keypressed) do begin end;
c2:=readkey;
case c2 of
        #0:begin
                c2:=readkey;
                checkkey(c2);
                case c2 of
                        #68:begin
                                d2:=TRUE;
                                autosave:=TRUE;
                            end;
                        #72:begin
                            gotoxy(2,x2+1);
                            textcolor(7);
                            textbackground(0);
                            write(choices[curr2]);
                            dec(curr2);
                            dec(x2);
                            if (curr2=3) then x2:=3;
                            if (curr2=4) then x2:=13;
                            if (curr2=5) then x2:=15;
                            if (curr2=0) then begin
                                curr2:=9;
                                x2:=20;
                            end;
                            end;
                        #80:begin
                            gotoxy(2,x2+1);
                            textcolor(7);
                            textbackground(0);
                            write(choices[curr2]);
                            inc(curr2);
                            inc(x2);
                            if (curr2=4) then inc(x2,9);
                            if (curr2=5) then inc(x2,1);
                            if (curr2=6) then inc(x2,1);
                            if (curr2=10) then begin
                                curr2:=1;
                                x2:=1;
                            end;
                            end;
                end;
           end;
        #13:begin
                                infield_inp_fgrd:=15;
                                infield_inp_bkgd:=1;
                                infield_out_fgrd:=3;
                                infield_out_bkgd:=0;
                                infield_allcaps:=FALSE;
                                infield_numbers_only:=false;
                                infield_show_colors:=FALSE;
                                infield_maxshow:=0;
                                infield_clear:=TRUE;
                                infield_putatend:=TRUE;
                                gotoxy(2,x2+1);
                                textcolor(7);
                                textbackground(0);
                                write(choices[curr2]);
                                gotoxy(18,x2+1);
                                textcolor(9);
                                textbackground(0);
                                write('>');
                                gotoxy(20,x2+1);
                case curr2 of
                        1:begin
                                infield_allcaps:=TRUE;
                                s:=NXF.Fheader.filename;
                                infielde(s,12);
                                if (s<>NXF.Fheader.filename) then begin
                                        changed:=TRUE;
                                        NXF.Fheader.filename:=s;
                                end;
                          end;
                        2:begin
                                gotoxy(18,x2+1);
                                textcolor(9);
                                textbackground(0);
                                write('>');
                                gotoxy(20,x2+1);
                                infield_allcaps:=TRUE;
                                s:=NXF.Fheader.magicname;
                                infielde(s,12);
                                if (s<>NXF.Fheader.magicname) then begin
                                        changed:=TRUE;
                                        NXF.Fheader.magicname:=s;
                                end;
                          end;
                        3:begin
setwindow4(w3,1,1,79,24,8,0,8,'Edit File #'+cstr(current),'File Base Manager',FALSE);
                                if (getdescription2) then if not(changed) then
                                        changed:=TRUE;
setwindow5(w3,1,1,79,24,3,0,8,'Edit File #'+cstr(current),'File Base Manager',FALSE);
                                window(2,2,78,23);
                                showdesc;
                          end;
                        4:begin
setwindow4(w3,1,1,79,24,8,0,8,'Edit File #'+cstr(current),'File Base Manager',FALSE);
                                displaybox('This feature is not yet available!',2000);
setwindow5(w3,1,1,79,24,3,0,8,'Edit File #'+cstr(current),'File Base Manager',FALSE);
                                window(2,2,78,23);
                          end;
                        5:begin
setwindow4(w3,1,1,79,24,8,0,8,'Edit File #'+cstr(current),'File Base Manager',FALSE);
                                getfileinfo;
setwindow5(w3,1,1,79,24,3,0,8,'Edit File #'+cstr(current),'File Base Manager',FALSE);
                                window(2,2,78,23);
                                fileinfo;
                          end;
                        6:begin
setwindow4(w3,1,1,79,24,8,0,8,'Edit File #'+cstr(current),'File Base Manager',FALSE);
                                getulinfo;
setwindow5(w3,1,1,79,24,3,0,8,'Edit File #'+cstr(current),'File Base Manager',FALSE);
                                window(2,2,78,23);
                                uploadinfo;
                          end;
                        7:begin
setwindow4(w3,1,1,79,24,8,0,8,'Edit File #'+cstr(current),'File Base Manager',FALSE);
                                getdlinfo;
setwindow5(w3,1,1,79,24,3,0,8,'Edit File #'+cstr(current),'File Base Manager',FALSE);
                                window(2,2,78,23);
                                dlinfo;
                          end;
                        8:begin
setwindow4(w3,1,1,79,24,8,0,8,'Edit File #'+cstr(current),'File Base Manager',FALSE);
                                getaccessinfo;
setwindow5(w3,1,1,79,24,3,0,8,'Edit File #'+cstr(current),'File Base Manager',FALSE);
                                window(2,2,78,23);
                                acsinfo;
                          end;
                        9:begin
setwindow4(w3,1,1,79,24,8,0,8,'Edit File #'+cstr(current),'File Base Manager',FALSE);
                                getflags;
setwindow5(w3,1,1,79,24,3,0,8,'Edit File #'+cstr(current),'File Base Manager',FALSE);
                                window(2,2,78,23);
                                ffflags;
                        end;
                end;
            end;
        #27:d2:=TRUE;
end;
until (d2);
if (changed) and not(autosave) then
        autosave:=pynqbox('Save changes? ');
if (changed) and (autosave) then begin
        NXF.RewriteHeader(NXF.Fheader);
end;
removewindow(w3);
end;

procedure writescrolldown;
var p:real;
perc:integer;
    oldcol:integer;
    x2,x3,hgt,perc2:integer;
begin
window(1,1,80,25);
p:=(current/total);
perc:=trunc(p*100);
hgt:=((bry-2) - (tly+3))+1;
if (current=1) then begin
                oldcol:=textattr;
                textcolor(tcolr);
                textbackground(bcolr);
                for x2:=(TLY+2) to (BRY-2) do begin
                        gotoxy(brx,x2);
                        write('°');
                end;
                gotoxy(brx,tly+2);
                write('Û');
                textattr:=oldcol;
                lastscroll:=0;
end {else if (current=total) then begin
                oldcol:=textattr;
                textcolor(tcolr);
                textbackground(bcolr);
                for x2:=(TLY+2) to (BRY-2) do begin
                        gotoxy(brx,x2);
                        write('°');
                end;
                gotoxy(brx,bry-2);
                write('Û');
                textattr:=oldcol;
                lastscroll:=hgt+1;
end} else begin
for x3:=1 to hgt do begin
        p:=(x3/hgt);
        if ((perc>=trunc((x3/hgt)*100)) and (perc<trunc(((x3+1)/hgt)*100))){ or
                (lastscroll=0) }then begin
                if (x3<>lastscroll) then begin
                oldcol:=textattr;
                textcolor(tcolr);
                textbackground(bcolr);
                for x2:=(TLY+2) to (BRY-2) do begin
                        gotoxy(brx,x2);
                        write('°');
                end;
                gotoxy(brx,(tly+3)+(x3-1));
                write('Û');
                textattr:=oldcol;
                lastscroll:=x3;
                x3:=hgt;
                end;
        end;
end;
end;
window(TLX+1,TLY+1,BRX-1,BRY-1);
end;

procedure setindex(x:longint; d1,d2,m,t:boolean; mb:integer);
var nf:tindexrec;
begin
if (nofiles) then begin
        exit;
end;
if (x<=filesize(tff)-1) then begin
        seek(tff,x);
        read(tff,nf);
        nf.status:=[];
        if (d1) then nf.status:=nf.status+[deleted];
        if (d2) then nf.status:=nf.status+[dfile];
        if (m) then nf.status:=nf.status+[moved];
        if (t) then nf.status:=nf.status+[tagged];
        nf.mbase:=mb;
        seek(tff,x);
        write(tff,nf);
end;
end;

function checkindex(x:longint; ftype:byte; var mbase:integer):boolean;
var nf:tindexrec;
begin
if (nofiles) then begin
        checkindex:=FALSE;
        exit;
end;
if (x<=filesize(tff)-1) then begin
        seek(tff,x);
        read(tff,nf);
        case ftype of
                1:checkindex:=(deleted in nf.status);
                2:checkindex:=(dfile in nf.status);
                3:checkindex:=(moved in nf.status);
                4:checkindex:=(tagged in nf.status);
        end;
        mbase:=nf.mbase;
end;
end;

procedure showline(x2:integer);
var dt:datetime;
    s10:string;
    x:integer;
begin
if (nofiles) then exit;
unixtodt(NXF.Fheader.UploadedDate,dt);
NXF.DescStartup;
s10:=NXF.GetDescLine;
if (s10=#1+'EOF'+#1) then s10:='';
if (checkindex(x2,1,x)) then cwrite('%120%D %070%') else
if (checkindex(x2,3,x)) then cwrite('%120%M %070%') else
if (checkindex(x2,4,x)) then cwrite('%140%þ %070%') else
cwrite('%070%  ');
cwrite(mln(mln(NXF.Fheader.filename,12)+' '+
mrn(showblocks(trunc(NXF.Fheader.filesize/1024.0)),4)+' '+formatteddate(dt,'MM/DD/YY')+' '+mln(s10,45),brx-(tlx+5)));
end;

procedure showline2(x2:integer);
var dt:datetime;
    s10:string;
    x:integer;
begin
if (nofiles) then exit;
unixtodt(NXF.Fheader.UploadedDate,dt);
NXF.DescStartup;
s10:=NXF.GetDescLine;
if (s10=#1+'EOF'+#1) then s10:='';
if (checkindex(x2,1,x)) then cwrite('%120%D %151%') else
if (checkindex(x2,3,x)) then cwrite('%120%M %151%') else
if (checkindex(x2,4,x)) then cwrite('%140%þ %151%') else
cwrite('%070%  %151%');
cwrite(mln(mln(NXF.Fheader.filename,12)+' '+
mrn(showblocks(trunc(NXF.Fheader.filesize/1024.0)),4)+' '+formatteddate(dt,'MM/DD/YY')+' '+mln(s10,45),brx-(tlx+5)));
end;

procedure upkey;
var w8:windowrec;
begin
savescreen(w8,tlx+2,tly+1,brx-1,bry-3);
movewindow(w8,tlx+2,tly+2);
window(TLX+1,TLY+1,BRX-1,BRY-1);
NXF.SeekFile(top);
NXF.ReadHeader;
textcolor(7);
textbackground(0);
gotoxy(2,2);
showline(top-1);
end;


procedure downkey;
var w8:windowrec;
begin
savescreen(w8,tlx+2,tly+3,brx-1,bry-1);
movewindow(w8,tlx+2,tly+2);
window(TLX+1,TLY+1,BRX-1,BRY-1);
textcolor(7);
textbackground(0);
gotoxy(2,height+1);
showline(current-1);
end;

procedure redrawdata;
var x:integer;
begin
if (nofiles) then begin
        for x:=1 to height do begin
                textcolor(7);
                textbackground(0);
                gotoxy(2,x+1);
                write(mln(' ',brx-(tlx+3)));
        end;
end else begin
textcolor(7);
textbackground(0);
for x:=1 to height do begin
        NXF.Seekfile(top+(x-1));
        if not(NXF.Ferror) then begin
        NXF.ReadHeader;
        textcolor(7);
        textbackground(0);
        gotoxy(2,x+1);
        showline((top+(x-1))-1);
        end else begin
        textcolor(7);
        textbackground(0);
        gotoxy(2,x+1);
        write(mln(' ',brx-(tlx+3)));
        end;
        end;
end;
end;


procedure delfile(fn:string);
var f3:file;
    ti:integer;
begin
assign(f3,fn);
{$I-} erase(f3); {$I+}
ti:=ioresult;
if (ti<>0) then begin
        displaybox(cstr(ti)+': Error deleting file: '+allcaps(fn),2000);
end;
end;

procedure setupbottom;
begin
window(1,1,80,25);
gotoxy(1,25);
textcolor(14);
textbackground(0);
clreol;
cwrite('%140%Esc%070%=Exit %140%Enter%070%=Edit %140%Ins/Del '+
       '%140%ALT+: M%070%=Move %140%S%070%=Sort %140%K%070%=Comment %140%C%070%=Convert %140%G%070%=Global');
window(TLX+1,TLY+1,BRX-1,BRY-1);
end;

function getsorttype:string;
var cchoices:array[1..2] of string[15];
    w10:windowrec;
    ccur:byte;
    dnn:boolean;
    ch10:char;
    ret:string[2];

        function showorder(ch8:char):string;
        begin
                case ch8 of
                        '0':showorder:='Descending';
                        '1':showorder:='Ascending ';
                end;
        end;

        function showsort(ch8:char):string;
        begin
               case ch8 of
                'D':showsort:='Date       ';
                'N':showsort:='Filename   ';
                'E':showsort:='Extension  ';
                'F':showsort:='Filepoints ';
                'S':showsort:='Size       ';
                'T':showsort:='Times DLed ';
               end;
        end;
begin
        ret:='1N';
        setwindow(w10,25,10,55,15,3,0,8,'Sort Options',TRUE);
        cchoices[1]:='Sort by  :';
        cchoices[2]:='Order    :';
        gotoxy(2,2);
        textcolor(7);
        textbackground(0);
        write(cchoices[1]+' ');
        textcolor(3);
        write(showsort(ret[2]));
        gotoxy(2,3);
        textcolor(7);
        textbackground(0);
        write(cchoices[2]+' ');
        textcolor(3);
        write(showorder(ret[1]));
        dnn:=FALSE;
        ccur:=1;
        repeat
        window(1,1,80,25);
        gotoxy(1,25);
        textcolor(14);
        textbackground(0);
        clreol;
        write('Esc');
        textcolor(7);
        write('=Abort ');
        textcolor(14);
        write('F10');
        textcolor(7);
        write('=Continue');
        window(26,11,54,14);
        gotoxy(2,ccur+1);
        textcolor(15);
        textbackground(1);
        write(cchoices[ccur]);
        while not(keypressed) do begin end;
        ch10:=readkey;
        case ch10 of
                #0:begin
                        ch10:=readkey;
                        checkkey(ch10);
                      case ch10 of
                        #68:begin
                                dnn:=TRUE;
                            end;
                        #72,#80:begin
                                        gotoxy(2,ccur+1);
                                        textcolor(7);
                                        textbackground(0);
                                        write(cchoices[ccur]);
                                        if (ccur=1) then ccur:=2 else ccur:=1;
                                end;
                       end;
                   end;
               #13:case ccur of
                        1:begin
                               case ret[2] of
                                'D':ret[2]:='N';
                                'N':ret[2]:='E';
                                'E':ret[2]:='F';
                                'F':ret[2]:='S';
                                'S':ret[2]:='T';
                                'T':ret[2]:='D';
                               end;
                               gotoxy(13,2);
                               textcolor(3);
                               textbackground(0);
                               write(showsort(ret[2]));
                          end;
                        2:begin
                                if (ret[1]='1') then ret[1]:='0' else
                                ret[1]:='1';
                                gotoxy(13,3);
                                textcolor(3);
                                textbackground(0);
                                write(showorder(ret[1]));
                          end;
                   end;
                #27:begin
                        ret:='';
                        dnn:=TRUE;
                    end;
        end;
        until (dnn);
        removewindow(w10);
        getsorttype:=ret;
end;

procedure deletefromindex(x:integer);
var x2:integer;
    nf:tindexrec;
begin
seek(tff,x);
for x2:=x+1 to filesize(tff)-1 do begin
        seek(tff,x2);
        read(tff,nf);
        seek(tff,x2-1);
        write(tff,nf);
end;
seek(tff,filesize(tff)-1);
truncate(tff);
end;

procedure purgefiles;
var nf:tindexrec;
    x:longint;
begin
if (nofiles) then begin
        exit;
end;
x:=filesize(tff)-1;
setwindow2(w2,10,10,70,15,3,0,8,'Deleting file(s)...','',TRUE);
window(11,11,69,14);
textcolor(7);
textbackground(0);
gotoxy(2,2);
write('Filename         :');
gotoxy(2,3);
write('Del physical file:');
while (x>=0) do begin
        seek(tff,x);
        read(tff,nf);
        if (deleted in nf.status) then begin
                window(11,11,69,14);
                gotoxy(21,2);
                textcolor(3);
                write(mln(adrv(curf.dlpath)+nf.filename,35));
                gotoxy(21,3);
                textcolor(3);
                cwrite(syn(dfile in nf.status));
                delrecord(x+1);
                deletefromindex(x);
                if (dfile in nf.status) then begin
                      delfile(adrv(curf.dlpath)+nf.filename);
                end;
        end;
        dec(x);
end;
removewindow(w2);
aredeleted:=FALSE;
curread:=-1;
end;

procedure moveallfiles;
var nf:tindexrec;
    x:longint;
    w2:windowrec;
begin
if (nofiles) then begin
        exit;
end;
filemode:=66;
x:=filesize(tff)-1;
setwindow2(w2,10,10,70,15,3,0,8,'Moving file(s)...','',TRUE);
window(11,11,69,14);
textcolor(7);
textbackground(0);
gotoxy(2,2);
write('Filename   :');
gotoxy(2,3);
write('To filebase:');
while (x>=0) do begin
        seek(tff,x);
        read(tff,nf);
        if (moved in nf.status) then begin
                loadfilebase(nf.mbase,2);
                window(11,11,69,14);
                gotoxy(15,2);
                textcolor(3);
                write(mln(nf.filename,12));
                gotoxy(15,3);
                textcolor(3);
                cwrite(mln(movf.name,40));
                current:=x+1;
                movefile(nf.filename);
                if (recordmoved) then deletefromindex(x);
        end;
        dec(x);
end;
removewindow(w2);
aremoved:=FALSE;
curread:=-1;
end;

procedure checkaretagged;
var nf:tindexrec;
    x:longint;
begin
if (nofiles) then begin
        exit;
end;
aretagged:=FALSE;
aredeleted:=FALSE;
aremoved:=FALSE;
while not(eof(tff)) and not((aretagged) and (aredeleted) and (aremoved)) do begin
        read(tff,nf);
        if (tagged in nf.status) then aretagged:=TRUE;
        if (deleted in nf.status) then aredeleted:=TRUE;
        if (moved in nf.status) then aremoved:=TRUE;
end;
end;

procedure converttags(d1,d2,m:boolean; mb:integer);
var nf:tindexrec;
begin
if (nofiles) then begin
        exit;
end;
seek(tff,0);
while not(eof(tff)) do begin
        read(tff,nf);
        if (tagged in nf.status) then begin
                if (d1) then begin
                        nf.status:=[deleted];
                        if (d2) then nf.status:=nf.status+[dfile];
                end;
                if (m) then begin
                        nf.status:=[moved];
                        nf.mbase:=mb;
                end;
        end;
        seek(tff,filepos(tff)-1);
        write(tff,nf);
end;
aretagged:=FALSE;
end;

begin
cursoron(FALSE);
height:=bry-(tly+3);
if (height<2) then exit;
        if (fbdirdlpath in curf.fbstat) then begin
                NXF.Init(adrv(curf.dlpath)+curf.filename+'.NFD', syst.nkeywords,syst.ndesclines);
        end else begin
                NXF.Init(adrv(systat.filepath)+curf.filename+'.NFD', syst.nkeywords,syst.ndesclines);
        end;
nofiles:=FALSE;
total:=NXF.Numfiles;
if (total=0) then begin
        nofiles:=TRUE;
end;
title:=cstr(curbase)+': '+copy(stripcolor(curf.name),1,30)+' ('+cstr(total)+' file'+aonoff((total=1),'','s')+')';
setwindow2(wind,TLX,TLY,BRX,BRY,tcolr,bcolr,boxtype,title,title2,shadow);
setupbottom;
current:=si;
top:=ti;
done:=false;
if (current>total) then current:=total;
if (top+height>total) and (top<>1) then top:=total-(height-1);
redrawdata;
lastscroll:=0;
if (total>height) then begin
    window(1,1,80,25);
    gotoxy(brx,tly+1);
    textcolor(tcolr);
    textbackground(bcolr);
    write('');
    for x:=(TLY+2) to (BRY-2) do begin
        gotoxy(brx,x);
        write('°');
    end;
    gotoxy(brx,bry-1);
    write('');
    window(TLX+1,TLY+1,BRX-1,BRY-1);
    writescrolldown;
end;
repeat
{setupbottom;}
if not(nofiles) then begin
gotoxy(2,(current-top)+2);
NXF.SeekFile(current);
NXF.ReadHeader;
showline2(current-1);
end;
while not(keypressed) do begin end;
c:=readkey;
case ord(c) of
        0:begin
                c:=readkey;
                checkkey(c);
                case ord(c) of
                        31:begin
                                gotoxy(2,(current-top)+2);
                                textcolor(7);
                                textbackground(0);
                                showline(current-1);
setwindow4(wind,TLX,TLY,BRX,BRY,8,bcolr,boxtype,title,title2,shadow);

                           gl:=pynqbox('Sort all filebases? ');
                           cd:=TRUE;
                           if (gl) then cd:=pynqbox('Sort CD-ROM filebases? ');
                           temps:=getsorttype;
                           if (temps<>'') then begin
                           window(1,1,80,25);
                           textcolor(14);
                           textbackground(0);
                           gotoxy(1,25);
                           clreol;
                           write('Sorting filebase');
                           if (gl) then write('s...') else write('...');
                           sort(curread,temps[2],gl,cd,(temps[1]='1'),TRUE);
                           buildindex(1);
                           end;
title:=cstr(curbase)+': '+copy(stripcolor(curf.name),1,30)+' ('+cstr(total)+' file'+aonoff((total=1),'','s')+')';
setwindow5(wind,TLX,TLY,BRX,BRY,tcolr,bcolr,boxtype,title,title2,shadow);
                           window(TLX+1,TLY+1,BRX-1,BRY-1);
                           setupbottom;
                           redrawdata;
if (total>height) then begin
    window(1,1,80,25);
    gotoxy(brx,tly+1);
    textcolor(tcolr);
    textbackground(bcolr);
    write('');
    for x:=(TLY+2) to (BRY-2) do begin
        gotoxy(brx,x);
        write('°');
    end;
    gotoxy(brx,bry-1);
    write('');
    window(TLX+1,TLY+1,BRX-1,BRY-1);
    writescrolldown;
end;
                           end;
                        34:begin
                                gotoxy(2,(current-top)+2);
                                textcolor(7);
                                textbackground(0);
                                showline(current-1);
setwindow4(wind,TLX,TLY,BRX,BRY,8,bcolr,boxtype,title,title2,shadow);
                           GetGlobal;
setwindow5(wind,TLX,TLY,BRX,BRY,tcolr,bcolr,boxtype,title,title2,shadow);
                           window(TLX+1,TLY+1,BRX-1,BRY-1);
                           buildindex(1);
                           setupbottom;
                           redrawdata;
                           end;
                        37:begin { Alt-K Recomment }
                                gotoxy(2,(current-top)+2);
                                textcolor(7);
                                textbackground(0);
                                showline(current-1);
setwindow4(wind,TLX,TLY,BRX,BRY,8,bcolr,boxtype,title,title2,shadow);
                           GetcommentType;
setwindow5(wind,TLX,TLY,BRX,BRY,tcolr,bcolr,boxtype,title,title2,shadow);
                           window(TLX+1,TLY+1,BRX-1,BRY-1);
                           setupbottom;
                           redrawdata;
                           end;
                        46:begin { Alt-C Convert }
                                gotoxy(2,(current-top)+2);
                                textcolor(7);
                                textbackground(0);
                                showline(current-1);
setwindow4(wind,TLX,TLY,BRX,BRY,8,bcolr,boxtype,title,title2,shadow);
                           GetconvertType;
setwindow5(wind,TLX,TLY,BRX,BRY,tcolr,bcolr,boxtype,title,title2,shadow);
                           window(TLX+1,TLY+1,BRX-1,BRY-1);
                           setupbottom;
                           redrawdata;
                           end;
                        68:begin
                                done:=TRUE;
                           end;
                        71:begin
                                if (current>1) and not(nofiles) then begin
                                gotoxy(2,(current-top)+2);
                                textcolor(7);
                                textbackground(0);
                                showline(current-1);
                                current:=1;
                                if (current<top) then begin
                                        top:=current;
                                        redrawdata;
                                end;
                                if (total>height) then writescrolldown;
                                end;
                        end;
                        73:begin
                                if (current>1) and not(nofiles) then begin
                                gotoxy(2,(current-top)+2);
                                textcolor(7);
                                textbackground(0);
                                showline(current-1);
                                if (current-height<1) then begin
                                        current:=1;
                                        top:=1;
                                        end else begin
                                                dec(current,height);
                                                if (top-height<1) then
                                                        top:=1
                                                else
                                                dec(top,height);
                                        end;
                                redrawdata;
                                if (total>height) then
                                writescrolldown;
                                end;
                        end;
                        79:begin
                                if (current<total) and not(Nofiles) then begin
                                gotoxy(2,(current-top)+2);
                                textcolor(7);
                                textbackground(0);
                                showline(current-1);
                                current:=total;
                                if (total-(height)>0) then top:=total-(height-1) else
                                        top:=1;
                                redrawdata;
                                if (total>height) then writescrolldown;
                                end;
                        end;
                        81:begin
                                if (current<total) and not(nofiles) then begin
                                gotoxy(2,(current-top)+2);
                                textcolor(7);
                                textbackground(0);
                                showline(current-1);
                                if (current+height>total) then begin
                                        current:=total;
                                        top:=total-(height-1);
                                        if (top<1) then top:=1;
                                        end else begin
                                inc(current,height);
                                inc(top,height);
                                if (top+height>total) then top:=total-(height-1);
                                end;
                                redrawdata;
                                if (total>height) then writescrolldown;
                                end;
                        end;
                        82:begin
                                if not(nofiles) then begin
                                gotoxy(2,(current-top)+2);
                                textcolor(7);
                                textbackground(0);
                                showline(current-1);
                                end;
setwindow4(wind,TLX,TLY,BRX,BRY,8,bcolr,boxtype,title,title2,shadow);
                                addfiles(TRUE);
{                                if not(nofiles) then close(ff); }
                                buildindex(1);
(*                                {$I-} reset(ff); {$I+}
                                if (ioresult<>0) then begin
                                        displaybox('Error re-reading filebase!',4000);
                                        exit; 
                                end; *)
title:=cstr(curbase)+': '+copy(stripcolor(curf.name),1,30)+' ('+cstr(total)+' file'+aonoff((total=1),'','s')+')';
setwindow5(wind,TLX,TLY,BRX,BRY,tcolr,bcolr,boxtype,title,title2,shadow);
                                window(TLX+1,TLY+1,BRX-1,BRY-1);
                                setupbottom;
                                if not(nofiles) then begin
                                redrawdata;
                                end;
if (total>height) then begin
    window(1,1,80,25);
    gotoxy(brx,tly+1);
    textcolor(tcolr);
    textbackground(bcolr);
    write('');
    for x:=(TLY+2) to (BRY-2) do begin
        gotoxy(brx,x);
        write('°');
    end;
    gotoxy(brx,bry-1);
    write('');
    window(TLX+1,TLY+1,BRX-1,BRY-1);
    writescrolldown;
end;
                           end;
                        83:begin
                                if not(nofiles) then begin
                                gotoxy(2,(current-top)+2);
                                textcolor(7);
                                textbackground(0);
                                showline(current-1);
                                setwindow4(wind,TLX,TLY,BRX,BRY,8,bcolr,boxtype,title,title2,shadow);
                                if (aretagged) then begin
                                        if pynqbox('Delete selected file records? ') then begin
                                        aredeleted:=TRUE;
                                        if pynqbox('Delete files also? ') then begin
                                                converttags(TRUE,TRUE,FALSE,x);
                                        end else begin
                                                converttags(TRUE,FALSE,FALSE,x);
                                        end;
                                        window(TLX+1,TLY+1,BRX-1,BRY-1);
                                        redrawdata;
                                        end;
                                end else
                                if (checkindex(current-1,3,x)) then begin
                                        displaybox('File is tagged to be moved to another base.',3000);
                                        window(TLX+1,TLY+1,BRX-1,BRY-1);
                                end else
                                if (checkindex(current-1,1,x)) then begin
                                        if pynqbox('Remove deletion flag from file? ') then begin
                                                setindex(current-1,FALSE,FALSE,FALSE,FALSE,x);
                                        end;
                                        window(TLX+1,TLY+1,BRX-1,BRY-1);
                                        redrawdata;
                                end else
                                if pynqbox('Delete file record for '+allcaps(NXF.Fheader.filename)+'? ') then begin
                                        aredeleted:=TRUE;
                                        setindex(current-1,TRUE,FALSE,FALSE,FALSE,x);
                                        if pynqbox('Delete file also? ') then begin
                                                setindex(current-1,TRUE,TRUE,FALSE,FALSE,x);
                                        end;
                                        window(TLX+1,TLY+1,BRX-1,BRY-1);
                                        redrawdata;
                                end;
                                window(1,1,80,25);
title:=cstr(curbase)+': '+copy(stripcolor(curf.name),1,30)+' ('+cstr(total)+' file'+aonoff((total=1),'','s')+')';
setwindow5(wind,TLX,TLY,BRX,BRY,tcolr,bcolr,boxtype,title,title2,shadow);
                                window(TLX+1,TLY+1,BRX-1,BRY-1);
                                setupbottom;
                                end;
                        end;
                        50:begin
                                if not(nofiles) then begin
                                gotoxy(2,(current-top)+2);
                                textcolor(7);
                                textbackground(0);
                                showline(current-1);
                                cur2:=1;
                                top2:=1;
                                setwindow4(wind,TLX,TLY,BRX,BRY,8,bcolr,boxtype,title,title2,shadow);
                                tempx:=getfbase(cur2,top2,2,'Move file to...');
                                if (tempx<>-1) then begin
                                        aremoved:=TRUE;
                                        if (aretagged) then begin
                                                converttags(FALSE,FALSE,TRUE,tempx);
                                        end else begin
                                                setindex(current-1,FALSE,FALSE,TRUE,FALSE,tempx);
                                        end;
                                        window(TLX+1,TLY+1,BRX-1,BRY-1);
                                        redrawdata;
                                end;
                                window(1,1,80,25);
                                setupbottom;
title:=cstr(curbase)+': '+copy(stripcolor(curf.name),1,30)+' ('+cstr(total)+' file'+aonoff((total=1),'','s')+')';
setwindow5(wind,TLX,TLY,BRX,BRY,tcolr,bcolr,boxtype,title,title2,shadow);
                                window(TLX+1,TLY+1,BRX-1,BRY-1);
                                setupbottom;
                                end;
                           end;
                        72:begin {UP}
                                if (current>1) and not(nofiles) then begin
                                gotoxy(2,(current-top)+2);
                                textcolor(7);
                                textbackground(0);
                                showline(current-1);
                                dec(current);
                                if (current<top) then begin
                                        top:=current;
                                        upkey;
                                end;
                                if (total>height) then
                                writescrolldown;
                                end;
                        end;
                        80:begin
                                if (current<total) and not(nofiles) then begin
                                gotoxy(2,(current-top)+2);
                                textcolor(7);
                                textbackground(0);
                                showline(current-1);
                                inc(current);
                                if ((current-top)+1>height) then begin
                                        top:=top+1;
                                        downkey;
                                end;
                                if (total>height) then writescrolldown;
                                end;
                        end;
                end;
        end;
(*              ord('0')..ord('9'):begin

  setwindow(w2,29,12,52,14,3,0,8,'',TRUE);
  gotoxy(2,1);
  textcolor(7);
  textbackground(0);
  write('Goto number  : ');
  gotoxy(17,1);
  s:=c;
  infield_inp_fgrd:=15;
  infield_inp_bkgd:=1;
  infield_out_fgrd:=3;
  infield_out_bkgd:=0;
  infield_allcaps:=false;
  infield_numbers_only:=TRUE;
  infield_escape_zero:=FALSE;
  infield_escape_blank:=TRUE;
  infield_putatend:=TRUE;
  infield_clear:=FALSE;
  infield_insert:=TRUE;
  infielde(s,5);
  infield_escape_blank:=FALSE;
  infield_putatend:=FALSE;
  infield_clear:=TRUE;
  infield_insert:=TRUE;
  ii4:=value(s);
  if ((ii4>=0) and (ii4<=total)) and (s<>'') then begin
  ii5:=current;
  current:=ii4+listbox_goto_offset;
  top:=ii4+listbox_goto_offset;
  if (top+height>total) then top:=total-(height-1);
  if (ii4+listbox_goto_offset>ii5) then begin
        if (total>height) then writescrolldown;
  end else begin
        if (total>height) then writescrolldown;
  end;
  end;
  removewindow(w2);
  window(TLX+1,TLY+1,BRX-1,BRY-1);
  redrawdata;
                        end; *)
        13:if not(nofiles) then begin
                editfile;
                window(TLX+1,TLY+1,BRX-1,BRY-1);
                { edit file }
            end;
        32:begin
                if (checkindex(current-1,1,x)) then begin
                        displaybox('File is flagged for deletion.',3000);
                        window(TLX+1,TLY+1,BRX-1,BRY-1);
                end else
                if (checkindex(current-1,3,x)) then begin
                        displaybox('File is flagged for move to another base.',3000);
                        window(TLX+1,TLY+1,BRX-1,BRY-1);
                end else begin
                if (checkindex(current-1,4,x)) then begin
                        setindex(current-1,FALSE,FALSE,FALSE,FALSE,x);
                        checkaretagged;
                        window(TLX+1,TLY+1,BRX-1,BRY-1);
                end else begin
                        aretagged:=TRUE;
                        setindex(current-1,FALSE,FALSE,FALSE,TRUE,x);
                        window(TLX+1,TLY+1,BRX-1,BRY-1);
                end;
                                if (current<total) and not(nofiles) then begin
                                gotoxy(2,(current-top)+2);
                                textcolor(7);
                                textbackground(0);
                                showline(current-1);
                                inc(current);
                                if ((current-top)+1>height) then begin
                                        top:=top+1;
                                        downkey;
                                end;
                                if (total>height) then writescrolldown;
                                end;
                 end;
           end;
        27:begin
                done:=TRUE;
        end;
end;
until (done);
if (aredeleted) then aredeleted:=pynqbox('Delete records/files tagged for deletion? ');
if (aredeleted) then purgefiles;
if (aremoved) then aremoved:=pynqbox('Move records/files tagged for move? ');
if (aremoved) then moveallfiles;
if (aretagged) then converttags(FALSE,FALSE,FALSE,0);
setwindow4(wind,TLX,TLY,BRX,BRY,8,0,boxtype,title,title2,shadow);
textcolor(7);
textbackground(0);
hback:=255;
ti:=top;
si:=current;
NXF.Done;
end;


end.

{$A+,B+,D-,E+,F+,I+,L+,N-,O+,R-,S+,V-}
unit file5;

interface

uses
  crt, dos, file0, file1, file2, file4, file8, file9, file11,
  common, execbat, file25;

procedure minidos;
procedure newfiles(b:integer; var abort,next:boolean);
procedure gnfiles;
procedure nf(mstr:astr);
procedure search;


implementation

uses archive1, file6,myio3,doors, file12, tagunit,mkstring,runprog,script;
  
  

var
  xword:array[1..9] of astr;

procedure parse(s:astr);
var i,j,k:integer;
begin
  for i:=1 to 9 do xword[i]:='';
  i:=1; j:=1; k:=1;
  if (length(s)=1) then xword[1]:=s;
  while (i<length(s)) do begin
    inc(i);
    if ((s[i]=' ') or (length(s)=i)) then begin
      if (length(s)=i) then inc(i);
      xword[k]:=copy(s,j,(i-j));
      j:=i+1;
      inc(k);
    end;
  end;
end;

procedure minidos;
var curdir,s,s1:astr;
    abort,next,done,restr,nocmd,nospace:boolean;
{    af:file of filearcinforec;
    a:filearcinforec; }
    wasrestr:boolean;

  procedure versioninfo;
  begin
    print(stripcolor(verline(1)));
    print(stripcolor(verline(2)));
    print(stripcolor(verline(3)));
    nl;
    print('SymSys<tm> Simulated Command Interpreter v'+ver);
    nl;
    nl;
  end;

  procedure docmd(cmd:astr);
  var fi:file of byte;
      f:file;
      ps,ns,es,op,np:astr;
      s1,s2,s3:astr;
      numfiles,tsiz:longint;
      retlevel,i,j:integer;
      b,b2,ok:boolean;

    function restr1:boolean;
    begin
      restr1:=restr;
      if (restr) then wasrestr:=TRUE;
    end;

    procedure helpscreen(b:byte);
    begin
    cls;
    versioninfo;
    case b of
        1:begin {main help}
                sprint('Condensed Command Help - Type HELP [command] for more information.');
                nl;
                sprint('%100%DIR        %070%Display current directory contents');
                sprint('%100%CD | CHDIR %070%Change to specified directory');
                sprint('%100%RD | RMDIR %070%Remove specified directory');
                sprint('%100%MD | MKDIR %070%Create specified directory');
                sprint('%100%TYPE       %070%Display contents of specified display file');
                sprint('%100%RUN        %070%Run the specified Nexecutable');
                sprint('%100%SEND       %070%Send specified file to remote system');
                sprint('%100%COPY       %070%Copy specified file(s) to new location');
                sprint('%100%MOVE       %070%Move specified file(s) to new location');
                sprint('%100%DEL[ETE]   %070%Delete specified file');
                sprint('%100%REN[AME]   %070%Rename specified file to new filename');
                sprint('%100%CLS        %070%Clear current display screen');
                nl;
          end;
        2:begin {dir help}
                sprint('DIR [drive:][path][filename] [/W]');
                nl;
                sprint('Displays a list of files and subdirectories in a directory.');
                nl;
                sprint('  [drive:][path][filename]');
                sprint('              Specifies drive, directory, and/or files to list.');
                sprint('              (Could be enhanced file specification or multiple filespecs.)');
                nl;
                sprint('  /W          Uses wide list format.');
                nl;
          end;
        3:begin {CD help}
                sprint('CHDIR [drive:][path]');
                sprint('CHDIR[..]');
                sprint('CD [drive:][path]');
                sprint('CD[..]');
                nl;
                sprint('Displays the name of or changes the current directory.');
                nl;
                sprint('  ..   Specifies that you want to change to the parent directory.');
                nl;
                sprint('Type CD drive: to display the current directory in the specified drive.');
                sprint('Type CD without parameters to display the current drive and directory.');
                nl;
          end;
        end;
    end;

  begin
    wasrestr:=FALSE;
    abort:=FALSE; next:=FALSE; nocmd:=FALSE;
    for i:=1 to 9 do xword[i]:=allcaps(xword[i]);
    s:=xword[1];
    if ((pos('\',xword[2])<>0) or (pos('..',xword[2])<>0)) and
       (restr) then exit;

    if (s='DIR/W') then s:='DIR *.* /W';
    if (s='?') or (s='HELP') then begin
        if (xword[2]='') then helpscreen(1) else
        if (xword[2]='DIR') then helpscreen(2) else
        if (xword[2]='CD') or (xword[2]='CHDIR') then helpscreen(3);
    end
    else
    if (s='EXIT') or (s='QUIT') then done:=TRUE
    else
    if (s='RUNNXE') then begin
        runprogram(fexpand(xword[2]));
    end else
    if (s='RUN') then begin
        doscript(fexpand(xword[2]),'');
    end else
    if ((s='DEL') or (s='DELETE')) and (not restr1) then begin
      if ((not exist(xword[2])) and (not iswildcard(xword[2]))) or
         (xword[2]='') then
        print('File not found ['+xword[2]+'].')
      else begin
        xword[2]:=fexpand(xword[2]);
        ffile(xword[2]);
        repeat
          if not ((dirinfo.attr and VolumeID=VolumeID) or
                  (dirinfo.attr and Directory=Directory)) then begin
            assign(f,dirinfo.name);
            {$I-} erase(f); {$I+}
            if (ioresult<>0) then
              print('Could not delete ['+dirinfo.name+'].');
          end;
          nfile;
        until (not found) or (hangup);
      end;
    end
    else
    if (s='TYPE') then begin
      printf(fexpand(xword[2]));
      if (nofile) then print('File not found.');
    end
    else
    if ((s='REN') or (s='RENAME')) then begin
      if ((not exist(xword[2])) and (xword[2]<>'')) then
        print('File not found.')
      else begin
        xword[2]:=fexpand(xword[2]);
        assign(f,xword[2]);
        {$I-} rename(f,xword[3]); {$I+}
        if (ioresult<>0) then print('File not found.');
      end
    end
    else
    if (s='DIR') then begin
      b:=TRUE;
      b2:=TRUE;
      for i:=2 to 9 do begin
        if (length(xword[i])>=2) then
        case xword[i][1] of
                '/','-':begin
                                case xword[i][2] of
                                '?','H':begin
                                                helpscreen(2);
                                                b2:=FALSE;
                                        end;
                                    'W':begin
                                                b:=FALSE;
                                                xword[i]:='';
                                        end;
                                end;
                        end;
                    '?':begin
                        helpscreen(2);
                        b2:=FALSE;
                        end;
        end;
      end;
      if (b2) then begin
      if (xword[2]='') then xword[2]:='*.*';
      s1:=curdir;
      xword[2]:=fexpand(xword[2]);
      fsplit(xword[2],ps,ns,es);
      s1:=ps; s2:=ns+es;
      if (s2='') then s2:='*.*';
      if (not iswildcard(xword[2])) then begin
        ffile(xword[2]);
        if ((found) and (dirinfo.attr=directory)) or
           ((length(s1)=3) and (s1[3]='\')) then begin   {* root directory *}
          s1:=bslash(TRUE,xword[2]);
          s2:='*.*';
        end;
      end;
      nl; dir(s1,s2,b); nl;
      end;
    end
    else
    if (s='CD') and (xword[2]='') then begin
        sprint(curdir);
        nl;
    end else
    if ((((s='CD') or (s='CHDIR')) and (xword[2]<>'')) or
        (copy(s,1,3)='CD\') or (copy(s,1,4)='CD..')) and not(restr1) then begin
                if (copy(s,1,3)='CD\') then xword[2]:=copy(s,3,length(s)-2);
                if (copy(s,1,4)='CD..') then xword[2]:=copy(s,3,length(s)-2);
                if (xword[2][2]=':') and (length(xword[2])=2) then begin
                        getdir(ord(xword[2][1])-64,s);
                        sprint(s);
                end else begin
                if (xword[2]='/?') or (xword[2]='-?') or (xword[2]='?') or
                   (xword[2]='/H') or (xword[2]='-H') then helpscreen(3) else
                begin
                xword[2]:=fexpand(xword[2]);
                if (copy(xword[2],length(xword[2]),1)='\') and (not(copy(xword[2],2,2)=':\') and
                        not(length(xword[2])=3)) then xword[2]:=copy(xword[2],1,length(xword[2])-1);
                {$I-} chdir(xword[2]); {$I+}
                if (ioresult<>0) then print('Invalid directory');
                nl;
                end;
                end;
    end else
    if ((s='MD') or (s='MKDIR')) and (xword[2]<>'') and (not restr1) then begin
      {$I-} mkdir(xword[2]); {$I+}
      if (ioresult<>0) then print('Unable to create directory.');
    end
    else
    if ((s='RD') or (s='RMDIR')) and (xword[2]<>'') and (not restr1) then begin
      {$I-} rmdir(xword[2]); {$I+}
      if (ioresult<>0) then print('Unable to remove directory.');
    end
    else
    if (s='COPY') and (not restr1) then begin
      if (xword[2]<>'') then begin
        if (iswildcard(xword[3])) then
          print('Wildcards not allowed in destination parameter!')
        else begin
          if (xword[3]='') then xword[3]:=curdir;
          xword[2]:=bslash(FALSE,fexpand(xword[2]));
          xword[3]:=fexpand(xword[3]);
          ffile(xword[3]);
          b:=((found) and (dirinfo.attr and directory=directory));
          if ((not b) and (copy(xword[3],2,2)=':\') and
              (length(xword[3])=3)) then b:=TRUE;

          fsplit(xword[2],op,ns,es);
          op:=bslash(TRUE,op);

          if (b) then
            np:=bslash(TRUE,xword[3])
          else begin
            fsplit(xword[3],np,ns,es);
            np:=bslash(TRUE,np);
          end;

          j:=0;
          abort:=FALSE; next:=FALSE;
          ffile(xword[2]);
          while (found) and (not abort) and (not hangup) do begin
            if (not ((dirinfo.attr=directory) or (dirinfo.attr=volumeid))) then
            begin
              s1:=op+dirinfo.name;
              if (b) then s2:=np+dirinfo.name else s2:=np+ns+es;
              prompt(s1+' -> '+s2+' :');
              copyfile(ok,nospace,TRUE,s1,s2);
              if (ok) then begin
                inc(j);
                nl;
              end else
                if (nospace) then sprompt('%120% - Insufficient space')
                else sprompt('%120% - Copy failed');
              nl;
            end;
            if (not empty) then wkey(abort,next);
            nfile;
          end;
          if (j<>0) then begin
            prompt('  '+cstr(j)+' file');
            if (j<>1) then prompt('s');
            print(' copied.');
          end;
        end;
      end;
    end
    else
    if (s='MOVE') and (not restr1) then begin
      print('nxMOVE v'+ver);
      nl;
      if (xword[2]<>'') then begin
        if (iswildcard(xword[3])) then
          print('Wildcards not allowed in destination parameter!')
        else begin
          if (xword[3]='') then xword[3]:=curdir;
          if (xword[2]='/?') or (xword[2]='-?') then begin
                print('Syntax:    Move [drive:][path]Source [drive:][path][Destination]');
                nl;
                abort:=true;
                end;
          xword[2]:=bslash(FALSE,fexpand(xword[2]));
          xword[3]:=fexpand(xword[3]);
          ffile(xword[3]);
          b:=((found) and (dirinfo.attr and directory=directory));
          if ((not b) and (copy(xword[3],2,2)=':\') and
              (length(xword[3])=3)) then b:=TRUE;

          fsplit(xword[2],op,ns,es);
          op:=bslash(TRUE,op);

          if (b) then
            np:=bslash(TRUE,xword[3])
          else begin
            fsplit(xword[3],np,ns,es);
            np:=bslash(TRUE,np);
          end;

          j:=0;
          abort:=FALSE; next:=FALSE;
          ffile(xword[2]);
          while (found) and (not abort) and (not hangup) do begin
            if (not ((dirinfo.attr=directory) or (dirinfo.attr=volumeid))) then
            begin
              s1:=op+dirinfo.name;
              if (b) then s2:=np+dirinfo.name else s2:=np+ns+es;
              prompt(s1+' to '+s2+' ');
              movefile(ok,nospace,FALSE,s1,s2);
              if (ok) then begin
                inc(j);
                print('û');
              end else
                if (nospace) then print('Low Space')
                else print('Fail');
            end;
            if (not empty) then wkey(abort,next);
            nfile;
          end;
          if (j<>0) then begin
            prompt(cstr(j)+' File');
            if (j<>1) then prompt('s');
            print(' Moved.');
          end;
          nl;print('Finished!');nl;
        end;
      end else begin
        print('Syntax:    Move [drive:][path]Source [drive:][path][Destination]');
        nl;
        end;
    end
    else
    if (s='CLS') then cls
    else
    if (length(s)=2) and (s[1]>='A') and (s[1]<='Z') and
       (s[2]=':') and (not restr1) then begin
      {$I-} getdir(ord(s[1])-64,s1); {$I+}
      if (ioresult<>0) then print('Invalid drive.')
      else begin
        {$I-} chdir(s1); {$I+}
        if (ioresult<>0) then begin
          print('Invalid drive.');
          chdir(curdir);
        end;
      end;
    end
(*    else
    if (s='APS') and (not restr1) then begin
      if (xword[2]='') then begin
        nl;
        print('APS 1.00 - Archive Processing System');
        print('(c) Copyright 1996 Epoch Software.  All rights reserved.');
        nl;
        print('Syntax:  APS [/C] [Filename] [New Extension]');
        nl;
        print('Options:');
        nl;
        print('         /C  =  Converts to [New Extention]');
        nl;
        print('         APS [Filename] will list files contained in archive.');
        nl;
        print('Internal Archive formats supported:');
        nl;
        print('   ZIP, LZH, ARC, ZOO');
        nl;
        print('External Archivers also supported.');
      end else begin

    if (xword[2]='/C') then begin
      if (not exist(xword[3])) or (xword[3]='') then print('File not found.')
        else begin
          i:=arctype(xword[3]);
          if (i=0) then invarc
          else begin
            s3:=xword[4]; s3:=copy(s3,length(s3)-2,3);
            j:=arctype('FILENAME.'+s3);
            fsplit(xword[3],ps,ns,es);
            assign(af,adrv(systat^.gfilepath)+'ARCHIVER.DAT');
            {$I-} reset(af); {$I+}
            if (ioresult<>0) then begin
                sprint('%120%Error opening ARCHIVER.DAT.');
            end else begin
            if (j>filesize(af)-1) then begin
                sprint('%120%Error finding archiver.');
            end else begin
            if (length(xword[4])<=3) and (j<>0) then begin
                seek(af,j);
                read(af,a);
                close(af);
              s3:=ps+ns+'.'+a.ext;
            end else
              s3:=xword[4];
            if (j=0) then invarc
            else begin
              ok:=TRUE;
              conva(ok,i,j,newtemp,sqoutsp(fexpand(xword[3])),
                    sqoutsp(fexpand(s3)));
              if (ok) then begin
                assign(fi,sqoutsp(fexpand(xword[3])));
                {$I-} erase(fi); {$I+}
                if (ioresult<>0) then
                  sprint('%090%Unable to delete original: %120%'+
                       sqoutsp(fexpand(xword[3])));
              end else
                sprint('%120%Conversion unsuccessful.');
            end;
            end;
            end;
          end;
        end;
      end
     else
        begin
        s1:=xword[2];
        if (pos('.',s1)=0) then s1:=s1+'*.*';
        lfi(s1,abort,next);
      end;
    end;
    end*) else
    if (s='SEND') and (xword[2]<>'') then begin
      if exist(xword[2]) then unlisted_download(fexpand(xword[2]))
        else print('File not found.');
    end
    else
    if (s='VER') then versioninfo
    else
    if (s='FORMAT') then begin
      nl;
      print('Formatting of Disk Drives is not allowed in SymSys(tm).');
      nl;
    end else
    if (s='DIRSIZE') then begin
      nl;
      if (xword[2]='') then print('Needs a parameter.')
      else begin
        numfiles:=0; tsiz:=0;
        ffile(xword[2]);
        while (found) do begin
          inc(tsiz,dirinfo.size);
          inc(numfiles);
          nfile;
        end;
        if (numfiles=0) then print('No files found!')
          else print('"'+allcaps(xword[2])+'": '+cstrl(numfiles)+' files, '+
                     cstrl(tsiz)+' bytes.');
      end;
      nl;
    end
    else
    if (s='DISKFREE') then begin
      if (xword[2]='') then j:=exdrv(curdir) else j:=exdrv(xword[2]);
      nl;
      print(cstrl(freek(j)*1024)+' bytes free on '+chr(j+64)+':');
      nl;
    end
    else
    if (s='EXT') and (not restr1) then begin
      s1:=cmd;
      j:=pos('EXT',allcaps(s1))+3; s1:=copy(s1,j,length(s1)-(j-1));
      while (copy(s1,1,1)=' ') do s1:=copy(s1,2,length(s1)-1);
      if ((incom) or (outcom)) then
        s1:=s1+' >'+systat^.remdevice+' <'+systat^.remdevice;
      if (length(s1)>127) then begin nl; print('Command too long!'); nl; end
      else
        if allcaps(copy(s1,1,6))='FORMAT' then begin
                nl; print('FORMAT may not be used in SymSys(tm).');nl; end else
        currentswap:=modemr^.swapdoor;
        shelldos(TRUE,s1,retlevel);
        currentswap:=0;
    end
(*    else
    if ((s='UNARC') or (s='UNZIP') or (s='ARJ E') or (s='ARJ X') or (s='RAR E') or (s='RAR X') or (s='RAR') or
       (s='PKXARC') or (s='PKUNPAK') or (s='PKUNZIP')) and (not restr1) then begin
      if (xword[2]='') then begin
        nl;
        print(s+' - Nexus Archive De-Compression Command.');
        nl;
        print('Syntax:   '+s+' [Filename] [Archive Filespecs]');
        nl;
        print('The archive type can be ANY archive format which has been');
        print('configured into Nexus via NxSetup.');
        nl;
      end else begin
        i:=arctype(xword[2]);
        assign(af,adrv(systat^.gfilepath)+'ARCHIVER.DAT');
        {$I-} reset(af); {$I+}
        if (ioresult<>0) then begin
            sprint('%120%Error Opening ARCHIVER.DAT.');
            i:=0;
        end else begin
           if (i>filesize(af)-1) then begin
                sprint('%120%Error Finding Archiver.');
                i:=0;
        end;
        end;
        if (not exist(xword[2])) then print('File not found.') else
          if (i=0) then invarc
          else begin
            seek(af,i);
            read(af,a);
            close(af);
            s3:='';
            if (xword[3]='') then s3:=' *.*'
            else
              for j:=3 to 9 do
                if (xword[j]<>'') then s3:=s3+' '+fexpand(xword[j]);
            s3:=copy(s3,2,length(s3)-1);
            shel1;
            pexecbatch(TRUE,'nextemp1.bat','',bslash(TRUE,curdir),
                       arcmci(a.unarcline,fexpand(xword[2]),s3),
                       retlevel);
            shel2;
            inuserwindow;
          end;
      end;
    end
    else
    if ((s='ARC') or (s='ZIP') or (s='ARJ A') or (s='RAR A') or (s='RAR') or
       (s='PKARC') or (s='PKPAK') or (s='PKZIP')) and (not restr1) then begin
      if (xword[2]='') then begin
        nl;
        print(s+' - Nexus Archive Compression Command.');
        nl;
        print('Syntax:   '+s+' [Archive-name] [Archive Filespecs]');
        nl;
        print('The archive type can be ANY archive format which has been');
        print('configured into Nexus via System Configuration.');
        nl;
      end else begin
        i:=arctype(xword[2]);
        assign(af,adrv(systat^.gfilepath)+'ARCHIVER.DAT');
        {$I-} reset(af); {$I+}
        if (ioresult<>0) then begin
            sprint('%120%Error Opening ARCHIVER.DAT.');
            i:=0;
        end else begin
           if (i>filesize(af)-1) then begin
                sprint('%120%Error Finding Archiver.');
                i:=0;
        end;
        end;
        if (i=0) then invarc
        else begin
          seek(af,i);
          read(af,a);
          close(af);
          s3:='';
          if (xword[3]='') then s3:=' *.*'
          else
            for j:=3 to 9 do
              if (xword[j]<>'') then s3:=s3+' '+fexpand(xword[j]);
          s3:=copy(s3,2,length(s3)-1);
          shel1;
          pexecbatch(TRUE,'nextemp1.bat','',bslash(TRUE,curdir),
                     arcmci(a.arcline,fexpand(xword[2]),s3),
                     retlevel);
          shel2;
        end;
      end;
    end *) else begin
      nocmd:=TRUE;
      if (s<>'') then
        if (not wasrestr) then print('Invalid command or file name.')
        else print('Restricted command.');
    end;
  end;

begin
  chdir(bslash(FALSE,adrv(systat^.afilepath)));
  restr:=(not cso);
  done:=FALSE;
  cls;
  print('Type "Exit" to return to Nexus.');
  nl;
  versioninfo;
  if (restr) then begin
    print('Only *.TXT and *.ANS files may be modified.');
    print('Activity restricted to '+allcaps(adrv(systat^.afilepath))+' only.');
    nl;
  end;
  repeat
    getdir(0,curdir);
    sprompt('%070%'+curdir+'>');
    inputl(s1,128);
    parse(s1);
    if (s1<>'') then begin
        sl1('s','SymSys: '+s1);
        docmd(s1);
        if (s1<>'') and not(nocmd) then
                if (not wasrestr) then sl1('s','SymSys: Invalid command or file name.')
                else sl1('s','SymSys: Restricted command.');
    end;
  until (done) or (hangup);
  chdir(start_dir);
end;

procedure newfiles(b:integer; var abort,next:boolean);
var lns,oldboard,pl,rn:integer;
begin
  oldboard:=fileboard;
  if (fileboard<>b) then changefileboard(b);
  if (fileboard=b) then begin
    fiscan(pl);
    sprompt(gstring(451));
    if (badfpath) then begin
        sprompt(gstring(452));
        lil:=0;
        exit;
    end;
    rn:=1;
    next:=browse(-1,'','','',1,abort);
    if not(next) then sprompt(gstring(452));
    lil:=0;
  end;
  fileboard:=oldboard;
end;

procedure gnfiles;
var i,x:integer;
    abort,next,n2:boolean;
    oldboard:integer;
    displayed,dstring:boolean;
    UTAG:^TagRecordOBJ;
begin
  oldboard:=fileboard;
  dstring:=TRUE;
  displayed:=FALSE;
  sl1('+','Global NewScan of File Bases');
  i:=0;
  abort:=FALSE; next:=FALSE;
  sprompt(gstring(450));
  n2:=FALSE;
  new(UTAG);
  if (UTAG=NIL) then begin
        sprint('%120%Unable to allocate memory to complete scan.');
        exit;
  end;
  UTAG^.Init(adrv(systat^.userpath)+hexlong(thisuser.userid)+'\'+hexlong(thisuser.userid)+'.NFT');
  UTAG^.MaxBases:=Maxulb;
  i:=(UTAG^.GetFirst(adrv(systat^.gfilepath)+'USER'+cstrn(cnode)+'.TFT'));
  while (i<>-1) and not(abort) and not(hangup) do begin
    if (infconf(i)) then begin
            if (fileboard<>i) then changefileboard(i);
            if ((i=fileboard) and (aacs(memuboard.acs))) then begin
                        newfiles(i,abort,n2);
            end;
    end;
    i:=(UTAG^.GetNext);
    wkey(abort,next);
    if (next) then begin abort:=FALSE; next:=FALSE; end;
  end;
  sprompt(gstring(455));
  fileboard:=oldboard;
end;

procedure nf(mstr:astr);
var bn:integer;
    abort,next:boolean;
    instr:string;
    which:integer;
    scanned:boolean;
    oldfconf:byte;
    c:char;
    x:integer;
begin
  abort:=FALSE; next:=FALSE;
  lil:=0;
  if (allcaps(copy(mstr,1,1))='D') then begin
        mstr:=copy(mstr,2,length(mstr));
        pointdate;
  end;
  if (mstr='C') then newfiles(board,abort,next)
  else if (copy(mstr,1,1)='G') then begin
        scanned:=FALSE;
        if (length(mstr)>1) then begin
        if (mstr[2]='C') then begin
                scanned:=TRUE;
                gnfiles;
        end;
        if (mstr[2]='A') then begin
                oldfconf:=fconf;
                fconf:=0;
                gnfiles;
                fconf:=oldfconf;
                scanned:=TRUE;
        end;
        end;
        if not(scanned) then begin
    sprompt(gstring(456));
    sprompt(gstring(458));
    sprompt(gstring(459));
    sprompt(gstring(460));
    instr:=allcaps(gstring(461));
    if (length(instr)<3) then instr:='CAQ';
    instr:=instr+^M;
    onek(c,instr);
    which:=pos(c,instr);
    case which of
           1,4:begin
                 gnfiles;
               end;
             2:begin
                oldfconf:=fconf;
                fconf:=0;
                gnfiles;
                fconf:=oldfconf;
            end;
    end;
        end;
  end
  else if (value(mstr)<>0) then newfiles(value(mstr),abort,next)
  else begin
    sprompt(gstring(456));
    sprompt(gstring(457));
    sprompt(gstring(458));
    sprompt(gstring(459));
    sprompt(gstring(460));
    instr:=allcaps(gstring(462));
    if (length(instr)<4) then instr:='CATQ';
    instr:=instr+^M;
    onek(c,instr);
    which:=pos(c,instr);
    case which of
           1,5:begin
                gnfiles;
               end;
             3:begin
               newfiles(fileboard,abort,next);
               end;
             2:begin
               oldfconf:=fconf;
               fconf:=0;
               gnfiles;
               fconf:=oldfconf;
               end;
          end;
  end;
  newdate:=datelong;
  thisuser.filescandate:=u_daynum(datelong);
end;

procedure search;
var fn:astr;
    kw:astr;
    dta,kw2:astr;
    c:char;
    oldfconf:byte;
    oldboard,bn:integer;
    bs:byte;
    n2,start,quit,abort,next:boolean;

function showbase:string;
begin
case bs of
        1:showbase:='%150%This Base';
        2:showbase:='%150%Current Conference';
        3:showbase:='%150%All Conferences';
end;
end;

begin
  dta:='00/00/00';
  oldboard:=fileboard;
  fn:='*.*';
  kw:='';
  bs:=1;
  quit:=false;
  start:=false;
  repeat
  if (kw<>'') then kw2:=kw else kw2:='None';
  sprompt(gstring(470));
  sprint('%080%[%150%F%080%] %030%Filemask       : %150%'+fn);
  sprint('%080%[%150%K%080%] %030%Keyword        : %150%'+kw2);
  sprompt('%080%[%150%D%080%] %030%Date           : ');
  if (dta='00/00/00') then sprint('%150%All') else sprint('%150%'+dta);
  sprint('%080%[%150%B%080%] %030%Scan Selection : '+showbase);
  nl;
  sprompt(gstring(475));
  onek(c,'FKDSBQ'^M);
  case c of
        'F':begin
            sprompt('%030%File Mask: %150%');
            if (fn='') then defaultst:='*.*'
            else defaultst:=fn;
            inputd(fn,12);
            if (pos('.',fn)=0) then fn:=fn+'.';
            end;
        'K':begin
                sprompt('%030%Keyword  : %150%');
                defaultst:=kw;
                inputd(kw,20);
            end;
        'D':begin 
                sprompt('%030%Date     : %150%');
                getbirth(dta,false);
                if lenn(dta)<8 then dta:='00/00/00';
           end;
        'S':begin start:=true; quit:=true; end;
        'B':begin
                inc(bs);
                if (bs=4) then bs:=1;
            end;
        'Q':quit:=true;
  end;
  until (quit);
  if (start) then begin
  if (bs in [2,3]) then begin
  cls;
  if (bs=3) then begin
  oldfconf:=fconf;
  fconf:=0;
  end;
  bn:=0; abort:=FALSE; next:=FALSE;
  n2:=FALSE;
  while (not abort) and (bn<=maxulb) and (not hangup) do begin
    lil:=0;
    if (infconf(bn)) then begin
    if (fileboard<>bn) then changefileboard(bn);
    if ((fileboard=bn) and (fbaseac(bn))) then begin
        if (n2) then cls;
        n2:=FALSE;
        sprompt('%070%Searching %140%'+memuboard.name+' #'+cstr(fileboard)+'%070%...');
        n2:=(browse(-1,fn,dta,kw,2,abort));
        if not(n2) then sprint('%150%Finished.');
    end;
    end;
    inc(bn);
    wkey(abort,next);
    if (next) then begin abort:=FALSE; next:=FALSE; end;
  end;
  if (bs=3) then begin
  fconf:=oldfconf;
  end;
  end else begin
        abort:=FALSE; next:=FALSE;
        loaduboard(fileboard);
        sprompt('%070%Searching %140%'+memuboard.name+' #'+cstr(fileboard)+'%070%...');
        if not(browse(-1,fn,dta,kw,2,abort)) then sprint('%150%Finished.');
        end;
  end;
  fileboard:=oldboard;
end;

end.

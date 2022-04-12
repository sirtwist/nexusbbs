{----------------------------------------------------------------------------}
{ Nexus Bulletin Board System                                                }
{                                                                            }
{ All material contained herein is                                           }
{  (c) Copyright 1996 Epoch Development Company.  All rights reserved.       }
{  (c) Copyright 1994-95 Intuitive Vision Software.  All rights reserved.    }
{                                                                            }
{ MODULE     :  NXSETUP.PAS (Main Setup Program Module)                      }
{ AUTHOR     :  George A. Roberts IV                                         }
{                                                                            }
{----------------------------------------------------------------------------}
{ Nexus and Nexecutable are trademarks of Epoch Development Company.         }
{----------------------------------------------------------------------------}
{D-,E+,I+,L-,R+,S+,V-}

program nxSETUP;

uses dos, crt, init2, misc, myio, mainset, keyunit,
     sysop9, sysop8,usertag;


{$I BUILD2.INC}
{.O init2}
{.O myio}
{.O mainset}
{.O keyunit}
{.O sysop2m}
{.O pconfig}
{.O sysop2a}
{.O sysop2b}
{.O sysop2c}
{.O sysop2d}
{.O sysop2e}
{.O sysop2f}
{.O sysop2g}
{.O sysop2h}
{.O mtemp}
{.O sysop2i}
{.O aconfig}
{.O sysop2s}
{.O sysop3}
{.O ivhelp1}
{.O sysop7}
{.O sysop8}
{.O sysop9}
{.O sysop7m}
{.O dsetup}
{.O usertag}

Const
  ovrmaxsize = 50000;
  mconfidx:boolean=FALSE;
  fconfidx:boolean=FALSE;
  mbidx:boolean=FALSE;
  fbidx:boolean=FALSE;
  utagmessage:boolean=FALSE;
  utagfile:boolean=FALSE;

var okin:boolean;
    sd:string;


var
  OvrPath : String;
  sortstart,sortend,tooktime:datetimerec;
  I,RCode         : Integer;
  SyStatF         : File of MatrixREC;
  x,y:integer;
  st:real;
  c:char;
  s,s2:string;
  d:datetimerec;
  startdir:string;

procedure endabort;
var
  ErrTemp : integer;
begin
  if startdir = '' then     // WAY invalid under unix...
    startdir := startdir + '/';
  {$I-} chdir(startdir); {$I+}
  ErrTemp := IOResult;
  if (ErrTemp <> 0) then begin 
    writeln('Failure to change directory to ',startdir,' Error # is ',ErrTemp);
  end;
  textcolor(7);
  textbackground(0);
  halt;
end;

procedure newsystat;
var 
  x, k  : integer;

        function finduid : longint;
        var 
          uidf  : file of useridrec;
          ui    : useridrec;
          w8    : windowrec;
        begin
          assign(uidf,adrv(systat.gfilepath)+'USERID.IDX');
          {$I-} reset(uidf); {$I+}
          if (ioresult<>0) then begin
            // setwindow(w8,2,10,78,15,3,0,8,'Unable to find USERID.IDX',TRUE);
            writeln('Unable to find USERID.IDX.');
            textcolor(12);
            textbackground(0);
            gotoxy(2,1);
            write('Unable to find USERID.IDX to create new MATRIX.DAT!');
            gotoxy(2,3);
            textcolor(15);
            write('Please enter the your DATA path below:');
            gotoxy(2,4);
            infield_inp_fgrd:=15;
            infield_inp_bkgd:=1;
            infield_out_fgrd:=3;
            infield_out_bkgd:=0;
            infield_allcaps:=TRUE;
            infield_numbers_only:=FALSE;
            infield_maxshow:=70;
            infield_show_colors:=FALSE;
            infield_put_slash:=TRUE;
            s := systat.gfilepath;
            infielde(s,79);
            infield_put_slash:=FALSE;
            infield_maxshow:=0;
            infield_show_colors:=FALSE;
            if (s<>systat.gfilepath) then begin
              systat.gfilepath:=s;
              assign(uidf,adrv(systat.gfilepath)+'USERID.IDX');
              {$I-} reset(uidf); {$I+}
              if (ioresult<>0) then begin
                writeln; writeln;
                writeln('Unable to create MATRIX.DAT - Cannot open USERID.IDX');
                //  displaybox('Unable to create MATRIX.DAT - Cannot open USERID.IDX!',5000);
                endabort;
              end;
            end else begin
              writeln; writeln;
              writeln('Unable to create MATRIX.DAT - Cannot open USERID.IDX');
              // displaybox('Unable to create MATRIX.DAT - Cannot open USERID.IDX!',5000);
              endabort;
            end;
          end;
          seek(uidf,filesize(uidf)-1);
          read(uidf,ui);
          close(uidf);
          finduid := ui.userid;
        end;

begin
  fillchar(systat,sizeof(systat),#0);
  with systat do begin
    majorversion:=majversion;
    minorversion:=minversion;
{$IFDEF LINUX}
    gfilepath := nexusdir + '/data/';
    afilepath := nexusdir + '/display/';
    menupath := nexusdir + '/menus/';
    trappath := nexusdir + '/logs/';
    userpath := nexusdir + '/messages/';
    utilpath := nexusdir + '/utils/';
    semaphorepath := nexusdir + '/sema/';
    filepath := nexusdir + '/filebase/';
    temppath := nexusdir + '/temp/';
    swappath := nexusdir + '/swap/';
    filereqpath := nexusdir + '/requests/';
    nexecutepath := nexusdir + '/nexecute/';
{$ELSE}
    gfilepath:=nexusdir+'\DATA\';
    afilepath:=nexusdir+'\DISPLAY\';
    menupath:=nexusdir+'\MENUS\';
    trappath:=nexusdir+'\LOGS\';
    userpath:=nexusdir+'\MESSAGES\';
    utilpath:=nexusdir+'\UTILS\';
    semaphorepath:=nexusdir+'\SEMA\';
    filepath:=nexusdir+'\FILEBASE\';
    temppath:=nexusdir+'\TEMP\';
    swappath:=nexusdir+'\SWAP\';
    filereqpath:=nexusdir+'\REQUESTS\';
    nexecutepath:=nexusdir+'\NEXECUTE\';
{$ENDIF}
    cbuild := 1;
    cbuildmod := '';

    bbsname := 'New Nexus BBS';
    bbscitystate := 'Somewhere, USA';
    bbsphone := '000-000-0000';
    sysopname := 'New Nexus Sysop';
    maxusers := 32767;
    sysoppw := 'SYSOP';
    eventwarningtime := 3;

    sop := 'S100';
    csop := 'S99';
    msop := 'S98';
    fsop := 'S97';
    spw := 'S98';
    seepw := 'S100';
    normpubpost := 'S20';
    netmail := 'S98';
    seeunval := 'S97';
    dlunval := 'S97';
    nodlratio := 'S97';
    nopostratio := 'S98';
    nofilepts := 'S97';
    ulvalreq := 'S10';
    setnetmailflags := 'S98';
    netmailoutofzone := 'S98';
    nonodelist := 'S98';

    maxfback := 3;
    maxpubpost := 50;
    maxchat := 3;
    maxlines := 120;
    csmaxlines := 160;
    maxlogontries := 3;
    sysopcolor := 4;
    usercolor := 3;
    minspaceforpost := 50;
    minspaceforupload := 500;
    backsysoplogs := 7;
    pagelen := 24;
    lastlogdelete := 0;

    allowalias := FALSE;
    phonepw := FALSE;
    localsec := FALSE;
    localscreensec := FALSE;
    globaltrap := TRUE;
    autochatopen := TRUE;

    newapp := 1;
    timeoutbell := 1;
    timeout := 3;
    timeoutlocal := TRUE;
    usebios := FALSE;
    cgasnow := FALSE;
    showlocaloutput := TRUE;
    showlocaloutput2 := TRUE;
    useextchat := FALSE;

    uldlratio := FALSE;
    fileptratio := TRUE;
    fileptcomp := 10;
    fileptcompbasesize := 10;
    ulrefund := 100;
    tosysopdir := 0;
    validateallfiles := TRUE;
    remdevice := 'CON';
    maxintemp := 500;
    minresume := 100;
    searchdup := 0;
    searchdupstrict := FALSE;
    listtype := 0;
    numusers := 1;
  end;
end;

function verline(i : integer):string;
var 
  s : string;
  d : datetimerec;

begin
  s := '';
  case i of
    1:begin
	s:='nxSETUP v'+version+build+' - Setup for Nexus Bulletin Board System';
      end;
    2:s:='(c) Copyright 1994-2003 George A. Roberts IV. All rights reserved.';
    3:s:='This is an Open Source Project available from http://www.nexusbbs.net/';
  end;
  verline:=s;
end;


procedure getparams;
var 
  np, np2  : integer;
  sp       : string;
  idx,
  idx2     : boolean;
begin
  idx := FALSE;
  idx2 := FALSE;
  np := paramcount;
  if (paramcount>0) then begin
    np2 := 1;
    while (np2<=np) do begin
      sp:=paramstr(np2);
      if (allcaps(sp)='/Z') or (allcaps(sp)='-Z') then 
        nxe:=TRUE;
      if (allcaps(sp)='INDEX') then 
        idx:=TRUE;
      if (idx) then begin
        if (allcaps(sp)='ALL') then begin
          idx2:=TRUE;
          mconfidx:=TRUE;
          utagfile:=TRUE;
          utagmessage:=TRUE;
          fconfidx:=TRUE;
          fbidx:=TRUE;
          mbidx:=TRUE;
      end;
      if (allcaps(sp)='MCONF') then begin
        mconfidx:=TRUE;
        idx2:=TRUE;
      end;
      if (allcaps(sp)='FCONF') then begin 
        fconfidx:=TRUE;
        idx2:=TRUE;
      end;
      if (allcaps(sp)='MSG') then begin 
        mbidx:=TRUE;
        idx2:=TRUE;
      end;
      if (allcaps(sp)='FILE') then begin 
        fbidx:=TRUE;
        idx2:=TRUE;
      end;
      if (allcaps(sp)='TAGMSG') then begin
        utagmessage:=TRUE;
        idx2:=TRUE;
      end;
      if (allcaps(sp)='TAGFILE') then begin
        utagfile:=TRUE;
        idx2:=TRUE;
      end;
    end;
    if (allcaps(sp)='/?') or (allcaps(sp)='-?') or (allcaps(sp)='?') then begin
      textcolor(7);
      textbackground(0);
      clrscr;
      writeln(verline(1));
      writeln(verline(2));
      writeln(verline(3));
      writeln;
      if (idx) then begin
        writeln('Syntax:');
        writeln;
        writeln('   NXSETUP INDEX <TYPE> [TYPE] [TYPE] [TYPE]');
        writeln;
        writeln('Types:');
        writeln;
        writeln('   MCONF       Rebuild Message Conference index');
        writeln('   FCONF       Rebuild File Conference index');
        writeln('   MSG         Rebuild Message Base index');
        writeln('   FILE        Rebuild File Base index');
        writeln('   TAGMSG      Rebuild Default Message Tags');
        writeln('   TAGFILE     Rebuild Default File Tags');
        writeln('   ALL         Rebuild all the indices listed above');
        writeln;
        writeln('Example:');
        writeln;
        writeln('   NXSETUP INDEX MSG FCONF');
        writeln('   NXSETUP INDEX ALL');
      end else begin
        writeln('Syntax:');
        writeln;
{$IFDEF Linux}
	writeln('   ./nxsetup [command] [option]');
{$ELSE}
        writeln('   NXSETUP [Command]');
{$ENDIF}
        writeln;
        writeln('Commands:');
        writeln;
        writeln('   index       Rebuild specified index files');
        writeln;
        writeln('By specifying no commands, you will be taken into the setup portion of nxSETUP.');
        writeln;
        writeln('Run NXSETUP [command] ? for more information about a specific command.');
      end;
      halt;
    end;
    inc(np2);
  end;
  if (idx) and not(idx2) then begin
    textcolor(7);
    textbackground(0);
    clrscr;
    writeln(verline(1));
    writeln(verline(2));
    writeln(verline(3));
    writeln;
    writeln('Syntax:');
    writeln;
    writeln('   NXSETUP INDEX <TYPE> [TYPE] [TYPE] [TYPE]');
    writeln;
    writeln('Types:');
    writeln;
    writeln('   MCONF       Rebuild Message Conference index');
    writeln('   FCONF       Rebuild File Conference index');
    writeln('   MSG         Rebuild Message Base index');
    writeln('   FILE        Rebuild File Base index');
    writeln('   TAGMSG      Rebuild Default Message Tags');
    writeln('   TAGFILE     Rebuild Default File Tags');
    writeln('   ALL         Rebuild all the indices listed above');
    writeln;
    writeln('Example:');
    writeln;
    writeln('   NXSETUP INDEX MSG FCONF');
    writeln('   NXSETUP INDEX ALL');
    halt;
  end;
  end;
end;

procedure bscreen;
var  wfcFile : file;
     dump:array[1..4000] of byte;
     r,c:integer;
begin
   window(1,1,80,25);
   cursoron(FALSE);
   assign(wfcFile,bslash(true,pathonly(paramstr(0)))+'nxsetup.bin');
   {$I-} reset(wfcFile,1); {$I+}
   if (ioresult<>0) then begin
        displaybox('Error reading '+bslash(true,pathonly(paramstr(0)))+'NXSETUP.BIN',2000);
        halt;
   end;
   if (filesize(wfcfile)<4000) then begin
        displaybox(bslash(true,pathonly(paramstr(0)))+'NXSETUP.BIN is an invalid size!',2000);
        halt;
   end;
   blockRead(wfcFile,dump,4000);
   close(wfcFile);
   for r:=0 to 23 do begin
	for c:=1 to 80 do begin
		gotoxy(c,r+1);
		textattr:=dump[(c*2)+(r*160)];
		write(chr(dump[((c*2)-1)+(r*160)]));
	end;
   end;
end;

begin
  getdir(0,startdir);
  nexusdir:=getenv('NEXUS');
{$IFDEF LINUX}
  if (nexusdir[length(nexusdir)]='/') then
{$ELSE}
  if (nexusdir[length(nexusdir)]='\') then
{$ENDIF}
    nexusdir:=copy(nexusdir,1,length(nexusdir)-1);
  start_dir:=nexusdir;
  showcontrolbox:=FALSE;
  nxe:=false;
  filemode:=66;
  if (nexusdir='') then begin
    writeln('You must set your NEXUS environment variable to point to your main Nexus');
    writeln('directory or nxSETUP will not run.');
    writeln;
    halt(0);
  end;
{$IFDEF LINUX}
  keydir := nexusdir + '/';
{$ELSE}
  keydir:=nexusdir+'\';
{$ENDIF}
  checkkey('NEXUS');
  getparams;
cursoron(FALSE);
  if not(nxe) then begin
    textcolor(7);
    textbackground(0);
    clrscr;
    bscreen;
  end;

{$IFDEF LINUX}
  Assign(systatf, nexusdir + '/matrix.dat');
{$ELSE}
  assign(systatf,nexusdir+'\MATRIX.DAT');
{$ENDIF}
  {$I-} reset(systatf); {$I+}
  if (ioresult<>0) then
  begin
    drawwindow2(5,10,75,16,1,3,0,11,'ERROR!');
    textcolor(12);
    textbackground(3);
    gotoxy(22,11);
{$IFDEF LINUX}
    write('Unable to find ', nexusdir, '/matrix.dat!');
{$ELSE}
    write('Unable To Find ',allcaps(Nexusdir),'\MATRIX.DAT!');
{$ENDIF}
    textcolor(14);
    gotoxy(7,13);
    write('You must have MATRIX.DAT to load Nexus. If you cannot find your');
    gotoxy(7,14);
    write('MATRIX.DAT file, re-create one by pressing "D".');
    gotoxy(1,25);
    textcolor(14);
    textbackground(0);
    write('Q');
    textcolor(7);
    write('=Exit ');
    textcolor(14);
    write('D');
    textcolor(7);
    write('=Recreate using defaults');
cursoron(FALSE);
    // while not(keypressed) do begin timeslice; end;

    repeat until(keypressed);	
    c:=readkey;
    case Upcase(c) of
      'D':begin
            newsystat;
            rewrite(systatf);
            write(systatf,systat);
            close(systatf);
          end;


     'Q':begin
          cursoron(TRUE); 
	  window(1,1,80,25);
          textcolor(7);
          textbackground(0);
	  clrscr;
          halt;
        end;
    end;
  end else begin
    {$I-} read(systatf,systat); {$I+}
    close(systatf);
  end;

  init(Nexusdir);

  ver:=version+build;

  okin:=TRUE;
  if ((nxset.restrict) and (systat.sysoppw<>'')) and not((mconfidx) or (fconfidx) or (mbidx) or (fbidx) or
          (utagmessage) or (utagfile)) then begin
    okin:=FALSE;
    setwindow(w,22,12,58,14,3,0,8,'',TRUE);
    gotoxy(2,1);
    textcolor(7);
    textbackground(0);
    write('Password   : ');
    gotoxy(15,1);
    s:='';
    infield_inp_fgrd:=15;
    infield_inp_bkgd:=1;
    infield_out_fgrd:=3;
    infield_out_bkgd:=0;
    infield_allcaps:=TRUE;
    infield_numbers_only:=FALSE;
    infield_escape_zero:=FALSE;
    infield_escape_blank:=TRUE;
    infield_insert:=TRUE;
    infielde(s,20);
    infield_escape_blank:=FALSE;
    if (s<>'') then begin
      if (allcaps(s)=allcaps(systat.sysoppw)) then
        okin:=TRUE;
    end;
    removewindow(w);
    if not(okin) and (s<>'') then
      displaybox('Invalid Password!',2000);
  end;
  if (okin) then begin
    if (mconfidx) or (fconfidx) or (mbidx) or (fbidx) or
        (utagmessage) or (utagfile) then begin
      if (mconfidx) then
        updatemconfs;
      if (mbidx) then
        updatembaseidx;
      if (utagmessage) then
        createdefaulttags(1);
      if (fconfidx) then
        updatefconfs;
      if (fbidx) then
        updatefbaseidx;
      if (utagfile) then
        createdefaulttags(2);
    end else
      changestuff(nexusdir);
  end;
{dispose(fstring);}
  if (length(startdir)=2) and (startdir[2]=':') then
{$IFDEF LINUX}
  clrscr;
  startdir := startdir + '/';
{$ELSE}
  startdir:=startdir+'\';
{$ENDIF}
  {$I-} chdir(startdir); {$I+}
  if (ioresult<>0) then begin end;
  window(1,1,80,25);
  clrscr;
  cursoron(TRUE);
  textcolor(7);
  textbackground(0);
end.

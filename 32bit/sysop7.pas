(*****************************************************************************)
(*>                                                                         <*)
(*>                     Next Epoch matriX User System                       <*)
(*>                                                                         <*)
(*>     Copyright 1995 Intuitive Vision Software.  All Rights Reserved.     <*)
(*>                    Written by George A. Roberts IV                      <*)
(*>                                                                         <*)
(*>                      Nexus Filename : SYSOP7.PAS                        <*)
(*>                                                                         <*)
(*>                      SysOp functions: Menu editor                       <*)
(*>                                                                         <*)
(*****************************************************************************)
{$A+,B+,D-,E+,F+,I+,L+,N-,O+,R-,S+,V-}
unit sysop7;

interface

uses
  crt, dos, myio, misc, sysop7m, {inptmisc,}procspec;


procedure menu_edit;

implementation

var menuchanged,justcreated:boolean;
    x:integer;
    fiv:text;
    mdf:file of commandrec;
    bcurmenu:astr;
    hmm:^windowrec;
    


function getlanguagemenu:string;
var lang:byte;
    langf:file of languagerec;
    langr:languagerec;
    s2:string;
    ok:boolean;
begin
        s2:='';
        ok:=TRUE;
        lang:=getlanguage;
        if (lang=0) then begin
                getlanguagemenu:='';
                exit;
        end;
        assign(langf,systat.gfilepath+'LANGUAGE.DAT');
        {$I-} reset(langf); {$I+}
        if (ioresult<>0) then begin
                displaybox('Error reading LANGUAGE.DAT... Recreating.',3000);
                ok:=recreatelanguage;
                if (ok) then begin
                        {$I-} reset(langf); {$I+}
                        if (ioresult<>0) then begin
                                displaybox('Error recreating LANGUAGE.DAT...',3000);
                                getlanguagemenu:='';
                                exit;
                        end;
                        lang:=1;
                end else begin
                                displaybox('Error recreating LANGUAGE.DAT...',3000);
                                getlanguagemenu:='';
                                exit;
                end;
        end;
        seek(langf,lang);
        read(langf,langr);
        close(langf);
        s2:=langr.menuname;
        getlanguagemenu:=s2;
end;

procedure newmenu;
begin
    with menur^ do begin
    name:='New Nexus Menu';
    mnufile:='NEWMENU';
    mnuheader:='';
    mnufooter:='';
    directive:='';
    tutorial:='';
    fallback:=8;
    menuname[1]:='';
    menuname[2]:='';    
    menuname[3]:='';
    menuprompt:='%090%Selection (%150%?%090%=Help) : %150%';
    acs:='';
    accesskey:='';
    forcehelplevel:=0;
    gencols:=3;
    gcol[1]:=8;
    gcol[2]:=15;
    gcol[3]:=3;
    menuflags:=[];
  end;
 end;

procedure newmenufile(b:byte);
begin
    with menur^ do begin
    case b of
        1:begin
                name:='Global Menu Commands';
                mnufile:='GLOBAL';
          end;
        2:begin
                name:='Newuser Menu';
                mnufile:='NEWUSER';
          end;
        3:begin
                name:='Prelogon Menu';
                mnufile:='PRELOGON';
          end;
        4:begin
                name:='Logon Menu';
                mnufile:='LOGON';
          end;
        5:begin
                name:='Fast Logon Menu';
                mnufile:='FASTLOG';
          end;
        6:begin
                name:='Message Reading Menu';
                mnufile:='MREAD';
          end;
        7:begin
                name:='File Listing Menu';
                mnufile:='FLIST';
          end;
        8:begin
                name:='Main System Menu';
                mnufile:='MENU';
          end;
    end;
    mnuheader:='';
    mnufooter:='';
    directive:='';
    tutorial:='';
    fallback:=8;
    menuname[1]:='';
    menuname[2]:='';    
    menuname[3]:='';
    case b of
         6:begin
                menuprompt:='%080%(%150%|CURMSG|%080%) %030%Read messages (%150%1%030%-'+
                '%150%|HIGHMSG|%030%, %150%?%030%=Help) : %151%';
           end;
         7:begin
                menuprompt:='%080%(%150%|FBNUMBER|%080%) %030%|FBNAME||LF|%030%File listing'+
                ' (%150%1%030%-%150%|NUMFILES|%030%,%150%F%030%=Flag,%150%D%030%=Download,%150%'+
                'I%030%=Info,%150%Q%030%=Quit) : %151%';
           end;
         else begin
                menuprompt:='%030%Selection (%150%?%030%=Help) : %150%';
         end;
    end;
    acs:='';
    accesskey:='';
    forcehelplevel:=0;
    gencols:=3;
    gcol[1]:=(8 or (0 shl 4));
    gcol[2]:=(15 or (0 shl 4));
    gcol[3]:=(3 or (0 shl 4));
    menuflags:=[];
  end;
 end;

function readin3:boolean;                    (* read in the menu file curmenu *)
var s:astr;
    i:integer;
begin
  noc:=0;
  assign(mdf,systat.menupath+menur^.mnufile+'.MNU');
  {$I-} reset(mdf); {$I+}
  if ioresult<>0 then begin
    readin3:=FALSE;
  end else begin
    repeat
      inc(noc);
      read(mdf,cmdr^[noc]);
    until (eof(mdf));
    close(mdf);

    readin3:=TRUE;
  end;
end;

procedure menu_edit;
const menudata:boolean=TRUE;
var nocsave,i,i1,i2,ii:integer;
    c:char;
    abort,next:boolean;
    s,scurmenu:astr;
    deleted,done2,done:boolean;
        
procedure genericmenu2(t:integer);
var glin:array [1..maxmenucmds] of astr;
    s,s1:astr;
    c2:char;
    w2:windowrec;
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
      b:=TRUE;
      if (((b) or (unhidden in cmdr^[i].commandflags)) and
          (not (hidden in cmdr^[i].commandflags))) then
        if (titleline in cmdr^[i].commandflags) then begin
          inc(numglin); glin[numglin]:=cmdr^[i].ldesc;
          j:=lenn(glin[numglin]); if (j>maxright) then maxright:=j;
          if (cmdr^[i].mstring<>'') then newgcolors(cmdr^[i].mstring);
        end else
          if (cmdr^[i].ldesc<>'') then begin
            inc(numglin);
            glin[numglin]:=gencolored(cmdr^[i].ckeys,cmdr^[i].ldesc,b);
            j:=lenn(glin[numglin]); if (j>maxright) then maxright:=j;
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
    s3:=stripcolor(s3);
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
      b:=TRUE;
      if (((b) or (unhidden in cmdr^[i].commandflags)) and
          (not (hidden in cmdr^[i].commandflags))) then begin
        if (titleline in cmdr^[i].commandflags) then begin
          if (onlin<>0) then inc(numglin);
          glin[numglin]:=#2+cmdr^[i].ldesc;
          inc(numglin); glin[numglin]:='';
          onlin:=0;
          if (cmdr^[i].mstring<>'') then newgcolors(cmdr^[i].mstring);
        end else begin
          if (cmdr^[i].sdesc<>'') then begin
            inc(onlin); s1:=gencolored(cmdr^[i].ckeys,cmdr^[i].sdesc,b);
            if (onlin<>numcols) then fixit(s1,colsiz);
            glin[numglin]:=glin[numglin]+s1;
          end;
          if (onlin=numcols) then begin
            j:=lenn(glin[numglin]); if (j>maxright) then maxright:=j;
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
    c:=(c div 2)-(lenn(s) div 2);
    if (c<1) then c:=0;
    tcentered:=copy(spacestr,1,c)+s;
  end;

  procedure dotitles;
  var i:integer;
      b:boolean;
  begin
    b:=FALSE;
    textcolor(7);
    textbackground(0);
    clrscr;
    for i:=1 to 3 do
      if (menur^.menuname[i]<>'') then begin
        if (not b) then begin writeln; b:=TRUE; end;
        if (dontcenter in menur^.menuflags) then begin
          cwrite(menur^.menuname[i]+#13#10);
        end else begin
          cwrite(tcentered(maxright,menur^.menuname[i])+#13#10);
        end;
      end;
    writeln;
  end;

begin
  savescreen(w2,1,1,80,25);
  window(1,1,80,25);
  if not(readin3) then begin
        displaybox('No menu commands defined.',3000);
        exit;
  end;
  for i:=1 to 3 do gcolors[i]:=menur^.gcol[i];
  numcols:=menur^.gencols;
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
        cwrite(glin[i]+#13#10);
      end else begin
        cwrite(tcentered(maxright,copy(glin[i],2,length(glin[i])-1))+#13#10);
      end;
   inc(i);
   end;
   writeln;
   write('Press ANY KEY to continue.');
   while not(keypressed) do begin timeslice; end;
   c2:=readkey;
   if (c2=#0) then c2:=readkey;
   removewindow(w2);
end;


        procedure getextended;
        var w2:windowrec;
            cho3:array[1..5] of string[15];
            cur3:integer;
            s3:string;
            done3:boolean;
            b:byte;

function valueb(s:string):byte;
var i:byte;
    j:integer;
begin
  val(s,i,j);
  if (j<>0) then begin
    s:=copy(s,1,j-1);
    val(s,i,j)
  end;
  valueb:=i;
  if (s='') then valueb:=0;
end;

        begin
        cho3[1]:='Columns       :';
        cho3[2]:='Bracket Color  ';
        cho3[3]:='Command Color  ';
        cho3[4]:='Desc Color     ';
        cho3[5]:='Show Menu      ';
        setwindow(w2,30,8,50,16,3,0,8,'Generic Info',TRUE);
        for cur3:=1 to 5 do begin
        textcolor(7);
        textbackground(0);
        gotoxy(2,cur3+1);
        write(cho3[cur3]);
        end;
        gotoxy(18,2);
        textcolor(3);
        textbackground(0);
        write(cstr(menur^.gencols));
        cur3:=1;
        done3:=FALSE;
                  repeat
                  gotoxy(2,cur3+1);
                  textcolor(15);
                  textbackground(1);
                  write(cho3[cur3]);
                  while not(keypressed) do begin timeslice; end;
                  c:=readkey;
                  case c of
                        #0:begin
                                c:=readkey;
                                checkkey(c);
                                case c of
                                        #68:begin
                                                done3:=TRUE;
                                            end;
                                        #72:begin
                                                gotoxy(2,cur3+1);
                                                textcolor(7);
                                                textbackground(0);
                                                write(cho3[cur3]);
                                                dec(cur3);
                                                if (cur3=0) then cur3:=5;
                                            end;
                                        #80:begin
                                                gotoxy(2,cur3+1);
                                                textcolor(7);
                                                textbackground(0);
                                                write(cho3[cur3]);
                                                inc(cur3);
                                                if (cur3=6) then cur3:=1;
                                            end;
                                end;
                           end;
                       #13:begin
                                case cur3 of
                                        1:begin
                                                gotoxy(2,cur3+1);
                                                textcolor(7);
                                                textbackground(0);
                                                write(cho3[cur3]);
                                                gotoxy(16,cur3+1);
                                                textcolor(9);
                                                textbackground(0);
                                                write('>');
                                                gotoxy(18,cur3+1);
  infield_inp_fgrd:=15;
  infield_inp_bkgd:=1;
  infield_out_fgrd:=3;
  infield_out_bkgd:=0;
  infield_allcaps:=false;
  infield_numbers_only:=TRUE;
  infield_putatend:=TRUE;
  infield_insert:=FALSE;
  s:=cstr(menur^.gencols);
  infield_min_value:=2;
  infield_max_value:=7;
  infielde(s,1);
  infield_putatend:=FALSE;
  infield_min_value:=-1;
  infield_max_value:=-1;
  infield_insert:=TRUE;
  if (valueb(s)<>menur^.gencols) then begin
        menuchanged:=TRUE;
        menur^.gencols:=valueb(s);
  end;
        
                                          end;
                                        2..4:begin
{                                          
b:=getcolor(3,8,menur^.gcol[cur3-1],'Sample String');}
                                          if (b<>menur^.gcol[cur3-1]) then begin
                                                menuchanged:=TRUE;
                                                menur^.gcol[cur3-1]:=b;
                                          end;
                                          end;
                                        5:begin
                                          genericmenu2(2);
                                          window(31,9,49,15);
                                          end;
                                end;
                           end;
                       #27:begin
                           done3:=TRUE;
                           end;
                       end;
                  until (done3);
                  removewindow(w2);
        end;



        function restrm:boolean;
        begin
        if ((allcaps(scurmenu)='FASTLOG') or (allcaps(scurmenu)='PRELOGON') 
                or (allcaps(scurmenu)='LOGON') or (allcaps(scurmenu)='NEWUSER')) 
                        then restrm:=true else restrm:=false;
        end;
  
  procedure mes1;
  var s:astr;
      i:integer;
  begin
    seek(mf,filepos(mf)-1);
    write(mf,menur^);
  end;

  procedure mes2;
  var i:integer;
      yup:boolean;
  begin
    yup:=TRUE;
    if (noc=0) then begin
        if pynqbox('Delete ALL Commands from this Menu? ') then begin
        assign(mdf,bcurmenu);
        {$I-} erase(mdf); {$I+}
        if (ioresult<>0) then begin end;
        end;
    yup:=FALSE;
    end;
    if (yup) then begin
    assign(mdf,bcurmenu);
    filemode:=66;
    rewrite(mdf);
    for i:=1 to noc do begin
      write(mdf,cmdr^[i]);
    end;
    close(mdf);
    end;
  end;

  procedure med(num:integer);
  var i,x:integer;
  begin
    if (num<1) then exit;
    i:=num;
    seek(mf,i);
    read(mf,menur^);
    s:=systat.menupath+allcaps(menur^.mnufile)+'.MNU';
    assign(fiv,s);
    {$I-} reset(fiv); {$I+}
    if (ioresult=0) then begin
      close(fiv);
      writeln;
      if pynqbox('Delete menu command file '+allcaps(s)+'? ') then begin
        {$I-} erase(fiv); {$I+}
        if (ioresult<>0) then begin end;
      end;
    end;
    if (i<filesize(mf)-1) then
    for x:=(i+1) to (filesize(mf)-1) do begin
        seek(mf,x);
        read(mf,menur^);
        seek(mf,x-1);
        write(mf,menur^);
    end;
    seek(mf,filesize(mf)-1);
    truncate(mf);
    if (filesize(mf)=0) then begin
        newmenu;
        write(mf,menur^);
    end;
  end;

  procedure mei(num:integer);
  var i,x:integer;
  begin
    if (num<5) then exit;
    i:=num;
    if not(filesize(mf)=0) then begin
    for x:=(filesize(mf)-1) downto (i+1) do begin
        seek(mf,x);
        read(mf,menur^);
        seek(mf,x+1);
        write(mf,menur^);
    end;
    seek(mf,i+1);
    end;
        newmenu;
        write(mf,menur^);
  end;

  procedure mem(num:integer);
  var i,j,k:integer;
      c,c3:char;
      b:byte;
      cur2,top2:integer;
      done,auto,done4,bb,update:boolean;
      wback,wb:windowrec;
      cho:array[1..14] of string[30];
      des:array[1..14] of string[60];
      menub:menuptr;
      current,cu:integer;
      


    function getforcehelp:byte;
    var chh:array[1..5] of string[20];
        curh,t1:byte;
        c12:char;
        d2:boolean;
    begin
    t1:=menur^.forcehelplevel;
    chh[1]:='Based on User';
    chh[2]:='Expert       ';
    chh[3]:='Novice       ';
    chh[4]:='Help Screen  ';
    chh[5]:='LightBar     ';
    setwindow(w,24,11,40,19,3,0,8,'Help',TRUE);
    for curh:=1 to 5 do begin
                gotoxy(2,curh+1);
                textcolor(7);
                textbackground(0);
                write(chh[curh]);
    end;
    curh:=1;
    d2:=FALSE;
    repeat
    textcolor(15);
    textbackground(1);
    gotoxy(2,curh+1);
    write(chh[curh]);
    while not(keypressed) do begin timeslice; end;
    c12:=readkey;
    case c12 of
        #0:begin
                c12:=readkey;
                checkkey(c12);
                case c12 of
                        #68:d2:=TRUE;
                        #72:begin
                            textcolor(7);
                            textbackground(0);
                            gotoxy(2,curh+1);
                            write(chh[curh]);
                            dec(curh);
                            if (curh=0) then curh:=5;
                        end;
                        #80:begin
                            textcolor(7);
                            textbackground(0);
                            gotoxy(2,curh+1);
                            write(chh[curh]);
                            inc(curh);
                            if (curh=6) then curh:=1;
                        end;
                end;
        end;
        #13:begin
                t1:=curh-1;
                d2:=TRUE;
                menuchanged:=TRUE;
        end;
        #27:d2:=TRUE;
    end;
    until (d2);
    removewindow(w);
    getforcehelp:=t1;
    end;

    function showfh(i:byte):string;
    begin
    case i of
        0:showfh:='Based on User';
        1:showfh:='Expert       ';
        2:showfh:='Novice       ';
        3:showfh:='Help Screen  ';
        else
          showfh:='Error-Reset! ';
    end;
    end;

    function showflags:string;
    var s:string;
    begin
    s:='';
    if (clrscrbefore in menur^.menuflags) then s:='Clear ';
    if (dontcenter in menur^.menuflags) then s:=s+'NoCenter ';
    if (nomenuprompt in menur^.menuflags) then s:=s+'NoPrompt ';
    if (forcepause in menur^.menuflags) then s:=s+'Pause ';
    if (autotime in menur^.menuflags) then s:=s+'AutoTime ';
    if (filequickchange in menur^.menuflags) then s:=s+'FQuick ';
    if (msgquickchange in menur^.menuflags) then s:=s+'MQuick ';
    if (noloadglobal in menur^.menuflags) then s:=s+'NoGlobal ';
    s:=mln(s,50);
    showflags:=s;
    end;

    procedure getflags;
    var choi:array[1..6] of string;
        cr,x1:integer;
        done1:boolean;
        c1:char;

    begin
    done1:=FALSE;
    choi[1]:='Clear Screen Before:';
    choi[2]:='Don''t Center Titles:';
    choi[3]:='No Menu Prompt     :';
    choi[4]:='Force Pause Before :';
    choi[5]:='Display Time Left  :';
    choi[6]:='No Global Commands :';
    cr:=1;
    setwindow(w,26,10,54,18,3,0,8,'Flags',TRUE);
    for x1:=1 to 6 do begin
        gotoxy(2,x1+1);
        textcolor(7);
        textbackground(0);
        write(choi[x1]);
    end;
    justcreated:=FALSE;
    repeat
    gotoxy(23,2);
    textcolor(3);
    textbackground(0);
    write(syn(clrscrbefore in menur^.menuflags));
    gotoxy(23,3);
    write(syn(dontcenter in menur^.menuflags));
    gotoxy(23,4);
    write(syn(nomenuprompt in menur^.menuflags));
    gotoxy(23,5);
    write(syn(forcepause in menur^.menuflags));
    gotoxy(23,6);
    write(syn(autotime in menur^.menuflags));
    gotoxy(23,7);
    write(syn(noloadglobal in menur^.menuflags));
    gotoxy(2,cr+1);
    textcolor(15);
    textbackground(1);
    write(choi[cr]);
    while not(keypressed) do begin timeslice; end;
    c1:=readkey;
    case c1 of
        #0:begin
                c1:=readkey;
                checkkey(c1);
                case c1 of
                        #68:done1:=TRUE;
                        #72:begin
                        gotoxy(2,cr+1);
                        textcolor(7);
                        textbackground(0);
                        write(choi[cr]);
                        dec(cr);
                        if (cr=0) then cr:=6;
                        end;
                        #80:begin
                        gotoxy(2,cr+1);
                        textcolor(7);
                        textbackground(0);
                        write(choi[cr]);
                        inc(cr);
                        if (cr=7) then cr:=1;
                        end;
                end;
           end;
        #27:done1:=TRUE;
        #13:begin
                menuchanged:=TRUE;
                case cr of
                1:if (clrscrbefore in menur^.menuflags) then menur^.menuflags:=
                        menur^.menuflags-[clrscrbefore] else menur^.menuflags:=
                        menur^.menuflags+[clrscrbefore];
                2:if (dontcenter in menur^.menuflags) then menur^.menuflags:=
                        menur^.menuflags-[dontcenter] else menur^.menuflags:=
                        menur^.menuflags+[dontcenter];
                3:if (nomenuprompt in menur^.menuflags) then menur^.menuflags:=
                        menur^.menuflags-[nomenuprompt] else menur^.menuflags:=
                        menur^.menuflags+[nomenuprompt];
                4:if (forcepause in menur^.menuflags) then menur^.menuflags:=
                        menur^.menuflags-[forcepause] else menur^.menuflags:=
                        menur^.menuflags+[forcepause];
                5:if (autotime in menur^.menuflags) then menur^.menuflags:=
                        menur^.menuflags-[autotime] else menur^.menuflags:=
                        menur^.menuflags+[autotime];
                6:if (noloadglobal in menur^.menuflags) then menur^.menuflags:=
                        menur^.menuflags-[noloadglobal] else menur^.menuflags:=
                        menur^.menuflags+[noloadglobal];
                end;
            end;
    end;
    until (done1);
    removewindow(w);
    end;


  begin
  done:=FALSE;
  auto:=FALSE;
  cho[1]:='Menu Name             :';
  cho[2]:='Menu Filename         :';
  cho[3]:='Menu Header File      :';
  cho[4]:='Menu Footer File      :';
  cho[5]:='Menu Display File     :';
  cho[6]:='Menu Help File        :';
  cho[7]:='Menu Generic Title     ';
  cho[8]:='Menu Prompt           :';
  cho[9]:='Access String         :';
 cho[10]:='Password              :';
 cho[11]:='Fallback Menu         :';
 cho[12]:='Menu Display Level    :';
 cho[13]:='Generic Information   -';
 cho[14]:='Menu Flags            :';
 des[1]:='The Name of this menu for reference purposes    ';
 des[2]:='The name of the .MNU file that this menu uses   ';
 des[3]:='The name of the display file used for the header';
 des[4]:='The name of the display file used for the footer';
 des[5]:='The name of the display file for the whole menu ';
 des[6]:='The name of the display file for the help screen';
 des[7]:='Edit the three line Generic Menu title          ';
 des[8]:='The string that is displayed as the menu prompt ';
 des[9]:='Access String to allow access to this menu      ';
des[10]:='Password to present to users (blank=none)       ';
des[11]:='Fallback Menu if this .MNU fails initialization ';
des[12]:='Display Level of this Menu (Type of Display)    ';
des[13]:='Generic Display information                     ';
des[14]:='Menu Flags for this Menu                        ';
    i:=num;
    editingmenu:=i+1;
    seek(mf,i);
    read(mf,menur^);
      scurmenu:=menur^.mnufile;
      bcurmenu:=adrv(systat.menupath)+scurmenu+'.MNU';
      menuchanged:=FALSE;
 current:=1;
 cursoron(FALSE);
 setwindow2(wb,1,6,78,23,3,0,8,'Edit Menu Data','Menu Editor: '+scurmenu,TRUE);
 for x:=1 to 14 do begin
 gotoxy(2,x+1);
 textcolor(7);
 textbackground(0);
 write(cho[x]);
 end;
 update:=TRUE;
 repeat
 if (update) then begin
 scurmenu:=menur^.mnufile;
 bcurmenu:=adrv(systat.menupath)+scurmenu+'.MNU';
 update:=FALSE;
 setwindow3(wb,1,6,78,23,3,0,8,'Edit Menu Data','Menu Editor: '+scurmenu,TRUE);
 with menur^ do begin
 gotoxy(26,2);
 textcolor(3);
 textbackground(0);
 write(name);
 gotoxy(26,3);
 write(mnufile);
 gotoxy(26,4);
 write(mnuheader);
 gotoxy(26,5);
 write(mnufooter);
 gotoxy(26,6);
 write(directive);
 gotoxy(26,7);
 write(tutorial);
 gotoxy(26,9);
 cwrite(mln(menuprompt,50));
 gotoxy(26,10);
 textcolor(3);
 textbackground(0);
 write(mln(acs,20));
 gotoxy(26,11);
 write(mln(accesskey,15));
 gotoxY(26,12);
 write(mln(cstr(fallback),4));
 gotoxy(26,13);
 write(showfh(forcehelplevel));
 gotoxy(26,14);
 textcolor(7);
 textbackground(0);
 write('Columns: ');
 textcolor(3);
 textbackground(0);
 write(cstr(gencols)+'  ');
 textcolor(7);
 textbackground(0);
 write('Colors:   ');
 textattr:=gcol[1];
 write('(');
 textattr:=gcol[2];
 write('I');
 textattr:=gcol[1];
 write(')');
 textattr:=gcol[3];
 write('nformation on Nexus');
 gotoxy(26,15);
 textcolor(3);
 textbackground(0);
 write(showflags);
 end;
 end;
          window(1,1,80,25);
          gotoxy(1,25);
          textcolor(14);
          textbackground(0);
          clreol;
          cwrite('%140%Esc%070%=Exit %140%Alt-C%070%=Edit Commands %140%'+des[current]);
          window(2,7,77,22);
          gotoxy(2,current+1);
          textcolor(15);
          textbackground(1);
          write(cho[current]);
          while not(keypressed) do begin timeslice; end;
          c:=readkey;
          case upcase(c) of
            #0:begin
                c:=readkey;
                checkkey(c);
                case c of
                        #46:begin
                            gotoxy(2,current+1);
                            textcolor(7);
                            textbackground(0);
                            write(cho[current]);
 setwindow4(wb,1,6,78,23,8,0,8,'Edit Menu Data','Menu Editor: '+scurmenu,TRUE);
                                   memm(bcurmenu);
 setwindow5(wb,1,6,78,23,3,0,8,'Edit Menu Data','Menu Editor: '+scurmenu,TRUE);
                                   window(2,7,77,22);
                            end;
                        #68:begin
                                done:=TRUE;
                                auto:=TRUE;
                            end;
                        #72:begin
                            gotoxy(2,current+1);
                            textcolor(7);
                            textbackground(0);
                            write(cho[current]);
                            dec(current);
                            if (current=0) then current:=14;
                            end;
                        #80:begin
                            gotoxy(2,current+1);
                            textcolor(7);
                            textbackground(0);
                            write(cho[current]);
                            inc(current);
                            if (current=15) then current:=1;
                            end;
                end;
               end;
            #27:done:=TRUE;
            #13:case current of

                        1:begin
                            gotoxy(2,current+1);
                            textcolor(7);
                            textbackground(0);
                            write(cho[current]);
                            gotoxy(24,current+1);
                                        textcolor(9);
                                        textbackground(0);
                                        write('>');
                                        gotoxy(26,current+1);
                                        infield_inp_fgrd:=15;
                                        infield_inp_bkgd:=1;
                                        infield_out_fgrd:=3;
                                        infield_out_bkgd:=0;
                                        infield_allcaps:=false;
                                        infield_numbers_only:=FALSE;
                                        infield_maxshow:=50;
                                        infield_show_colors:=TRUE;
                                        s:=menur^.name;
                                        infielde(s,60);
                                        infield_maxshow:=0;
                                        infield_show_colors:=FALSE;
                                        if (s<>menur^.name) then begin
                                        menuchanged:=TRUE;
                                        menur^.name:=s;
                                        end;
                        end;
                        2:begin
                            gotoxy(2,current+1);
                            textcolor(7);
                            textbackground(0);
                            write(cho[current]);
                            gotoxy(24,current+1);
                                        textcolor(9);
                                        textbackground(0);
                                        write('>');
                                        gotoxy(26,current+1);
                                        infield_inp_fgrd:=15;
                                        infield_inp_bkgd:=1;
                                        infield_out_fgrd:=3;
                                        infield_out_bkgd:=0;
                                        infield_allcaps:=TRUE;
                                        infield_numbers_only:=FALSE;
                                        infield_maxshow:=0;
                                        infield_show_colors:=TRUE;
                                        s:=menur^.mnufile;
                                        infielde(s,8);
                                        infield_maxshow:=0;
                                        infield_show_colors:=FALSE;
                                        if (s<>menur^.mnufile) then begin
                                        if pynqbox('Menu File Changed: Save Changes? ') then begin
                                        menuchanged:=TRUE;
                                        menur^.mnufile:=s;
                                        mes1;
                                        menuchanged:=FALSE;
                                        update:=TRUE;
                                        end;
                                        end;
                        end;
                        3:begin
                            gotoxy(2,current+1);
                            textcolor(7);
                            textbackground(0);
                            write(cho[current]);
                            gotoxy(24,current+1);
                                        textcolor(9);
                                        textbackground(0);
                                        write('>');
                                        gotoxy(26,current+1);
                                        infield_inp_fgrd:=15;
                                        infield_inp_bkgd:=1;
                                        infield_out_fgrd:=3;
                                        infield_out_bkgd:=0;
                                        infield_allcaps:=TRUE;
                                        infield_numbers_only:=FALSE;
                                        infield_maxshow:=0;
                                        infield_show_colors:=TRUE;
                                        s:=menur^.mnuheader;
                                        infielde(s,12);
                                        infield_maxshow:=0;
                                        infield_show_colors:=FALSE;
                                        if (s<>menur^.mnuheader) then begin
                                        menuchanged:=TRUE;
                                        menur^.mnuheader:=s;
                                        end;
                        end;
                        4:begin
                            gotoxy(2,current+1);
                            textcolor(7);
                            textbackground(0);
                            write(cho[current]);
                            gotoxy(24,current+1);
                                        textcolor(9);
                                        textbackground(0);
                                        write('>');
                                        gotoxy(26,current+1);
                                        infield_inp_fgrd:=15;
                                        infield_inp_bkgd:=1;
                                        infield_out_fgrd:=3;
                                        infield_out_bkgd:=0;
                                        infield_allcaps:=TRUE;
                                        infield_numbers_only:=FALSE;
                                        infield_maxshow:=0;
                                        infield_show_colors:=TRUE;
                                        s:=menur^.mnufooter;
                                        infielde(s,12);
                                        infield_maxshow:=0;
                                        infield_show_colors:=FALSE;
                                        if (s<>menur^.mnufooter) then begin
                                        menuchanged:=TRUE;
                                        menur^.mnufooter:=s;
                                        end;
                        end;
                        5:begin
                            gotoxy(2,current+1);
                            textcolor(7);
                            textbackground(0);
                            write(cho[current]);
                            gotoxy(24,current+1);
                                        textcolor(9);
                                        textbackground(0);
                                        write('>');
                                        gotoxy(26,current+1);
                                        infield_inp_fgrd:=15;
                                        infield_inp_bkgd:=1;
                                        infield_out_fgrd:=3;
                                        infield_out_bkgd:=0;
                                        infield_allcaps:=TRUE;
                                        infield_numbers_only:=FALSE;
                                        infield_maxshow:=0;
                                        infield_show_colors:=TRUE;
                                        s:=menur^.directive;
                                        infielde(s,12);
                                        infield_maxshow:=0;
                                        infield_show_colors:=FALSE;
                                        if (s<>menur^.directive) then begin
                                        menuchanged:=TRUE;
                                        menur^.directive:=s;
                                        end;
                        end;
                        6:begin
                            gotoxy(2,current+1);
                            textcolor(7);
                            textbackground(0);
                            write(cho[current]);
                            gotoxy(24,current+1);
                                        textcolor(9);
                                        textbackground(0);
                                        write('>');
                                        gotoxy(26,current+1);
                                        infield_inp_fgrd:=15;
                                        infield_inp_bkgd:=1;
                                        infield_out_fgrd:=3;
                                        infield_out_bkgd:=0;
                                        infield_allcaps:=false;
                                        infield_numbers_only:=FALSE;
                                        infield_maxshow:=0;
                                        infield_show_colors:=TRUE;
                                        s:=menur^.tutorial;
                                        infielde(s,12);
                                        infield_maxshow:=0;
                                        infield_show_colors:=FALSE;
                                        if (s<>menur^.tutorial) then begin
                                        menuchanged:=TRUE;
                                        menur^.tutorial:=s;
                                        end;
                        end;
                        7:begin
                        end;
                       8:begin
                            gotoxy(2,current+1);
                            textcolor(7);
                            textbackground(0);
                            write(cho[current]);
                            gotoxy(24,current+1);
                                        textcolor(9);
                                        textbackground(0);
                                        write('>');
                                        gotoxy(26,current+1);
                                        infield_inp_fgrd:=15;
                                        infield_inp_bkgd:=1;
                                        infield_out_fgrd:=3;
                                        infield_out_bkgd:=0;
                                        infield_allcaps:=false;
                                        infield_numbers_only:=FALSE;
                                        infield_maxshow:=50;
                                        infield_show_colors:=TRUE;
                                        s:=menur^.menuprompt;
                                        infielde(s,120);
                                        infield_maxshow:=0;
                                        infield_show_colors:=FALSE;
                                        if (s<>menur^.menuprompt) then begin
                                        menuchanged:=TRUE;
                                        menur^.menuprompt:=s;
                                        end;
                        end;
                        9:begin
                            gotoxy(2,current+1);
                            textcolor(7);
                            textbackground(0);
                            write(cho[current]);
                            gotoxy(24,current+1);
                                        textcolor(9);
                                        textbackground(0);
                                        write('>');
                                        gotoxy(26,current+1);
                                        infield_inp_fgrd:=15;
                                        infield_inp_bkgd:=1;
                                        infield_out_fgrd:=3;
                                        infield_out_bkgd:=0;
                                        infield_allcaps:=false;
                                        infield_numbers_only:=FALSE;
                                        infield_maxshow:=0;
                                        infield_show_colors:=TRUE;
                                        s:=menur^.acs;
                                        infielde(s,20);
                                        infield_maxshow:=0;
                                        infield_show_colors:=FALSE;
                                        if (s<>menur^.acs) then begin
                                        menuchanged:=TRUE;
                                        menur^.acs:=s;
                                        end;
                        end;
                        10:begin
                            gotoxy(2,current+1);
                            textcolor(7);
                            textbackground(0);
                            write(cho[current]);
                            gotoxy(24,current+1);
                                        textcolor(9);
                                        textbackground(0);
                                        write('>');
                                        gotoxy(26,current+1);
                                        infield_inp_fgrd:=15;
                                        infield_inp_bkgd:=1;
                                        infield_out_fgrd:=3;
                                        infield_out_bkgd:=0;
                                        infield_allcaps:=false;
                                        infield_numbers_only:=FALSE;
                                        infield_maxshow:=0;
                                        infield_show_colors:=TRUE;
                                        s:=menur^.accesskey;
                                        infielde(s,15);
                                        infield_maxshow:=0;
                                        infield_show_colors:=FALSE;
                                        if (s<>menur^.accesskey) then begin
                                        menuchanged:=TRUE;
                                        menur^.accesskey:=s;
                                        end;
                        end;
                        11:begin
  new(menub);
  menub^:=menur^;
  disposeall2;
  readinpointers2;
  menur^:=menub^;
  dispose(menub);
  cur2:=1;
  top2:=1;
  done4:=false;
  repeat
    for x:=1 to 100 do rt.data[x]:=-1;
    lp:=firstlp;
    listbox(wback,rt,top2,cur2,lp,6,8,74,21,3,0,8,'Menus - '+mfilename,'Menu Editor',TRUE);
    case rt.kind of
        0:begin
                c3:=chr(rt.data[100]);
                removewindow(wback);
                checkkey(c3);
                rt.data[100]:=-1;
          end;
        1:if rt.data[1]<>-1 then begin
                if (rt.data[1]<>menur^.fallback) then begin
                menur^.fallback:=rt.data[1];
                menuchanged:=TRUE;
                end;
                done4:=TRUE;
        end;
        2:begin
                done4:=TRUE;
        end;
      end;
  until (done4);
                        removewindow(wback);
                        window(2,7,77,22);
                        textcolor(3);
                        textbackground(0);
                        gotoxY(26,12);
                        write(mln(cstr(menur^.fallback),4));
                        end;
                        12:begin
                            gotoxy(2,current+1);
                            textcolor(7);
                            textbackground(0);
                            write(cho[current]);
 setwindow4(wb,1,6,78,23,8,0,8,'Edit Menu Data','Menu Editor: '+scurmenu,TRUE);
                        menur^.forcehelplevel:=getforcehelp;
 setwindow5(wb,1,6,78,23,3,0,8,'Edit Menu Data','Menu Editor: '+scurmenu,TRUE);
                        window(2,7,77,22);
                        gotoxy(26,13);
                        textcolor(3);
                        textbackground(0);
                        write(showfh(menur^.forcehelplevel));
                        end;
                        13:begin
 setwindow4(wb,1,6,78,23,8,0,8,'Edit Menu Data','Menu Editor: '+scurmenu,TRUE);
                        getextended;
 setwindow5(wb,1,6,78,23,3,0,8,'Edit Menu Data','Menu Editor: '+scurmenu,TRUE);
                        window(2,7,77,22);
                        end;
                        14:begin
                            gotoxy(2,current+1);
                            textcolor(7);
                            textbackground(0);
                            write(cho[current]);
 setwindow4(wb,1,6,78,23,8,0,8,'Edit Menu Data','Menu Editor: '+scurmenu,TRUE);
                        getflags;
 setwindow5(wb,1,6,78,23,3,0,8,'Edit Menu Data','Menu Editor: '+scurmenu,TRUE);
                        window(2,7,77,22);
                        gotoxy(26,15);
                        textcolor(3);
                        textbackground(0);
                        write(showflags);
                        end;
                end;                        
            'L':begin
                  savescreen(wback,1,1,80,25);
                  textcolor(7);
                  textbackground(0);
                  genericmenu2(3);
                  removewindow(wback);
                  window(2,7,77,22);
                end;
             end;
        until (done);
        if (menuchanged) then begin
          if not(auto) then auto:=pynqbox('Save changes? ');
          if (auto) then begin
          mes1;
          end;
          menuchanged:=FALSE;
          auto:=FALSE;
        end;
        removewindow(wb);
  end;




begin
  mfilename:=getlanguagemenu;
  if (mfilename='') then exit;
  assign(mf,systat.gfilepath+mfilename+'.NXM');
  {assign(mf,systat.gfilepath+'ENGLISH.NXM');}
  new(menur);
  new(cmdr);
  new(hmm);
  nocsave:=noc;
  noc:=0;
  bcurmenu:='';
  {$I-} reset(mf); {$I+}
  if (ioresult<>0) then begin
        rewrite(mf);
        newmenufile(1);
        write(mf,menur^);
        newmenufile(2);
        write(mf,menur^);
        newmenufile(3);
        write(mf,menur^);
        newmenufile(4);
        write(mf,menur^);
        newmenufile(5);
        write(mf,menur^);
        newmenufile(6);
        write(mf,menur^);
        newmenufile(7);
        write(mf,menur^);
        newmenufile(8);
        write(mf,menur^);
  end;
  readinpointers2;
  cur:=1;
  top:=1;
  done:=false;
  repeat
    editingmenu:=0;
    for x:=1 to 100 do rt.data[x]:=-1;
    lp:=firstlp;
    listbox(hmm^,rt,top,cur,lp,6,8,74,21,3,0,8,'Menus - '+mfilename,'Menu Editor',TRUE);
    case rt.kind of
        0:begin
                removewindow(hmm^);
                c4:=chr(rt.data[100]);
                checkkey(c4);
                rt.data[100]:=-1;
          end;
        1:if rt.data[1]<>-1 then begin
                removewindow(hmm^);
                mem(rt.data[1]-1);
                disposeall2;
                readinpointers2;
        end;
        2:begin
                done:=TRUE;
                disposeall2;
                removewindow(hmm^);
        end;
        3:begin
        removewindow(hmm^);
        if (rt.data[1]>5) then begin
                                mei(rt.data[1]-1);
                                disposeall2;
                                readinpointers2;
        end;
        end;
        4:begin
                removewindow(hmm^);
                deleted:=FALSE;
                for x:=100 downto 1 do begin
                        if (rt.data[x]>1) then begin
                                if pynqbox('Delete menu #'+cstr(rt.data[x])+' - Are you sure? ') then begin
                                displaybox('Deleting Menu: '+cstr(rt.data[x]),2000);
                                med(rt.data[x]-1);
                                deleted:=TRUE;
                                end;
                        end;
                end;
                if (deleted) then begin
                                disposeall2;
                                readinpointers2;
                                if (cur>filesize(mf)) then cur:=filesize(mf);
                end;
          end;
      end;
  until (done);
  close(mf);
  noc:=nocsave;
  dispose(menur);
  dispose(cmdr);
  dispose(hmm);
end;

end.

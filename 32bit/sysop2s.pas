(*****************************************************************************)
(*>                                                                         <*)
(*>  SYSOP2S .PAS -  Written by Eric Oman                                   <*)
(*>                                                                         <*)
(*>  SysOp functions: System Configuration Editor -- "S" command.           <*)
(*>                                                                         <*)
(*>                                                                         <*)
(*****************************************************************************)
{$A+,B+,D-,E+,F+,I+,L+,N-,O+,R-,S+,V-}
unit sysop2s;

interface

uses
  crt, dos, myio, misc,procspec;

procedure postring;

implementation

var dnotfound:boolean;

function getlanguagename:string;
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
                getlanguagename:='';
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
                                getlanguagename:='';
                                exit;
                        end;
                        lang:=1;
                end else begin
                                displaybox('Error recreating LANGUAGE.DAT...',3000);
                                getlanguagename:='';
                                exit;
                end;
        end;
        seek(langf,lang);
        read(langf,langr);
        close(langf);
        s2:=langr.filename;
        getlanguagename:=s2;
end;


procedure displaylang(i:integer; langname:string);
var i2:integer;
    ld:langdefrec;
    langdf:file of langdefrec;
begin
        assign(langdf,adrv(systat.gfilepath)+langname+'.NLD');
        {$I-} reset(langdf); {$I+}
        if (ioresult<>0) then begin
                dnotfound:=TRUE;
        end else begin
                {$I-} seek(langdf,i); {$I+}
                if (ioresult<>0) then begin
                        dnotfound:=TRUE;
                end else begin
                        read(langdf,ld);
                        gotoxy(2,2);
                        textcolor(7);
                        textbackground(0);
                        write('Name          : ');
                        textcolor(3);
                        textbackground(0);
                        cwrite(mln(ld.name,40));
                        for i2:=1 to 5 do begin
                                gotoxy(2,3+i2);
                                cwrite(mln(ld.description[i2],70));
                        end;
                        gotoxy(2,10);
                        textcolor(7);
                        textbackground(0);
                        if (i=0) then begin
                        write('Default Char  : ');
                        textcolor(3);
                        textbackground(0);
                        cwrite(mln(ld.defstring,1));
                        gotoxy(2,11);
                        textcolor(3);
                        textbackground(0);
                        cwrite(mln(' ',70));
                        end else begin
                        write('Default String:  ');
                        gotoxy(2,11);
                        textcolor(3);
                        textbackground(0);
                        cwrite(mln(ld.defstring,70));
                        end;
                end;
                close(langdf);
        end;
end;

function getdesc(i:integer; langname:string):STRING;
var i2:integer;
    ld:langdefrec;
    langdf:file of langdefrec;
begin
        assign(langdf,adrv(systat.gfilepath)+langname+'.NLD');
        {$I-} reset(langdf); {$I+}
        if (ioresult<>0) then begin
                dnotfound:=TRUE;
        end else begin
                {$I-} seek(langdf,i); {$I+}
                if (ioresult<>0) then begin
                        dnotfound:=TRUE;
                end else begin
                        read(langdf,ld);
                        getdesc:=mln(ld.name,40);
                end;
                close(langdf);
        end;
end;

procedure postring;
TYPE TString=STRING[255];
var onpage:integer;
    done:boolean;
    c:char;
    s:string[255];
    w2:windowrec;
    x:integer;
    cur,top:integer;
    rt:returntype;
    c3:char;
    firstlp,lp,lp2:listptr;
    langname:string[8];
    f:file;
    f2:file of tstring;
    si:^stringidx;
    changed:boolean;

procedure readstrings;
var x8:integer;
    s2:tstring;

function gstring(x9:integer):string;
var s3:string;
begin
if (si^.offset[x9]<>-1) then begin
if (si^.offset[x9]<=filesize(f)-1) then begin
seek(f,si^.offset[x9]);
blockread(f,s3[0],1);
blockread(f,s3[1],ord(s3[0]));
end else begin
        displaybox('Error reading string.  File may be corrupted!',3000);
        s3:='';
end;
end else s3:='';
gstring:=s3;
end;

begin
  assign(f,adrv(systat.gfilepath)+langname+'.NXL');
  assign(f2,adrv(systat.gfilepath)+langname+'.NX~');
  {$I-} reset(f,1); {$I+}
  if (ioresult<>0) then begin
        displaybox('Error Reading '+langname+'.NXL...',4000);
        exit;
  end;
  rewrite(f2);
  fillchar(si^,sizeof(si^),#0);
  blockread(f,si^,sizeof(si^));
  for x8:=1 to 2000 do begin
  s2:=gstring(x8);
  write(f2,s2);
  end;
  close(f);
  close(f2);
end;

function readstring(x8:integer):string;
var s2:tstring;
begin
{$I-} reset(f2); {$I+}
if (ioresult<>0) then begin
        displaybox('ERROR reading String!',2000);
        exit;
end;
seek(f2,x8-1);
read(f2,s2);
close(f2);
readstring:=s2;
end;

procedure setstring(x8:integer; s2:tstring);
begin
{$I-} reset(f2); {$I+}
if (ioresult<>0) then begin
        displaybox('ERROR reading String!',2000);
        exit;
end;
seek(f2,x8-1);
write(f2,s2);
close(f2);
end;

procedure compilestrings;
var s2:tstring;
    x2:integer;
begin
{$I-} reset(f2); {$I+}
if (ioresult<>0) then begin
        displaybox('Error updating strings!',2000);
        exit;
end;
rewrite(f,1);
fillchar(si^,sizeof(si^),#0);
blockwrite(f,si^,sizeof(si^));
for x2:=1 to 2000 do begin
seek(f2,x2-1);
read(f2,s2);
if (s2<>'') then begin
si^.offset[x2]:=filepos(f);
blockwrite(f,s2[0],ord(s2[0])+1);
end else si^.offset[x2]:=-1;
end;
seek(f,0);
blockwrite(f,si^,sizeof(si^));
close(f);
close(f2);
end;

begin
  dnotfound:=FALSE;
  changed:=FALSE;
  onpage:=1; done:=FALSE;
  langname:=getlanguagename;
  if (langname='') then exit;
  new(si);
  displaybox2(w,'Decompiling string file...');
  readstrings;
  removewindow(w);

  setwindow2(w,1,7,78,23,3,0,8,'Edit String '+cstr(onpage)+'/2000','String Editor - '+langname,TRUE);
  window(1,1,80,25);
  gotoxy(1,25);
  textcolor(7);
  textbackground(0);
  clreol;
  textcolor(14);
  write('Esc');
  textcolor(7);
  write('=Exit ');
  textcolor(14);
  write('Enter');
  textcolor(7);
  write('=Edit ');
  textcolor(14);
  write('Alt-L');
  textcolor(7);
  write('=List ');
  window(2,8,77,22);
  dnotfound:=TRUE;
  repeat
    if not(dnotfound) then begin
    displaylang(onpage,langname);
    end;
    
    gotoxy(2,13);
    textcolor(15);
    textbackground(1);
    write('Edit String   :');
    textcolor(3);
    textbackground(0);
    gotoxy(18,13);
    write(' ');
    gotoxy(2,15);
    cwrite(mln(readstring(onpage),70));
    while not(keypressed) do begin timeslice; end;
    c:=readkey;
    case c of
        #0:begin
                c:=readkey;
                checkkey(c);
                case c of
{                        #38:begin
                                new(lp);
                                lp^.p:=NIL;
                                displaybox2(w2,'Reading String File...');
                                lp^.list:=getdesc(0,langname);
                                firstlp:=lp;
                                for x:=1 to 2000 do begin
                                new(lp2);
                                lp2^.p:=lp;
                                lp^.n:=lp2;
                                lp2^.list:=getdesc(x,langname);
                                lp:=lp2;
                                end;
                                removewindow(w2);
                                lp^.n:=NIL;
                                top:=onpage+1;
                                cur:=onpage+1;
                                listbox_insert:=FALSE;
                                listbox_delete:=FALSE;
                                listbox_move:=FALSE;
                                listbox_tag:=FALSE;
                                repeat
                                for x:=1 to 100 do rt.data[x]:=-1;
                                x:=-1;
                                lp:=firstlp;
                                listbox(w2,rt,top,cur,lp,18,9,62,22,3,0,8,'Strings','Language: '+langname,TRUE);
                                removewindow(w2);
                                case rt.kind of
                                        0:begin
                                                c3:=chr(rt.data[100]);
                                                checkkey(c3);
                                                rt.data[100]:=-1;
                                                x:=-1;
                                          end;
                                        1:begin
                                                x:=rt.data[1]-1;
                                          end;
                                        2:begin
                                                x:=2001;
                                          end;
                                end;
                                until (x<>-1);
                                                                lp:=firstlp;
                                                                while (lp<>NIL) do begin
                                                                        lp2:=lp^.n;
                                                                        dispose(lp);
                                                                        lp:=lp2;
                                                                end;
                                listbox_insert:=TRUE;
                                listbox_delete:=TRUE;
                                listbox_move:=TRUE;
                                listbox_tag:=TRUE;
                                if (x>=0) and (x<=2000) then onpage:=x;
                            end;}
                        #75:begin
                                dec(onpage);
                                if (onpage<1) then onpage:=2000;
                            end;
                        #77:begin
                                inc(onpage);
                                if (onpage>2000) then onpage:=1;
                             end;
                 end;
            end;
              '0'..'9':begin

  setwindow(w2,25,12,56,14,3,0,8,'',TRUE);
  gotoxy(2,1);
  textcolor(7);
  textbackground(0);
  write('Goto String Number : ');
  gotoxy(23,1);
  s:=c;
  infield_inp_fgrd:=15;
  infield_inp_bkgd:=1;
  infield_out_fgrd:=3;
  infield_out_bkgd:=0;
  infield_allcaps:=false;
  infield_numbers_only:=TRUE;
  infield_min_value:=1;
  infield_max_value:=2000;
  infield_escape_zero:=FALSE;
  infield_escape_blank:=TRUE;
  infield_putatend:=TRUE;
  infield_insert:=FALSE;
  infielde(s,4);
  infield_min_value:=-1;
  infield_max_value:=-1;
  infield_escape_blank:=FALSE;
  infield_putatend:=FALSE;
  infield_insert:=TRUE;
  if (value(s)>=0) and (value(s)<=2000) then begin
  if (s<>'') then onpage:=value(s);
  end;
  removewindow(w2);

                        end;
        #13:begin
                                        gotoxy(2,13);
                                        textcolor(7);
                                        textbackground(0);
                                        write('Edit String   :');
                                        gotoxy(16,13);
                                        textcolor(9);
                                        textbackground(0);
                                        write('>');
                                        gotoxy(2,15);
                                        infield_inp_fgrd:=15;
                                        infield_inp_bkgd:=1;
                                        infield_out_fgrd:=3;
                                        infield_out_bkgd:=0;
                                        infield_allcaps:=false;
                                        infield_numbers_only:=FALSE;
                                        s:=readstring(onpage);
                                        infield_maxshow:=70;
                                        infielde(s,255);
                                        if (s<>readstring(onpage)) then begin
                                        setstring(onpage,s);
                                        changed:=TRUE;
                                        end;
                                        infield_maxshow:=0;
            end;
        #27:done:=TRUE;
     end;
     if not(done) then begin
       setwindow3(w,1,7,78,23,3,0,8,'Edit String '+cstr(onpage)+'/2000','String Editor - '+langname,TRUE)
     end;
  until (done);
  if (changed) then
  if pynqbox('Save Changes? ') then begin
  removewindow(w);
  displaybox2(w,'Compiling string file...');
  compilestrings;
  removewindow(w);
  end else removewindow(w);
  {$I-} erase(f2); {$I+}
  if (ioresult<>0) then begin
        displaybox('Error removing temporary file '+langname+'.NX~',2000);
  end;
  dispose(si);
end;

end.

{$A+,B+,D-,E+,F+,I+,L+,N-,O+,R+,S+,V-}
unit omsset2;

interface

uses dos,crt,misc,myio;

var systatf:file of MatrixREC;
    systat:MatrixREC;

procedure NxWave;

implementation

procedure NxWave;
var n:nxwaverec;
    nxwf:file of nxwaverec;
    c:char;
    s:string;
    b:byte;
    i,x:integer;
    changed,dn:boolean;
    protf:file of protrec;
    prot:protrec;
    choices:array[1..14] of string[30];
    desc:array[1..14] of string[30];
    current:integer;

    procedure getnews;
    var w2:windowrec;
        ch:array[1..5] of string[12];
        c2:char;
        cur:integer;
        dn:boolean;
        s2:string;
    begin
    dn:=FALSE;
    ch[1]:='Filename #1:';
    ch[2]:='Filename #2:';
    ch[3]:='Filename #3:';
    ch[4]:='Filename #4:';
    ch[5]:='Filename #5:';
    setwindow(w2,26,10,54,17,3,0,8,'News/Welcome Files',TRUE);
    textbackground(0);
    for cur:=1 to 5 do begin
    textcolor(7);
    gotoxy(2,cur+1);
    write(ch[cur]);
    textcolor(3);
    write(' '+mln(n.news[cur],12));
    end;
    cur:=1;
    repeat
    gotoxy(2,cur+1);
    textcolor(15);
    textbackground(1);
    write(ch[cur]);
    while not(keypressed) do begin end;
    c2:=readkey;
    case c2 of
        #0:begin
                c2:=readkey;
                case c2 of
                        #72:begin
                                gotoxy(2,cur+1);
                                textcolor(7);
                                textbackground(0);
                                write(ch[cur]);
                                dec(cur);
                                if (cur=0) then cur:=5;
                            end;
                        #80:begin
                                gotoxy(2,cur+1);
                                textcolor(7);
                                textbackground(0);
                                write(ch[cur]);
                                inc(cur);
                                if (cur=6) then cur:=1;
                            end;
                end;
           end;
       #13:begin
                                gotoxy(2,cur+1);
                                textcolor(7);
                                textbackground(0);
                                write(ch[cur]);
                                gotoxy(13,cur+1);
                                textcolor(9);
                                write('>');
                                gotoxy(15,cur+1);
                                infield_inp_fgrd:=15;
                                infield_inp_bkgd:=1;
                                infield_out_fgrd:=3;
                                infield_out_bkgd:=0;
                                infield_allcaps:=TRUE;
                                infield_show_colors:=FALSE;
                                infield_numbers_only:=FALSE;
                                infield_putatend:=TRUE;
                                infield_insert:=TRUE;
                                infield_clear:=TRUE;
                                s2:=n.news[cur];
                                infielde(s2,12);
                                infield_putatend:=FALSE;
                                infield_insert:=FALSE;
                                infield_clear:=FALSE;
                                if (s2<>n.news[cur]) then begin
                                        n.news[cur]:=s2;
                                        changed:=TRUE;
                                end;
           end;
       #27:dn:=TRUE;
    end;
    until (dn);
    removewindow(w2);
    end;

    function dformat(w3:word):string;
    begin
    case w3 of
        0:dformat:='QWK Compatible      ';
        1:dformat:='Blue Wave Compatible';
    end;
    end;

    procedure getsuppress(s:string;var b:byte);
    var c:char;
        x2:integer;
        cho:array[1..3] of string[22];
        done2:boolean;
        cur2:byte;
        w2:windowrec;
    begin
    done2:=FALSE;
    cho[1]:='Default from Nexus    ';
    cho[2]:='Suppress Output       ';
    cho[3]:='DO NOT Suppress Output';
    setwindow(w2,30,12,56,17,3,0,8,s,TRUE);
    textcolor(7);
    textbackground(0);
    for x2:=1 to 3 do begin
        gotoxy(2,x2+1);
        write(cho[x2]);
    end;
    cur2:=1;
    repeat
    gotoxy(2,cur2+1);
    textcolor(15);
    textbackground(1);
    write(cho[cur2]);
    while not(keypressed) do begin end;
    c:=upcase(readkey);
    case c of
        #0:begin
                c:=readkey;
                case c of
                        #72:begin
                                gotoxy(2,cur2+1);
                                textcolor(7);
                                textbackground(0);
                                write(cho[cur2]);
                                dec(cur2);
                                if (cur2=0) then cur2:=3;
                            end;
                        #80:begin
                                gotoxy(2,cur2+1);
                                textcolor(7);
                                textbackground(0);
                                write(cho[cur2]);
                                dec(cur2);
                                if (cur2=4) then cur2:=1;
                            end;
                end;
           end;
       #13:begin
                b:=cur2-1;
                done2:=TRUE;
           end;
       #27:begin
                done2:=TRUE;
           end;
    end;
    until (done2);
    removewindow(w2);
    end;

    function sup(w3:byte):string;
    begin
    case w3 of
        0:sup:='Default As Set In Nexus';
        1:sup:='Yes';
        2:sup:='No';
    end;
    end;



        function showprot(i:integer):string;
        begin
                assign(protf,adrv(systat.gfilepath)+'PROTOCOL.DAT');
                filemode:=66;
                {$I-} reset(protf); {$I+}
                if ioresult<>0 then begin
                        showprot:='None';
                        displaybox('Error Opening PROTOCOL.DAT',3000);
                        exit;
                end;
                if (i<filesize(protf)) then begin
                seek(protf,i);
                read(protf,prot);
                close(protf);
                showprot:=prot.descr;
                end else showprot:='None';
        end;

        function showarc(i:integer):string;
        var af:file of archiverrec;
            a:archiverrec;
        begin
        assign(af,adrv(systat.gfilepath)+'ARCHIVER.DAT');
        {$I-} reset(af); {$I+}
        if (ioresult<>0) then begin
                showarc:='None';
                displaybox('Error Opening ARCHIVER.DAT',3000);
                exit;
        end;
        if (i>filesize(af)-1) then begin
                showarc:=mln('None',40);
                close(af);
                exit;
        end;
        seek(af,i);
        read(af,a);
        if (a.active) then showarc:=mln(a.name,40) else
            showarc:=mln('None',40);
        close(af);
        end;

        procedure getprot;
        var s:string;
            done:boolean;
        begin
                s:='';
                assign(protf,adrv(systat.gfilepath)+'PROTOCOL.DAT');
                filemode:=66;
                {$I-} reset(protf); {$I+}
                if ioresult<>0 then begin
                        displaybox('Error opening PROTOCOL.DAT',3000);
                        exit;
                end;
                done:=FALSE;
                repeat
                clrscr;
                writeln(' Available Protocols:');
                writeln;
                seek(protf,0);
                while not(eof(protf)) do begin
                        read(protf,prot);
                        if (prot.ulcmd<>'') and (prot.dlcmd<>'') then begin
                        write(' '+stripcolor(prot.descr));
                        if (n.defaultprotocol=filepos(protf)-1) then writeln('  [Current]')
                                else writeln;
                        end;
                end;
                seek(protf,0);
                writeln;
                write(' Protocol [Q=Quit] : ');
                {mpkey(s);}
                if (upcase(s[1])='Q') then done:=true else begin
                        while not(eof(protf)) and not(done) do begin
                                read(protf,prot);
                                if (upcase(s[1])=allcaps(prot.ckeys)) and 
                                        ((prot.ulcmd<>'') and (prot.dlcmd<>''))
                                        then begin
                                        n.defaultprotocol:=filepos(protf)-1;
                                        done:=true;
                                end;
                        end;
                end;
                if not(done) then writeln('Invalid Selection.');
        until (done);
        close(protf);
        end;

        function getarc:boolean;
        var af:file of archiverrec;
            a:archiverrec;
    x:integer;
    top,cur:integer;
    firstlp,lp,lp2:listptr;
    rt:returntype;
    w2:windowrec;
    c:char;
    done:boolean;

procedure getlistbox;
var x:integer;
begin
                                new(lp);
                                lp^.p:=NIL;
                                seek(af,1);
                                read(af,a);
                                lp^.list:=mln(a.extension,3)+'  '+mln(a.name,40);
                                firstlp:=lp;
                                for x:=2 to 22 do begin
                                seek(af,x);
                                read(af,a);
                                new(lp2);
                                lp2^.p:=lp;
                                lp^.n:=lp2;
                                lp2^.list:=mln(a.extension,3)+'  '+mln(a.name,40);
                                lp:=lp2;
                                end;
                                lp^.n:=NIL;
end;


        begin
        assign(af,adrv(systat.gfilepath)+'ARCHIVER.DAT');
        {$I-} reset(af); {$I+}
        if (ioresult<>0) then begin
                displaybox('Error reading ARCHIVER.DAT!',3000);
                exit;
        end;
  listbox_goto:=FALSE;
  listbox_goto_offset:=0;
  listbox_insert:=FALSE;
  listbox_delete:=FALSE;
  listbox_tag:=FALSE;
  listbox_move:=FALSE;
  getlistbox;
                                top:=1;
                                cur:=1;
                                repeat
                                for x:=1 to 100 do rt.data[x]:=-1;
                                lp:=firstlp;
                                listbox(w2,rt,top,cur,lp,13,10,67,20,3,0,8,'Select Archiver','',TRUE);
                                case rt.kind of
                                        0:begin
                                                c:=chr(rt.data[100]);
                                                removewindow(w2);
                                                {checkkey(c);}
                                                rt.data[100]:=-1;
                                          end;
                                        1:begin
                                               n.defaultarchiver:=rt.data[1];
                                               getarc:=TRUE;
                                                                lp:=firstlp;
                                                                while (lp<>NIL) do begin
                                                                        lp2:=lp^.n;
                                                                        dispose(lp);
                                                                        lp:=lp2;
                                                                end;
                                                removewindow(w2);
                                                done:=TRUE;
                                          end;
                                        2:begin
                                                done:=TRUE;
                                                getarc:=FALSE;
                                                removewindow(w2);
                                                                lp:=firstlp;
                                                                while (lp<>NIL) do begin
                                                                        lp2:=lp^.n;
                                                                        dispose(lp);
                                                                        lp:=lp2;
                                                                end;
                                          end;
                                end;
                                until (done);


  listbox_insert:=TRUE;
  listbox_delete:=TRUE;
  listbox_tag:=TRUE;
  listbox_move:=TRUE;
  listbox_goto_offset:=0;

        close(af);
        end;

(*        procedure getarc;
        var s:string;
            i:integer;
            done:boolean;
        begin
                s:='';
                done:=FALSE;
                repeat
                clrscr;
                listarctypes2;
                write(' Archiver [Quit] : ');
                {scaninput(s,'Q',TRUE);}
                if (s='Q') then done:=true else 
                                begin
                                                n.defaultarchiver:=value(s);
                                                done:=true;
                                end;
                if not(done) then writeln('Invalid Selection.');
        until (done);
        end; *)

begin
changed:=FALSE;
dn:=FALSE;
filemode:=66;
choices[1]:='BBS ID - Filename          :';
choices[2]:='BBS Software Type          :';
choices[3]:='Local Download Path        :';
choices[4]:='Local Upload Path          :';
choices[5]:='Local Temporary Path       :';
choices[6]:='Default Format             :';
choices[7]:='Default Protocol           :';
choices[8]:='Default Archiver           :';
choices[9]:='Maximum File Requests/Day  :';
choices[10]:='File Request Access String :';
choices[11]:='Maximum Messages/Day       :';
choices[12]:='Maximum KB of Packets/Day  :';
choices[13]:='Suppress Output            -';
choices[14]:='News/Welcome Files          ';
cursoron(FALSE);
assign(nxwf,adrv(systat.gfilepath)+'NXWAVE.DAT');
{$I-} reset(nxwf); {$I+}
      if ioresult<>0 then begin
        with n do begin          
                Packetname:='';
                LocalDLPath:='C:\';
                LocalULPath:='C:\';
                DefaultProtocol:=0;
                DefaultArchiver:=0;
                DefaultFormat:=0;
                for x:=1 to 5 do news[x]:='';
                LocalTempPath:=systat.temppath;
                MaxFreq:=0;
                NewFiles:=FALSE;
                SuppressProtocol:=0;
                SuppressArchiver:=0;
                MaxMsgs:=0;
                MaxK:=0;
                FREQacs:='';
                BBStype:=1;
                for x:=1 to sizeof(res) do res[x]:=0;
                crc:=227;
        end;
        rewrite(nxwf);
        write(nxwf,n);
end;
seek(nxwf,0);
read(nxwf,n);
close(nxwf);
setwindow(w,2,6,78,23,3,0,8,'Offline Mail Configuration',TRUE);
textcolor(7);
textbackground(0);
for x:=1 to 14 do begin
gotoxy(2,x+1);
write(choices[x]);
end;
gotoxy(31,2);
textcolor(3);
textbackground(0);
with n do begin
write(mln(packetname,8));
gotoxy(31,3);
write('Nexus');
gotoxy(31,4);
write(mln(localdlpath,44));
gotoxy(31,5);
write(mln(localulpath,44));
gotoxy(31,6);
write(mln(localtemppath,44));
gotoxy(31,7);
write(dformat(defaultformat));
gotoxy(31,8);
cwrite(showprot(defaultprotocol));
gotoxy(31,9);
write(showarc(defaultarchiver));
gotoxy(31,10);
write(mln(cstr(maxfreq),3));
gotoxy(31,11);
write(mln(freqacs,20));
gotoxy(31,12);
write(mln(cstr(maxmsgs),5));
gotoxy(31,13);
write(mln(cstr(maxk),5));
end;
current:=1;
repeat
gotoxy(2,current+1);
textcolor(15);
textbackground(1);
write(choices[current]);
with n do begin
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
                                if (current=0) then current:=14;
                            end;
                        #80:begin
                                gotoxy(2,current+1);
                                textcolor(7);
                                textbackground(0);
                                write(choices[current]);
                                inc(current);
                                if (current=15) then current:=1;
                            end;
                end;
           end;
        #27:dn:=TRUE;
        #13:begin
                gotoxy(2,current+1);
                textcolor(7);
                textbackground(0);
                write(choices[current]);
                gotoxy(29,current+1);
                textcolor(9);
                write('>');
                gotoxy(31,current+1);
                case current of
                        1:begin
                                infield_inp_fgrd:=15;
                                infield_inp_bkgd:=1;
                                infield_out_fgrd:=3;
                                infield_out_bkgd:=0;
                                infield_allcaps:=TRUE;
                                infield_show_colors:=FALSE;
                                infield_numbers_only:=FALSE;
                                infield_putatend:=TRUE;
                                infield_insert:=TRUE;
                                infield_clear:=TRUE;
                                s:=packetname;
                                infielde(s,8);
                                infield_putatend:=FALSE;
                                infield_insert:=FALSE;
                                infield_clear:=FALSE;
                                if (s<>packetname) then begin
                                        packetname:=s;
                                        changed:=TRUE;
                                end;
                          end;
                        3:begin
                                infield_inp_fgrd:=15;
                                infield_inp_bkgd:=1;
                                infield_out_fgrd:=3;
                                infield_out_bkgd:=0;
                                infield_allcaps:=TRUE;
                                infield_show_colors:=FALSE;
                                infield_numbers_only:=FALSE;
                                infield_put_slash:=TRUE;
                                infield_putatend:=TRUE;
                                infield_insert:=TRUE;
                                infield_clear:=TRUE;
                                infield_maxshow:=44;
                                s:=localdlpath;
                                infielde(s,79);
                                infield_maxshow:=0;
                                infield_put_slash:=FALSE;
                                infield_putatend:=FALSE;
                                infield_insert:=FALSE;
                                infield_clear:=FALSE;
                                if (s<>localdlpath) then begin
                                        localdlpath:=s;
                                        changed:=TRUE;
                                end;
                          end;
                        4:begin
                                infield_inp_fgrd:=15;
                                infield_inp_bkgd:=1;
                                infield_out_fgrd:=3;
                                infield_out_bkgd:=0;
                                infield_allcaps:=TRUE;
                                infield_show_colors:=FALSE;
                                infield_numbers_only:=FALSE;
                                infield_put_slash:=TRUE;
                                infield_putatend:=TRUE;
                                infield_insert:=TRUE;
                                infield_clear:=TRUE;
                                infield_maxshow:=44;
                                s:=localulpath;
                                infielde(s,79);
                                infield_maxshow:=0;
                                infield_put_slash:=FALSE;
                                infield_putatend:=FALSE;
                                infield_insert:=FALSE;
                                infield_clear:=FALSE;
                                if (s<>localulpath) then begin
                                        localulpath:=s;
                                        changed:=TRUE;
                                end;
                          end;
                        5:begin
                                infield_inp_fgrd:=15;
                                infield_inp_bkgd:=1;
                                infield_out_fgrd:=3;
                                infield_out_bkgd:=0;
                                infield_allcaps:=TRUE;
                                infield_show_colors:=FALSE;
                                infield_numbers_only:=FALSE;
                                infield_put_slash:=TRUE;
                                infield_putatend:=TRUE;
                                infield_insert:=TRUE;
                                infield_clear:=TRUE;
                                infield_maxshow:=44;
                                s:=localtemppath;
                                infielde(s,79);
                                infield_maxshow:=0;
                                infield_put_slash:=FALSE;
                                infield_putatend:=FALSE;
                                infield_insert:=FALSE;
                                infield_clear:=FALSE;
                                if (s<>localtemppath) then begin
                                        localtemppath:=s;
                                        changed:=TRUE;
                                end;
                          end;
                        6:begin
                                if (defaultformat=0) then defaultformat:=1 else
                                defaultformat:=0;
                                gotoxy(31,7);
                                textcolor(3);
                                textbackground(0);
                                write(dformat(defaultformat));
                                changed:=TRUE;
                          end;
                        7:begin
                          end;
                        8:begin
                                setwindow4(w,2,6,78,23,8,0,8,'Offline Mail Configuration','',TRUE);
                                if (getarc) then if not(changed) then changed:=TRUE;
                                setwindow5(w,2,6,78,23,8,0,8,'Offline Mail Configuration','',TRUE);
                                window(3,7,77,22);
                                textcolor(3);
                                textbackground(0);
                                gotoxy(31,9);
                                write(showarc(defaultarchiver));
                          end;
                        9:begin
                          end;
                       10:begin
                          end;
                       11:begin
                          end;
                       12:begin
                          end;
                       13:begin
                          end;
                       14:begin
                          getnews;
                          window(3,7,77,22);
                          end;
                end;
            end;
        end;
end;
until (dn);
if (changed) then begin
if pynqbox('Save Changes? ') then begin
        {$I-} reset(nxwf); {$I+}
        if (ioresult<>0) then begin
                displaybox('Error updating NXWAVE.DAT',3000);
                exit;
        end;
        seek(nxwf,0);
        write(nxwf,n);
        close(nxwf);
end;
end;
end;

end.

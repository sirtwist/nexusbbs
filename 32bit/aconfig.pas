{----------------------------------------------------------------------------}
{ Next Epoch matriX User System - Nexus BBS Software                         }
{                                                                            }
{ All material contained herein is (c) Copyright 19996 Intuitive Vision      }
{ Software.  All Rights Reserved.                                            }
{                                                                            }
{ MODULE     :  ACONFIG.PAS  (Archiver Configuration)                        }
{ AUTHOR     :  George A. Roberts IV                                         }
{                                                                            }
{----------------------------------------------------------------------------}
{ Intuitive Vision Software is a Division of Intuitive Vision Computer       }
{ Services.  Nexus, Next Epoch matriX User System, and ivOMS are Trademarks  }
{ of Intuitive Vision Software.                                              }
{----------------------------------------------------------------------------}
{$A+,B+,D-,E+,F+,I+,L+,N-,O+,R-,S+,V-}
unit aconfig;

interface

uses
  crt, dos, myio, misc,procspec;

procedure poarcconfig;

implementation

procedure poarcconfig;
var w2,w3:windowrec;
    current:byte;
    choices:array[1..14] of string[11];
    desc:array[1..14] of string[70];
    af:file of archiverrec;
    a:archiverrec;
    c:char;
    done:boolean;

        procedure editinternal(wh:integer);
        var ch:array[1..8] of string[15];
            cur:integer;
            s:string;
            c2:char;
            auto,d2,change:boolean;

            function showarc2(wh2:integer):string;
            begin
                case wh2 of
                        1:showarc2:='ARC';
                        2:showarc2:='ARJ';
                        3:showarc2:='LHA';
                        4:showarc2:='PAK';
                        5:showarc2:='PKZIP';
                        6:showarc2:='RAR';
                        7:showarc2:='SQZ';
                        8:showarc2:='ZOO';
                        9:showarc2:='Hyper';
                        10:showarc2:='DWC';
                        11:showarc2:='MDCD';
                        12:showarc2:='SIT!';
                        else showarc2:='Error!';
                end;
            end;

            function showlist:string;
            begin
            if (a.listfiles='') then showlist:='*INTERNAL*' else showlist:=a.listfiles;
            end;

        begin
        d2:=FALSE;
        change:=FALSE;
        auto:=FALSE;
        seek(af,wh);
        read(af,a);
        ch[1]:='Active        :';
        ch[2]:='Name          :';
        ch[3]:='List          :';
        ch[4]:='Compress      :';
        ch[5]:='Decompress    :';
        ch[6]:='Test Files    :';
        ch[7]:='Comment       :';
        ch[8]:='Errorlevel    :';
        setwindow2(w3,6,10,72,21,3,0,8,'Edit Archiver ('+showarc2(wh)+')','Archiver Editor',TRUE);
        textcolor(7);
        textbackground(0);
        for cur:=1 to 8 do begin
                gotoxy(2,cur+1);
                write(ch[cur]);
        end;
        textcolor(3);
        textbackground(0);
        gotoxy(18,2);
        write(syn(a.active));
        gotoxy(18,3);
        write(mln(a.name,40));
        gotoxy(18,4);
        write(mln(showlist,40));
        gotoxy(18,5);
        write(mln(a.compress,40));
        gotoxy(18,6);
        write(mln(a.decompress,40));
        gotoxy(18,7);
        write(mln(a.testfiles,40));
        gotoxy(18,8);
        write(mln(a.comment,40));
        gotoxy(18,9);
        write(mln(cstr(a.errorlevel),5));
        cur:=1;
        repeat
        gotoxy(2,cur+1);
        textcolor(15);
        textbackground(1);
        write(ch[cur]);
        while not(keypressed) do begin timeslice; end;
        c2:=readkey;
        case c2 of
                #0:begin
                        c2:=readkey;
                        case c2 of
                                #68:begin
                                        auto:=TRUE;
                                        d2:=TRUE;
                                    end;
                                #72:begin
                                        gotoxy(2,cur+1);
                                        textbackground(0);
                                        textcolor(7);
                                        write(ch[cur]);
                                        dec(cur);
                                        if (cur=0) then cur:=8;
                                    end;
                                #80:begin
                                        gotoxy(2,cur+1);
                                        textbackground(0);
                                        textcolor(7);
                                        write(ch[cur]);
                                        inc(cur);
                                        if (cur=9) then cur:=1;
                                    end;
                        end;
                   end;
                #13:begin
                                        gotoxy(2,cur+1);
                                        textcolor(7);
                                        textbackground(0);
                                        write(ch[cur]);
                                        gotoxy(16,cur+1);
                                        textcolor(9);
                                        textbackground(0);
                                        write('>');
                                        gotoxy(18,cur+1);
                                        infield_inp_fgrd:=15;
                                        infield_inp_bkgd:=1;
                                        infield_out_fgrd:=3;
                                        infield_out_bkgd:=0;
                                        infield_allcaps:=FALSE;
                                        infield_numbers_only:=FALSE;
                                        infield_show_colors:=FALSE;
                                        infield_putatend:=TRUE;
                                        infield_clear:=TRUE;
                        case cur of
                                1:begin
                                        a.active:=not(a.active);
                                        change:=TRUE;
                                        gotoxy(18,cur+1);
                                        textcolor(3);
                                        textbackground(0);
                                        write(syn(a.active));
                                  end;
                                2:begin
                                        s:=a.name;
                                        infield_show_colors:=TRUE;
                                        infielde(s,40);
                                        infield_putatend:=FALSE;
                                        infield_clear:=FALSE;
                                        infield_allcaps:=FALSE;
                                        infield_maxshow:=0;
                                        infield_show_colors:=FALSE;
                                        if (s<>a.name) then begin
                                        change:=TRUE;
                                        a.name:=s;
                                        end;
                                  end;
                                3:begin
                                        infield_maxshow:=45;
                                        s:=a.listfiles;
                                        infielde(s,80);
                                        infield_putatend:=FALSE;
                                        infield_clear:=FALSE;
                                        infield_allcaps:=FALSE;
                                        infield_maxshow:=0;
                                        infield_show_colors:=FALSE;
                                        if (s<>a.listfiles) then begin
                                        change:=TRUE;
                                        a.listfiles:=s;
                                        end;
                                        textcolor(3);
                                        textbackground(0);
                                        gotoxy(18,4);
                                        write(mln(showlist,40));
                                  end;
                                4:begin
                                        infield_maxshow:=45;
                                        s:=a.compress;
                                        infielde(s,80);
                                        infield_putatend:=FALSE;
                                        infield_clear:=FALSE;
                                        infield_allcaps:=FALSE;
                                        infield_maxshow:=0;
                                        infield_show_colors:=FALSE;
                                        if (s<>a.compress) then begin
                                        change:=TRUE;
                                        a.compress:=s;
                                        end;
                                  end;
                                5:begin
                                        infield_maxshow:=45;
                                        s:=a.decompress;
                                        infielde(s,80);
                                        infield_putatend:=FALSE;
                                        infield_clear:=FALSE;
                                        infield_allcaps:=FALSE;
                                        infield_maxshow:=0;
                                        infield_show_colors:=FALSE;
                                        if (s<>a.decompress) then begin
                                        change:=TRUE;
                                        a.decompress:=s;
                                        end;
                                  end;
                                6:begin
                                        infield_maxshow:=45;
                                        s:=a.testfiles;
                                        infielde(s,80);
                                        infield_putatend:=FALSE;
                                        infield_clear:=FALSE;
                                        infield_allcaps:=FALSE;
                                        infield_maxshow:=0;
                                        infield_show_colors:=FALSE;
                                        if (s<>a.testfiles) then begin
                                        change:=TRUE;
                                        a.testfiles:=s;
                                        end;
                                  end;
                                7:begin
                                        infield_maxshow:=45;
                                        s:=a.comment;
                                        infielde(s,80);
                                        infield_putatend:=FALSE;
                                        infield_clear:=FALSE;
                                        infield_allcaps:=FALSE;
                                        infield_maxshow:=0;
                                        infield_show_colors:=FALSE;
                                        if (s<>a.comment) then begin
                                        change:=TRUE;
                                        a.comment:=s;
                                        end;
                                  end;
                                8:begin
                                        s:=cstr(a.errorlevel);
                                        infield_numbers_only:=TRUE;
                                        infield_min_value:=-1;
                                        infield_max_value:=255;
                                        infielde(s,3);
                                        infield_numbers_only:=FALSE;
                                        infield_max_value:=-1;
                                        infield_putatend:=FALSE;
                                        infield_clear:=FALSE;
                                        infield_allcaps:=FALSE;
                                        infield_maxshow:=0;
                                        infield_show_colors:=FALSE;
                                        if (value(s)<>a.errorlevel) then begin
                                        change:=TRUE;
                                        a.errorlevel:=value(s);
                                        end;
                                  end;
                        end;
                    end;
                #27:begin
                        d2:=TRUE;
                    end;
        end;
        until (d2);
        if (change) then begin
        if not(auto) then auto:=pynqbox('Save changes? ');
        if (auto) then begin
                seek(af,wh);
                write(af,a);
        end;
        change:=FALSE;
        end;
        auto:=FALSE;
        removewindow(w3);
        end;

        procedure editexternal;
        var ch:array[1..9] of string[15];
            cur,wh:integer;
            c2:char;
            s:string;
            change,auto,update,editing,d2,arrows:boolean;


        begin
        update:=TRUE;
        d2:=FALSE;
        editing:=FALSE;
        arrows:=FALSE;
        change:=FALSE;
        auto:=FALSE;
        wh:=13;
        ch[1]:='Active        :';
        ch[2]:='Name          :';
        ch[3]:='List          :';
        ch[4]:='Compress      :';
        ch[5]:='Decompress    :';
        ch[6]:='Test Files    :';
        ch[7]:='Comment       :';
        ch[8]:='Errorlevel    :';
        ch[9]:='Extension     :';
        setwindow2(w3,6,10,72,22,3,0,8,'View Archiver '+cstr(wh-12)+'/10','Archiver Editor',TRUE);
        textcolor(7);
        textbackground(0);
        for cur:=1 to 9 do begin
                gotoxy(2,cur+1);
                write(ch[cur]);
        end;
        repeat
        if (update) then begin
        update:=FALSE;
        cur:=1;
        seek(af,wh);
        read(af,a);
        if (editing) then begin
        setwindow3(w3,6,10,72,22,3,0,8,'Edit Archiver '+cstr(wh-12)+'/10','Archiver Editor',TRUE);
        end else begin
        setwindow3(w3,6,10,72,22,3,0,8,'View Archiver '+cstr(wh-12)+'/10','Archiver Editor',TRUE);
        end;
        textcolor(3);
        textbackground(0);
        gotoxy(18,2);
        write(syn(a.active));
        gotoxy(18,3);
        write(mln(a.name,40));
        gotoxy(18,4);
        write(mln(a.listfiles,40));
        gotoxy(18,5);
        write(mln(a.compress,40));
        gotoxy(18,6);
        write(mln(a.decompress,40));
        gotoxy(18,7);
        write(mln(a.testfiles,40));
        gotoxy(18,8);
        write(mln(a.comment,40));
        gotoxy(18,9);
        write(mln(cstr(a.errorlevel),5));
        gotoxy(18,10);
        write(mln(a.extension,3));
        end;
        if (editing) then begin
        gotoxy(2,cur+1);
        textcolor(15);
        textbackground(1);
        write(ch[cur]);
        end;
        while not(keypressed) do begin timeslice; end;
        c2:=readkey;
        case c2 of
                #0:begin
                        c2:=readkey;
                        case c2 of
                                #68:if (editing) then begin
                                        auto:=TRUE;
                                        arrows:=TRUE;
                                        update:=TRUE;
                                        gotoxy(2,cur+1);
                                        textbackground(0);
                                        textcolor(7);
                                        write(ch[cur]);
                                        editing:=FALSE;
                                    end else begin
                                        d2:=TRUE;
                                    end;
                                #72:if (editing) then begin
                                        gotoxy(2,cur+1);
                                        textbackground(0);
                                        textcolor(7);
                                        write(ch[cur]);
                                        dec(cur);
                                        if (cur=0) then cur:=9;
                                    end;
                                #75:if not(editing) then begin
                                        update:=TRUE;
                                        arrows:=TRUE;
                                        dec(wh);
                                        if (wh=12) then wh:=22;
                                    end;
                                #77:if not(editing) then begin
                                        arrows:=TRUE;
                                        update:=TRUE;
                                        inc(wh);
                                        if (wh=23) then wh:=13;
                                    end;
                                #80:if (editing) then begin
                                        gotoxy(2,cur+1);
                                        textbackground(0);
                                        textcolor(7);
                                        write(ch[cur]);
                                        inc(cur);
                                        if (cur=10) then cur:=1;
                                    end;
                                #83:if not(editing) then begin
                                    end;
                        end;
                   end;
                #13:if not(editing) then begin
                        editing:=TRUE;
                        cur:=1;
                        update:=TRUE;
                    end else begin
                                        gotoxy(2,cur+1);
                                        textcolor(7);
                                        textbackground(0);
                                        write(ch[cur]);
                                        gotoxy(16,cur+1);
                                        textcolor(9);
                                        textbackground(0);
                                        write('>');
                                        gotoxy(18,cur+1);
                                        infield_inp_fgrd:=15;
                                        infield_inp_bkgd:=1;
                                        infield_out_fgrd:=3;
                                        infield_out_bkgd:=0;
                                        infield_allcaps:=FALSE;
                                        infield_numbers_only:=FALSE;
                                        infield_show_colors:=FALSE;
                                        infield_putatend:=TRUE;
                                        infield_clear:=TRUE;
                        case cur of
                                1:begin
                                        a.active:=not(a.active);
                                        change:=TRUE;
                                        gotoxy(18,cur+1);
                                        textcolor(3);
                                        textbackground(0);
                                        write(syn(a.active));
                                  end;
                                2:begin
                                        s:=a.name;
                                        infield_show_colors:=TRUE;
                                        infielde(s,40);
                                        infield_putatend:=FALSE;
                                        infield_clear:=FALSE;
                                        infield_allcaps:=FALSE;
                                        infield_maxshow:=0;
                                        infield_show_colors:=FALSE;
                                        if (s<>a.name) then begin
                                        change:=TRUE;
                                        a.name:=s;
                                        end;
                                  end;
                                3:begin
                                        infield_maxshow:=45;
                                        s:=a.listfiles;
                                        infielde(s,80);
                                        infield_putatend:=FALSE;
                                        infield_clear:=FALSE;
                                        infield_allcaps:=FALSE;
                                        infield_maxshow:=0;
                                        infield_show_colors:=FALSE;
                                        if (s<>a.listfiles) then begin
                                        change:=TRUE;
                                        a.listfiles:=s;
                                        end;
                                  end;
                                4:begin
                                        infield_maxshow:=45;
                                        s:=a.compress;
                                        infielde(s,80);
                                        infield_putatend:=FALSE;
                                        infield_clear:=FALSE;
                                        infield_allcaps:=FALSE;
                                        infield_maxshow:=0;
                                        infield_show_colors:=FALSE;
                                        if (s<>a.compress) then begin
                                        change:=TRUE;
                                        a.compress:=s;
                                        end;
                                  end;
                                5:begin
                                        infield_maxshow:=45;
                                        s:=a.decompress;
                                        infielde(s,80);
                                        infield_putatend:=FALSE;
                                        infield_clear:=FALSE;
                                        infield_allcaps:=FALSE;
                                        infield_maxshow:=0;
                                        infield_show_colors:=FALSE;
                                        if (s<>a.decompress) then begin
                                        change:=TRUE;
                                        a.decompress:=s;
                                        end;
                                  end;
                                6:begin
                                        s:=a.testfiles;
                                        infield_maxshow:=45;
                                        infielde(s,80);
                                        infield_putatend:=FALSE;
                                        infield_clear:=FALSE;
                                        infield_allcaps:=FALSE;
                                        infield_maxshow:=0;
                                        infield_show_colors:=FALSE;
                                        if (s<>a.testfiles) then begin
                                        change:=TRUE;
                                        a.testfiles:=s;
                                        end;
                                  end;
                                7:begin
                                        infield_maxshow:=45;
                                        s:=a.comment;
                                        infielde(s,80);
                                        infield_putatend:=FALSE;
                                        infield_clear:=FALSE;
                                        infield_allcaps:=FALSE;
                                        infield_maxshow:=0;
                                        infield_show_colors:=FALSE;
                                        if (s<>a.comment) then begin
                                        change:=TRUE;
                                        a.comment:=s;
                                        end;
                                  end;
                                8:begin
                                        s:=cstr(a.errorlevel);
                                        infield_numbers_only:=TRUE;
                                        infield_min_value:=-1;
                                        infield_max_value:=255;
                                        infielde(s,3);
                                        infield_numbers_only:=FALSE;
                                        infield_max_value:=-1;
                                        infield_putatend:=FALSE;
                                        infield_clear:=FALSE;
                                        infield_allcaps:=FALSE;
                                        infield_maxshow:=0;
                                        infield_show_colors:=FALSE;
                                        if (value(s)<>a.errorlevel) then begin
                                        change:=TRUE;
                                        a.errorlevel:=value(s);
                                        end;
                                  end;
                                9:begin
                                        s:=a.extension;
                                        infield_allcaps:=TRUE;
                                        infielde(s,3);
                                        infield_putatend:=FALSE;
                                        infield_clear:=FALSE;
                                        infield_allcaps:=FALSE;
                                        infield_maxshow:=0;
                                        infield_show_colors:=FALSE;
                                        if (s<>a.extension) then begin
                                        change:=TRUE;
                                        a.extension:=s;
                                        end;
                                  end;

                        end;
                    end;
                #27:if (editing) then begin
                        gotoxy(2,cur+1);
                        textbackground(0);
                        textcolor(7);
                        write(ch[cur]);
                        editing:=FALSE;
                        arrows:=TRUE;
                        update:=TRUE;
                    end else begin
                        d2:=TRUE;
                    end;
        end;
        if (arrows) and (change) then begin
        if not(auto) then auto:=pynqbox('Save changes? ');
        if (auto) then begin
                seek(af,wh);
                write(af,a);
        end;
        change:=FALSE;
        end;
        arrows:=FALSE;
        auto:=FALSE;
        until (d2);
        removewindow(w3);
        end;

        procedure createnewfile;
        var tmp:integer;
        begin
        rewrite(af);
fillchar(a,sizeof(a),#0);
write(af,a);
a.active:=TRUE;
a.name:='System Enhancement Associate''s ARC';
a.listfiles:='';
a.compress:='ARC.EXE -a |ARCNAME| |INFILE|';
a.decompress:='ARC.EXE -eo |ARCNAME| |INFILE|';
a.testfiles:='ARC.EXE -t |ARCNAME|';
a.comment:='';
a.errorlevel:=0;
a.extension:='ARC';
write(af,a);
fillchar(a,sizeof(a),#0);
a.active:=TRUE;
a.name:='Robert Jung''s ARJ';
a.listfiles:='';
a.compress:='ARJ.EXE a -e -m1 -s -t0 -y |ARCNAME| |INFILE|';
a.decompress:='ARJ.EXE e -c -ha -y |ARCNAME| |INFILE|';
a.testfiles:='ARJ.EXE t |ARCNAME|';
a.comment:='ARJ.EXE c |ARCNAME| -z|COMMENT|';
a.errorlevel:=0;
a.extension:='ARJ';
write(af,a);
fillchar(a,sizeof(a),#0);
a.active:=TRUE;
a.name:='Yoshizaki''s LHA';
a.listfiles:='';
a.compress:='LHA.EXE a /mt |ARCNAME| |INFILE|';
a.decompress:='LHA.EXE e /cm |ARCNAME| |INFILE|';
a.testfiles:='LHA.EXE t /m+ |ARCNAME|';
a.comment:='';
a.errorlevel:=0;
a.extension:='LZH';
write(af,a);
fillchar(a,sizeof(a),#0);
a.active:=TRUE;
a.name:='NoGate Consulting''s PAK';
a.listfiles:='';
a.compress:='PAK.EXE A /L /ST |ARCNAME| |INFILE|';
a.decompress:='PAK.EXE E /WA |ARCNAME| |INFILE|';
a.testfiles:='PAK.EXE T |ARCNAME|';
a.comment:='';
a.errorlevel:=0;
a.extension:='PAK';
write(af,a);
fillchar(a,sizeof(a),#0);
a.active:=TRUE;
a.name:='PKWARE, Inc''s PKZIP';
a.listfiles:='';
a.compress:='PKZIP.EXE -a -ex -o |ARCNAME| |INFILE|';
a.decompress:='PKUNZIP.EXE -o -ed |ARCNAME| |INFILE|';
a.testfiles:='PKUNZIP.EXE -t |ARCNAME|';
a.comment:='';
a.errorlevel:=0;
a.extension:='ZIP';
write(af,a);
fillchar(a,sizeof(a),#0);
a.active:=TRUE;
a.name:='Eugene Roshal''s RAR';
a.listfiles:='';
a.compress:='RAR.EXE a -ep -y -c- -std |ARCNAME| |INFILE|';
a.decompress:='RAR.EXE e -o+ -y -c- -p1 -std |ARCNAME| |INFILE|';
a.testfiles:='RAR.EXE t -y -c- -std |ARCNAME| |INFILE|';
a.comment:='RAR.EXE c -y -c- -std |ARCNAME| -z|COMMENT|';
a.errorlevel:=0;
a.extension:='RAR';
write(af,a);
fillchar(a,sizeof(a),#0);
a.active:=TRUE;
a.name:='Hammarberg''s Squeeze-It (SQZ)';
a.listfiles:='';
a.compress:='SQZ.EXE a /p3q0z3 |ARCNAME| |INFILE|';
a.decompress:='SQZ.EXE e /o1 |ARCNAME| |INFILE|';
a.testfiles:='SQZ.EXE t |ARCNAME|';
a.comment:='SQZ.EXE c |ARCNAME| |COMMENT|';
a.errorlevel:=0;
a.extension:='SQZ';
write(af,a);
fillchar(a,sizeof(a),#0);
a.active:=TRUE;
a.name:='Dhesi''s ZOO';
a.listfiles:='';
a.compress:='ZOO.EXE a: |ARCNAME| |INFILE|';
a.decompress:='ZOO.EXE eO |ARCNAME| |INFILE|';
a.testfiles:='ZOO.EXE e:N |ARCNAME|';
a.comment:='';
a.errorlevel:=0;
a.extension:='ZOO';
write(af,a);
fillchar(a,sizeof(a),#0);
a.active:=FALSE;
a.name:='Hyper';
a.listfiles:='';
a.compress:='';
a.decompress:='';
a.testfiles:='';
a.comment:='';
a.errorlevel:=0;
a.extension:='HYP';
write(af,a);
fillchar(a,sizeof(a),#0);
a.active:=FALSE;
a.name:='DWC';
a.listfiles:='';
a.compress:='';
a.decompress:='';
a.testfiles:='';
a.comment:='';
a.errorlevel:=0;
a.extension:='DWC';
write(af,a);
fillchar(a,sizeof(a),#0);
a.name:='MDCD';
a.active:=FALSE;
a.listfiles:='';
a.compress:='';
a.decompress:='';
a.testfiles:='';
a.comment:='';
a.errorlevel:=0;
a.extension:='';
write(af,a);
fillchar(a,sizeof(a),#0);
a.name:='Macintosh SIT! Format';
a.active:=FALSE;
a.listfiles:='';
a.compress:='';
a.decompress:='';
a.testfiles:='';
a.comment:='';
a.errorlevel:=0;
a.extension:='SIT';
write(af,a);
for tmp:=1 to 10 do begin
fillchar(a,sizeof(a),#0);
a.name:='Unused Archiver';
a.active:=FALSE;
a.listfiles:='';
a.compress:='';
a.decompress:='';
a.testfiles:='';
a.comment:='';
a.errorlevel:=0;
a.extension:='';
write(af,a);
end;
end;

function showarc(x:integer):string;
begin
seek(af,x);
read(af,a);
showarc:=mln(a.compress,28)+'    '+mln(a.decompress,28);
end;

begin
done:=FALSE;
assign(af,adrv(systat.gfilepath)+'ARCHIVER.DAT');
{$I-} reset(af); {$I+}
if (ioresult<>0) then begin
        displaybox('Error reading ARCHIVER.DAT... creating.',2000);
        createnewfile;
        seek(af,0);
end;
choices[1]:='ARC       :';
choices[2]:='ARJ       :';
choices[3]:='LHA       :';
choices[4]:='PAK       :';
choices[5]:='PKZIP     :';
choices[6]:='RAR       :';
choices[7]:='SQZ       :';
choices[8]:='ZOO       :';
choices[9]:='Hyper     :';
choices[10]:='DWC       :';
choices[11]:='MDCD      :';
choices[12]:='SIT!      :';
choices[13]:='Additional ';
setwindow(w2,2,7,77,23,3,0,8,'Archiver Configuration',TRUE);
textcolor(7);
textbackground(0);
for current:=1 to 13 do begin
        gotoxy(2,current+1);
        write(choices[current]);
end;
for current:=1 to 12 do begin
        seek(af,current);
        read(af,a);
        desc[current]:='%140%Esc%070%=Exit %140%'+a.name;
end;
desc[13]:='%140%Esc%070%=Exit %140%Additional archivers not internally supported';
textcolor(3);
textbackground(0);
for current:=1 to 12 do begin
        gotoxy(14,current+1);
        write(showarc(current));
end;
current:=1;
repeat
window(1,1,80,25);
gotoxy(1,25);
textcolor(14);
textbackground(0);
clreol;
cwrite(desc[current]);
window(3,8,76,22);
gotoxy(2,current+1);
textcolor(15);
textbackground(1);
write(choices[current]);
while not(keypressed) do begin timeslice; end;
c:=readkey;
case c of
        #0:begin
                c:=readkey;
                case c of
                        #68:done:=TRUE;
                        #72:begin
                                textcolor(7);
                                textbackground(0);
                                gotoxy(2,current+1);
                                write(choices[current]);
                                dec(current);
                                if (current=0) then current:=13;
                            end;
                        #80:begin
                                textcolor(7);
                                textbackground(0);
                                gotoxy(2,current+1);
                                write(choices[current]);
                                inc(current);
                                if (current=14) then current:=1;
                            end;
                end;
           end;
       #13:begin
           setwindow4(w2,2,7,77,23,8,0,8,'Archiver Configuration','',TRUE);
           textcolor(7);
           textbackground(0);
           gotoxy(2,current+1);
           write(choices[current]);
           if (current=13) then editexternal else
                editinternal(current);
           setwindow5(w2,2,7,77,23,3,0,8,'Archiver Configuration','',TRUE);
           window(3,8,76,22);
           end;
      #27:begin
                done:=TRUE;
          end;
end;
until (done);
removewindow(w2);
close(af);
end;

end.

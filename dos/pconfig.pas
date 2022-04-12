{----------------------------------------------------------------------------}
{ Nexus Bulletin Board System                                                }
{                                                                            }
{ All material contained herein is                                           }
{  (c) Copyright 1996 Epoch Software.  All Rights Reserved.                  }
{  (c) Copyright 1994-95 Intuitive Vision Software.  All Rights Reserved.    }
{                                                                            }
{ MODULE     :  ACONFIG.PAS (Archiver Configuration)                         }
{ AUTHOR     :  George A. Roberts IV                                         }
{                                                                            }
{----------------------------------------------------------------------------}
{ Nexus and Nexecutable are trademarks of Epoch Software.                    }
{----------------------------------------------------------------------------}
{$A+,B+,D-,E+,F+,I+,L+,N-,O+,R-,S+,V-}
unit pconfig;

interface

uses
  crt, dos, myio, misc,procspec;

procedure protconfig;

implementation

procedure protconfig;
var w2,w3:windowrec;
    current:byte;
    choices:array[1..11] of string[11];
    desc:array[1..11] of string[70];
    pf:file of protrec;
    p:protrec;
    c:char;
    changed,done:boolean;


    function showflags:string;
    var s8:string;
    begin
    s8:='';
    if (xbbatch in p.xbstat) then s8:=s8+'Batch ';
    if (xbResume in p.xbstat) then s8:=s8+'Resume ';
    if (xbNameSingle in p.xbstat) then s8:=s8+'AskName ';
    if (xbINTERNAL in p.xbstat) and (xbMiniDisplay in p.xbstat) then
        s8:=s8+'MiniDisplay';
    if (s8='') then s8:='None';
    showflags:=s8;
    end;

    procedure getflags;
    var w8:windowrec;
        cho:array[1..4] of string;
        cur2:integer;
        mshow:integer;
        c2:char;
        d2:boolean;
    begin
    mshow:=3;
    cho[1]:='Batch Supported              :';
    cho[2]:='Resume Supported             :';
    cho[3]:='Ask For Filename When Single :';
    if (xbINTERNAL in p.xbstat) then begin
    cho[4]:='Use MiniDisplay Mode         :';
    mshow:=4;
    end;
    setwindow(w8,20,8,60,11+mshow,3,0,8,'Protocol Flags',TRUE);
    gotoxy(2,2);
    textcolor(7);
    textbackground(0);
    write(cho[1]);
    gotoxy(2,3);
    write(cho[2]);
    gotoxy(2,4);
    write(cho[3]);
    if (mshow=4) then begin
    gotoxy(2,5);
    write(cho[4]);
    end;
    d2:=FALSE;
    gotoxy(33,2);
    textcolor(3);
    write(aonoff(xbBatch in p.xbstat,'Yes','No '));
    gotoxy(33,3);
    write(aonoff(xbResume in p.xbstat,'Yes','No '));
    gotoxy(33,4);
    write(aonoff(xbNameSingle in p.xbstat,'Yes','No '));
    if (mshow=4) then begin
    gotoxy(33,5);
    write(aonoff(xbMiniDisplay in p.xbstat,'Yes','No '));
    end;
    cur2:=1;
    repeat
    textcolor(15);
    textbackground(1);
    gotoxy(2,cur2+1);
    write(cho[cur2]);
    while not(keypressed) do begin timeslice; end;
    c2:=readkey;
    case c2 of
        #0:begin
                c2:=readkey;
                case c2 of
                        #68:d2:=TRUE;
                        #72:begin
                                gotoxy(2,cur2+1);
                                textcolor(7);
                                textbackground(0);
                                write(cho[cur2]);
                                dec(cur2);
                                if (cur2=0) then cur2:=mshow;
                            end;
                        #80:begin
                                gotoxy(2,cur2+1);
                                textcolor(7);
                                textbackground(0);
                                write(cho[cur2]);
                                inc(cur2);
                                if (cur2=mshow+1) then cur2:=1;
                        end;
                end;
        end;
        #13:begin
                case cur2 of
                        1:begin
                                changed:=TRUE;
                                if (xbBatch in p.xbstat) then
                                p.xbstat:=p.xbstat-[xbbatch]
                                else
                                p.xbstat:=p.xbstat+[xbbatch];
                                gotoxy(33,2);
                                textcolor(3);
                                textbackground(0);
                                write(aonoff(xbBatch in p.xbstat,'Yes','No '));
                          end;
                        2:begin
                                changed:=TRUE;
                                if (xbResume in p.xbstat) then
                                p.xbstat:=p.xbstat-[xbresume]
                                else
                                p.xbstat:=p.xbstat+[xbresume];
                                gotoxy(33,3);
                                textcolor(3);
                                textbackground(0);
                                write(aonoff(xbresume in p.xbstat,'Yes','No '));
                          end;
                        3:begin
                                changed:=TRUE;
                                if (xbNameSingle in p.xbstat) then
                                p.xbstat:=p.xbstat-[xbnamesingle]
                                else
                                p.xbstat:=p.xbstat+[xbnamesingle];
                                gotoxy(33,4);
                                textcolor(3);
                                textbackground(0);
                                write(aonoff(xbnamesingle in p.xbstat,'Yes','No '));
                          end;
                        4:begin
                                changed:=TRUE;
                                if (xbMiniDisplay in p.xbstat) then
                                p.xbstat:=p.xbstat-[xbMiniDisplay]
                                else
                                p.xbstat:=p.xbstat+[xbMiniDisplay];
                                gotoxy(33,5);
                                textcolor(3);
                                textbackground(0);
                                write(aonoff(xbMiniDisplay in p.xbstat,'Yes','No '));
                          end;
                end;
        end;
        #27:d2:=TRUE;
    end;
    until (d2);
    removewindow(w8);
    end;


procedure editexternal;
var wrd:word;
    i1,i2,ii,xloaded:integer;
    c:char;
    abort,next:boolean;
    st:astr;

  procedure xed(i:integer);
  var x:integer;
  begin
    if (i>=0) and (i<=filesize(pf)-1) then begin
      if (i>=0) and (i<filesize(pf)-1) then
        for x:=i to filesize(pf)-2 do begin
          seek(pf,x+1); read(pf,p);
          seek(pf,x); write(pf,p);
        end;
      seek(pf,filesize(pf)-1); truncate(pf);
    end;
  end;

  procedure xei(i:integer);
  var x:integer;
  begin
    if (i>=0) and (i<=filesize(pf)) and (filesize(pf)<maxprotocols) then begin
      for x:=filesize(pf)-1 downto i do begin
        seek(pf,x); read(pf,p);
        write(pf,p);  (* to next record *)
      end;
      with p do begin
        xbstat:=[xbActive];
        ckeys:='!';
        descr:='%030%(%150%!%030%) New External Protocol';
        acs:='';
        templog:='';
        uloadlog:=''; dloadlog:='';
        ulcmd:=''; dlcmd:='';
        ulcode:=0; dlcode:=0;
        envcmd:='';
        dlflist:='';
        maxchrs:=128;
        logpf:=0; logps:=0;
        fillchar(reserved,sizeof(reserved),#0);
      end;
      seek(pf,i); write(pf,p);
    end;
  end;

  procedure xem;
  var s:astr;
      x,i,j,i1,i2,ii,ii4:integer;
      c,c1:char;
      bb:byte;
      choices:array[1..13] of string;
      current:integer;
      w2:windowrec;
      arrows,editing,done,update,b:boolean;


  begin
    xloaded:=-1;
    ii:=11;
    c:=' ';
    editing:=FALSE;
    update:=TRUE;
    arrows:=FALSE;
    done:=FALSE;
    choices[1]:='Active                :';
    choices[2]:='Description           :';
    choices[3]:='Command Key           :';
    choices[4]:='Access String         :';
    choices[5]:='Protocol Flags        :';
    choices[6]:='Upload Batch File     :';
    choices[7]:='Download Batch File   :';
    choices[8]:='Upload Errorlevel     :';
   choices[9]:='Download Errorlevel   :';
   choices[10]:='Environment Command   :';
   choices[11]:='Download Filelist     :';
   choices[12]:='Max Commandline Chars :';
   choices[13]:='Log File Configuration ';
   setwindow2(w,1,6,78,22,3,0,8,'View Protocol '+cstr(ii+1)+'/'+cstr(filesize(pf)),
        'Protocol Editor',TRUE);
   for x:=1 to 13 do begin
        gotoxy(2,x+1);
        textcolor(7);
        textbackground(0);
        write(choices[x]);
   end;
   current:=1;
   cursoron(FALSE);
   if (ii>=0) and (ii<=filesize(pf)-1) then begin
        with p do
        repeat
        arrows:=FALSE;
        if (xloaded<>ii) then begin
          seek(pf,ii); read(pf,p);
          xloaded:=ii; changed:=FALSE;
        end;
        if (update) then begin
                update:=FALSE;
                if (editing) then begin
   setwindow3(w,1,6,78,22,3,0,8,'Edit Protocol '+cstr(ii-10)+'/'+cstr(filesize(pf)-11),
        'Protocol Editor',TRUE);
                end else begin
   setwindow3(w,1,6,78,22,3,0,8,'View Protocol '+cstr(ii-10)+'/'+cstr(filesize(pf)-11),
        'Protocol Editor',TRUE);
                end;
        gotoxy(26,2);
        textcolor(3);
        textbackground(0);
        write(aonoff(xbactive in xbstat,'Yes','No '));
        gotoxy(26,3);
        textcolor(3);
        textbackground(0);
        cwrite(mln(descr,45));
        gotoxy(26,4);
        write(ckeys);
        gotoxy(26,5);
        write(mln(acs,20));
        gotoxy(26,6);
        write(mln(showflags,40));
        gotoxy(26,7);
        write(mln(ulcmd,40));
        gotoxy(26,8);
        write(mln(dlcmd,40));
        gotoxy(26,9);
        write(mln(cstr(ulcode),5));
        gotoxy(26,10);
        write(mln(cstr(dlcode),5));
        gotoxy(26,11);
        write(mln(envcmd,25));
        gotoxy(26,12);
        write(mln(dlflist,25));
        gotoxy(26,13);
        write(mln(cstr(maxchrs),5));
        end;
        if (editing) then begin
        textcolor(15);
        textbackground(1);
        gotoxy(2,current+1);
        write(choices[current]);
        end;
            while not(keypressed) do begin timeslice; end;
            c:=readkey;
            case c of
              #0:begin
                 c:=readkey;
                 checkkey(c);
                 case c of
                        #72:if (editing) then begin
                            gotoxy(2,current+1);
                            textcolor(7);
                            textbackground(0);
                            write(choices[current]);
                            dec(current);
                            if (current=0) then current:=13;
                            end;
                        #75:if not(editing) then begin
                            dec(ii);
                            if (ii<11) then ii:=filesize(pf)-1;
                            update:=TRUE;
                            arrows:=TRUE;
                            end;
                        #77:if not(editing) then begin
                            inc(ii);
                            if (ii>filesize(pf)-1) then ii:=11;
                            update:=TRUE;
                            arrows:=TRUE;
                            end;
                        #80:if (editing) then begin
                            gotoxy(2,current+1);
                            textcolor(7);
                            textbackground(0);
                            write(choices[current]);
                            inc(current);
                            if (current=14) then current:=1;
                            end;
                        #82:if not(editing) then begin
                            xei(ii+1);
                            inc(ii);
                            update:=TRUE;
                            arrows:=TRUE;
                            end;
                        #68:if (editing) then begin
                        seek(pf,xloaded); write(pf,p);
                        window(2,7,77,22);
                        changed:=FALSE;
                        editing:=FALSE;
                        update:=TRUE;
                        arrows:=TRUE;
                        gotoxy(2,current+1);
                        textcolor(7);
                        textbackground(0);
                        write(choices[current]);
                        current:=1;
                            end;
                        #83:if not(editing) then begin
                                yndefault:=FALSE;
                                if pynqbox('Delete '+stripcolor(descr)+'? ') then begin
                                        xed(ii);
                                        if (ii>filesize(pf)-1) then ii:=filesize(pf)-1;
                                        update:=TRUE;
                                        arrows:=TRUE;
                                end;
                                yndefault:=TRUE;
                                window(2,7,77,22);
                            end;
                 end;
                 end;
              #27:if (editing) then begin
                        editing:=FALSE;
                        update:=TRUE;
                        arrows:=TRUE;
                        gotoxy(2,current+1);
                        textcolor(7);
                        textbackground(0);
                        write(choices[current]);
                        current:=1;
                   end else done:=TRUE;
              '0'..'9':if not(editing) then begin

  setwindow(w2,28,12,53,14,3,0,8,'',TRUE);
  gotoxy(2,1);
  textcolor(7);
  textbackground(0);
  write('Goto Protocol  : ');
  gotoxy(19,1);
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
  infield_insert:=TRUE;
  infielde(s,5);
  infield_escape_blank:=FALSE;
  infield_putatend:=FALSE;
  infield_insert:=TRUE;
  if (s='') then ii4:=0 else
  ii4:=value(s);
  if (ii4>0) and (ii4<=filesize(pf)-11) then begin
  if (s<>'') then begin
  ii:=ii4+10;
  update:=TRUE;
  arrows:=TRUE;
  end;
  end;
  removewindow(w2);

                        end;
              #13:begin
                 if not(editing) then begin
                        editing:=TRUE;
                        update:=TRUE;
                        current:=1;
                 end else
                        case current of
                        1:begin
                      if (xbactive in xbstat) then xbstat:=xbstat-[xbactive] else
                      xbstat:=xbstat+[xbactive];
                      changed:=true;
        gotoxy(26,3);
        textcolor(3);
        textbackground(0);
        write(aonoff(xbactive in xbstat,'Yes','No '));
                          end;
                        2:begin
                                        gotoxy(2,current+1);
                                        textcolor(7);
                                        textbackground(0);
                                        write(choices[current]);
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
                                        infield_show_colors:=TRUE;
                                        s:=descr;
                                        infielde(s,40);
                                        infield_maxshow:=0;
                                        infield_show_colors:=FALSE;
                                        if (s<>descr) then begin
                                                changed:=TRUE;
                                                descr:=s;
                                        end;
                        end;
                        3:begin
                                        gotoxy(2,current+1);
                                        textcolor(7);
                                        textbackground(0);
                                        write(choices[current]);
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
                                        s:=ckeys;
                                        infielde(s,1);
                                        infield_maxshow:=0;
                                        infield_show_colors:=FALSE;
                                        if (s[1]<>ckeys) then begin
                                        changed:=TRUE;
                                        ckeys:=s[1];
                                        end;
                        end;
                        4:begin
                                        gotoxy(2,current+1);
                                        textcolor(7);
                                        textbackground(0);
                                        write(choices[current]);
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
                                        s:=acs;
                                        infielde(s,20);
                                        infield_maxshow:=0;
                                        infield_show_colors:=FALSE;
                                        if (s<>acs) then begin
                                        changed:=TRUE;
                                        acs:=s;
                                        end;
                        end;
                        5:begin
                                gotoxy(2,current+1);
                                textcolor(7);
                                textbackground(0);
                                write(choices[current]);
   setwindow4(w,1,6,78,22,8,0,8,'Edit Protocol '+cstr(ii+1)+'/'+cstr(filesize(pf)),
        'Protocol Editor',TRUE);
                                getflags;
   setwindow5(w,1,6,78,22,3,0,8,'Edit Protocol '+cstr(ii+1)+'/'+cstr(filesize(pf)),
        'Protocol Editor',TRUE);
                                window(2,7,77,22);
                                textcolor(3);
                                textbackground(0);
                                gotoxy(26,6);
                                write(mln(showflags,40));
                          end;
                        6:begin
                                        gotoxy(2,current+1);
                                        textcolor(7);
                                        textbackground(0);
                                        write(choices[current]);
                                        gotoxy(24,current+1);
                                        textcolor(9);
                                        textbackground(0);
                                        write('>');
                                        gotoxy(26,current+1);
                                        infield_inp_fgrd:=15;
                                        infield_inp_bkgd:=1;
                                        infield_out_fgrd:=3;
                                        infield_out_bkgd:=0;
                                        infield_allcaps:=FALSE;
                                        infield_numbers_only:=FALSE;
                                        infield_show_colors:=FALSE;
                                        infield_putatend:=TRUE;
                                        infield_clear:=TRUE;
                                        infield_maxshow:=45;
                                        s:=ulcmd;
                                        infielde(s,79);
                                        infield_putatend:=FALSE;
                                        infield_clear:=FALSE;
                                        infield_allcaps:=FALSE;
                                        infield_maxshow:=0;
                                        infield_show_colors:=FALSE;
                                        if (s<>ulcmd) then begin
                                        changed:=TRUE;
                                        ulcmd:=s;
                                        end;
                          end;
                        7:begin
                                        gotoxy(2,current+1);
                                        textcolor(7);
                                        textbackground(0);
                                        write(choices[current]);
                                        gotoxy(24,current+1);
                                        textcolor(9);
                                        textbackground(0);
                                        write('>');
                                        gotoxy(26,current+1);
                                        infield_inp_fgrd:=15;
                                        infield_inp_bkgd:=1;
                                        infield_out_fgrd:=3;
                                        infield_out_bkgd:=0;
                                        infield_allcaps:=FALSE;
                                        infield_numbers_only:=FALSE;
                                        infield_show_colors:=FALSE;
                                        infield_maxshow:=45;
                                        infield_putatend:=TRUE;
                                        infield_clear:=TRUE;
                                        s:=dlcmd;
                                        infielde(s,79);
                                        infield_putatend:=FALSE;
                                        infield_clear:=FALSE;
                                        infield_allcaps:=FALSE;
                                        infield_maxshow:=0;
                                        infield_show_colors:=FALSE;
                                        if (s<>dlcmd) then begin
                                        changed:=TRUE;
                                        dlcmd:=s;
                                        end;
                          end;
                        8:begin
                                        gotoxy(2,current+1);
                                        textcolor(7);
                                        textbackground(0);
                                        write(choices[current]);
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
                                        infield_numbers_only:=TRUE;
                                        infield_show_colors:=FALSE;
                                        infield_min_value:=0;
                                        infield_putatend:=TRUE;
                                        infield_clear:=TRUE;
                                        infield_max_value:=255;
                                        s:=cstr(ulcode);
                                        infielde(s,3);
                                        infield_min_value:=-1;
                                        infield_putatend:=false;
                                        infield_clear:=false;
                                        infield_max_value:=-1;
                                        infield_numbers_only:=FALSE;
                                        infield_maxshow:=0;
                                        infield_show_colors:=FALSE;
                                        if (value(s)<>ulcode) then begin
                                        changed:=TRUE;
                                        ulcode:=value(s);
                                        end;
                          end;
                       9:begin
                                        gotoxy(2,current+1);
                                        textcolor(7);
                                        textbackground(0);
                                        write(choices[current]);
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
                                        infield_numbers_only:=TRUE;
                                        infield_putatend:=TRUE;
                                        infield_clear:=TRUE;
                                        infield_min_value:=0;
                                        infield_max_value:=255;
                                        infield_show_colors:=FALSE;
                                        s:=cstr(dlcode);
                                        infielde(s,3);
                                        infield_min_value:=-1;
                                        infield_max_value:=-1;
                                        infield_putatend:=false;
                                        infield_clear:=false;
                                        infield_maxshow:=0;
                                        infield_show_colors:=FALSE;
                                        infield_numbers_only:=FALSE;
                                        if (value(s)<>dlcode) then begin
                                        changed:=TRUE;
                                        dlcode:=value(s);
                                        end;
                          end;
                       10:begin
                                        gotoxy(2,current+1);
                                        textcolor(7);
                                        textbackground(0);
                                        write(choices[current]);
                                        gotoxy(24,current+1);
                                        textcolor(9);
                                        textbackground(0);
                                        write('>');
                                        gotoxy(26,current+1);
                                        infield_inp_fgrd:=15;
                                        infield_inp_bkgd:=1;
                                        infield_out_fgrd:=3;
                                        infield_out_bkgd:=0;
                                        infield_allcaps:=FALSE;
                                        infield_numbers_only:=FALSE;
                                        infield_show_colors:=FALSE;
                                        infield_maxshow:=45;
                                        infield_putatend:=TRUE;
                                        infield_clear:=TRUE;
                                        s:=envcmd;
                                        infielde(s,60);
                                        infield_putatend:=FALSE;
                                        infield_clear:=FALSE;
                                        infield_allcaps:=FALSE;
                                        infield_maxshow:=0;
                                        infield_show_colors:=FALSE;
                                        if (s<>envcmd) then begin
                                        changed:=TRUE;
                                        envcmd:=s;
                                        end;
                          end;
                       11:begin
                                        gotoxy(2,current+1);
                                        textcolor(7);
                                        textbackground(0);
                                        write(choices[current]);
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
                                        infield_show_colors:=FALSE;
                                        infield_putatend:=TRUE;
                                        infield_clear:=TRUE;
                                        s:=dlflist;
                                        infielde(s,25);
                                        infield_putatend:=FALSE;
                                        infield_clear:=FALSE;
                                        infield_allcaps:=FALSE;
                                        infield_maxshow:=0;
                                        infield_show_colors:=FALSE;
                                        if (s<>dlflist) then begin
                                        changed:=TRUE;
                                        dlflist:=s;
                                        end;
                          end;
                       12:begin
                                        gotoxy(2,current+1);
                                        textcolor(7);
                                        textbackground(0);
                                        write(choices[current]);
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
                                        infield_numbers_only:=TRUE;
                                        infield_show_colors:=FALSE;
                                        infield_min_value:=0;
                                        infield_putatend:=TRUE;
                                        infield_clear:=TRUE;
                                        infield_max_value:=255;
                                        s:=cstr(maxchrs);
                                        infielde(s,3);
                                        infield_min_value:=-1;
                                        infield_putatend:=false;
                                        infield_clear:=false;
                                        infield_max_value:=-1;
                                        infield_numbers_only:=FALSE;
                                        infield_maxshow:=0;
                                        infield_show_colors:=FALSE;
                                        if (value(s)<>maxchrs) then begin
                                        changed:=TRUE;
                                        maxchrs:=value(s);
                                        end;
                          end;
                       13:begin
                          end;
                        end;
                  end;
            end;
          if (changed) and ((done) or (arrows)) then begin
              if pynqbox('Save Changes? ') then begin
              seek(pf,xloaded); write(pf,p);
              end;
              window(2,7,77,21);
              changed:=FALSE;
          end;
          until (done);
    end;
    removewindow(w);
  end;

begin
  xloaded:=-1; c:=#0;
  xem;
end;








        procedure editinternal(wh:integer);
        var ch:array[1..5] of string[15];
            cur:integer;
            s:string;
            c2:char;
            auto,d2,change:boolean;

            function showprot2(wh2:integer):string;
            begin
                case wh2 of
                        1:showprot2:='Zmodem';
                        2:showprot2:='Ymodem/G';
                        3:showprot2:='Ymodem';
                        4:showprot2:='Xmodem/1K';
                        5:showprot2:='Xmodem';
                        else showprot2:='Error!';
                end;
            end;


        begin
        d2:=FALSE;
        auto:=FALSE;
        change:=FALSE;
        seek(pf,wh);
        read(pf,p);
        ch[1]:='Active        :';
        ch[2]:='Description   :';
        ch[3]:='Command Key   :';
        ch[4]:='Access String :';
        ch[5]:='Flags         :';
        setwindow2(w3,6,10,72,18,3,0,8,'Edit Protocol ('+showprot2(wh)+')','Protocol Editor',TRUE);
        textcolor(7);
        textbackground(0);
        for cur:=1 to 5 do begin
                gotoxy(2,cur+1);
                write(ch[cur]);
        end;
        textcolor(3);
        textbackground(0);
        gotoxy(18,2);
        write(syn(xbactive in p.xbstat));
        gotoxy(18,3);
        cwrite(mln(p.descr,45));
        gotoxy(18,4);
        write(p.ckeys);
        gotoxy(18,5);
        write(mln(p.acs,40));
        gotoxy(18,6);
        write(mln(showflags,40));
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
                                        if (cur=0) then cur:=5;
                                    end;
                                #80:begin
                                        gotoxy(2,cur+1);
                                        textbackground(0);
                                        textcolor(7);
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
                      if (xbactive in p.xbstat) then p.xbstat:=p.xbstat-[xbactive] else
                      p.xbstat:=p.xbstat+[xbactive];
                      change:=true;
                        gotoxy(18,cur+1);
                        textcolor(3);
                        textbackground(0);
                        write(aonoff(xbactive in p.xbstat,'Yes','No '));
                                  end;
                                2:begin
                                        s:=p.descr;
                                        infield_show_colors:=TRUE;
                                        infield_maxshow:=45;
                                        infielde(s,70);
                                        infield_maxshow:=0;
                                        infield_putatend:=FALSE;
                                        infield_clear:=FALSE;
                                        infield_allcaps:=FALSE;
                                        infield_maxshow:=0;
                                        infield_show_colors:=TRUE;
                                        if (s<>p.descr) then begin
                                        change:=TRUE;
                                        p.descr:=s;
                                        end;
                                  end;
                                3:begin
                                        infield_inp_fgrd:=15;
                                        infield_inp_bkgd:=1;
                                        infield_out_fgrd:=3;
                                        infield_out_bkgd:=0;
                                        infield_allcaps:=TRUE;
                                        infield_numbers_only:=FALSE;
                                        s:=p.ckeys;
                                        infielde(s,1);
                                        infield_maxshow:=0;
                                        infield_show_colors:=FALSE;
                                        if (s[1]<>p.ckeys) then begin
                                        change:=TRUE;
                                        p.ckeys:=s[1];
                                        end;
                                  end;
                                4:begin
                                        infield_allcaps:=TRUE;
                                        s:=p.acs;
                                        infielde(s,20);
                                        infield_putatend:=FALSE;
                                        infield_clear:=FALSE;
                                        infield_allcaps:=FALSE;
                                        infield_maxshow:=0;
                                        infield_show_colors:=FALSE;
                                        if (s<>p.acs) then begin
                                        change:=TRUE;
                                        p.acs:=s;
                                        end;
                                  end;
                                5:begin
        setwindow4(w3,6,10,72,18,8,0,8,'Edit Protocol ('+showprot2(wh)+')','Protocol Editor',TRUE);
                                        getflags;
        setwindow5(w3,6,10,72,18,3,0,8,'Edit Protocol ('+showprot2(wh)+')','Protocol Editor',TRUE);
                                        window(7,11,71,17);
                                        textcolor(3);
                                        textbackground(0);
                                        gotoxy(18,6);
                                        write(mln(showflags,40));
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
                seek(pf,wh);
                write(pf,p);
        end;
        change:=FALSE;
        end;
        auto:=FALSE;
        removewindow(w3);
        end;


        procedure createnewfile;
        var tmp:integer;
        begin
        rewrite(pf);
fillchar(p,sizeof(p),#0);
write(pf,p);
p.xbstat:=[xbActive,xbBatch,xbResume,xbINTERNAL];
p.Descr:='%030%(%150%Z%030%) Zmodem';
p.ckeys:='Z';
p.acs:='';
p.ulcmd:='INT_ZMODEM_RECV';
p.dlcmd:='INT_ZMODEM_SEND';
p.templog:='';
p.uloadlog:='|TEMPDIR|\UL|PADDEDNODE|.LOG';
p.dloadlog:='|TEMPDIR|\DL|PADDEDNODE|.LOG';
p.envcmd:='';
p.dlflist:='|TEMPDIR|\FLAG|PADDEDNODE|.LST';
p.ulcode:=0;
p.dlcode:=0;
p.maxchrs:=128;
p.logpf:=0;
p.logps:=0;
write(pf,p);
p.xbstat:=[xbActive,xbBatch,xbResume,xbINTERNAL];
p.Descr:='%030%(%150%G%030%) Ymodem/G';
p.ckeys:='G';
p.acs:='';
p.ulcmd:='INT_YMOD-G_RECV';
p.dlcmd:='INT_YMOD-G_SEND';
p.templog:='';
p.uloadlog:='|TEMPDIR|\UL|PADDEDNODE|.LOG';
p.dloadlog:='|TEMPDIR|\DL|PADDEDNODE|.LOG';
p.envcmd:='';
p.dlflist:='|TEMPDIR|\FLAG|PADDEDNODE|.LST';
p.ulcode:=0;
p.dlcode:=0;
p.maxchrs:=128;
p.logpf:=0;
p.logps:=0;
write(pf,p);
p.xbstat:=[xbActive,xbBatch,xbResume,xbINTERNAL];
p.Descr:='%030%(%150%Y%030%) Ymodem';
p.ckeys:='Y';
p.acs:='';
p.ulcmd:='INT_YMODEM_RECV';
p.dlcmd:='INT_YMODEM_SEND';
p.templog:='';
p.uloadlog:='|TEMPDIR|\UL|PADDEDNODE|.LOG';
p.dloadlog:='|TEMPDIR|\DL|PADDEDNODE|.LOG';
p.envcmd:='';
p.dlflist:='|TEMPDIR|\FLAG|PADDEDNODE|.LST';
p.ulcode:=0;
p.dlcode:=0;
p.maxchrs:=128;
p.logpf:=0;
p.logps:=0;
write(pf,p);
p.xbstat:=[xbActive,xbINTERNAL,xbNameSingle];
p.Descr:='%030%(%150%1%030%) Xmodem/1K';
p.ckeys:='1';
p.acs:='';
p.ulcmd:='INT_XMOD1K_RECV';
p.dlcmd:='INT_XMOD1K_SEND';
p.templog:='';
p.uloadlog:='|TEMPDIR|\UL|PADDEDNODE|.LOG';
p.dloadlog:='|TEMPDIR|\DL|PADDEDNODE|.LOG';
p.envcmd:='';
p.dlflist:='|TEMPDIR|\FLAG|PADDEDNODE|.LST';
p.ulcode:=0;
p.dlcode:=0;
p.maxchrs:=128;
p.logpf:=0;
p.logps:=0;
write(pf,p);
p.xbstat:=[xbActive,xbINTERNAL,xbNameSingle];
p.Descr:='%030%(%150%X%030%) Xmodem';
p.ckeys:='X';
p.acs:='';
p.ulcmd:='INT_XMODEM_RECV';
p.dlcmd:='INT_XMODEM_SEND';
p.templog:='';
p.uloadlog:='|TEMPDIR|\UL|PADDEDNODE|.LOG';
p.dloadlog:='|TEMPDIR|\DL|PADDEDNODE|.LOG';
p.envcmd:='';
p.dlflist:='|TEMPDIR|\FLAG|PADDEDNODE|.LST';
p.ulcode:=0;
p.dlcode:=0;
p.maxchrs:=128;
p.logpf:=0;
p.logps:=0;
write(pf,p);
fillchar(p,sizeof(p),#0);
p.maxchrs:=128;
write(pf,p);
write(pf,p);
write(pf,p);
write(pf,p);
write(pf,p);
p.xbstat:=[];
p.Descr:='%030%(%150%!%030%) New External Protocol';
p.ckeys:='!';
p.acs:='';
p.ulcmd:='';
p.dlcmd:='';
p.templog:='';
p.uloadlog:='|TEMPDIR|\UL|PADDEDNODE|.LOG';
p.dloadlog:='|TEMPDIR|\DL|PADDEDNODE|.LOG';
p.envcmd:='';
p.dlflist:='|TEMPDIR|\FLAG|PADDEDNODE|.LST';
p.ulcode:=0;
p.dlcode:=0;
p.maxchrs:=128;
p.logpf:=0;
p.logps:=0;
write(pf,p);
end;

function showarc(x:integer):string;
begin
seek(pf,x);
read(pf,p);
showarc:=mln(p.ckeys,2)+'  '+mln(p.descr,50);
end;


begin
done:=FALSE;
assign(pf,adrv(systat.gfilepath)+'PROTOCOL.DAT');
{$I-} reset(pf); {$I+}
if (ioresult<>0) then begin
        displaybox('Error reading PROTOCOL.DAT... creating.',2000);
        createnewfile;
        seek(pf,0);
end;
choices[1]:='Zmodem    :';
choices[2]:='Ymodem/G  :';
choices[3]:='Ymodem    :';
choices[4]:='Xmodem/1K :';
choices[5]:='Xmodem    :';
choices[6]:='unused    :';
choices[7]:='unused    :';
choices[8]:='unused    :';
choices[9]:='unused    :';
choices[10]:='unused    :';
choices[11]:='Additional ';
setwindow(w2,2,7,77,21,3,0,8,'Protocol Configuration',TRUE);
textcolor(7);
textbackground(0);
for current:=1 to 11 do begin
        gotoxy(2,current+1);
        write(choices[current]);
end;
for current:=1 to 10 do begin
        seek(pf,current);
        read(pf,p);
        desc[current]:='%140%Esc%070%=Exit %140%'+p.descr;
end;
desc[11]:='%140%Esc%070%=Exit %140%Additional archivers not internally supported';
textcolor(3);
textbackground(0);
for current:=1 to 10 do begin
        gotoxy(14,current+1);
        cwrite(showarc(current));
end;
current:=1;
repeat
window(1,1,80,25);
gotoxy(1,25);
textcolor(14);
textbackground(0);
clreol;
cwrite(desc[current]);
window(3,8,76,20);
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
                                if (current=0) then current:=11;
                            end;
                        #80:begin
                                textcolor(7);
                                textbackground(0);
                                gotoxy(2,current+1);
                                write(choices[current]);
                                inc(current);
                                if (current=12) then current:=1;
                            end;
                end;
           end;
       #13:begin
           setwindow4(w2,2,7,77,21,8,0,8,'Protocol Configuration','',TRUE);
           textcolor(7);
           textbackground(0);
           gotoxy(2,current+1);
           write(choices[current]);
           if (current=11) then editexternal else begin
                if (current in [1..5]) then editinternal(current);
           end;
           setwindow5(w2,2,7,77,21,3,0,8,'Protocol Configuration','',TRUE);
           window(3,8,76,20);
           end;
      #27:begin
                done:=TRUE;
          end;
end;
until (done);
removewindow(w2);
close(pf);
end;

end.

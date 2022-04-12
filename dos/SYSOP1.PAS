(*****************************************************************************)
(*>                                                                         <*)
(*>  SYSOP1  .PAS -  Copyright 1993 Intuitive Vision Software.              <*)
(*>                  All Rights Reserved.                                   <*)
(*>  SysOp functions: Protocol editor.                                      <*)
(*>                                                                         <*)
(*****************************************************************************)
{$A+,B+,D-,E+,F+,I+,L+,N-,O+,R-,S+,V-}
unit sysop1;

interface

procedure exproedit;

implementation

uses
  crt, dos, myio, misc,procspec;

var x:integer;
    xf:file of protrec;
    protocol:protrec;             { protocol in memory                    }


procedure exproedit;
var wrd:word;
    i1,i2,ii,xloaded:integer;
    c:char;
    abort,next:boolean;
    st:astr;

  procedure xed(i:integer);
  var x:integer;
  begin
    if (i>=0) and (i<=filesize(xf)-1) then begin
      if (i>=0) and (i<filesize(xf)-1) then
        for x:=i to filesize(xf)-2 do begin
          seek(xf,x+1); read(xf,protocol);
          seek(xf,x); write(xf,protocol);
        end;
      seek(xf,filesize(xf)-1); truncate(xf);
    end;
  end;

  procedure xei(i:integer);
  var x:integer;
  begin
    if (i>=0) and (i<=filesize(xf)) and (filesize(xf)<maxprotocols) then begin
      for x:=filesize(xf)-1 downto i do begin
        seek(xf,x); read(xf,protocol);
        write(xf,protocol);  (* to next record *)
      end;
      with protocol do begin
        xbstat:=[];
        ckeys:='!';
        descr:='%080%[%150%!%080%] %030%New Protocol';
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
      seek(xf,i); write(xf,protocol);
    end;
  end;


  function substone(src,old,new:astr):astr;
  var p:integer;
  begin
    p:=pos(old,allcaps(src));
    if (p>0) then begin
      insert(new,src,p+length(old));
      delete(src,p,length(old));
    end;
    substone:=src;
  end;

  procedure xem;
  var s:astr;
      x,i,j,i1,i2,ii,ii4:integer;
      c,c1:char;
      bb:byte;
      choices:array[1..13] of string;
      current:integer;
      w2:windowrec;
      arrows,editing,done,update,changed,b:boolean;

    function cfip(pt:integer; s:astr):astr;
    begin
      if (pt<1) or (pt>5) then cfip:=s else cfip:='';
    end;

    function nnon(s:astr):astr;
    begin
      if (s<>'') then nnon:=s else nnon:='None';
    end;

    function showflags:string;
    var s8:string;
    begin
    s8:='';
    if (xbbatch in protocol.xbstat) then s8:=s8+'Batch ';
    if (xbResume in protocol.xbstat) then s8:=s8+'Resume ';
    if (xbNameSingle in protocol.xbstat) then s8:=s8+'AskName';
    if (s8='') then s8:='None';
    showflags:=s8;
    end;

    procedure getflags;
    var w8:windowrec;
        cho:array[1..3] of string;
        cur2:integer;
        c2:char;
        d2:boolean;
    begin
    setwindow(w8,20,8,60,14,3,0,8,'Protocol Flags',TRUE);
    cho[1]:='Batch Supported              :';
    cho[2]:='Resume Supported             :';
    cho[3]:='Ask For Filename When Single :';
    gotoxy(2,2);
    textcolor(7);
    textbackground(0);
    write(cho[1]);
    gotoxy(2,3);
    write(cho[2]);
    gotoxy(2,4);
    write(cho[3]);
    d2:=FALSE;
    gotoxy(33,2);
    textcolor(3);
    write(aonoff(xbBatch in protocol.xbstat,'Yes','No '));
    gotoxy(33,3);
    write(aonoff(xbResume in protocol.xbstat,'Yes','No '));
    gotoxy(33,4);
    write(aonoff(xbNameSingle in protocol.xbstat,'Yes','No '));
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
                                inc(cur2);
                                if (cur2=4) then cur2:=1;
                        end;
                end;
        end;
        #13:begin
                case cur2 of
                        1:begin
                                changed:=TRUE;
                                if (xbBatch in protocol.xbstat) then
                                protocol.xbstat:=protocol.xbstat-[xbbatch]
                                else
                                protocol.xbstat:=protocol.xbstat+[xbbatch];
                                gotoxy(33,2);
                                textcolor(3);
                                textbackground(0);
                                write(aonoff(xbBatch in protocol.xbstat,'Yes','No '));
                          end;
                        2:begin
                                changed:=TRUE;
                                if (xbResume in protocol.xbstat) then
                                protocol.xbstat:=protocol.xbstat-[xbresume]
                                else
                                protocol.xbstat:=protocol.xbstat+[xbresume];
                                gotoxy(33,3);
                                textcolor(3);
                                textbackground(0);
                                write(aonoff(xbresume in protocol.xbstat,'Yes','No '));
                          end;
                        3:begin
                                changed:=TRUE;
                                if (xbNameSingle in protocol.xbstat) then
                                protocol.xbstat:=protocol.xbstat-[xbnamesingle]
                                else
                                protocol.xbstat:=protocol.xbstat+[xbnamesingle];
                                gotoxy(33,4);
                                textcolor(3);
                                textbackground(0);
                                write(aonoff(xbnamesingle in protocol.xbstat,'Yes','No '));
                          end;
                end;
        end;
        #27:d2:=TRUE;
    end;
    until (d2);
    removewindow(w8);
    end;

  begin
    xloaded:=-1;
    ii:=0;
    c:=' ';
    editing:=FALSE;
    update:=TRUE;
    arrows:=FALSE;
    done:=FALSE;
    choices[1]:='Description           :';
    choices[2]:='Active                :';
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
   setwindow2(w,1,6,78,22,3,0,8,'View Protocol '+cstr(ii+1)+'/'+cstr(filesize(xf)),
        'Protocol Editor',TRUE);
   for x:=1 to 13 do begin
        gotoxy(2,x+1);
        textcolor(7);
        textbackground(0);
        write(choices[x]);
   end;
   current:=1;
   cursoron(FALSE);
   if (ii>=0) and (ii<=filesize(xf)-1) then begin
        with protocol do
        repeat
        arrows:=FALSE;
        if (xloaded<>ii) then begin
          seek(xf,ii); read(xf,protocol);
          xloaded:=ii; changed:=FALSE;
        end;
        if (update) then begin
                update:=FALSE;
                if (editing) then begin
   setwindow3(w,1,6,78,22,3,0,8,'Edit Protocol '+cstr(ii+1)+'/'+cstr(filesize(xf)),
        'Protocol Editor',TRUE);
                end else begin
   setwindow3(w,1,6,78,22,3,0,8,'View Protocol '+cstr(ii+1)+'/'+cstr(filesize(xf)),
        'Protocol Editor',TRUE);
                end;
        gotoxy(26,2);
        textcolor(3);
        textbackground(0);
        cwrite(mln(descr,40));
        gotoxy(26,3);
        textcolor(3);
        textbackground(0);
        write(aonoff(xbactive in xbstat,'Yes','No '));
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
                            if (ii<0) then ii:=filesize(xf)-1;
                            update:=TRUE;
                            arrows:=TRUE;
                            end;
                        #77:if not(editing) then begin
                            inc(ii);
                            if (ii>filesize(xf)-1) then ii:=0;
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
                        seek(xf,xloaded); write(xf,protocol);
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
                                        if (ii>filesize(xf)-1) then ii:=filesize(xf)-1;
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
  if (ii4>0) and (ii4<=filesize(xf)) then begin
  if (s<>'') then begin
  ii:=ii4-1;
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
                        2:begin
                      if (xbactive in xbstat) then xbstat:=xbstat-[xbactive] else
                      xbstat:=xbstat+[xbactive];
                      changed:=true;
        gotoxy(26,3);
        textcolor(3);
        textbackground(0);
        write(aonoff(xbactive in xbstat,'Yes','No '));
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
   setwindow4(w,1,6,78,22,8,0,8,'Edit Protocol '+cstr(ii+1)+'/'+cstr(filesize(xf)),
        'Protocol Editor',TRUE);
                                getflags;
   setwindow5(w,1,6,78,22,3,0,8,'Edit Protocol '+cstr(ii+1)+'/'+cstr(filesize(xf)),
        'Protocol Editor',TRUE);
                                window(2,7,77,22);
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
              seek(xf,xloaded); write(xf,protocol);
              end;
              window(2,7,77,21);
              changed:=FALSE;
          end;
          until (done);
    end;
  end;

  { move protocol function goes BEFORE the protocol }

begin
  assign(xf,adrv(systat.gfilepath)+'PROTOCOL.DAT');
  {$I-} reset(xf); {$I+}
  if (ioresult<>0) then begin
        rewrite(xf);
      with protocol do begin
        xbstat:=[];
        ckeys:='!';
        descr:='%080%[%150%!%080%] %030%New Protocol';
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
      seek(xf,0); write(xf,protocol);
  end;
  xloaded:=-1; c:=#0;
  xem;
  close(xf);
end;

end.

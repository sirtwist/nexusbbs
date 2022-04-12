(*****************************************************************************)
(*>                                                                         <*)
(*>  SYSOP2F .PAS -  Written by Eric Oman                                   <*)
(*>                                                                         <*)
(*>  SysOp functions: System Configuration Editor -- "F" command.           <*)
(*>                                                                         <*)
(*****************************************************************************)
{$A+,B+,D-,E+,F+,I+,L+,N-,O+,R-,S+,V-}
unit sysop2f;

interface

uses
  crt, dos, myio, misc,procspec;

procedure pofilesconfig;
procedure getarctype;

implementation

uses spawno;

procedure runresize(nkw,ndl:integer);
var x,y,x1,y1,x2,y2:integer;
    newswaptype:byte;
    wr:windowrec;
    s:string;
begin
     x:=wherex;
     y:=wherey;
     x1:=Lo(windmin)+1;
     y1:=Hi(windmin)+1;
     x2:=lo(windmax)+1;
     y2:=hi(windmax)+1;

     savescreen(wr,1,1,80,25);
     window(1,1,80,25);
     textcolor(7);
     textbackground(0);

     case nxset.swaptype of
                1:newswaptype:=swap_disk;
                2:newswaptype:=swap_xms;
                3:newswaptype:=swap_ext;
                4:newswaptype:=swap_all;
                else newswaptype:=swap_all;
     end;
     s:=' /c '+adrv(systat.utilpath)+'NXFDBS.EXE '+cstr(nkw)+' '+cstr(ndl);
     if (nxset.swaptype>0) then begin
     Init_spawno(nexusdir,newswaptype,20,0);
     if (spawn(getenv('COMSPEC'),s,0)=-1) then begin
        displaybox('Error spawning external program!',2000);
     end;
     end else begin
        swapvectors;
        exec(getenv('COMSPEC'),s);
        swapvectors;
     end;
     removewindow(wr);
     window(x1,y1,x2,y2);
     gotoxy(x,y);
end;

function dupecheck(b:byte):string;
begin
case b of
        0:dupecheck:='Off             ';
        1:dupecheck:='All Bases       ';
        2:dupecheck:='Hard Drive Bases';
end;
end;

function listt(b:byte):string;
begin
case b of
        0:listt:='10 lines';
        1:listt:='5 lines ';
        2:listt:='1 line  ';
end;
end;

{    filearccomment:ARRAY[1..3] of STRING[80];  BBS comments for archives }

procedure getarctype;
var w2:windowrec;
    s2:string;
    cho:array[1..3] of string;
    cur:integer;
    c2:char;
    dn2:boolean;
begin
dn2:=FALSE;
cho[1]:='Comment File #1 :';
cho[2]:='Comment File #2 :';
cho[3]:='Comment File #3 :';
setwindow(w2,1,9,78,15,3,0,8,'Archive Comment Files',TRUE);
for cur:=1 to 3 do begin
gotoxy(2,cur+1);
textcolor(7);
textbackground(0);
write(cho[cur]);
textcolor(3);
textbackground(0);
write(' '+mln(systat.filearccomment[cur],52));
end;
cur:=1;
repeat
gotoxy(2,cur+1);
textcolor(15);
textbackground(1);
write(cho[cur]);
while not(keypressed) do begin timeslice; end;
c2:=readkey;
case c2 of
        #0:begin
                c2:=readkey;
                checkkey(c2);
                case c2 of
                        #68:dn2:=TRUE;
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
                gotoxy(2,cur+1);
                textcolor(7);
                textbackground(0);
                write(cho[cur]);
                gotoxy(18,cur+1);
                textcolor(9);
                textbackground(0);
                write('>');
                gotoxy(20,cur+1);
                                        infield_inp_fgrd:=15;
                                        infield_inp_bkgd:=1;
                                        infield_out_fgrd:=3;
                                        infield_out_bkgd:=0;
                                        infield_allcaps:=TRUE;
                                        infield_numbers_only:=FALSE;
                                        infield_show_colors:=FALSE;
                                        infield_putatend:=TRUE;
                                        infield_clear:=TRUE;
                                        infield_maxshow:=52;
                                        s2:=systat.filearccomment[cur];
                                        infielde(s2,80);
                                        infield_maxshow:=0;
                                        infield_putatend:=false;
                                        infield_clear:=false;
                                        infield_numbers_only:=FALSE;
                                        infield_allcaps:=FALSE;
                                        if (s2<>systat.filearccomment[cur]) then begin
                                        systat.filearccomment[cur]:=s2;
                                        end;

           end;
       #27:begin
                dn2:=TRUE;
           end;
end;
until (dn2);
removewindow(w2);
end;

procedure pofilesconfig;
var s:string[80];
    i:integer;
    c:char;
    b:byte;
    choices:array[1..15] of string;
    desc:array[1..15] of string;
    x,current:integer;
    nkw,ndl:integer;
    changed2,abort,next,done,changed:boolean;


function showcredittype:string;
begin
with systat do begin
        if (uldlratio) then begin
                if (fileptratio) then showcredittype:='Ratio/Filepoint'
                else showcredittype:='UL/DL Ratio    '
        end else
        if (fileptratio) then showcredittype:='Filepoint      ' else
                              showcredittype:='None           ';
end;
end;


begin
  nkw:=syst.nkeywords;
  ndl:=syst.ndesclines;
  done:=FALSE;
  changed2:=FALSE;
  choices[1]:='Number of Description Lines/File:';
  choices[2]:='Number of Keywords/File         :';
  choices[3]:='File Credit System              :';
  choices[4]:='Filepoints for UL Percentage    :';
  choices[5]:='File Size/1 Filepoint for DL    :';
  choices[6]:='Upload Time Refund Percentage   :';
  choices[7]:='"Sysop" File Base (-1=Inactive) :';
  choices[8]:='Validate ALL Files Uploaded     :';
  choices[9]:='Remote DOS Re-Direction Device  :';
 choices[10]:='Minimum Kb Free for Uploads     :';
 choices[11]:='Maximum Kb Allowed in Temp Dir  :';
 choices[12]:='Minimum Kb To Save for Resume   :';
 choices[13]:='Search for Duplicates on Upload :';
 choices[14]:='Convert archives if AV present? :';
 choices[15]:='Convert archives of same type?  :';

 desc[1]:='Number of Description Lines for each File Record           ';
 desc[2]:='Number of Keywords for each File Record                    ';
 desc[3]:='File Credit System: UL/DL Ratio / Filepoint / Both         ';
 desc[4]:='When file is ULed, Percentage of file''s Filepoints awarded';
 desc[5]:='When file is DLed, Number of Kb per 1 Filepoint assessed   ';
 desc[6]:='Percentage of time spent Uploading that is given back      ';
 desc[7]:='File Base where files marked as "To Sysop" are placed      ';
 desc[8]:='Mark ALL files uploaded as Validated automatically?        ';
 desc[9]:='Re-Direction Device for Shells in File Functions           ';
desc[10]:='Minimum Kb of Drive Space Free to allow Uploads            ';
desc[11]:='Maximum Kb of files allowed in the Temporary Directory     ';
desc[12]:='Minimum Kb of partial file received to save for resume     ';
desc[13]:='Search for Duplicate filenames when a file is uploaded?    ';
desc[14]:='Convert archives even if authenticity verification present?';
desc[15]:='Convert archives even if origin and destination format same';
 setwindow(w,13,5,67,23,3,0,8,'File System Variables',TRUE);
 for x:=1 to 15 do begin
        gotoxy(2,x+1);
        textcolor(7);
        textbackground(0);
        write(choices[x]);
 end;
 textcolor(3);
 textbackground(0);
 with systat do begin
 gotoxy(36,2);
 write(mln(cstr(ndl),4));
 gotoxy(36,3);
 write(mln(cstr(nkw),4));
 gotoxy(36,4);
 write(showcredittype);
 gotoxy(36,5);
 write(mln(cstr(fileptcomp),3)+' %');
 gotoxy(36,6);
 write(mln(cstr(fileptcompbasesize),3)+' k');
 gotoxy(36,7);
 write(mln(cstr(ulrefund),3)+' %');
 gotoxy(36,8);
 write(mln(cstr(tosysopdir),5));
 gotoxy(36,9);
 write(syn(validateallfiles));
 gotoxy(36,10);
 write(mln(systat.remdevice,10));
 gotoxy(36,11);
 write(mn(minspaceforupload,4));
 gotoxy(36,12);
 write(mln(cstr(systat.maxintemp),5));
 gotoxy(36,13);
 write(mln(cstr(systat.minresume),5));
 gotoxy(36,14);
 write(dupecheck(systat.searchdup));
 gotoxy(36,15);
 write(syn(systat.convertwithav));
 gotoxy(36,16);
 write(syn(systat.convertsame));
 end;
 current:=1;
 window(1,1,80,25);
 gotoxy(1,25);
 textcolor(14);
 textbackground(0);
 write('Esc');
 textcolor(7);
 write('=Exit ');
 window(14,6,66,22);
 with systat do
 repeat
      textcolor(15);
      textbackground(1);
      gotoxy(2,current+1);
      write(choices[current]);
      window(1,1,80,25);
      gotoxy(10,25);
      textcolor(14);
      textbackground(0);
      clreol;
      write(desc[current]);
      window(14,6,66,22);
      while not(keypressed) do begin timeslice; end;
      c:=readkey;
      case c of
        #27:done:=TRUE;
        #0:begin
                c:=readkey;
                checkkey(c);
                case c of
                        #68:done:=TRUE;
                        #72:begin
                                gotoxy(2,current+1);
                                textcolor(7);
                                textbackground(0);
                                write(choices[current]);
                                dec(current);
                                if (current=0) then current:=15;
                            end;
                        #80:begin
                                gotoxy(2,current+1);
                                textcolor(7);
                                textbackground(0);
                                write(choices[current]);
                                inc(current);
                                if (current=16) then current:=1;
                            end;
                end;
           end;
        #13:begin
                case current of
                        1:begin
                                gotoxy(2,current+1);
                                textcolor(7);
                                textbackground(0);
                                write(choices[current]);
                                gotoxy(34,current+1);
                                textcolor(9);
                                write('>');
                                gotoxy(36,current+1);
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
                                        infield_max_value:=9999;
                                        s:=cstr(ndl);
                                        infielde(s,4);
                                        infield_min_value:=-1;
                                        infield_putatend:=false;
                                        infield_clear:=false;
                                        infield_max_value:=-1;
                                        infield_numbers_only:=FALSE;
                                        infield_maxshow:=0;
                                        infield_show_colors:=FALSE;
                                        if (value(s)<>ndl) then begin
                                        ndl:=value(s);
                                        changed2:=TRUE;
                                        end;
                          end;
                        2:begin
                                gotoxy(2,current+1);
                                textcolor(7);
                                textbackground(0);
                                write(choices[current]);
                                gotoxy(34,current+1);
                                textcolor(9);
                                write('>');
                                gotoxy(36,current+1);
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
                                        infield_max_value:=9999;
                                        s:=cstr(nkw);
                                        infielde(s,4);
                                        infield_min_value:=-1;
                                        infield_putatend:=false;
                                        infield_clear:=false;
                                        infield_max_value:=-1;
                                        infield_numbers_only:=FALSE;
                                        infield_maxshow:=0;
                                        infield_show_colors:=FALSE;
                                        if (value(s)<>nkw) then begin
                                        nkw:=value(s);
                                        changed2:=TRUE;
                                        end;
                          end;
                        3:begin
                          if (uldlratio) and (fileptratio) then begin
                                uldlratio:=TRUE;
                                fileptratio:=FALSE;
                          end else if (uldlratio) then begin
                                uldlratio:=FALSE;
                                fileptratio:=TRUE;
                          end else if (fileptratio) then begin
                                uldlratio:=TRUE;
                                fileptratio:=TRUE;
                          end;
                          gotoxy(36,current+1);
                          textcolor(3);
                          textbackground(0);
                          write(showcredittype);
                          end;
                        4:begin
                                gotoxy(2,current+1);
                                textcolor(7);
                                textbackground(0);
                                write(choices[current]);
                                gotoxy(34,current+1);
                                textcolor(9);
                                write('>');
                                gotoxy(36,current+1);
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
                                        infield_max_value:=200;
                                        s:=cstr(fileptcomp);
                                        infielde(s,3);
                                        infield_min_value:=-1;
                                        infield_putatend:=false;
                                        infield_clear:=false;
                                        infield_max_value:=-1;
                                        infield_numbers_only:=FALSE;
                                        infield_maxshow:=0;
                                        infield_show_colors:=FALSE;
                                        if (value(s)<>fileptcomp) then begin
                                        fileptcomp:=value(s);
                                        end;
                          end;
                        5:begin
                                gotoxy(2,current+1);
                                textcolor(7);
                                textbackground(0);
                                write(choices[current]);
                                gotoxy(34,current+1);
                                textcolor(9);
                                write('>');
                                gotoxy(36,current+1);
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
                                        s:=cstr(fileptcompbasesize);
                                        infielde(s,3);
                                        infield_min_value:=-1;
                                        infield_putatend:=false;
                                        infield_clear:=false;
                                        infield_max_value:=-1;
                                        infield_numbers_only:=FALSE;
                                        infield_maxshow:=0;
                                        infield_show_colors:=FALSE;
                                        if (value(s)<>fileptcompbasesize) then begin
                                        fileptcompbasesize:=value(s);
                                        end;
                          end;
                        6:begin
                                gotoxy(2,current+1);
                                textcolor(7);
                                textbackground(0);
                                write(choices[current]);
                                gotoxy(34,current+1);
                                textcolor(9);
                                write('>');
                                gotoxy(36,current+1);
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
                                        infield_max_value:=200;
                                        s:=cstr(ulrefund);
                                        infielde(s,3);
                                        infield_min_value:=-1;
                                        infield_putatend:=false;
                                        infield_clear:=false;
                                        infield_max_value:=-1;
                                        infield_numbers_only:=FALSE;
                                        infield_maxshow:=0;
                                        infield_show_colors:=FALSE;
                                        if (value(s)<>ulrefund) then begin
                                        ulrefund:=value(s);
                                        end;
                          end;
                        7:begin
                                gotoxy(2,current+1);
                                textcolor(7);
                                textbackground(0);
                                write(choices[current]);
                                gotoxy(34,current+1);
                                textcolor(9);
                                write('>');
                                gotoxy(36,current+1);
                                        infield_inp_fgrd:=15;
                                        infield_inp_bkgd:=1;
                                        infield_out_fgrd:=3;
                                        infield_out_bkgd:=0;
                                        infield_allcaps:=false;
                                        infield_numbers_only:=TRUE;
                                        infield_show_colors:=FALSE;
                                        infield_min_value:=-1;
                                        infield_putatend:=TRUE;
                                        infield_clear:=TRUE;
                                        infield_max_value:=32767;
                                        s:=cstr(tosysopdir);
                                        infielde(s,5);
                                        infield_min_value:=-1;
                                        infield_putatend:=false;
                                        infield_clear:=false;
                                        infield_max_value:=-1;
                                        infield_numbers_only:=FALSE;
                                        infield_maxshow:=0;
                                        infield_show_colors:=FALSE;
                                        if (value(s)<>tosysopdir) then begin
                                        tosysopdir:=value(s);
                                        end;
                          end;
                        8:begin
                          validateallfiles:=not validateallfiles;
                          textcolor(3);
                          textbackground(0);
                          gotoxy(36,current+1);
                          write(syn(validateallfiles));
                          end;
                        9:begin
                                gotoxy(2,current+1);
                                textcolor(7);
                                textbackground(0);
                                write(choices[current]);
                                gotoxy(34,current+1);
                                textcolor(9);
                                write('>');
                                gotoxy(36,current+1);
                                        infield_inp_fgrd:=15;
                                        infield_inp_bkgd:=1;
                                        infield_out_fgrd:=3;
                                        infield_out_bkgd:=0;
                                        infield_allcaps:=TRUE;
                                        infield_numbers_only:=FALSE;
                                        infield_show_colors:=FALSE;
                                        infield_putatend:=TRUE;
                                        infield_clear:=TRUE;
                                        s:=remdevice;
                                        infielde(s,10);
                                        infield_min_value:=-1;
                                        infield_putatend:=false;
                                        infield_clear:=false;
                                        infield_max_value:=-1;
                                        infield_numbers_only:=FALSE;
                                        infield_maxshow:=0;
                                        infield_allcaps:=FALSE;
                                        infield_show_colors:=FALSE;
                                        if (s<>remdevice) then begin
                                        remdevice:=s;
                                        end;
                          end;
                        10:begin
                                gotoxy(2,current+1);
                                textcolor(7);
                                textbackground(0);
                                write(choices[current]);
                                gotoxy(34,current+1);
                                textcolor(9);
                                write('>');
                                gotoxy(36,current+1);
                                        infield_inp_fgrd:=15;
                                        infield_inp_bkgd:=1;
                                        infield_out_fgrd:=3;
                                        infield_out_bkgd:=0;
                                        infield_allcaps:=false;
                                        infield_numbers_only:=TRUE;
                                        infield_show_colors:=FALSE;
                                        infield_min_value:=-1;
                                        infield_putatend:=TRUE;
                                        infield_clear:=TRUE;
                                        infield_max_value:=32767;
                                        s:=cstr(minspaceforupload);
                                        infielde(s,5);
                                        infield_min_value:=-1;
                                        infield_putatend:=false;
                                        infield_clear:=false;
                                        infield_max_value:=-1;
                                        infield_numbers_only:=FALSE;
                                        infield_maxshow:=0;
                                        infield_show_colors:=FALSE;
                                        if (value(s)<>minspaceforupload) then begin
                                        minspaceforupload:=value(s);
                                        end;
                          end;
                       11:begin
                                gotoxy(2,current+1);
                                textcolor(7);
                                textbackground(0);
                                write(choices[current]);
                                gotoxy(34,current+1);
                                textcolor(9);
                                write('>');
                                gotoxy(36,current+1);
                                        infield_inp_fgrd:=15;
                                        infield_inp_bkgd:=1;
                                        infield_out_fgrd:=3;
                                        infield_out_bkgd:=0;
                                        infield_allcaps:=false;
                                        infield_numbers_only:=TRUE;
                                        infield_show_colors:=FALSE;
                                        infield_min_value:=-1;
                                        infield_putatend:=TRUE;
                                        infield_clear:=TRUE;
                                        infield_max_value:=32767;
                                        s:=cstr(maxintemp);
                                        infielde(s,5);
                                        infield_min_value:=-1;
                                        infield_putatend:=false;
                                        infield_clear:=false;
                                        infield_max_value:=-1;
                                        infield_numbers_only:=FALSE;
                                        infield_maxshow:=0;
                                        infield_show_colors:=FALSE;
                                        if (value(s)<>maxintemp) then begin
                                        maxintemp:=value(s);
                                        end;
                          end;
                       12:begin
                                gotoxy(2,current+1);
                                textcolor(7);
                                textbackground(0);
                                write(choices[current]);
                                gotoxy(34,current+1);
                                textcolor(9);
                                write('>');
                                gotoxy(36,current+1);
                                        infield_inp_fgrd:=15;
                                        infield_inp_bkgd:=1;
                                        infield_out_fgrd:=3;
                                        infield_out_bkgd:=0;
                                        infield_allcaps:=false;
                                        infield_numbers_only:=TRUE;
                                        infield_show_colors:=FALSE;
                                        infield_min_value:=-1;
                                        infield_putatend:=TRUE;
                                        infield_clear:=TRUE;
                                        infield_max_value:=32767;
                                        s:=cstr(minresume);
                                        infielde(s,5);
                                        infield_min_value:=-1;
                                        infield_putatend:=false;
                                        infield_clear:=false;
                                        infield_max_value:=-1;
                                        infield_numbers_only:=FALSE;
                                        infield_maxshow:=0;
                                        infield_show_colors:=FALSE;
                                        if (value(s)<>minresume) then begin
                                        minresume:=value(s);
                                        end;
                          end;
                       13:begin
                          inc(searchdup);
                          if (searchdup=3) then searchdup:=0;
                          gotoxy(36,current+1);
                          textcolor(3);
                          textbackground(0);
                          write(dupecheck(systat.searchdup));
                          end;
                       14:begin
                          convertwithav:=not convertwithav;
                          textcolor(3);
                          textbackground(0);
                          gotoxy(36,current+1);
                          write(syn(convertwithav));
                          end;
                       15:begin
                          convertsame:=not convertsame;
                          textcolor(3);
                          textbackground(0);
                          gotoxy(36,current+1);
                          write(syn(convertsame));
                          end;
                end;
            end;
         end;
  until (done);
  gotoxy(2,current+1);
  textcolor(7);
  textbackground(0);
  write(choices[current]);
  if (changed2) then begin
        setwindow4(w,13,5,67,23,8,0,8,'File System Variables','',TRUE);
        runresize(nkw,ndl);
        done:=readsystemdat;
        setwindow5(w,13,5,67,23,3,0,8,'File System Variables','',TRUE);
  end;
  removewindow(w);
end;

end.

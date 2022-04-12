{$A+,B+,D-,E+,F+,G+,I+,L-,N-,O+,R+,S+,V-}
unit procspec;

interface

uses dos,crt,misc,spawno,myio;

{$I build2.inc}

procedure checkkey(var c:char);
procedure externalutilities;

implementation

var x4:integer;

procedure runext(executable:string);
var  wr:windowrec;
     s:string;
     x,y,x1,y1,x2,y2:integer;
     newswaptype:byte;
     goahead:boolean;
begin
     x:=wherex;
     y:=wherey;
     x1:=Lo(windmin)+1;
     y1:=Hi(windmin)+1;
     x2:=lo(windmax)+1;
     y2:=hi(windmax)+1;
     goahead:=TRUE;

     savescreen(wr,1,1,80,25);
     window(1,1,80,25);
     textcolor(7);
     textbackground(0);
     cursoron(TRUE);
     case nxset.swaptype of
                1:newswaptype:=swap_disk;
                2:newswaptype:=swap_xms;
                3:newswaptype:=swap_ext;
                4:newswaptype:=swap_all;
                else newswaptype:=swap_all;
     end;
     if (goahead) then begin
     if (nxset.swaptype>0) then begin
     Init_spawno(nexusdir,newswaptype,20,0);
     if (spawn(getenv('COMSPEC'),' /c '+executable,0)=-1) then begin
        displaybox('Error spawning external program!',2000);
     end;
     end else begin
        swapvectors;
        exec(getenv('COMSPEC'),' /c '+executable);
        swapvectors;
     end;
     end;
     removewindow(wr);
     window(x1,y1,x2,y2);
     gotoxy(x,y);
     cursoron(FALSE);
end;

procedure externalutilities;
var euf:file of extutilsrec;
    eu:extutilsrec;
      flp,l,l2:listptr;
      top8,cur8:integer;
      rt2:returntype;
      x,x2:integer;
      w6:windowrec;
      done:boolean;

               procedure getlistbox;
               var x:integer;
               begin
                                if (filesize(euf)>0) then begin
                                seek(euf,0);
                                read(euf,eu);
                                new(l);
                                l^.p:=NIL;
                                l^.list:=mln(eu.description,60);
                                flp:=l;
                                if (filesize(euf)>1) then begin
                                while not(eof(euf)) do begin
                                read(euf,eu);
                                new(l2);
                                l2^.p:=l;
                                l^.n:=l2;
                                l2^.list:=mln(eu.description,60);
                                l:=l2;
                                end;
                                end;
                                l^.n:=NIL;
                                end;
                    end;

procedure additem;
var w2:windowrec;
    choices:array[1..2] of string;
    x,current:integer;
    c:char;
    s:string;
    path,desc:string;
    tf:text;
    ch,dn,save:boolean;
begin
ch:=false;
dn:=false;
save:=false;
choices[1]:='Description    :';
choices[2]:='Executable File:';
setwindow(w2,10,11,70,16,3,0,8,'Add Item',TRUE);
for x:=1 to 2 do begin
gotoxy(2,x+1);
textcolor(7);
textbackground(0);
write(choices[x]);
end;
current:=1;
desc:='';
path:='';
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
                case c of
                        #72:begin
                                gotoxy(2,current+1);
                                textcolor(7);
                                textbackground(0);
                                write(choices[current]);
                                dec(current);
                                if (current=0) then current:=2;
                            end;
                        #80:begin
                                gotoxy(2,current+1);
                                textcolor(7);
                                textbackground(0);
                                write(choices[current]);
                                inc(current);
                                if (current=3) then current:=1;
                            end;
                        #68:begin dn:=TRUE; save:=TRUE; end;
                end;
           end;
       #13:begin
                gotoxy(2,current+1);
                textcolor(7);
                textbackground(0);
                write(choices[current]);
                gotoxy(17,current+1);
                textcolor(9);
                write('>');
                gotoxy(19,current+1);
                case current of
                        1:begin
                                        infield_inp_fgrd:=15;
                                        infield_inp_bkgd:=1;
                                        infield_out_fgrd:=3;
                                        infield_out_bkgd:=0;
                                        infield_allcaps:=false;
                                        infield_numbers_only:=FALSE;
                                        infield_show_colors:=TRUE;
                                        infield_maxshow:=38;
                                        infield_putatend:=TRUE;
                                        infield_clear:=TRUE;
                                        infield_insert:=TRUE;
                                        s:=desc;
                                        infielde(s,60);
                                        infield_maxshow:=0;
                                        infield_show_colors:=FALSE;
                                        if (s<>desc) then begin
                                                desc:=s;
                                                ch:=TRUE;
                                        end;
                          end;
                        2:begin
                                        infield_inp_fgrd:=15;
                                        infield_inp_bkgd:=1;
                                        infield_out_fgrd:=3;
                                        infield_out_bkgd:=0;
                                        infield_allcaps:=false;
                                        infield_numbers_only:=FALSE;
                                        infield_show_colors:=TRUE;
                                        infield_putatend:=TRUE;
                                        infield_clear:=TRUE;
                                        infield_insert:=TRUE;
                                        infield_maxshow:=38;
                                        s:=path;
                                        infielde(s,255);
                                        infield_maxshow:=0;
                                        infield_show_colors:=FALSE;
                                        if (s<>path) then begin
                                                path:=s;
                                                ch:=true;
                                        end;
                          end;
                end;
           end;
       #27:begin
                dn:=TRUE;
           end;
end;
until (dn);
if (ch) then begin
     if not(save) then save:=pynqbox('Save changes? ');
     if (save) then begin
          assign(tf,adrv(systat.temppath)+'UTILMENU.UCF');
          rewrite(tf);
          writeln(tf,desc);
          writeln(tf,path);
          close(tf);
          runext(adrv(systat.utilpath)+'UTLSETUP.EXE '+adrv(systat.temppath)+'UTILMENU.UCF');
     end;
end;
removewindow(w2);
end;


  begin
  filemode:=66;
  assign(euf,adrv(systat.gfilepath)+'UTILMENU.DAT');
  {$I-} reset(euf); {$I+}
  if (ioresult<>0) then begin
     displaybox('Error opening '+adrv(systat.gfilepath)+'UTILMENU.DAT',3000);
     exit;
  end;
  listbox_goto:=FALSE;
  listbox_goto_offset:=0;
  listbox_insert:=TRUE;
  listbox_delete:=FALSE;
  listbox_tag:=FALSE;
  listbox_move:=FALSE;
  listbox_f10:=FALSE;
  getlistbox;
                                top8:=1;
                                cur8:=1;
                                done:=FALSE;
                                repeat
                                for x:=1 to 100 do rt2.data[x]:=-1;
                                l:=flp;
                                listbox(w6,rt2,top8,cur8,l,5,8,75,22,3,0,8,'Utilities','',TRUE);
                                case rt2.kind of
                                        1:begin
                                                seek(euf,(rt2.data[1]-1));
                                                read(euf,eu);
                                                runext(eu.executable);
                                                removewindow(w6);
                                          end;
                                        2:begin
                                                removewindow(w6);
                                                done:=TRUE;
                                                                l:=flp;
                                                                while (l<>NIL) do begin
                                                                        l2:=l^.n;
                                                                        dispose(l);
                                                                        l:=l2;
                                                                end;
                                          end;
                                        3:begin
                                                removewindow(w6);
                                                additem;
                                                                l:=flp;
                                                                while (l<>NIL) do begin
                                                                        l2:=l^.n;
                                                                        dispose(l);
                                                                        l:=l2;
                                                                end;
                                                getlistbox;
                                          end;
                                end;
                                until (done);

  listbox_insert:=TRUE;
  listbox_delete:=TRUE;
  listbox_tag:=TRUE;
  listbox_move:=TRUE;
  listbox_f10:=TRUE;
  close(euf);
end;

procedure showspeckeys;
var desc:array[1..10] of string;
    c:char;
    x:integer;

begin
  desc[1]:='Alt-F1 :';
  desc[2]:='Alt-F2 :';
  desc[3]:='Alt-F3 :';
  desc[4]:='Alt-F4 :';
  desc[5]:='Alt-F5 :';
  desc[6]:='Alt-F6 :';
  desc[7]:='Alt-F7 :';
  desc[8]:='Alt-F8 :';
  desc[9]:='Alt-F9 :';
  desc[10]:='Alt-F10:';
  textcolor(14);
  textbackground(0);
  window(1,1,80,25);
  gotoxy(1,25);
  clreol;
  write('Esc');
  textcolor(7);
  write('=Exit');
  setwindow(w,11,8,69,21,3,0,8,'Special Function Keys',TRUE);
  textcolor(7);
  textbackground(0);
  for x:=1 to 10 do begin
  gotoxy(2,x+1);
  write(desc[x]);
  end;
  for x:=1 to 10 do begin
  gotoxy(11,x+1);
  textcolor(3);
  textbackground(0);
  write(mln(nxset.speckey[x].name,40));
  end;
  while not(keypressed) do begin timeslice; end;
  c:=readkey;
  case c of
        #0:begin
                c:=readkey;
        end;
  end;
  removewindow(w);
end;

procedure runspec(b:byte);
var  wr:windowrec;
     s:string;
     x,y,x1,y1,x2,y2:integer;
     newswaptype:byte;
     goahead:boolean;
begin
     x:=wherex;
     y:=wherey;
     x1:=Lo(windmin)+1;
     y1:=Hi(windmin)+1;
     x2:=lo(windmax)+1;
     y2:=hi(windmax)+1;
     goahead:=TRUE;

     savescreen(wr,1,1,80,25);
     window(1,1,80,25);
     textcolor(7);
     textbackground(0);
     case b of
        1..10:begin
                if (nxset.speckey[b].path<>'') then begin
                s:=' /c '+nxset.speckey[b].path;
                end else goahead:=FALSE;
              end;
           11:begin
                s:='';
                clrscr;
                writeln('nxSETUP v'+version+build+' - Setup for Nexus Bulletin Board System');
                writeln('(c) Copyr. 1996-2000 George A. Roberts IV. All rights reserved.');
                writeln('(c) Copyr. 1994-95 Internet Pro''s Network LLC. All rights reserved.');
                writeln;
                writeln('Type "EXIT" to return to nxSETUP.');
                writeln;
              end;
           12:begin
                s:='';
                showspeckeys;
                goahead:=FALSE;
              end;
     end;

     cursoron(TRUE);
     case nxset.swaptype of
                1:newswaptype:=swap_disk;
                2:newswaptype:=swap_xms;
                3:newswaptype:=swap_ext;
                4:newswaptype:=swap_all;
                else newswaptype:=swap_all;
     end;
     if (goahead) then begin
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
     end;
     removewindow(wr);
     window(x1,y1,x2,y2);
     gotoxy(x,y);
     cursoron(FALSE);
end;

procedure checkkey(var c:char);
var b:byte;
begin
b:=ord(c);
if (b in [36,37,104..113]) then begin
        case b of
                36:b:=11;
                37:b:=12;
                104..113:b:=b-103;
        end;                
        runspec(b);
        c:=#0;
end;
end;

begin
end.

{$M 65000,0,100000}      { Memory Allocation Sizes }
program nxsquimp;

uses dos,crt,myio,misc,mkstring,mkmisc,mkdos,usertag;

var t:text;
    s:string;
    i:longint;
    systatf:file of matrixrec;
    quit:boolean;
    tagf:file of basetagidx;
    tag:basetagidx;
    processfile:string;
    lastused:integer;


    function tagexists(sss:string):boolean;
    var fnd:boolean;
    begin
    assign(tagf,adrv(systat.gfilepath)+'MBTAGS.IDX');
    {$I-} reset(tagf); {$I+}
    if (ioresult<>0) then begin
            writeln('Error reading MBTAGS.IDX');
            halt;
    end;
    fnd:=FALSE;
    while not(eof(tagf)) and not(fnd) do begin
      read(tagf,tag);
      if (allcaps(tag.nettagname)=allcaps(sss)) then fnd:=TRUE;
    end;
    close(tagf);
    tagexists:=fnd;
    end;


procedure updatembaseidx;
var btf:file of basetagidx;
      bt:basetagidx;
      w2:windowrec;
      bf:file of boardrec;
      bif:file of baseidx;
      bi:baseidx;
      mb:boardrec;
  begin
  assign(bf,adrv(systat.gfilepath)+'MBASES.DAT');
  {$I-} reset(bf); {$I+}
  if (ioresult<>0) then begin
        displaybox('Error opening MBASES.DAT',3000);
        exit;
  end;
  seek(bf,0);
  assign(btf,adrv(systat.gfilepath)+'MBTAGS.IDX');
  {$I-} rewrite(btf); {$I+}
  if (ioresult<>0) then begin
        displaybox('Error updating MBTAGS.IDX',3000);
        exit;
  end;
  displaybox3(11,w2,'Updating Message Base Tag Indexes...');
  while not(eof(bf)) do begin
        read(bf,mb);
        bt.nettagname:=mb.nettagname;
        write(btf,bt);
  end;
  close(btf);
  removewindow(w2);
  seek(bf,0);
  assign(bif,adrv(systat.gfilepath)+'MBASES.IDX');
  {$I-} rewrite(bif); {$I+}
  if (ioresult<>0) then begin
        displaybox('Error updating MBASES.IDX',3000);
        exit;
  end;
  displaybox3(11,w2,'Updating Message Base Indexes...');
  while not(eof(bf)) do begin
        bi.offset:=filepos(bf);
        read(bf,mb);
        bi.baseid:=mb.baseid;
        write(bif,bi);
  end;
  close(bif);
  close(bf);
  removewindow(w2);
  end;

procedure updatemconfs;
TYPE
booleanrec=
        RECORD
        bool:array[0..32767] of boolean;
        end;

var w2:windowrec;
    bf:file of boardrec;
    b:boardrec;
    boolf:file of booleanrec;
    bol:^booleanrec;
    x:integer;
    c4:char;
    baseavail:boolean;
    conff:file of confrec;
    conf:confrec;

begin
new(bol);
setwindow(w2,18,10,62,13,3,0,8,'Updating Message Conferences',TRUE);
assign(bf,adrv(systat.gfilepath)+'MBASES.DAT');
{$I-} reset(bf); {$I+}
if (ioresult<>0) then begin
        displaybox('Error opening MBASES.DAT',3000);
        removewindow(w2);
        exit;
end;
assign(conff,adrv(systat.gfilepath)+'CONFS.DAT');
{$I-} reset(conff); {$I+}
if (ioresult<>0) then begin
        displaybox('Error reading CONFS.DAT',3000);
        removewindow(w2);
        exit;
end;
read(conff,conf);
close(conff);
gotoxy(2,2);
textcolor(3);
textbackground(0);
write('Conference [ ]  Bases Available [     ]');
textcolor(15);
textbackground(0);
for c4:='A' to 'Z' do begin
if (conf.msgconf[ord(c4)-64].active) then begin
        gotoxy(14,2);
        write(c4);
        assign(boolf,adrv(systat.gfilepath)+'MCONF'+c4+'.IDX');
        {$I-} rewrite(boolf); {$I+}
        if (ioresult<>0) then begin
                displaybox('Error creating '+adrv(systat.gfilepath)+'MCONF'+c4+'.IDX',3000);
                exit;
        end;
        baseavail:=FALSE;
        fillchar(bol^,sizeof(bol^),#0);
        write(boolf,bol^);
        x:=0;
        seek(bf,0);
        while not(eof(bf)) do begin
                seek(bf,x);
                read(bf,b);
                baseavail:=TRUE;
                if (c4 in b.inconfs) then begin
                        gotoxy(35,2);
                        write(mln(cstr(x),5));
                        bol^.bool[x]:=baseavail;
                end;
                inc(x);
        end;
        seek(boolf,0);
        write(boolf,bol^);
        close(boolf);
        end;
end;
close(bf);
dispose(bol);
removewindow(w2);
end;

  function newmemboard:boolean;
  var btf:file of msgbasetemp;
      mtmp:msgbasetemp;
      done:boolean;
      flp,l,l2:listptr;
      top8,cur8:integer;
      rt2:returntype;
      c:char;
      x,x2:integer;
      w6:windowrec;

                        procedure getlistbox;
                        var x:integer;
                        begin
                                read(btf,mtmp);
                                new(l);
                                l^.p:=NIL;
                                l^.list:=mln(cstr(0),3)+mln(mtmp.template,45);
                                flp:=l;
                                for x:=1 to 20 do begin
                                read(btf,mtmp);
                                new(l2);
                                l2^.p:=l;
                                l^.n:=l2;
                                l2^.list:=mln(cstr(x),3)+mln(mtmp.template,45);
                                l:=l2;
                                end;
                                l^.n:=NIL;
                        end;

  begin
      assign(btf,adrv(systat.gfilepath)+'MBASES.TMP');
      {$I-} reset(btf); {$I+}
      if (ioresult<>0) then begin
        displaybox('No templates available!  Please create templates!',3000);
        newmemboard:=FALSE;
        exit;
      end;
  listbox_goto:=FALSE;
  listbox_goto_offset:=0;
  listbox_insert:=FALSE;
  listbox_delete:=FALSE;
  listbox_tag:=FALSE;
  listbox_move:=FALSE;
  getlistbox;
                                top8:=1;
                                cur8:=lastused;
                                done:=FALSE;
                                repeat
                                for x:=1 to 100 do rt2.data[x]:=-1;
                                l:=flp;
                                listbox(w6,rt2,top8,cur8,l,13,8,67,22,3,0,8,'Message Base Templates','',TRUE);
                                case rt2.kind of
                                        0:begin
                                                c:=chr(rt2.data[100]);
                                                removewindow(w6);
                                                rt2.data[100]:=-1;
                                          end;
                                        1:begin
                                               seek(btf,rt2.data[1]-1);
                                               read(btf,mtmp);
                                               fillchar(memboard,sizeof(memboard),#0);
      with memboard do begin
        name:=mtmp.name;
        filename:=mtmp.filename;
        mbtype:=mtmp.mbtype;
        msgpath:=mtmp.msgpath;
        acs:=mtmp.access;
        postacs:=mtmp.postaccess;
        maxmsgs:=mtmp.maxmsgs;
        password:=mtmp.accesskey;
        for x2:=1 to 30 do address[x2]:=mtmp.address[x2];
        group:=1;
        messagetype:=mtmp.messagetype;
        origin:=mtmp.origin;
        tagtype:=mtmp.tagtype;
        nameusage:=mtmp.nameusage;
        text_color:=mtmp.txtcolor;
        quote_color:=mtmp.quotecolor;
        tear_color:=mtmp.tearcolor;
        origin_color:=mtmp.origincolor;
        tag_color:=mtmp.tagcolor;
        oldtear_color:=mtmp.oldtearcolor;
        mbstat:=mtmp.mbflag;
        mbpriv:=mtmp.mbpriv;
        inconfs:=mtmp.inconfs;
      end;
                                                                l:=flp;
                                                                while (l<>NIL) do begin
                                                                        l2:=l^.n;
                                                                        dispose(l);
                                                                        l:=l2;
                                                                end;
                                                removewindow(w6);
                                                done:=TRUE;
                                                newmemboard:=TRUE;
                                          end;
                                        2:begin
                                                done:=TRUE;
                                                newmemboard:=FALSE;
                                                removewindow(w6);
                                                                l:=flp;
                                                                while (l<>NIL) do begin
                                                                        l2:=l^.n;
                                                                        dispose(l);
                                                                        l:=l2;
                                                                end;
                                          end;
                                end;
                                until (done);


  listbox_insert:=TRUE;
  listbox_delete:=TRUE;
  listbox_tag:=TRUE;
  listbox_move:=TRUE;
  close(btf);
  lastused:=cur8;
  end;


  procedure idxadd(bidx:longint; x:integer);
  var bif:file of baseididx;
      bi:baseididx;
  begin
  assign(bif,adrv(systat.gfilepath)+'MBASEID.IDX');
  {$I-} reset(bif); {$I+}
  if (ioresult<>0) then begin
        displaybox('Error updating MBASEID.IDX',3000);
        exit;
  end;
  seek(bif,filesize(bif));
  bi.baseid:=bidx;
  bi.offset:=x;
  write(bif,bi);
  close(bif);
  end;

  function newindexno:longint;
  begin
    readpermid;
    inc(perm.lastmbaseid);
    updatepermid;
    newindexno:=perm.lastmbaseid;
  end;

procedure getparams;
var np,np2:integer;
    sp:string;
    idx,idx2:boolean;
begin
  idx:=FALSE;
  idx2:=FALSE;
  np:=paramcount;
  if (paramcount>0) then begin
  np2:=1;
  while (np2<=np) do begin
        sp:=paramstr(np2);
        if (allcaps(sp)='/?') or (allcaps(sp)='-?') or (allcaps(sp)='?') then begin
          textcolor(7);
          textbackground(0);
          writeln('Syntax:');
          writeln;
          writeln('   NXSQUIMP [path\filename to import]');
          writeln;
          halt;
        end else processfile:=sp;
        inc(np2);
  end;
  end else begin
          textcolor(7);
          textbackground(0);
          writeln('Syntax:');
          writeln;
          writeln('   NXSQUIMP [path\filename to import]');
          writeln;
          halt;
  end;
end;

begin
lastused:=1;
clrscr;
textcolor(7);
textbackground(0);
writeln('nxSQUIMP v1.00 - Nexus BBS Squish Config Importer');
writeln('(c) Copyright 2001 George A. Roberts IV. All rights reserved.');
writeln;
nexusdir:=getenv('NEXUS');
if (nexusdir='') then begin
      writeln('ERROR: You must set your NEXUS environment variable before running nxSQUIMP');
      halt;
end;
if (nexusdir[length(nexusdir)]='\') then nexusdir:=copy(nexusdir,1,length(nexusdir)-1);
getparams;
if (processfile='') then begin
      writeln('No path/filename to import specified.');
      halt;
end;
assign(systatf,nexusdir+'\MATRIX.DAT');
{$I-} reset(systatf); {$I+}
if (ioresult<>0) then begin
      writeln('Error reading '+nexusdir+'\MATRIX.DAT');
      halt;
end;
read(systatf,systat);
close(systatf);
assign(t,processfile);
{$I-} reset(t); {$I+}
if (ioresult<>0) then begin
        writeln('Error reading '+processfile);
        halt;
end;
quit:=FALSE;
assign(bf,adrv(systat.gfilepath)+'MBASES.DAT');
{$I-} reset(bf); {$I+}
if (ioresult<>0) then begin
      writeln('Error reading '+adrv(systat.gfilepath)+'MBASES.DAT');
      halt;
end;
while not(eof(t)) and not(quit) do begin
      readln(t,s);
      if (allcaps(extractword(s,1))='ECHOAREA') then begin
              if not(tagexists(extractword(s,2))) then begin
              fillchar(memboard,sizeof(memboard),#0);
              gotoxy(1,4);
              textcolor(14);
              write('Processing line:');
              gotoxy(1,5);
              textcolor(7);
              write(mln(copy(s,1,79),79));
              if (newmemboard) then begin
              memboard.BaseID:=newindexno;
              memboard.nettagname:=extractword(s,2);
              memboard.msgid:=getdosdate;
              memboard.filename:=allcaps(fileonly(extractword(s,3)));
              memboard.msgpath:=allcaps(bslash(TRUE,pathonly(extractword(s,3))));
              memboard.name:=memboard.name+memboard.nettagname;
              i:=filesize(bf);
              seek(bf,i); write(bf,memboard);
              idxadd(memboard.BaseID,i);
              inc(numboards);
              end else begin
                  quit:=TRUE;
              end;
              end;
      end;
end;
close(t);
close(bf);
updatemconfs;
updatembaseidx;
createdefaulttags(1);
end.

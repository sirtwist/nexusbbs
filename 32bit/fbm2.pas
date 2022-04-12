unit fbm2;

interface

TYPE tstatus=(Tagged,Deleted,DFile,Moved);

     tindexrec=RECORD
        filename:string[12];
        status  :set of tstatus;
        mbase   :integer;
     end;

const indexopen:BOOLEAN=FALSE;
      index2open:BOOLEAN=FALSE;
var tff:file of tindexrec;
    tff2:file of tindexrec;

procedure buildindex(typ:byte);
procedure loadfilebase(var cbase:integer; typ:byte);
function getfbase(var st,tp:integer; typ:integer; line2:string):integer;
procedure shelldos(cl:string; var rcode:integer);

implementation

uses crt,dos,myio,misc,fbm1,fbm4,procs2,spawno;

procedure shelldos(cl:string; var rcode:integer);
var t:text;
    s,s2:string;
    i:integer;
    bat:boolean;
begin
  nosound;
  bat:=FALSE;
  if (pos(' ',cl)<>0) then begin
          s2:=copy(cl,1,pos(' ',cl)-1);
          if (exist(s2)) then s2:=fexpand(s2);
          cl:=copy(cl,pos(' ',cl)+1,length(cl));
  end else begin
          s2:=cl;
          if (exist(s2)) then s2:=fexpand(s2);
  end;
  if (s2='') then begin
          s2:=getenv('COMSPEC');
          cl:='';
  end else
  if (allcaps(extonly(s2))<>'EXE') and (allcaps(extonly(s2))<>'COM') then begin
    assign(t,adrv(systat.temppath)+'~NXFB.BAT');
    rewrite(t);
    writeln(t,'@ECHO OFF');
    if (extonly(s2)='') then
    writeln(t,s2+' '+cl)
    else
    writeln(t,'CALL '+s2+' '+cl);
    writeln(t,'IF ERRORLEVEL '+cstr(rcode)+' ECHO '+cstr(rcode)+' > '+adrv(systat.temppath)+'ARLVFBM.DAT');
    close(t);
    s2:=getenv('COMSPEC');
    cl:='/c '+adrv(systat.temppath)+'~NXFB.BAT';
    bat:=TRUE;
  end;
  If not(exist(s2)) then s2 := FSearch(s2, getenv('PATH'));

  swapvectors;
  Init_spawno('.\~NXARC',swap_all,20,0);
  rcode:=spawn(s2,cl,0);
  swapvectors;
  if (bat) then begin
    assign(t,adrv(systat.temppath)+'~NXFB.BAT');
    {$I-} erase(t); {$I+}
    if (ioresult<>0) then ;
    if (exist(adrv(systat.temppath)+'ARLVFBM.DAT')) then begin
    assign(t,adrv(systat.temppath)+'ARLVFBM.DAT');
    {$I-} erase(t); {$I+}
    if (ioresult<>0) then ;
    rcode:=0;
    end else rcode:=1;
  end;
  textattr:=7;
end;


procedure buildindex(typ:byte);
var ir:tindexrec;
    x:integer;
    w8:windowrec;
begin
displaybox2(w8,'Building index...');
case typ of
1:begin
        if (indexopen) then begin
                close(tff);
                indexopen:=FALSE;
        end;
        assign(tff,adrv(systat.temppath)+'~NXFBM.TMP');
        if (fbdirdlpath in curf.fbstat) then begin
                NXF.Init(adrv(curf.dlpath)+curf.filename+'.NFD', syst.nkeywords,syst.ndesclines);
        end else begin
                NXF.Init(adrv(systat.filepath)+curf.filename+'.NFD', syst.nkeywords,syst.ndesclines);
        end;
        if (NXF.Ferror) then
                displaybox('ERROR!',5000);
        rewrite(tff);
        indexopen:=TRUE;
        filemode:=66;
        x:=1;
        while (x<=NXF.NumFiles) do begin
                NXF.Seekfile(x);
                NXF.ReadHeader;
                fillchar(ir,sizeof(ir),#0);
                ir.filename:=NXF.Fheader.Filename;
                write(tff,ir);
                inc(x);
        end;
        removewindow(w8);
  end;
2:begin
        if (index2open) then begin
                close(tff2);
                index2open:=FALSE;
        end;
        assign(tff2,adrv(systat.temppath)+'~NXFBS.TMP');
        if (fbdirdlpath in movf.fbstat) then begin
                NXF2.Init(adrv(movf.dlpath)+movf.filename+'.NFD', syst.nkeywords,syst.ndesclines);
        end else begin
                NXF2.Init(adrv(systat.filepath)+movf.filename+'.NFD', syst.nkeywords,syst.ndesclines);
        end;
        rewrite(tff2);
        indexopen:=TRUE;
        filemode:=66;
        x:=1;
        while (x<=NXF2.NumFiles) do begin
                NXF2.Seekfile(x);
                NXF2.ReadHeader;
                fillchar(ir,sizeof(ir),#0);
                ir.filename:=NXF2.Fheader.Filename;
                write(tff2,ir);
                inc(x);
        end;
        NXF2.Done;
        removewindow(w8);
  end;
end;
end;

procedure loadfilebase(var cbase:integer; typ:byte);
var ff:file of ulrec;
begin
filemode:=66;
assign(ff,adrv(systat.gfilepath)+'FBASES.DAT');
{$I-} reset(ff); {$I+}
if (ioresult<>0) then begin
        displaybox(cstr(cbase),3000);
        displaybox('Error reading file bases!',3000);
        cbase:=-1;
        exit;
end;
if (cbase>filesize(ff)-1) then begin
        cbase:=-1;
        exit;
end;
seek(ff,cbase);
case typ of
        1:read(ff,curf);
        2:read(ff,movf);
end;
close(ff);
if ((typ=1) and (cbase=curread)) or ((typ=2) and (cbase=movread)) then
begin end else begin
        case typ of
                1:curread:=cbase;
                2:movread:=cbase;
        end;
        buildindex(typ);
end;
end;

function getfbase(var st,tp:integer; typ:integer; line2:string):integer;
var w2:windowrec;
    ii2:integer;
    getbase,cur,top,x,x2:integer;
    s:string;
    ch:char;
    rt:returntype;
    ff:file of ulrec;
    f:ulrec;
    dn:boolean;

begin
dn:=FALSE;
filemode:=66;
assign(ff,adrv(systat.gfilepath)+'FBASES.DAT');
{$I-} reset(ff); {$I+}
if (ioresult<>0) then begin
        displaybox('Error reading file bases!',3000);
        getfbase:=-1;
        exit;
end;
listbox_tag:=FALSE;
listbox_insert:=FALSE;
listbox_delete:=FALSE;
listbox_move:=FALSE;
listbox_goto:=TRUE;
listbox_goto_offset:=1;
listbox_f10:=FALSE;
listbox_allow_extra_func:=TRUE;
listbox_extrakeys_func:=#36;
listbox_bottom:='';
                                if (firstlp=NIL) then begin
                                displaybox2(w2,'Reading file bases...');
                                new(lp);
                                seek(ff,0);       
                                read(ff,f);
                                ii2:=0;
                                lp^.p:=NIL;
                                s:=mln(cstr(ii2),5)+mln(f.name,51);
                                if (f.cdrom) then s:=s+' CD-ROM' else
                                                  s:=s+'       ';
                                lp^.list:=s;
                                firstlp:=lp;
                                while (not(eof(ff))) do begin
                                inc(ii2);
                                read(ff,f);
                                new(lp2);
                                lp2^.p:=lp;
                                lp^.n:=lp2;
                                s:=mln(cstr(ii2),5)+mln(f.name,51);
                                if (f.cdrom) then s:=s+' CD-ROM' else s:=s+'       ';
                                lp2^.list:=s;
                                lp:=lp2;
                                end;
                                seek(ff,0);
                                read(ff,f);
                                lp^.n:=NIL;
                                removewindow(w2);
                                end;
                                close(ff);
                                top:=tp;
                                cur:=st;
                                repeat
                                for x:=1 to 100 do rt.data[x]:=-1;
                                lp:=firstlp;
                                listbox(w2,rt,top,cur,lp,7,8,73,21,3,0,8,'File Bases',line2,TRUE);
                                case rt.kind of
                                        0:begin
                                                ch:=chr(rt.data[100]);
                                                removewindow(w2);
                                                checkkey(ch);
                                                rt.data[100]:=-1;
                                          end;
                                        1:begin
                                                if (rt.data[1]<>-1) then begin
                                                        getbase:=rt.data[1]-1;
                                                        dn:=TRUE;
                                                end;
                                        end;
                                        else begin
                                                getbase:=-1;
                                                dn:=TRUE;
                                        end;
                                end;
                                until (dn);
                                listbox_tag:=TRUE;
                                listbox_insert:=TRUE;
listbox_allow_extra_func:=FALSe;
listbox_extrakeys_func:='';
listbox_bottom:='';
                                listbox_delete:=TRUE;
                                listbox_move:=TRUE;
                                listbox_goto:=false;
                                listbox_goto_offset:=0;
                                listbox_f10:=TRUE;
                                getfbase:=getbase;


                                st:=cur;
                                tp:=top;
                                removewindow(w2);
end;

end.

program nxAREAS;

uses dos,crt,misc;

var systatf:file of MatrixREC;
    tf:text;
    foundadd,x:byte;
    ff:file of fidorec;
    fr:fidorec;

function atype:string;
begin
case memboard.messagetype of
        1:atype:='$';
        2:atype:='!';
        3:atype:='';
end;
end;

function bfilename:string;
begin
if (memboard.messagetype in [1,2]) then begin
        bfilename:=memboard.msgpath+memboard.filename;
end else begin
        bfilename:=bslash(FALSE,memboard.msgpath);
end;
end;

    function getaddr(zone,net,node,point:integer):string;
    var s:string;
    begin
      if (point=0) then
        s:=cstr(zone)+':'+cstr(net)+'/'+cstr(node)
      else
        s:=cstr(zone)+':'+cstr(net)+'/'+cstr(node)+'.'+cstr(point);
      getaddr:=s;
    end;

begin
nexusdir:=getenv('NEXUS');
if (nexusdir[length(nexusdir)]<>'\') then nexusdir:=nexusdir+'\';
start_dir:=bslash(FALSE,nexusdir);
assign(systatf,nexusdir+'MATRIX.DAT');
{$I-} reset(systatf); {$I+}
if (ioresult<>0) then begin
        writeln('Error reading MATRIX.DAT');
        halt;
end;
read(systatf,systat);
close(systatf);
assign(bf,adrv(systat.gfilepath)+'MBASES.DAT');
{$I-} reset(bf); {$I+}
if (ioresult<>0) then begin
        writeln('Error reading MBASES.DAT');
        halt;
end;
assign(ff,adrv(systat.gfilepath)+'NETWORK.DAT');
{$I-} reset(ff); {$I+}
if (ioresult<>0) then begin
        writeln('Error reading NETWORK.DAT');
        halt;
end;
read(ff,fr);
close(ff);
assign(tf,'AREAS.BBS');
rewrite(tf);
writeln(tf,'; AREAS.BBS Export from '+systat.bbsname);
writeln(tf,'; Created on '+date+' '+time+' by nxAREAS v1.00');
writeln(tf,';');

while not(eof(bf)) do begin
        read(bf,memboard);
        for x:=30 downto 1 do begin
                if (memboard.address[x]) then foundadd:=x;
        end;
        writeln(tf,mln(atype+bfilename,30)+' '+mln(memboard.nettagname,20)+' '
           +getaddr(fr.address[foundadd].zone,fr.address[foundadd].net,
                           fr.address[foundadd].node,fr.address[foundadd].point)); 
end;
close(tf);
end.

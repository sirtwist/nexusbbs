unit iemsi;

interface

uses dos,crt,myio3,common,mkdos,mkmisc,mkstring,crc32;

function isiemsi(var iname,ialias,ipassword,ivoice:string):byte;

implementation

function tcheck(s:real; i:integer):boolean;
var r:real;
begin
  r:=timer-s;
  if r<0.0 then r:=r+86400.0;
  if (r<0.0) or (r>32760.0) then r:=32766.0;
  if trunc(r)>i then tcheck:=FALSE else tcheck:=TRUE;
end;

function isiemsi(var iname,ialias,ipassword,ivoice:string):byte;

var rt,rt2:real;
    c:char;
    t:text;
    ox,oy,oc:byte;
    isi,s,ici:string;
    tries:integer;
    skip,found:boolean;

    function getcrc:string;
    var l:longint;
        x:integer;
        counter:byte;
    begin
    l:=$FFFFFFFF;
    for x:=1 to length(isi) do begin
        l:=UpdC32(ord(isi[x]),l);
    end;
    getcrc:=hexlong(l);
    end;

begin
ivoice:='';
iname:='';
ialias:='';
ipassword:='';
isi:='{Nexus,'+ver+'}{'+systat^.bbsname+'}{}{'+systat^.sysopname+'}{'+hexlong(tounixdate(getdosdate))+
'}{(c) 1996 Epoch Software. All Rights Reserved.}{'+^P+'}{}';
isi:='EMSI_ISI'+hexstr(length(isi))+isi;
assign(t,adrv(systat^.trappath)+'EMSI'+cstrn(cnode)+'.LOG');
rt:=timer;
{$I-} append(t); {$I+}
if (ioresult<>0) then begin
        rewrite(t);
end;
writeln(t,'');
writeln(t,'IEMSI Transmission Dump for '+date+' '+time);
writeln(t,'');
writeln(t,'Attempting to negotiate IEMSI session...');
found:=false;
        tries:=0;
        ox:=wherex;
        oy:=wherey;
        oc:=textattr;
        setwindow2(w,10,8,70,16,3,0,8,'Negotiating...','IEMSI Session',TRUE);
        textcolor(3);
        textbackground(0);
        gotoxy(2,2);
        write('Real Name  :');
        gotoxy(2,3);
        write('Alias      :');
        gotoxy(2,4);
        write('Phone      :');
        gotoxy(2,5);
        write('Access Key :');
        gotoxy(2,6);
        write('Emulation  :');
        repeat
        pr('**EMSI_IRQ8E08');
        wantout:=FALSE;
        sprompt(gstring(1));
        wantout:=TRUE;
        rt2:=timer;
        inc(tries);
        if (tries>3) then begin
                isiemsi:=1;
                writeln(t,'');
                writeln(t,'');
                writeln(t,'Unable to negotiate IEMSI session... (timed out)');
                close(t);
        removewindow(w);
        window(1,1,80,24);
        gotoxy(ox,oy);
        textattr:=oc;
                exit;
        end;
        c:=#0;
        s:='';
        skip:=FALSE;
        while (tcheck(rt2,20)) and (c<>#13) and not(hangup) and not(found)
        and not(skip) do begin
                c:=cinkey;
                if (s='') and (c<>#0) and (c<>'*') then begin
                        buf:=buf+c;
                        isiemsi:=2;
                writeln(t,'');
                writeln(t,'');
                writeln(t,'Unable to negotiate IEMSI session...');
                        close(t);
        removewindow(w);
        window(1,1,80,24);
        gotoxy(ox,oy);
        textattr:=oc;
                        exit;
                end else begin
                if (c<>#0) then write(t,c);
                end;
                if (c<>#0) and (c<>#13) then begin
                        s:=s+c;
                end;
                if (c=#13) then begin
                        if (copy(s,1,10)='**EMSI_ICI') then found:=TRUE else
                        begin
                                pr('**EMSI_NAKEEC3');
                                skip:=TRUE;
                        end;
                end;
                { wait for EMSI_ICI }
        end;
        until not(tcheck(rt,60)) or (found);
        if not(found) then begin
                isiemsi:=1;
                close(t);
                writeln(t,'');
                writeln(t,'');
                writeln(t,'Unable to negotiate IEMSI session...');
        removewindow(w);
        window(1,1,80,24);
        gotoxy(ox,oy);
        textattr:=oc;
                exit;
        end;
        ici:=s;
        found:=FALSE;
        tries:=0;
        repeat
        pr('**'+isi+getcrc);
        rt2:=timer;
        inc(tries);
        if (tries>3) then begin
                isiemsi:=1;
                writeln(t,'');
                writeln(t,'');
                writeln(t,'Unable to negotiate IEMSI session... (timed out)');
                close(t);
        removewindow(w);
        window(1,1,80,24);
        gotoxy(ox,oy);
        textattr:=oc;
                exit;
        end;
        c:=#0;
        s:='';
        skip:=FALSE;
        while (tcheck(rt2,20)) and (c<>#13) and not(hangup) and not(found)
        and not(skip) do begin
                c:=cinkey;
                if (c<>#0) then write(t,c);
                if (s='') and (c<>#0) and (c<>'*') then begin
                        buf:=buf+c;
                        isiemsi:=2;
                writeln(t,'');
                writeln(t,'');
                writeln(t,'Unable to negotiate IEMSI session...');
                        close(t);
        removewindow(w);
        window(1,1,80,24);
        gotoxy(ox,oy);
        textattr:=oc;
                        exit;
                end;
                if (c<>#0) and (c<>#13) then begin
                        s:=s+c;
                end;
                if (c=#13) then begin
                        if (copy(s,1,10)='**EMSI_ACK') then found:=TRUE else
                        begin
                                skip:=TRUE;
                        end;
                end;
                { wait for EMSI_ICI }
        end;
        until not(tcheck(rt,60)) or (found);
        if not(found) then begin
                isiemsi:=1;
                writeln(t,'');
                writeln(t,'');
                writeln(t,'Unable to negotiate IEMSI session...');
                close(t);
        removewindow(w);
        window(1,1,80,24);
        gotoxy(ox,oy);
        textattr:=oc;
                exit;
        end;
        isiemsi:=0;
        writeln(t);
        close(t);
        textcolor(15);
        iname:=copy(ici,pos('{',ici)+1,pos('}',ici)-pos('{',ici)-1);
        gotoxy(15,2);
        write(mln(iname,40));
        ici:=copy(ici,pos('}',ici)+1,length(ici));
        ialias:=copy(ici,pos('{',ici)+1,pos('}',ici)-pos('{',ici)-1);
        gotoxy(15,3);
        write(mln(ialias,40));
        ici:=copy(ici,pos('}',ici)+1,length(ici));
        s:=copy(ici,pos('{',ici)+1,pos('}',ici)-pos('{',ici)-1);
        ici:=copy(ici,pos('}',ici)+1,length(ici));
        s:=copy(ici,pos('{',ici)+1,pos('}',ici)-pos('{',ici)-1);
        ici:=copy(ici,pos('}',ici)+1,length(ici));
        ivoice:=copy(ici,pos('{',ici)+1,pos('}',ici)-pos('{',ici)-1);
        gotoxy(15,4);
        write(mln(ivoice,40));
        ici:=copy(ici,pos('}',ici)+1,length(ici));
        ipassword:=copy(ici,pos('{',ici)+1,pos('}',ici)-pos('{',ici)-1);
        ipassword:=allcaps(ipassword);
        gotoxy(15,5);
        if (systat^.localscreensec) then
        write(padleft('','*',40))
        else
        write(mln(ipassword,40));
        ici:=copy(ici,pos('}',ici)+1,length(ici));
        s:=copy(ici,pos('{',ici)+1,pos('}',ici)-pos('{',ici)-1);
        ici:=copy(ici,pos('}',ici)+1,length(ici));
        if allcaps(copy(s,1,pos(',',s)-1))='AVT0' then ansidetected:=TRUE;
        if allcaps(copy(s,1,pos(',',s)-1))='ANSI' then ansidetected:=TRUE;
        if allcaps(copy(s,1,pos(',',s)-1))='TTY' then ansidetected:=FALSE;
        delay(1000);
        removewindow(w);
        window(1,1,80,24);
        gotoxy(ox,oy);
        textattr:=oc;
        buf:='';
        curco:=7;
end;

end.

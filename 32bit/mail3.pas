{$A+,B+,D-,E+,F+,I+,L+,N-,O+,R-,S+,V-}
unit mail3;

interface

uses
  crt, dos, common, mail0, mkglobt;

procedure readmsg(dkludge:boolean; var abort,next:boolean);
procedure exportmsg(filename:string; anum,mnum,tnum:longint; var abort,next:boolean);

const lastmsgansi:boolean=FALSE;

implementation

{ anum=actual, mnum=M#/t#, tnum=m#/T# }
procedure readmsg(dkludge:boolean; var abort,next:boolean);
var c:char;
    s,s2:string;
    i:word;
    i2,j,x:integer;
    gottoname,readto,strcolor,stripit,done:boolean;

begin
  emailto:='';
  gottoname:=FALSE;
  readto:=FALSE;
  mabort:=FALSE;
  abort:=FALSE;
  next:=FALSE;
  with CurrentMSG^ do begin
    if (memboard.mbtype=3) then begin
        MsgTxtStartUp;
        s:=GetNoKludgeStr(79);
        if (allcaps(copy(s,1,4))='TO: ') then begin
                gottoname:=TRUE;
                emailto:=copy(s,5,length(s)-4);
        end;
    end;
    sprompt(gstring(580));
    sprompt(gstring(581));
    sprompt(gstring(582));
    sprompt(gstring(583));
    sprompt(gstring(584));
    sprompt(gstring(585));
    if (hangup) then exit;
    wkey(abort,next);
    if (not abort) then begin
      reading_a_msg:=TRUE;
      mpausescr:=true;
      read_with_mci:=FALSE;
      abort:=FALSE;
      next:=FALSE;
      mabort:=FALSE;
      CurrentMSG^.MsgTxtStartUp;
      while not(currentmsg^.EOM) and not(abort) and not(hangup) do begin
        s:=GetString(80);
        while (CurrentMSG^.WasWrap) and not(currentmsg^.EOM) and (length(s)<75) do begin
          s:=s+' '+CurrentMSG^.GetString(78-Length(s));
        end;
        if (mbshowcolor in memboard.mbstat) then strcolor:=FALSE else strcolor:=TRUE;
        setc(memboard.text_color);
        s2:=s;
        j:=pos('>',s2);
        stripit:=false;        
        if ((j>0) and (j<=5)) then begin
              if (pos('<',s2)=0) or (pos('<',s2)>5) then begin
                  setc(memboard.quote_color);
                  strcolor:=TRUE;
              end;
        end else setc(memboard.text_color);
        if (copy(s2,1,4)='... ') then begin
            setc(memboard.tag_color);
            strcolor:=TRUE;
        end;
        if (copy(s2,1,4)='___ ') or (copy(s2,1,4)='~~~ ') then begin
                setc(memboard.oldtear_color);
                strcolor:=TRUE;
        end;
        if (copy(s2,1,4)='--- ') then begin
            setc(memboard.tear_color);
            strcolor:=TRUE;
        end;
        if (copy(s2,1,10)=' * Origin:') then 
                begin
                if (mbsorigin in memboard.mbstat) then stripit:=true else
                setc(memboard.origin_color);
                strcolor:=TRUE;
                end;
        if (mbskludge in memboard.mbstat) and not(dkludge) then begin
                if (copy(s2,1,1)=#1) then stripit:=true;
        end else if (dkludge) then begin
                if (copy(s2,1,1)=#1) then setc(memboard.oldtear_color);
                strcolor:=TRUE;
        end;
        if (mbsseenby in memboard.mbstat) and not(dkludge) then begin
                if (copy(s2,1,8)='SEEN-BY:') then stripit:=true;
        end else if (dkludge) then begin
                if (copy(s2,1,8)='SEEN-BY:') then setc(memboard.oldtear_color);
                strcolor:=TRUE;
        end;
        if (strcolor) then s2:=stripcolor(s2);
        i2:=pos(#27,s);
        if (i2<>0) then lastmsgansi:=TRUE;
        while (i2<>0) do begin
                s[i2]:='*';
                i2:=pos(#27,s);
        end;
        while (pos(#13,s)<>0) do
                delete(s,pos(#13,s),1);
        while (pos(#10,s)<>0) do 
                delete(s,pos(#10,s),1);
        i2:=pos(#12,s);
        while (i2<>0) do begin
                delete(s,i2,1);
                i2:=pos(#12,s);
        end;
        noshowmci:=TRUE;
        if (mbshowcolor in memboard.mbstat) then noshowpipe:=FALSE else noshowpipe:=TRUE;
        dyny:=TRUE;
        if not(stripit) then begin
                if (gottoname) and (allcaps(copy(s2,1,3))='TO:') then begin
                        gottoname:=FALSE;
                        readto:=TRUE;
                end else begin
                      if (copy(s2,1,1)<>^A) then gottoname:=FALSE;
                      if (readto) and (s2='') then begin
                      end else begin
                        sprint(copy(s2,1,80));
                      end;
                      readto:=FALSE;
                end;
        end;
        noshowpipe:=false;
        noshowmci:=false;
        wkey(abort,next);
        next:=FALSE;
        if (mabort) then abort:=true;
      end;
      read_with_mci:=FALSE;
      reading_a_msg:=false;
      noshowmci:=false;
      if not(mabort) then nl;
      ctrljoff:=false;
      mabort:=false;
    end;
  end;
  mpausescr:=false;
  emailto:='';
  reading_a_msg:=FALSE;
end;

procedure exportmsg(filename:string; anum,mnum,tnum:longint; var abort,next:boolean);
var c:char;
    s,s1,s2:string;
    i:word;
    i2,j,x:integer;
    t:text;
    gottoname,readto,stripit,done:boolean;

begin
  emailto:='';
  gottoname:=FALSE;
  readto:=FALSE;
  mabort:=FALSE;
  abort:=FALSE;
  next:=FALSE;

  assign(t,filename);
  if (exist(filename)) then begin
        if pynq('%150%'+filename+' %030%exists.  Append message to it? %150%') then
        begin
                {$I-} append(t); {$I+}
                if (ioresult<>0) then begin
                        sprompt('|LF|%120%Error opening file: '+allcaps(filename)+'|LF||LF|');
                        exit;
                end;
        end else begin
                {$I-} rewrite(t); {$I+}
                if (ioresult<>0) then begin
                        sprompt('|LF|%120%Error creating file: '+allcaps(filename)+'|LF||LF|');
                        exit;
                end;
        end;
  end else begin
  {$I-} rewrite(t); {$I+}
  if (ioresult<>0) then begin
        sprompt('|LF|%120%Error creating file: '+allcaps(filename)+'|LF||LF|');
        exit;
  end;
  end;

  with CurrentMSG^ do begin
    SeekFirst(anum);    
    if not(seekfound) then exit;

    MsgStartUp;
    if (memboard.mbtype=3) then begin
    MsgTxtStartUp;
    s:=GetNoKludgeStr(79);
    if (allcaps(copy(s,1,4))='TO: ') then begin
        gottoname:=TRUE;
        emailto:=copy(s,5,length(s)-4);
    end;
    end;
    loadboard(board);
    write(t,stripcolor(processMCI(gstring(580))));
    write(t,stripcolor(processMCI(gstring(581))));
    write(t,stripcolor(processMCI(gstring(582))));
    write(t,stripcolor(processMCI(gstring(583))));
    write(t,stripcolor(processMCI(gstring(584))));
    write(t,stripcolor(processMCI(gstring(585))));
    if not(abort) then begin
      reading_a_msg:=TRUE;
      mpausescr:=true;
      read_with_mci:=FALSE;
      abort:=FALSE;
      next:=FALSE;
      mabort:=FALSE;
      MsgTxtStartUp;
      while not(currentmsg^.EOM) and not(abort) and not(hangup) do begin
        s:=GetString(80);
        while (CurrentMSG^.WasWrap) and not(currentmsg^.EOM) and (length(s)<75) do begin
          s:=s+' '+CurrentMSG^.GetString(78-Length(s));
        end;
        setc(memboard.text_color);
        s2:=stripcolor(s);
        stripit:=false;        
        if (copy(s2,1,10)=' * Origin:') then 
                begin
                if (mbsorigin in memboard.mbstat) then stripit:=true;
                end;
        if (mbskludge in memboard.mbstat) then begin
                if (copy(s2,1,1)=#1) then stripit:=true;
                end;
        if (mbsseenby in memboard.mbstat) then begin
                if (copy(s2,1,8)='SEEN-BY:') then
                        stripit:=true;
                end;
        i2:=pos(#27,s);
        while (i2<>0) do begin
                s[i2]:='*';
                i2:=pos(#27,s);
        end;
        while (pos(#13,s)<>0) do
                delete(s,pos(#13,s),1);
        while (pos(#10,s)<>0) do 
                delete(s,pos(#10,s),1);
        i2:=pos(#12,s);
        while (i2<>0) do begin
                delete(s,i2,1);
                i2:=pos(#12,s);
                end;
        noshowmci:=TRUE;
        noshowpipe:=true;
        if not(stripit) then begin
                if (gottoname) and (allcaps(copy(s2,1,3))='TO:') then begin
                        gottoname:=FALSE;
                        readto:=TRUE;
                end else begin
                if (copy(s2,1,1)<>^A) then gottoname:=FALSE;
                if (readto) and (s2='') then begin
                end else writeln(t,copy(s2,1,80));
                readto:=FALSE;
                end;
        end;
        noshowpipe:=false;
        noshowmci:=false;
        next:=FALSE;
        abort:=FALSE;
      end;
      read_with_mci:=FALSE;
      reading_a_msg:=false;
      noshowmci:=false;

      ctrljoff:=false;
      mabort:=false;
    end;
  end;
  mpausescr:=false;
  reading_a_msg:=FALSE;
  close(t);
end;

end.

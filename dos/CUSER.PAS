{$A+,B+,D-,E+,F+,I+,L+,N-,O+,R+,S+,V-}
unit cuser;

interface

uses
  crt, dos, common;

procedure cstuff(which,how:byte);

implementation

(******************************************************************************
 procedure: cstuff(which,how:byte);
---
 purpose:   Inputs user information.
---
 variables passed:

    which- 1:Address        6:Occupation  11:Screen size
           2:Age            7:User name   12:Sex
           3:ANSI status    8:Phone #     13:BBS reference
           4:City & State   9:Password    14:Zip code
           5:Computer type 10:Real name

      how- 1:New user logon in process
           2:Menu edit command
           3:Called by the user-list editor

******************************************************************************)

uses file6,archive1;

procedure cstuff(which,how:byte);
var done,done1:boolean;
    try:integer;
    fi:text;
    s:astr;
    i:integer;

  procedure selectlanguage;
  var lf:file of languagerec;
      l:languagerec;
      x:integer;
      s:string;
  begin
  assign(lf,adrv(systat^.gfilepath)+'LANGUAGE.DAT');
  filemode:=66;
  {$I-} reset(lf); {$I+}
  if (ioresult<>0) then begin
        sl1('!','Error opening LANGUAGE.DAT.');
        sl1('!','Set language to #1');
        thisuser.language:=1;
        clanguage:=1;
        getlang(thisuser.language);
        sprompt(gstring(292));
        done1:=TRUE;
        exit;
  end;
  if (filesize(lf)=2) then begin
        thisuser.language:=1;
        clanguage:=1;
        getlang(thisuser.language);
        sprompt(gstring(292));
        done1:=TRUE;
        exit;
  end;
  repeat
  sprompt(gstring(290));
  seek(lf,1);
  x:=1;
  while not(eof(lf)) do begin
        read(lf,l);
        sprint('%150%'+mln(cstr(x),3)+' %030%'+l.name);
        inc(x);
  end;
  sprompt(gstring(291));
  scaninput(s,^M,TRUE);
  if (s=#13) then s:='1';
  x:=value(s);
  if (x<filesize(lf)) then begin
        thisuser.language:=x;
        clanguage:=x;
        done1:=TRUE;
  end;
  until (done1);
  close(lf);
  getlang(thisuser.language);
  sprompt(gstring(292));
  end;

  procedure phonezipentry;
  var s1:astr;
      allowed:string;
      c:char;
  begin
  sprompt(gstring(202));
  sprompt(gstring(203));
  sprompt(gstring(204));
  sprompt(gstring(205));
  sprompt(gstring(206));
  allowed:=gstring(207);
  if (length(allowed)<3) then allowed:='123';
  onek(c,allowed);
  case pos(c,allowed) of
        1:begin
                callfromarea2:=1;
                callfromarea:=1;
            end;
        2:begin
                callfromarea:=1;
                callfromarea2:=2;
            end;
        3:begin
                callfromarea:=2;
                callfromarea2:=2;
            end;
  end;
  done1:=TRUE;
  end;

  procedure doaddress;
  var s1,s2:astr;
  begin
    sprompt(gstring(208));
    inputcaps(s1,30);
    if (s1<>'') then begin
      thisuser.street:=s1;
      done1:=TRUE;
    end;
    sprompt(gstring(209));
    inputcaps(s2,30);
    if (s2<>'') then begin
      thisuser.street2:=s2;
      done1:=TRUE;
    end;
  end;

  procedure getmsgeditor;
  var msgf:file of doorrec;
      s:string;
      m:doorrec;
      x:integer;
      tempstr:string[3];
      bb:byte;

  begin
  tempstr:=gstring(254)+^M;
  assign(msgf,adrv(systat^.gfilepath)+'EDITORS.DAT');
  {$I-} reset(msgf); {$I+}
  if (ioresult<>0) then begin
        thisuser.msgeditor:=0;
        if (how<>1) then
        sprompt(gstring(250));
        done1:=TRUE;
        exit;
  end;
  if (filesize(msgf)<2) then begin
        thisuser.msgeditor:=0;
        if (how<>1) then
        sprompt(gstring(250));
        done1:=TRUE;
        exit;
  end;
  seek(msgf,1);
  sprompt(gstring(251));
  if (thisuser.msgeditor=0) then sprompt(gstring(253)) else nl;
  sprompt(gstring(252));
  if (thisuser.msgeditor=-1) then sprompt(gstring(253)) else nl;
  x:=1;
  while not(eof(msgf)) do begin
                {$I-} seek(msgf,x); {$I+}
                read(msgf,m);
                if (m.DOORfilename<>'') then
                sprompt('%080%[%150%'+cstr(x)+'%080%] %110%'+m.doorname);
                if (thisuser.msgeditor=x) then sprompt(gstring(253)) else nl;
                inc(x);
  end;  
  x:=x-1;
  sprompt(gstring(212));
  scaninput(s,tempstr,TRUE);
        case pos(s[1],tempstr) of
                1:begin
                        thisuser.msgeditor:=0;
                  end;
                2:begin
                        thisuser.msgeditor:=-1;
                  end;
                else begin
                  bb:=value(s);
                  if (bb<=x) and (bb>0) then begin
                        seek(msgf,bb);
                        read(msgf,m);
                        if (m.DOORfilename<>'') then begin
                                thisuser.msgeditor:=bb;
                        end;
                  end;
                end;
                end;
        sprompt(gstring(250));
        close(msgf);
        done1:=TRUE;
        nl;
  end;


  procedure doage;
  var b:byte;
      s:astr;

    function numsok(s:astr):boolean;
    var i:integer;
    begin
      numsok:=FALSE;
      for i:=1 to 10 do
        if not ((s[i] in ['0'..'9']) or (i=3) or (i=6)) then exit;
      numsok:=TRUE;
    end;

  begin
    sprompt(gstring(214));
    s:='';
    getbirth(s,false);
    if (length(s)=10) then
      if (numsok(s)) then
        if (ageuser(s)>3) then begin
          thisuser.bday:=u_daynum(s);
          done1:=TRUE;
        end;
    if ((not done1) and (how=1)) then sprompt(gstring(215));
  end;

  procedure asktaglines;
  begin
    dyny:=true;
    if pynq(gstring(216)) then
        thisuser.ac:=thisuser.ac+[usetaglines] else
        thisuser.ac:=thisuser.ac-[usetaglines];
    done1:=true;
  end;

  procedure tog_taglines;
    begin
    if (usetaglines in thisuser.ac) then begin
        thisuser.ac:=thisuser.ac-[usetaglines];
        sprompt(gstring(217));
        end else begin
        sprompt(gstring(218));
        thisuser.ac:=thisuser.ac+[usetaglines];
        end;
    done1:=true;
    end;

  procedure doansi;
  begin
    if (ansidetected) then begin
        thisuser.ac:=thisuser.ac+[ansi,color];
        sprompt(gstring(219));
        dyny:=TRUE;
        if not(pynq(gstring(222))) then thisuser.ac:=thisuser.ac-[color];
    end else begin
    pr(#27+'[0;1;5;33;40mNexus Bulletin Board System'+#27+'[0m'); 
    textcolor(30);
    textbackground(0);
    curco:=(30 or (0 shl 4));
    writeln('Nexus Bulletin Board System');
    textcolor(7);
    textbackground(0);
    curco:=(7 or (0 shl 4));
    sprompt(gstring(220));
    if pynq(gstring(221)) then begin
      thisuser.ac:=thisuser.ac+[ansi,color];
      if (how=2) then ansidetected:=TRUE;
      dyny:=TRUE;
      if not(pynq(gstring(222))) then thisuser.ac:=thisuser.ac-[color];
    end;
    end;
    done1:=TRUE;
  end;

  procedure dobusiness;
  var s:string;
  begin
     sprompt(gstring(223));
     sprompt(gstring(19));
     if (thisuser.business<>'') then
     defaultst:=thisuser.business else
     defaultst:=thisuser.citystate;
     inputdef(s,40,'');
     defaultst:='';
     if s<>'' then begin
     thisuser.business:=s;
     done1:=true;
     end;
  end;

  procedure docitystate;
  var s,s1,s2:astr;
  begin
      sprompt(gstring(224));
      inputcaps(s1,26);
      while (copy(s1,1,1)=' ') do s1:=copy(s1,2,length(s1)-1);
      while (copy(s1,length(s1),1)=' ') do s1:=copy(s1,1,length(s1)-1);
      if (length(s1)<2) then begin
        sprompt(gstring(225));
        exit;
      end;
      if (pos(',',s1)=0) then begin
        sprompt(gstring(226));
        exit;
      end;
      thisuser.citystate:=s1;
      done1:=TRUE;
  end;

  procedure docomputer;
  begin
    sprompt(gstring(227));
    inputl(s,30);
    if (s<>'') then begin
      thisuser.option1:=s;
      done1:=TRUE;
    end;
  end;

  procedure dojob;
  begin
    sprompt(gstring(228));
    inputl(s,40);
    if (s<>'') then begin
      thisuser.option2:=s;
      done1:=TRUE;
    end;
  end;

  procedure doname;
  var i:integer;
      s1,s2:astr;
      sfo:boolean;
      sr:smalrec;
  begin
    sprompt(gstring(229));
    sprompt(gstring(19)); inputcaps(s,36);
    
    done1:=TRUE;
    if ((not (s[1] in ['A'..'Z','?'])) or (s='')) then done1:=FALSE;
    if (s='') then if pynq(gstring(230)) then
        begin
                s:=thisuser.realname;
                done1:=TRUE;
        end;
    sfo:=(filerec(sf).mode<>fmclosed);
    if (not sfo) then reset(sf);
    for i:=1 to filesize(sf)-1 do begin
      seek(sf,i); read(sf,sr);
      if (allcaps(sr.name)=allcaps(s)) or (allcaps(sr.real)=allcaps(s)) then begin
        done1:=FALSE;
      end;
    end;
    if (not sfo) then close(sf);
    assign(fi,adrv(systat^.gfilepath)+'LOCKOUT.TXT');
    {$I-} reset(fi); {$I+}
    if (ioresult=0) then begin
      s2:=' '+s+' ';
      while not eof(fi) do begin
        readln(fi,s1);
        if s1[length(s1)]=#1 then s1[length(s1)]:=' ' else s1:=s1+' ';
        s1:=' '+s1;
        for i:=1 to length(s1) do s1[i]:=upcase(s1[i]);
        if pos(allcaps(s1),allcaps(s2))<>0 then begin
          done1:=FALSE;
        end;
      end;
      close(fi);
    end;
    if (not done1) and (s<>'') and (not hangup) then begin
      sprint(gstring(231));
      inc(try);
      sl1('!','Unacceptable Name : '+s);
    end;
    if (done1) then thisuser.name:=s;
  end;

  procedure donickname;
  var i:integer;
      s1,s2:astr;
      sfo:boolean;
      sr:smalrec;
  begin
    sprompt(gstring(255));
    sprompt(gstring(19)); inputl(s,8);
    
    done1:=TRUE;
    if ((not (s[1] in ['A'..'Z','a'..'z'])) or (s='')) then done1:=FALSE;
    sfo:=(filerec(sf).mode<>fmclosed);
    if (not sfo) then reset(sf);
    for i:=1 to filesize(sf)-1 do begin
      seek(sf,i); read(sf,sr);
      if (allcaps(sr.nickname)=allcaps(s)) then begin
        done1:=FALSE;
      end;
    end;
    if (not sfo) then close(sf);
    assign(fi,adrv(systat^.gfilepath)+'LOCKOUT.TXT');
    {$I-} reset(fi); {$I+}
    if (ioresult=0) then begin
      s2:=' '+s+' ';
      while not eof(fi) do begin
        readln(fi,s1);
        if s1[length(s1)]=#1 then s1[length(s1)]:=' ' else s1:=s1+' ';
        s1:=' '+s1;
        for i:=1 to length(s1) do s1[i]:=upcase(s1[i]);
        if pos(allcaps(s1),allcaps(s2))<>0 then begin
          done1:=FALSE;
        end;
      end;
      close(fi);
    end;
    if (not done1) and (s<>'') and (not hangup) then begin
      sprint(gstring(231));
      inc(try);
      sl1('!','Unacceptable Name : '+s);
    end;
    if (done1) then thisuser.nickname:=s;
  end;

  procedure dophone(type1:byte);
  begin
    if (how=2) and (thisuser.phentrytype=0) then begin
        phonezipentry;
        nl;
    end;
    if (callfromarea=2) then begin
        sprompt(gstring(231+type1));
        input(s,20);
    end else begin
    sprompt(gstring(231+type1));
    if ((how=1) and (type1=1)) then getphone(s,TRUE) else getphone(s,FALSE);
    end;
    case type1 of
        1:thisuser.phone1:=s;
        2:thisuser.phone2:=s;
        3:thisuser.phone3:=s;
        4:thisuser.phone4:=s;
    end;
    done1:=TRUE;
  end;

  procedure dopw;
  var s,s2:astr;
  outloop:boolean;
  ptries:integer;
  
  begin
    case how of
      1:begin
          sprompt(gstring(268));
          sprompt(gstring(269)); input(s,20);
          if (length(s)<4) then begin
            sprompt(gstring(270));
          end else begin
          if (length(s)>20) then begin
            sprompt(gstring(271));
          end else begin
            ptries:=0;
            repeat
            sprompt(gstring(272));
            sprompt(gstring(273));input(s2,20);
            if (s2=s) then
                begin
                sprint(gstring(274));
                outloop:=true;
                done1:=true;
                end
            else
                begin
                sprint(gstring(6));
                ptries:=1;
                end;
            until ((outloop) or (ptries=3));
            if ptries=3 then hangup2:=true;
            if (done1) then thisuser.pw:=s;
          end;
        end;
        end;
      2:begin
          sprompt(gstring(268));
          sprompt(gstring(275)); input(s,20);
          if (s<>thisuser.pw) then sprint(gstring(276))
          else begin
            sprompt(gstring(277));
            repeat
              prt(gstring(278)); mpl(20); input(s,20);
              if (length(s)<4) then begin
                    sprompt(gstring(270));
              end;
              if (length(s)>20) then begin
                    sprompt(gstring(271));
              end;
            until (((length(s)>=4) and (length(s)<=20)) or (s='') or (hangup));
            if (s<>'') then begin
            ptries:=0;
            repeat
            sprompt(gstring(279));
            sprompt(gstring(280));input(s2,20);
            if (s2=s) then
                begin
                sprint(gstring(281));
                outloop:=true;
                done1:=true;
                end
            else
                begin
                sprint(gstring(282));
                ptries:=1;
                end;
            until ((outloop) or (ptries=3));
            if ptries=3 then hangup2:=true;
            if (done1) then thisuser.pw:=s;
            end else
              sprint(gstring(23));
          end;
         end;
    end;
  end;

  procedure dorealname;
  var i:integer;
      don2:boolean;
      s1,s2:astr;
      sfo:boolean;
      sr:smalrec;
  begin
    sprompt(gstring(242));
    sprompt(gstring(19));
    inc(try);
    done1:=TRUE;
    inputcaps(s,36);
    while copy(s,1,1)=' ' do s:=copy(s,2,length(s)-1);
    while copy(s,length(s),1)=' ' do s:=copy(s,1,length(s)-1);
    if (s='') then done1:=FALSE;
    if (pos(' ',s)=0) and (s<>'') and (how<>3) then begin
      sprint(gstring(243));
      s:='';
      done1:=FALSE;
    end;
    sfo:=(filerec(sf).mode<>fmclosed);
    if (not sfo) then reset(sf);
    for i:=1 to filesize(sf)-1 do begin
      seek(sf,i); read(sf,sr);
      if (allcaps(sr.name)=allcaps(s)) or (allcaps(sr.real)=allcaps(s)) then begin
        done1:=FALSE;
      end;
    end;
    if (not sfo) then close(sf);
    assign(fi,adrv(systat^.gfilepath)+'LOCKOUT.TXT');
    {$I-} reset(fi); {$I+}
    if (ioresult=0) then begin
      s2:=' '+s+' ';
      while not eof(fi) do begin
        readln(fi,s1);
        if s1[length(s1)]=#1 then s1[length(s1)]:=' ' else s1:=s1+' ';
        s1:=' '+s1;
        for i:=1 to length(s1) do s1[i]:=upcase(s1[i]);
        if pos(allcaps(s1),allcaps(s2))<>0 then begin
          done1:=FALSE;
        end;
      end;
      close(fi);
    end;
    if (not done1) and (s<>'') and (not hangup2) then begin
      sprint(gstring(231));
      inc(try);
      sl1('!','Unacceptable Name : '+s);
    end;
    if (try>=3) then hangup2:=TRUE;
    if (done1) then begin
      thisuser.realname:=s;
      if not(systat^.allowalias) then thisuser.name:=thisuser.realname;
      done1:=TRUE;
    end;
  end;

  procedure doscreen;
  var v:string;
      bb:byte;
  begin
    if (how=1) then begin
      thisuser.pagelen:=systat^.pagelen;
    end;
    defaultst:=cstr(thisuser.pagelen);
    sprompt(gstring(244));
    inil(bb);
    if (bb>50) then bb:=50;
    if (bb<4) then bb:=4;
    if (not badini) then thisuser.pagelen:=bb;
    nl;
    done1:=TRUE;
  end;

  procedure dosex;
  var c:char;
  begin
    if (how=3) then begin
      sprompt(gstring(113));
      onek(c,'MFU'^M);
      if (c in ['M','F','U']) then thisuser.sex:=c;
    end else begin
      thisuser.sex:=#0;
      repeat
        sprompt(gstring(113));
        onek(thisuser.sex,'MFU'^M);
        if (thisuser.sex=^M) then nl;
      until ((thisuser.sex in ['M','F','U']) or (hangup));
    end;
    done1:=TRUE;
  end;

  procedure dowherebbs;
  begin
    sprompt(gstring(114));
    inputl(s,40);
    if (s<>'') then begin thisuser.option3:=s; done1:=TRUE; end;
  end;

  procedure dozipcode;
  begin
    if (how=2) and (thisuser.zipentrytype=0) then begin
        phonezipentry;
        nl;
    end;
        s:='';
        if (callfromarea2=2) then begin
          sprompt(gstring(115));
          inputl(s,20);
        end else begin
          sprompt(gstring(115));
          getzip(s);
        end;
        thisuser.zipcode:=s;
        done1:=TRUE;
  end;


  procedure tog_ansi;
  var c:char;
      tempstr:string;
  begin
    sprompt(gstring(260));
    sprompt(gstring(261));
    if not(ansidetected) then sprompt(gstring(264))
        else sprompt(gstring(265));
    sprompt(gstring(262));
    if (ansidetected) then sprompt(gstring(264)) else sprompt(gstring(265));
    sprompt(gstring(266));
    tempstr:=gstring(267);
    if (length(tempstr)<3) then tempstr:=mln(tempstr,3);
    onek(c,tempstr);
    thisuser.ac:=thisuser.ac-[ansi,color];
    case pos(c,tempstr) of
      2:begin doansi; end;
    end;
    done1:=TRUE;
  end;

  procedure tog_color;
  begin
    if (color in thisuser.ac) then begin
      thisuser.ac:=thisuser.ac-[color];
      sprint(gstring(119));
    end else begin
      thisuser.ac:=thisuser.ac+[color];
      sprint(gstring(120));
    end;
    done1:=TRUE;
  end;

  procedure tog_pause;
  begin
    if (pause in thisuser.ac) then begin
      thisuser.ac:=thisuser.ac-[pause];
      sprompt(gstring(285));
    end else begin
      thisuser.ac:=thisuser.ac+[pause];
      sprompt(gstring(286));
    end;
    done1:=TRUE;
  end;

  procedure tog_input;
  begin
    sprompt('%030%Input Type : ');
    if (onekey in thisuser.ac) then begin
      thisuser.ac:=thisuser.ac-[onekey];
      sprint('%150%Full Line.');
    end else begin
      thisuser.ac:=thisuser.ac+[onekey];
      sprint('%150%QuickKey.');
    end;
    done1:=TRUE;
  end;

  procedure Check_inp;
  begin
    dyny:=true;
    if pynq(gstring(287)) then
      thisuser.ac:=thisuser.ac+[onekey]
    else
      thisuser.ac:=thisuser.ac-[onekey];
    done1:=TRUE;
  end;

  procedure quickkey;
  begin
        thisuser.ac:=thisuser.ac+[onekey];
        done1:=true;
  end;

  procedure full_line;
  begin
        thisuser.ac:=thisuser.ac-[onekey];
        done1:=true;
  end;
  
  procedure check_mruler;
  begin
    dyny:=true;
    if pynq(gstring(288)) then
      thisuser.mruler:=1
    else
      thisuser.mruler:=2;
    done1:=TRUE;
  end;
  
  procedure tog_mruler;
  begin
    if (thisuser.mruler=1) then begin
      thisuser.mruler:=2;
      sprint('%030%Message Editor Ruler: %150%OFF');
    end else begin
      thisuser.mruler:=1;
      sprint('%030%Message Editor Ruler: %150%ON');
    end;
    done1:=TRUE;
  end;


  procedure tog_expert;
  begin
    if (novice in thisuser.ac) then begin
      thisuser.ac:=thisuser.ac-[novice];
      chelplevel:=1;        
      sprint('%030%Menu Mode: %150%Expert');
    end else begin
      thisuser.ac:=thisuser.ac+[novice];
      chelplevel:=2;
      sprint('%030%Menu Mode: %150%Novice');
    end;
    done1:=TRUE;
  end;

  procedure defaultprotocol;
  var c:char;
  begin
        {$I-} reset(xf); {$I+}
        if (ioresult<>0) then begin
                done1:=TRUE;
                exit;
        end;
        repeat
        sprompt('%090%Please select from the following protocols:|LF||LF|');
        showprots(FALSE,TRUE,FALSE,FALSE);
        sprompt(gstring(201));
        getkey(c);
        c:=upcase(c);
        sprint(c);
        if (c='@') then begin
                thisuser.defprotocol:=c;
                done1:=TRUE;
        end else begin
                if (findprot(c,FALSE,TRUE,FALSE,FALSE)<>-99) then begin
                        thisuser.defprotocol:=c;
                        done1:=TRUE;
                end else begin
                        sprompt(gstring(210));
                end;
        end;
        until (done1);
        close(xf);
  end;

  procedure checkwantpause;
  begin
    dyny:=true;
    if pynq(gstring(289)) then
      thisuser.ac:=thisuser.ac+[pause]
    else
      thisuser.ac:=thisuser.ac-[pause];
    done1:=TRUE;
  end;

  procedure ww(www:integer);
  begin
    case www of
      1:doaddress;     2:doage;         3:doansi;
      4:docitystate;   5:docomputer;    6:dojob;
      7:doname;        8:donickname;    9:dopw;
     10:dorealname;   11:doscreen;     12:dosex;
     13:dowherebbs;   14:dozipcode;    15:selectlanguage;
     16:tog_ansi;     17:tog_color;    18:tog_pause;
     19:tog_input;    20:tog_mruler; 
     22:tog_expert;                    24:checkwantpause;
     25:phonezipentry;                 27:check_inp;
     28:check_mruler; 29:dobusiness;   30:asktaglines;
     31:tog_taglines;                  33:defaultprotocol;
     34:quickkey;     35:full_line;
     37:getmsgeditor; 38:dophone(1);   39:dophone(2);
     40:dophone(3);   41:dophone(4);
     else done1:=TRUE;
    end;
  end;


begin
  try:=0; done1:=FALSE;
  case how of
    1:repeat ww(which) until (done1) or (hangup);
  2,3:begin
        ww(which);
        if not(done1) then sprompt(gstring(23));
      end;
  end;
end;

end.

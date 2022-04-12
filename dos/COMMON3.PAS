{$A+,B+,D-,E+,F+,I+,L-,N-,O+,R+,S+,V-}
unit common3;

interface

uses
  crt, dos,
  myio3,
  tmpcom;

procedure inu(var i:integer);
procedure inul(var i:longint);
procedure ini(var i:byte);
procedure inil(var i:byte);
procedure inputwn1(var v:string; l:integer; flags:string; var changed:boolean);
procedure inputwn(var v:string; l:integer; var changed:boolean);
procedure inputwnwc(var v:string; l:integer; var changed:boolean);
procedure inputscript(var s:string; ml:integer; flags:string);
procedure inputmain(var s:string; ml:integer; flags:string);
procedure inputdef(var s:string; ml:integer; flags:string);
procedure inputwc(var s:string; ml:integer);
procedure input(var s:string; ml:integer);
procedure inputd(var s:string; ml:integer);
procedure inputdl(var s:string; ml:integer);
procedure inputdln(var s:string; ml:integer);
procedure inputdlnp(var s:string; ml:integer);
procedure inputl(var s:string; ml:integer);
procedure inputdef1(var v:string; l:integer; flags:string; var changed:boolean);
procedure inputcaps(var s:string; ml:integer);
procedure mmkey(var s:string);
procedure GetPhone(var s:string; force:boolean);
procedure GetBirth(var s:string;entr:boolean);
procedure GetZip(var s:string);

implementation

uses
  common, common1, common2;

procedure inu(var i:integer);
var s:string[5];
begin
  badini:=FALSE;
  input(s,5); i:=value(s);
  if (s='') then badini:=TRUE;
end;

procedure inul(var i:longint);
var s:string[10];
    e:integer;
begin
  badini:=FALSE;
  input(s,10); val(s,i,e);
  if ((e<>0) or (s='')) then badini:=TRUE;
end;


procedure ini(var i:byte);
var s:string[3];
begin
  badini:=FALSE;
  input(s,3); i:=value(s);
  if s='' then badini:=TRUE;
end;

procedure inil(var i:byte);
var s:string[3];
begin
  badini:=false;
  inputdef(s,3,'L'); i:=value(s);
  if s='' then badini:=true;
end;

procedure inputwn1(var v:string; l:integer; flags:string; var changed:boolean);
var s,os:string;
begin
  os:=v;
  inputmain(s,l,flags);
  if (s=' ') then begin
    dyny:=true;
    if pynq('Set To Empty String? ') then v:='' else
	begin
	end;
    end
  else if (s<>'') then v:=s;
  if (os<>v) then changed:=TRUE;
end;

procedure inputdef1(var v:string; l:integer; flags:string; var changed:boolean);
var s,os:string;
begin
  os:=defaultst;
  inputdef(s,l,flags);
  if (s=' ') then begin
    dyny:=true;
    if pynq('Set To Empty String? ') then v:='' else
	begin
	end;
    end
  else if (s<>'') then v:=s;
  if (os<>v) then changed:=TRUE;
end;

procedure inputwn(var v:string; l:integer; var changed:boolean);
begin
  inputwn1(v,l,'',changed);
end;

procedure inputwnwc(var v:string; l:integer; var changed:boolean);
begin
  inputwn1(v,l,'c',changed);
end;

(* flags: "U" - Uppercase only
	  "C" - Colors allowed
	  "L" - Linefeeds OFF - no linefeed after <CR> pressed
	  "D" - Display old if no change
	  "P" - Capitalize characters ("ERIC OMAN" --> "Eric Oman")
*)
procedure inputmain(var s:string; ml:integer; flags:string);
var os:^string;
    cp:integer;
    c:char;
    origcolor:byte;
    oldecho:boolean;
    xxupperonly,xxcolor,xxnolf,xxredisp,xxcaps:boolean;

  procedure dobackspace;
  var i:integer;
      c:byte;
  begin
    if (cp>1) then begin
      dec(cp);
      if (s[cp] in [#32..#255]) then begin
        outkey(^H); 
        if (trapping) then write(trapfile,^H' '^H);
        if (pap>0) then dec(pap);
      end else begin
        dec(pap);
        if (cp>1) then
	  if (not (s[cp-1] in [#32..#255])) then begin
	    dec(cp); dec(pap);
	  end;
      end;
    end;
  end;

begin
  new(os);
  flags:=allcaps(flags);
  xxupperonly:=(pos('U',flags)<>0); xxcolor:=(pos('C',flags)<>0);
  xxnolf:=(pos('L',flags)<>0); xxredisp:=(pos('D',flags)<>0);
  xxcaps:=(pos('P',flags)<>0);
  origcolor:=lastco; os^:=s;

  checkhangup;
  if (hangup) then begin
        dispose(os);
        exit;
  end;
  if (ml>78-pap) then mpl(78-pap) else
  mpl(ml);
  cp:=1;
  repeat
    getkey(c);
    if (skipcommand) then c:=^M;
    if (xxupperonly) then c:=upcase(c);
    if (xxcaps) then
      if (cp>1) then begin
	if (c in ['A'..'Z','a'..'z']) then
	  if (s[cp-1] in ['A'..'Z','a'..'z']) then begin
	    {if (c in ['A'..'Z']) then c:=chr(ord(c)+32);}
        end else begin
          if (c in ['a'..'z']) then c:=chr(ord(c)-32) else
          if (c in ['A'..'Z']) then c:=chr(ord(c)+32);
        end;
      end else begin
          {c:=upcase(c);}
          if (c in ['a'..'z']) then c:=chr(ord(c)-32) else
          if (c in ['A'..'Z']) then c:=chr(ord(c)+32);
      end;
    if (c in [#32..#255]) then begin
     if (cp<=ml) then begin
          s[cp]:=c;
          inc(cp);
          inc(pap);
          outkey(c);
          if (trapping) then write(trapfile,c);
     end;
    end else case c of
      ^H:dobackspace;
      ^X:while (cp<>1) do dobackspace;
    end;
  until ((c=^M) or (c=^N) or (hangup));
  if (skipcommand) then begin
        s:='';
        cp:=0;
        xxredisp:=FALSE;
  end;
  s[0]:=chr(cp-1);
  if ((xxredisp) and (s='')) then begin
    s:=os^;
    sprompt(s);
  end;
  if (not xxnolf) then nl;
  defaultst:='';
  dispose(os);
  setc(origcolor);
end;

(* flags: "U" - Uppercase only
	  "C" - Colors allowed
	  "L" - Linefeeds OFF - no linefeed after <CR> pressed
	  "D" - Display old if no change
	  "P" - Capitalize characters ("ERIC OMAN" --> "Eric Oman")
*)
procedure inputscript(var s:string; ml:integer; flags:string);
var os:^string;
    cp:integer;
    c:char;
    origcolor:byte;
    oldecho:boolean;
    xxupperonly,xxcolor,xxnolf,xxredisp,xxcaps:boolean;

  procedure dobackspace;
  var i:integer;
      c:byte;
  begin
    if (cp>1) then begin
      dec(cp);
      if (s[cp] in [#32..#255]) then begin
        outkey(^H); 
        if (trapping) then write(trapfile,^H' '^H);
        if (pap>0) then dec(pap);
      end else begin
        dec(pap);
        if (cp>1) then
	  if (not (s[cp-1] in [#32..#255])) then begin
	    dec(cp); dec(pap);
	  end;
      end;
    end;
  end;

begin
  new(os);
  flags:=allcaps(flags);
  xxupperonly:=(pos('U',flags)<>0); xxcolor:=(pos('C',flags)<>0);
  xxnolf:=(pos('L',flags)<>0); xxredisp:=(pos('D',flags)<>0);
  xxcaps:=(pos('P',flags)<>0);
  origcolor:=lastco; os^:=s;

  checkhangup;
  if (hangup) then begin
        dispose(os);
        exit;
  end;
  if (ml>78-pap) then mpl(78-pap) else
  mpl(ml);
  cp:=length(s)+1;
  sprompt(s);
  repeat
    getkey(c);
    if (skipcommand) then c:=^M;
    if (xxupperonly) then c:=upcase(c);
    if (xxcaps) then
      if (cp>1) then begin
	if (c in ['A'..'Z','a'..'z']) then
	  if (s[cp-1] in ['A'..'Z','a'..'z']) then begin
	    {if (c in ['A'..'Z']) then c:=chr(ord(c)+32);}
        end else begin
          if (c in ['a'..'z']) then c:=chr(ord(c)-32) else
          if (c in ['A'..'Z']) then c:=chr(ord(c)+32);
        end;
      end else begin
          {c:=upcase(c);}
          if (c in ['a'..'z']) then c:=chr(ord(c)-32) else
          if (c in ['A'..'Z']) then c:=chr(ord(c)+32);
      end;
    if (c in [#32..#255]) then
     if (cp<=ml) then begin
	s[cp]:=c; inc(cp); inc(pap);
        outkey(c);
	if (trapping) then write(trapfile,c);
      end else
	  begin
	  end
    else case c of
      ^H:dobackspace;
      ^X:while (cp<>1) do dobackspace;
    end;
  until ((c=^M) or (c=^N) or (hangup));
  if (skipcommand) then begin
        s:='';
        cp:=0;
        xxredisp:=FALSE;
  end;
  s[0]:=chr(cp-1);
  if ((xxredisp) and (s='')) then begin
    s:=os^;
    sprompt(s);
  end;
  if (not xxnolf) then nl;
  defaultst:='';
  dispose(os);
  setc(origcolor);
end;

procedure inputdef(var s:string; ml:integer; flags:string);
var x,cp:integer;
    c:char;
    origcolor,curcolor:byte;
    xxnochange,xxdisponly,redist,firsttime,xxupperonly,
    centered,bspc,xxcolor,xxnolf,xxcaps:boolean;

  procedure dobackspace;
  var i:integer;
      c:byte;
  begin
    if (cp>1) then begin
      dec(cp);
      if (s[cp] in [#32..#255]) then begin
        outkey(^H); 
	if (trapping) then write(trapfile,^H' '^H);
	if (pap>0) then dec(pap);
      end else begin
	dec(pap);
	if (cp>1) then
	  if (not (s[cp-1] in [#32..#255])) then begin
	    dec(cp); dec(pap);
	  end;
      end;
    end;
  end;

begin
  redist:=false;
  bspc:=true;
  centered:=false;
  flags:=allcaps(flags);
  xxupperonly:=(pos('U',flags)<>0); xxcolor:=(pos('C',flags)<>0);
  xxdisponly:=(pos('D',flags)<>0); 
  xxnolf:=(pos('L',flags)<>0);
  xxcaps:=(pos('P',flags)<>0);
  xxnochange:=(pos('N',flags)<>0);
  origcolor:=lastco; 
  curcolor:=curco;
  setc(curcolor);
  firsttime:=true;

  checkhangup;
  if (hangup) then exit;
  if (ml>78-pap) then mpl(78-pap) else
  mpl(ml);
  cp:=length(defaultst)+1;
  s:=defaultst;
  if (defaultst<>'') then begin
	sprompt(defaultst);
	end;
  repeat
    setc(curcolor);
    getkey(c);
    if (skipcommand) then begin
        c:=^M;
    end;
    if (xxupperonly) then c:=upcase(c);
    if (xxcaps) then
      if (cp>1) then begin
	if (c in ['A'..'Z','a'..'z']) then
	  if (s[cp-1] in ['A'..'Z','a'..'z']) then begin
	    {if (c in ['A'..'Z']) then c:=chr(ord(c)+32);}
	  end else
	    if (c in ['a'..'z']) then c:=chr(ord(c)-32);
{        if (c in ['A'..'Z','a'..'z']) then
		if (s[cp-1] in ['A'..'Z','a'..'z']) then begin
			if (c in ['A'..'Z']) then c:=chr(ord(c)+32);
                end;}
      end else c:=upcase(c);


    if (c in [#32..#255]) then begin
	if ((firsttime) and (bspc)) then begin
		redist:=false;
                for x:=1 to lenn(defaultst) do prompt(^H' '^H);
		cp:=1;
		s:='';
	end;
	firsttime:=false;
	centered:=true;
	if (cp<=ml) then begin
		s[cp]:=c; inc(cp); inc(pap);
                setc(curcolor);
                outkey(c);
		if (trapping) then write(trapfile,c);
	end else begin end
    end else begin
       {if ((firsttime) and (bspc) and (not (c=^M))) then begin
                for x:=1 to lenn(defaultst) do prompt(^H' '^H);
       end;}
       case c of
	^H:begin bspc:=false;redist:=true; dobackspace; 
		if (cp<2) then firsttime:=TRUE; end;
	#27:begin s:=defaultst; redist:=TRUE; firsttime:=TRUE; centered:=false; end;
	^X:while (cp<>1) do begin bspc:=false; redist:=true; dobackspace; end;
      end;
    end;
    {if ((firsttime) and (redist) and (centered) and not(c=^M)) then begin 
	sprompt(defaultst);
	bspc:=TRUE;
	centered:=false;
    end;}
  until ((c=^M) or (c=^N) or (c=#27) or (hangup));
  if (skipcommand) then begin
        s:='';
        cp:=0;
        c:=#0;
        redist:=FALSE;
  end;
  if (c=^M) then
	if (((firsttime) and (defaultst<>'')) and not(xxdisponly)) then begin 
		if lenn(s)>ml then s:=copy(s,1,ml);
	end else s[0]:=chr(cp-1);
  if ((c=^N) or (hangup)) then s[0]:=chr(cp-1);
  if ((firsttime) and (redist) and not(centered)) then begin
	sprompt(s);
  end;
  if (not xxnolf) then nl;
  defaultst:='';
  setc(origcolor);
end;

procedure inputwc(var s:string; ml:integer);
  begin inputmain(s,ml,'c'); end;

procedure input(var s:string; ml:integer);
  begin inputmain(s,ml,'u'); end;

procedure inputd(var s:string; ml:integer);
  begin inputdef(s,ml,'u'); end;

procedure inputdl(var s:string; ml:integer);
  begin inputdef(s,ml,''); end;

procedure inputdln(var s:string; ml:integer);
  begin inputdef(s,ml,'L'); end;

procedure inputdlnp(var s:string; ml:integer);
  begin inputdef(s,ml,'PL'); end;

procedure inputl(var s:string; ml:integer);
  begin inputmain(s,ml,''); end;

procedure inputcaps(var s:string; ml:integer);
  begin inputmain(s,ml,'p'); end;

procedure mmkey(var s:string);
var s1:string;
    i,newarea:integer;
    c,cc:char;
    achange,bb:boolean;
begin
  s:='';
  if (buf<>'') then
    if (copy(buf,1,1)='`') then begin
      buf:=copy(buf,2,length(buf)-1);
      i:=pos('`',buf);
      if (i<>0) then begin
	s:=allcaps(copy(buf,1,i-1));
	buf:=copy(buf,i+1,length(buf)-i);
	nl;
	exit;
      end;
    end;

  if (not (onekey in thisuser.ac)) then
    input(s,60)
  else
    repeat
      achange:=FALSE;
      repeat
	getkey(c); c:=upcase(c);
      until ((c in [^H,^M,#32..#255]) or (hangup));
      if (c<>^H) then begin
	outkey(c);
	if (trapping) then write(trapfile,c);
	inc(pap);
      end;
      if (c='/') then begin
	s:=c;
	repeat
	  getkey(c); c:=upcase(c);
	until (c in [^H,^M,#32..#255]) or (hangup);
	if (c<>^M) then begin
	  case c of
	    #225:bb:=bb; {* do nothing *}
	  else
	       begin
		 outkey(c);
		 if (trapping) then write(trapfile,c);
	       end;
	  end;
	  inc(pap);
	end else
	  nl;
	if (c in [^H,#127]) then prompt(' '+c);
	if (c in ['/',#225]) then begin
          bb:=systat^.localsec;
	  if (c=#225) then begin
            systat^.localsec:=TRUE;
	    echo:=FALSE;
	  end;
          setc(15 or (0 shl 4));
          input(s,60);
          systat^.localsec:=bb;
	  echo:=TRUE;
	end else
	  if (not (c in [^H,#127,^M])) then begin s:=s+c; nl; end;
      end else
      if (c=';') then begin
	input(s,60);
	s:=c+s;
      end else
      if (c in ['0'..'9']) and ((fqarea) or (mqarea)) then begin
	s:=c; getkey(c);
	if (c in ['0'..'9']) then begin
	  print(c);
	  s:=s+c;
	end;
	if (c=^M) then nl;
	if (c in [^H,#127]) then prompt(c+' '+c);
      end else
	if (c=^M) then nl
	else
	if (c<>^H) then begin
	  s:=c;
	  nl;
	end;
    until (not (c in [^H,#127])) or (hangup);
  if (pos(';',s)<>0) then                 {* "command macros" *}
    if (copy(s,1,2)<>'\\') then begin
      if (onekey in thisuser.ac) then begin
	s1:=copy(s,2,length(s)-1);
	 if (copy(s1,1,1)='/') then s:=copy(s1,1,2) else s:=copy(s1,1,1);
	 s1:=copy(s1,length(s)+1,length(s1)-length(s));
      end else begin
	s1:=copy(s,pos(';',s)+1,length(s)-pos(';',s));
	s:=copy(s,1,pos(';',s)-1);
      end;
      while (pos(';',s1)<>0) do s1[pos(';',s1)]:=^M;
      dm(' '+s1,c);
    end;
end;

procedure GetPhone(var s:string; force:boolean);

var os:string;
    cp,ml:integer;
    c:char;
    origcolor,curcolor:byte;
    xxupperonly,xxcolor,xxnolf,xxredisp,xxcaps:boolean;

  procedure dobackspace;
  var i:integer;
      c:byte;
      x2:integer;
  begin
    if (cp>1) then begin
      dec(cp);
      if (cp=4) then begin
        for x2:=1 to lenn(gstring(107)) do begin
        outkey(^H); 
        if (trapping) then write(trapfile,^H' '^H);
        if (pap>0) then dec(pap);
        end;
	dec(cp);
      end;
      if (cp=8) then begin
        for x2:=1 to lenn(gstring(108)) do begin
        outkey(^H); 
	if (trapping) then write(trapfile,^H' '^H);
	if (pap>0) then dec(pap);
        end;
	dec(cp);
      end;
      if (s[cp] in [#32..#255]) then begin
        outkey(^H); 
	if (trapping) then write(trapfile,^H' '^H);
	if (pap>0) then dec(pap);
      end else begin
	dec(pap);
	if (cp>1) then
	  if (not (s[cp-1] in [#32..#255])) then begin
	    dec(cp); dec(pap);
	  end;
      end;
    end;
  end;

begin
  ml:=12;
  origcolor:=lastco;
  curcolor:=curco;
  os:=s;

  checkhangup;
  if (hangup) then exit;
  mpl(13);
  sprompt(gstring(106));
  setc(curcolor);
  cp:=1;
  repeat
    begin
    getkey(c);
    if (c in [#48..#57]) then
      if (cp<=ml) then 
	begin
	s[cp]:=c; inc(cp); inc(pap); outkey(c);
	if (trapping) then write(trapfile,c);
	if cp=4 then 
		begin
                sprompt(gstring(107));
                setc(curcolor);
		s[cp]:='-';
		inc(cp);
		end;
	if cp=8 then 
		begin
                sprompt(gstring(108));
                setc(curcolor);
		s[cp]:='-';
		inc(cp);
		end;
      end else
	  begin
	  end
    else case c of
      ^H:dobackspace;
      ^X:while (cp<>1) do dobackspace;
    end;
    end;
  until (((c=^M) and not(force)) or ((c=^M) and (cp=13) and (force))
  or (c=^N) or (hangup));
  s[0]:=chr(cp-1);
  nl;
  setc(origcolor);
end;

procedure GetBirth(var s:string;entr:boolean);

var os:string;
    x,cp,ml:integer;
    c:char;
    origcolor,curcolor:byte;
    clearfirst,xxupperonly,xxcolor,xxnolf,xxredisp,xxcaps,ent:boolean;

  procedure dobackspace;
  var i:integer;
      c:byte;
      x2:integer;
  begin
    if ((ent) and (not entr)) then ent:=false;
    if (cp>1) then begin
      dec(cp);
      if (cp=3) then begin
        for x2:=1 to lenn(gstring(109)) do begin
        outkey(^H); 
	if (trapping) then write(trapfile,^H' '^H);
	if (pap>0) then dec(pap);
        end;
        setc(curcolor);
	dec(cp);
      end;
      if (cp=6) then begin
        for x2:=1 to lenn(gstring(110)) do begin
        outkey(^H); 
	if (trapping) then write(trapfile,^H' '^H);
	if (pap>0) then dec(pap);
        end;
        setc(curcolor);
	dec(cp);
      end;
      if (s[cp] in [#32..#255]) then begin
        outkey(^H); 
        setc(curcolor);
	if (trapping) then write(trapfile,^H' '^H);
	if (pap>0) then dec(pap);
      end else begin
	dec(pap);
	if (cp>1) then
	  if (not (s[cp-1] in [#32..#255])) then begin
	    dec(cp); dec(pap);
	  end;
      end;
    end;
  end;

begin
  ml:=10;
  origcolor:=lastco;
  curcolor:=curco;
  os:=s;
  ent:=entr;
  checkhangup;
  clearfirst:=FALSE;
  if (hangup) then exit;
  mpl(10);
  cp:=1;
  if (s<>'') then begin
        clearfirst:=TRUE;
        sprompt(copy(s,1,2));
        sprompt(gstring(109));
        setc(curcolor);
        sprompt(copy(s,4,2));
        sprompt(gstring(110));
        setc(curcolor);
        sprompt(copy(s,7,4));
        cp:=length(s)+1;
  end;
  setc(curcolor);
  repeat
    begin
    getkey(c);
    if (c in [#48..#57]) then begin
      if (clearfirst) then begin
        clearfirst:=FALSE;
        for x:=1 to length(s) do prompt(^H' '^H);
        s:='';
        cp:=1;
      end;
      if (cp<=ml) then begin
	s[cp]:=c; inc(cp); inc(pap); outkey(c);
	if (trapping) then write(trapfile,c);
        if (cp=3) then begin
                sprompt(gstring(109));
                setc(curcolor);
		s[cp]:='/';
		inc(cp);
        end;
        if (cp=6) then begin
                sprompt(gstring(110));
                setc(curcolor);
		s[cp]:='/';
		inc(cp);
        end;
        if (cp=11) then ent:=true;
      end;
    end else begin
    case c of
      ^H:begin
          clearfirst:=FALSE;
          dobackspace;
         end;
      ^X:begin
          clearfirst:=FALSE;
          while (cp<>1) do dobackspace;
         end;
    end;
    end;
    end;
  until (((c=^M) and (ent)) or (c=^N) or (hangup));
  s[0]:=chr(cp-1);
  nl;
  setc(origcolor);
end;

procedure GetZip(var s:string);

var os:string;
    x,cp,ml:integer;
    c:char;
    origcolor,curcolor:byte;
    xxupperonly,xxcolor,xxnolf,xxredisp,xxcaps:boolean;

  procedure dobackspace;
  var i:integer;
      c:byte;
      x2:integer;
  begin
    if (cp>1) then begin
      dec(cp);
      if (cp=6) then begin
        for x2:=1 to lenn(gstring(111)) do begin
        outkey(^H); 
        if (trapping) then write(trapfile,^H' '^H);
	if (pap>0) then dec(pap);
        end;
        setc(curcolor);
	dec(cp);
	end;
      if (s[cp] in [#32..#255]) then begin
        outkey(^H); 
        setc(curcolor);
	if (trapping) then write(trapfile,^H' '^H);
	if (pap>0) then dec(pap);
      end else begin
	dec(pap);
	if (cp>1) then
	  if (not (s[cp-1] in [#32..#255])) then begin
	    dec(cp); dec(pap);
	  end;
      end;
    end;
  end;

begin
  ml:=10;
  origcolor:=lastco;
  curcolor:=curco;
  os:=s;

  checkhangup;
  if (hangup) then exit;
  mpl(10);
  cp:=1;
  repeat
    begin
    getkey(c);
    if (c in [#48..#57]) then
      if (cp<=ml) then 
	begin
	s[cp]:=c; inc(cp); inc(pap); outkey(c);
	if (trapping) then write(trapfile,c);
        if (cp=6) then 
		begin
                sprompt(gstring(111));
                setc(curcolor);
		s[cp]:='-';
		inc(cp);
		end;
      end else
	  begin
	  end
    else case c of
      ^H:dobackspace;
      ^X:while (cp<>1) do dobackspace;
    end;
    end;
  until (((c=^M) and ((cp=7) or (cp=11))) or (c=^N) or (hangup));
  if (cp=7) then for x:=7 to 10 do begin s[x]:='0'; outkey(s[x]); end; 
  s[0]:=chr(10);
  nl;
  setc(origcolor);
end;

end.

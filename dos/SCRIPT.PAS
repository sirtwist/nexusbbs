{$A+,B+,F+,I-,L+,O+,R-,S-,V-}
Unit Script;

Interface

Uses crt,dos,common;

procedure DoScript(Fn,startlabel:String);
Implementation

Uses Menus,doors;

function fileonly(s:string):string;
var
 x : integer;
 done : boolean;
begin
 x := length(s);
 done:=FALSE;
 while (x > 1) and not (done) do begin
       if s[x] = '\' then begin
          done := true;
       end;
       dec(x);
 end;
 if not(done) then s:='' else
 s := copy(s,x+2,length(s));
 fileonly := copy(s,1,pos('.',s)-1);
end;


procedure newstatus(newname:string);
var oc:byte;
    wx,wy:byte;
begin
          oc:=textattr;
          wx:=wherex;
          wy:=wherey;
          window(1,1,80,25);
          gotoxy(27,25);
          textcolor(14);
          textbackground(3);
          write(' Nexecutable : ');
          textcolor(12);
          write(mln(allcaps(newname),15));
          window(1,1,80,24);
          textattr:=oc;
          gotoxy(wx,wy);
end;

function decomp_line(s : string) : string;
var cnt : byte;
    tmp : string;
begin
  tmp := '';
  for cnt := 1 to length(s) do
      tmp := tmp + chr(255 - ord(s[cnt]));
  decomp_line := tmp;
end;

procedure doscript(fn,startlabel:string);
type
 vrec = record  {this is where variables are put}
 n: string[8];
 p: string[80];
 end;

 trec = record {trapkeys}
 k: char;
 l: string[10];
 end;

const
  vmax = 99; {maximum of variables}
  tmax = 9; {maximum of trapkeys - almost unuseful.. gotta change thiz}
  nplver = '2'; {npl ver}
  nplrev = '1'; {npl rev}
  ischained:boolean=FALSE;
var
  filename: string;
  olddir: string;                         {temp variable}
  trapset: set of char;                   {keys that are trapped}
  stmax: integer;                         {unuseful var =)}
  trapesc: string[10];                    {trap data}
  t: array[0..tmax] of ^trec;             {other trap data}
  s, cm: string;                          {temp variables}
  b: boolean;                             {temp boolean}
  curline: integer;                       {current line in proggie}
  v: array[0..vmax] of ^vrec;             {variable data}
  stack: array[0..49] of integer;         {stack data}
  stackpos: byte;                         {stack data}
  f: text;                                {temp var}
  c: integer;                             {temp counter var}
  error: string;                          {error message}
  k: char;                                {temp}
  fsz, finput, foutput: text;             {used with f* commands}
  tmpn: integer;                          {another fucking temp var}
  blah: boolean;                          {i'm bored of temp vars}

function LTrim(stri: string): string;
	begin
  	while (stri[1] = ' ') and (Length(stri) > 0) do
    	stri := Copy(stri, 2, 255);
    LTrim := stri;
  end;

function RTrim(stri: string): string;
  var
  	ok: boolean;
	begin
  	ok := false;
    if Length(stri) > 0 then
    begin
	    repeat
  	  	if stri[Length(stri)] = ' ' then
    	  	stri := Copy(stri, 1, Length(stri)-1)
      	else
      		ok := true;
	    until ok;
    end;
    RTrim := stri;
  end;

function Trim(stri: string): string;
  begin
  	while stri[1] = ' ' do
    	stri := Copy(stri, 2, Length(stri));
    if Pos(' ', stri) > 0 then
    	stri := Copy(stri, 1, Pos(' ', stri)-1);
  	Trim := stri;
  end;

function GoodNum(s: string): boolean;
  var
  	i, code: integer;
	begin
  	Val(s, i, code);
    GoodNum := (code = 0);
	end;

function Remove(st: string; ch: char): string;
	begin
  	while Pos(ch, st) > 0 do
    	Delete(st, Pos(ch, st), 1);
    Remove := st;
  end;

function CtrlStr(st: string): string;
	var
  	tmp: string;
    c2: byte;
  begin
    tmp := '';
    if Length(st) > 0 then
    begin
	    for c2 := 1 to Length(st) do
      	if st[c2] in [#0..#31] then
        	tmp := tmp + '[#'+Cstr(Ord(st[c2]))+']'
        else
        	tmp := tmp + st[c2];
    end;
    CtrlStr := tmp;
  end;

function LeadZero(st: string): string;
	begin
  	if Length(st) = 1 then
    	st := '0'+st;
    LeadZero := st;
  end;

function TimeStr(st: string): string;
  var
  	hr, mn, sc, s1, yr, mt, dy, dw: word;
    tmp: string;
    ct: byte;
	begin
    GetTime(hr, mn, sc, s1);
    GetDate(yr, mt, dy, dw);
    tmp := '';
    if Length(st) > 0 then
    	for ct := 1 to Length(st) do
      	case UpCase(st[ct]) of
        	'H': tmp := tmp + LeadZero(Cstr(hr));
          'M': tmp := tmp + LeadZero(Cstr(mn));
          'S': tmp := tmp + LeadZero(Cstr(sc));
          'X': tmp := tmp + LeadZero(Cstr(s1));
          'Y': tmp := tmp + Cstr(yr);
          'O': tmp := tmp + LeadZero(Cstr(mt));
          'D': tmp := tmp + LeadZero(Cstr(dy));
          'W': tmp := tmp + Cstr(dw);
        else
        	tmp := tmp + st[ct];
        end;
    TimeStr := tmp;
  end;

procedure DisplayVars;
	var
  	c2: byte;
  begin
  	for c2 := 0 to vmax do
    begin
      if v[c2]^.n <> '' then
      begin
      	Write(c2:2, ' ');
	    	Write(v[c2]^.n+mln(' ',8-Length(v[c2]^.n))+' = ');
  	    Writeln(CtrlStr(v[c2]^.p));
      end;
    end;
  end;

function FindVar(s: string): string;
  var
  	tmp: string;
    c2: byte;
	begin
    tmp := '';
  	for c2 := 0 to vmax do
    	if v[c2]^.n = AllCaps(s) then
      	tmp := v[c2]^.p;
  	FindVar := tmp;
  end;

procedure SetVar(n, s: string);
  var
  	c2: byte;
	begin
    if n = '' then
    	error := 'Variable name missing'
    else
    begin
	  	n := AllCaps(n);
  	  c2 := 0;
    	while (v[c2]^.n <> n) and (c2 <> vmax+1) do
    		Inc(c2);
	    if c2 < vmax+1 then
  	  begin
	  	  if s <> '' then
  	  		v[c2]^.p := s
	    	else
  	  		v[c2]^.n := '';
    	end
	    else
  	  begin
    	  c2 := 0;
      	while (v[c2]^.n <> '') and (c2 <> vmax+1) do
      		Inc(c2);
	      if (c2 < vmax+1) and (s <> '') then
  	    begin
    	  	v[c2]^.n := n;
      	  v[c2]^.p := s;
	      end
  	    else if s <> '' then
    	  	error := 'Out of variable space';
	    end;
    end;
  end;

procedure MakeTrapSet;
	var
  	c2: byte;
  begin
    trapset := [];
    for c2 := 0 to tmax do
    begin
      if t[c2]^.k <> #0 then
      	trapset := trapset + [t[c2]^.k];
    end;
  end;

procedure DisplayTraps;
	var
  	c2: byte;
  begin
  	for c2 := 0 to tmax do
    begin
      if t[c2]^.k <> #0 then
      begin
      	Write(c2:2, ' ');
	    	Write(Ord(t[c2]^.k):3, ' = ');
  	    Writeln(CtrlStr(t[c2]^.l));
      end;
    end;
    if trapesc <> '' then
    	Writeln('   Esc = ', CtrlStr(trapesc));
  end;

procedure ClearTraps;
  var
  	c: byte;
	begin
    for c := 0 to tmax do
    begin
    	t[c]^.k := #0;
      t[c]^.l := '';
    end;
    trapesc := '';
  end;

function FindTrap(k: char): string;
  var
  	tmp: string;
    c2: byte;
	begin
    tmp := '';
  	for c2 := 0 to tmax do
    	if t[c2]^.k = k then
      	tmp := t[c2]^.l;
  	FindTrap := tmp;
  end;

procedure SetTrap(k: char; s: string);
  var
  	c2: byte;
	begin
    if k = #0 then
    	error := 'Trap key missing'
    else
    begin
  	  c2 := 0;
    	while (t[c2]^.k <> k) and (c2 <> tmax+1) do
    		Inc(c2);
	    if c2 < tmax+1 then
  	  begin
	  	  if s <> '' then
  	  		t[c2]^.l := s
	    	else
  	  		t[c2]^.k := #0;
    	end
	    else
  	  begin
    	  c2 := 0;
      	while (t[c2]^.k <> #0) and (c2 <> tmax+1) do
      		Inc(c2);
	      if (c2 < tmax+1) and (s <> '') then
  	    begin
    	  	t[c2]^.k := k;
                t[c2]^.l := s;
	      end
  	    else if s <> '' then
    	  	error := 'Out of key trap space';
	    end;
    end;
  end;

procedure DisplayStack;
	var
  	c2: integer;
  begin
    if stackpos > 0 then
    begin
	  	for c2 := 0 to stackpos-1 do
  	  begin
     		Write(c2:2, ' ');
	    	Write('= ');
 		    Writeln(stack[c2]:4);
      end;
    end;
  end;

function Expand(st: string): string;
	var
	  s: string;
    val: string;
    c2, c3, c4: byte;
	begin
    while Pos('&', st) > 0 do
    begin
      c2 := Pos('&', st);
      s := '';
      repeat
        Inc(c2);
        s := s + st[c2];
      until (st[c2] in ['&', ' ']) or (c2 = Length(st));
      s := Copy(s, 1, Length(s)-1);
      if st[c2] = '&' then
      	c3 := 2
      else
      	c3 := 1;
      c4 := Pos('&', st);
      Delete(st, c4, Length(s)+c3);
      val := FindVar(s);
      Insert(val, st, c4);
    end;
    Expand := st;
  end;

function Line(num: integer): string;
  var
    s: string;
    c2: integer;
  begin
    GetDir(0, s);
    if s <> olddir then
    begin
      ChDir(olddir);
      Close(f);
      ChDir(s);
      Assign(f, FExpand(filename));
      Reset(f);
      curline := 0;
      olddir := s;
    end;
    if num > curline then
    begin
    	c2 := curline;
      while c2 < num do
      begin
      	Inc(c2);
        if Eof(f) then
        	s := 'END'
        else
          begin
          Readln(f, s);
          s := decomp_line(s);
          end;
      end;
    end
    else
    begin
      Reset(f);
      c2 := 0;
      while c2 < num do
      begin
      	Inc(c2);
        if Eof(f) then
        	s := 'END'
        else
          begin
          Readln(f, s);
          s := decomp_line(s);
          end;
      end;
    end;
    curline := num;
    if Pos(';', s) > 0 then
    	s := Copy(s, 1, Pos(';', s)-1);
    Line := RTrim(LTrim(s));
  end;

function Search(l: string): integer;
var c2: integer;
    s, lb: string;

begin
    if l <> '' then
    begin
         l := AllCaps(l);
         c2 := 0;
         lb := '';
	    repeat
          Inc(c2);
    		s := Line(c2);
      	if s[1] = ':' then
	      	lb := AllCaps(Copy(s, 2, 255));
         until (s = 'END') or (lb = l);
         if s = 'END' then
         begin
    		error := 'Label not found: '+l;
          c2 := c+1;
         end;
    end
    else
    begin
    	error := 'Label missing';
      c2 := c+1;
    end;
	  Search := c2-1;
  end;

function Cmd(st: string): string;
	begin
    st := AllCaps(st);
  	if Pos(' ', st) > 0 then
    	st := Copy(st, 1, Pos(' ', st)-1);
    Cmd := st;
  end;

function Parm(st: string; num: byte): string;
  var
  	c2: byte;
	begin
    for c2 := 1 to num do
    begin
    	if Pos(' ', st) = 0 then
      	st := ''
      else
      	Delete(st, 1, Pos(' ', st));
    end;
    if Pos(' ', st) > 0 then
      Delete(st, Pos(' ', st), 255);
    Parm := st;
  end;

function ParmLine(st: string; num: byte): string;
  var
  	c2: byte;
	begin
    for c2 := 1 to num do
    begin
	  	if Pos(' ', st) = 0 then
  	  	st := ''
    	else
    		Delete(st, 1, Pos(' ', st));
    end;
    ParmLine := st;
  end;

procedure Compare(s1, s2: string);
  var
    tmp: string;
	begin
    if GoodNum(s1) and GoodNum(s2) then
    begin
    	if Value(s1) = Value(s2) then
      	tmp := '='
      else if Value(s1) < Value(s2) then
      	tmp := '<'
      else
      	tmp := '>';
    end
    else
    begin
	    if s1 = s2 then
  	  	tmp := '='
    	else if s1 < s2 then
    		tmp := '<'
	    else
  	  	tmp := '>';
    end;
    SetVar('COMPARE', tmp);
  end;

function IfComp(symb: string): boolean;
  var
  	tmp: string;
	begin
  	tmp := FindVar('COMPARE');
    IfComp := (Pos(tmp, symb) > 0);
  end;

procedure PushStack(l: integer);
	begin
  	stack[stackpos] := l;
    if stackpos = 49 then
    	error := 'Out of stack space'
    else
	    Inc(stackpos);
  end;

procedure PopStack;
	begin
    if stackpos = 0 then
    	error := 'Unable to pop from stack'
    else
	  	Dec(stackpos);
  end;

function Onf(st: string): boolean;
	begin
  	Onf := (allcaps(st) = 'ON');
  end;

function Off(st: string): boolean;
	begin
  	Off := (allcaps(st) = 'OFF');
  end;

function Char1(s: string): char;
	begin
  	Char1 := s[1];
  end;

procedure Startup(fn: string);
 var c:integer;
	begin
     GetDir(0, olddir);
  	curline := 0;
     filename := FExpand(fn);
     for c:=0 to vmax do
		begin
           New(v[c]);
           v[c]^.n := '';
           v[c]^.p := '';
		end;
     for c:=0 to tmax do
          begin
           new(t[c]);
           t[c]^.k := #0;
           t[c]^.l := '';
          end;

     ClearTraps;
     trapesc := '';
     {default-set variables}
     SetVar('NPLVER', nplver);
     SetVar('NPLREV', nplrev);
     SetVar('SPACE', ' ');
     SetVar('CR', ^M);
     SetVar('LF', ^J);
     SetVar('NULL', #0);
     SetVar('ESC', #27);
     error := '';
     stackpos := 0;
     Assign(f, filename);
     {$I-} Reset(f); {$I+}
     if (ioresult<>0) then begin
          error:='Unable to invoke program';
     end;
  end;

procedure Shutdown;
var c:integer;
begin
  for c:=0 to vmax do
  begin
    Dispose(v[c]);
    v[c] := nil;
  end;
  for c:=0 to tmax do
  begin
    Dispose(t[c]);
    t[c] := nil;
  end;
  {$I-} close(f); {$I+}
  if (ioresult<>0) then begin end;
end;

procedure Run;
  var
    tmpn:integer;
    tmp,cm: string;
    wx, wy: byte;
    d: DirStr;
    n: NameStr;
    fuckup,done:boolean;
    e: ExtStr;

begin
    fuckup:=true;
    {$I-}
    c := 0;
    if (error='') then
    repeat
      Inc(c);
      if (startlabel<>'') then begin
          c:=search(startlabel);
          startlabel:='';
      end;
      s := Expand(Line(c));
      cm := Cmd(s);
      if cm = 'LWRITELN' then
        writeln(ParmLine(s, 1))
      else if cm = 'LWRITE' then
      	write(ParmLine(s, 1))
      else if cm = 'WRITELN' then
        sprint(ParmLine(s, 1))
      else if cm = 'WRITE' then
      	sprompt(ParmLine(s, 1))
      else if cm = 'EXEC' then
      begin
        SwapVectors;
      	Exec(GetEnv('COMSPEC'), '/C '+ParmLine(s, 1));
        SwapVectors;
        SetVar('DOSERR', Cstr(DosError));
      end
      else if cm = 'DEXEC' then
      begin
      	SwapVectors;
        Exec(allcaps(Parm(s, 1)), ParmLine(s, 2));
        SwapVectors;
        SetVar('EL', Cstr(DosExitCode));
        SetVar('DOSERR', Cstr(DosError));
      end
      else if cm = 'GOTO' then
        c := Search(Parm(s, 1))
      else if cm = 'GOSUB' then
      begin
        PushStack(c);
        c := Search(Parm(s, 1));
      end
      else if cm = 'RETURN' then
      begin
      	PopStack;
        c := stack[stackpos];
      end
      else if cm = 'POP' then
      	PopStack
      else if cm = 'PUSH' then
      begin
        if Parm(s, 1) <> '' then
        	PushStack(Search(Parm(s, 1)))
        else
	      	PushStack(c-1);
      end
      else if cm = 'CLSTACK' then
      	stackpos := 0
      else if cm = 'SET' then
        SetVar(Parm(s, 1), processmci(ParmLine(s, 2)))
      else if cm = 'ASK' then
      begin
        if onekey in thisuser.ac then blah := true;
        thisuser.ac := thisuser.ac-[onekey];
        tmp:=findvar(parm(s,1));
        sprompt(ParmLine(s, 4));
        if (allcaps(parm(s,3))='N') then
        inputscript(tmp, value(parm(s,2)), '')
        else
        inputscript(tmp, value(parm(s,2)), parm(s,3));
{        input(tmp, 80-Length(ParmLine(s, 2))-1);}
        SetVar(Parm(s, 1), tmp);
        if blah then thisuser.ac := thisuser.ac+[onekey]
      end
      else if cm = 'YN' then
      begin
        if (pynq(parmline(s, 2)+' ')) then setvar(parm(s,1),'1') else setvar(parm(s,1),'0');
      end
      else if cm = 'UPCASE' then
      	SetVar(Parm(s, 1), allcaps(FindVar(Parm(s, 1))))
      else if cm = 'LOCATE' then
      begin
      	if ansi in thisuser.ac then
        	sprompt(#27'['+Parm(s, 2)+';'+Parm(s, 1)+'H');
      end
      else if cm = 'CLS' then cls
      else if cm = 'CLEOL' then
      begin
      	if ansi in thisuser.ac then
        	sprompt(#27'[K');
      end
      else if cm = 'PAUSE' then
      	Pausescr
      else if cm = 'INKEY' then
      begin
        if (keypressed) or ((incom) and (not com_rx_empty)) then
        begin
          getkey(k);
{          sprompt(cstr(ord(k)));}
{          k:=readkey;}
{          if upcase(k)=upcase(s[1]) then c := Search(Parm(s, 2))}
          if cstr(ord(k))=Parm(s,1) then c := Search(Parm(s, 2))
        end;
      end
      else if cm = 'READKEY' then
      begin
        repeat
	  getKey(k);
        until (k <> '&') or (FindVar('AMP') <> '');
      	SetVar(Parm(s, 1), k);
      end
      else if cm = 'LEN' then
      	SetVar(Parm(s, 1), Cstr(Length(ParmLine(s, 2))))
      else if cm = 'CHR' then
      	SetVar(Parm(s, 1), Chr(Value(Parm(s, 2))))
      else if cm = 'FORE' then
      begin
          textcolor(value(parm(s,1)));
          lastco:=curco;
          setc(textattr);
      end
      else if cm = 'BACK' then
      begin
          textbackground(value(parm(s,1)));
          lastco:=curco;
          setc(textattr);
      end    
      else if cm = 'CENTER' then
          sprint(centered(ParmLine(s, 1),80))
      else if cm = 'SCENTER' then
          sprompt(centered(ParmLine(s, 1),80))
      else if cm = 'COMPARE' then
          Compare(processmci(Parm(s, 1)), processmci(Parm(s, 2)))
      else if cm = 'IF' then
      begin
      	if IfComp(Parm(s, 1)) then
        	c := Search(Parm(s, 2))
        else if Parm(s, 3) <> '' then
        	c := Search(Parm(s, 3));
      end
      else if cm = 'IFEXIST' then
      begin
          if Exist(processmci(Parm(s, 1))) then
        	c := Search(Parm(s, 2))
        else if Parm(s, 3) <> '' then
        	c := Search(Parm(s, 3));
      end
      else if cm = 'REMOVE' then
      	SetVar(Parm(s, 1), Remove(FindVar(Parm(s, 1)), Char1(Parm(s, 1))))
      else if cm = 'LTRIM' then
      	SetVar(Parm(s, 1), LTrim(FindVar(Parm(s, 1))))
      else if cm = 'FWOPEN' then
      begin
          Assign(foutput, processmci(Parm(s, 1)));
        Rewrite(foutput);
        SetVar('IOERR', Cstr(IOResult));
      end
      else if cm = 'FWAPPEND' then
      begin
          Assign(foutput, processmci(Parm(s, 1)));
          if Exist(processmci(Parm(s, 1))) then
	        Append(foutput)
          else
        	Rewrite(foutput);
        SetVar('IOERR', Cstr(IOResult));
      end
      else if cm = 'FWRITE' then
      begin
        Writeln(foutput, processmci(ParmLine(s, 1)));
        SetVar('IOERR', Cstr(IOResult));
      end
      else if cm = 'FWCLOSE' then
      begin
      	Close(foutput);
        SetVar('IOERR', Cstr(IOResult));
      end
      else if cm = 'FROPEN' then
      begin
          Assign(finput, processmci(Parm(s, 1)));
        Reset(finput);
        SetVar('IOERR', Cstr(IOResult));
        if Parm(s, 2) <> '' then
        	SetVar('FEOF', Parm(s, 2));
      end
      else if cm = 'FILESIZE' then
      begin
        Assign(fsz, processmci(Parm(s, 1)));
        Reset(fsz);
        tmpn:=ioresult;
        if (tmpn<>0) then begin
             SetVar('IOERR', Cstr(tmpn));
        end else begin
             tmpn:=0;
             while not eof(fsz) do begin
               Readln(fsz, tmp);
               inc(tmpn);
             end;
             close(fsz);
             SetVar(parm(s,2),cstr(tmpn));
        end;
      end
      else if cm = 'FREAD' then
      begin
        if not Eof(finput) then
        begin
          Readln(finput, tmp);
          if FindVar('AMP') = '' then
          begin
            while Pos('&', tmp) > 0 do
            	Delete(tmp, Pos('&', tmp), 1);
          end;
	        SetVar(Parm(s, 1), tmp);
        end
        else
        	c := Search(FindVar('FEOF'));
        SetVar('IOERR', Cstr(IOResult));
      end
      else if cm = 'FRCLOSE' then
      begin
      	Close(finput);
        SetVar('IOERR', Cstr(IOResult));
      end
      else if cm = 'CD' then
      begin
      	ChDir(Parm(s, 1));
        SetVar('IOERR', Cstr(IOResult));
      end
      else if cm = 'MD' then
      begin
      	MkDir(Parm(s, 1));
        SetVar('IOERR', Cstr(IOResult));
      end
      else if cm = 'RD' then
      begin
      	RmDir(Parm(s, 1));
        SetVar('IOERR', Cstr(IOResult));
      end
      else if cm = 'IFNUM' then
      begin
      	if GoodNum(Parm(s, 1)) then
        	c := Search(Parm(s, 2))
        else if Parm(s, 3) <> '' then
        	c := Search(Parm(s, 3));
      end
      else if cm = 'INC' then
      begin
      	if GoodNum(FindVar(Parm(s, 1))) then
        begin
          if Parm(s, 2) <> '' then
            tmpn := value(Parm(s, 2))
          else
          	tmpn := 1;
          SetVar(Parm(s, 1), Cstr(value(FindVar(Parm(s, 1)))+tmpn));
        end;
      end
      else if cm = 'DEC' then
      begin
      	if GoodNum(FindVar(Parm(s, 1))) then
        begin
          if Parm(s, 2) <> '' then
            tmpn := value(Parm(s, 2))
          else
          	tmpn := 1;
          SetVar(Parm(s, 1), Cstr(value(FindVar(Parm(s, 1)))-tmpn));
        end;
      end
      else if cm = 'MULT' then
        SetVar(Parm(s, 1), Cstr(value(FindVar(Parm(s, 1)))*value(Parm(s, 2))))
      else if cm = 'DIV' then
      begin
      	tmpn := value(Parm(s, 2));
        if tmpn = 0 then
        	error := 'Division by zero'
        else
        	SetVar(Parm(s, 1), Cstr(value(FindVar(Parm(s, 1))) div tmpn));
      end
      else if cm = 'STRING' then
        SetVar(Parm(s, 1), Mln(Char1(Parm(s, 3)), value(Parm(s, 2))))
      else if cm = 'CMD' then
      	SetVar(Parm(s, 1), Parm(s, 2))
      else if cm = 'ARG' then
      	SetVar(Parm(s, 1), Parm(ParmLine(s, 3), value(Parm(s, 2))))
      else if cm = 'ARGLINE' then
      	SetVar(Parm(s, 1), ParmLine(ParmLine(s, 3), value(Parm(s, 2))))
      else if cm = 'INSTR' then
      begin
      	tmpn := Pos(Parm(s, 1), Parm(s, 2));
        SetVar('INSTR', Cstr(tmpn));
        if tmpn > 0 then
        	SetVar('COMPARE', '=')
        else
        	SetVar('COMPARE', '<');
      end
      else if cm = 'SHOWVAR' then
      	DisplayVars
      else if cm = 'SHOWSTACK' then
      	DisplayStack
      else if cm = 'SHOWTRAP' then
      	DisplayTraps
      else if cm = 'GETDSIZE' then
        SetVar(Parm(s, 1), Cstr(DiskSize(0)))
      else if cm = 'GETDFREE' then
      	SetVar(Parm(s, 1), Cstr(DiskFree(0)))
      else if cm = 'GETVER' then
      	SetVar(Parm(s, 1), Cstr(Lo(DosVersion))+'.'+Cstr(System.Hi(DosVersion)))
      else if cm = 'GETDIR' then
      begin
      	GetDir(0, tmp);
        SetVar(Parm(s, 1), tmp);
      end
      else if cm = 'GETTIME' then
      	SetVar(Parm(s, 1), TimeStr(ParmLine(s, 2)))
      else if cm = 'SETTIME' then
      	SetTime(value(Parm(s, 1)), value(Parm(s, 2)),
				        value(Parm(s, 3)), value(Parm(s, 4)))
      else if cm = 'SETDATE' then
      	SetDate(value(Parm(s, 1)), value(Parm(s, 2)), value(Parm(s, 3)))
      else if cm = 'CUT' then
      	SetVar(Parm(s, 1), Copy(ParmLine(s, 4), value(Parm(s, 2)),
                                value(Parm(s, 3))))
      else if cm = 'CTRLSTR' then
      	SetVar(Parm(s, 1), CtrlStr(FindVar(Parm(s, 1))))
      else if cm = 'DELAY' then
      	delay(value(Parm(s, 1)))
      else if cm = 'SOUND' then
      begin
      	Sound(value(Parm(s, 1)));
        delay(value(Parm(s, 2)));
        NoSound;
      end
      else if cm = 'BEEP' then
      begin
      	for tmpn := 1 to value(Parm(s, 1)) do
          sprompt(^G);
      end
      else if cm = 'GETX' then
      	SetVar(Parm(s, 1), Cstr(WhereX))
      else if cm = 'GETY' then
      	SetVar(Parm(s, 1), Cstr(WhereY))
      else if cm = 'ERROR' then
      	error := ParmLine(s, 1)
      else if cm = 'RANDOMIZE' then
      	Randomize
      else if cm = 'RANDOM' then
      	SetVar(Parm(s, 1), Cstr(Random(value(Parm(s, 2)))))
      else if cm = 'EXPAND' then
      	SetVar(Parm(s, 1), FExpand(FindVar(Parm(s, 1))))
      else if cm = 'SPLIT' then
      begin
      	tmp := FindVar(Parm(s, 1));
        FSplit(tmp, d, n, e);
        SetVar('SPLDIR', d);
        SetVar('SPLNAME', n);
        SetVar('SPLEXT', e);
      end
      else if cm = 'COPYVAR' then
      	SetVar(Parm(s, 2), FindVar(Parm(s, 1)))
      else if cm = 'LJUST' then
      begin
        tmp := FindVar(Parm(s, 1));
      	SetVar(Parm(s, 1), tmp + Mln(' ',value(Parm(s, 2))-Length(tmp)));
      end
      else if cm = 'RJUST' then
      begin
        tmp := FindVar(Parm(s, 1));
      	SetVar(Parm(s, 1), Mln(' ',value(Parm(s, 2))-Length(tmp)) + tmp);
      end
      else if cm = 'CJUST' then
      begin
      	tmp := FindVar(Parm(s, 1));
        tmpn := value(Parm(s, 2))-Length(tmp);
        SetVar(Parm(s, 1), Mln(' ',tmpn div 2)+tmp+mln(' ',tmpn-(tmpn div 2)));
      end
      else if cm = 'GETENV' then
      	SetVar(Parm(s, 1), GetEnv(Parm(s, 2)))
      else if cm = 'CHAIN' then
      begin
{        startup(tmp2);
        run;
        shutdown;}
        if not(ischained) then begin
        doscript(parm(s,1),parm(s,2)+'|C');
        ischained:=FALSE;
        newstatus(fileonly(fn));
        end else begin
        error:='Cannot chain within a chained Nexecutable';
        end;
      end 
{      else if cm = 'LOADMENU' then
        begin curmenu:=systat^.menupath+parm(s,1); shutdown; readin; end}
      else if cm = 'MENUCMD' then begin
          tmp:='';
          s:=allcaps(s);
          domenucommand(done,parm(s,1)+parmline(s,2),tmp);
      end
      else if cm = 'DOOR' then begin
                currentswap:=modemr^.swapdoor;
                dodoorfunc(parm(s,1),FALSE);
                currentswap:=0;
      end
      else if cm = 'SUBSCRIPT' then begin
                getsubscription(value(parm(s,1)));
                sl1('x','Setting Subscription to Level #'+parm(s,1));
      end
    until (cm = 'END') or (error <> '') or (hangup);
    if (error<>'') and (fuckup) then begin
      nl;
      sprint('|12An error has occurred in the current Nexecutable:');
      nl;
      sprint('|12ERROR: '+error);
      sprint('|12LINE : '+Cstr(c));
      sprint('|12PROG : '+filename);
      nl;
      sprint('|12Please notify |SYSOPNAME|.');
     end;
    {$I+}
  end;

begin
  {oldmenu:=curmenu;}
  ischained:=FALSE;
  fn:=allcaps(fn);
  if pos('.',fn)=0 then fn:=fn+'.NPX';
  if pos('\',fn)=0 then fn:=adrv(systat^.nexecutepath)+fn;
  if (copy(startlabel,length(startlabel)-1,2)='|C') then begin
     ischained:=TRUE;
     startlabel:=copy(startlabel,1,length(startlabel)-2);
  end;
  newstatus(fileonly(fn));
  startup(fn);
  run;
  shutdown;
  topscr;
end; {run script}

end.

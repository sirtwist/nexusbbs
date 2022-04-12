{$A+,B+,D-,E+,F+,I+,L+,N-,O+,R+,S+,V-}
unit mail1;

interface

uses
  crt, dos, common,  fidonet,
  mkglobt, mkmsgabs, mkdos, mkstring, v7engine;

function inmsg(pub,uti:boolean; ftit:string; ReplyString:string):boolean;
procedure inli(var i:string);

implementation

uses keyunit,mail0,myio3,doors,execbat,archive1,mail4;

var
  inmsgfile:text;
  cmdsoff:boolean;
  lastline:string;

function bslash(b:boolean; s:astr):astr;
begin
  if (b) then begin
    while (copy(s,length(s)-1,2)='\\') do s:=copy(s,1,length(s)-2);
    if (copy(s,length(s),1)<>'\') then s:=s+'\';
  end else
    while (copy(s,length(s),1)='\') do s:=copy(s,1,length(s)-1);
  bslash:=s;
end;

procedure tscaninput(ctl:integer; s3:string; var s:string; allowed:string; lfeed:boolean);
  var os:string;
      x,i:integer;
      c:char;
      clear,show,gotcmd:boolean;
  begin
    gotcmd:=FALSE; s:='';
    clear:=true;
    show:=false;
    sprompt('%150%'+s3);
    repeat
      getkey(c); c:=upcase(c);
      os:=s;
      if ((pos(c,allowed)<>0) and (s='')) then begin 
      gotcmd:=TRUE; s:=c;
      if (clear) then begin
      for x:=1 to length(s3) do sprompt(^H' '^H);
      clear:=false;
      end;
      case c of
              'L':if (ctl=1) then sprint('%150%List Taglines') else begin
                sprint('%150%Continue'); end;
              'M':sprint('%150%Manual Entry');
              'R':sprint('%150%Random Tagline');
              'N':sprint('%150%No Tagline');
              '?':sprint('%150%Help');
      end;
      end else
      if (pos(c,'0123456789')<>0) then begin
        if (ctl<>-1) then begin
	if ((s='') and (clear)) then begin
		for x:=1 to length(s3) do sprompt(^H' '^H);
		clear:=false;
	end;
	if (length(s)<5) then begin s:=s+c;
	show:=true;
	end else show:=false;
        end;
      end
      else
      if ((s<>'') and (c=^H)) then begin
		s:=copy(s,1,length(s)-1);
		sprompt(^H' '^H);
		if (s='') then begin
                        sprompt('%150%'+s3);
			clear:=true;
		end;
		show:=false;
      end
      else
      if (c=^X) then begin
	for i:=1 to length(s) do prompt(^H' '^H);
	s:=''; os:='';
      end
      else
      if (c=#13) then begin
	gotcmd:=TRUE;
	show:=false;
	if (clear) then begin
	for x:=1 to length(s3) do sprompt(^H' '^H);
	clear:=false;
	end;
	if (s='') then 
        if (ctl=1) then sprint('%150%List Taglines') else begin
                sprint('%150%Continue'); end;
      end;

      if (show) then sprompt('%150%'+copy(s,length(s),1));
    until ((gotcmd) or (hangup));
    if (lfeed) then nl;
  end;

procedure listtags(x:integer);
var tagf:file of tagrec;
    tag:tagrec;
    y,b:integer;
    c:char;
    done,done2:boolean;
    
begin
done:=false;
assign(tagf,adrv(systat^.gfilepath)+'TAGLINES.DAT');
{$I-} reset(tagf); {$I+}
if ioresult<>0 then begin
        sprint('No taglines currently available.');
	rewrite(tagf);
        tag.tag:='';
        write(tagf,tag);
	done:=true;
	end;
if (filesize(tagf)=1) then begin
        sprint('No taglines currently available.');
	done:=true;
	end;
if not(done) then begin        
	cls;
	done2:=false;
	for y:=x to (x+thisuser.pagelen-5) do begin
	if eof(tagf) then done2:=true;
	if not(done2) then begin
	seek(tagf,y);
        read(tagf,tag);
        sprint('%150%'+mrn(cstr(y),5)+': %140%'+mln(tag.tag,72));
	end else y:=x+thisuser.pagelen-5;
	end;
	nl;
	if (x>(filesize(tagf)-1)) then done:=true;
end;
close(tagf);
end;

procedure choosetagline(var s:string);
var tagf:file of tagrec;
    tag:tagrec;
    tm:real;
    tm2:longint;
    dt:datetimerec;
    s2,s3:string;
    x,ctl:integer;
    i:longint;
    none,done,dprmpt:boolean;

begin
done:=false;
dprmpt:=true;
ctl:=1;
assign(tagf,adrv(systat^.gfilepath)+'TAGLINES.DAT');
repeat
s:='';
s2:='';
if (dprmpt) then begin
{$I-} reset(tagf); {$I+}
if ioresult=0 then begin
sprompt('%030%Choose tagline (%150%1%030%-%150%'+cstr(filesize(tagf)-1)+'%030%, %150%?%030%=Help) : %150%');
none:=false;
close(tagf);
end else begin
sprompt('%030%Add tagline (%150%None available%030%, %150%?%030%=Help) : %150%');
none:=true;
end;
end;
dprmpt:=true;
if (none) then begin
s3:='Manual Entry';
ctl:=-1;
end else
if (ctl>1) then s3:='Continue' else s3:='List Taglines';
if (none) then
tscaninput(ctl,s3,s2,'NM?',false)
else
tscaninput(ctl,s3,s2,'LRNM?',false);
i:=value(s2);
if (i<>0) then 
   begin
	if not(none) then 
	    begin
		nl;
		{$I-} reset(tagf); {$I+}
                if ioresult<>0 then sprint('%120%Tagline not found.') 
		else 
		 begin
		  if not(i>(filesize(tagf)-1)) then 
		    begin
			seek(tagf,i);
			read(tagf,tag);
			s:=tag.tag;
			done:=true;
		    end;
		 end;
		close(tagf);
	    end else 
	      begin 
	       for x:=1 to length(s2) do sprompt(^H' '^H); 
	       dprmpt:=false; 
	      end;
   end else
begin
if (none) then begin
if (s2='') then s2:='M';
end else if (s2='') then s2:='L';
case s2[1] of
	'?':begin
                if (none) then begin
		nl;
                sprint('%080%(%150%M%080%) %030%Manually enter a tagline');
                sprint('%080%(%150%N%080%) %030%No tagline');
		nl;
                end else begin
		nl;
                sprint('%080%(%150%#%080%) %030%Enter tagline number to use');
                sprint('%080%(%150%L%080%) %030%List existing taglines');
                sprint('%080%(%150%R%080%) %030%Randomly choose a tagline');
                sprint('%080%(%150%M%080%) %030%Manually enter a tagline');
                sprint('%080%(%150%N%080%) %030%No tagline');
		nl;
                end;
	    end;
	'L':begin
		Listtags(ctl);
		ctl:=ctl+thisuser.pagelen-5;
		{$I-} reset(tagf); {$I+}
		if ioresult=0 then 
			begin 
				if (ctl>(filesize(tagf))) then ctl:=1; 
				close(tagf);
			end else ctl:=1;
		end;
	'R':begin
		common.getdatetime(dt);
		tm:=dt2r(dt);
		tm2:=trunc(tm);
		randseed:=tm2;
		randomize;
		{$I-} reset(tagf); {$I+}
		if ioresult=0 then begin 
		i:=succ(random(filesize(tagf)-1));
		if not(i>(filesize(tagf)-1)) then begin
			seek(tagf,i);
			read(tagf,tag);
			s:=tag.tag;
		     end;
		close(tagf);
		nl;
                sprint('%150%'+mrn(cstr(i),5)+'  %140%'+s);
		dyny:=true;
		nl;
                if pynq('%120%Use this tagline? %110%') then begin
			done:=true;
			end;
		nl;
		end else begin
                        sprint('%120%No taglines to use.');
		end;
	    end;
	'N':begin
		s:='';
		done:=true;
	    end;
	'M':begin
                nl;
                sprint('%030%Please enter a tagline:');
                sprompt(gstring(19));
		inputl(s2,75);
		if (s2<>'') then begin 
		s:=s2; done:=true; 
		dyny:=true;
                nl;
                if pynq('%120%Add this tagline to tagline file? %110%') then begin
			{$I-} reset(tagf); {$I+}
			if ioresult<>0 then begin
				rewrite(tagf);
				tag.tag:='';
				write(tagf,tag);
			end;
			tag.tag:=copy(s,1,75);
			seek(tagf,filesize(tagf));
			write(tagf,tag);
			close(tagf);
		   end;
		end;
                nl;
	end;
	else begin dprmpt:=false; end;
	end;
end;
until (done);
end;

function substone(src,old,anew:string):string;
var p:integer;
begin
  if (old<>'') then begin
    p:=pos(old,src);
    if (p>0) then begin
      insert(anew,src,p+length(old));
      delete(src,p,length(old));
    end;
  end;
  substone:=src;
end;

function inmsg(pub,uti:boolean; ftit:string; replystring:string):boolean;
type liptr=array[1..160] of string[80];
type s80=string[80];
var li:^liptr;
    mftit,ffrom,fto:^s80;
    s1,s2:string;
    s:astr;
    intertemp:integer;
    intertype:byte;
    intertoname:string[36];
    outaddress,t,maxli,lc,topp,i,quoteli:integer;
    fidorf:file of fidorec;
    fidor:fidorec;                { FidoNet information                   }
    c:char;
    add,add2:addrtype;
    externaleditor, gettag,
    created,cantabort,saveline,goquote,exited,save,abortit,abort,next:boolean;

function showflags:string;
var s2:string;
begin
with CurrentMSG^ do begin
s2:='Local ';
if (IsPriv) then s2:=s2+'Priv ';
if (IsCrash) then s2:=s2+'Crash ';
if (IsKillSent) then s2:=s2+'Kill ';
if (IsHold) then s2:=s2+'Hold ';
if (IsFileReq) then s2:=s2+'FileReq ';
if (IsReqRct) then s2:=s2+'RetRecReq ';
if (IsDirect) then s2:=s2+'Direct';
end;
showflags:=s2;
end;
  
  procedure printmsgtitle(s:string);
  var gs1,gs2:string;
  begin
    cls;
    sprompt('%080%To : %150%'+mln(fto^,25));
    sprint('%080% Subject: %150%'+mln(mftit^,36));
    gs1:=gstring(26);
    gs2:=gstring(27);
    if (gs1<>'') then sprint(gs1);
    if (gs2<>'') then sprint(gs2);
    sprint(s);
    setc(3 or (0 shl 4));
    if thisuser.mruler=1 then 
    print(copy('ÚÄÄÄÂÄÄÄÄÂÄÄÄÄÂÄÄÄÄÂÄÄÄÄÂÄÄÄÄÂÄÄÄÄÂÄÄÄÄÅÄÄÄÄÂÄÄÄÄÂÄÄÄÄÂÄÄÄÄÂÄÄÄÄÂÄÄÄÄÂÄÄÄÄÂÄÄÄ¿',
      1,80))
    else
    print('ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ');
    setc(7 or (0 shl 4));
  end;
  
  procedure listit(stline:integer; linenum,disptotal:boolean);
  var lasts:string;
      cur,l:integer;
  begin
    if (disptotal) then begin
      printmsgtitle('%150%Current Line: '+cstr(lc));
    end;
    l:=stline;
    abort:=FALSE;
    next:=FALSE;
    lasts:='';
    cur:=1;
    while ((l<lc) and (not abort)) do begin
      if (linenum) then sprompt('%140%'+cstr(l)+' ');
      
      read_with_mci:=FALSE;
      mpausescr:=TRUE;
      setc(7 or (0 shl 4));
      print(copy(li^[l],1,length(li^[l])-1));
      mpausescr:=FALSE;
      if (mabort) then abort:=TRUE;

      if (cur>=79) then begin
        cls;
        printmsgtitle('');
        cur:=0;
      end;
      lasts:=li^[l];
      inc(l);
      inc(cur);
    end;

    saveline:=FALSE;
  end;

  procedure rpl(var v:astr; old,anew:astr);
  var p:integer;
  begin
    p:=pos(old,v);
    if (p>0) then begin
      insert(anew,v,p+length(old));
      delete(v,p,length(old));
    end;
  end;

  procedure rpl1;
  var done,skip:boolean;
  begin
    done:=false;
    skip:=false;
    if (lc<=1) then sprint('%120%'+'Nothing to replace.') else begin
      repeat
      skip:=FALSE;
      sprompt('%030%Replace string on which line [%150%1%030%-%150%'+cstr(lc-1)+'%030%,%150%L=%030%List] : %150%');
      scaninput(s,'L'^M,TRUE);
      if allcaps(s)='L' then begin
		printmsgtitle('Replace String:');
		listit(1,TRUE,TRUE);
		skip:=true;
      end;
      if not(skip) then begin
      if (value(s)<1) or (value(s)>lc-1) then
        sprint('%120%'+'Invalid Line Number.')
      else begin
	nl;
        sprint('%030%Original line:');
	abort:=FALSE;
	next:=FALSE;
	sprint(li^[value(s)]);
	nl;
        sprompt('%030%Enter string to replace: ');
	inputl(s1,78);
	if (s1<>'') then
	  if (pos(s1,li^[value(s)])=0) then begin
            sprint('%120%'+'String not found.');
	    done:=true;
	    end
	  else begin
            sprompt('%030%Enter replacement string: ');
	    inputl(s2,78);
	    if (s2<>'') then begin
	      rpl(li^[value(s)],s1,s2);
	      nl;
              sprint('%030%'+'Edited Line:');
	      abort:=FALSE;
	      next:=FALSE;
	      sprint(li^[value(s)]);
	      done:=true;
	    end;
	  end;
      end;
      nl;
    end;
    until (done);
    end;
  end;

  procedure doquote;
  var f:text;
      t1,x:integer;
      c:char;
      s:string[79];
      ss:string;
      noquote,qdone,lastwrap,fok,sok,bdone,done:boolean;
      s1,s2:string;
      qstart,b1,b2:byte;

    procedure openquotefile;
    begin
      done:=FALSE;
      assign(f,newtemp+'msgtmp');
      {$I-} reset(f); {$I+}
      if (ioresult<>0) then done:=TRUE;
    end;

    procedure readquoteline;
    var c:char;
        d1:boolean;
    begin
      d1:=FALSE;
      lastwrap:=FALSE;
      s:='';
      if eof(f) then done:=TRUE else begin
          while (not eof(f)) and not(d1) do begin
            read(f,c);
            case c of
                #141:begin
                        d1:=TRUE;
                        lastwrap:=TRUE;
                     end;
                #13:begin
                        d1:=TRUE;
                        lastwrap:=FALSE;
                    end;
                #10:begin end;
                    else begin
                        s:=s+c;
                    end;
             end;
          end;
        end;
    end;

    procedure gotoquoteline(b:boolean);
    begin
      if (b) then begin
	close(f);
	openquotefile;
      end;
      if (not done) then begin
	t1:=0;
	repeat
	  inc(t1);
	  readquoteline;
	until ((t1=quoteli) or (done));
      end;
      if (done) then quoteli:=1;
    end;



  begin
    noquote:=true;
    openquotefile;
    quoteli:=0;
    qdone:=false;
    bdone:=false;
    qstart:=lc;
    if (not done) then begin
      done:=FALSE;
      if (not done) then repeat
        setc(memboard.quote_color);
	x:=0;
	bdone:=false;
	badini:=false;
	if (quoteli<>0) then gotoquoteline(true);
	cls;
	repeat
		begin
		inc(x);
		inc(quoteli);
		readquoteline;
                if not (done) then sprint(cstr(quoteli)+': '+copy(s,1,78-length(cstr(quoteli))));
		end;
	until ((done) or (x=15));
	nl;
	repeat
	fok:=false;
        sprompt('%030%Quote Start Line [%150%?%030%=Help] : %150%');
	input(s1,5);
	badini:=FALSE;
	b1:=value(s1);
	if (s1='') then begin badini:=TRUE; fok:=true; end;
	if (badini) then bdone:=true else fok:=true;
		case upcase(s1[1]) of
			'?':begin
				nl;
                                sprint('%080%[%150%###%080%]   %030%Line number to start quoting');
                                sprint('%080%[%150%Enter%080%] %030%Continue displaying quote lines');
                                sprint('%080%[%150%Q%080%]     %030%Quit quoting');
				nl;
				fok:=false;
				badini:=false;
			    end;
			'Q':begin
				fok:=true;
				qdone:=true;
				s1:='';
				b1:=0;
				b2:=0;
				bdone:=true;
				badini:=true;
			    end;
			end;
		
	until (fok);
	repeat
	sok:=false;
	if (not badini) then begin
        sprompt('%030%Quote End Line   [%150%?%030%=Help] : %150%');
	badini:=FALSE;
	input(s2,5); b2:=value(s2);
	if (s2='') then begin b2:=b1; sok:=true; end;
        sprompt('%070%');
	sok:=true;
	case upcase(s2[1]) of
	  '?':begin
		nl;
		sok:=false;
                sprint('%080%[%150%###%080%]   %030%Last line number to quote');
                sprint('%080%[%150%Enter%080%] %030%Continue displaying quote lines');
                sprint('%080%[%150%Q%080%]     %030%Quit quoting');
		nl;
	      end;
	  'Q':begin done:=true; sok:=true; end;
	  end;
	end else sok:=true;
	until (sok);

	if (not bdone) then begin
		 quoteli:=b1;
		 gotoquoteline(TRUE);
		 for x:=(b1) to (b2) do begin
			if (lc>maxli) then done:=TRUE else begin
				noquote:=false;
                                if (lastwrap) then
                                li^[lc]:=s+#141
                                else
                                li^[lc]:=s+#13;
				inc(lc);
				readquoteline;
				if (done) then dec(quoteli);
			end;
			quoteli:=b2;
			end;
		 end else begin
		 done:=false;
		 inc(quoteli);
		 readquoteline;
	      end;
	      if (qdone) then done:=true;
	until (done);
    end;
    {$I-} close(f); {$I+}
    if (noquote) then begin
		for x:=(lc-1) downto qstart do begin
			li^[x]:='';
			dec(lc);
		end;
	end;
  end;

  function getuudest(var uzone,unet,unode,upoint:word; var ufrom:integer; var utype:byte; var uto:string):boolean;
  var uuf:file of internetrec;
      uu:^internetrec;
  begin
        new(uu);
        assign(uuf,adrv(systat^.gfilepath)+'INTERNET.DAT');
        {$I-} reset(uuf); {$I+}
        if (ioresult<>0) then begin
                sl1('!','Error reading INTERNET.DAT!');
                sl1('!','Message aborted.');
                sprint('%120%Error reading Gateway information.');
                getuudest:=FALSE;
                save:=FALSE;
                exit;
        end else begin
                read(uuf,uu^);
                close(uuf);
                utype:=uu^.gateways[memboard.gateway].gatewaytype;
                ufrom:=uu^.gateways[memboard.gateway].fromaddress;
                uto:=uu^.gateways[memboard.gateway].toname;
                if (interaddr='') then begin
                        uzone:=uu^.gateways[memboard.gateway].toaddress.zone;
                        unet:=uu^.gateways[memboard.gateway].toaddress.net;
                        unode:=uu^.gateways[memboard.gateway].toaddress.node;
                        upoint:=uu^.gateways[memboard.gateway].toaddress.point;
                end else begin
                        conv_netnode(interaddr,add.zone,add.net,add.node,add.point);
                end;
                getuudest:=TRUE;
        end;
  end;


function getmsgheader:boolean;
var s:^string;
    x:integer;
    found:boolean;
begin
new(s);
sprompt(gstring(37));
sprint(memboard.name);
sprompt(gstring(38));
sprompt(ffrom^+'|LF|');
if (Public in Memboard.MBpriv) then pub:=FALSE else pub:=TRUE;
if (PubPriv in Memboard.MBpriv) then begin
nl;
if (pynq('Send a private message? ')) then pub:=TRUE else pub:=FALSE;
nl;
end;
sprompt(gstring(40));
if not(pub) then
if (fto^<>'') and (allcaps(fto^)<>'ALL') then defaultst:=fto^ else defaultst:='All'
else
if (fto^<>'') and (allcaps(fto^)<>'ALL') then defaultst:=fto^ else defaultst:='';
if (memboard.mbtype=3) then
        inputdl(s^,50)
else begin
        inputdlnp(s^,50);
        if (((memboard.mbtype=0) and (pub)) and (s^<>'')) then begin
                s^:=findusername(s^);
        end;
        if not((memboard.mbtype=0) and (pub)) then nl;
end;
if (s^='') then begin
        getmsgheader:=FALSE;
        exit;
end;
fto^:=s^;
if (memboard.mbtype=2) then begin
                        sprompt(gstring(42));
                        defaultst:='';
                        if (repaddress<>'') then defaultst:=repaddress;
                        inputdln(s^,20);
                        conv_netnode(s^,add.zone,add.net,add.node,add.point);
                        if (add.zone=0) then begin
                                getmsgheader:=FALSE;
				exit;
			end;
			x:=1;
                        found:=FALSE;
                        nl;
			repeat
			if (memboard.address[x]) then begin
                                if (fidor.address[x].zone=add.zone) then begin
					found:=TRUE;
				end else inc(x);
			end else inc(x);
			until (found) or (x=31);
                        if not(found) then begin
                                sprint('%120%Unavailable address.');
                                nl;
                                getmsgheader:=FALSE;
                        end;
                        add2.zone:=fidor.address[x].zone;
                        add2.net:=fidor.address[x].net;
                        add2.node:=fidor.address[x].node;
                        add2.point:=fidor.address[x].point;
end;
sprompt(gstring(41));
if copy(mftit^,1,1)='\' then sprint(copy(mftit^,2,length(mftit^)-1));
if copy(mftit^,1,1)='/' then sprint(copy(mftit^,2,length(mftit^)-1));
if (copy(mftit^,1,1)<>'\') and (copy(mftit^,1,1)<>'/') then begin
  defaultst:=mftit^;
  inputdl(s^,72);
  if (s^='') then begin
        getmsgheader:=FALSE;
        exit;
  end;
  mftit^:=s^;
end;
getmsgheader:=TRUE;
dispose(s);
end;

  procedure inputthemessage;
  var t2:integer;
      lnm:boolean;
      ok,found:boolean;
      c2:char;
      ret:integer;
      x,x2:integer;
      ttf:text;


  begin
    cmdsoff:=FALSE;
    found:=FALSE;
    abort:=FALSE;
    next:=FALSE;
    goquote:=FALSE;
    quoteli:=1;
    if (private in memboard.mbpriv) then begin 
	pub:=false;
    end;
    if (freek(exdrv(adrv(memboard.msgpath)))>=systat^.minspaceforpost) then begin
        lc:=1;
        lastline:='';
        if (cso) then maxli:=systat^.csmaxlines else maxli:=systat^.maxlines;
    end else begin
        mftit^:='';
        sprompt('|LF|%120%Insufficient space to record message.|LF|');
        c:=chr(exdrv(adrv(memboard.msgpath))+64);
        if (c='@') then sl1('!','Insufficient space for message on Main Drive.')
        else sl1('!','Insufficient space for message on Drive '+c+'.');
        if (cantabort) then begin
        sl1('!','Unable to save required message.');
        end;
        exit;
    end;
    repeat
    save:=getmsgheader;
    until (save) or (not(save) and not(cantabort));
    if not(save) then exit;
    pub:=not(pub);
    if (pub) then CurrentMSG^.SetPRIV(FALSE) else CurrentMSG^.SetPRIV(TRUE);
    if (memboard.mbtype=1) then begin
			x:=1;
			x2:=0;
			repeat
				if (memboard.address[x]) then x2:=x;
				inc(x);
			until ((x2>0) or (x=31));
			if (x2=0) then x2:=1;
                        add2.zone:=fidor.address[x2].zone;
                        add2.net:=fidor.address[x2].net;
                        add2.node:=fidor.address[x2].node;
                        add2.point:=fidor.address[x2].point;
                        CurrentMSG^.SetOrig(add2);
     end;
     if ((memboard.mbtype=2)) then begin
                        CurrentMSG^.SetOrig(add2);
                        CurrentMSG^.SetDest(add);
			outaddress:=x;
                        currentmsg^.setpriv(fidor.isprivate);
                        currentmsg^.setcrash(fidor.iscrash);
                        currentmsg^.setkillsent(fidor.iskillsent);
                        currentmsg^.setfilereq(fidor.isfilereq);
                        currentmsg^.sethold(fidor.ishold);
                        currentmsg^.setreqrct(fidor.isreqrct);
                        if (aacs(systat^.setnetmailflags)) then begin
				repeat
				nl;
                                sprint('%030%Netmail Flags: %150%'+showflags);
                                sprompt('%030%Change [%150%PCKHIFD%030%, %150%? %030%Help] : %150%');
                                onek(c,'PCKHRFAD?'^M);
				case c of
					'?':begin
						nl;
                                                sprint('%150%P%030%=Private                 %150%C%030%=Crash');
                                                sprint('%150%K%030%=Kill/Sent               %150%H%030%=Hold');
                                                sprint('%150%R%030%=Return Receipt Request  %150%F%030%=FileReq');
                                                sprint('%150%D%030%=Direct');
                                                sprint('%150%ENTER%030%=Done');
					    end;
					'P':begin
						if (CurrentMSG^.Ispriv) then CurrentMSG^.SetPriv(FALSE) else
							CUrrentMSG^.SetPriv(TRUE);
					end;
					'C':begin
						if (CurrentMSG^.IScrash) then CurrentMSG^.SetCrash(FALSE) else
							CurrentMSG^.SetCRASH(TRUE);
					end;
					'K':begin
                                                if (Currentmsg^.ISkillsent) then currentmsg^.SetKillsent(FALSE) else
                                                        CurrentMSG^.SetKillSent(TRUE);
					end;
					'H':begin
						if (CurrentMSG^.IsHold) then CurrentMSG^.SetHold(FALSE) else
							CurrentMSG^.SetHOLD(TRUE);
					end;
					'F':begin
                                                if (CurrentMSG^.IsFileReq) then CurrentMSG^.SetFileReq(FALSE) else
                                                        CurrentMSG^.SetFileReq(TRUE);
					end;
                                        'R':begin
                                                if (CurrentMSG^.IsReqRct) then CurrentMSG^.SetReqRct(FALSE) else
                                                        CurrentMSG^.SetReqRct(TRUE);
					end;
                                        'D':begin
                                                if (CurrentMSG^.IsDirect) then CurrentMSG^.SetDirect(FALSE) else
                                                        CurrentMSG^.SetDirect(TRUE);
					end;

			end;
                        until (c=^M) or (hangup);
                        end;
     end;
     if (memboard.mbtype=3) then begin
           if (getuudest(add.zone,add.net,add.node,add.point,intertemp,intertype,intertoname)) then begin
                        add2.zone:=fidor.address[intertemp].zone;
                        add2.net:=fidor.address[intertemp].net;
                        add2.node:=fidor.address[intertemp].node;
                        add2.point:=fidor.address[intertemp].point;
                        CurrentMSG^.SetOrig(add2);
                        CurrentMSG^.SetDest(add);
           end else begin
                exit;
           end;
     end;
     gettag:=TRUE;
     if (externaleditor) and not(copymessage) and not(hangup) then begin
                        if (thisuser.msgeditor=-1) then begin
                                gettag:=FALSE;
                                currentswap:=modemr^.swapeditor;
                                doors.timeremaining:=nsl/60;
                                write_door_sys(newtemp,TRUE);
                                assign(ttf,newtemp+'MSGINF');
                                rewrite(ttf);
                                if (mbrealname in memboard.mbstat) then 
                                writeln(ttf,thisuser.realname) else
                                writeln(ttf,thisuser.name);
                                if (memboard.mbtype=3) then
                                writeln(ttf,fto^) else
                                writeln(ttf,fto^);
                                writeln(ttf,mftit^);
                                writeln(ttf,cstr(himsg+1));
                                writeln(ttf,stripcolor(memboard.name));
                                writeln(ttf,allcaps(syn(pub)));
                                close(ttf);
                                chdir(bslash(FALSE,adrv(systat^.utilpath)));
                                ret:=0;
                                if (cantabort) then begin
                                shelldos(FALSE,adrv(systat^.utilpath)+'NXEDIT.EXE -N'+cstr(cnode)+' -A -D'+newtemp,ret);
                                end else begin
                                shelldos(FALSE,adrv(systat^.utilpath)+'NXEDIT.EXE -N'+cstr(cnode)+' -D'+newtemp,ret);
                                end;
                                common.getdatetime(tim);
                                currentswap:=0;
                                if ((useron) and (outcom)) then com_flush_rx;
                                {$I-} chdir(start_dir); {$I+}
                                if (ioresult<>0) then begin end;
                                if (useron) then begin
                                        topscr;
                                        sdc;
                                end;
                       end else begin
                        gettag:=gettags;
                        currentswap:=modemr^.swapeditor;
                        assign(ttf,newtemp+'MSGINF');
                        rewrite(ttf);
                        if (mbrealname in memboard.mbstat) then 
                               writeln(ttf,thisuser.realname) else
                               writeln(ttf,thisuser.name);
                        writeln(ttf,fto^);
                        writeln(ttf,mftit^);
                        writeln(ttf,cstr(himsg+1));
                        writeln(ttf,stripcolor(memboard.name));
                        writeln(ttf,allcaps(syn(pub)));
                        close(ttf);
                        dodoorfunc(cstr(thisuser.msgeditor),TRUE);
                        currentswap:=0;
			save:=true;
                        end;
     end;
     if (copymessage) then save:=TRUE;
     if ((not(editorok) and (externaleditor)) and not(copymessage) or
        not(externaleditor)) then begin
     externaleditor:=FALSE;
     copymessage:=FALSE;
     editorok:=FALSE;
     save:=false;
     new(li);
     if (li=NIL) then begin
	save:=FALSE;
        sl1('!','Error initializing Message memory');
        sprint('%120%Memory Error!');
	exit;
     end;
     created:=TRUE;
     printmsgtitle('');
     repeat
       repeat
	saveline:=TRUE;
	nofeed:=FALSE;
	exited:=FALSE;
	save:=FALSE;
	abortit:=FALSE;
	write_msg:=TRUE;
        inli(s);
	write_msg:=FALSE;
	if (s=#27^H) then begin
	  saveline:=FALSE;
	  if (lc<>1) then begin
	    dec(lc);
	    lastline:=li^[lc];
	    if (copy(lastline,length(lastline),1)=#1) then
	      lastline:=copy(lastline,1,length(lastline)-1);
            if (copy(lastline,length(lastline),1)=#13) then
	      lastline:=copy(lastline,1,length(lastline)-1);
            if (copy(lastline,length(lastline),1)=#141) then
	      lastline:=copy(lastline,1,length(lastline)-1);
            printmsgtitle('%150%'+'Current Line: '+cstr(lc));
            if (lc<topp+4) and (lc>14) then begin
                        listit(lc-14,FALSE,FALSE);
                        topp:=lc-14;
            end else begin
                        if (lc<=14) then begin
                                topp:=1;
                        end;
                        listit(topp,False,FALSE);
            end;
            end;
	end;
	if (s=#27) then begin
          repeat
          sprompt(gstring(43));
	  getkey(c);
          for t2:=1 to length(gstring(43))+1 do
	    prompt(^H' '^H);
	  saveline:=false;
	  case upcase(c) of
	     '*':begin
                  if ((not hangup) and (mso)) then begin
                    sprompt('%030%File to import: %150%');
		    mpl(40);
		    inputl(s,40);
		    if ((s<>'') and (not hangup)) then begin
		      assign(inmsgfile,s);
		      {$I-} reset(inmsgfile); {$I+}
		      if (ioresult<>0) then
                        sprint('%120%File not found.')
		      else begin
			inmsgfileopen:=TRUE;
			cmdsoff:=TRUE;
		      end;
		    end;
		  end;
		end;
	    '?','H':begin
                 nl;
                 sprint('%080%[%150%Enter%080%] %030%Continue editing message');
                 nl;
                 sprint('%080%[%150%S%080%] %030%Save message');
                 sprint('%080%[%150%A%080%] %030%Abort message');
                 sprint('%080%[%150%C%080%] %030%Clear message');
                 nl;
                 if (exist(newtemp+'msgtmp')) then begin
                 sprint('%080%[%150%Q%080%] %030%Add quoted text to message');
                 end;
                 if (spd='KB') and (mso) then
                 sprint('%080%[%150%*%080%] %030%Import a File into message');
                 sprint('%080%[%150%L%080%] %030%List message');
                 nl;
                 sprint('%080%[%150%D%080%] %030%Delete a line of message');
                 sprint('%080%[%150%P%080%] %030%Replace a string');
                 sprint('%080%[%150%Z%080%] %030%Delete last line');
                 sprint('%080%[%150%I%080%] %030%Insert a line of message');
                 sprint('%080%[%150%R%080%] %030%Replace a line of message');
                 nl;
                 end;
            ^M:begin
               end;
	    'A':if (not cantabort) then
		  begin
		  dyny:=False;
                  if pynq('|LF|%120%Abort message? %110%') then begin
		    exited:=TRUE;
		    abortit:=TRUE;
		  end else begin
                    printmsgtitle('%150%'+'Continue:');
		    if (lc>1) then
			if (lc>10) then listit(lc-10,FALSE,FALSE)
			else listit(1,FALSE,FALSE);
		    end;
		    end;
	    'C':begin
		dyny:=false;
                if pynq('|LF|%120%Clear message? %110%') then begin
		  lc:=1;
                  printmsgtitle('%150%'+'Message Cleared.  Continue:');
		end else begin
                  printmsgtitle('%150%'+'Continue:');
		  if (lc>1) then
			if (lc>10) then listit(lc-10,FALSE,FALSE)
			else listit(1,FALSE,FALSE);
		  end;
		end;
	    'D':begin
                  sprompt('%030%Delete which line [%150%1%030%-%150%'+cstr(lc-1)+'%030%] : %150%');
		  input(s,4);
		  t:=value(s);
		  if (t>0) and (t<lc) then begin
                    for t2:=t to lc-2 do
                      li^[t2]:=li^[t2+1];
		    dec(lc);
		  end;
                  printmsgtitle('%150%'+'Deleted line '+cstr(t)+'. Continue:');
		  if (lc>1) then
			if (lc>10) then listit(lc-10,FALSE,FALSE)
			else listit(1,FALSE,FALSE);
		
		end;
	    
	    'I':begin
		if (lc<maxli) then begin
                  sprompt('%030%Insert before which line [%150%1%030%-%150%'+cstr(lc-1)+'%030%] : %150%');
		  input(s,4);
		  t:=value(s);
		  if (t>0) and (t<lc) then begin
                    for t2:=lc downto t+1 do li^[t2]:=li^[t2-1];
		    inc(lc);
                    printmsgtitle('%150%'+'Inserted before line '+cstr(t)+'. Continue:');
		    if (lc>1) then
			if (lc>10) then listit(lc-10,FALSE,FALSE)
			else listit(1,FALSE,FALSE);
		  end;
		end else begin
                  printmsgtitle('%150%'+'Maximum line count reached.');
		  if (lc>1) then
			if (lc>10) then listit(lc-10,FALSE,FALSE)
			else listit(1,FALSE,FALSE);
	     end;                  
	      
	      end;
	    'L':begin
		dyny:=true;
                lnm:=pynq('|LF|%120%List message with line numbers? %110%');
		printmsgtitle('');
                listit(1,lnm,TRUE);
		end;
	    'P':begin rpl1; end;
	    'Q':begin 
		if (not exist(newtemp+'msgtmp')) then begin
                  printmsgtitle('%150%'+'Not Replying To A Message.');
		  if (lc>1) then
			if (lc>10) then listit(lc-10,FALSE,FALSE)
			else listit(1,FALSE,FALSE);
		end else
		  goquote:=TRUE;
	       end;
	    'Z':begin
		if (lc>1) then begin
		  dec(lc);
                  printmsgtitle('%150%'+'Last Line Deleted.  Continue:');
		  if (lc>1) then
			if (lc>10) then listit(lc-10,FALSE,FALSE)
			else listit(1,FALSE,FALSE);
		end;
		end;
	    'R':begin
                  sprompt('%030%Line number to replace [%150%1%030%-%150%'+cstr(lc-1)+'%030%] : %150%');
		  input(s,4);
		  t:=value(s);
		  if ((t>0) and (t<lc)) then begin
		    abort:=FALSE;
		    nl;
                    sprint('%030%Old line:%070%');
		    sprint(li^[t]);
                    sprint('%030%Enter new line:%070%');
		    inli(s);
		    if (li^[t][length(li^[t])]=#1) and
		       (s[length(s)]<>#1) then li^[t]:=s+#1 else li^[t]:=s;
                  printmsgtitle('%150%'+'Line Number '+cstr(t)+' Deleted.  Continue:');
		  if (lc>1) then
			if (lc>10) then listit(lc-10,FALSE,FALSE)
			else listit(1,FALSE,FALSE);
		  
		  end;
		end;
	    
	    'S':begin 
		if ((not cantabort) or (lc>1)) then begin
		  exited:=TRUE;
		  save:=TRUE;
		end;
		end;
	    end;
            until (c<>'?');
            if (c in [^M,'*']) then begin
		    printmsgtitle('');
		    if (lc>1) then
			if (lc>10) then listit(lc-10,FALSE,FALSE)
			else listit(1,FALSE,FALSE);
            end;
	end;
	

	if (goquote) then begin
	  doquote;
	  goquote:=FALSE;
	  printmsgtitle('');
	  if (lc>1) then
	    if (lc>10) then listit(lc-10,FALSE,FALSE)
	      else listit(1,FALSE,FALSE);
	end;

	if (saveline) then begin
	  li^[lc]:=s;
	  inc(lc);
	  if (lc>maxli) then begin
	    print('You have used up your maximum amount of lines.');
	    if (inmsgfileopen) then begin
	      inmsgfileopen:=FALSE;
	      cmdsoff:=FALSE;
	      close(inmsgfile);
	    end;
	    exited:=TRUE;
	  end;
          if (lc>(topp+(thisuser.pagelen-5))) then begin
                printmsgtitle('');
                topp:=lc-10;
                listit(topp,FALSE,FALSE);
          end;
	end;
      until ((exited) or (hangup));
      if (hangup) then abortit:=TRUE;
    until ((abortit) or (save) or (hangup));
    if (lc=1) then begin
      abortit:=TRUE;
      save:=FALSE;
    end;
    end;
  end;

  function getorigin:string;
  var s:astr;
  begin
    if (fidor.origins[memboard.origin]<>'') then s:=fidor.origins[memboard.origin]
      else if (fidor.origins[1]<>'') then s:=fidor.origins[1]
        else s:=copy(stripcolor(systat^.bbsname),1,50);
    while (copy(s,length(s),1)=' ') do
      s:=copy(s,1,length(s)-1);
    getorigin:=s;
  end;

  function seenbyline(x:integer):string;
  var x2,basezone:integer;
      s:string;
      first:boolean;
  begin
  first:=true;
  basezone:=fidor.address[x].zone;
  s:='';
  for x2:=1 to 30 do begin
	if (fidor.address[x2].zone<>0) then
		if (fidor.address[x2].zone=basezone) then begin
			if (first) then begin 
				s:='SEEN-BY: '+cstr(fidor.address[x2].zone)+
				':'+cstr(fidor.address[x2].net)+'/'+cstr(fidor.address[x2].node);
				if (fidor.address[x2].point<>0) then s:=s+'.'+cstr(fidor.address[x2].point);
				first:=false;
			end else begin        
				s:=s+' '+cstr(fidor.address[x2].net)+'/'+cstr(fidor.address[x2].node);
				if (fidor.address[x2].point<>0) then s:=s+'.'+cstr(fidor.address[x2].point);
			end;
		end;  
  end;            
  seenbyline:=s;
  end;

  procedure saveit;
  var t:text;
      add,x,x2,i,j,qcolor,tcolor:integer;
      c:char;
      s:astr;
      d:datetimerec;

    function getaddr(zone,net,node,point:integer):string;
    var s:string;
    begin
      if (point=0) then
	s:=cstr(zone)+':'+cstr(net)+'/'+cstr(node)+')'
      else
	s:=cstr(zone)+':'+cstr(net)+'/'+cstr(node)+'.'+cstr(point)+')';
      getaddr:=s;
    end;

  begin
    abortit:=false;
    save:=TRUE;
    with memboard do begin
      assign(t,newtemp+'MSGTMP');
      if not(externaleditor) and not(copymessage) then begin
	rewrite(t);
	for j:=1 to (lc-1) do begin
                write(t,li^[j]);
	end;
      end else begin
        if (exist(newtemp+'MSGTMP')) then begin
		{$I-} reset(t); {$I+}
		if ioresult=0 then begin
			x2:=0;
			while not(eof(t)) do begin
				readln(t,s);
				if (s<>'') then inc(x2);
				end;
			close(t);
			if (x2<=0) then begin
				abortit:=TRUE;
				save:=false;
                        end else begin
				{$I-} append(t); {$I-}
                                if (ioresult<>0) then begin
                                        abortit:=TRUE;
                                        save:=FALSE;
                                        end
                                else begin 
                                if (copymessage) then begin
                                        nl;
                                        sprint('%150%Message has been copied.');
                                        nl;
                                end;
                                end;
			end;
		end else begin
			abortit:=TRUE;
			save:=false;
			end;
	end else begin 
		abortit:=true;
		save:=false;
	end;
      end;
      if (abortit) then exit;
      { cases where need an extra line :

        int, local, tagline
        int, <>local
        ext, tagline

        }
      if (not(externaleditor) and (mbtype=0) and (usetaglines in thisuser.ac)) or
         (not(externaleditor) and (mbtype<>0)) or
         ((externaleditor) and (gettag)) then begin
           writeln(t,'');
      end;
      if (usetaglines in thisuser.ac) and (gettag) then begin
	choosetagline(s);
	if (s<>'') then begin
	s:='... '+s;
	writeln(t,s);
	end;
      end;
      if (mbtype>=1) then begin
        s:='--- Nexus v'+getlongversion(2);
        if (fidor.nodeintear) then s:=s+' [node '+cstr(cnode)+']';
        writeln(t,s);
        if (memboard.mbtype=1) then begin
              s:=' * Origin: '+getorigin+' (';
              s:=s+getaddr(add2.zone,add2.net,add2.node,add2.point);
              write(t,s+#13);
        end;
      end;
      close(t);
      if (memboard.mbtype in [1..3]) then 
      currentmsg^.dokludgeln(^A+'MSGID: '+pointedaddrstr(add2)+' '+lower(hexlong(memboard.msgid)));
      inc(memboard.msgid);
      if (uti) then begin
        s:=currentmSG^.GetMSGID;
        if (s<>'') then currentmSG^.DoKludgeln(^A+'REPLY: '+s);
      end;
      outmessagetext(newtemp+'MSGTMP',TRUE);
      purgedir(newtemp);
    end;
  end;

  procedure readytogo;
  var f:file;
  begin
    if (exist(newtemp+'MSGTMP')) then begin
      assign(f,newtemp+'MSGTMP');
      {$I-} reset(f); {$I+}
      if (ioresult=0) then begin
	close(f);
	erase(f);
      end;
    end;
    if (exist(newtemp+'MSGINF')) then begin
      assign(f,newtemp+'MSGINF');
      {$I-} reset(f); {$I+}
      if (ioresult=0) then begin
	close(f);
	erase(f);
      end;
    end;
  end;

  procedure getfileattach;
  var s,s2:string;
  begin
  s:='';
  s2:='';
  if ((spd='KB') and (memboard.mbtype in [0,2])) then begin
  nl;
  dyny:=FALSE;
  if pynq('%120%Attach files to this message? %110%') then begin
        if (spd='KB') then begin
        sprompt('%030%Filename: %150%');
        input(s,70);
        while (s<>'') do begin
                if (exist(s)) then begin
                        if (s2='') then s2:=s else
                        s2:=s2+' '+s;
                end else begin
                        sprompt('%120%File does not exist!|LF||LF|');
                end;
                writeln(s);
                writeln(s2);
                s:='';
                sprompt('%030%Filename: %150%');
                input(s,70);
        end;
        nl;
        end else begin
                { Uploading of files...}
        end;
        if (s2<>'') then begin
        CurrentMSG^.SetFAttach(TRUE);
        CurrentMSG^.SetSubj(s2);
        end;
  end;
  end;
  dyny:=TRUE;
  end;

begin
  new(mftit);
  new(ffrom);
  new(fto);
  inmsg:=FALSE;
  externaleditor:=false;

  assign(fidorf,systat^.gfilepath+'NETWORK.DAT');
  {$I-} reset(fidorf); {$I+}
  if (ioresult<>0) then begin
	sprint('Error Opening Network Information.  Please Inform the SysOp.');
        sl1('!','Error Opening '+systat^.gfilepath+'NETWORK.DAT');
	exit;
  end;
  read(fidorf,fidor);
  close(fidorf);
  case memboard.mbtype of
	0:CurrentMSG^.SetMailType(mmtNormal);
	1:CurrentMSG^.SetMailType(mmtEchoMail);
	2:CurrentMSG^.SetMailType(mmtNetMail);
        3:CurrentMSG^.SetMailType(mmtNetMail);
  end;
  CurrentMSG^.StartNewMsg;       {initialize for adding msg}
  
  if (thisuser.msgeditor<>0) then externaleditor:=TRUE;
  
  if (uti) then fto^:=ReplyString
    else if (privuser<>'') then fto^:=privuser else fto^:='';
  mftit^:='';
  if (ftit<>'') then mftit^:=ftit;
  if (copy(mftit^,1,1)='\') then begin
    mftit^:=copy(mftit^,2,length(mftit^)-1);
    cantabort:=TRUE;
  end else begin
    if (copy(mftit^,1,1)='/') then mftit^:=copy(mftit^,2,length(mftit^)-1);
    cantabort:=FALSE;
  end;
  if (mbrealname in memboard.mbstat) then 
      ffrom^:=thisuser.realname else
      ffrom^:=thisuser.name;
  created:=FALSE;
  editorok:=TRUE;
  inputthemessage;
  if (not save) then begin
    print('Aborted.');
    readytogo;
    if (created) then dispose(li);
    dispose(mftit);
    dispose(ffrom);
    dispose(fto);
    exit;
  end;

  with CurrentMSG^ do begin
    SetSubj(mftit^);
    if (mbrealname in memboard.mbstat) then 
      mftit^:=thisuser.realname else
      mftit^:=thisuser.name;
    SetDate(DateStr(GetDosDate));
    SetTime(TimeStr(GetDosDate));
    SetFrom(mftit^);
    if (memboard.mbtype=3) then begin
        if (intertype=0) then begin
        if (interto='') then begin
        mftit^:=intertoname;
        SetTo(mftit^);
        emailto:=fto^;
        end else begin
                mftit^:=interto;
                SetTo(mftit^);
                emailto:=fto^;
        end;
        end else begin
        if (interto='') then begin
        mftit^:=fto^;
        setTo(mftit^);
        emailto:='';
        end else begin
                mftit^:=interto;
                SetTo(mftit^);
                emailto:=fto^;
        end;
        end;
    end else begin
    emailto:='';
    mftit^:='';
    if (allcaps(sqoutsp(fto^))='ALL') then fto^:='All';
    mftit^:=fto^;
    SetTo(mftit^);
    end;
    SetEcho(TRUE);
    SetLocal(TRUE);
  end;

  loadboard(board);

  if not(externaleditor) and not(copymessage) then begin
  nl;
  while ((lc>1) and ((li^[lc-1]='') or (li^[lc-1]=^J))) do dec(lc);
  end;

  saveit;
  if (not save) then begin
    print('Aborted.');
    readytogo;
    if (created) then dispose(li);
    exit;
  end;
  getfileattach;
  sprompt('%150%'+'Saving... ');
  savesystat;

  filemode:=66; 
  if not(filerec(bf).mode<>fmclosed) then begin
      {$I-} reset(bf); {$I+}
      if (ioresult=0) then begin
        seek(bf,board);
        write(bf,memboard);
        close(bf);
      end;
  end;

  readytogo;
  if (created) then dispose(li);
  dispose(mftit);
  dispose(ffrom);
  dispose(fto);
  inmsg:=TRUE;
end;

procedure inli(var i:string);
var s:astr;
    cp,rp,cv,cc,xxy:integer;
    c,d:char;
    hitcmdkey,hitbkspc,escp,dothischar,abort,next,savallowabort:boolean;

  procedure bkspc;
  begin
    if (cp>1) then begin
	if (i[cp-1]=^H) then begin
	  prompt(' ');
	  inc(rp);
	end else
	  if (i[cp-1]<>#10) then begin
            prompt(^H);
	    dec(rp);
	  end;
      dec(cp);
    end;
  end;

begin
  write_msg:=TRUE; hitcmdkey:=FALSE; hitbkspc:=FALSE;
  escp:=FALSE;
  rp:=1; cp:=1;
  i:='';
  if (lastline<>'') then begin
    abort:=FALSE; next:=FALSE;
    savallowabort:=allowabort; allowabort:=FALSE;
    reading_a_msg:=TRUE;
    sprompt(lastline);
    reading_a_msg:=FALSE;
    allowabort:=savallowabort;
    i:=lastline; lastline:='';
    escp:=(pos(^[,i)<>0);
    cp:=length(i)+1;
    rp:=cp;
  end;
  repeat
    if ((inmsgfileopen) and (buf='')) then
      if (not eof(inmsgfile)) then begin
	readln(inmsgfile,buf);
	buf:=buf+^M;
      end else begin
	close(inmsgfile);
	inmsgfileopen:=FALSE; cmdsoff:=FALSE;
        sprompt('%070%');
        cp:=1;
      end;
    getkey(c);

    dothischar:=FALSE;
    if (c=^G) then begin
      cmdsoff:=not cmdsoff;
      nl; nl;
      if (cmdsoff) then begin
        sprint('%140%'+'Message commands OFF now, to allow entry of special characters.');
        sprint('%140%'+'Press Ctrl-G again to turn message commands back on.');
      end else
        sprint('%140%'+'Message commands back on again.');
      nl;
      for xxy:=1 to cp do s[xxy]:=i[xxy]; s[0]:=chr(cp-1);
      abort:=FALSE; next:=FALSE;
      sprompt(s);
      wkey(abort,next);
    end;
    if (not cmdsoff) then
      if ((c>=#32) and (c<=#255)) then begin dothischar:=TRUE;
      end else begin
	case c of
	  ^[:dothischar:=TRUE;
	  ^B:dm(' -'^N'/'^N'l'^N'\'^N,c);
	  ^H:if (cp=1) then begin
	       hitcmdkey:=TRUE;
	       hitbkspc:=TRUE;
	     end else
	       bkspc;
	  ^I:begin
	       cv:=5-(cp mod 5);
               if (cp+cv<strlen) and (rp+cv<79) then
		 for cc:=1 to cv do begin
		   outkey(' '); if (trapping) then write(trapfile,' ');
		   i[cp]:=' ';
		   inc(rp); inc(cp);
		 end;
	     end;
	  ^J:if (not (rbackspace in thisuser.ac)) then begin
	       outkey(c); i[cp]:=c;
	       if (trapping) then write(trapfile,^J);
	       inc(cp);
	     end;
	  ^N:if (not (rbackspace in thisuser.ac)) then begin
	       outkey(^H); i[cp]:=^H;
	       if (trapping) then write(trapfile,^H);
	       inc(cp); dec(rp);
	     end;
	  ^S:dm(nam,c);
	  ^W:if (cp=1) then begin
	       hitcmdkey:=TRUE;
	       hitbkspc:=TRUE;
	     end else
               repeat bkspc until (cp=1) or (i[cp]=' ');
	  ^X:begin
	       cp:=1;
	       for cv:=1 to rp-1 do prompt(^H' '^H);
	       rp:=1;
	     end;
	end;
        if (c=#27) then
        if not(inmsgfileopen) then begin
        if (cp=1) then begin
                hitcmdkey:=true;
                dothischar:=false;
        end else begin
                getkey(c);
                case c of
                        #91:begin
                        getkey(c);
                        case c of
                                #65..#68:begin
                                dothischar:=FALSE;
                                end;
                                else begin
                                dothischar:=TRUE;
                                i[cp]:=#27; inc(cp); inc(rp);
                                outkey(c);
                                i[cp]:=#91; inc(cp); inc(rp);
                                outkey(c);
                                inc(pap,2);
                                end;
                        end;
                        end;
                        else begin
                                dothischar:=TRUE;
                                i[cp]:=#27; inc(cp); inc(rp);
                                outkey(c); inc(pap);
                        end;
               end;
               end;
        end;
      end;

    if ((dothischar) or (cmdsoff)) and ((c<>^G) and (c<>^M)) then
      if ((cp<strlen) and (escp)) or
         ((rp<79) and (not escp)) then begin
	if (c=^[) then escp:=TRUE;
	i[cp]:=c; inc(cp); inc(rp);
	outkey(c);
	if (trapping) then write(trapfile,c);
	inc(pap);
      end;
  until ((rp=(79)) and (not escp)) or ((cp=strlen) and (escp)) or
	(c=^M) or (hitcmdkey) or (hangup);

  if (hitcmdkey) then begin
    if (hitbkspc) then i:=#27^H else i:=#27;
  end else begin
    i[0]:=chr(cp-1);
    if (c<>^M) and (cp<>strlen) and (not escp) then begin
      cv:=cp-1;
      while (cv>1) and (i[cv]<>' ') do dec(cv);
      if (cv>rp div 2) and (cv<>cp-1) then begin
	lastline:=copy(i,cv+1,cp-cv);
	for cc:=cp-2 downto cv do prompt(^H);
	for cc:=cp-2 downto cv do prompt(' ');
	i[0]:=chr(cv-1);
        i:=i+#141;
      end;
    end;
    if (c=^M) then i:=i+#13;
    if (escp) and (rp=79) then cp:=strlen;
    if (cp<>strlen) then nl
    else begin
      rp:=1; cp:=1;
      i:=i+#29;
    end;
  end;

  write_msg:=FALSE;
end;

end.

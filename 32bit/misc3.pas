(*****************************************************************************)
(*>                                                                         <*)
(*>  MISC3   .PAS -  Written by Eric Oman                                   <*)
(*>                                                                         <*)
(*>  Various miscellaneous functions used by the BBS.                       <*)
(*>                                                                         <*)
(*>                                                                         <*)
(*****************************************************************************)
{$A+,B+,D-,E+,F+,I+,L+,N-,O+,R-,S+,V-}
unit misc3;

interface

uses
  crt, dos,
  common;

procedure finduserws(var usernum:integer);
procedure sysopstatus;

implementation


procedure finduserws(var usernum:integer);
var user:userrec;
    sr:smalrec;
    nn,duh:astr;
    tp,x,t,i,i1,gg:integer;
    c:char;
    sfo,ufo,done,asked:boolean;
begin
  ufo:=(filerec(uf).mode<>fmclosed);
  if (not ufo) then reset(uf);
  inputmain(nn,36,'L');
  {usernum:=value(nn);}
  nn:=allcaps(nn);
  if (nn='SYSOP') then usernum:=1;
    if (nn<>'') then begin
      sfo:=(filerec(sf).mode<>fmclosed);
      if (not sfo) then reset(sf);
      done:=FALSE; asked:=FALSE;
      gg:=0;
      while ((gg<filesize(sf)-1) and (not done)) do begin
	inc(gg);
	seek(sf,gg); read(sf,sr);
	tp:=0;
     if (pos(nn,allcaps(sr.name))<>0) then tp:=1 else if (pos(nn,allcaps(sr.real))<>0) then tp:=2;
	if (tp<>0) then          
       if ((allcaps(sr.name)=nn) or (allcaps(sr.real)=nn)) then
	    usernum:=sr.number
	  else begin
	    if (not asked) then begin nl; asked:=TRUE; end;
	    for x:=1 to length(nn) do prompt(^H' '^H);
            if tp=1 then sprompt('%120%'+sr.name) else
               sprompt('%120%'+sr.real);
            sprompt('%120%? [%150%Q%120%=Quit] : %110%Yes');
	    onekcr:=false;
	    onekda:=false;
	    onek(c,'QYN'^M);
	    onekcr:=true;
	    onekda:=true;
	    done:=TRUE;
	    case c of
	      'Q':begin
		  usernum:=0;
		  for x:=1 to 3 do prompt(^H' '^H);
                  sprint('%110%Quit');
		  end;
	      'Y':begin
		  usernum:=sr.number;
		  nl;
		  end;
	    else begin
		  done:=FALSE;
		  for x:=1 to 3 do prompt(^H' '^H);
                  sprint('%110%No');
		  end;
	    end;
	  end;
      end;
      if (usernum=0) then begin for x:=1 to length(nn) do prompt(^H' '^H);print('User Not Found.'); end;
      if (not sfo) then close(sf);
    end;
  if (not ufo) then close(uf);
end;

procedure sysopstatus;
begin
	if (sysop) then begin
		printf('SYSOPIN');
                if (nofile) then sprompt(gstring(10));
	end else begin
		printf('SYSOPOUT');
                if (nofile) then sprompt(gstring(11));
	end;
end;

end.

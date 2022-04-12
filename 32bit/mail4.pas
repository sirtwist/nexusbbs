{$A+,B+,D-,E+,F+,I+,L+,N-,O+,R-,S+,V-}
unit mail4;

interface

uses
  crt, dos, common;
 
function extractusernum(s:string):integer;
function findusername(s:string):string;

implementation

function findusername(s:string):string;
type narr=array[1..20] of integer;
var sr:smalrec;
    s2:string[5];
    s3:string[36];
    done,sfo:boolean;
    nums:^narr;
    more:boolean;
    highnum,nextstart,xx:integer;

    procedure getpage;
    var i2:integer;
    begin
      i2:=1;
      if (more) then begin
        more:=FALSE;
        seek(sf,nextstart);
        nextstart:=0;
      end;
      while not(eof(sf)) and not(more) do begin
        read(sf,sr);
        if (pos(allcaps(s),allcaps(sr.name))<>0)
        or (pos(allcaps(s),allcaps(sr.real))<>0) then begin
                if (i2<20) then begin
                        nums^[i2]:=filepos(sf)-1;
                        highnum:=i2;
                        inc(i2);
                end else
                if (i2=20) then begin
                        more:=TRUE;
                        nextstart:=filepos(sf)-1;
                        inc(i2);
                end;
        end;
      end;
    end;

        function userealname:boolean;
        begin
        if ((systat^.allowalias) and (systat^.aliasprimary) and not(mbrealname in
                memboard.mbstat)) then userealname:=FALSE else userealname:=TRUE;
        end;

    procedure showpage;
    var x2:integer;
    begin
         cls;
         for x2:=1 to highnum do begin
             seek(sf,nums^[x2]);
             read(sf,sr);
             sprompt(mln('%080%[%150%'+cstr(x2)+'%080%]',4)+'  %030%');
             if (userealname) then sprint(sr.real) else sprint(sr.name);
         end;
         nl;
    end;


begin
    highnum:=0;
    nextstart:=0;
    more:=TRUE;
    new(nums);
    fillchar(nums^,sizeof(nums^),#0);
    s3:='';
    if (s<>'') then begin
      sfo:=(filerec(sf).mode<>fmclosed);
      if (not sfo) then reset(sf);
      seek(sf,0);
      done:=FALSE;
      while (more) and not(done) do begin
                getpage;
                if (highnum=0) then begin
                        sprint('%120% -- User not found.');
                        done:=TRUE;
                        s3:='';
                end else
                if (highnum=1) then begin
                        seek(sf,nums^[1]);
                        read(sf,sr);
                        if (userealname) then s3:=sr.real else
                        s3:=sr.name;
                        done:=TRUE;
                        for xx:=1 to length(s) do prompt(^H' '^H);
                        print(s3);
                end else begin
                showpage;
                if (more) then begin
                        sprompt('%030%Select user (%150%1%030%-%150%'+cstr(highnum)+
                                '%030%,%150%Q%030%=Quit,%150%ENTER%030%=More) : %150%');
                end else begin
                        sprompt('%030%Select user (%150%1%030%-%150%'+cstr(highnum)+
                                '%030%,%150%Q%030%=Quit) : %150%');
                end;
                scaninput(s2,'Q'^M,TRUE);
                if (s2='Q') then begin
                        done:=TRUE;
                end else
                if ((s2='') or (s2=#13)) then begin
                        if not(more) then done:=TRUE;
                end else begin
                        if (value(s2)>0) and (value(s2)<=highnum) then begin
                        seek(sf,nums^[value(s2)]);
                        read(sf,sr);
                        if (userealname) then s3:=sr.real else
                        s3:=sr.name;
                        nl;
                        done:=TRUE;
                        end;
                end;
                end;
      end;
      close(sf);
     end;
     dispose(nums);
     findusername:=s3;
end;

function extractusernum(s:string):integer;
var i,gg:integer;
    sr:smalrec;
    done,sfo:boolean;
begin
    i:=0;
    if (s<>'') then begin
      sfo:=(filerec(sf).mode<>fmclosed);
      if (not sfo) then reset(sf);
      gg:=0;
      done:=false;
      while ((gg<filesize(sf)-1) and (not done)) do begin
        inc(gg);
        seek(sf,gg); read(sf,sr);
        if ((allcaps(sr.name)=allcaps(s)) or (allcaps(sr.real)=allcaps(s))) then begin
            i:=sr.number;
            done:=true;
        end;
      end;
      if (i=0) then begin
        sprint('Unknown User: '+s);
        i:=0;
      end;
     end;
  extractusernum:=i;
end;

end.

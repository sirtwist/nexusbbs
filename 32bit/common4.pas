{$A+,B+,D-,E+,F+,I+,L-,N-,O+,R+,S+,V-}
unit common4;

interface

function subdaysleft:string;
function subdays:string;

implementation

uses common;

function subdaysleft:string;
var ssf:file of subscriptionrec;
     ss:subscriptionrec;
     tmpdate:longint;
     tmpstring:string[20];
begin
  tmpstring:='Error!';
  assign(ssf,adrv(systat^.gfilepath)+'SUBSCRIP.DAT');
  {$I-} reset(ssf); {$I+}
  if (ioresult<>0) then begin
        sl1('!','Error Opening SUBSCRIP.DAT');
        sl1('!','Unable to retrieve user''s subscription info');
  end else begin
        if (thisuser.subscription>filesize(ssf)-1) then begin
                sl1('!','Subscription Setting for User no longer available');
                sl1('!','Please change to available Subscription Level');
        end else begin
                seek(ssf,thisuser.subscription);
                read(ssf,ss);
                if (ss.sublength<>0) and (ss.newsublevel<>0) then begin
                tmpdate:=u_daynum(datelong+'  '+time);
                tmpdate:=tmpdate-thisuser.subdate;
                tmpdate:=trunc(tmpdate/86400);
                tmpdate:=ss.sublength-tmpdate;
                end else begin
                        tmpdate:=-1;
                end;
                if (tmpdate=-1) then
                tmpstring:='0 (No expire)'
                else
                tmpstring:=cstr(tmpdate);
        end;
        close(ssf);
  end;
  subdaysleft:=tmpstring;
end;

function subdays:string;
var ssf:file of subscriptionrec;
     ss:subscriptionrec;
     tmpdate:longint;
     tmpstring:string[20];
begin
  tmpstring:='Error!';
  assign(ssf,adrv(systat^.gfilepath)+'SUBSCRIP.DAT');
  {$I-} reset(ssf); {$I+}
  if (ioresult<>0) then begin
        sl1('!','Error Opening SUBSCRIP.DAT');
        sl1('!','Unable to retrieve user''s subscription info');
  end else begin
        if (thisuser.subscription>filesize(ssf)-1) then begin
                sl1('!','Subscription Setting for User no longer available');
                sl1('!','Please change to available Subscription Level');
        end else begin
                seek(ssf,thisuser.subscription);
                read(ssf,ss);
                if (ss.sublength=0) or (ss.newsublevel=0) then
                tmpstring:='0 (No expire)'
                else
                tmpstring:=cstr(ss.sublength);
        end;
        close(ssf);
  end;
  subdays:=tmpstring;
end;

end.

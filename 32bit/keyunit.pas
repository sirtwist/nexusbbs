{$O+}
unit keyunit;

interface

uses dos,crt,misc;

type ivreg=
     RECORD
        name:string[36];
        company:string[36];
        bbs:string[36];
        random1:byte;           { 112 }
        phone:string[20];
        telnet:string[80];
        expires:string[10];
        random2:byte;           { 226 }
        regdate:string[10];
        serial:integer;
        level:byte;
        rtype:byte;
        random3:byte;           { 242 }
        product:string[8];
        id:array[1..3] of char;
     end;


var tmp:array[1..254] of byte;
    ivr:ivreg;
    keydir:string;
    registered:boolean;

procedure checkkey(product:string);
procedure createkey(ivr2:ivreg;prod:string);
function expired:boolean;

implementation

function expired:boolean;
begin
if (ivr.expires='') then begin
        expired:=FALSE;
end else
if (value(copy(datelong,7,4))<value(copy(ivr.expires,7,4))) then begin
        expired:=FALSE;
end else
if (value(copy(datelong,7,4))>value(copy(ivr.expires,7,4))) then begin
        expired:=TRUE;
end else
if (value(copy(datelong,7,4))=value(copy(ivr.expires,7,4))) then begin
        if (value(copy(datelong,1,2))<value(copy(ivr.expires,1,2))) then begin
                expired:=FALSE;
        end else
        if (value(copy(datelong,1,2))>value(copy(ivr.expires,1,2))) then begin
                expired:=TRUE;
        end else
        if (value(copy(datelong,1,2))=value(copy(ivr.expires,1,2))) then begin
                if (value(copy(datelong,4,2))<=value(copy(ivr.expires,4,2))) then begin
                        expired:=FALSE;
                end else
                if (value(copy(datelong,4,2))>value(copy(ivr.expires,4,2))) then begin
                        expired:=TRUE;
                end;
        end;
end;
end;

procedure checkkey(product:string);
var r1,r2,r3:byte;
    x,i:integer;
    f:file;

begin
registered:=FALSE;
assign(f,keydir+product+'.KEY');
{$I-} reset(f,1); {$I+}
if (ioresult<>0) then begin
        registered:=FALSE;
        exit;
end;
blockread(f,tmp[1],254);
close(f);
r3:=tmp[112];
i:=8-ord(r3);
for x:=1 to 254 do begin
tmp[x]:=(ord(tmp[x]) shl i) or (ord(tmp[x]) shr r3);
end;
r3:=tmp[226];
i:=8-ord(r3);
for x:=1 to 254 do begin
tmp[x]:=(ord(tmp[x]) shl i) or (ord(tmp[x]) shr r3);
end;
r3:=tmp[242];
i:=8-ord(r3);
for x:=1 to 254 do begin
tmp[x]:=(ord(tmp[x]) shl i) or (ord(tmp[x]) shr r3);
end;
move(tmp,ivr,254);
if (ivr.id[1]='E') and (ivr.id[2]='K') and (ivr.id[3]='S') then registered:=TRUE;
end;

procedure createkey(ivr2:ivreg;prod:string);
var r1,r2,r3:byte;
    x,i:integer;
    f:file;
begin
randseed:=trunc(timer);
randomize;
for x:=1 to 254 do begin
r3:=0;
while (r3=0) do begin
r3:=random(254);
end;
tmp[x]:=r3;
end;
move(tmp,ivr,254);
with ivr do begin
name:=ivr2.name;
company:=ivr2.company;
bbs:=ivr2.bbs;
phone:=ivr2.phone;
telnet:=ivr2.telnet;
ivr.product:=prod;
serial:=ivr2.serial;
regdate:=ivr2.regdate;
expires:=ivr2.expires;
level:=ivr2.level;
rtype:=ivr2.rtype;
id[1]:='E';
id[2]:='K';
id[3]:='S';
end;
move(ivr,tmp[1],254);
assign(f,prod+'.KEY');
rewrite(f,1);
randseed:=trunc(timer);
randomize;
r3:=0;
while (r3=0) do begin
r3:=random(5);
end;
i:=8-ord(r3);
for x:=1 to 254 do begin
tmp[x]:=(ord(tmp[x]) shl r3) or (ord(tmp[x]) shr i);
end;
tmp[242]:=r3;
for x:=1 to 254 do begin
write(tmp[x]);
end;
writeln;writeln;
r3:=0;
while (r3=0) do begin
r3:=random(5);
end;
i:=8-ord(r3);
for x:=1 to 254 do begin
tmp[x]:=(ord(tmp[x]) shl r3) or (ord(tmp[x]) shr i);
end;
tmp[226]:=r3;
for x:=1 to 254 do begin
write(tmp[x]);
end;
writeln;writeln;
r3:=0;
while (r3=0) do begin
r3:=random(5);
end;
i:=8-ord(r3);
for x:=1 to 254 do begin
tmp[x]:=(ord(tmp[x]) shl r3) or (ord(tmp[x]) shr i);
end;
tmp[112]:=r3;
for x:=1 to 254 do begin
write(tmp[x]);
end;
writeln;writeln;
blockwrite(f,tmp[1],254);
close(f);
end;

end.

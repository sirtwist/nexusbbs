program buildp;

uses dos,crt,misc;

{$I BUILD.INC}

var t,t2:text;
    s,s2:string;
    i:integer;

begin
s:=paramstr(1);
if (s='') then begin
        s:=copy(build,2,2);
end;
if (allcaps(paramstr(2))<>'BETA') then begin
        if (value(paramstr(2))<>0) then begin
                s:=s+'.'+cstrnfile(value(paramstr(2)));
        end else begin
                s:=s+'.'+cstrnfile(value(copy(build,5,3))+1);
        end;
end;
assign(t2,'header.txt');
reset(t2);
assign(t,'build.inc');
rewrite(t);
while not(eof(t2)) do begin
       readln(t2,s2);
       writeln(t,s2);
end;
close(t2);
writeln(t);
writeln(t,'CONST');
writeln(t);
writeln(t,'Build:String[7]=',chr(39),'.',s,chr(39),';');
writeln(t,'CompiledString:String='+#39+datelong+'  '+time+#39+';');
writeln(t);
close(t);
end.


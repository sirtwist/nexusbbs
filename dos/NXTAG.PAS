Program nxTAG;

uses dos,crt,myio,misc;

var

tagf:file of tagrec;
tag:tagrec;
t:text;
x,counter:integer;
p1,p2,p3,s,v,b:string;
app,exp:boolean;

procedure title;
begin
writeln('nxTAG v',v,b,' - Tagline Importer/Exporter for Nexus Bulletin Board System');
writeln('Copyright 1994-2001 George A. Roberts IV.  All rights reserved.');
writeln;
end;

procedure help;
begin
writeln('Syntax:  nxTAG [Command] [Tagline File] [Text File]');
writeln;
writeln('Commands:   U    -  Uncompress into text file ');
writeln('            C[A] -  Compress into tagline file [A - Append To ');
writeln('                       existing tagline file]');
writeln;
halt;
end;

begin
v:='1.00';
b:='.02';
title;
if (paramcount<3) then begin
        help;
        end;
p1:=paramstr(1);
p2:=paramstr(2);
p3:=paramstr(3);
assign(tagf,p2);
assign(t,p3);
exp:=false;
app:=false;
if upcase(p1[1])='U' then exp:=TRUE;
if upcase(p1[2])='A' then app:=TRUE;
if (exp) then begin
        {$I-} reset(tagf); {$I+}
        if ioresult<>0 then begin
                writeln('Error opening ',p2);
                halt;
                end;
        if (filesize(tagf)=1) then begin
                writeln('No taglines in this file.');
                halt;
        end;
        seek(tagf,1);
        rewrite(t);
        writeln('Uncompressing: ',p2,' to ',p3);
        writeln;
        counter:=1;
        write('Uncompressing [');
        while not(eof(tagf)) do begin
                write(counter,']');
                read(tagf,tag);
                writeln(t,tag.tag);
                for x:=1 to length(cstr(counter))+1 do write(^H' '^H);
                inc(counter);
        end;
        writeln(counter-1,']');
        close(tagf);
        close(t);
end else begin
        {$I-} reset(t); {$I+}
        if ioresult<>0 then begin
                writeln('Error opening ',p3);
                halt;
        end;
        if (app) then begin
                {$I+} reset(tagf); {$I-}
                if ioresult<>0 then begin
                        writeln('No tagline file: creating new file.');
                        rewrite(tagf);
                end;
                seek(tagf,filesize(tagf));
                counter:=filesize(tagf);
        end else begin
                rewrite(tagf);
                counter:=1;
        end;
        tag.tag:='Nexus - Copyright 1994-2001 George A. Roberts IV';
        write(tagf,tag);
        if (app) then writeln('Updating: ',p2,' with ',p3) else
        writeln('Compressing: ',p3,' to ',p2);
        writeln;
        if (app) then write('Adding [') else
        write('Compressing [');
        while not(eof(t)) do begin
                readln(t,s);
                if ((s<>'') and (s[1]<>';') and (allcaps(copy(s,1,9))<>'[HANCOCK]')
                        and (allcaps(copy(s,1,9))<>'[ALTLIST]')
                        and (allcaps(copy(s,1,9))<>'[COMMENT]'))
                        then begin
                        write(counter,']');
                        tag.tag:=s;
                        write(tagf,tag);
                        for x:=1 to length(cstr(counter))+1 do write(^H' '^H);
                        inc(counter);
                end;
        end;
        writeln(counter-1,']');
        close(tagf);
        close(t);
end;
end.






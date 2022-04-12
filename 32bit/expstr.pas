unit expstr;

interface

uses dos,crt,misc;

procedure export(nxlname,txtname:string);

implementation

var si:stringidx;
    s,inf:string;
    f:file;
    x:integer;
    t:text;

function getstring(x:integer):string;
begin
if (si.offset[x]<>-1) then begin
if (si.offset[x]<=filesize(f)-1) then begin
seek(f,si.offset[x]);
blockread(f,s[0],1);
blockread(f,s[1],ord(s[0]));
end else s:='';
end else s:='';
getstring:=s;
end;

procedure export(nxlname,txtname:string);
begin
assign(f,nxlname);
assign(t,txtname);
{$I-} reset(f,1); {$I+}
if (ioresult<>0) then begin
writeln('Error opening '+nxlname);
halt;
end;
{$I-} reset(t); {$I+}
if (ioresult=0) then begin
        writeln(txtname+' already exists!  Please rename existing file.');
        close(t);
        halt;
end;
writeln('Source file    : '+nxlname);
writeln('Exporting to   : '+txtname);
writeln;
write('Exporting... ');
rewrite(t);
fillchar(si,sizeof(si),#0);
blockread(f,si,sizeof(si));
writeln(t,'; Language Definition: '+txtname);
writeln(t,'; Created by MAKELANG v1.10 on '+date+' '+time);
writeln(t,';');
writeln(t,'; For use with the Nexus Bulletin Board System v1.00');
writeln(t,';');
writeln(t,'; (c) Copyright 1996-2000 George A. Roberts IV.  All Rights Reserved.');
writeln(t,';');
writeln(t,';');
writeln(t,';');
writeln(t,';');
writeln(t,'; USAGE NOTES:');
writeln(t,';');
writeln(t,'; Use the file MAKELANG.EXE to compile this string file.  NOTE: When');
writeln(t,'; importing this definition, all changes that you may have made via the');
writeln(t,'; String Editor in Nexus, but have not made here, will be lost!');
writeln(t,';');
writeln(t,'; Notes regarding the use of configurable strings in Nexus:');
writeln(t,';');
writeln(t,';  o  The maximum length of a string AFTER color code and MCI code replacement');
writeln(t,';     is 255 characters.  If this is not adhered to, you will see some');
writeln(t,';     unexpected results in the display of that particular string;');
writeln(t,';');
writeln(t,';  o  Some strings are used to determine the valid input characters of');
writeln(t,';     of various prompts.  These strings are ORDER sensitive.  In other words,');
writeln(t,';     the characters in the string represent values for choices.  If you');
writeln(t,';     have a default string of ABCD and change it to DCBA, the letter that');
writeln(t,';     will be accepted as valid for choice #1 will be changed.  Be VERY');
writeln(t,';     CAREFUL when modifying these strings and be sure that the appropriate');
writeln(t,';     help strings and screens reflect your changes, so your users are not');
writeln(t,';     confused by what results from pressing a key.');
writeln(t,';');
writeln(t,';  o  String #5 is the string used for the echo character.  Nexus will ONLY');
writeln(t,';     use the first character in the string.  Specifying additional characters');
writeln(t,';     though harmless, will do nothing.');
writeln(t,';');
writeln(t,';  o  When displaying a string, Nexus WILL NOT automatically place a CR/LF');
writeln(t,';     sequence after it.  This is to allow you flexibility in design.');
writeln(t,';     Therefore, be sure that when you wish to have a string displayed with');
writeln(t,';     a CR/LF sequence at the end, that you place a |LF| at the end.');
writeln(t,';');
writeln(t,';  o  |FILE|, |NXE|, and |DOOR| are valid entries in all strings EXCEPT');
writeln(t,';     the valid character input strings.');
writeln(t,';');
writeln(t,';  IMPORTANT NOTE:  MAKE SURE TO KEEP A BACKUP OF THE ORIGINAL LANGUAGE');
writeln(t,';                   DEFINITION FILE.  IF YOU SHOULD MAKE CHANGES THAT DO NOT');
writeln(t,';                   WORK PROPERLY, YOU WILL BE ABLE TO CUT AND PASTE FROM');
writeln(t,';                   YOUR ORIGINAL FILE TO FIX THE PROBLEMS.');
writeln(t,';');
writeln(t,';');
for x:=1 to 2000 do begin
writeln(t,mln(cstr(x),5)+': '+getstring(x));
end;
close(t);
close(f);
writeln('Finished!');
end;

end.


(*****************************************************************************)
(*>                                                                         <*)
(*>  MENUS3  .PAS -  Written by Eric Oman                                   <*)
(*>                                                                         <*)
(*>  Menu command execution routines.                                       <*)
(*>                                                                         <*)
(*****************************************************************************)
{$A+,B+,D-,E+,F+,I+,L+,N-,O+,R-,S+,V-}
unit menus3;

interface

uses
  crt, dos, 
  file0,
  common;

procedure dochangemenu(var done:boolean; var newmenucmd:astr;
                       c2:char; mstr:astr);

implementation

uses menus2;

procedure dochangemenu(var done:boolean; var newmenucmd:astr;
                       c2:char; mstr:astr);
var s,s1:astr;
begin
  case c2 of
    '1':begin
          s1:=mstr;
          if (pos(';',s1)<>0) then s1:=copy(s1,1,pos(';',s1)-1);
          if (mstr<>'') then begin
            s:=mstr;
            if (pos(';',s)<>0) then s:=copy(s,pos(';',s)+1,length(s));
            if (copy(s,1,1)='C') then menustackptr:=0;
            if (pos(';',s)=0) or (length(s)=1) then s:=''
              else s:=copy(s,pos(';',s)+1,length(s));
          end;
          if (s1<>'') then begin
            last_menu:=curmenu; curmenu:=value(s1);
            done:=TRUE;
            if (s<>'') then newmenucmd:=allcaps(s);
            newmenutoload:=TRUE;
          end;
        end;
    '2':begin
          s1:=mstr;
          if (pos(';',s1)<>0) then s1:=copy(s1,1,pos(';',s1)-1);
          if ((mstr<>'') and (menustackptr<>8)) then begin
            s:=mstr;
            if (pos(';',s)<>0) then s:=copy(s,pos(';',s)+1,length(s));
            if (copy(s,1,1)='C') then menustackptr:=0;
            if (pos(';',s)=0) or (length(s)=1) then s:=''
              else s:=copy(s,pos(';',s)+1,length(s));
            inc(menustackptr);
            menustack[menustackptr]:=curmenu;
          end;
          if (s1<>'') then begin
            last_menu:=curmenu; curmenu:=value(s1);
            done:=TRUE;
            if (s<>'') then newmenucmd:=allcaps(s);
            newmenutoload:=TRUE;
          end;
        end;
    '3':begin
          s:=mstr;
          if (menustackptr<>0) then begin
            last_menu:=curmenu;
            curmenu:=menustack[menustackptr];
            dec(menustackptr);
          end;
          if (copy(s,1,1)='C') then menustackptr:=0;
          done:=TRUE;
          if (pos(';',s)=0) then s:='' else
            newmenucmd:=allcaps(copy(s,pos(';',s)+1,length(s)));
          newmenutoload:=TRUE;
        end;
  end;
end;

end.

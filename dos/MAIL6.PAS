{$A+,B+,D-,E+,F+,I+,L+,N-,O+,R-,S+,V-}
unit mail6;

interface

uses
  crt, dos, common, mail0, mail3, mail9;

procedure chbds;

implementation

uses myio3,tagunit,mkstring;

procedure chbds;
var s:astr;
    x5,i:integer;
    done:boolean;
    UTAG:^TagRecordOBJ;

begin
  if (novice in thisuser.ac) then mbasechange(done,'L') else nl;
  new(UTAG);
  if (UTAG=NIL) then begin
      sprint('%120%Unable to access tag records.');
      exit;
  end;
  UTAG^.Init(adrv(systat^.userpath)+hexlong(thisuser.userid)+'\'+hexlong(thisuser.userid)+'.NMT');
  UTAG^.MaxBases:=Numboards;
  done:=FALSE;
  repeat
    sprompt('%030%Tag Message Bases [%150%?%030%=Help] : %150%'); scaninput(s,'LAU?Q',TRUE);
    if (s='Q') then done:=TRUE;
    if (s='?') then begin
	nl;
        sprint('%080%[%150%L%080%] %030%Re-list Message Bases');
        sprint('%080%[%150%#%080%] %030%Toggle base scan on/off for this base number');
        sprint('%080%[%150%A%080%] %030%Set all bases to be scanned');
        sprint('%080%[%150%U%080%] %030%Set all bases NOT to be scanned');
        sprint('%080%[%150%Q%080%] %030%Quit Message Base tagging');
	nl;
	end;
    if (s='L') then begin
        UTAG^.Done;
        dispose(UTAG);
        mbasechange(done,'L');
        new(UTAG);
        if (UTAG=NIL) then begin
            sprint('%120%Unable to access tag records.');
            exit;
        end;
        UTAG^.Init(adrv(systat^.userpath)+hexlong(thisuser.userid)+'\'+hexlong(thisuser.userid)+'.NMT');
        UTAG^.MaxBases:=Numboards;
    end;
    i:=value(s);
    if ((i>0) and (i<=numboards) and (s<>'')) or ((i=0) and (s='0')) then begin
    if (inmconf(i)) then
    if (mbaseac(i)) then begin
        if (memboard.tagtype=2) and not(aacs(systat^.untagmandatory)) then begin
                sprompt('|LF|%120%This is a mandatory base!|LF||LF|');
        end else begin
	nl;
        if (UTAG^.IsTagged(memboard.baseid)) then begin
          sprint('%030%Untagging: %150%'+memboard.name);
          UTAG^.Removetag(memboard.baseid);
	end else begin
          sprint('%030%Tagging  : %150%'+memboard.name);
          UTAG^.Addtag(memboard.baseid);
	end;
	nl;
        end;
      end;
    end;
    if (s='A') then begin
            sprompt('%120%Tagging: %150%');
            for i:=0 to numboards do
            if (inmconf(i)) then
            if (mbaseac(i)) then begin { loads memboard }
                sprompt(cstr(i));
                UTAG^.AddTag(memboard.baseid);
                for x5:=1 to length(cstr(i)) do begin
                        prompt(^H' '^H);
                end;
            end;
            sprint('%140%All Message Bases Tagged.');
            nl;
    end;
    if (s='U') then begin
            sprompt('%120%Untagging: %150%');
            for i:=0 to numboards do
            if (inmconf(i)) then
            if (mbaseac(i)) then { loads memboard } begin
                if (memboard.tagtype<>2) then begin
                sprompt(cstr(i));
                UTAG^.RemoveTag(Memboard.baseid);
                for x5:=1 to length(cstr(i)) do begin
                        prompt(^H' '^H);
                end;
                end;
            end;
            sprint('%140%All Message Bases UnTagged.');
            nl;
    end;
  until (done) or (hangup);
  lastcommandovr:=TRUE;
  loadboard(board);
  setc(7 or (0 shl 4));
  UTAG^.SortTags(adrv(systat^.gfilepath)+'USER'+cstrn(cnode)+'.TMT',1);
  UTAG^.Done;
  dispose(UTAG);
end;

end.

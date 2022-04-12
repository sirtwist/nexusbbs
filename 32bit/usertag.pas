{----------------------------------------------------------------------------}
{ Next Epoch matriX User System - Nexus BBS Software                         }
{                                                                            }
{ All material contained herein is (c) Copyright 1996 Intuitive Vision       }
{ Software.  All Rights Reserved.                                            }
{                                                                            }
{ MODULE     :  USERTAG.PAS (Mandatory/New Tag Unit)                         }
{ AUTHOR     :  George A. Roberts IV                                         }
{                                                                            }
{----------------------------------------------------------------------------}
{ Intuitive Vision Software is a Division of Intuitive Vision Computer       }
{ Services.  Nexus, Next Epoch matriX User System, and ivOMS are Trademarks  }
{ of Intuitive Vision Software.                                              }
{----------------------------------------------------------------------------}

{$A+,B+,D-,E+,F+,I+,L+,N-,O+,R+,S+,V-}
unit usertag;

interface

uses dos,crt,myio,tagunit,misc;

procedure createdefaulttags(btype:byte);
procedure tagallusers(basenum:integer; btype:byte);

implementation

procedure createdefaulttags(btype:byte);
var mdf:file of boardrec;
    mr:boardrec;
    fdf:file of ulrec;
    fr:ulrec;
    f:file;
    x,x2,x3:integer;
    UTAG:^TagRecordOBJ;
    w2:windowrec;
begin
        new(UTAG);
        if (UTAG=NIL) then begin
                displaybox('Unable to create default tag records!',3000);
                exit;
        end;
        case btype of
                1:begin         { MESSAGE }
                        filemode:=66;
                        assign(mdf,adrv(systat.gfilepath)+'MBASES.DAT');
                        {$I-} reset(mdf); {$I+}
                        if (ioresult<>0) then begin
                                displaybox('Error reading MBASES.DAT!',3000);
                                dispose(UTAG);
                                exit;
                        end;
                        assign(f,adrv(systat.userpath)+'DEFAULT.NMT');
                        {$I-} erase(f); {$I+}
                        if (ioresult<>0) then begin end;
                        setwindow(w2,18,12,61,16,3,0,8,'Creating default MESSAGE tags...',TRUE);
                        textcolor(3);
                        gotoxy(2,2);
                        for x3:=1 to 40 do write('°');
                        x3:=1;
                        x:=0;
                        UTAG^.Init(adrv(systat.userpath)+'DEFAULT.NMT');
                        UTAG^.Maxbases:=filesize(mdf)-1;
                        textcolor(9);
                        while not(eof(mdf)) do begin
                                read(mdf,mr);
                                for x2:=x3 to 40 do begin
                                if (x>=((UTAG^.Maxbases div 40)*x2)) then begin
                                        gotoxy(1+x3,2);
                                        write('Û');
                                        inc(x3);
                                end;
                                end;
                                if (mr.tagtype in [0,2]) then UTAG^.addtag(mr.baseid);
                                inc(x);
                        end;
                        UTAG^.Done;
                        dispose(UTAG);
                        close(mdf);
                        removewindow(w2);
                  end;
                2:begin         { FILE }
                        filemode:=66;
                        assign(fdf,adrv(systat.gfilepath)+'FBASES.DAT');
                        {$I-} reset(fdf); {$I+}
                        if (ioresult<>0) then begin
                                displaybox('Error reading FBASES.DAT!',3000);
                                dispose(UTAG);
                                exit;
                        end;
                        assign(f,adrv(systat.userpath)+'DEFAULT.NFT');
                        {$I-} erase(f); {$I+}
                        if (ioresult<>0) then begin end;
                        setwindow(w2,18,12,61,16,3,0,8,'Creating default FILE tags...',TRUE);
                        textcolor(3);
                        gotoxy(2,2);
                        for x3:=1 to 40 do write('°');
                        x3:=1;
                        x:=0;
                        UTAG^.Init(adrv(systat.userpath)+'DEFAULT.NFT');
                        UTAG^.Maxbases:=filesize(fdf)-1;
                        textcolor(9);
                        while not(eof(fdf)) do begin
                                read(fdf,fr);
                                for x2:=x3 to 40 do begin
                                if (x>=((UTAG^.Maxbases div 40)*x2)) then begin
                                        gotoxy(1+x3,2);
                                        write('Û');
                                        inc(x3);
                                end;
                                end;
                                if (fr.tagtype in [0,2]) then UTAG^.addtag(fr.baseid);
                                inc(x);
                        end;
                        UTAG^.Done;
                        dispose(UTAG);
                        close(fdf);
                        removewindow(w2);
                  end;
        end;
end;

procedure tagallusers(basenum:integer; btype:byte);
begin
end;

end.

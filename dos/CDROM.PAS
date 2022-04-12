{$O+}
UNIT CDROM;

INTERFACE

USES  Dos,cdrom2,volume,common;   { import  Intr, Registers         }
VAR   DrvName   : CHAR;           { first extended drive (A: to Z:) }
      DrvCount   : WORD;          { number of extended drives       }
      IsMSCDEX,                   { TRUE if MSCDEX is installed     }
      IsCDROM   : BOOLEAN;        { TRUE if extended drive is CDROM }
      CDLIST: CDR_DRIVE_UNITS;
      tx:byte;
      cdf:file of cdrec;
      cdif:file of cdidxrec;
      cdi:cdidxrec;
      cds:cdrec;
      tstr:string;
      found:boolean;
      z:integer;

PROCEDURE INITCDROMS;
PROCEDURE CD_ROMdat ( VAR DrvCount  : WORD;     { total ext. drives }
                      VAR FirstDrv  : CHAR;     { first ext. drv    }
                      VAR IsMSCDEX  : BOOLEAN;  { MSCDEX found?     }
                      VAR IsCDROM   : BOOLEAN); { is CD-ROM?        }

(*-----------------------------------------------------------------*)
{ Detect if/how-many extended drives (CD-ROMs) are in system ...    }

IMPLEMENTATION

uses myio;

PROCEDURE CD_ROMdat ( VAR DrvCount  : WORD;     { total ext. drives }
                      VAR FirstDrv  : CHAR;     { first ext. drv    }
                      VAR IsMSCDEX  : BOOLEAN;  { MSCDEX found?     }
                      VAR IsCDROM   : BOOLEAN); { is CD-ROM?        }
  VAR Reg : Registers;            { to access 8086 CPU registers    }
  BEGIN {CD_ROMdat}
                                  { initialize the VARs...          }
      FirstDrv  := #0;            { assume no extension drives      }
      IsMSCDEX  := FALSE;         { assume MSCDEX not installed     }
      IsCDROM   := FALSE;         { assume drive isn't a CD-ROM     }
      Reg.AX := $1500;            { fn: check if CD-ROM is present  }
      Reg.BX := 0;                    { clear BX                    }
      Intr ($2F, Reg);                { invoke MSCDEX               }
      DrvCount := Reg.BX;             { count of extended drives    }
      IF (DrvCount = 0) THEN EXIT;    { abort if no extended drive  }
      FirstDrv := CHR (Reg.CX + 65);  { first drive IN ['A'..'Z']   }
      Reg.AX := $150B;                { fn: CD-ROM drive check      }
      Reg.BX := 0;                    { Reg.CX already has drive #  }
      Intr ($2F, Reg);                { call the CD-ROM services    }
      IF (Reg.BX <> $ADAD) THEN EXIT; { MSCDEX isn't installed      }
      IsMSCDEX := TRUE;               { MSCDEX is installed         }
      IF (Reg.AX = 0) THEN EXIT;      { ext. drive isn't a CD-ROM   }
      IsCDROM := TRUE;                { extended is a CD-ROM        }
  END {CD_ROMdat};                    { END PROCEDURE DC_ROMdat     }

(*-----------------------------------------------------------------*)
procedure CDI_GET_DRIVE_UNITS(VAR BUFF:CDR_DRIVE_UNITS);
var x,x2:integer;
begin
for x:=0 to 25 do BUFF[x]:=0;
assign(cdif,adrv(systat^.gfilepath)+'CDS.IDX');
{$I-} reset(cdif); {$I+}
if (ioresult<>0) then begin
        exit;
end;
read(cdif,cdi);
close(cdif);
x2:=1;
for x:=1 to 26 do begin
        if (cdi.drives[x]<>#0) then begin
                buff[x2]:=ord(cdi.drives[x])-65;
                inc(x2);
        end;
end;
end;

PROCEDURE INITCDROMS;
var cdfile:file;
BEGIN {PROGRAM CDROM}
  if (cdmap) and (exist(adrv(systat^.gfilepath)+'CDS.MAP')) then begin
        assign(cdfile,adrv(systat^.gfilepath)+'CDS.MAP');
        {$I-} reset(cdfile,1); {$I+}
        if (ioresult=0) then begin
                blockread(cdfile,cdavail,sizeof(cdavail));
                close(cdfile);
                exit;
        end;
  end;
  for tx:=1 to 26 do cdavail[tx]:=0;

  filemode:=66;
  assign(cdf,adrv(systat^.gfilepath)+'CDS.DAT');
  {$I-} reset(cdf); {$I+}
  if ioresult<>0 then begin
        exit;
  end;

  CD_ROMdat (DrvCount, DrvName, IsMSCDEX, IsCDROM);
  IF (DrvCount <> 0) THEN BEGIN
    IF IsMSCDEX THEN sl2 (10,'i','MSCDEX v'+cstr(hi(CDR_VERSION))+'.'+cstr(lo(CDR_VERSION))+' detected');
    sl2 (10,'i','Physical CD-ROM drive(s) detected ('+cstr(DrvCount)+' Drive(s), First Drive: '+drvname+')');
    CDR_GET_DRIVE_UNITS(CDLIST);
    for tx:=0 to 25 do begin
        if (cdlist[tx]<>0) then begin
                tstr:=getvol(cdlist[tx]+1);
                z:=0;
                if (tstr<>'') then
                repeat
                begin
                        found:=false;
                        seek(cdf,z);
                        read(cdf,cds);
                        if not(cds.useunique) then begin
                                if allcaps(tstr)=allcaps(cds.volumeid) then 
                                begin
                                        cdavail[cdlist[tx]+1]:=filepos(cdf)-1;
                                        sl2(10,'i','Found CD-ROM - Drive '+chr(cdlist[tx]+65)+' : '+stripcolor(cds.name)+
                                        ' ('+cds.volumeid+')');
                                        found:=true;
                                end;
                        end;
                inc(z);
                end;
                until (z>filesize(cdf)-1) or (found);
        end;
    end;
    END; {IF DrvCount}
    CDI_GET_DRIVE_UNITS(CDLIST);
    for tx:=0 to 25 do begin
        if (cdlist[tx]<>0) then begin
                if (cdavail[cdlist[tx]+1]=0) then begin
                tstr:=getvol(cdlist[tx]+1);
                z:=0;
                if (tstr<>'') then
                repeat
                begin
                        found:=false;
                        seek(cdf,z);
                        read(cdf,cds);
                        if (cds.useunique) then begin
                                if exist(chr(cdlist[tx]+65)+':'+cds.uniquefile) then 
                                begin
                                        cdavail[cdlist[tx]+1]:=filepos(cdf)-1;
                                        sl2(10,'i','Found CD-ROM - Drive '+chr(cdlist[tx]+65)+' : '+stripcolor(cds.name)+
                                        ' ('+chr(cdlist[tx]+65)+':'+cds.uniquefile+')');
                                        found:=true;
                                end;
                        end else begin
                                if allcaps(tstr)=allcaps(cds.volumeid) then 
                                begin
                                        cdavail[cdlist[tx]+1]:=filepos(cdf)-1;
                                        sl2(10,'i','Found CD-ROM - Drive '+chr(cdlist[tx]+65)+' : '+stripcolor(cds.name)+
                                        ' ('+cds.volumeid+')');
                                        found:=true;
                                end;
                        end;
                inc(z);
                end;
                until (z>filesize(cdf)-1) or (found);
                end;
        end;
    end;
    close(cdf);
    assign(cdfile,adrv(systat^.gfilepath)+'CDS.MAP');
    {$I-} rewrite(cdfile,1); {$I+}
    if (ioresult<>0) then begin
        displaybox('Unable to create CD-ROM Map.',3000);
    end else begin
        blockwrite(cdfile,cdavail,sizeof(cdavail));
        close(cdfile);
    end;
END;

END {CDROM}.

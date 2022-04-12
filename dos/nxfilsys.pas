{----------------------------------------------------------------------------}
{ Nexus Bulletin Board System                                                }
{                                                                            }
{ All material contained herein is (c) Copyright 1996 Epoch Software.        }
{ All Rights Reserved.                                                       }
{                                                                            }
{ MODULE     :  NXFILSYS.PAS (Nexus File Database System)                    }
{ AUTHOR     :  George A. Roberts IV                                         }
{                                                                            }
{----------------------------------------------------------------------------}

{$A+,B+,D-,E+,F+,G-,I+,L-,N-,O-,R+,S+,V-}
unit nxFILSYS;

interface

uses common; 

TYPE nxFILEOBJ=Object
        FBopened:boolean;
        Initattempted:boolean;
        F:FILE;
        NKEY:INTEGER;
        NDESC:INTEGER;
        FPOS:SHORTINT;              { 0 : header  1: keyword  2:desc }
                                    { -1 : NOT READY }
        NFBPOS:LONGINT;
        FError:BOOLEAN;
        KWR,DLR:INTEGER;            { Keywords Read, and Desc Lines Read }
        NK,ND:LONGINT;              { File Position for Keywords and Desc }
                                    { in a new entry }
        Fheader:FheaderREC;
        Procedure Init(BasePath:STRING; NKW,NDL:INTEGER);
        Function  NumFiles:LONGINT;
        Procedure SeekFile(x:longint);
        Procedure ReadHeader;
        Procedure ReWriteHeader(Fh:Fheaderrec);
        Procedure KeywordStartup;
        Function  GetKeyword:STRING;
        Procedure DescStartup;
        Function  GetDescLine:STRING;
        Procedure AddNewFile(Fh:Fheaderrec);
        Function  AddKeyword(s:string):BOOLEAN;
        Function  AddDescLine(s:string):BOOLEAN;
        Function  SetDescLine(s:string; x:integer):BOOLEAN;
        Procedure DeleteFile(x:integer);
        Procedure Done;
     END;
        

implementation

Procedure nxFILEOBJ.Init(BasePath:STRING; NKW,NDL:INTEGER);
begin
Done;
initattempted:=TRUE;
FPOS:=-1;
DLR:=0;
KWR:=0;
NFBPOS:=0;
NKEY:=NKW;
NDESC:=NDL;
Ferror:=FALSE;
FBopened:=FALSE;
assign(f,BasePath);
filemode:=66;
{$I-} reset(f,1); {$I+}
if (ioresult=0) then begin
        if (filesize(f)<>0) then begin
                FBopened:=TRUE;
        end else begin
                close(f);
        end;
end;
end;

Function nxFILEOBJ.NumFiles:LONGINT;
var l:longint;
begin
if (Fbopened) then begin
        l:=filesize(f);
        NumFiles:=(l div (sizeof(Fheaderrec) + (NKEY * sizeof(FKeywordREC)) +
                (NDESC * sizeof(FDescREC))));
end else begin
        Numfiles:=0;
end;
end;

Procedure nxFILEOBJ.SeekFile(x:longint);
begin
FERROR:=FALSE;
if (Fbopened) and (x<=numfiles) then begin
        seek(f,((x - 1) * (sizeof(Fheaderrec) + (NKEY * sizeof(FKeywordREC)) +
               (NDESC * sizeof(FDescREC)))));
        NFBPOS:=filepos(f);
        FPOS:=0;
end else ferror:=TRUE;
end;

Procedure nxFILEOBJ.ReadHeader;
var numread:word;
begin
FERROR:=FALSE;
if (fbopened) and (FPOS=0) then begin
        blockread(f,Fheader,sizeof(Fheaderrec),numread);
        if (numread<>sizeof(Fheaderrec)) then begin
                FPOS:=-1;
                FERROR:=TRUE;
        end;
end;
end;

Procedure nxFILEOBJ.ReWriteHeader(Fh:Fheaderrec);
begin
if (Fbopened) then begin
        seek(f,NFBPOS);
        blockwrite(f,Fh,Sizeof(Fh));
end;
end;

Procedure nxFILEOBJ.KeywordStartup;
begin
if (Fbopened) and (FPOS=0) then begin
        seek(f,NFBPOS+sizeof(Fheaderrec));
        FPOS:=1;
        kwr:=0;
end;
end;

Function nxFILEOBJ.GetKeyword:STRING;
var kw:Fkeywordrec;
    numread:word;
begin
FERROR:=FALSE;
if (FbOpened) and (FPOS=1) then begin
        if (KWR=NKEY) or (NKEY=0) then begin
                GetKeyword:='';
        end else begin
        blockread(f,kw,sizeof(fkeywordrec),numread);
        if (numread<>sizeof(fkeywordrec)) then begin
                ferror:=TRUE;
                fpos:=-1;
        end else begin
                inc(KWR);
                if (kw.keyword='') then kwr:=nkey;
                GetKeyword:=kw.keyword;
        end;
        end;
end else begin
        GetKeyword:='';
end;
end;

Procedure nxFILEOBJ.DescStartup;
begin
if (Fbopened) and (FPOS>=0) then begin
        seek(f,NFBPOS+sizeof(Fheaderrec)+(NKEY * sizeof(FKeywordRec)));
        FPOS:=2;
        dlr:=0;
end;
end;

Function nxFILEOBJ.GetDescLine:STRING;
var kw:Fdescrec;
    numread:word;
begin
FERROR:=FALSE;
if (FbOpened) and (FPOS=2) then begin
        if (DLR=NDESC) or (NDESC=0) then begin
                GetDescLine:=#1+'EOF'+#1;
        end else begin
        blockread(f,kw,sizeof(fdescrec),numread);
        if (numread<>sizeof(fdescrec)) then begin
                ferror:=TRUE;
                fpos:=-1;
        end else begin
                inc(DLR);
                if (kw.description=#1+'EOF'+#1) then begin
                        dlr:=ndesc;
                        GetDescLine:=#1+'EOF'+#1;
                end else begin
                        GetDescLine:=kw.description;
                end;
        end;
        end;
end else begin
        GetDescLine:=#1+'EOF'+#1;
end;
end;

Procedure nxFILEOBJ.AddNewFile(Fh:Fheaderrec);
var kw:fkeywordrec;
    d:fdescrec;
    x,l:longint;
begin
if not(fbopened) and (initattempted) then begin
        rewrite(f,1);
        fbopened:=TRUE;
end;
if (Fbopened) then begin
        FPOS:=4;
        seek(f,filesize(f));
        blockwrite(f,fh,sizeof(fheaderrec));
        l:=filepos(f);
        DLR:=0;
        KWR:=0;
        fillchar(kw,sizeof(fkeywordrec),#0);
        kw.keyword:='';
        NK:=l;
        if (NKEY>0) then
        for x:=1 to NKEY do begin
                blockwrite(f,kw,sizeof(fkeywordrec));
        end;
        ND:=filepos(f);
        fillchar(d,sizeof(fdescrec),#0);
        d.description:=#1+'EOF'+#1;
        if (NDESC>0) then
        for x:=1 to NDESC do begin
                blockwrite(f,d,sizeof(fdescrec));
        end;
        seek(f,l);
end;
end;

Function nxFILEOBJ.AddKeyword(s:string):BOOLEAN;
var kw:Fkeywordrec;
begin
if (FBopened) and (FPOS=4) then begin
        if (KWR=NKEY) or (NKEY=0) then begin
                addkeyword:=FALSE;
        end else begin
                seek(f,NK+(kwr * sizeof(fkeywordrec)));
                inc(kwr);
                kw.keyword:=s;
                blockwrite(f,kw,sizeof(fkeywordrec));
                addkeyword:=TRUE;
        end;
end else addkeyword:=FALSE;
end;

Function nxFILEOBJ.AddDescLine(s:string):BOOLEAN;
var d:FDescRec;
begin
if (FBopened) and (FPOS=4) then begin
        if (DLR=NDESC) or (NDESC=0) then begin
                adddescline:=FALSE;
        end else begin
                seek(f,ND+(dlr * sizeof(fdescrec)));
                inc(dlr);
                d.description:=s;
                blockwrite(f,d,sizeof(fdescrec));
                adddescline:=TRUE;
        end;
end else adddescline:=FALSE;
end;

Function nxFILEOBJ.SetDescLine(s:string; x:integer):BOOLEAN;
var d:FDescRec;
begin
if (x>NDESC) or (NDESC=0) then exit;
if (FBopened) and (FPOS=2) then begin
        seek(f,NFBPOS+sizeof(Fheaderrec)+(NKEY * sizeof(FKeywordRec))+
                ((x-1) * sizeof(FDescRec)));
        d.description:=s;
        blockwrite(f,d,sizeof(fdescrec));
        setdescline:=TRUE;
end else setdescline:=FALSE;
end;

procedure nxFILEOBJ.DeleteFile(x:integer);
type oarray=ARRAY[1..128] of byte;
var ONFBPOS:longint;
    tmppos:longint;
    numread:word;
    optr:^oarray;
begin
ONFBPOS:=NFBPOS;
FERROR:=FALSE;
if (x=Numfiles) then begin
                seek(f,filesize(f)-((sizeof(Fheaderrec) + (NKEY * sizeof(FKeywordREC)) +
                (NDESC * sizeof(FDescREC)))));
                truncate(f);
                if (ONFBPOS>filesize(f)) then ONFBPOS:=0;
                if (filesize(f)=0) then done else begin
                        seek(f,ONFBPOS);
                        NFBPOS:=ONFBPOS;
                end;
end else begin
        seekfile(x+1);
        if not(FERROR) then begin
                new(optr);
                while not(eof(f)) do begin
                        blockread(f,optr^,sizeof(optr^),numread);
                        tmppos:=filepos(f);
                        seek(f,tmppos-(numread+((sizeof(Fheaderrec) + (NKEY * sizeof(FKeywordREC)) +
                        (NDESC * sizeof(FDescREC))))));
                        blockwrite(f,optr^,numread);
                        seek(f,tmppos);
                end;
                seek(f,filesize(f)-((sizeof(Fheaderrec) + (NKEY * sizeof(FKeywordREC)) +
                (NDESC * sizeof(FDescREC)))));
                truncate(f);
                if (ONFBPOS>filesize(f)) then ONFBPOS:=0;
                if (filesize(f)=0) then done else begin
                        seek(f,ONFBPOS);
                        NFBPOS:=ONFBPOS;
                end;
        end;
end;
end;

Procedure nxFILEOBJ.Done;
begin
if (FBopened) then begin
        {$I-} close(f); {$I+}
        if (ioresult<>0) then begin end;
        FBopened:=FALSE;
        initattempted:=FALSE;
end;
end;

end.

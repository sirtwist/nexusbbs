Unit V7Engine;      { Version 7 nodelist engine }

{

ver 1.0 - initial release


This is public domain by Joy Mukherjee.

This has been ported from the Binkley 2.50 source code which was written 
in C.  I am releasing this in to the public domain with no real 
restrictions, but if you choose to use this unit in your source code, 
please mention me!  I would certainly appreciate it, and I think it 
encourages other people to release code if you give due credit where 
credit is due.

}

{$V-}
{$X+}

interface

type
    Str8       = String [8];        { String - 8 char in length   }
    Str160     = String [160];      { String - 160 char in length }

{ A comparison function }

    CompProc   = function (var ALine, Desire; L : Char) : Integer;

    DATRec = record
        Zone,                       { Zone of board               }
        Net,                        { Net Address of board        }
        Node,                       { Node Address of board       }
        Point     : Integer;        { Either point number or 0    }
        CallCost,                   { Cost to sysop to send       }
        MsgFee,                     { Cost to user to send        }
        NodeFlags   : Word;         { Node flags                  }
        ModemType,                  { Modem type                  }
        PassWord    : String [9];
        Phone       : String [39];
        BName       : String [39];
        CName       : String [39];
        SName       : String [39];
        BaudRate    : Byte;         { Highest Baud Rate           }
        RecSize     : Byte;         { Size of the node on file    }
     end;


{ Make an address to search for }

function MakeAddress (Z,                { Zone  }
                      Nt,               { Net   }
                      N,                { Node  }
                      P     : Word)     { Point }
                            : Str160;   { A string value of info }

{ Format a name to search for }

function MakeName (Name : Str160)       { The name to search for }
                        : Str160;       { A string value of info }

{ Data pulled from the DAT file }

function GetData (var F1 : File; SL : LongInt; var DAT : DATRec) : Boolean;

{ Compare two names, DESIRE can be the first part of a last name if TOTAL
    is defined }

function CompName (var ALine, Desire; L : Char) : Integer;

{ Compare two string type addresses, no wild cards }

function CompAddress (var ALine, Desire; L : Char) : Integer;

{ This is the actual look up routine.  Send it an opened NDX file, a
    string to look for (MakeAddress, MakeName), and a comparision 
    procedure to use (CompAddress, CompName). }

function BTree (var F1      : File;     { Opened NDX file to use    }
                    Desired : Str160;   { What to search for        }
                    Compare : CompProc) { Procedure to compare keys }
                            : LongInt;  { Location in DAT file      }

{ Write a table type structure for the DATa }

procedure WriteDATInfo (var DAT : DATRec);

implementation

uses CRT;

type
    IndxRefBlk = record
            IndxOfs     : Word;     { Offset of string into block }
            IndxLen     : Word;     { Length of string            }
            IndxData    : LongInt;  { Record number of string     }
            IndxPtr     : LongInt;  { Block number of lower index }
         end;  { IndxRef }
    LeafRefBlk = record
            KeyOfs      : Word;     { Offset of string into block }
            KeyLen      : Word;     { Length of string            }
            KeyVal      : LongInt;  { Pointer to data block       }
         end;   { LeafRef }
    CtlBlk = record
        CtlBlkSize  : Word;         { Blocksize of Index Blocks   }
        CtlRoot,                    { Block number of Root        }
        CtlHiBlk,                   { Block number of last block  }
        CtlLoLeaf   : LongInt;      { Block number of first leaf  }
        CtlHiLeaf   : LongInt;      { Block number of last leaf   }
        CtlFree     : LongInt;      { Head of freelist            }
        CtlLvls     : Word;         { Number of index levels      }
        CtlParity   : Word;         { XOR of above fields         }
     end;
    INodeBlk = record
        IndxFirst   : LongInt;      { Pointer to next lower level }
        IndxBLink   : LongInt;      { Pointer to previous link    }
        IndxFLink   : LongInt;      { Pointer to next link        }
        IndxCnt     : Integer;      { Count of Items in block     }
        IndxStr     : Word;         { Offset in block of 1st str  }
                        { If IndxFirst is NOT -1, this is INode:  }
        IndxRef     : array [0..49] of IndxRefBlk;
     end;
    LNodeBlk = record
        IndxFirst   : LongInt;      { Pointer to next lower level }
        IndxBLink   : LongInt;      { Pointer to previous link    }
        IndxFLink   : LongInt;      { Pointer to next link        }
        IndxCnt     : Integer;      { Count of Items in block     }
        IndxStr     : Word;         { Offset in block of 1st str  }
        LeafRef     : array [0..49] of LeafRefBlk;
    end;

{ Put an address into string format }

function MakeAddress (Z, Nt, N, P : Word) : Str160;

type
    NodeType = record       { A node address type }
        Len   : Byte;
        Zone  : Word;
        Net   : Word;
        Node  : Word;
        Point : Word;
     end;

var
    Address : NodeType;
    S2      : Str160 absolute Address;

begin
    With Address do
        begin
            Zone := Z;
            Net := Nt;
            Node := N;
            Point := P;
            Len := 8;
         end;
    MakeAddress := S2;
end;

{ put a string into lower case }

function Lower (Str : String) : String;

var
  I : Integer;

begin
    for I := 1 to Length (Str) do
        If Ord (Str [I]) in [65..90] then
           Str [I] := Chr (Ord (Str [I]) + 32);
    Lower := Str;
end;  {Func Lower}

{ Change a name to a more formal looking string,
    i.e.  JOY MUKHERJEE -> Joy Mukherjee }

function Proper (Str : String) : String;

var
  I     : Integer;
  Space : Boolean;

begin
    Space := True;
    Str := Lower (Str);
    for I := 1 to Length (Str) do
        If Space and (Ord (Str [I]) in [97..122]) then
            begin
                Space := False;
                Str[I] := Upcase (Str [I]);
            end
        else
            If (Space = False) and (Str[I] = ' ') then
                Space := True;
    Proper := Str;
end;

{ Make a name into nodelist looking format.
    i.e. Joy Mukherjee -> Mukherjee, Joy    }

function MakeName (Name : Str160) : Str160;

var
    Temp  : Str160;
    Comma : String [2];

begin
    Temp := Proper (Name);
    If Pos (' ', Name) > 0 then Comma := ', ' else Comma := '';
    MakeName := Copy (Temp, Pos (' ', Temp) + 1, Length (Temp) - Pos (' ', Temp))
                + Comma + Copy (Temp, 1, Pos (' ', Temp) - 1) + #0;
end;

{ Uncompress a name, city, state, sysop in the V7 nodelist }

procedure UnPk (S1 : Str160; var S2 : Str160; Count : Byte);

const
    UnWrk : array [0..38] of Char = ' EANROSTILCHBDMUGPKYWFVJXZQ-''0123456789';

type
    CharType = record
        C1, C2 : Byte;
     end;

var
    U       : CharType;
    W1      : Word absolute U;
    I, J    : Integer;
    OBuf    : array [0..2] of Char;
    Loc1,
    Loc2    : Byte;

begin
    S2 := '';
    Loc1 := 1;
    Loc2 := 1;
    While Count > 0 do
        begin
            U.C1 := Ord (S1 [Loc1]);
            Inc (Loc1);
            U.C2 := Ord (S1 [Loc1]);
            Inc (Loc1);
            Count := Count - 2;
            for J := 2 downto 0 do
                begin
                    I := W1 MOD 40;
                    W1 := W1 DIV 40;
                    OBuf [J] := UnWrk [I];
                 end;
            Move (OBuf, S2 [Loc2], 3);
            Inc (Loc2, 3);
        end;
    S2 [0] := Chr (Loc2);
end;

{ Get the data from the file }

function GetData (var F1 : File; SL : LongInt; var DAT : DATRec) : Boolean;

type
    RealDATRec = record
        Zone,                       { Zone of board               }
        Net,                        { Net Address of board        }
        Node,                       { Node Address of board       }
        Point     : Integer;        { Either point number or 0    }
        CallCost,                   { Cost to sysop to send       }
        MsgFee,                     { Cost to user to send        }
        NodeFlags   : Word;         { Node flags                  }
        ModemType,                  { Modem type                  }
        PhoneLen,                   { Length of Phone Number      }
        PassWordLen,                { Length of Password          }
        BNameLen,                   { Length of Board Name        }
        SNameLen,                   { Length of Sysop Name        }
        CNameLen,                   { Length of City/State Name   }
        PackLen,                    { Length of Packed String     }
        Baud        : Byte;         { Highest Baud Rate           }
        Pack        : array [1..160]
                        of Char;    { The Packed String           }
     end;

var
    DATA    : RealDATRec;
    Error   : Boolean;
    UnPack  : Str160;

begin
    Seek (F1, SL);
        {$I-}

{ Read everything at once to keep disk access to a minimum }

    BlockRead (F1, DATA, SizeOf (DATA));
        {$I+}
    Error := IOResult <> 0;

    If Not Error then
        With DAT, DATA do
          begin
            Move (DATA, DAT, 15);
            Phone := Copy (Pack, 1, PhoneLen);
            PassWord  := Copy (Pack, PhoneLen + 1, PasswordLen);
            Move (Pack [PhoneLen + PasswordLen + 1], Pack [1], PackLen);
            UnPk (Pack, UnPack, PackLen);
            BName := Copy (UnPack, 1, BNameLen);
            SName := Copy (Unpack, BNameLen + 1, SNameLen);
            CName := Copy (UnPack, BNameLen + SNameLen + 1, CNameLen);
            BaudRate := Baud;
            RecSize := (PhoneLen + PassWordLen + PackLen) + 22;
          end;
end;

{ Pull a node from the nodelist }

procedure Get7Node (var F         : File;
                        SL        : LongInt;
                    var Buf);

begin
    Seek (F, SL);
        {$I-}
    BlockRead (F, Buf, 512);
        {$I+}
    If IOResult <> 0 then Halt (1);
end;


{$F+}

function CompName (var ALine, Desire; L : Char) : Integer;

var
    Key     : Str160;
    Desired : Str160;
    Len     : Byte absolute L;

begin
    Key [0] := L;
    Desired [0] := L;
    Move (ALine, Key [1], Len);
    Move (Desire, Desired [1], Len);
    If Key > Desired then CompName := 1
        else If Key < Desired then CompName := -1
            else CompName := 0;
end;


{
 From : KEVIN PARADINE              1:107/480               24 May 92  12:21:00
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
}

function CompAddress (var ALine, Desire; L : Char) : Integer;

type
    NodeType = record
        Zone  : Word;
        Net   : Word;
        Node  : Word;
        Point : Word;
     end;

var
    Key     : NodeType absolute ALine;
    Desired : NodeType absolute Desire;
    Count   : Byte;
    K       : Integer;

begin
    Count := 0;
    repeat
        Inc (Count);
        Case Count of
            1 : Word (K) := Key.Zone - Desired.Zone;
            2 : Word (K) := Key.Net  - Desired.Net;
            3 : Word (K) := Key.Node - Desired.Node;
            4 : begin
                    If L = #6 then Key.Point := 0;
                    Word (K) := Key.Point - Desired.Point;
                 end;
         end;  { Case }
    until (Count = 4) or (K <> 0);
    CompAddress := K;
end;

{$F-}

function BTree (var F1 : File; Desired : Str160; Compare : CompProc) : LongInt;

label Return;

var
    Buf     : array [0..511] of Char;   { These four variables all occupy   }
    CTL     : CTLBlk absolute Buf;      { the same memory location.  Total  }
    INode   : INodeBlk absolute Buf;    { of 512 bytes.                     }
    LNode   : LNodeBlk absolute Buf;    { --------------------------------- }

    NodeCTL : CTLBlk;                   { Store the CTL block seperately    }
    J, K, L : Integer;                  { Temp integers                     }
    Count   : Integer;                  { The counter for the index in node }
    ALine   : Str160;                   { Address from NDX file             }
    TP      : Word;                     { Pointer to location in BUF        }
    Rec     : LongInt;                  { A temp record in the file         }
    FRec    : LongInt;                  { The record when found or not      }

begin

{
 * FRec will be our found record, or a -1 indicating no found!  Assume
     it doesn't exist
}

    FRec := -1;

{ Read Control Block }

    Get7Node (F1, 0, Buf);
    If CTL.CTLBlkSize = 0 then goto Return;

    Move (Buf, NodeCTL, SizeOf (CTL));

{ Read the first Index Node }

    Get7Node (F1, NodeCTL.CtlRoot * NodeCTL.CtlBlkSize, Buf);

{
 * Follow the node tree until we either match a key right in the index
 * node, or locate the leaf node which must contain the entry.
}
    
    While (INode.IndxFirst <> -1) and (FRec = -1) do
        begin
            Count := INode.IndxCnt;
            If Count = 0 then goto Return;

{ Search the keys of the BTRee.  Initial K to a value less than 0, so we 
    get in loop }

            J := 0;
            K := -1;
            While (J < Count) and (K < 0) do
                begin

{ TP is our pointer to node address in Buf,
  L  is the length of the adress,
  ALine is the string version of the node address }

                    TP := INode.IndxRef [J].IndxOfs;
                    L := INode.IndxRef [J].IndxLen;
{                    ALine [0] := Chr (L);}
                    Move (Buf [TP], ALine [1], L);

{ K is a number which determines whether or not we go down the tree, or 
    to the side.

 If K = 0 - we found the address
 If K > 0 - go down the tree
 If K < 0 - move to right (i.e. Increment J) until K >= 0 }

                    K := Compare (ALine [1], Desired [1], Chr (L));
                    If K = 0 then FRec := INode.IndxRef [J].IndxData
                        else If K < 0 then Inc (J);
                 end;

{ If we haven't found our address, move down the tree somewhere.  Either 
to the left (J = 0) or to the right (J <> 0).  Reload our record }

                 If (FRec = -1) then
                    begin
                        If J = 0 then Rec := INode.IndxFirst
                            else Rec := INode.IndxRef [J - 1].IndxPtr;
                        Get7Node (F1, Rec * NodeCTL.CtlBlkSize, Buf);
                     end;
             end;

{ Have we found our stinking node yet??  If not, we are at a LEAF node, 
    which means we find it here or the thing does not exist! }

    If (FRec = -1) then
        begin
            Count := LNode.IndxCnt;
            If (Count <> 0) then
                begin

                    { Search for a higher key }

                    J := 0;
                    While (J < Count) and (FRec = -1) do
                        begin

{ TP is our pointer to node address in Buf,
  L  is the length of the adress,
  ALine is the string version of the node address }

                            TP := LNode.LeafRef [J].KeyOfs;
                            L := LNode.LeafRef [J].KeyLen;
{                            ALine [0] := Chr (L);}
                            Move (Buf [TP], ALine [1], L);

{ K is a number which determines whether or not we go down the tree, or
    to the side.

 If K = 0 - we found the address
 If K < 0 - move to right (i.e. Increment J) until K >= 0 }

                            K := Compare (ALine [1], Desired [1], Chr (L));
                            If K = 0 then FRec := LNode.LeafRef [J].KeyVal;
                            Inc (J);
                         end;  { While }
                    end;  { If }
            end;  { If }
Return :

    BTree := FRec;
end;

procedure WriteDATInfo (var DAT : DATRec);

var
    Pass    : String [9];
    Unpack  : Str160;
    Phone   : String [40];

begin
    With DAT do
        begin
            Writeln ('Address        : ', Zone, ':', Net, '/', Node, '.', Point);
            Writeln ('Cost           : ', CallCost);
            Writeln ('Baud           : ', BaudRate * 300);
            Writeln ('Board Name     : ', BName);
            Writeln ('Sysop Name     : ', SName);
            Writeln ('City and State : ', CName);
            Writeln ('Phone          : ', Phone);
            Writeln ('Password       : ', Password);
         end;
end;

end.

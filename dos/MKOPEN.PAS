{$A+,B+,D-,E+,F+,I+,L+,N-,O+,R+,S+,V-}
Unit MKOpen; {Open a message area using an MsgAreaId}

{$I-}
{$V-}
{$S+}
{$F+}
{$R-}

Interface

Uses MKMsgAbs;

Function OpenMsgArea(Var Msg: AbsMsgPtr; MsgAreaId: String): Boolean;
Function OpenOrCreateMsgArea(Var Msg: AbsMsgPtr; MsgAreaId: String): Boolean;
Function CloseMsgArea(Var Msg: AbsMsgPtr): Boolean;
Function InitMsgPtr(Var Msg: AbsMsgPtr; MsgAreaId: String): Boolean;
Function DoneMsgPtr(Var Msg: AbsMsgPtr): Boolean;

Implementation


Uses MKMsgFid, MKMsgSqu, MKMsgJam;

{ Area ids begin with identifier for msg base type }
{ The following characters are already reserved    }
{   B = PC-Board            }
{   E = Ezycomm             }
{   F = Fido *.Msg          }
{   H = Hudson              }
{   I = ISR - msg fossil    }
{   J = JAM                 }
{   M = MK                  }
{   P = *.PKT               }
{   Q = QWK/REP             }
{   S = Squish              }
{   W = Wildcat             }


Function OpenMsgArea(Var Msg: AbsMsgPtr; MsgAreaId: String): Boolean;
  Begin
  If InitMsgPtr(Msg, MsgAreaId) Then
    Begin
    OpenMsgArea := True;
    If Msg^.OpenMsgBase <> 0 Then
      Begin
      OpenMsgArea := False;
      If DoneMsgPtr(Msg) Then;
      End;
    End
  Else
    OpenMsgArea := False;
  End;


Function OpenOrCreateMsgArea(Var Msg: AbsMsgPtr; MsgAreaId: String): Boolean;
var tmp:boolean;
  Begin
  tmp:=FALSE;
  If InitMsgPtr(Msg, MsgAreaId) Then
    Begin
    tmp := True;
    If Not Msg^.MsgBaseExists Then begin
      If Not Msg^.CreateMsgBase(200, 10) = 0 Then begin
        tmp := False;
        end;
    end;
    if (tmp) then
    If Msg^.OpenMsgBase <> 0 Then
      Begin
      tmp := False;
      If DoneMsgPtr(Msg) Then;
      End;
    End;
    openorcreatemsgarea:=tmp;
  End;


Function CloseMsgArea(Var Msg: AbsMsgPtr): Boolean;
  Begin
  If Msg <> Nil Then
    Begin
    CloseMsgArea := (Msg^.CloseMsgBase = 0);
    If DoneMsgPtr(Msg) Then;
    End
  Else
    CloseMsgArea := False;
  End;


Function InitMsgPtr(Var Msg: AbsMsgPtr; MsgAreaId: String): Boolean;
  Begin
  Msg := Nil;
  InitMsgPtr := TRUE;
  Case UpCase(MsgAreaId[1]) of
    'S': Msg := New(SqMsgPtr, Init);
    'F': Msg := New(FidoMsgPtr, Init);
    'J': Msg := New(JamMsgPtr, Init);
    Else
      InitMsgPtr := False;
    End;
  If (Msg <> Nil) Then
    Msg^.SetMsgPath(Copy(MsgAreaId, 2, 128))
  else initmsgptr:=FALSE;
  End;


Function DoneMsgPtr(Var Msg: AbsMsgPtr): Boolean;
  Begin
  If Msg <> Nil Then
    Dispose(Msg, Done);
  Msg := Nil;
  End;

End.

(*****************************************************************************)
(*                                                                           *)
(*           The Blue Wave Offline Mail System Packet Structures             *)
(*   Copyright 1990-1995 by Cutting Edge Computing.  All rights reserved.    *)
(*                        Created by George Hatchew                          *)
(*                                                                           *)
(*                      Version 3 - November 30, 1995                        *)
(*                                                                           *)
(*        ---------------------------------------------------------          *)
(*            DISTRIBUTION OF THIS FILE IS LIMITED BY THE TERMS              *)
(*           SPECIFIED IN THE BLUE WAVE STRUCTURE DOCUMENTATION!             *)
(*        ---------------------------------------------------------          *)
(*                                                                           *)
(*   NOTE:  Refer to BLUEWAVE.H and the Blue Wave structure documentation    *)
(*          for additional comments and information.                         *)
(*                                                                           *)
(*****************************************************************************)

const
  PACKET_LEVEL            = 3;      (* Mail packet revision level  *)
  ORIGINAL_INF_HEADER_LEN = 1230;   (* Original *.INF header len   *)
  ORIGINAL_INF_AREA_LEN   = 80;     (* Original *.INF area rec len *)
  ORIGINAL_MIX_STRUCT_LEN = 14;     (* Original *.MIX record len   *)
  ORIGINAL_FTI_STRUCT_LEN = 186;    (* Original *.FTI record len   *)

(*---------------------------------------------------------------------------*)

(*  Bit-masks for INF_HEADER.UFLAGS field  *)

type
  inf_hdr_uflags =
  (
    INF_HOTKEYS     ,           (* User uses "hotkeys" in door prompts   *)
    INF_XPERT       ,           (* Short menus displayed in door         *)
    INF_UFLAGS_RES1 ,           (* RESERVED -- DO NOT USE!               *)
    INF_GRAPHICS    ,           (* Enable ANSI control sequences in door *)
    INF_NOT_MY_MAIL ,           (* Do not bundle mail from user          *)
    INF_EXT_INFO    ,           (* Download extended info with messages  *)
                                (*   (VERSION 3 AND LATER ONLY)          *)
    INF_NUMERIC_EXT ,           (* Use numeric extensions on packets     *)
                                (*   (VERSION 3 AND LATER ONLY)          *)
    INF_UFLAGS_RES2 ,           (* RESERVED -- DO NOT USE!               *)
    INF_UFLAGS_RES3 ,           (* RESERVED -- DO NOT USE!               *)
    INF_UFLAGS_RES4 ,           (* RESERVED -- DO NOT USE!               *)
    INF_UFLAGS_RES5 ,           (* RESERVED -- DO NOT USE!               *)
    INF_UFLAGS_RES6 ,           (* RESERVED -- DO NOT USE!               *)
    INF_UFLAGS_RES7 ,           (* RESERVED -- DO NOT USE!               *)
    INF_UFLAGS_RES8 ,           (* RESERVED -- DO NOT USE!               *)
    INF_UFLAGS_RES9 ,           (* RESERVED -- DO NOT USE!               *)
    INF_UFLAGS_RES10            (* RESERVED -- DO NOT USE!               *)
  );

(*  Bit-masks for INF_HEADER.NETMAIL_FLAGS field  *)

type
  inf_hdr_netmail =
  (
    INF_NETMAIL_RES1,           (* RESERVED -- DO NOT USE!     *)
    INF_CAN_CRASH   ,           (* Allow Crash status          *)
    INF_NETMAIL_RES2,           (* RESERVED -- DO NOT USE!     *)
    INF_NETMAIL_RES3,           (* RESERVED -- DO NOT USE!     *)
    INF_CAN_ATTACH  ,           (* Allow File Attach messages  *)
    INF_NETMAIL_RES4,           (* RESERVED -- DO NOT USE!     *)
    INF_NETMAIL_RES5,           (* RESERVED -- DO NOT USE!     *)
    INF_CAN_KSENT   ,           (* Allow Kill/Sent status      *)
    INF_NETMAIL_RES6,           (* RESERVED -- DO NOT USE!     *)
    INF_CAN_HOLD    ,           (* Allow Hold status           *)
    INF_CAN_IMM     ,           (* Allow Immediate status      *)
    INF_CAN_FREQ    ,           (* Allow File Request messages *)
    INF_CAN_DIRECT  ,           (* Allow Direct status         *)
    INF_NETMAIL_RES7,           (* RESERVED -- DO NOT USE!     *)
    INF_NETMAIL_RES8,           (* RESERVED -- DO NOT USE!     *)
    INF_NETMAIL_RES9            (* RESERVED -- DO NOT USE!     *)
  );

(*  Bit-masks for INF_HEADER.CTRL_FLAGS field  *)

type
  inf_hdr_ctrl =
  (
    INF_NO_CONFIG ,             (* Do not allow offline configuration *)
    INF_NO_FREQ   ,             (* Do not allow file requesting       *)
    INF_CTRL_RES1 ,             (* RESERVED -- DO NOT USE!            *)
    INF_CTRL_RES2 ,             (* RESERVED -- DO NOT USE!            *)
    INF_CTRL_RES3 ,             (* RESERVED -- DO NOT USE!            *)
    INF_CTRL_RES4 ,             (* RESERVED -- DO NOT USE!            *)
    INF_CTRL_RES5 ,             (* RESERVED -- DO NOT USE!            *)
    INF_CTRL_RES6 ,             (* RESERVED -- DO NOT USE!            *)
    INF_CTRL_RES7 ,             (* RESERVED -- DO NOT USE!            *)
    INF_CTRL_RES8 ,             (* RESERVED -- DO NOT USE!            *)
    INF_CTRL_RES9 ,             (* RESERVED -- DO NOT USE!            *)
    INF_CTRL_RES10,             (* RESERVED -- DO NOT USE!            *)
    INF_CTRL_RES11,             (* RESERVED -- DO NOT USE!            *)
    INF_CTRL_RES12,             (* RESERVED -- DO NOT USE!            *)
    INF_CTRL_RES13,             (* RESERVED -- DO NOT USE!            *)
    INF_CTRL_RES14              (* RESERVED -- DO NOT USE!            *)
  );

(*  Values for INF_HEADER.FILE_LIST_TYPE field  *)

const
  INF_FLIST_NONE = 0;           (* Door does not generate a list file  *)
  INF_FLIST_TEXT = 1;           (* Door generates plain text list file *)
  INF_FLIST_ANSI = 2;           (* Door generates ANSI list file       *)

type
  INF_HEADER =
  record
    ver:byte;                   (* Packet version type (currently 2)        *)
    readerfiles:                (* Files to be displayed by reader          *)
      array[1..5] of
      array[1..13] of byte;
    regnum:                     (* User's registration number               *)
      array[1..9] of byte;
    mashtype:byte;              (* Currently unused (door fills with 0)     *)
                                (*   Reserved for Blue Wave reader to store *)
                                (*   the compression type the packet uses.  *)
    loginname:                  (* Name user types at BBS login             *)
      array[1..43] of byte;
    aliasname:                  (* User's "other" name                      *)
      array[1..43] of byte;
    password:                   (* Password                                 *)
      array[1..21] of byte;     (*   All bytes should be the actually ASCII *)
                                (*   value plus 10.  Lame security, yes,    *)
                                (*   but it does prevent "TYPE *.INF" from  *)
                                (*   showing the password.                  *)
    passtype:byte;              (* Password type                            *)
                                (*   0=none 1=door 2=reader 3=both          *)
    zone:word;                  (* Main network address of host BBS         *)
    net:word;                   (*   (zone:net/node.point)                  *)
    node:word;
    point:word;
    sysop:                      (* Name of SysOp of host BBS                *)
      array[1..41] of byte;
    ctrl_flags:                 (* Flags to control reader capabilities     *)
      set of inf_hdr_ctrl;      (*   (VERSION 3 AND LATER ONLY)             *)
    systemname:                 (* Name of host BBS                         *)
      array[1..65] of byte;
    maxfreqs:byte;              (* Max number of file requests allowed      *)
    is_QWK:word;                (* Whether *.INF belongs to a QWK packet    *)
    obsolete2:                  (* OBSOLETE -- DO NOT USE!                  *)
      array[1..4] of byte;
    uflags:                     (* Bit-mapped door options/toggles          *)
      set of inf_hdr_uflags;
    keywords:                   (* User's entire set of door keywords       *)
      array[1..10] of
      array[1..21] of byte;
    filters:                    (* User's entire set of door filters        *)
      array[1..10] of
      array[1..21] of byte;
    macros:                     (* User's door bundling command macros      *)
      array[1..3] of
      array[1..80] of byte;
    netmail_flags:              (* Bit-mapped NetMail options               *)
      set of inf_hdr_netmail;
    credits:word;               (* NetMail credits                          *)
    debits:word;                (* NetMail debits                           *)
    can_forward:boolean;        (* 0=Message forwarding not allowed         *)
    inf_header_len:word;        (* Size of INF_HEADER structure             *)
    inf_areainfo_len:word;      (* Size of INF_AREA_INFO structure          *)
    mix_structlen:word;         (* Size of MIX_REC structure                *)
    fti_structlen:word;         (* Size of FTI_REC structure                *)
    uses_upl_file:boolean;      (* If this field is not zero, the door that *)
                                (*   created this packet can receive reply  *)
                                (*   packets in the new *.UPL file format.  *)
                                (*   Otherwise, the old *.UPI and *.NET     *)
                                (*   files must be used.                    *)
    from_to_len:byte;           (* The maximum length of the FROM: and TO:  *)
                                (*   fields that the host BBS can support.  *)
                                (*   If this value is 0 or is greater than  *)
                                (*   35, then 35 must be used (the upload   *)
                                (*   file formats only allow for a maximum  *)
                                (*   of 35 characters).                     *)
    subject_len:byte;           (* The maximum length of the SUBJECT: field *)
                                (*   that the host BBS can support.  If     *)
                                (*   this value is 0 or is greater than 71, *)
                                (*   then 71 must be used (the upload file  *)
                                (*   formats only allow for a maximum of 71 *)
                                (*   characters).                           *)
    packet_id:                  (* Original root name of the mail packet,   *)
      array[1..9] of byte;      (*   as specified by the mail door.  All    *)
                                (*   files in the packet that are created   *)
                                (*   by the mail door will use this root    *)
                                (*   name, as will the reader when creating *)
                                (*   the upload files.  Thus, even if the   *)
                                (*   packets themselves are renamed to      *)
                                (*   something completely different, the    *)
                                (*   mail doors and readers will still be   *)
                                (*   able to work with the proper files.    *)
    file_list_type:byte;        (* New file listing type                    *)
                                (* (VERSION 3 AND LATER ONLY)               *)
                                (*   Specifies the type of new file list    *)
                                (*   that is generated by the door (see     *)
                                (*   INF_FLIST_xxx, above).  This field is  *)
                                (*   intended for use with offline config.  *)
    auto_macro:                 (* Auto-macro indicator flags               *)
      array[1..3] of boolean;   (* (VERSION 3 AND LATER ONLY)               *)
                                (*   Specifies which macros are auto macros *)
                                (*   (i.e. execute automatically after mail *)
                                (*   is scanned).                           *)
    max_packet_size:integer;    (* Maximum size of uncompressed packet      *)
                                (* (VERSION 3 AND LATER ONLY)               *)
                                (*   Specifies, in K, the maximum size of   *)
                                (*   an uncompressed mail packet.  A value  *)
                                (*   of 0 indicates no maximum length.      *)
                                (*   This field is intended for use with    *)
                                (*   offline config.                        *)
    reserved:                   (* RESERVED FOR FUTURE USE                  *)
      array[1..228] of byte;    (*   This field MUST be filled with ASCII   *)
                                (*   NUL (0x00) characters in order for     *)
                                (*   future additional features to work     *)
                                (*   properly!                              *)
  end;

(*---------------------------------------------------------------------------*)

(*  Bit-masks for INF_AREA_INFO.AREA_FLAGS field  *)

type
  inf_area_flags =
  (
    INF_SCANNING       ,        (* On=User is active for area               *)
    INF_ALIAS_NAME     ,        (* On=Alias name, Off=Login name            *)
                                (*   If ON, use INF_HEADER.ALIASNAME when   *)
                                (*   addressing new mail or replies for the *)
                                (*   message area.  If OFF, the reader uses *)
                                (*   the INF_HEADER.LOGINNAME for this      *)
                                (*   purpose.                               *)
    INF_ANY_NAME       ,        (* On=Allow any name to be entered          *)
                                (*   If ON, any name can be entered in the  *)
                                (*   From: field when addressing new mail   *)
                                (*   or replies for the message area.  If   *)
                                (*   OFF, the normal rules apply.           *)
    INF_ECHO           ,        (* On=Network mail, Off=Local mail          *)
    INF_NETMAIL        ,        (* On=E-mail, Off=Conference mail           *)
                                (*   Refer to the chart below (the values   *)
                                (*   for the NETWORK_TYPE field) for info   *)
                                (*   on how these two flags should be set   *)
                                (*   for message areas.                     *)
    INF_POST           ,        (* On=User can post, Off=User CANNOT post   *)
    INF_NO_PRIVATE     ,        (* On=Private messages are NOT allowed      *)
    INF_NO_PUBLIC      ,        (* On=Public messages are NOT allowed       *)
    INF_NO_TAGLINE     ,        (* On=Taglines are not allowed              *)
    INF_NO_HIGHBIT     ,        (* On=ASCII 1-127 only, Off=ASCII 1-255     *)
                                (*   If ON, only ASCII values 1 to 127 are  *)
                                (*   allowed in messages.  If OFF, all      *)
                                (*   values from 1 to 255 are allowed.  Due *)
                                (*   to the fact that ASCII value 0 is used *)
                                (*   in C as a string terminator, the value *)
                                (*   0 should not be allowed in messages at *)
                                (*   all.                                   *)
    INF_NOECHO         ,        (* On=User can prevent messages from being  *)
                                (*   sent through the network               *)
    INF_HASFILE        ,        (* On=User can attach files to messages     *)
    INF_PERSONAL       ,        (* On=User is downloading only personal     *)
                                (*   msgs in this message area.  The flag   *)
                                (*   INF_SCANNING also needs to be ON.      *)
                                (*   (VERSION 3 AND LATER ONLY)             *)
    INF_TO_ALL         ,        (* On=User is downloading messages to "All" *)
                                (*   and personal messages only in this     *)
                                (*   area.  The flag INF_SCANNING also      *)
                                (*   needs to be ON.  INF_PERSONAL should   *)
                                (*   *not* be set, as this flag implies the *)
                                (*   downloading of personal messages also. *)
                                (*   (VERSION 3 AND LATER ONLY)             *)
    INF_AREA_FLAGS_RES1,        (* RESERVED -- DO NOT USE!                  *)
    INF_AREA_FLAGS_RES2         (* RESERVED -- DO NOT USE!                  *)
  );

(*  Values for INF_AREA_INFO.NETWORK_TYPE field  *)

const
  INF_NET_FIDONET  = 0;         (* FidoNet-style E-mail and conferences     *)
                                (*   Local     = INF_ECHO=off, NETMAIL=off  *)
                                (*   EchoMail  = INF_ECHO=on,  NETMAIL=off  *)
                                (*   GroupMail = INF_ECHO=on,  NETMAIL=off  *)
                                (*   NetMail   = INF_ECHO=on,  NETMAIL=on   *)
  INF_NET_INTERNET = 1;         (* Internet E-mail and Usenet newsgroups    *)
                                (*   Local     = INF_ECHO=off, NETMAIL=off  *)
                                (*   Newsgroup = INF_ECHO=on,  NETMAIL=off  *)
                                (*   E-mail    = INF_ECHO=on,  NETMAIL=on   *)

type
  INF_AREA_INFO =
  record
    areanum:                    (* Area number this record corresponds to  *)
      array[1..6] of byte;
    echotag:                    (* Area tag name (*.BRD name for Telegard) *)
      array[1..21] of byte;
    title:                      (* Area description/title                  *)
      array[1..50] of byte;
    area_flags:                 (* Bit-mapped area options                 *)
      set of inf_area_flags;
    network_type:byte;          (* Network mail type (see above)           *)
  end;

(*---------------------------------------------------------------------------*)

type
  MIX_REC =
  record
    areanum:                (* Area number this record corresponds to        *)
      array[1..6] of byte;  (*   This is the ASCII representation of the     *)
                            (*   actual area number shown on the host BBS.   *)
    totmsgs:word;           (* Total number of messages for this area        *)
    numpers:word;           (* Total number of personal messages in area     *)
    msghptr:longint;        (* Pointer to first message header in *.FTI file *)
  end;

(*---------------------------------------------------------------------------*)

(*  Bit-masks for FTI_REC.FLAGS field  *)

type
  fti_rec_flags =
  (
    FTI_MSGPRIVATE  ,           (* Private = For addressee ONLY         *)
    FTI_MSGCRASH    ,           (* Crash = High priority mail           *)
    FTI_MSGREAD     ,           (* Read = Message read by addressee     *)
    FTI_MSGSENT     ,           (* Sent = Message sent                  *)
    FTI_MSGFILE     ,           (* File Attach = Send file(s)           *)
    FTI_MSGFWD      ,           (* Forward = Message to/from others     *)
    FTI_MSGORPHAN   ,           (* Orphan = Message destination unknown *)
    FTI_MSGKILL     ,           (* Kill/Sent = Delete after sending     *)
    FTI_MSGLOCAL    ,           (* Local = Message originated here      *)
    FTI_MSGHOLD     ,           (* Hold = Hold for pickup, don't send   *)
    FTI_MSGIMMEDIATE,           (* Immediate = Send message NOW         *)
    FTI_MSGFRQ      ,           (* File Request = Request file(s)       *)
    FTI_MSGDIRECT   ,           (* Direct = Send direct, no routing     *)
    FTI_MSGUNUSED1  ,           (*                                      *)
    FTI_MSGUNUSED2  ,           (*                                      *)
    FTI_MSGURQ                  (* Update Request = Req updated file(s) *)
  );

type
  FTI_REC =
  record
    mfrom:                  (* Person message is from                       *)
      array[1..36] of byte;
    mto:                    (* Person message is to                         *)
      array[1..36] of byte;
    subject:                (* Subject/title of message                     *)
      array[1..72] of byte;
    date:                   (* Origin date of message                       *)
      array[1..20] of byte; (*   Depending on the host BBS's date storage   *)
                            (*   format, the EXACT format of this field     *)
                            (*   will change.  Some will take all 19 bytes, *)
                            (*   others may take only 10.                   *)
    msgnum:word;            (* Number of THIS message on BBS                *)
    replyto:word;           (* "This is a reply to #xx"                     *)
                            (*   Not used for every message.  When non-     *)
                            (*   zero, there is a previous message in       *)
                            (*   the thread.                                *)
    replyat:word;           (* "There is a reply at #xx"                    *)
                            (*   Not used for every message.  When non-     *)
                            (*   zero, there is a reply to this message.    *)
    msgptr:longint;         (* Offset to start of message in *.DAT file     *)
                            (*   Seek to this exact offset in the *.DAT     *)
                            (*   file, then read "msglength" bytes from     *)
                            (*   the file to load the entire message text.  *)
    msglength:longint;      (* Length of message text (in bytes)            *)
    flags:                  (* Bit-mapped message status flags              *)
      set of fti_rec_flags;
    orig_zone:word;         (* Origin address of message                    *)
                            (*   These three fields will most likely be 0,  *)
                            (*   unless the current message belongs to a    *)
                            (*   NetMail message base.                      *)
    orig_net:word;
    orig_node:word;
  end;

(*---------------------------------------------------------------------------*)

(*  Bit-masks for MSG_REC.ATTR field  *)

type
  msg_rec_attr =
  (
    MSG_NET_PRIVATE  ,          (* Private                *)
    MSG_NET_CRASH    ,          (* Crash mail             *)
    MSG_NET_RECEIVED ,          (* Received               *)
    MSG_NET_SENT     ,          (* Sent                   *)
    MSG_NET_FATTACH  ,          (* File attached          *)
    MSG_NET_INTRANSIT,          (* In-transit             *)
    MSG_NET_ORPHAN   ,          (* Orphaned               *)
    MSG_NET_KILL     ,          (* Kill after sending     *)
    MSG_NET_LOCAL    ,          (* Local message          *)
    MSG_NET_HOLD     ,          (* Hold for pickup        *)
    MSG_NET_RESERVED ,          (* RESERVED               *)
    MSG_NET_FREQ     ,          (* File request           *)
    MSG_NET_RREQ     ,          (* Return receipt request *)
    MSG_NET_RECEIPT  ,          (* Return receipt message *)
    MSG_NET_AREQ     ,          (* Audit request          *)
    MSG_NET_FUREQ               (* File update request    *)
  );

type
  MSG_REC =
  record
    mfrom:              (* Person message is from                           *)
      array[1..36] of byte;
    mto:                (* Person message is to                             *)
      array[1..36] of byte;
    subj:               (* Subject/title of message                         *)
      array[1..72] of byte;
    date:               (* Creation date/time                               *)
      array[1..20] of   (*   This date/time is usually in either of the     *)
      byte;             (*   Fido-sanctioned formats "DD MMM YY  HH:MM:SS"  *)
                        (*   or "WWW DD MMM YY HH:MM", but due to the       *)
                        (*   chaotic nature of FidoNet-compatible software, *)
                        (*   this CANNOT be relied upon!                    *)
    times:word;         (* Number of times read (fairly obsolete)           *)
    dest:word;          (* Destination node (of net/node)                   *)
    orig:word;          (* Origin node (of net/node)                        *)
    cost:word;          (* Cost of sending message (usually in US cents)    *)
    orig_net:word;      (* Origin net (of net/node)                         *)
    destnet:word;       (* Destination net (of net/node)                    *)
    unused1:longint;    (* Undefined                                        *)
    unused2:longint;    (*   Some software (Opus and Maximus, for example)  *)
                        (*   uses these fields to store the sent/received   *)
                        (*   date/time as bit-packed fields, using the same *)
                        (*   format used in MS-DOS directory entries.       *)
    reply:word;         (* Message # that this message replies to           *)
    attr:               (* Message attributes and behavior flags            *)
      set of msg_rec_attr;
    up:word;            (* Message # that replies to this message           *)
  end;

(*---------------------------------------------------------------------------*)

(*  Bit-masks for XTI_REC.FLAGS field  *)

type
  xti_flags =
  (
    XTI_HAS_READ   ,            (* Message has been read            *)
    XTI_HAS_REPLIED,            (* Message has been replied to      *)
    XTI_IS_PERSONAL,            (* Message is personal              *)
    XTI_IS_TAGGED  ,            (* Message has been 'tagged'        *)
    XTI_HAS_SAVED  ,            (* Message has been saved           *)
    XTI_HAS_PRINTED,            (* Message has been printed         *)
    XTI_FLAGS_RES1 ,            (* RESERVED -- DO NOT USE!          *)
    XTI_FLAGS_RES2              (* RESERVED -- DO NOT USE!          *)
  );

(*  Bit-masks for XTI_REC.MARKS field  *)

type
  xti_marks =
  (
    XTI_MARK_SAVE  ,            (* Message marked for saving   *)
    XTI_MARK_REPLY ,            (* Message marked for replying *)
    XTI_MARK_PRINT ,            (* Message marked for printing *)
    XTI_MARK_DELETE,            (* Message marked for deletion *)
    XTI_MARK_RES1  ,            (* RESERVED -- DO NOT USE!     *)
    XTI_MARK_RES2  ,            (* RESERVED -- DO NOT USE!     *)
    XTI_MARK_RES3  ,            (* RESERVED -- DO NOT USE!     *)
    XTI_MARK_RES4               (* RESERVED -- DO NOT USE!     *)
  );

type
  XTI_REC =
  record
    flags:set of xti_flags;   (* Bit-mapped message flags   *)
    marks:set of xti_marks;   (* Bit-mapped message markers *)
  end;

(*---------------------------------------------------------------------------*)

type
  NET_REC =
  record
    msg:MSG_REC;            (* The Fido-style *.MSG header                *)
    fname:                  (* Filename the message text is in            *)
      array[1..13] of byte;
    echotag:                (* NetMail area tag (*.BRD name for Telegard) *)
      array[1..21] of byte;
    zone:word;              (* Destination zone (of zone:net/node.point)  *)
    point:word;             (* Destination point (of zone:net/node.point) *)
    unix_date:longint;      (* Date/time of message                       *)
                            (*   This Unix-style date/time value (number  *)
                            (*   of seconds since 01/01/70) is converted  *)
                            (*   to the date/time storage method used by  *)
                            (*   the host BBS.                            *)
  end;

(*---------------------------------------------------------------------------*)

type
  UPI_HEADER =
  record
    regnum:             (* Reader registration number                   *)
      array[1..9] of byte;
    vernum:             (* Reader version number                        *)
      array[1..13] of   (*   All bytes should be the actually ASCII     *)
      byte;             (*   value plus 10.  Lame security, yes, but it *)
                        (*   does prevent "TYPE *.UPI" from showing the *)
                        (*   version number.                            *)
    future:             (* RESERVED FOR FUTURE USE                      *)
      array[1..33] of byte;
  end;

(*  Bit-masks for UPI_REC.FLAGS field  *)

type
  upi_flags =
  (
    UPI_RES1   ,                (* RESERVED FOR FUTURE USE                   *)
    UPI_RES2   ,                (* RESERVED FOR FUTURE USE                   *)
    UPI_RES3   ,                (* RESERVED FOR FUTURE USE                   *)
    UPI_RES4   ,                (* RESERVED FOR FUTURE USE                   *)
    UPI_RES5   ,                (* RESERVED FOR FUTURE USE                   *)
    UPI_RES6   ,                (* RESERVED FOR FUTURE USE                   *)
    UPI_PRIVATE,                (* Message is PRIVATE                        *)
    UPI_NO_ECHO                 (* Message is NOT to be echoed               *)
                                (*   This feature is not yet implemented in  *)
                                (*   the Blue Wave reader or doors, as none  *)
                                (*   of the currently supported BBS software *)
                                (*   has support for this feature.           *)
  );

type
  UPI_REC =
  record
    mfrom:              (* Person message is from                     *)
      array[1..36] of byte;
    mto:                (* Person message is to                       *)
      array[1..36] of byte;
    subj:               (* Subject/title of message                   *)
      array[1..72] of byte;
    unix_date:longint;  (* Date/time of message                       *)
                        (*   This Unix-style date/time value (number  *)
                        (*   of seconds since 01/01/70) is converted  *)
                        (*   to the date/time storage method used by  *)
                        (*   the host BBS.                            *)
    fname:              (* Filename the message text is in            *)
      array[1..13] of byte;
    echotag:            (* Area tag name (*.BRD name for Telegard)    *)
      array[1..21] of byte;
    flags:              (* Bit-mapped flags                           *)
      set of upi_flags;
    reedit:byte;        (* INTERNAL USE ONLY!                         *)
                        (*   This flag is used internally by the Blue *)
                        (*   Wave reader.  Doors should ignore this   *)
                        (*   field during reply packet processing.    *)
  end;

(*---------------------------------------------------------------------------*)

type
  UPL_HEADER =
  record
    regnum:                 (* Reader registration number (if desired)      *)
      array[1..10] of byte;
    vernum:                 (* Reader version number as a string.           *)
      array[1..20] of byte; (*   All bytes should be the actually ASCII     *)
                            (*   value plus 10.  Lame security, yes, but it *)
                            (*   does prevent "TYPE *.UPL" from showing the *)
                            (*   version number.                            *)
                            (*   Examples:  "2.10a Beta"                    *)
                            (*              "2.11"                          *)
    reader_major:byte;      (* Major version of the reader (number to the   *)
                            (*   left of the decimal point)                 *)
    reader_minor:byte;      (* Minor version of the reader (number to the   *)
                            (*   right of the decimal point)                *)
    reader_name:            (* String containing name of the reader, such   *)
      array[1..80] of byte; (*   as "The Blue Wave Offline Mail Reader".    *)
                            (*   This is provided for door programmers that *)
                            (*   wish to display the name of the reader     *)
                            (*   that created the reply packet.  (Filling   *)
                            (*   it is mandatory but using it is optional.) *)
    upl_header_len:word;    (* Size of UPL_HEADER structure                 *)
    upl_rec_len:word;       (* Size of UPL_REC structure                    *)
                            (*   NOTE:  Refer to the INF_HEADER section for *)
                            (*          more information on using the size  *)
                            (*          fields.                             *)
    loginname:              (* Name found in INF_HEADER.LOGINNAME.  This is *)
      array[1..44] of byte; (*   provided for door authors as a security    *)
                            (*   measure to implement as they wish.         *)
    aliasname:              (* Name found in INF_HEADER.ALIASNAME           *)
      array[1..44] of byte;
    reader_tear:            (* String containing abbreviated name of the    *)
      array[1..16] of byte; (*   reader, such as "Blue Wave", "Q-Blue",     *)
                            (*   "Wave Rider", etc.  This is provided for   *)
                            (*   doors programmers that wish to add to the  *)
                            (*   tear line the name of the reader that      *)
                            (*   created the reply packet.  (Filling it is  *)
                            (*   mandatory but using it is optional.)  If   *)
                            (*   this field is blank, the tear line to be   *)
                            (*   generated is left to the discretion of the *)
                            (*   door author.                               *)
    compress_type:byte;     (* Compression type required for mail packet    *)
                            (*   The Blue Wave reader uses this internally  *)
                            (*   to store the compression type required for *)
                            (*   this particular mail packet.               *)
    flags:byte;             (* Reader processing flags                      *)
                            (*   The Blue Wave reader uses this internally  *)
                            (*   to store flags required for later          *)
                            (*   processing.                                *)
                            (*     = $01 = Was a .QWK packet.                *)
                            (*     = $02 = Host requires a *.UPI file        *)
    not_registered:boolean; (* Reader is not registered to user             *)
                            (*   If this byte is set to a non-zero value,   *)
                            (*   the Blue Wave doors will assume that the   *)
                            (*   user's reader was not registered, and will *)
                            (*   place "[NR]" at the end of the tear line.  *)
                            (*   Third-party doors may use this flag for    *)
                            (*   the same purpose; its use is optional by   *)
                            (*   mail readers (especially if you don't care *)
                            (*   whether or not "[NR]" shows up on the tear *)
                            (*   line <grin>).                              *)
    pad:                    (* RESERVED FOR FUTURE USE, and to pad struct   *)
      array[1..33] of byte; (*   out to a 'nice' 256 bytes                  *)
  end;

(*---------------------------------------------------------------------------*)

(*  Bit-masks for UPL_REC.MSG_ATTR field  *)

type
  upl_msg_attr =
  (
    UPL_INACTIVE,               (* Message is INACTIVE                       *)
                                (*   Doors should NOT attempt to import this *)
                                (*   message.                                *)
    UPL_PRIVATE ,               (* Message is PRIVATE                        *)
    UPL_NO_ECHO ,               (* Message is NOT to be echoed               *)
                                (*   This feature is not yet implemented in  *)
                                (*   the Blue Wave reader or doors, as none  *)
                                (*   of the currently supported BBS software *)
                                (*   has support for this feature.           *)
    UPL_HAS_FILE,               (* Message has file "attached" to it         *)
                                (*   It is up to the door to check the       *)
                                (*   validity of this flag.  If the file is  *)
                                (*   contained in the mail packet, great.    *)
                                (*   If not, the door should probably prompt *)
                                (*   the user to begin uploading the file    *)
                                (*   after importing the messages.  (Not yet *)
                                (*   implemented in the Blue Wave reader.)   *)
    UPL_NETMAIL ,               (* Message is network mail                   *)
                                (*   Indicates NetMail/E-mail message.  The  *)
                                (*   NETWORK_TYPE field (see below) will     *)
                                (*   indicate which fields should be used    *)
                                (*   for addressing the message.             *)
    UPL_IS_REPLY,               (* Indicates that the message is a reply to  *)
                                (*   an existing message, rather than being  *)
                                (*   a completely new message.               *)
    UPL_MRES7   ,               (* RESERVED FOR FUTURE USE                   *)
    UPL_MRES8   ,               (* RESERVED FOR FUTURE USE                   *)
                                (* All of the other 8 bits of this field are *)
                                (*   also reserved for future use.  This     *)
                                (*   should provide for plenty of expansion  *)
                                (*   for future development.                 *)
    UPL_MSG_RES1,               (* RESERVED FOR FUTURE USE                   *)
    UPL_MSG_RES2,               (* RESERVED FOR FUTURE USE                   *)
    UPL_MSG_RES3,               (* RESERVED FOR FUTURE USE                   *)
    UPL_MSG_RES4,               (* RESERVED FOR FUTURE USE                   *)
    UPL_MSG_RES5,               (* RESERVED FOR FUTURE USE                   *)
    UPL_MSG_RES6,               (* RESERVED FOR FUTURE USE                   *)
    UPL_MSG_RES7,               (* RESERVED FOR FUTURE USE                   *)
    UPL_MSG_RES8                (* RESERVED FOR FUTURE USE                   *)
  );

(*  Bit-masks for UPL_REC.NETMAIL_ATTR field  *)

type
  upl_net_attr =
  (
    UPL_NRES1       ,           (* RESERVED FOR FUTURE USE             *)
    UPL_NETCRASH    ,           (* Crash = High priority mail          *)
    UPL_NRES2       ,           (* RESERVED FOR FUTURE USE             *)
    UPL_NRES3       ,           (* RESERVED FOR FUTURE USE             *)
    UPL_NETFILE     ,           (* File Attach = Send file(s) listed   *)
                                (*   in Subject field                  *)
    UPL_NRES4       ,           (* RESERVED FOR FUTURE USE             *)
    UPL_NRES5       ,           (* RESERVED FOR FUTURE USE             *)
    UPL_NETKILL     ,           (* Kill/Sent = Delete after sending    *)
    UPL_NETLOCAL    ,           (* Local = Message originated here     *)
    UPL_NETHOLD     ,           (* Hold = Hold for pickup, do not send *)
    UPL_NETIMMEDIATE,           (* Immediate = Send message NOW        *)
    UPL_NETFRQ      ,           (* File Request = Request file(s)      *)
                                (*   listed in Subject field           *)
    UPL_NETDIRECT   ,           (* Direct = Send direct, no routing    *)
    UPL_NRES6       ,           (* RESERVED FOR FUTURE USE             *)
    UPL_NRES7       ,           (* RESERVED FOR FUTURE USE             *)
    UPL_NETURQ                  (* Update Request = Request updated    *)
                                (*   file(s) listed in Subject field   *)
  );

(*  Values for UPL_REC.NETWORK_TYPE field  *)

const
  UPL_NET_FIDONET  = 0;         (* FidoNet-style E-mail and conferences     *)
                                (*   UPL_NETMAIL=off - Local, Echo, Group   *)
                                (*   UPL_NETMAIL=on  - NetMail              *)
  UPL_NET_INTERNET = 1;         (* Internet E-mail and Usenet newsgroups    *)
                                (*   UPL_NETMAIL=off - Local, Newsgroup     *)
                                (*   UPL_NETMAIL=on  - E-mail               *)

type
  UPL_REC =
  record
    mfrom:                  (* Person message is from                        *)
      array[1..36] of byte; (*   NOTE: Doors should validate this field!     *)
    mto:                    (* Person message is to (non-Internet)           *)
      array[1..36] of byte; (*   For Internet E-mail, the NET_DEST field     *)
                            (*   should be used to store the destination     *)
                            (*   name/address, leaving this field blank.     *)
                            (*   For Usenet newsgroups, this field should be *)
                            (*   left blank, as newsgroups don't use a "To:" *)
                            (*   field.                                      *)
    subj:                   (* Subject/Title of message                      *)
      array[1..72] of byte;
    destzone:word;          (* Destination address (FidoNet only)            *)
                            (*   If the message is not a FidoNet NetMail     *)
                            (*   message, this field (and the subsequent     *)
                            (*   three fields as well) should be set to      *)
                            (*   zero.                                       *)
    destnet:word;
    destnode:word;
    destpoint:word;
    msg_attr:               (* Bit-mapped message attributes                 *)
      set of upl_msg_attr;
    netmail_attr:           (* Bit-mapped NetMail attributes (FidoNet only)  *)
      set of upl_net_attr;  (*   If the message is not a FidoNet NetMail     *)
                            (*   message, this field should not be used.     *)
    unix_date:longint;      (* Date/time of message                          *)
                            (*   This Unix-style date/time value (number     *)
                            (*   of seconds since 01/01/70) is converted to  *)
                            (*   the date/time storage method used by the    *)
                            (*   host BBS.                                   *)
    replyto:longint;        (* This unsigned long word stores the message #  *)
                            (*   that this message is a reply to.  This      *)
                            (*   should be the same as FTI.MSGNUM.  Note,    *)
                            (*   however, that FTI.MSGNUM is a word, so the  *)
                            (*   value should be typecast during assignment  *)
                            (*   (i.e. upl.replyto=longint(fti.msgnum)).  As *)
                            (*   messaging/BBS systems become more complex,  *)
                            (*   FTI.MSGNUM may become obsolete, and a       *)
                            (*   longint variable may be used in its place.  *)
    filename:               (* Filename the message text is in               *)
      array[1..13] of byte; (*   If this file does not exist in the upload   *)
                            (*   packet then doors should consider this an   *)
                            (*   invalid record.                             *)
    echotag:                (* Area tag the message goes in                  *)
      array[1..21] of byte; (*   This must correspond exactly to the         *)
                            (*   INF_AREA_INFO.ECHOTAG field for the message *)
                            (*   area this message belongs to.  Simple area  *)
                            (*   number matching has proven not to work      *)
                            (*   simply because sysops are finicky people,   *)
                            (*   and seem to constantly renumber/change the  *)
                            (*   message area numbers on the host BBS.       *)
                            (*   Using an echotag helps to alleviate this    *)
                            (*   problem.  C_ECHO will be C_ECHO on the BBS, *)
                            (*   whether it is msg area 17 on the host BBS   *)
                            (*   or whether it is area 207. Doors should do  *)
                            (*   a case-INSENSITIVE compare on this field to *)
                            (*   find where the message belongs.             *)
    area_flags:word;        (* The Blue Wave Offline Mail Reader uses this   *)
                            (*   word internally to store the same value as  *)
                            (*   in INF_AREA_INFO.AREA_FLAGS.  The purpose   *)
                            (*   of this word is to hold the original        *)
                            (*   information about the message area so that  *)
                            (*   later message editing processes can be      *)
                            (*   controlled properly.  For example, if a     *)
                            (*   user later wanted to edit this message, the *)
                            (*   reader would know instantly whether this is *)
                            (*   a NETMAIL area, whether PVT messages are    *)
                            (*   allowed, etc.  This allows re-editing of    *)
                            (*   the message, even when there is not a       *)
                            (*   corresponding *.INF file laying around, or  *)
                            (*   the area is not listed in the *.INF file    *)
                            (*   you currently have to work with.  DOOR      *)
                            (*   AUTHORS SHOULD IGNORE THIS FIELD WHEN       *)
                            (*   IMPORTING MESSAGES!                         *)
    f_attach:               (* If the UPL_HAS_FILE flag is set, this field   *)
      array[1..13] of byte; (*   will contain the file name that is attached *)
                            (*   to the message.                             *)
    user_area:              (* User-defined storage.  Doors should ignore    *)
      array[1..6] of byte;  (*   this field, and reader authors should feel  *)
                            (*   free to utilize this field for their own    *)
                            (*   internal use, if necessary.                 *)
    network_type:byte;      (* Indicates the network type.  This field must  *)
                            (*   hold the same value as the NETWORK_TYPE     *)
                            (*   field in INF_AREA_INFO, allowing doors and  *)
                            (*   readers to properly handle the message.     *)
                            (*   (Values duplicated as UPL_NET_xxx, above.)  *)
                            (*   For FidoNet NetMail and Internet E-mail, it *)
                            (*   also indicates which fields should be used  *)
                            (*   for addressing and status information (as   *)
                            (*   indicated in comments above and below).     *)
    net_dest:               (* Network destination address (non-FidoNet)     *)
      array[1..100] of      (*   Internet E-mail messages should use this    *)
      byte;                 (*   field to store the destination address.     *)
  end;

(*---------------------------------------------------------------------------*)

type
  REQ_REC =
  record
    filename:array[1..13] of byte;    (* Name of file to request *)
  end;

(*---------------------------------------------------------------------------*)

(*  Bit-masks for PDQ_HEADER.FLAGS field  *)

type
  pdq_flags =
  (
    PDQ_HOTKEYS     ,           (* Toggle "hotkeys" in prompts        *)
    PDQ_XPERT       ,           (* Toggle expert mode (menu displays) *)
    PDQ_AREA_CHANGES,           (* Change active message areas        *)
    PDQ_GRAPHICS    ,           (* Toggle IBM 8-bit ASCII characters  *)
    PDQ_NOT_MY_MAIL ,           (* Toggle bundling mail from user     *)
    PDQ_FLAGS_RES1  ,           (* RESERVED FOR FUTURE USE            *)
    PDQ_FLAGS_RES2  ,           (* RESERVED FOR FUTURE USE            *)
    PDQ_FLAGS_RES3  ,           (* RESERVED FOR FUTURE USE            *)
    PDQ_FLAGS_RES4  ,           (* RESERVED FOR FUTURE USE            *)
    PDQ_FLAGS_RES5  ,           (* RESERVED FOR FUTURE USE            *)
    PDQ_FLAGS_RES6  ,           (* RESERVED FOR FUTURE USE            *)
    PDQ_FLAGS_RES7  ,           (* RESERVED FOR FUTURE USE            *)
    PDQ_FLAGS_RES8  ,           (* RESERVED FOR FUTURE USE            *)
    PDQ_FLAGS_RES9  ,           (* RESERVED FOR FUTURE USE            *)
    PDQ_FLAGS_RES10 ,           (* RESERVED FOR FUTURE USE            *)
    PDQ_FLAGS_RES11             (* RESERVED FOR FUTURE USE            *)
  );

type
  PDQ_HEADER =
  record
    keywords:                   (* User's entire set of door keywords  *)
      array[1..10] of
      array[1..21] of byte;
    filters:                    (* User's entire set of door filters   *)
      array[1..10] of
      array[1..21] of byte;
    macros:                     (* User's door bundling command macros *)
      array[1..3] of
      array[1..78] of byte;
    password:                   (* Password                            *)
      array[1..21] of byte;
    passtype:byte;              (* Password type                       *)
                                (*   0=none 1=door 2=reader 3=both     *)
    flags:set of pdq_flags;     (* Bit-mapped flags                    *)
  end;

(*---------------------------------------------------------------------------*)

type
  PDQ_REC =
  record
    echotag:                (* Echo tag of message area to activate    *)
      array[1..21] of byte; (*   With Telegard systems, this should    *)
                            (*   be the name of the *.BRD file, rather *)
                            (*   than the actual echo tag.             *)
  end;

(*---------------------------------------------------------------------------*)

(*  end of BLUEWAVE.INC  *)

{nexus nexus nexus nexus nexus nexus nexus nexus nexus nexus nexus nexus nexu}
{ nexus nexus nexus  ‹€‹‹‹‹   ‹‹‹‹‹  €‹‹ ‹‹€ ‹€‹ ‹‹   ‹‹‹‹‹   nexus nexus nex}
{s nexus nexus nexus ±€€ ±€€ ±€€  ±€ ±€€ ±€€ ±€€ ±€€ ±€€  ﬂ€ s nexus nexus ne}
{us nexus nexus nexu ∞€€ ∞€€ ∞€€‹‹∞€ ∞€€ ∞€€ ∞€€ ∞€€ ∞€€     us nexus nexus n}
{xus nexus nexus nex ∞€€ ∞€€ ∞€€       ‹ﬂ‹   ∞€€ ∞€€ ﬂ€€‹    xus nexus nexus }
{exus nexus nexus ne ∞€€ ∞€€ ∞€€     ∞€€ ∞€€ ∞€€ ∞€€    ﬂ€€‹ exus nexus nexus}
{nexus nexus nexus n ∞€€ ∞€€ ∞€€  ‹  ∞€€ ∞€€ ∞€€ ∞€€ ‹   ∞€€ nexus nexus nexu}
{ nexus nexus nexus  ∞€ﬂ ∞€ﬂ  €€€€ﬂ  ∞€ﬂ ∞€€ ∞€€‹∞€ﬂ ﬂ€€€€€ﬂ  nexus nexus nex}
{s nexus nexus nexus NEXUS   BULLETIN    ∞€€  BOARD   SYSTEM s nexus nexus ne}
{us nexus nexus nexus nexus nexus nexus n ﬂﬂ  nexus nexus nexus nexus nexus n}
{xus nexus nexus nexus nexus nexus nexus nexus nexus nexus nexus nexus nexus }
{============================================================================}
{                                                                            }
{                      Nexus Bulletin Board System v1.00                     }
{                                                                            }
{                               DATA STRUCTURES                              }
{                             Turbo Pascal Format                            }
{                                                                            }
{ All material contained herein is copyright 1995-2000 George A. Roberts IV. }
{ All rights reserved.                                                       }
{                                                                            }
{ Nexus is a trademark of George A. Roberts IV. Turbo Pascal is a Trademark  }
{ of Borland International.                                                  }
{                                                                            }
{ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ}

{----------------------------------------------------------------------------}
{ NOTES TO TURBO PASCAL DEVELOPERS:                                          }
{                                                                            }
{     George A. Roberts IV (the Author) guarantees no reliability of these   }
{ structures.  The Author has provided these structures to allow Turbo       }
{ Pascal Developers to develop Nexus compatible applications.                }
{                                                                            }
{ These structures are provided AS IS.  The Author provides no warranty,     }
{ expressed or implied, to those who use these structures.  At no time, for  }
{ any reason, shall the Author, his employees, contractors, or other         }
{ affiliates be held responsible for any loss due to the use of these        }
{ structures, whether direct or indirect.                                    }
{                                                                            }
{                                                                            }
{   IMPORTANT - IMPORTANT - IMPORTANT - IMPORTANT - IMPORTANT - IMPORTANT    }
{                                                                            }
{  DO NOT MODIFY any variables that are labeled as RESERVED.  These are      }
{  reserved for future enhancements and modifying them may cause current or  }
{  future versions of Nexus to run improperly or even crash.                 }
{----------------------------------------------------------------------------}

{----------------------------------------------------------------------------}
{ Version Number Information:                                                }
{                                                                            }
{ <Version>    String formatted typed CONSTANT representing the string       }
{              display of the version number                                 }
{ <MajVersion> Major/Minor Version numbers - byte format. This is the current}
{ <MinVersion> version that these structures support.  This can be used to   }
{              check the MATRIX.DAT (MXxxxx.DAT) for the version number that }
{              it is being used with, for compatibility sake.                }
{----------------------------------------------------------------------------}

CONST

Version         : STRING[4]='0.99';
MajVersion      : BYTE=0;
MinVersion      : BYTE=99;


{----------------------------------------------------------------------------}
{ CONSTANT Declarations:                                                     }
{                                                                            }
{ Various CONSTANTS that are used internally in Nexus.  They are included    }
{ here for reference.  They give you an idea of what type of limitations     }
{ that Nexus places on certain data files, so that you can impose the same   }
{ limitations in your programs.  Please follow these restrictions closely,   }
{ as if you add more than the maximum allowed, those above maximum will not  }
{ be used by Nexus.                                                          }
{----------------------------------------------------------------------------}

CONST

MaxBoards       = 32766;          { 0 to 32766                               }
MaxUBoards      = 32766;          { 0 to 32766                               }
MaxProtocols    = 120;            { 0 to 120                                 }
MaxEvents       = 10;             { 0 to 10                                  } 
MaxArcs         = 8;              { 1 to 8                                   }
MaxMenuCmds     = 50;             { 1 to 50                                  }


{----------------------------------------------------------------------------}
{ TYPE Declarations:                                                         }
{                                                                            }
{ Various TYPES that are used throughout Nexus for internal workings and for }
{ data structures in data files.  If a structure is the specific foundation  }
{ of a file, the filename and information will be listed before the structure}
{ information, so as to help you with which structures go with which files.  }
{----------------------------------------------------------------------------}

TYPE

Astr            = STRING[160];    { Generic String Type                      }
ACString        = STRING[20];     { Access Control String                    }
ACRQ            = '@'..'Z';       { AR flags                                 }


                                  { packed date/time format                  }
CPackDateTime   = ARRAY[1..6] of BYTE;

                                  { Date/Time record                         }
DateTimeREC=
RECORD
    day, hour, min, sec : LONGINT;
END;
                                  { These colors are being phased out        }
Clrs            = ARRAY[FALSE..TRUE,0..9] of BYTE;


{----------------------------------------------------------------------------}
{ Filename: USERS.IDX                                                        }
{ Location: DATA Directory                                                   }
{ Format  : 1 <SmalREC> record per entry, 0 record is blank buffer           }
{                                                                            }
{ Notes   : Used to have a quick index to to the USERS.DAT file.  Records    }
{           must correspond with the appropriate record in the USERS.DAT     }
{           file.  i.e. Record 1 of USERS.IDX should match Record 1 of       }
{           USERS.DAT.  The <number> variable is a safeguard for a case      }
{           where they do not match.                                         }
{----------------------------------------------------------------------------}

SmalREC=
RECORD
    name:STRING[36];              { user name                                }
    real:STRING[36];              { user real name                           }
    nickname:STRING[8];           { user chat nickname                       }
    number:INTEGER;               { Record Number in USERS.DAT               }
    UserID:Longint;
    RESERVED:ARRAY[1..5] of BYTE;
END;

{----------------------------------------------------------------------------}
{ Filename: NAMES.IDX                                                        }
{ Location: DATA Directory                                                   }
{ Format  : 1 <NamesIDX> record per entry                                    }
{                                                                            }
{ Notes   : Used to have a quick sorted index to the Real Names of all users }
{           that are not deleted.  There will be one record for each User.   }
{----------------------------------------------------------------------------}

NamesIDX=
RECORD
    Name:STRING[36];
END;


{----------------------------------------------------------------------------}
{ Filename: ALIASES.IDX                                                      }
{ Location: DATA Directory                                                   }
{ Format  : 1 <AliasIDX> record per entry                                    }
{                                                                            }
{ Notes   : Used to have a quick sorted index to the Aliases of all users    }
{           that are not deleted.  There will be one record for each User.   }
{----------------------------------------------------------------------------}

AliasIDX=
RECORD
    Alias:STRING[36];
END;


{----------------------------------------------------------------------------}
{ Filename: USERID.IDX                                                       }
{ Location: DATA Directory                                                   }
{ Format  : 1 <UserIDREC> record per entry                                   }
{                                                                            }
{ Notes   : Used to have a quick index to to the UserIDs.  There will be one }
{           record for each UserID.  The <Number> variable will be set to -1 }
{           if the user has been deleted.                                    }
{           The <Number> variable will be set to -2 if this UserID is in use }
{           by nxEMAIL for a LISTSERVER.                                     }
{----------------------------------------------------------------------------}

UserIDREC=
RECORD
    UserID      : LONGINT;
    Number      : INTEGER;
END;


{----------------------------------------------------------------------------}
{ Filename: USERS.DAT                                                        }
{ Location: DATA Directory                                                   }
{ Format  : 1 <UserREC> record per entry, 0 record is blank buffer           }
{                                                                            }
{ Notes   : Used to store user information.  One record per user. Record     }
{           #0 is a blank record that is used to buffer the file out so      }
{           that the user numbers start at 1.                                }
{----------------------------------------------------------------------------}

UFlags =
   (rLogon,                       { Restricted to one call a day             }
    rChat,                        { Can't page the SysOp                     }
    rValidate,                    { Posts marked unvalidated                 }
    rBackspace,                   { Can't do special keys in messages        }
    RESERVED1,                    { RESERVED }
    RESERVED2,                    { RESERVED }
    rpost,                        { Can't post at all                        }
    remail,                       { Can't post any private messages          }
    RESERVED3,                    { RESERVED }
    rmsg,                         { Force private message deletion           }
    spcsr,                        { RESERVED }
    onekey,                       { QuickKey input mode                      }
    RESERVED4,                    { RESERVED }
    pause,                        { Pause when screen is full                }
    novice,                       { User is at novice help level             }
    ansi,                         { User has ANSI                            }
    color,                        { User has color                           }
    alert,                        { Alert SysOp when user logs on            }
    usetaglines,                  { Use taglines when writing messages       }
    RESERVED5,                    { RESERVED                                 }
    fnodlratio,                   { No UL/DL ratio                           }
    fnopostratio,                 { No post/call ratio                       }
    fnofilepts,                   { No file points checking                  }
    fnodeletion);                 { Protection from deletion                 }

joinedconfs = 'A'..'Z';


UserREC=
RECORD
    Name         : STRING[36];    { Logon Name                               }
    RealName     : STRING[36];    { real name                                }
    UserID       : LONGINT;       { UserID                                   }
    Nickname     : STRING[8];     { Chat nickname                            }
    RESERVED6    : ARRAY[1..24] of
                        BYTE;     { RESERVED                                 }
    pw           : STRING[20];    { user password                            }
    phone1       : STRING[20];    { user phone #1                            }
    phone2       : STRING[20];    { user phone #2                            }
    phone3       : STRING[20];    { user phone #3                            }
    phone4       : STRING[20];    { user phone #4                            }
    street       : STRING[30];    { mailing address #1                       }
    street2      : STRING[30];    { mailing address #2                       }
    citystate    : STRING[40];    { city, state                              }
    zipcode      : STRING[20];    { zipcode                                  }
    bday         : LONGINT;       { user birthdate (UNIX TimeDate)           }
    sex          : CHAR;          { user gender                              }
    option1      : STRING[30];    { type of computer                         }
    option2      : STRING[40];    { occupation                               }
    option3      : STRING[40];    { BBS reference                            }
    note         : STRING[40];    { SysOp note                               }
    business     : STRING[40];    { Business Affiliated With                 }
    title        : STRING[20];    { title                                    }
    desc         : ARRAY[1..4]
                   of STRING[40]; { User Self Description                    }
    clearentry   : ARRAY[1..20]   
                   of BOOLEAN;    { Clear Entries Flags                      }

    RESERVED1    : ARRAY[1..37]
                     of BYTE;     { RESERVED                                 }
    phentrytype  : BYTE;
    zipentrytype : BYTE;
    firston      : LONGINT;       { firston date (UNIX Time Date)            }
    laston       : LONGINT;       { laston date (UNIX Time Date)             }
    filescandate : LONGINT;       { file scan date (UNIX Time Date)          }
    sl           : BYTE;          { Security Level                           }
    ac           : SET of UFlags; { user flags                               }
    ar           : SET of ACRQ;   { AR flags                                 }
    lockedout    : BOOLEAN;       { if locked out                            } 
    deleted      : BOOLEAN;       { if deleted                               }
    lockedfile   : STRING[8];     { lockout msg to print                     }
    ar2          : SET of ACRQ;   { AR flags #2                              }

    RESERVED2    : ARRAY[1..46]
                     of BYTE;     { RESERVED                                 }
    ttimeon      : LONGINT;       { total mins spent on                      }
    loggedon     : INTEGER;       { # times logged on                        }
    tltoday      : INTEGER;       { # min left today                         }
    ontoday      : BYTE;          { # times on today                         }
    illegal      : BYTE;          { # illegal logon attempts                 }
    credit       : LONGINT;       { Credits                                  }
    timebank     : INTEGER;       { # mins in Time Bank                      }
    timebankadd  : INTEGER;       { time added to timebank TODAY             }
    trapactivity : BOOLEAN;       { if trapping users activity               }
    trapseperate : BOOLEAN;       { if trap to seperate TRAP file            }
    chatauto     : BOOLEAN;       { if auto chat trapping                    }
    chatseperate : BOOLEAN;       { if seperate chat file to trap to         }
    slogseperate : BOOLEAN;       { seperate SysOp log?                      }
    pagelen      : BYTE;          { page length (# rows)                     }
    uscheme      : INTEGER;       { Scheme Number                            }
    userstartmenu: INTEGER;       { menu to start user out on                }
    timebankwith : INTEGER;       { time withdrawn from timebank TODAY       }
    RESERVED3    : ARRAY[1..48]
                     of BYTE;     { RESERVED                                 }
    lastfconf    : BYTE;          { Last File Conference In                  }
    lastfil      : INTEGER;       { Last File Base In                        }
    uk           : LONGINT;       { UL k                                     }
    dk           : LONGINT;       { DL k                                     }
    uploads      : INTEGER;       { # of ULs                                 }
    downloads    : INTEGER;       { # of DLs                                 }
    filepoints   : INTEGER;       { # of file points                         }
    defprotocol  : CHAR;          { Default Protocol, @=Ask Each Transfer    }
                                  { Message Bases that user is Sysop of      }
    uboardsysop  : ARRAY[1..20] of INTEGER;

    RESERVED4    : ARRAY[1..50]
                     of BYTE;     { RESERVED                                 }
    lastmconf    : BYTE;          { Last Message Conference In               }
    lastmsg      : INTEGER;       { Last Message Base In                     }
    msgpost      : INTEGER;       { # public posts                           }
    feedback     : INTEGER;       { # feedback sent                          }
    mruler       : BYTE;          { Message Ruler 0 = OFF  1 = ON            }
    msgeditor    : SHORTINT;      {-1 : Nexus Full-Screen Editor             }
                                  { 0 : Nexus Line Editor                    }
                                  { 1^: External Editor                      }
                                  { Message Bases that user is Sysop of      }
    boardsysop   : ARRAY[1..20] of INTEGER;

    subscription : BYTE;          { Current Subscription Level               }
    subdate      : LONGINT;       { Subscription Level Start Date/Time in    }
                                  { UNIX Date/Time Stamp format              }
    language     : BYTE;          { Language this user has selected          }
    RESERVED5    : ARRAY[1..99]
                       of BYTE;   { RESERVED                                 }
END;

{----------------------------------------------------------------------------}
{ Filename: USERxxxx.DAT    (xxxx = Node number in format 0001, 0010, etc.)  }
{ Location: DATA Directory                                                   }
{ Format  : 1 <OnlineREC> record                                             }
{                                                                            }
{ Notes   : Used to provide information to external programs about a         }
{           particular node's current status.  This information is useful    }
{           for a door program that is written specifically to work with     }
{           Nexus, such as a callback verifier or multiline chat program.    }
{           Much of the information found in the USERS.DAT file may not be   }
{           necessary, so the information in the USERxxxx.DAT file may be    }
{           used.  If more information is needed, the <Number> variable      }
{           points to the record number in the USERS.DAT file where this     }
{           user is located.                                                 }
{                                                                            }
{           This file is automatically created when a user logs on to Nexus  }
{           and is deleted when the user logs off.  Nexus creates a file for }
{           the node if it is at the Waiting for Caller screen logged in and }
{           places a 2 in the appropriate index value in the ONLINE.IDX so   }
{           that other nodes of Nexus will see that this node is waiting for }
{           a caller.                                                        }
{----------------------------------------------------------------------------}

OnlineREC=
RECORD
    Name         : STRING[36];    { User Logon Name                          }
    real         : STRING[36];    { User Real Name                           }
    UserID       : LONGINT;       { UserID                                   }
    TimeLeft     : INTEGER;       { Time Left Online                         }
    Status       : BYTE;          { Node Status - 0=Waiting For Caller       }
                                  {               1=Logging In               }
                                  {               2=Logged In                }
    Nickname     : STRING[8];     { User Nickname                            }
    RESERVED     : ARRAY[1..20] of
                        BYTE;     { RESERVED                                 }
    invisible    : BOOLEAN;       { User is invisible (does not show in last }
                                  { callers and who's online listings        }
    business     : STRING[40];    { User Business (calling from)             }
    number       : INTEGER;       { User Number                              }
    activity     : STRING[20];    { Current Activity                         }
    available    : BOOLEAN;       { User Available?                          }
    Baud         : WORD;          { 0 = Local  Other = Connect Rate / 10     }
    LockBaud     : WORD;          { 0 = Port not locked                      }
                                  { Locked Baud Rate / 10                    }
    Comport      : WORD;          { 0=Local                                  }
    Comtype      : BYTE;          { 0=Fossil  1=Interrupt (internal)         }
                                  { 2=Digiboard                              }
    emulation    : WORD;          { 0=TTY   1=ANSI                           }
END;

NodeMsgREC=
RECORD
    SentBy      : STRING[36];
    SentByNode  : INTEGER;
    Message     : STRING[79];
END;

{----------------------------------------------------------------------------}
{ Filename: TAGLINES.DAT                                                     }
{ Location: DATA Directory                                                   }
{ Format  : 1 <TagREC> record per entry                                      }
{                                                                            }
{ Notes   : Used to provide users the ability to add taglines to their       }
{           messages.  A global tagline file is able to be added to by the   }
{           users and then they may select any of the taglines to add to     }
{           their message.                                                   }
{----------------------------------------------------------------------------}
  
TagREC=
RECORD
    Tag          : STRING[75];    { Tagline }
END;

{----------------------------------------------------------------------------}
{ Filename: NETWORK.DAT                                                      }
{ Location: DATA Directory                                                   }
{ Format  : 1 <FidoREC> record                                               }
{                                                                            }
{ Notes   : Used to store default values and information regarding message   }
{           networks.  There is one record of <FidoREC> in the NETWORK.DAT   }
{           file.                                                            }
{----------------------------------------------------------------------------}

FidoREC=
RECORD
    Address      : ARRAY[1..30] of               { Address Information       }
        RECORD
                Zone  : WORD;     { Zone number                              }
                Net   : WORD;     { Net number                               }
                Node  : WORD;     { Node number                              }
                Point : WORD;     { Point number                             }
        END;
    Origins      : ARRAY[1..20] of STRING[50];   { Origin Lines              }
    RES2         : ARRAY[1..807] of BYTE;        { RESERVED                  }
    NodelistType : BYTE;          { Nodelist Type Found in NODELIST PATH     }
                                  {     0: No Nodelist                       }
                                  {     1: Version 7                         }
                                  {     2: Frontdoor                         }
                                  { other: RESERVED                          }
    Text_color   : BYTE;          { default color of standard text           }
    Quote_color  : BYTE;          { default color of quoted text             }
    Tag_color    : BYTE;          { default color of tagline                 }
    Oldtear_color: BYTE;          { default color old tearline ( ~~~ or ___ )}
    Tear_color   : BYTE;          { default color of tear line               }
    Origin_color : BYTE;          { default color of origin line             }
    SKludge      : BOOLEAN;       { default strip kludge lines?              }
    SSeenby      : BOOLEAN;       { default strip SEEN-BY lines?             }
    SOrigin      : BOOLEAN;       { default strip origin line?               }
    nodelistpath : STRING[79];    { Path to Nodelist Files                   }
    isprivate    : BOOLEAN;       { Default Netmail Private?                 }
    iscrash      : BOOLEAN;       { Default Netmail Crash?                   }
    isfattach    : BOOLEAN;       { Default Netmail File Attach?             }
    iskillsent   : BOOLEAN;       { Default Netmail Kill/Sent?               }
    ishold       : BOOLEAN;       { Default Netmail Hold?                    }
    isfilereq    : BOOLEAN;       { Default Netmail File Request?            }
    isreqrct     : BOOLEAN;       { Default Netmail ReturnReceiptRequest?    }
    isdirect     : BOOLEAN;       { Default Netmail Direct?                  }
    nodeintear   : BOOLEAN;       { Place node number in tear line?          }
    res          : ARRAY[1..11] of BYTE;         { RESERVED }
END;

InternetREC=
RECORD
    Gateways:ARRAY[1..30] of
        RECORD
        Name:STRING[40];
        ToName:STRING[36];
        ToAddress:RECORD
                Zone  : WORD;     { Zone number                              }
                Net   : WORD;     { Net number                               }
                Node  : WORD;     { Node number                              }
                Point : WORD;     { Point number                             }
        END;
        FromAddress:BYTE;
        GatewayType:BYTE;         { 0: Place ToName in Header, TO: <site> in }
                                  {    first line of text.                   }
                                  { 1: Place <site> in Header                }
        RESERVED1:ARRAY[1..29] of BYTE;
        END;
    RESERVED2:ARRAY[1..50] of BYTE;
END;

  CallInfoREC=                          { CALLINFO.xxx (DAT) : Call Logs }
  RECORD
    RESERVED1:ARRAY[1..9] of BYTE;
    userbaud:ARRAY[0..40] of INTEGER;
    active,
    calls,
    newusers,
    pubpost,
    fback,
    criterr:INTEGER;
    uploads,
    downloads:INTEGER;
    uk,
    dk:LONGINT;
    date:LONGINT;
    RESERVED:ARRAY[1..16] of BYTE;
  END;

  TotalsREC=                          { TOTALS.xxx (DAT) : Call Logs }
  RECORD
    RESERVED1:ARRAY[1..9] of BYTE;
    userbaud:ARRAY[0..40] of LONGINT;
    active,
    calls,
    newusers,
    pubpost,
    fback,
    criterr:LONGINT;
    uploads,
    downloads:LONGINT;
    date:LONGINT;
    RESERVED:ARRAY[1..100] of BYTE;
  END;


ArchiverREC=
RECORD
    Active    : BOOLEAN;          { Is archiver active to be used?           }
                                  { Note if set to view with internal methods}
                                  { Nexus will still allow viewing even if   }
                                  { archiver is disabled.                    }
    Name      : STRING[40];       { Name of archiver                         }
    ListFiles : STRING[80];       { List archive commandline (blank=internal)}
    Compress  : STRING[80];       { Compress archive commandline             }
    Decompress: STRING[80];       { Decompress archive commandline           }
    TestFiles : STRING[80];       { Test archive commandline                 }
    Comment   : STRING[80];       { Comment archive commandline              }
    ErrorLevel: INTEGER;          { Errorlevel for success on external       }
    Extension : STRING[3];        { File extention (used only for records 12+}
    RESERVED  : ARRAY[1..100] of BYTE;  { RESERVED -- DO NOT MODIFY!         }
END;

(*

modemrec=                      { COMxxxx.DAT }
RECORD
    comport:BYTE;                { comport number                            }
    waitbaud:LONGINT;            { Wait Baud Rate                            }
    lockport:BOOLEAN;            { whether to force baud rate                }
    hangup:STRING[40];           { hangup string                             }
    ctype:byte;                       { 0 : Local                            }
                                      { 1 : Fossil                           }
                                      { 2 : Digiboard                        }
                                      { 3 : Internal                         }
    lowtime,                          { SysOp begin minute (in minutes) }
    hitime,                           { SysOp end time }
    dllowtime,                        { normal downloading hours begin.. }
    dlhitime:ARRAY[1..7] of INTEGER;  { ..and end }
    minimumbaud:LONGINT;              { lockout bauds below this baud rate }
    lockbegintime,                    { locked out baud calling hours begin..}
    lockendtime,                      { ..and end }
    lockbegin_dltime,                 { locked out baud dl hours begin..}
    lockend_dltime:ARRAY[1..7] of INTEGER;           { ..and end }
    closedsystem:BOOLEAN;             { System is CLOSED to NEW USERS        }
    swapprotocol:BYTE;
    swaparchiver:BYTE;
    swapdoor:BYTE;
    swapeditor:BYTE;
    swapchat:BYTE;
    swaplocalshell:BYTE;
END;

*)

modemrec=                      { NODExxxx.DAT }
RECORD
    comport:BYTE;                { comport number                            }
    waitbaud:LONGINT;            { Wait Baud Rate                            }
    lockport:BOOLEAN;            { whether to force baud rate                }
    ctype:byte;                       { 0 : Local                            }
                                      { 1 : Fossil                           }
                                      { 2 : Digiboard                        }
                                      { 3 : Internal                         }
    lowtime,                          { SysOp begin minute (in minutes) }
    hitime,                           { SysOp end time }
    dllowtime,                        { normal downloading hours begin.. }
    dlhitime:ARRAY[1..7] of INTEGER;  { ..and end }
    minimumbaud:LONGINT;              { lockout bauds below this baud rate }
    lockbegintime,                    { locked out baud calling hours begin..}
    lockendtime,                      { ..and end }
    lockbegin_dltime,                 { locked out baud dl hours begin..}
    lockend_dltime:ARRAY[1..7] of INTEGER;           { ..and end }
    closedsystem:BOOLEAN;             { System is CLOSED to NEW USERS        }
    swapprotocol:BYTE;
    swaparchiver:BYTE;
    swapdoor:BYTE;
    swapeditor:BYTE;
    swapchat:BYTE;
    swaplocalshell:BYTE;
    swapfrontend:BYTE;           { swap setting for front-end program        }
    UseFrontend:BOOLEAN;         { use front-end program                     }
    FrontEndPath:STRING[79];     { path\filename to front-end program        }
    init1:STRING[80];            { modem init string #1                      }
    init2:STRING[80];            { modem init string #2                      }
    init3:STRING[80];            { modem init string #3                      }
    answer:STRING[80];           { modem answer string                       }
    hangup:STRING[40];           { modem hangup string                       }
    offhook:STRING[40];          { modem offhook string                      }
    onhook:STRING[40];           { modem onhook string                       }
    responses:array[1..50] of
        RECORD
                response :STRING[40]; { modem response string                 }
                outelevel:byte;       { errorlevel returned from frontend     }
                action   :byte;       { action to perform when receiving this }
                                      { response string or outelevel:         }
                                      { 1: LOG ON WITH baud BAUD RATE         }
                                      { 2: EXIT WITH elevel ERRORLEVEL        }
                                      { 3: RUN cmdline COMMANDLINE            }
                baud     :longint;    { baud to log on with                   }
                elevel   :byte;       { errorlevel to exit with               }
                cmdline  :string[79]; { cmdline to shell out with             }
                reserved :array[1..100]
                          of byte; 
        END;
    rspok:STRING[20];
    rsperror:STRING[20];
    rspcarrier:STRING[20];
    rspring:STRING[20];
    RESERVED:ARRAY[1..116] of BYTE;
END;

{ NOTES: When using NXWFC.EXE, nxWFC will wait for call, answer, and then
         check the response with the above response strings.  When/if it finds
         a match, it will exit with the errorlevel set in outelevel for that
         response.  When using a front-end mailer in back-end mode, you will
         configure the mailer to exit with the specific errorlevel, and place
         those errorlevels in the appropriate outelevel variable. }

PermIDREC=
RECORD
    LastMBaseID:LONGINT;
    LastFBaseID:LONGINT;
    LastDoorID:LONGINT;
    LastEditorID:LONGINT;
    LastUserID:LONGINT;
    RESERVED     : ARRAY[1..1004] of BYTE;
END;

SystemREC=                            { SYSTEM.DAT }
RECORD
    callernum    : LONGINT;       { System Caller Number                     }
    numusers     : LONGINT;       { Number of Callers to this node           }
    highnode     : INTEGER;       { Highest Node Number Ever Executed        }
    RESERVEDx    : ARRAY[1..29]
                   of BYTE;       
    NKeywords:LONGINT;
    NDescLines:LONGINT;
    lastdate     : LONGINT;       { Last date Nexus was run (UNIX TimeDate   }
    RESERVED     : ARRAY[1..26] of BYTE;
    ordate       : DateTimeREC;   { Original First Run Date                  }
    ordone       : BOOLEAN;       { Whether OrDate has been entered          }
   {RESERVED     : ARRAY[1..17] of BYTE;}     { RESERVED - DO NOT MODIFY     }
END;

{----------------------------------------------------------------------------}
{ Filename: SECURITY.DAT                                                     }
{ Location: DATA Directory                                                   }
{ Format  : Record #0 is holding record                                      }
{           100 <SecurityREC> records                                        }
{                                                                            }
{ Notes   : Used to store security level configuration for each security     }
{           level.  The security level is not used if the <Active> variable  }
{           is set to FALSE.                                                 }
{----------------------------------------------------------------------------}


SecurityREC=
RECORD
    Active       : BOOLEAN;       { Is Security Level begin used?            }
    Description  : STRING[20];    { Description of Security Level            }
    CallsPerDay  : BYTE;          { Number of Calls Per Day for SL           }
    TimePerCall  : INTEGER;       { Time Per Call (minutes)  0=Use Time/Day  }
    TimePerDay   : INTEGER;       { Time Per Day (minutes)                   }
    PostPerCall  : INTEGER;       { Posts Per Call Required                  }
    DLRatioFiles : INTEGER;       { Number of Files DLed before 1 upload req }
    DLRatioKb    : INTEGER;       { Number of Kb DLed before 1 Kb required   }
                                  {           1 =300    2 =1200   3 =2400    }
                                  { 4 =4800   5 =7200   6 =9600   7 =12000   }
                                  { 8 =14400  9 =19200  10=38400  11=57600   }
                                  { 12=115200                                }
    MaxInTB      : INTEGER;       { Maximum amount in Time Bank              }
    WithTBDay    : INTEGER;       { Withdrawal Maximum per Day               }
    WithTBCall   : INTEGER;       { Withdrawal Maximum per Call              }
    AddTBDay     : INTEGER;       { Maximum minutes per Day can be Added     }
    AddTBCall    : INTEGER;       { Maximum minutes per Call can be Added    }
    RESERVED1    : ARRAY[1..10] of BYTE;      { RESERVED                     }
    MaxDLPerCall : ARRAY[1..12] of INTEGER;   { Max Files DLed based on baud }
    RESERVED2    : ARRAY[1..8] of INTEGER;    { RESERVED                     }
    MaxKbPerCall : ARRAY[1..12] of LONGINT;   { Max Kb DLed based on baud    }
    RESERVED3    : ARRAY[1..8] of INTEGER;    { RESERVED                     }
end;


MatrixREC=                          { MATRIX.DAT }
RECORD
    majorversion:BYTE;                { major version number }  
    minorversion:BYTE;                { major version number }
    gfilepath:STRING[79];             { DATA path                            }
    afilepath:STRING[79];             { DISPLAY path                         }
    menupath:STRING[79];              { MENUS path                           }
    trappath:STRING[79];              { LOG path                             }
    userpath:STRING[79];              { USER DIRECTORY path                  }
    utilpath:STRING[79];              { UTILITY path                         }
    semaphorepath:STRING[79];         { SEMAPHORE FILE path                  }
    filereqpath:STRING[79];           { RESERVED -- DO NOT MODIFY            }
    filepath:STRING[79];              { NEXUS FILE DATABASE (NFD) path       }
    temppath:STRING[79];              { TEMPORARY STORAGE path               }
    swappath:STRING[79];              { SWAP ON EXECUTE path                 }
    nexecutepath:STRING[79];          { NEXECUTABLE path                     }
    ExtUploadPath:STRING[79];         { Path to external program run after   }
                                      { an upload and before checking for    }
                                      { FILE_ID.DIZ                          }
    RESERVED4path:STRING[79];         { RESERVED -- DO NOT MODIFY            }
    netmailpath:STRING[79];           { Used for nxEMAIL to import internet  }
                                      { e-mail from the netmail path         }
                                      { This is that path to a *.MSG base    }
    
    bbsname:STRING[80];               { BBS name }
    bbscitystate:STRING[30];          { BBS City State }
    bbsphone:STRING[12];              { BBS phone number }
    sysopname:STRING[30];             { SysOp's full name or alias }
    maxusers:INTEGER;                 { max number of users system can have }
    cbuild:byte;                      { Current Nexus Build #                }
    cbuildmod:string[4];              { Current Nexus Build Modification #   }
    RS1:ARRAY[1..50] of BYTE;
    sysoppw,                          { SysOp PW }
    newuserpw:STRING[20];             { newuser PW (or NULL if none) }
    RS2:ARRAY[1..61] of BYTE;
    RESERVED1:BYTE;                   { RESERVED                             }
    eventwarningtime:INTEGER;         { Time before event Warning            }
    deflanguage:BYTE;
    res1:ARRAY[1..29] of BYTE;        { RESERVED SPACE #1 }

    sop,                              { SysOp }
    csop,                             { Co-SysOp }
    msop,                             { Message SysOp }
    fsop,                             { File SysOp }
    spw,                              { SysOp PW at logon }
    seepw,                            { see SysOp PWs remotely  }
    normpubpost,                      { make normal public posts }
    netmail,                          { send netmail }
    seeunval,                         { see unvalidated files }
    dlunval,                          { DL unvalidated files }
    nodlratio,                        { no UL/DL ratio }
    nopostratio,                      { no post/call ratio }
    nofilepts,                        { no file points checking }
    ulvalreq,                         { uploads require validation by SysOp }
    setnetmailflags,                  { set flags for netmail message when
                                        writing message }
    netmailoutofzone,                 { netmail to zones not found }
    nonodelist,                       { netmail with no nodelist }
    untagmandatory,                   { Untag mandatory bases? }
    loginvisible,                     { Log on in invisible mode }
    seeinvisible:ACString;            { See people logged on invisible }
    res2:ARRAY[1..147] of BYTE;       { RESERVED SPACE #2 }

    maxfback,                         { max feedback per call }
    maxpubpost,                       { max posts per call }
    maxchat,                          { max chat-pages per call }
    maxlines,                         { max lines in message }
    csmaxlines,                       { max lines in message for Co-SysOp + }
    maxlogontries,                    { tries allowed for PW's at logon }
    sysopcolor,                       { SysOp color in chat mode }
    usercolor:BYTE;                   { user color in chat mode }
    minspaceforpost:INTEGER;          { minimum K drive space left to post }
    NEWRESERVE2:INTEGER;              { minimum K drive space left to upload }
    backsysoplogs:BYTE;               { days to keep NEXxxxx.LOG }
    pagelen:BYTE;                     { default video page length }
    lastlogdelete:BYTE;               { how many days has log been active }
    res3:ARRAY[1..30] of BYTE;        { RESERVED SPACE #3 }

    allowalias:BOOLEAN;               { Allow Aliases on this BBS?           }
    phonepw,                          { use phone number password in logon? }
    localsec,                         { is local security ON? }
    localscreensec,                   { is local screen-security ON? }
    globaltrap,                       { trap ALL USER'S activity? }
    autochatopen:BOOLEAN;             { does chat buffer auto-open? }
    aliasprimary:BOOLEAN;
    allowiemsi:BOOLEAN;               { Allow IEMSI logins to the BBS?       }
    MXUnused2:ARRAY[1..9] of BYTE;    { UNUSED }
    
    newapp,                           { user# to send new user application to}
    timeoutbell,                      { minutes before time-out bell }
    timeout:INTEGER;                  { minutes before timeout (logoff) }
    timeoutlocal:BOOLEAN;             { does system timeout with local logons}
(*    useems:BOOLEAN;                   { **OBSOLETED** use EMS for overlay } *)
    usebios:BOOLEAN;                  { use ROM BIOS for local video output }
    cgasnow:BOOLEAN;                  { suppress snow on CGA systems }
    showlocaloutput:BOOLEAN;          { protocols }
    showlocaloutput2:BOOLEAN;         { archivers }
    useextchat:BOOLEAN;               { use External Chat defined in record 0}
    res4:ARRAY[1..27] of BYTE;        { RESERVED SPACE #4 }

    filearccomment:ARRAY[1..3] of STRING[80]; { BBS comments for archives }
    uldlratio,                        { are UL/DL ratios active? }
    fileptratio:BOOLEAN;              { is auto file-pt compensation active? }
    fileptcomp,                       { file point compensation ratio }
    fileptcompbasesize,               { file point "base compensation size" }
    ulrefund:BYTE;                    { percent time refund for ULs }
    NEWRESERVE:BYTE;                  { "To SysOp" file base }
    validateallfiles:BOOLEAN;         { validate ALL FILES automatically? }
    remdevice:STRING[10];             { remote output device (GATEx,COMx,etc) }
    maxintemp,                        { max K allowed in TEMP }
    minresume:INTEGER;                { min K to allow resume-later }
    minspaceforupload:INTEGER;
    searchdup:BYTE;                   { search for duplicate filenames on
                                        upload -  0 = NONE }
                                      {           1 = All Bases }  
                                      {           2 = Only Hard Drive Bases }
    searchdupstrict:BOOLEAN;          { search for duplicates strictly - only }
                                      { match files with exact first 8 CHARs }
                                      { if off - match files with filename in }
                                      { it anywhere , i.e.  FIRST2.ZIP would }
                                      { be found if user wants to upload }
                                      { FIRST.ARJ }
    listtype:BYTE;                    { 0 - 10 line }
                                      { 1 - 5 line }
                                      { 2 - 1 line }

    tosysopdir:INTEGER;           { -1 DISABLED                              }
    allowofflinereq:boolean;      { Allow Offline Files to be requested?     }
    convertwithav:boolean;        { Convert files with known AV stamp?       }
    convertsame:boolean;          { Convert archives even if source and      }
                                  { destination are same archive type?       }
    addwithav:boolean;            { allow adding of files to archives with an}
                                  { AV stamp?                                }
    res8:ARRAY[1..13] of BYTE;    { RESERVED                                 }

    timezone:byte;                { Local Time Zone                          }
    numusers:INTEGER;             { number of users                          }
    RSREC:ARRAY[1..79] of BYTE;   { RESERVED                                 }
    res:ARRAY[1..133] of BYTE;    { RESERVED                                 }
  END;


SubscriptionREC=                  { SUBSCRIP.DAT                             }
RECORD
    Description  : STRING[40];    { Description of Subscription Level        }
    SL           : BYTE;          { Security Level of Subscription Level     }
    ARflags      : SET of ACRQ;   { AR Flag Set for this Subscription Level  }
    ARmodifier   : BYTE;          { 0: Set AR Flags to this Set              }
                                  { 1: Soft update of AR Flags               }
    ACflags      : SET of uflags; { AC Flag Set for this Subscription Level  }
    ACmodifier   : BYTE;          { 0: Set AC Flags to this Set              }
                                  { 1: Soft update of AC Flags               }
    FilePoints   : INTEGER;       { File Points for this Subscription Level  }
    FPmodifier   : BYTE;          { 0: Set FP to value                       }
                                  { 1: Add value to FP                       }
                                  { 2: Subtract value from FP                }
    Credits      : LONGINT;       { Credits for this Subscription Level      }
    Cmodifier    : BYTE;          { 0: Set Credits to value                  }
                                  { 1: Add value to Credits                  }
                                  { 2: Subtract value from Credits           }
    TimeBank     : INTEGER;       { Time Bank for this Subscription Level    }
    TBmodifier   : BYTE;          { 0: Set Time Bank to value                }
                                  { 1: Add value to Time Bank                }
                                  { 2: Subtract value from TimeBank          }
    SubLength    : INTEGER;       { Length of subscription level             }
                                  { -1: No length (indefinate)               }
    NewSubLevel  : INTEGER;       { New Subscription Level after expiration  }
    ARflags2     : SET of ACRQ;   { AR Flag Set #2 for this Subscription Lev }
    ARmodifier2  : BYTE;          { 0: Set AR Flags #2 to this Set           }
                                  { 1: Soft update of AR Flags #2            }
    RESERVED     : ARRAY[1..14]
                      OF BYTE;    { RESERVED                                 }
END;
    



  languagerec=                          { LANGUAGE.DAT }
  RECORD
        name:STRING[40];                { Description }
        filename:STRING[8];             { [FILENAME].NXL }
        menuname:STRING[8];             { [FILENAME].NXM }
        access:ACString;                { Access Control String }
        displaypath:STRING[79];         { Display File Path
                                          '' = Use Default Path }
        checkdefpath:BOOLEAN;           { If display file does not exist,
                                          check Default Path? }
        startmenu:WORD;                 { Start Menu For this Language }
        RESERVED1:ARRAY[1..50] of BYTE; { RESERVED }
  END;


  langdefrec=                           { Language Definition Files          }
  RECORD                                { ex. ENGLISH.NLD                    }
                                        { 0 character , 200 string records   }
        name:string[40];
        description:array[1..5] of string[70];
        defstring:string[120];
  end;


BaseIDIDX=
RECORD
        BaseID:LONGINT;         { Permanent Base ID - Should match record # }
        Offset:INTEGER;         { Offset to record # in base data file      }
end;

BaseIDX=
RECORD
        Offset:INTEGER;         { Offset to record # in base data file      }
        BaseID:LONGINT;         { Permanent Base ID - Should match record # }
end;

Fbaseidx=
RECORD
        Filename:STRING[8];
END;

BaseTagIDX=
RECORD
        nettagname:string[50];
end;

  MBFlags=                        { Message Base Flags                       }
   (MBUnhidden,                   { whether *VISIBLE* to users w/o access    }
    MBRealname,                   { whether real names are forced            }
    MBFilter,                     { whether to filter ANSI/8-bit ASCII       }
    MBSKludge,                    { strip IFNA kludge lines                  }
    MBSSeenby,                    { strip SEEN-BY lines                      }
    MBNetmail,                    { whether netmail allowed to be sent       }
                                  { from this base                           }
    MBSOrigin,                    { strip origin lines                       }
    MBShowColor);                 { show color in this message base          }

  MBPrivTYPE=                     { MSG Types allowed                        }
   (Private,                      { Private Only                             }
    Public,                       { Public Only                              }
    PubPriv);                     { Public OR Private                        }

  BoardREC=                       { MBASES.DAT : Message base records        }
  RECORD
    Name:STRING[70];              { message base description                 }
    Filename:STRING[8];           { JAM/SQUISH Filename                      }
    NetTagName:STRING[50];        { Network Tag Name                         }
    MBType:INTEGER;               { 0 = Local                                }
                                  { 1 = Echo                                 }
                                  { 2 = Netmail                              }
                                  { 3 = Internet E-Mail                      }
    MSGPath:STRING[40];           { messages pathname                        }
    MBStat:SET of MBFlags;        { message base status vars                 }
    MBPriv:SET of MBPrivType;     { Message Types Allowed                    }
    ACS,                          { access requirement                       }
    PostACS:ACString;             { post access requirement                  }
    MaxMSGS:WORD;                 { max message count                        }
    PassWORD:STRING[20];          { base passWORD                            }
    Text_Color,                   { color of standard text                   }
    Quote_Color,                  { color of quoted text                     }
    Tag_Color,                    { color of taglines                        }
    OldTear_Color,                { color of old tear lines (___ or ~~~)     }
    Tear_Color,                   { color of tear line                       }
    Origin_Color:BYTE;            { color of origin line                     }
    Address:ARRAY[1..30] of BOOLEAN; { Address (1-30) out of NETWORK.DAT     }
                                     { Only one flagged on for ECHOMAIL      }
                                     { Any number for NETMAIL Bases          }
    Origin:BYTE;                  { Origin Line (1-20) out of NETWORK.DAT    }
    Group:BYTE;                   { Group (1-26) out of NETWORK.DAT          }
    MessageType:BYTE;             { 1 = Squish                               }
                                  { 2 = JAM(mbp)(tm)                         }
                                  { 3 = .MSG                                 }
    TagType:BYTE;                 { 0 = Default Tagged                       }
                                  { 1 = Default Untagged                     }
                                  { 2 = Mandatory                            }
    NameUsage:BYTE;               { 0 = Real Name                            }
                                  { 1 = Alias                                }
                                  { 2 = Ask                                  }
    InConfs:set of JoinedConfs;   { Conferences this Message Base is in      }
    Gateway:BYTE;                 { For INTERNET BASES : GATEWAY NUMBER from }
                                  { INTERNET.DAT.  Ignored on other bases.   }
    msgid:longint;                { MSGID to use for next message posted in  }
                                  { this base                                }
    RESERVED1:ARRAY[1..89] of BYTE;  { RESERVED                              }
    BaseID:longint;
  END;


MsgBaseTEMP=
RECORD
    Template     : STRING[70];    { Template Name                            }
    Name         : STRING[70];    { Message base description                 }
    Filename     : STRING[8];     { JAM/SQUISH Message Base Filename         }
                                  { *NOT NEEDED for .MSG                     }
    NetTagName   : STRING[50];    { Network Tag Name                         }
    MBType       : INTEGER;       { 0 = Local                                }
                                  { 1 = Echo                                 }
                                  { 2 = Netmail                              }
                                  { 3 = Internet E-Mail                      }
    MSGPath      : STRING[40];    { Messages pathname                        }
                                  { For JAM/Squish this is the path to the   }
                                  { Message Base Files.  For *.MSG, this is  }
                                  { the path to the .MSG files               }
    MBFlag       : SET of
                        MBFlags;  { Message Base Flags                       }
    MBPriv       : SET of
                        MBPrivTYPE;{ Message Priveledge Level                }
    Access       : ACString;      { Access to this Base                      }
    PostAccess   : ACString;      { Access to Post on this Base              }
    MaxMSGS      : WORD;          { Maximum Messages in this Base            }
    AccessKey    : STRING[20];    { Access Key to this Base                  }

                                  { Following colors are in TEXTATTR form:   }

    TxtColor     : BYTE;          { color of standard text                   }
    QuoteColor   : BYTE;          { color of quoted text                     }
    TagColor     : BYTE;          { color of taglines                        }
    OldTearColor : BYTE;          { color of old tear lines (___ or ~~~)     }
    TearColor    : BYTE;          { color of tear line                       }
    OriginColor  : BYTE;          { color of origin line                     }
    Address      : ARRAY[1..30] of
                        BOOLEAN;  { Address (1-30) out of NETWORK.DAT        }
                                  { Only one TRUE for ECHOMAIL bases         }
                                  { Only one TRUE for INTERNET EMAIL bases   }
                                  { Any number TRUE for NETMAIL Bases        }
    Origin       : BYTE;          { Origin Line (1-20) out of NETWORK.DAT    }
    RESERVED1    : BYTE;          { RESERVED                                 }
    MessageType  : BYTE;          { 1 = Squish                               }
                                  { 2 = JAM(mbp)(tm)                         }
                                  { 3 = .MSG                                 }
    TagType      : BYTE;          { 0 = Default Tagged                       }
                                  { 1 = Default Untagged                     }
                                  { 2 = Mandatory                            }
    NameUsage    : BYTE;          { 0 = Real Name                            }
                                  { 1 = Alias                                }
                                  { 2 = Ask                                  }
                                  { Included for FUTURE USE                  }
    InConfs      : SET of
                     JoinedConfs; { Conferences this Message Base is in      }
    Gateway:BYTE;                 { For INTERNET BASES : GATEWAY NUMBER from }
                                  { INTERNET.DAT.  Ignored on other bases.   }
    RESERVED2    : ARRAY[1..94] of
                        BYTE;     { RESERVED                                 }
END;



confIDX=                          { MCONF?.IDX; FCONF?.IDX }
RECORD
        BaseNum:INTEGER;          { Base Number that is in this conference   }
END;

  fbflags=
   (fbnoratio,                    { if all files are FREE }
    fbunhidden,                   { whether *VISIBLE* to users w/o access }
    fbdirdlpath,                  { if *.NFB file stored in DLPATH }
    fbticbase,                    { if a Network (TIC) type base }
    fbusegifspecs,                { whether to use GifSpecs }
    fbnfmbase,                    { whether NFM uses this base }
    fballowofflinerequest);       { Allow requesting of offline files? }

  ulrec=                          { FBASES.DAT : File base records }
  RECORD
    name:STRING[70];              { area description  }
    filename:STRING[8];           { filename + ".NFB" }
    RESERVEDx:ARRAY[1..4] of BYTE;
    dlpath:STRING[79];            { path to this bases files }
    RESERVED1:ARRAY[1..2] of BYTE;
    maxfiles:INTEGER;             { max files allowed }
    password:STRING[20];          { passWORD required }
    arctype:BYTE;                 { wanted archive type (1..max,0=inactive) }
    cmttype:BYTE;                 { wanted comment type (1..3,0=inactive) }
    fbstat:SET of fbflags;        { file base status vars }
    acs:ACString;                 { access requirements }
    ulacs:ACString;               { upload requirements }
    nameacs:ACString;             { see-names requirements }
    cdrom:BOOLEAN;                { Is this base on a CD? }
    cdul:BOOLEAN;                 { Has this base been uploaded by NFM? }
    cdnum:INTEGER;                { CD-ROM Disk Number associated with }
    allowfilerequest:BOOLEAN;     { Should NxExpress allow file request }
    tagtype:BYTE;
    InConfs:set of JoinedConfs;   { Conferences this File Base is in         }
    BaseID:LONGINT;               { Permanent ID - DO NOT MODIFY!            }
    SortAscending:BOOLEAN;        { Default Sorting - Ascending?             }
    SortBy:CHAR;                  { D - Date                                 }
                                  { B - First line of Description            }
                                  { N - Filename                             }
                                  { E - Extension                            }
                                  { F - Filepoints                           }
                                  { S - Filesize                             }
                                  { T - Times Downloaded                     }
    TicArea:STRING[40];           { Tic Area Name                            }
    res:ARRAY[1..48] of BYTE;     { RESERVED }
  END;

FileBaseTEMP=
RECORD
    Template    : STRING[70];     { Template name                            }
    Name        : STRING[70];     { Base Description                         }
    Filename    : STRING[8];      { NFB Filename (no extension)              }
    RESERVEDx   : ARRAY[1..4] of
                        BYTE;     { RESERVED - DO NOT MODIFY                 }
    DLPath      : STRING[79];     { Path to this file bases files            }
    RESERVED1   : ARRAY[1..2] of
                        BYTE;     { RESERVED - DO NOT MODIFY                 }
    MaxFiles    : INTEGER;        { Maximum files allowed                    }
    passWORD:STRING[20];          { passWORD required }
    arctype,                      { wanted archive type (1..max,0=inactive) }
    cmttype:BYTE;                 { wanted comment type (1..3,0=inactive) }
    fbstat:SET of fbflags;        { file base status vars }
    acs,                          { access requirements }
    ulacs,                        { upload requirements }
    nameacs:ACString;             { see-names requirements }
    cdrom:BOOLEAN;                { Is this base on a CD? }
    cdul:BOOLEAN;                 { Has this base been uploaded by NFM? }
    cdnum:INTEGER;                { CD-ROM Disk Number associated with }
    allowfilerequest:BOOLEAN;     { Should NxExpress allow file request }
    tagtype:BYTE;
    InConfs:set of JoinedConfs;   { Conferences this File Base is in         }
    BaseID:LONGINT;               { Permanent ID - DO NOT MODIFY!            }
    SortAscending:BOOLEAN;        { Default Sorting - Ascending?             }
    SortBy:CHAR;                  { D - Date                                 }
                                  { B - First line of Description            }
                                  { N - Filename                             }
                                  { E - Extension                            }
                                  { F - Filepoints                           }
                                  { S - Filesize                             }
                                  { T - Times Downloaded                     }
    res:ARRAY[1..89] of BYTE;     { RESERVED }
  END;



TYPE
FFlags=
   (ffnotval,                      { if file is NOT validated                }
    ffisrequest,                   { if file is REQUEST                      }
    ffresumelater,                 { if file is RESUME-LATER                 }
    ffisfree,                      { is file free?                           }
    ffchecksecurity,               { check ACS before Download?              }
    ffhidden,                      { is file hidden no matter what?          }
    ffishatched,                   { has file been hatched via TICK ?        }
    ffRESERVED1,                   { RESERVED                                }
    ffRESERVED2,                   { RESERVED                                }
    ffRESERVED3,                   { RESERVED                                }
    ffRESERVED4,                   { RESERVED                                }
    ffRESERVED5,                   { RESERVED                                }
    ffRESERVED6,                   { RESERVED                                }
    ffRESERVED7,                   { RESERVED                                }
    ffRESERVED8,                   { RESERVED                                }
    ffRESERVED9);                  { RESERVED                                }

FheaderRec=
RECORD
    FheaderID    : ARRAY[1..7]
                      of CHAR;     { Char #1 + 'N'+'E'+'X'+'U'+'S'+Char #1   }
    Filename     : STRING[12];     { Filename                                }
    Magicname    : STRING[12];     { Magic name of file                      }
    FilePoints   : INTEGER;        { Filepoints needed to download this file }
    FileSize     : LONGINT;        { File size in bytes                      }
    FileDate     : LONGINT;        { UNIX Time/Date Stamp of File            }
    UploadedDate : LONGINT;        { UNIX Time/Date Stamp of UL              }
    LastDLDate   : LONGINT;        { UNIX Time/Date Stamp Last DLed          }
    NumDownloads : INTEGER;        { Number of times downloaded              }
    UploadedBy   : STRING[36];     { Uploaded by user name                   }
    Access       : ACString;       { Access to this file                     }
    AccessKey    : STRING[20];     { Access Key to this file ''=none         }
    FileFlags    : SET of FFlags;  { File Flags                              }
    RESERVED     : ARRAY[1..30]
                      of BYTE;     { RESERVED                                }
END;
        
FKeywordREC=
RECORD
    Keyword      : STRING[20];     { Keyword (blank=NO MORE KEYWORDS)        }
END;

FDescREC=
RECORD
    Description  : STRING[45];     { Description Line (#1+'EOF'+#1 or        }
                                   { no more lines=Previous Line is last line}
END;



  lcallers=                       { LASTON.DAT : Last few callers records }
  RECORD
    name:STRING[36];              { user name of caller }
    number:INTEGER;               { user number of caller }
    citystate:STRING[30];         { city/state of caller }
    userbaud:STRING[6];           { baud rate called at }
    node:integer;
    dateon:string[8];
    timeon:string[8];
  END;

  eventrec=                       { EVENTS.DAT : Event records }
  RECORD
    active:BOOLEAN;               { whether active }
    description:STRING[30];       { event description (for logs) }
    etype:CHAR;                   { A:CS, C:hat, D:os call, E:xternal }
    execdata:STRING[20];          { errorlevel if "E", commandline if "D" }
    busytime:INTEGER;             { off-hook time before; 0 if none }
    exectime:INTEGER;             { time of execution }
    busyduring:BOOLEAN;           { busy phone DURING event? }
    duration:INTEGER;             { length of time event takes }
    execdays:BYTE;                { bitwise execution days or day of month if monthly }
    monthly:BOOLEAN;              { monthly event? }
  END;

  eflags=
       (AUsers,                    { Allow Users during this event?          }
        AUpload,                   { Allow Uploading during this event?      }
        ADownload,                 { Allow Downloading during this event?    }
        APage,                     { Allow Paging of SysOp during this event?}
        ExecuteOnce,               { Only Execute event once?                }
        Forced);                   { Run event even if it is past start time?}

  eventrec2=                       { EVENTS.DAT : Event records }
  RECORD
    active     : BOOLEAN;          { whether active                          }
    description: STRING[30];       { event description (for logs)            }
    node       : INTEGER;          { Node to execute event on  0 : All       }
    etype      : BYTE;             { 1 : Access Restriction                  }
                                   { 2 : OS Call (.BAT .EXE .COM to run)     }
                                   { 3 : External Event                      }
    execdata   : STRING[20];       { if etype = 1 : Access String            }
                                   {            2 : [drive:][path]filename   }
                                   {            3 : Errorlevel to exit with  }
    busytime   : INTEGER;          { off-hook time before; 0 if none         }
    exectime   : INTEGER;          { time of execution                       }
    busyduring : BOOLEAN;          { busy phone DURING event?                }
    duration   : INTEGER;          { length of time event takes (minutes)    }
    execdays   : BYTE;             { bitwise execution days/day of month     }
    monthly    : BOOLEAN;          { monthly event?                          }
    eventflags : set of eflags;    { event flags                             }
    RESERVED   : array[1..30] of byte;
                                   { RESERVED                                }
  END;


doorIDX=                           { DOORS.IDX / EDITORS.IDX                 }
RECORD
        DoorID:LONGINT;            { DoorID - Should match DoorREC variable  }
        Offset:LONGINT;            { Record Postition in *.DAT file where    }
                                   {    Door/Editor is located               }
END;

DoorTrackREC=
RECORD

        TimesUsed:LONGINT;
        MinutesUsed:LONGINT;
        DTRESERVED:ARRAY[1..100] of BYTE;
END;

EditorFLAGS=
        (SelectTagline,           { Should Nexus prompt for tagline after?   }
         eRESERVED1,
         eRESERVED2,
         eRESERVED3,
         eRESERVED4,
         eRESERVED5,
         eRESERVED6,
         eRESERVED7);

ChatFLAGS=
        (cRESERVED1,
         cRESERVED2,
         cRESERVED3,
         cRESERVED4,
         cRESERVED5,
         cRESERVED6,
         cRESERVED7,
         cRESERVED8);

DoorREC=                          { DOORS.DAT / EDITORS.DAT                  }
RECORD          
    DOORFilename  : STRING[79];   { Path/Filename to Door or Batch File      }
    DOORName      : STRING[40];   { Name for Display of Door                 }
    DOORDropType  : BYTE;         { Drop File Type:                          }
                                  {   1: DOOR.SYS                            }
                                  {   2: DOORFILE.SR                         }
                                  {   3: CHAIN.TXT                           }
                                  {   4: DORINFO1.DEF                        }
                                  {   5: SFDOORS.DAT                         }
                                  {   6: CALLINFO.BBS                        }
                                  {   7: No Drop File                        }
    DOORDropPath  : STRING[79];   { Path to the location to place the Drop   }
                                  { File                                     }
    RESERVED1     : BYTE;         { RESERVED SPACE                           }
    Realname      : BOOLEAN;      { Use Realnames                            }
    MaxMinutes    : REAL;         { Maximum minutes allowed (time left is max}
                                  { if less than this value, 0 means         }
                                  { disabled, use time left always           }
    LocalOnly        : BOOLEAN;   { For EDITORS only (ignored in Doors)      }
    ShowLoadingString: BOOLEAN;   { Display LOADING ... string before loading}
    DRESERVED1    : ARRAY[1..94]
                     of BYTE;     { RESERVED SPACE                           }
    DoorID        : LONGINT;      { Permanent DoorID number (DO NOT MODIFY)  }
    TRACKToday    : doortrackrec; { Door Tracking for Today - used for       }
                                  { running total and then moved to          }
                                  { yesterday at nightly maintenance         }
    TRACKYesterday: doortrackrec; { Door Tracking for Yesterday              }
    TRACKForever  : doortrackrec; { Door Tracking for Forever                }
    EFlags        : SET of        
                     EditorFLAGS; { Flags for EDITORS ONLY                   }
    CFlags        : SET of
                     ChatFLAGS;   { Flags for CHAT PROGRAM ONLY              }
    DRESERVED2    : ARRAY[1..298]
                     of BYTE;     { RESERVED SPACE                           }
END;

{----------------------------------------------------------------------------}
{ Filename: PROTOCOL.DAT                                                     }
{ Location: DATA Directory                                                   }
{ Format  : 1 <ProtREC> record per entry, 0 record is blank buffer           }
{                                                                            }
{ Notes   : This file is used to store the protocol definitions for the BBS. }
{           There is one record for each protocol, and they may be turned on }
{           or off via the <xbActive> flag.                                  }
{                                                                            }
{           FOR INTERNAL PROTOCOLS:  Records 1-5 are used for internal       }
{           protocol definitions.  Records 6-10 are left blank for future    }
{           additions of internal protocols.  These records should NOT be    }
{           removed, and the guidelines below should be followed when        }
{           modifying them.  The following are the UL and DL commands for the}
{           internal protocols:                                              }
{                                                                            }
{           INT_ZMODEM_SEND             Zmodem Send                          }
{           INT_ZMODEM_RECV             Zmodem Receive                       }
{           INT_YMOD-G_SEND             Ymodem/G Send                        }
{           INT_YMOD-G_RECV             Ymodem/G Receive                     }
{           INT_YMODEM_SEND             Ymodem Send                          }
{           INT_YMODEM_RECV             Ymodem Receive                       }
{           INT_XMOD1K_SEND             Xmodem/1K Send                       }
{           INT_XMOD1K_RECV             Xmodem/1K Receive                    }
{           INT_XMODEM_SEND             Xmodem Send                          }
{           INT_XMODEM_RECV             Xmodem Receive                       }
{----------------------------------------------------------------------------}
xbFLAGS=
   (xbActive,                         { Is this protocol active?             }
    xbBatch,                          { Is this protocol a batch protocol?   }
    xbResume,                         { Does this protocol support RESUME?   }
    xbUseOpus,                        { Add OPUS coding to batch list file?  }
    xbNameSingle,                     { Ask for the name when sending 1 file }
    xbINTERNAL,                       { INTERNAL PROTOCOL DEFINITION         }
                                      { RESERVED -- DO NOT MODIFY THIS FLAG!!}
    xbMiniDisplay);                   { INTERNAL - MiniDisplay Mode          }


ProtREC=
RECORD
    Descr       : STRING[70];         { description                          }
    ckeys       : CHAR;               { command key                          }
    xbstat      : SET of
                  xbFLAGS;            { protocol flags                       } 
    acs         : ACString;           { access string                        }
    ulcmd       : STRING[79];         { UL Batch File Name                   }
    dlcmd       : STRING[79];         { DL Batch File Name                   }
    templog     : STRING[79];         { temp. log file                       }
    uloadlog,
    dloadlog    : STRING[79];         { permanent log files                  }
    envcmd      : STRING[60];         { environment setup cmd                }
    dlflist     : STRING[79];         { DL file lists                        }
    ulcode      : INTEGER;            { UL errorcode OK                      }
    dlcode      : INTEGER;            { DL errorcode OK                      }
    maxchrs     : INTEGER;            { max chrs in cmdline                  }
    logpf,
    logps       : INTEGER;            { pos in log file for data             }
    RESERVED    : ARRAY[1..30] of
                  BYTE;               { RESERVED - DO NOT MODIFY!            }
END;

nxwuserrec=                         { NXWUSERS.DAT }
RECORD
        numdl:WORD;                 { Number of Packets Downloaded Today }
        keyWORDs:ARRAY[1..10] of    { KeyWORDs }
                 STRING[20];
        filters:ARRAY[1..10] of     { Filters }
                 STRING[20];
        macros:ARRAY[1..3] of       { Macros }
                 STRING[80];
        archiver,                   { User's Archiver Choice (record) }
        protocol:INTEGER;           { User's Protocol Choice (record) }
        format:WORD;                { User's Format Choice 0=QWK,1=BWAVE }
        bundlefrom:BOOLEAN;         { Bundle Mail From User? }
        passWORD:STRING[20];        { PassWORD }
        newfiles:BOOLEAN;           { Add new file list to bundle? }
        lastrun:LONGINT;            { Last time user used door in unix format }
        res1:ARRAY[1..2] of BYTE;   { RESERVED space }
        twits:ARRAY[1..5] of        { Five user names to "twit" from }
                 STRING[30];        { download packets }
        totalposts:WORD;            { number of posts today }
        totalmsgs:WORD;             { total number of messages downloaded today }
        totalk:WORD;                { total K of packets downloaded today }
        totalfreq:WORD;             { total number of file requests today }
        lastupd:string[8];          { Last time the numdl was reset          }
        hasconfig:boolean;
        res:ARRAY[1..150] of BYTE;  { RESERVED for expansion }
        crc:BYTE;                   { Must be „ }
END;

nxwaverec=                          { NXWAVE.DAT }
RECORD
        Packetname:STRING[8];       { Packet Filename }
        LocalDLPath:STRING[79];     { Local Download Path }
        LocalULPath:STRING[79];     { Local Upload Path }
        DefaultProtocol,            { Default Protocol (Record Number) }
        DefaultArchiver:INTEGER;    { Default Archiver (Record Number) }
        DefaultFormat:WORD;         { 0=QWK,1=BWAVE }
        News:ARRAY[1..5] of
                STRING[12];         { News Files in Graphics Directory }
        LocalTempPath:STRING[79];   { Local temporary directory }
        MaxFREQ:BYTE;               { Maximum File Requests / Day }
        NewFiles:BOOLEAN;           { Generate new file lists? }
        SuppressProtocol:BYTE;      { Suppress protocol output? }
        SuppressArchiver:BYTE;      { Suppress archiver output? }
                                    { 0=Default, 1=Yes, 2=No }
        maxmsgs:INTEGER;            { Maximum messages downloadable / day }
        maxk:INTEGER;               { Maximum K of packets downloadable / day }
        FREQacs:ACString;           { Access required to file request }
        log:BOOLEAN;                { Log? }
        lastupd:LONGINT;            { Last time midnight event was run as
                                      a unix date/time stamp }
        bbstype:byte;               { 1 : Nexus                              }
                                    { 2 : Telegard                           }
                                    { 3 : Renegade                           }
                                    { 4 : PCboard                            }
                                    { 5 : Maximus                            }
                                    { 6+: RESERVED FOR EXPANSION             }
        timeoffset:integer;         { Number of hours offset from UTC        }
        res:ARRAY[1..666] of BYTE;  { RESERVED for Expansion }
        crc:BYTE;                   { Must be „ }
END;

cdrec=                                  { CDS.DAT }
RECORD
    name:STRING[36];                    { Name of CD for Internal Use }
    volumeid:STRING[12];                { Volume ID of CD }
    uniquefile:STRING[40];              { Unique filename to use instead }
    useunique:boolean;                  { Use Unique Filename instead of
                                                VolumeID}
    viewACS:acstring;
    RESERVED:ARRAY[1..40] of BYTE;      { RESERVED }
END;

cdidxrec=                               { CDS.IDX }
RECORD
    drives:ARRAY[1..26] of CHAR; { Drives currently available for CDs }
END;

conrec=
RECORD
        name:STRING[40];
        access:ACString;
        active:BOOLEAN;
        hidden:BOOLEAN;
END;

confrec=                                { CONFS.DAT }
RECORD
        msgconf:ARRAY[1..26] of conrec;  { Message Conferences }
        fileconf:ARRAY[1..26] of conrec;  { File Conferences }
END;


nxsetuprec=
RECORD
        fbmgr:STRING[79];
        ommgr:STRING[79];
        RESERVED:ARRAY[1..158] of BYTE;
        restrict:boolean;               { restrict access to NxSetup by
                                          sysop password }
        speckey:ARRAY[1..10] of
                RECORD
                name:STRING[40];
                path:STRING[79];             { special key functions              }
                END;
        swaptype:byte;
        RESERVED2:ARRAY[1..199] of BYTE;
END;

requestrec=                             { FILE Path\REQUESTS.DAT }
RECORD
    FileAvail  : BOOLEAN;          { whether file has been made available in }
                                   { the Systat.FileReqPath Path             }
    ReqDenied  : BOOLEAN;          { If Sysop has denied File Request        }
    Filename   : STRING[12];       { Filename of File Requested              }
    FileBase   : INTEGER;          { Base Number File is In                  }
    UserReal   : STRING[36];       { User's Real Name that Requested File    }
    RESERVED   : ARRAY[1..100] of
                        BYTE;      { RESERVED                                }                          
end;


flaggedrec=                             { TEMP\FLAGxxxx.DAT }
RECORD
        filename:STRING[65];
        descript:array[1..10] of STRING[45];
        filebase:INTEGER;
        filepoints:INTEGER;
        blocks:LONGINT;
        ttime:real;
        iscdromfile:BOOLEAN;
        isfree:boolean;
END;



mnuflags=
   (clrscrbefore,                 { Clear screen before menu display         }
    dontcenter,                   { Don't center the menu titles!            }
    nomenuprompt,                 { No menu prompt whatsoever?               }
    forcepause,                   { Force a pause before menu display?       }
    autotime,                     { Is time displayed automatically?         }
    filequickchange,              { Allow Filebase QuickChange?              }
    msgquickchange,               { Allow Messagebase QuickChange?           }
    noloadglobal);                { RESERVED                                 }

menurec=                        { MENUS.DAT records }
RECORD
    name:STRING[60];              { Menu Name }
    mnufile:STRING[8];            { Menu Filename (*.MNU) }
    mnuheader:STRING[12];         { Menu Header Filename }
    mnufooter:STRING[12];         { Menu Footer Filename }
    directive:STRING[12];         { Menu Display File (blank=GENERIC) }
    tutorial:STRING[12];          { Menu Help File (blank=GENERIC) }
    fallback:WORD;                { Fallback Menu # }
    menuname:ARRAY[1..3] of
                  STRING[100];    { GENERIC Menu Header }
    menuprompt:STRING[120];       { Menu Prompt }
    acs:ACString;                 { Access Control String }
    accesskey:STRING[15];         { Access Key for Access to Menu }
    forcehelplevel:BYTE;          { Force Help Level to }
    gencols:BYTE;                 { GENERIC Number of Columns }
    gcol:ARRAY[1..3] of BYTE;     { GENERIC Colors }
    menuflags:SET of mnuflags;    { Menu Flags }
  END;
    

newmnuflags=
   (mclrscrbefore,                { Clear screen before menu display         }
    mdontcenter,                  { Don't center the menu titles!            }
    mnomenuprompt,                { No menu prompt whatsoever?               }
    mforcepause,                  { Force a pause before menu display?       }
    mautotime,                    { Is time displayed automatically?         }
    mfilequickchange,             { Allow Filebase QuickChange?              }
    mmsgquickchange,              { Allow Messagebase QuickChange?           }
    mnoloadglobal,                { Do not load Global Commands for this menu}
    mautomenu,                    { Is this menu an auto-execute menu?       }
    mreserved2,
    mreserved3,
    mreserved4,
    mreserved5,
    mreserved6,
    mreserved7,
    mreserved8);

newmenurec=                           { MENUS.DAT records                    }
RECORD
    description: STRING[60];          { Menu Description                     }
    mnufile    : STRING[8];           { Menu Filename (*.MNU)                }
    mnuheader  : ARRAY [1..3] of      { Menu Header Strings                  }
                        STRING[100];
    mnudisplay : STRING[12];          { Menu Display File (blank=GENERIC)    }
    mnuhelp    : STRING[12];          { Menu Help File (blank=GENERIC)       }
    fallback   : INTEGER;             { Fallback Menu #                      }
    menuprompt : ARRAY [1..3] of      { Menu Prompt                          }
                        STRING[100];
    accesss    : ACString;            { Access Control String                }
    accesskey  : STRING[20];          { Access Key for Access to Menu        }
    forcehelp  : BYTE;                { Force Help Level to                  }
    generic    : RECORD               { GENERIC INFORMATION                  }
                   columns : BYTE;    { Number of Columns                    }
                   bracket : BYTE;    { Bracket color in textattr format     }
                   command : BYTE;    { Command color in textattr format     }
                   desc    : BYTE;    { Description color in textattr format }
                 END;
    menuflags  : SET of mnuflags;     { Menu Flags                           }
    RESERVED   : ARRAY [1..100] of    { RESERVED                             }
                        BYTE;
  END;


  cmdflags=
   (hidden,                       { Command is ALWAYS hidden }
    unhidden,                     { Command is ALWAYS visible }
    autoexec,                     { Auto exececute command upon menu startup }
    titleline);                   { Command is a Title Display line }

  commandrec=                       { *.MNU : Command records }
  RECORD
    ldesc:STRING[70];               { long command description }
    sdesc:STRING[35];               { short command description }
    ckeys:STRING[14];               { command-execution keys }
    acs:ACString;                   { access requirements }
    cmdkeys:STRING[2];              { command keys: type of command }
    Mstring:STRING[80];             { MString: command data }
    commandflags:SET of cmdflags;   { command status variables }
  END;

StringIDX=
RECORD
    Offset:ARRAY[1..2000] of LONGINT;
END;


nxEMAILREC=
RECORD
      nomovefile    : STRING[79];      { text file containing names not to   }
                                       { import into the e-mail bases        }
      nobouncefile  : STRING[79];      { text file containing names not to   }
                                       { bounce                              }
      bouncenoexist : BOOLEAN;         { should nxEMAIL bounce messages that }
                                       { are addressed to non-existing users?}
      RESERVED      : ARRAY[1..1000]   { RESERVED -- DO NOT MODIFY!!         }
                        of BYTE;
END;


{-------------------------------INTERNAL USE---------------------------------}

{ SEE CLEAR.PAS - EXAMPLE FOR CLEARANCE PROCESSING }

{  accesstype=(not,less,lessequal,equal,greater,greaterequal);
   
   actype=(Age,Baud,Conference,Gender,Time,Filepoints,SL,TimeLeft,BaseType,
           DayOfWeek,UserFlags,ACFlags);

(* FILE:  SECCLEAR.DAT *)

(* Each current ACS string will (since it is currently 21 bytes) allow for
   up to 10 different Clearances to be placed on it (with 1 byte leftover).
   Nexus will compare the user's statistics against each Clearance Level
   before allowing a user to complete the function                          *)

(* Format for the Securities...

        21 bytes...

        Byte 1   -  Override Clearance #...  If this is defined (i.e. >1)
                    then Nexus will check this Clearance to see if the User
                    meets the criteria.  If so, they are automatically given
                    clearance.

        Rest of the bytes go in the following order:

        Byte 1   -  Clearance Record #
        Byte 2   -  Modifier (AND, OR)

                        AND  -  (Default) This clearance AND the follwing
                                clearance must be TRUE

                        OR   -  This clearance OR the following clearance
                                may be TRUE

*)

(* Comparison Tree:
   
   Check Clearance #1  - each of the 20 elements in the <ClearanceREC> is
                         checked with an implied AND on them.  If ANY of
                         the elements fails, the whole record fails.        *)



One Record BUFFER in SECCLEAR.DAT  -  each ACSstring entry will be turned off
if set to 0

ClearanceREC=ARRAY[1..20] of
RECORD
    Active       : BOOLEAN;
    ACStype      : SET of ACtype;
    ACSmodifier  : SET of ACCESStype;
    ACSdata      : STRING[5];
END;

ClearanceLIST=ARRAY[1..21] of BYTE;

}

{-----------------------------END INTERNAL USE-------------------------------}

HelpIDX=
RECORD
        ControlBlock:longint;
        Topic:string[40];
        RESERVED:ARRAY[1..20] of BYTE;
END;

HelpControlREC=
RECORD
        FirstLine:longint;
        NumLines:integer;
        FirstJump:longint;
        NumJumps:integer;
        RESERVED:ARRAY[1..108] of BYTE;
END;

HelpLineREC=
RECORD
        DLine:STRING[119];
END;

HelpJumpREC=
RECORD
        X1,Y1,X2,Y2:INTEGER;     { where this jump is...  x1,x2 are the
                                   position on the x coordinate in the window,
                                   y1, y2 are the line numbers }
        JumpTo:LONGINT;          { Topic Number }
        RESERVED:ARRAY[1..108] of BYTE;
END;

{
               Filename = [HELPFILE].xxx where xxx is the topic number
[TOPIC]
Lines

}

autobotREC=
RECORD
        Name      : STRING[36];     { Description/Name of AUTOBOT Response   }       
        Trigger   : STRING[36];     { Trigger required to activate AUTOBOT   }
        Response  : STRING[79];     { Filename of message text for response  }
        rFrom     : STRING[36];     { Response "from" name for message field }
        rSubject  : STRING[72];     { Response "subject" for message field   }
        RESERVED  : ARRAY[1..100]   
                        of BYTE;    { RESERVED -- DO NOT MODIFY!!            }
END;

astatREC=
RECORD
        datestart : LONGINT;        { Date these statistics start at         }
        numsent   : LONGINT;        { Number of responses sent               }
        RESERVED  : ARRAY[1..100]
                        of BYTE;    { RESERVED -- DO NOT MODIFY!!            }
END;

listservREC=
RECORD
        Name      : STRING[36];     { Description/Name of the List           }
        Trigger   : STRING[36];     { Trigger required to get on list        }
        Footer    : STRING[79];     { File used as a footer for messages new }
                                    { to the list                            }
        Signup    : STRING[79];     { Text file to send back when a user     }
                                    { subscribes                             }
        Logoff    : STRING[79];     { Text file to send back when a user     }
                                    { removes him/herself from the list      }
        Access    : BYTE;           { 0 - Any message posted in the local    }
                                    {     base will be placed on list        }
                                    { 1 - Any message in local base or in to }
                                    {     list from internet (e-mailed to    }
                                    {     trigger@yourhost.dom               }
        MbaseID   : LONGINT;        { MBaseID of the local message base to   }
                                    { host the list                          }
        UserID    : LONGINT;        { UserID assigned to this list for new   }
                                    { message scans                          }
        Gateway   : BYTE;           { GATEWAY # to use                       }
        replyaddr : STRING[70];     { reply address to use when posting to   }
                                    { this list                              }
        usereplyto: BOOLEAN;        { Use reply-to line in message (GIGO)    }
        RESERVED  : ARRAY[1..127]
                        of BYTE;    { RESERVED -- DO NOT MODIFY              }
END;

listusersREC=
RECORD
        address   : STRING[70];     { E-mail address of user on the list     }
        RESERVED  : ARRAY[1..100]
                        of BYTE;    { RESERVED -- DO NOT MODIFY              }
END;

extutilsREC=
RECORD
     Description:STRING[60];
     Executable:STRING[255];
     reserved:ARRAY[1..707] of BYTE;
END;

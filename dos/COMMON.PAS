{$A+,B+,D-,E+,F+,I+,L-,N-,O+,R+,S+,V-}
unit common;

interface

uses
  crt,dos,spawno,myio3,tmpcom,tagunit;

{$I nexus.inc}
{$I build.inc}

const strlen=80;
      dsaves:integer=0;
      topscrnum:integer=0;

TYPE
(*  actiontypes=(showmessage,getfirst,nomessage,normal,waiting,newmsg,global,cconly); *)

  confptr=^confrec;
  CurActREC=
  RECORD
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
  END;
  CurActPtr=^CurActREC;
  StringPtr=^StringIDX;
  ModemPtr=^ModemREC;
  MatrixPtr=^MatrixREC;

  
var ver:string[30];
    MSGSCAN:^TagRecordOBJ;
(*    actions:set of actiontypes; *)
    online:onlinerec;             { Online Information }
    onlinef:file of onlinerec;    { NODEXXXX.DAT }
    newtemp:string[79];           { Old Temp Path }
    newswap:string[79];           { Old Swap Path }
    cnode:integer;                { Current Node }
    uf:file of userrec;           { USER.LST                              }
    bf:file of boardrec;          { BOARDS.DAT                            }
    xf:file of protrec;           { PROTOCOL.DAT                          }
    ulf:file of ulrec;            { UPLOADS.DAT                           }
    sf:file of smalrec;           { NAMES.LST                             }
    curact:curactptr;
    
    sysopf:file;                  { NEXxxx.LOG                            }
    nodemsg:nodemsgrec;
(*  sysopf1,                      { SLOGxxxx.LOG                          } *)
    trapfile,                     { TRAP*.MSG                             }
    cf:text;                      { CHAT*.MSG                             }
    systatf:file of MatrixREC;
    systat:MatrixPtr;             { configuration information             }
    lcall:lcallers;
    securityf:file of securityrec;
    stridx:stringptr;
    security:securityrec;
    systemf:file of systemrec;
    syst:systemrec;
    fddt:datetime;
    modemr:ModemPTR;              { modem configuration                   }
    langr:languagerec;
    
    thisuser:userrec;             { user's account records                }
    cdavail:array[1..26] of integer;

    msg_on:longint;               { current message being read            }

    { PROTOCOLS }
    numprotocols:integer;         { # of protocols                        }

    { FILE BASES }
    memuboard:ulrec;              { uboard in memory                      }
    readuboard,                   { current uboard # in memory            }
    maxulb,                       { # of file bases                       }
    fileboard:integer;            { file base user is in                  }

    { MESSAGE BASES }
    memboard:boardrec;            { board in memory                       }
    readboard,                    { current board # in memory             }
    numboards,                    { # of message bases                    }
    board:integer;                { message base user is in               }

    spd:string[6];                { current modem speed, "KB" for local   }
    spdarq:boolean;               { whether modem connected with ARQ      }

(*****************************************************************************)

    
    { message stuff }
    himsg:longint;                { highest message number }

    con:confptr;
    buf:string[255];              { macro buffer                          }


    cmdlist,                      { list of cmds on current menu          }
    chatr:string[80];             { last chat reason                      }
    start_dir:string[80];         { directory BBS was executed from       }

    tim,                          { time last keystroke entered           }
    timeon:datetimerec;           { time user logged on                   }

    choptime,                     { time to chop off for system events    }
    extratime,                    { extra time - given by F7/F8, etc      }
    freetime,                     { free time                             }
    oltime:real;

    exteventtime,                 { # minutes before external event       }

    chatt,                        { number chat attempts made by user     }
    etoday,                       { E-mail sent by user this call         }
    ftoday,                       { feedback sent by user this call       }
    lastprot,                     { last protocol #                       }
    ldate,                        { last daynum()                         }
    lil,                          { lines on screen since last pausescr() }
    mread,                        { # public messages has read this call  }
    pap,                          { characters on this line so far        }
    ptoday,                       { posts made by user this call          }
    realsl,                       { real SL level of user (for F9)        }
    usernum:integer;              { user's user number                    }

    fsearchtext:string[20];

    defaultst:string[80];

    chelplevel,                   { current help level                    }
    curco,                        { current ANSI color                    }
    lastco,                       { last ANSI color                       }
    elevel:byte;                  { ERRORLEVEL to exit with               }
    utimeleft:integer;            { Time Left for this call               }

const
    disablelocalkeys:boolean=FALSE;
    noynnl:boolean=FALSE;         { do not print nl in yn question        }
    inwfcmenu:boolean=FALSE;
    telnet:boolean=FALSE;
    cdmap:boolean=FALSE;
    curtagged:boolean=FALSE;      { For MSG and FILE base changes, whether
                                    current base in list is tagged        }
    curbnum:integer=-2;
    mcimod:byte=0;                { 0 - no modification   1 - L justify   }
                                  { 2 - right justify                     }
    mcichange:integer=0;
    sysopon:boolean=FALSE;
    mcipad:string='';
    curdesc:integer=1;
    totaldesclines:integer=0;
    testcode:boolean=FALSE;
    nlnode:byte=1;
    iv_expired:boolean=FALSE;
    usewfcmenu:boolean=TRUE;
    callfromarea:byte=1;
    callfromarea2:byte=1;
    editorok:boolean=TRUE;
    ulname:string[36]='No One';
    ulgen:char='U';
    ullast:longint=0;
    ulcall:string[40]='Nowhere';
    mconf:byte=1;
    csubdesc:string[40]='';
    amconf:set of joinedconfs=[];
    currentswap:byte=0;
    fconf:byte=1;
    emailto:string[80]='';
    interto:string[50]='';
    interaddr:string[30]='';
    lastupdatetime:longint=0;
    afconf:set of joinedconfs=[];
    mpausescr:boolean=FALSE;      { pausing for messages or regular?      }
    hardback:byte=255;
    skipcommand:boolean=FALSE;
    clanguage:byte=1;
    fflag:boolean=FALSE;          { whether flagging files or downloading }
    dlflag:boolean=FALSE;
    lastyesno:boolean=FALSE;      { for MENU COMMAND Y/N Quest. }
    ansidetected:boolean=FALSE;
    tbaddcall:integer=0;
    tbwithcall:integer=0;
    allowabort:boolean=TRUE;      { are aborts allowed?                   }
    echo:boolean=TRUE;            { is text being echoed? (FALSE=use echo chr)}
    hangup2:boolean=TRUE;          { is user offline now?                  }
    nofile:boolean=TRUE;          { did last pfl() file NOT exist?        }
    answerbaud:longint=0;         { baud rate to answer the phone at      }
    onekcr:boolean=TRUE;          { does ONEK prints<CR> upon exit?       }
    onekda:boolean=TRUE;          { does ONEK display the choice?         }
    semaphore:boolean=FALSE;       { does Getkey() check for sema files?   }
    slogging:boolean=TRUE;        { are we outputting to the SysOp log?   }
    wantout:boolean=TRUE;         { output text locally?                  }
    wcolor:boolean=TRUE;          { in chat: was last key pressed by SysOp? }
    shelling:byte=0;              { 1:protocol 2:archiver }
    displayingmenu:boolean=FALSE;
    mabort:boolean=FALSE;
{    fabort:boolean=FALSE; }
    noexit:boolean=FALSE;
    lcycle:boolean=FALSE;
    badfpath:boolean=FALSE;       { is the current DL path BAD?           }
    badini:boolean=FALSE;         { was last call to ini/inu value()=0, s<>"0"? }
    beepend:boolean=FALSE;        { whether to beep after caller logs off }
    bnp:boolean=FALSE;            { was file base name printed yet?       }
    cfo:boolean=FALSE;            { is chat file open?                    }
    ch:boolean=FALSE;             { are we in chat mode?                  }
    chatcall:boolean=FALSE;       { is the chat call "noise" on?          }
    checkit:boolean=FALSE;        { }
    croff:boolean=FALSE;          { are CRs turned off?                   }
    ctrljoff:boolean=FALSE;       { turn color to #1 after ^Js??          }
    doneafternext:boolean=FALSE;  { offhook and exit after next logoff?   }
    doneday:boolean=FALSE;        { are we done now? ready to drop to DOS? }
    dyny:boolean=FALSE;           { does YN return Yes as default?        }
    enddayf:boolean=FALSE;        { perfrom "endday" after logoff?        }
    fastlogon:boolean=FALSE;      { if a FAST LOGON is requested          }
    forwarding_msg:boolean=FALSE;
    sysopshelling:boolean=FALSE;
    copymessage:boolean=FALSE;
    hungup:boolean=FALSE;         { did user drop carrier?                }
    incom:boolean=FALSE;          { accepting input from com?             }
    inmsgfileopen:boolean=FALSE;  { are we //U ULing a file into a message? }
    lan:boolean=FALSE;            { was last post/email anonymous/other?  }
    lastcommandgood:boolean=FALSE;{ was last command a REAL command?      }
    lastcommandovr:boolean=FALSE; { override PAUSE? (NO pause?)           }
    lmsg:boolean=FALSE;           { }
    smlist:string[70]='';
    mc:char=#0;
    overlayinems:boolean=TRUE;
    fastlocal:boolean=FALSE;
    noshowmci:boolean=FALSE;
    noshowpipe:boolean=FALSE;
    localioonly:boolean=FALSE;    { local I/O ONLY?                       }
    repaddress:string[30]='';
    newmenutoload:boolean=FALSE;  { menu command returns TRUE if new menu to load }
    nightly:boolean=FALSE;        { execute hard-coded nightly event?     }
    nofeed:boolean=FALSE;         { }
    nopfile:boolean=FALSE;        { }
    outcom:boolean=FALSE;         { outputting to com?                    }
    printingfile:boolean=FALSE;   { are we printing a file?               }
    quitafterdone:boolean=FALSE;  { quit after next user logs off?        }
    reading_a_msg:boolean=FALSE;  { is user reading a message?            }
    listing_files:boolean=FALSE;
    ldesc:integer=1;
    read_with_mci:boolean=FALSE;  { read message with MCI?                }
    shutupchatcall:boolean=FALSE; { was chat call "SHUT UP" for this call? }
    trapping:boolean=FALSE;       { are we trapping users text?           }
    useron:boolean=FALSE;         { is there a user on right now?         }
    wascriterr:boolean=FALSE;     { critical error during last call?      }
    wasnewuser:boolean=FALSE;     { did a NEW USER log on?                }
    write_msg:boolean=FALSE;      { is user writing a message?            }
    infilelist:boolean=FALSE;

    telluserevent:boolean=FALSE;     { has user been told about the up-coming event? }
    exiterrors:byte=254;          { ERRORLEVEL for Critical Error exit    }
    exitnormal:byte=0;            { ERRORLEVEL for Normal exit            }
    exitnetworkmail:byte=10;
    unlisted_filepoints=10;        { file points for unlisted downloads    }
    privuser:string[36]='';
    currentfile:string[79]='';

var
    lastread:longint;             { current lastread pointer for this base }
    fqarea,mqarea:boolean;        { file/message quick area changes       }
    last_menu,                    { last menu loaded                      }
    curmenu:word;                 { current menu loaded                   }
    first_time:boolean;           { first time loading a menu?            }

    newdate:string[10];           { NewScan pointer date                  }
    lrn:integer;                  { last record # for recno/nrecno        }
    lfn:string;                     { last filename for recno/nrecno        }
    menufname:string[8];

    batchtime:real;               { }
    numbatchfiles:integer;        { # files in DL batch queue             }

function centered(s:string;x:integer):string;
function substall(src,old,new:string):string;
function showdatestr(unix:longint):string;
procedure getnewsecurity(x:integer);
procedure getsubscription(x:byte);
function recreatelanguage:boolean;
procedure getlang(b:byte);
procedure showmemory;
procedure ansig(x,y:integer);
procedure timeslice;
procedure scaninput(var s:string; allowed:string; lfeed:boolean);
procedure updateonline;
Procedure DrawWindow(x1,y1,x2,y2,tpe,bk,bk2,f1,f2:integer;default:boolean;s:astr);
function processMCI(ss:string):string;
function infconf(b:integer):boolean;
function inmconf(b:integer):boolean;
function getnumstringlines(s:string):integer;
function lenn(s:string):integer;
function multsk:string;
function lennmci(s:string):integer;
function datelong:string;
procedure loaduboard(i:integer);
procedure loadboard(i:integer);
function smci3(s2:string;var ok:boolean):string;
procedure sprompt(s:string);
procedure tc(n:integer);
function mso:boolean;
function fso:boolean;
function cso:boolean;
function gstring(x:integer):STRING;
function so:boolean;
function timer:real;
function fbaseac(b:integer):boolean;
function mbaseac(nb:integer):boolean;
procedure opensysopf;
procedure LogOfCallers(x:integer);
{procedure newcomptables;}
procedure changefileboard(b:integer);
procedure changeboard(b:integer);
function freek(d:integer):longint;    (* See disk space *)
function nma:integer;
function okansi:boolean;
function okcolor:boolean;
function nsl:real;
function ageuser(bday:string):integer;     (* returns age of user by birthdate *)
function allcaps(s:string):string;    (* returns a COMPLETELY capitalized string *)
function caps(s:string):string;                (* returns a capitalized string.. *)
procedure remove_port;
procedure iport;
procedure sclearwindow;
procedure schangewindow(needcreate:boolean; newwind:integer);
procedure inuserwindow;
procedure sendcom1(c:char);
function recom1(var c:char):boolean;
procedure term_ready(ready_status:boolean);
procedure checkhangup;
function hangup:boolean;

function cinkey:char;
function intime(tim:real; tim1,tim2:integer):boolean;
					      (* check whether in time range *)
function sysop1:boolean;
function adrv(s:string):string;
function u_daynum(dt:string):longint;
function checkpw:boolean;
function sysop:boolean;
function stripcolor(o:string):string;
procedure sl1(c:char;s:string);
procedure sl2(level:byte; c:char; s:string);
procedure sysophead;
function tch(s:string):string;
function time:string;
function date:string;
function value(s:string):longint;
function cstr(i:longint):string;
function cstrf(i:longint):string;
function cstrn(i:longint):string;
function cstrnfile(i:longint):string;
function cstrf2(i:longint;ivryear:integer):string;
function nam:string;
procedure shelldos(bat:boolean; cl:string; var rcode:integer);
procedure sysopshell(takeuser:boolean);
procedure redrawforansi;
function leapyear(yr:integer):boolean;
function days(mo,yr:integer):integer;
function daycount(mo,yr:integer):integer;
function daynum(dt:string):integer;
function dat:string;
procedure getkey(var c:char);
procedure pr1(s:string);
procedure pr(s:string);
procedure sde; {* restore curco colors (DOS and tc) loc. after local *}
procedure sdc;
procedure stsc;
procedure setc(c:byte);
(*procedure cl(c:integer);
procedure promptc(c:char);*)
procedure dosansi(c:char);
procedure prompt(s:string);
function sqoutsp(s:string):string;
function exdrv(s:string):byte;
function mln(s:string; l:integer):string;
function mlnnomci(s:string; l:integer):string;
function mlnmci(s:string; l:integer):string;
function mrn(s:string; l:integer):string;
function mn(i,l:longint):string;
procedure pausescr;
procedure print(s:string);
procedure nl;
procedure prt(s:string);
procedure ynq(s:string);
procedure mpl(c:integer);
procedure tleft;
procedure prestrict(u:userrec);
procedure topscr;
procedure saveuf;
procedure loadurec(var u:userrec; i:integer);
procedure saveurec(u:userrec; i:integer);
function empty:boolean;
function inkey:char;
procedure outkey(c:char);
procedure dm(i:string; var c:char);
procedure cls;
procedure blockwritestr(var f:file;s:string);
procedure wait(b:boolean);
procedure swac(var u:userrec; r:uflags);
function tacch(c:char):uflags;
procedure acch(c:char; var u:userrec);
procedure sprint(s:string);
procedure lcmds(len,c:byte; c1,c2:string);
procedure inittrapfile;
procedure chatfile(b:boolean);
function aonoff(b:boolean; s1,s2:string):string;
function onoff(b:boolean):string;
function syn(b:boolean):string;
procedure pyn(b:boolean);
function yn:boolean;
function pynq(s:string):boolean;
procedure inu(var i:integer);
procedure inul(var i:longint);
procedure ini(var i:byte);
procedure inil(var i:byte);
procedure inputwn1(var v:string; l:integer; flags:string; var changed:boolean);
procedure inputwn(var v:string; l:integer; var changed:boolean);
procedure inputwnwc(var v:string; l:integer; var changed:boolean);
procedure inputscript(var s:string; ml:integer; flags:string);
procedure inputmain(var s:string; ml:integer; flags:string);
procedure inputwc(var s:string; ml:integer);
procedure input(var s:string; ml:integer);
procedure inputdef(var s:string; ml:integer; flags:string);
procedure inputdef1(var v:string; l:integer; flags:string; var changed:boolean);
procedure inputd(var s:string; ml:integer);
procedure inputdl(var s:string; ml:integer);
procedure inputdln(var s:string; ml:integer);
procedure inputdlnp(var s:string; ml:integer);
procedure inputl(var s:string; ml:integer);
procedure inputcaps(var s:string; ml:integer);
procedure onek(var c:char; ch:string);
procedure local_input1(var i:string; ml:integer; tf:boolean);
procedure local_input(var i:string; ml:integer);
procedure local_inputl(var i:string; ml:integer);
procedure local_onek(var c:char; ch:string);
function centre(s:string):string;
procedure wkey(var abort,next:boolean);
procedure wkey2(var ch:char; var abort,next:boolean);
function ctim(rl:real):string;
function tlef:string;
function longtim(dt:datetimerec):string;
function dt2r(dt:datetimerec):real;
procedure r2dt(r:real; var dt:datetimerec);
procedure timediff(var dt:datetimerec; dt1,dt2:datetimerec);
procedure getdatetime(var dt:datetimerec);
function getdow:byte;
function cstrl(li:longint):string;
function cstrr(rl:real; base:integer):string;
procedure savesystat;  (* save systat *)
procedure pfl(fn:string; var abort,next:boolean; cr:boolean);
procedure printfile(fn:string);
function exist(fn:string):boolean;
procedure printf(fn:string);
procedure mmkey(var s:string);

procedure com_flush_rx;
function com_carrier:boolean;
function com_rx_empty:boolean;
procedure com_set_speed(speed:word);

procedure chat;
Procedure SplitScreen;
procedure skey1(c:char);
function getlongversion(tp:byte):string;
function verline(i:integer):string;
function aacs1(u:userrec; un:Longint; s:string):boolean;
function aacs(s:string):boolean;
procedure GetPhone(var s:string; force:boolean);
procedure GetZip(var s:string);
procedure GetBirth(var s:string;entr:boolean);

procedure DisableInterrupts;
procedure EnableInterrupts;
procedure clearANSI;

implementation

uses    common1,        common2,        common3,        common4,
        common5,        multi,       misc1,          misc2,
        doors,          file0,          mail0,          ansi1,
        mkmisc,         mkglobt,        mkstring,       mkdos,
        runprog,        script;


{----------------------------------------------------------------------------}
{                                                                            }
{  These routines have been placed in the overlay to decrease the            }
{  in-memory size of the BBS.  Routines that are used frequently, and are    }
{  HIGHLY related to the overall speed of the BBS, have been kept out        }
{  of the overlay file, and remain in memory at all times.                   }
{                                                                            }
{----------------------------------------------------------------------------}

function getnumeditors:string; begin getnumeditors:=common5.getnumeditors; end;
function getcurrenteditor:string; begin getcurrenteditor:=common5.getcurrenteditor; end;
function tch(s:string):string; begin tch:=common5.tch(s); end;
function time:string; begin time:=common5.time; end;
function date:string; begin date:=common5.date; end;
function value(s:string):longint; begin value:=common5.value(s); end;
function cstr(i:longint):string; begin cstr:=common5.cstr(i); end;
function cstrf(i:longint):string; begin cstrf:=common5.cstrf(i); end;
function cstrn(i:longint):string; begin cstrn:=common5.cstrn(i); end;
function cstrnfile(i:longint):string; begin cstrnfile:=common5.cstrnfile(i); end;
function cstrf2(i:longint;ivryear:integer):string; begin cstrf2:=common5.cstrf2(i,ivryear); end;
function cstrl(li:longint):string; begin cstrl:=common5.cstrl(li); end;
function cstrr(rl:real; base:integer):string; begin cstrr:=common5.cstrr(rl,base); end;
function getlongversion(tp:byte):string; begin getlongversion:=common5.getlongversion(tp); end;
function verline(i:integer):string; begin verline:=common5.verline(i); end;
function aacs(s:string):boolean; begin
        aacs:=common5.aacs(s);
        end;
procedure showmemory; begin common2.showmemory; end;
function centered(s:string;x:integer):string; begin
        centered:=common5.centered(s,x); end;
procedure pfl(fn:string; var abort,next:boolean; cr:boolean); begin
        common5.pfl(fn,abort,next,cr); end;
procedure printfile(fn:string); begin
        common5.printfile(fn); end;
function exist(fn:string):boolean; begin
        exist:=common5.exist(fn); end;
procedure printf(fn:string); begin
        common5.printf(fn); end;
procedure GetPhone(var s:string; force:boolean); begin
        common3.getphone(s,force); end;
procedure GetZip(var s:string); begin
        common3.getzip(s); end;
procedure GetBirth(var s:string;entr:boolean);
        begin
        common3.getbirth(s,entr);
        end;
function getc(c:byte):string; begin getc:=common5.getc(c); end;
function checkpw:boolean; begin checkpw:=common1.checkpw; end;
procedure pausescr; begin common1.pausescr; end;
procedure wait(b:boolean); begin common1.wait(b); end;
procedure inittrapfile; begin common1.inittrapfile; end;
procedure chatfile(b:boolean); begin common1.chatfile(b); end;
procedure local_input1(var i:string; ml:integer; tf:boolean);
	  begin common1.local_input1(i,ml,tf); end;
procedure local_input(var i:string; ml:integer);
	  begin common1.local_input(i,ml); end;
procedure local_inputl(var i:string; ml:integer);
	  begin common1.local_inputl(i,ml); end;
function adrv(s:string):string;
	  begin adrv:=common1.adrv(s); end;
function u_daynum(dt:string):longint;
	  begin u_daynum:=common1.u_daynum(dt); end;
procedure local_onek(var c:char; ch:string);
	  begin common1.local_onek(c,ch); end;
function chinkey:char; begin chinkey:=common1.chinkey; end;
procedure inli1(var s:string); begin common1.inli1(s); end;
procedure chat; begin common1.chat; end;
Procedure SplitScreen; begin common1.splitscreen; end;
procedure sysopshell(takeuser:boolean);
	  begin common2.sysopshell(takeuser); end;
procedure showsysfunc; begin common1.showsysfunc; end;
procedure redrawforansi; begin common1.redrawforansi; end;
procedure clearANSI; begin ansi1.clearANSI; end;
procedure timeslice; begin multi.doslice; end;

procedure skey1(c:char); begin common2.skey1(c); end;
procedure remove_port; begin common2.remove_port; end;
procedure iport; begin common2.iport; end;
{procedure initthething; begin common2.initthething; end;}
{procedure gameport; begin common2.gameport; end;}
procedure sendcom1(c:char); begin common2.sendcom1(c); end;
function recom1(var c:char):boolean; begin recom1:=common2.recom1(c); end;
procedure term_ready(ready_status:boolean); begin common2.term_ready(ready_status); end;
procedure sclearwindow; begin common2.sclearwindow; end;
procedure schangewindow(needcreate:boolean; newwind:integer);
  begin common2.schangewindow(needcreate,newwind); end;
procedure inuserwindow; begin common2.inuserwindow; end;
procedure topscr; begin common2.topscr; end;
procedure tleft; begin common2.tleft; end;
procedure saveuf; begin common2.saveuf; end;

procedure inu(var i:integer); begin common3.inu(i); end;
procedure inul(var i:longint); begin common3.inul(i); end;
procedure ini(var i:byte); begin common3.ini(i); end;
procedure inil(var i:byte); begin common3.inil(i); end;
procedure inputwn1(var v:string; l:integer; flags:string; var changed:boolean);
  begin common3.inputwn1(v,l,flags,changed); end;
function datelong:string; begin datelong:=common5.datelong; end;
procedure inputwn(var v:string; l:integer; var changed:boolean);
  begin common3.inputwn(v,l,changed); end;
procedure inputwnwc(var v:string; l:integer; var changed:boolean);
  begin common3.inputwnwc(v,l,changed); end;
procedure inputscript(var s:string; ml:integer; flags:string);
  begin common3.inputscript(s,ml,flags); end;
procedure inputmain(var s:string; ml:integer; flags:string);
  begin common3.inputmain(s,ml,flags); end;
procedure inputwc(var s:string; ml:integer); begin common3.inputwc(s,ml); end;
procedure inputdef(var s:string; ml:integer; flags:string); begin common3.inputdef(s,ml,flags); end;
procedure inputdef1(var v:string; l:integer; flags:string; var changed:boolean);
	begin common3.inputdef1(v,l,flags,changed); end;
procedure input(var s:string; ml:integer); begin common3.input(s,ml); end;
procedure inputd(var s:string; ml:integer); begin common3.inputd(s,ml); end;
procedure inputdl(var s:string; ml:integer); begin common3.inputdl(s,ml); end;
procedure inputdln(var s:string; ml:integer); begin common3.inputdln(s,ml); end;
procedure inputdlnp(var s:string; ml:integer); begin common3.inputdlnp(s,ml); end;
procedure inputl(var s:string; ml:integer); begin common3.inputl(s,ml); end;
procedure inputcaps(var s:string; ml:integer);
  begin common3.inputcaps(s,ml); end;
procedure mmkey(var s:string); begin common3.mmkey(s); end;

procedure com_flush_rx; begin tmpcom.com_flush_rx; end;
function com_carrier:boolean; begin com_carrier:=tmpcom.com_carrier; end;
function com_rx_empty:boolean; begin com_rx_empty:=tmpcom.com_rx_empty; end;
procedure com_set_speed(speed:word); begin tmpcom.com_set_speed(speed); end;
function inmconf(b:integer):boolean; begin inmconf:=common5.inmconf(b); end;
function infconf(b:integer):boolean; begin infconf:=common5.infconf(b); end;

function ctim(rl:real):string; begin ctim:=common5.ctim(rl); end;
function tlef:string; begin tlef:=common5.tlef; end;
function longtim(dt:datetimerec):string; begin longtim:=common5.longtim(dt); end;
function dt2r(dt:datetimerec):real; begin dt2r:=common5.dt2r(dt); end;
procedure r2dt(r:real; var dt:datetimerec); begin common5.r2dt(r,dt); end;
procedure timediff(var dt:datetimerec; dt1,dt2:datetimerec); begin common5.timediff(dt,dt1,dt2); end;
function getdow:byte; begin getdow:=common5.getdow; end;
procedure getdatetime(var dt:datetimerec); begin common5.getdatetime(dt); end;
function showdatestr(unix:longint):string; begin showdatestr:=common5.showdatestr(unix); end;



(*****************************************************************************)

function tacch(c:char):uflags;
begin
  case c of
    'A':tacch:=rlogon;
    'B':tacch:=rchat;
    'C':tacch:=rvalidate;
    'D':tacch:=rbackspace;
    'E':tacch:=rpost;
    'F':tacch:=remail;
    'G':tacch:=rmsg;
    'H':tacch:=fnodlratio;
    'I':tacch:=fnopostratio;
    'J':tacch:=fnofilepts;
    'K':tacch:=fnodeletion;
  end;
end;

function getnumstringlines(s:string):integer;
var x,x2,x3:integer;
begin
x:=0;
x2:=pos('|LF|',allcaps(s));
x3:=pos(#13#10,s);
while (x2<>0) or (x3<>0) do begin
inc(x);
if (x2<x3) and (x2<>0) then begin
        s:=copy(s,pos('|LF|',allcaps(s))+4,length(s));
end else begin
        if (x3<x2) and (x3<>0) then begin
        s:=copy(s,pos(#13#10,s)+2,length(s));
        end else begin
                if (x2<>0) and (x3=0) then begin
                        s:=copy(s,pos('|LF|',allcaps(s))+4,length(s));
                end else begin
                        s:=copy(s,pos(#13#10,s)+2,length(s));
                end;
        end;
end;
x2:=pos('|LF|',allcaps(s));
x3:=pos(#13#10,s);
end;
if (s<>'') then inc(x);
getnumstringlines:=x;
end;

function gstring(x:integer):STRING;
var f:file;
    s:^string;
    numread:word;
begin
new(s);
if (stridx^.offset[x]<>-1) then begin
assign(f,adrv(systat^.gfilepath)+langr.filename+'.NXL');
{$I-}reset(f,1); {$I+}
if (ioresult<>0) then begin
        sl1('!','Error reading '+adrv(systat^.gfilepath)+langr.filename+'.NXL');
        gstring:='';
        exit;
end;
{$I-} seek(f,stridx^.offset[x]); {$I+}
if (ioresult<>0) then begin
        sl1('!','Error reading '+adrv(systat^.gfilepath)+langr.filename+'.NXL');
        gstring:='';
        close(f);
        exit;
end;
blockread(f,s^[0],1,numread);
if (numread<>1) then begin
        sl1('!','Error reading '+adrv(systat^.gfilepath)+langr.filename+'.NXL');
        gstring:='';
        close(f);
        exit;
end;
blockread(f,s^[1],ord(s^[0]),numread);
if (numread<>ord(s^[0])) then begin
        sl1('!','Error reading '+adrv(systat^.gfilepath)+langr.filename+'.NXL');
        gstring:='';
        close(f);
        exit;
end;
close(f);
end else s^:='';
gstring:=s^;
dispose(s);
end;

procedure getsubscription(x:byte);
var ssf:file of subscriptionrec;
    ss:subscriptionrec;
    oldflags:set of uflags;
    c:char;
begin
assign(ssf,adrv(systat^.gfilepath)+'SUBSCRIP.DAT');
{$I-} reset(ssf); {$I+}
if (ioresult<>0) then begin
        sprint('%120%No Subscriptions Set.  Please inform Sysop!');
        sl1('!','Error reading SUBSCRIP.DAT - exiting.');
        hangup2:=TRUE;
        exit;
end;
if (x<=filesize(ssf)-1) then begin
        seek(ssf,x);
        read(ssf,ss);
        close(ssf);
        thisuser.sl:=ss.sl;
        realsl:=ss.sl;
        if (ss.armodifier=0) then 
        thisuser.ar:=ss.arflags
        else 
        for c:='A' to 'Z' do
        if (c in ss.arflags) and not(c in thisuser.ar) then thisuser.ar:=thisuser.ar+[c];
        if (ss.armodifier2=0) then 
        thisuser.ar2:=ss.arflags2
        else 
        for c:='A' to 'Z' do
        if (c in ss.arflags2) and not(c in thisuser.ar2) then thisuser.ar2:=thisuser.ar2+[c];
        if (ss.acmodifier=0) then begin
                for c:='A' to 'K' do
                        if (tacch(c) in ss.acflags) then thisuser.ac:=thisuser.ac+[tacch(c)]
                                else thisuser.ac:=thisuser.ac-[tacch(c)];
        end else begin
                for c:='A' to 'K' do
                if (tacch(c) in ss.acflags) then thisuser.ac:=thisuser.ac+[tacch(c)];
        end;
        case ss.fpmodifier of
                0:begin
                  thisuser.filepoints:=ss.filepoints;
                  end;
                1:begin
                  thisuser.filepoints:=thisuser.filepoints+ss.filepoints;
                  end;
                2:begin
                  thisuser.filepoints:=thisuser.filepoints-ss.filepoints;
                  end;
        end;
        case ss.cmodifier of
                1:begin
                  thisuser.credit:=ss.credits;
                  end;
                2:begin
                  thisuser.credit:=thisuser.credit+ss.credits;
                  end;
                3:begin
                  thisuser.credit:=thisuser.credit-ss.credits;
                  end;
        end;
        case ss.timebank of
                1:begin
                  thisuser.timebank:=ss.timebank;
                  end;
                2:begin
                  thisuser.timebank:=thisuser.timebank+ss.timebank;
                  end;
                3:begin
                  thisuser.timebank:=thisuser.timebank-ss.timebank;
                  end;
        end;
        thisuser.subscription:=x;
        thisuser.subdate:=u_daynum(datelong+'  '+time);
        sl1(':','Set subscription: '+stripcolor(ss.description));
        csubdesc:=ss.description;
end else begin
        close(ssf);
        if (x=1) then begin
                sprint('%120%No Subscriptions Set.  Please inform Sysop!');
                sl1('!','No subscriptions set - exiting.');
                hangup2:=TRUE;
        end else begin
                sl1('!','Invalid Subscription: '+cstr(x)+' - Not Changed');
        end;
end;
end;

procedure getnewsecurity(x:integer);
begin
{$I-} reset(securityf); {$I-}
if (ioresult<>0) then begin
        sprint('Error Opening SECURITY.DAT');
        hangup2:=TRUE;
        exit;
end;
if (x<=100) and (x>0) then begin
        seek(securityf,x);
        read(securityf,security);
end;
close(securityf);
end;

function recreatelanguage:boolean;
var langf:file of languagerec;
    langr:languagerec;
    x:integer;
begin
assign(langf,adrv(systat^.gfilepath)+'LANGUAGE.DAT');
{$I-} rewrite(langf); {$I+}
if (ioresult<>0) then begin
        displaybox('Error Creating LANGUAGE.DAT',4000);
        recreatelanguage:=FALSE;
        end;
langr.name:='English';
langr.filename:='ENGLISH';
langr.menuname:='ENGLISH';
langr.access:='';
langr.displaypath:='';
langr.checkdefpath:=FALSE;
langr.startmenu:=6;
for x:=1 to sizeof(langr.reserved1) do langr.reserved1[x]:=0;
write(langf,langr);
write(langf,langr);
close(langf);
end;


procedure getlang(b:byte);
var langf:file of languagerec;
    ok:boolean;
    fstringf:file;
    numread:word;
begin
ok:=TRUE;
assign(langf,adrv(systat^.gfilepath)+'LANGUAGE.DAT');
{$I-} reset(langf); {$I+}
if (ioresult<>0) then begin
         ok:=recreatelanguage;
         if (ok) then begin
                {$I-} reset(langf); {$I+}
                if (ioresult<>0) then begin
                        sl1('!','Error opening LANGUAGE.DAT!');
                        sprint('%120%Error opening Language Control File!  Hanging up!');
                        hangup2:=TRUE;
                        exit;
                end;
         end else begin
                        sl1('!','Error opening LANGUAGE.DAT!');
                        sprint('%120%Error opening Language Control File!  Hanging up!');
                        hangup2:=TRUE;
                        exit;
         end;
end;
if (b<=filesize(langf)-1) then begin
        seek(langf,b);
        read(langf,langr);
end else begin
        if (filesize(langf)-1>=1) then begin
                seek(langf,1);
                read(langf,langr);
        end else begin
                        sl1('!','Error opening LANGUAGE.DAT!');
                        sprint('%120%Error opening Language Control File!  Hanging up!');
                        hangup2:=TRUE;
                        close(langf);
                        exit;
        end;
end;
close(langf);
assign(fstringf,adrv(systat^.gfilepath)+langr.filename+'.NXL');
filemode:=66; 
{$I-} reset(fstringf,1); {$I-}
if ioresult<>0 then begin
        sl1('!','Error reading '+adrv(systat^.gfilepath)+langr.filename+'.NXL ... Exiting.');
        writeln('Error reading '+adrv(systat^.gfilepath)+langr.filename+'.NXL ... Exiting.');
        halt(exiterrors);
end;
blockread(fstringf,stridx^,sizeof(stridx^),numread);
if (numread<>sizeof(stridx^)) then begin
        sl1('!','Error reading '+adrv(systat^.gfilepath)+langr.filename+'.NXL ... Exiting.');
        writeln('Error reading '+adrv(systat^.gfilepath)+langr.filename+'.NXL ... Exiting.');
        halt(exiterrors);
end;
close(fstringf);
menufname:=allcaps(langr.menuname);
end;

function substone(src,old,new:string):string;
var p:integer;
begin
  if (old<>'') then begin
    p:=pos(old,src);
    if (p>0) then begin
      insert(new,src,p+length(old));
      delete(src,p,length(old));
    end;
  end;
  substone:=src;
end;

function okcolor:boolean;
begin
okcolor:=(color in thisuser.ac) or (inwfcmenu);
end;

function okansi:boolean;
begin
if (ansidetected) or (inwfcmenu) then
  okansi:=(ansi in thisuser.ac)
else okansi:=FALSE;
end;

procedure ansig(x,y:integer);
begin
  if (spd<>'KB') then pr1(#27+'['+cstr(y)+';'+cstr(x)+'H');
  if (wantout) then gotoxy(x,y);
  pap:=x-1;
  lil:=y-1;
end;

procedure updateonline;
{var o:onlinerec;}
begin
filemode:=66;
assign(onlinef,adrv(systat^.gfilepath)+'USER'+cstrn(cnode)+'.DAT');
{$I-} reset(onlinef); {$I+}
if (ioresult<>0) then begin
        if (exist(adrv(systat^.gfilepath)+'USER'+cstrn(cnode)+'.DAT')) then begin
            sl1('!','Unable to update online node record!');
            exit;
        end;
        rewrite(onlinef);
end;
{seek(onlinef,0);
read(onlinef,o);}
seek(onlinef,0);
write(onlinef,online);
close(onlinef);
end;




procedure savesystat;
var f:file;
    x:integer;
    t:file;
    sr:searchrec;
begin
  rewrite(systatf); write(systatf,systat^); close(systatf);
  findfirst(adrv(systat^.semaphorepath)+'INUSE.*',anyfile,sr);
  while (doserror=0) do begin
        x:=value(copy(sr.name,pos('.',sr.name)+1,length(sr.name)-pos('.',sr.name)));
        if (x=0) then x:=1000;
        if (x<>cnode) then begin
                filemode:=66;
                assign(f,adrv(systat^.semaphorepath)+'INUSE.'+cstrnfile(x));
                {$I-} reset(f); {$I+}
                if (ioresult=0) then begin
                        close(f);
                        assign(t,adrv(systat^.semaphorepath)+'MXUPDATE.'+cstrnfile(x));
			rewrite(t);
			close(t);
		end;
        end;
   findnext(sr);
   end;
end;

Procedure DrawWindow(x1,y1,x2,y2,tpe,bk,bk2,f1,f2:integer;default:boolean;s:astr);
var
c,x,b:integer;
for3,for1,for2,shadow,text:byte;

begin
if (default) then begin
for1:=0 or (3 shl 4);
for2:=11 or (3 shl 4);
for3:=0 or (3 shl 4);
shadow:=8;
text:=15 or (3 shl 4);
end else begin
for1:=f1 or (bk shl 4);
for2:=f2 or (bk shl 4);
for3:=f1 or (bk2 shl 4);
shadow:=8 or (0 shl 4);
text:=15 or (bk shl 4);
end;
setc(for1);
ansig(x1,y1);
sprompt('Ú');
for x:=(x1+1) to (x2-1) do sprompt('Ä');
setc(for2);
sprompt('¿');
setc(shadow);
sprompt('Ü');
if (tpe=1) then c:=y2-1; 
if (tpe>1) then c:=y2-2;
for x:=(y1+1) to (c) do begin
ansig(x1,x);
setc(for1);
sprompt('³');
setc(for3);
for b:=(x1+1) to (x2-1) do sprompt(' ');
setc(for2);
sprompt('³');
setc(shadow);
sprompt('Û');
end;
ansig(x1,c+1);
setc(for1);
sprompt('À');
setc(for2);
for x:=(x1+1) to (x2-1) do sprompt('Ä');
sprompt('Ù'); setc(shadow); sprompt('Û');
if (tpe>1) then begin
	ansig(x1,y2);
	setc(for1);
	for x:=x1 to x2 do sprompt(' ');
	setc(shadow);sprompt('Û');setc(text);
	ansig(x1+(((((x2-x1)+1)-lenn(s)) div 2)-((((x2-x1)+1)-lenn(s)) mod 2)),y2);
	prompt(s);
	setc(shadow);
	end;
if (tpe=1) then ansig((x1+1),(c+2))
	else ansig((x1+1),(c+3));
for x:=(x1+1) to (x2+1) do sprompt('ß');
setc(7);
end;

    function getlastparen(s8:string):integer;
    var x8,x9:integer;
    begin
    x8:=length(s8);
    x9:=0;
    while (x8>1) and (x9=0) do begin
    if (s8[x8]=')') then x9:=x8;
    dec(x8);
    end;
    getlastparen:=x9;
    end;

function multsk:string;
var regs:registers;
    hiver,lover:string;

begin
          Case MultiTasker of
                NoTasker     : begin
                        regs.ah:=$30;
                        intr($21,regs);
                        multsk:='DOS v'+cstr(regs.al)+'.'+cstr(regs.ah);
                        end;
                DESQview     : begin
                        multsk:='DESQview';
                        end;
                WindowsTask  : begin
                        HiVer:=cstr(MultiVerMaj);
                        LoVer:=cstr(MultiVerMin);
                        if (Hiver='4') then begin
                        if (LoVer='10') then begin
                                multsk:='Windows 98';
                        end else
                        if (LoVer='00') then begin
                                multsk:='Windows 95 v'+Hiver+'.'+LoVer;
                        end else
                        if (LoVer='03') then begin
                                multsk:='Windows 95 v'+Hiver+'.'+LoVer;
                        end else
                                multsk:='Windows v'+Hiver+'.'+LoVer;
                        end else begin
                                multsk:='Windows v'+Hiver+'.'+LoVer+'/Enhanced';
                        end;
                        end;
                OS2          : begin
                        multsk:='OS/2 Warp';
                        end;
                DoubleDOS    : multsk:='DoubleDOS';
                WindowsNTTask: begin
                               multsk:='Windows NT/2000/XP';
                                end;
                end;
end;


function getkratio:real;
var t,r:real;
    j:integer;
    batchf:file of flaggedrec;
    batch:flaggedrec;
    olduboard:integer;
begin
          olduboard:=fileboard;
          t:=0;
          assign(batchf,adrv(systat^.temppath)+'FLAG'+cstrn(cnode)+'.DAT');
          {$I-} reset(batchf); {$I+}
          if (ioresult<>0) then begin
                numbatchfiles:=0;
          end else begin
          if (numbatchfiles<>filesize(batchf)) then numbatchfiles:=filesize(batchf);
          if (numbatchfiles<>0) then begin
          j:=1;
          while (j<=numbatchfiles) do begin
              read(batchf,batch);
              loaduboard(batch.filebase);
              if (not (fbnoratio in memuboard.fbstat)) and not(batch.isfree) then
              t:=t+(batch.blocks);
              inc(j);
          end;
          end;
          close(batchf);
        end;
        if (fileboard<>olduboard) then loaduboard(olduboard);
        t:=t+thisuser.dk;
        if (thisuser.uk=0) then r:=(t+0.001) else
        r:=(t+0.001)/(thisuser.uk+0.001);
        if (trunc(r)<1) then r:=1;
        getkratio:=r;
end;

  function showblocks(l2:longint):STRING;
  var tstr,tstr2:string;
      ti:integer;
  begin
  l2:=(l2 div 1024);
  if (l2>1024) then begin
        tstr:=cstr(l2 div 1024);
        tstr2:=cstr(trunc(((l2 mod 1024)/1024)*100));
        while (length(tstr2)<2) do tstr2:='0'+tstr2;
        ti:=value(copy(tstr2,1,1));
        if (ti>4) then inc(ti);
        if (ti=10) then begin
                tstr:=cstr((l2 div 1024)+1);
                ti:=0;
        end;
        showblocks:=tstr+'.'+cstr(ti)+'M';
  end else begin
        showblocks:=cstrl(l2)+'k';
  end;
  end;

  function ptsf:string;
  var s:string;
      xit:integer;
      avail:boolean;
  begin
    avail:=TRUE;
    if (memuboard.cdrom) then begin
           avail:=FALSE;
           for xit:=1 to 26 do begin
                if (memuboard.cdnum=cdavail[xit]) then begin
                        avail:=TRUE;
		end;
           end;
           if not(avail) then begin
                ptsf:=gstring(370);
           end;
    end;
    if (ffisrequest in NXF.Fheader.fileFlags) and (avail) then begin
                ptsf:=gstring(371);
    end else
      if (ffresumelater in NXF.Fheader.fileflags) and (avail) then begin
                ptsf:=gstring(372);
      end else
      if (ffnotval in NXF.Fheader.fileflags) and (avail) then begin
                ptsf:=gstring(373);
        end else if (avail) then begin
          if ((systat^.uldlratio) and (not systat^.fileptratio)) then begin
                if (fbnoratio in memuboard.fbstat) or (ffisfree in NXF.Fheader.fileflags) then
                s:=gstring(374) else s:=gstring(375);
                ptsf:=s;
          end else begin
                if (fbnoratio in memuboard.fbstat) or (ffisfree in NXF.Fheader.fileflags) then      
                s:=gstring(374) else s:=cstr(NXF.Fheader.filepoints);
                ptsf:=s;
          end;
          end;
  end;

function substall(src,old,new:string):string;
var p:integer;
    newstr:string;
begin
  newstr:='';
  p:=1;
  while p>0 do begin
    p:=pos(allcaps(old),allcaps(src));
    if (p>0) then begin
      newstr:=newstr+copy(src,1,p-1)+new;
      src:=copy(src,p+length(old),length(src));
    end;
  end;
  if (src<>'') then newstr:=newstr+src;
  substall:=newstr;
end;

function smci3(s2:string;var ok:boolean):string;
var c2:char;
    s:string;
    j,i:integer;
    l:longint;
    i2,r:real;
    add:addrtype;
    newmod:byte;
    newchange:integer;
    done:boolean;


begin
  newmod:=0;
  s:='#NEXUS#';
  if (noshowmci) and (allcaps(s2)<>'SHOWMCI') then begin
	smci3:=#28+s2+'|';
	exit;
  end;
  if (allcaps(s2)='NOMCI') then begin
        noshowmci:=TRUE;
        s:='';
  end else
  if (allcaps(s2)='SHOWMCI') then begin
        noshowmci:=FALSE;
        s:='';
  end else
  if (allcaps(s2)='NOCOLOR') then begin
        noshowpipe:=TRUE;
        s:='';
  end else
  if (allcaps(s2)='SHOWCOLOR') then begin
        noshowpipe:=FALSE;
        s:='';
  end else
  if (allcaps(s2)='LICTO') then begin
        s:='Open Source';
  end else
  if (allcaps(s2)='LICNUM') then begin
        s:='Open Source';
  end else
  if (allcaps(s2)='VERSION') then begin
        s:=getlongversion(4);
  end else
  if (allcaps(s2)='NEXUSDIR') then begin
        s:=bslash(TRUE,start_dir);
  end else
  if (allcaps(s2)='TRUETEMP') then begin
        s:=bslash(TRUE,systat^.temppath);
  end else
  if (allcaps(s2)='DATADIR') then begin
        s:=bslash(TRUE,systat^.gfilepath);
  end else
  if (allcaps(s2)='NMNAME') then begin
        s:=nodemsg.sentby;
  end else
  if (allcaps(s2)='NMNODE') then begin
        s:=cstr(nodemsg.sentbynode);
  end else
  if (allcaps(s2)='NMMESSAGE') then begin
        s:=nodemsg.message;
  end else
  if (allcaps(s2)='MINBAUD') then begin
        s:=cstr(modemr^.minimumbaud);
  end else
  if (allcaps(s2)='LOCKBEGIN') then begin
        s:=ctim(modemr^.lockbegintime[getdow]);
  end else
  if (allcaps(s2)='LOCKEND') then begin
        s:=ctim(modemr^.lockendtime[getdow]);
  end else
  if (allcaps(s2)='NUMEDITORS') then begin
        s:=getnumeditors;
  end else
  if (allcaps(s2)='CUREDITOR') then begin
        s:=getcurrenteditor;
  end else
  if (allcaps(s2)='CURLANG') then begin
        s:=langr.name;
  end else
  if (allcaps(copy(s2,1,2))='PL') and (mcimod=0) then begin
        newmod:=1;
        newchange:=value(copy(s2,3,length(s2)-2));
        if (newchange=0) then newmod:=0;
        s:='';
  end else
  if (allcaps(copy(s2,1,2))='PR') and (mcimod=0) then begin
        newmod:=2;
        newchange:=value(copy(s2,3,length(s2)-2));
        if (newchange=0) then newmod:=0;
        s:='';
  end else
  if (allcaps(copy(s2,1,2))='PC') and (mcimod=0) then begin
        newmod:=3;
        newchange:=value(copy(s2,3,length(s2)-2));
        if (newchange=0) then newmod:=0;
        s:='';
  end else
  if (allcaps(s2)='NLNODE') then s:=cstr(nlnode) else
  if (allcaps(s2)='NLNAME') then begin
        if (systat^.aliasprimary) then
        s:=online.name
        else s:=online.real;
  end else
  if (allcaps(s2)='NLFROM') then s:=online.business else
  if (allcaps(s2)='NLAVAIL') then begin
        if (online.available) then s:=gstring(95) else s:=gstring(96);
  end else
  if (allcaps(s2)='NLACT') then s:=online.activity else
  if (allcaps(s2)='MCONF') then s:=chr(mconf+64) else
  if (allcaps(s2)='MCONFNAME') then begin
        if (mconf in [1..26]) then begin
        s:=con^.msgconf[mconf].name;
        end else begin
        s:='%120%All Conferences';
        end;
  end else
  if (allcaps(s2)='MSGNEW') and (mbopened) then begin
        if (msg_on>lastread) then s:=gstring(679) else s:='';
        end else
  if (allcaps(s2)='MSGTO') and (mbopened) then begin
        s:='';
        if (memboard.mbtype=3) then begin
                if (emailto<>'') then s:=emailto else s:='';
        end;
        if (s='') then begin
        s:=currentMSG^.GetTo;
        if (s='') then s:='All';
        if (memboard.mbtype=2) then begin
        CurrentMSG^.GetDest(add);
        s:=s+', '+cstr(add.zone)+':'+cstr(add.net)+
                '/'+cstr(add.node);
        if (add.point<>0) then s:=s+'.'+cstr(add.point);
        end;
        end;
  end else
  if (allcaps(s2)='MSGFROM') and (mbopened) then begin
        s:=currentMSG^.Getfrom;
        if (memboard.mbtype=2) then begin
    CurrentMSG^.getorig(add);
    s:=s+', '+cstr(add.zone)+':'+cstr(add.net)+
                '/'+cstr(add.node);
    if (add.point<>0) then s:=s+'.'+cstr(add.point);
    end;
  end else
  if (allcaps(s2)='MSGDATE') and (mbopened) then begin
        s:=currentMSG^.GetDate;
  end else
  if (allcaps(s2)='MSGTIME') and (mbopened) then begin
        s:=currentMSG^.GetTime;
  end else
  if (allcaps(s2)='MSGSUBJ') and (mbopened) then begin
        s:=currentMSG^.GetSubj;
  end else
  if (allcaps(s2)='MSGFLAGS') and (mbopened) then begin
    s:='';
    if (currentmsg^.islocal) then s:='loc ';
    if not(public in memboard.mbpriv) or (currentmsg^.isPriv) then s:=s+'pvt ';
    if (memboard.mbtype=2) then begin
    if (currentmsg^.isHold) then s:=s+'hld ';
    if (currentmsg^.isCrash) then s:=s+'cra ';
    if (currentmsg^.isKillsent) then s:=s+'kil ';
    if (currentmsg^.isSent) then s:=s+'snt ';
    end;
    if (memboard.mbtype=2) or (memboard.mbtype=0) then
    if (currentmsg^.isFattach) then s:=s+'f/a ';
    if (memboard.mbtype=2) then begin
    if (currentmsg^.isFileReq) then s:=s+'frq ';
    if (currentmsg^.isRcvd) then s:=s+'rcv ';
    if (currentmsg^.isDirect) then s:=s+'dir';
    end;
    if (copy(s,length(s),1)=' ') then s:=copy(s,1,length(s)-1);
  end else
  if (allcaps(s2)='MSGREFER') and (mbopened) then begin
      s:='';
      if (CurrentMSG^.GetRefer<>0) then begin
         if (CurrentMSG^.GetRefer<>0) then s:=s+'<-'+cstr(CurrentMSG^.GetRefer);
      end;
  end else
  if (allcaps(s2)='MSGNEXT') and (mbopened) then begin
      s:='';
      if (CurrentMSG^.GetSeeAlso<>0) then begin
         if (CurrentMSG^.GetSeeAlso<>0) then s:=cstr(CurrentMSG^.GetSeeAlso)+'->';
      end;
  end else
  if (allcaps(s2)='MBNUMBER') then begin
        if (curbnum=-2) then begin
                s:=cstr(board);
        end else begin
                if (curbnum<>-1) then begin
                        s:=cstr(curbnum);
                end else begin
                        s:='-----';
                end;
        end;
  end else
  if (allcaps(s2)='MBNAME') then begin
        s:='%030%'+memboard.name; 
	end else
  if (allcaps(s2)='MBTAGGED') then begin
        if (curtagged) then begin
                s:='+';
        end else begin
                s:=' ';
        end;
  end else
  if (allcaps(s2)='MSGFILE') then begin 
        s:=newtemp+'MSGTMP'; 
	end else
  if (allcaps(s2)='HIGHMSG') then s:=cstr(himsg) else
  if (allcaps(s2)='MAXLINES') then begin
          if (cso) then i:=systat^.csmaxlines else i:=systat^.maxlines;
	  s:=cstr(i);
	end else
  if (allcaps(s2)='MBASE') then begin
          s:=' %080%['+cstr(board)+'%080%] %030%'+memboard.name;
	end else
  if (allcaps(s2)='CURMSG') then s:=cstr(msg_on) else
  if (allcaps(s2)='FPOINTS') then s:=cstr(thisuser.filepoints) else
  if (allcaps(s2)='FBASE') then begin
          s:=' %080%['+cstr(fileboard)+'%080%] %030%'+memuboard.name;
	end else
  if (allcaps(s2)='FCONF') then s:=chr(fconf+64) else
  if (allcaps(s2)='FCONFNAME') then begin
        if (fconf in [1..26]) then begin
                s:=con^.fileconf[fconf].name;
        end else begin
                s:='%120%All Conferences';
        end;
  end else
  if (allcaps(s2)='NUMFILES') then begin
        fiscan(i);
        s:=cstr(i);
  end else
  if (allcaps(s2)='FLFLAGGED') then begin
        if (isflagged(NXF.Fheader.filename,fileboard)) then s:=gstring(369) else
                s:=gstring(368);
  end else
  if (allcaps(s2)='FLNEW') then begin
        if (NXF.Fheader.UploadedDate>=u_daynum(newdate)) then s:=gstring(381) else
                s:=gstring(380);
  end else      
  if (allcaps(s2)='FLNUM') then begin
        s:=cstr(topp);
  end else
  if (allcaps(s2)='FLNAME') then begin
        if (fsearchtext<>'') then begin
                s:=substall(NXF.Fheader.Filename,fsearchtext,gstring(385)+fsearchtext+gstring(387));
        end else begin
        s:=NXF.Fheader.filename;
        end;
  end else
  if (allcaps(s2)='FLMAGIC') then begin
        s:=NXF.Fheader.magicname;
  end else
  if (allcaps(s2)='FLDESC') then begin
        s:=NXF.GetDescLine;
        if (s<>#1+'EOF'+#1) then begin
        if (fsearchtext<>'') then begin
                s:=substall(s,fsearchtext,gstring(385)+fsearchtext+gstring(386));
        end;
        end else s:='';
        inc(curdesc);
  end else
  if (allcaps(s2)='FLPTS') then begin
        s:=cstr(NXF.Fheader.filepoints);
  end else
  if (allcaps(s2)='FLULBY') then begin
        s:=NXF.Fheader.UploadedBy;
  end else
  if (allcaps(s2)='FLULDATE') then begin
        s:=showdatestr(NXF.Fheader.UploadedDate);
  end else
  if (allcaps(s2)='FLLASTDL') then begin
        s:=showdatestr(NXF.Fheader.LastDLDate);
  end else
  if (allcaps(s2)='FLDL') then begin
        s:=cstr(NXF.Fheader.NumDownloads);
  end else
  if (allcaps(s2)='FLSIZE') then begin
        s:=showblocks(NXF.Fheader.FileSize);
  end else
  if (allcaps(s2)='FLDATE') then begin
        s:=showdatestr(NXF.Fheader.FileDate);
  end else
  if (allcaps(s2)='FLSTAT') then begin
        s:=ptsf;
  end else
  if (allcaps(s2)='FBNUMBER') then begin
        if (curbnum=-2) then begin
                s:=cstr(fileboard);
        end else begin
                if (curbnum<>-1) then begin
                        s:=cstr(curbnum);
                end else begin
                        s:='-----';
                end;
        end;
  end else
  if (allcaps(s2)='FBTAGGED') then begin
        if (curtagged) then begin
                s:='+';
        end else begin
                s:=' ';
        end;
  end else
  if (allcaps(s2)='ULFILE') then s:=currentfile else
  if (allcaps(s2)='FBNAME') then begin
        s:='%030%'+memuboard.name;
	end else
  if (allcaps(s2)='FBFREE') then begin
          s:=cstrl(freek(exdrv(adrv(memuboard.dlpath))));
	end else
  if (allcaps(s2)='DLFLAG') then s:=cstr(numbatchfiles) else
  if (allcaps(s2)='ULDLNUM') then begin
        if (thisuser.uploads=0) then i2:=thisuser.downloads+numbatchfiles+0.001
        else
        i2:=(thisuser.downloads+numbatchfiles+0.001)/(thisuser.uploads+0.001);
        if (i2=0) then i2:=1;
        s:='1 to '+cstr(trunc(i2));
        end else
  if (allcaps(s2)='ULDLKB') then begin
        r:=getkratio;
        s:='1k to '+cstr(trunc(r))+'k';
        end else
  if (allcaps(s2)='UNICK') then s:=thisuser.nickname else
  if (allcaps(s2)='UREAL') then s:=thisuser.realname else
  if (allcaps(s2)='UFIRST') then s:=copy(thisuser.realname,1,pos(' ',thisuser.realname)-1)
	else
  if (allcaps(s2)='ULAST') then begin
          i:=length(thisuser.realname);
          while ((thisuser.realname[i]<>' ') and (i>1)) do begin
            s:=copy(thisuser.realname,i,(length(thisuser.realname)-i)+1);
	    dec(i);
	  end;
	end else
  if (allcaps(s2)='UALIAS') then s:=thisuser.name else
  if (allcaps(s2)='UNAME') then s:=nam else
  if (allcaps(s2)='UCALLFROM') then begin
        if (thisuser.business<>'') then begin
        s:=thisuser.business;
        end else begin
        s:=thisuser.citystate;        
        end;
  end else
  if (allcaps(s2)='UGENDER') then s:=thisuser.sex else
  if (allcaps(s2)='ULASTON') then begin
        unixtodt(thisuser.laston,fddt);
        s:=formatteddate(fddt,'MM/DD/YYYY');
  end else
  if (allcaps(s2)='ULNAME') then s:=ulname else
  if (allcaps(s2)='ULCALL') then begin
        s:=ulcall;
  end else
  if (allcaps(s2)='ULGEN') then s:=ulgen else
  if (allcaps(s2)='ULLAST') then begin
        unixtodt(ullast,fddt);
        s:=formatteddate(fddt,'MM/DD/YYYY');
  end else
  if (allcaps(s2)='UADDRESS1') then s:=thisuser.street else
  if (allcaps(s2)='UADDRESS2') then s:=aonoff(thisuser.street2<>'',
                                        thisuser.street2,' ') else
  if (allcaps(s2)='UCITYST') then s:=thisuser.citystate else
  if (allcaps(s2)='UZIPCODE') then s:=thisuser.zipcode else
  if (allcaps(s2)='UPASSWORD') then begin
        s:=thisuser.pw;
  end else
  if (allcaps(s2)='UPWDENC') then begin
        s:='';
        for i:=1 to length(thisuser.pw) do s:=s+gstring(5);
  end else
  if (allcaps(s2)='UCOLOR') then begin
        if (color in thisuser.ac) then s:=gstring(104) else s:=gstring(105);
  end else
  if (allcaps(s2)='UUSETAGS') then begin
        if (usetaglines in thisuser.ac) then s:=gstring(104) else s:=gstring(105);
  end else
  if (allcaps(s2)='UPAUSE') then begin
        if (pause in thisuser.ac) then s:=gstring(104) else s:=gstring(105);
  end else
  if (allcaps(s2)='UINPUT') then begin
        if (onekey in thisuser.ac) then s:='QuickKey' else s:='Full Line';
  end else
  if (allcaps(s2)='SLEVEL') then s:=cstr(thisuser.sl) else
  if (allcaps(s2)='SLDESC') then s:=security.description else
  if (allcaps(s2)='SUBDESC') then s:=csubdesc else
  if (allcaps(s2)='SUBLEFT') then s:=subdaysleft else
  if (allcaps(s2)='SUBDAYS') then s:=subdays else
  if (allcaps(s2)='TIMELEFT') then s:=tlef else
  if (allcaps(s2)='UTITLE') then s:=thisuser.title else
  if (allcaps(s2)='UPHONE1') then s:=thisuser.phone1 else
  if (allcaps(s2)='UPHONE2') then s:=thisuser.phone2 else
  if (allcaps(s2)='UPHONE3') then s:=thisuser.phone3 else
  if (allcaps(s2)='UPHONE4') then s:=thisuser.phone4 else
  if (allcaps(s2)='UOPTION1') then s:=thisuser.option1 else
  if (allcaps(s2)='UOPTION2') then s:=thisuser.option2 else
  if (allcaps(s2)='UOPTION3') then s:=thisuser.option3 else
  if (allcaps(s2)='UTERM') then begin
                if (okansi) then s:='Ansi' else
		s:='TTY';
	end else
  if (allcaps(s2)='USCREEN') then s:='80x'+cstr(thisuser.pagelen) else
  if (allcaps(s2)='TIMEBANK') then s:=cstr(thisuser.timebank) else
  if (allcaps(s2)='TBADDED') then s:=cstr(thisuser.timebankadd) else
  if (allcaps(s2)='USERUK') then s:=cstr(thisuser.uk) else
  if (allcaps(s2)='USERDK') then s:=cstr(thisuser.dk) else
  if (allcaps(s2)='USERUL') then s:=cstr(thisuser.uploads) else
  if (allcaps(s2)='USERDL') then s:=cstr(thisuser.downloads) else
  if (allcaps(s2)='USERPOST') then s:=cstr(thisuser.msgpost) else
  if (allcaps(s2)='USERFEED') then s:=cstr(thisuser.feedback) else
  if (allcaps(s2)='LCNAME') then s:=lcall.name else
  if (allcaps(s2)='LCFROM') then s:=lcall.citystate else
  if (allcaps(s2)='LCBAUD') then s:=lcall.userbaud else
  if (allcaps(s2)='LCNODE') then s:=cstr(lcall.node) else
  if (allcaps(s2)='LCDATE') then s:=lcall.dateon else
  if (allcaps(s2)='LCTIME') then s:=lcall.timeon else
  if (allcaps(s2)='NODE') then s:=cstr(cnode) else
  if (allcaps(s2)='PADDEDNODE') then s:=cstrn(cnode) else
  if (allcaps(s2)='SEMANODE') then s:=cstrnfile(cnode) else
  if (allcaps(s2)='TEMPDIR') then s:=newtemp else
  if (allcaps(s2)='LOCKBAUD') then begin
        if not(modemr^.lockport) then s:='0' else
        s:=cstrl(modemr^.waitbaud) 
	end else
  if (allcaps(s2)='BAUD') then begin
        if (not(incom) and not(outcom)) then s:=cstrl(0)
		else s:=cstrl(answerbaud);
	end else
  if (allcaps(s2)='PORT') then s:=cstrl(modemr^.comport) else
  if (allcaps(s2)='PORTLONG') then begin
        if (localioonly) then s:='local' else
        s:='com'+cstrl(modemr^.comport);
  end else
  if (allcaps(s2)='MULTIOS') then s:=multsk else
  if (allcaps(s2)='CMDLIST') then s:=cmdlist else
  if (allcaps(s2)='CREASON') then s:=chatr else
  if (allcaps(s2)='BELL') then s:=^G else
  if (allcaps(s2)='LF') then s:=^M^J else
  if (allcaps(s2)='BS') then s:=^H' '^H else
  if (copy(allcaps(s2),1,2)='BS') then begin
        s:='';
        l:=value(copy(s2,3,length(s2)-2));
        if (l=0) then l:=1;
        j:=1;
        while (j<=l) do begin
                s:=s+^H' '^H;
                inc(j);
        end;
  end else
  if (allcaps(copy(s2,1,4))='GOTO') then begin
        if (okansi) then begin
                ansig(value(copy(s2,5,pos(',',s2)-5)),
                value(copy(s2,pos(',',s2)+1,length(s2)-pos(',',s2))));
        end;
        s:='';
  end else
  if (allcaps(s2)='PAUSE') then begin
        s:=#3#2;
        end else
  if (allcaps(s2)='PAUSEYN') then begin
        s:=#3#3;
        end else
  if (allcaps(s2)='CLS') then begin
        s:=#3#1;
  end else
  if (copy(allcaps(s2),1,5)='DELAY') then begin
        i:=value(copy(s2,6,length(s2)-5));
        s:=#3#4+chr(i);
	end else
  if (allcaps(s2)='BBSNAME') then s:=systat^.bbsname else
  if (allcaps(s2)='BBSPHONE') then s:=systat^.bbsphone else
  if (allcaps(s2)='SYSOPNAME') then s:=systat^.sysopname else
  if (allcaps(s2)='SYSOPAVAIL') then begin
         if (sysop) then s:='Available' else s:='Unavailable';
  end else
  if (allcaps(s2)='DATE') then s:=date else
  if (allcaps(s2)='TIME') then s:=time else
  if (allcaps(s2)='EP') then begin
  case mcimod of
        1:begin
          s:=mln(mcipad,mcichange);
          mcimod:=0;
          mcichange:=0;
          mcipad:='';
          end;
        2:begin
          s:=mrn(mcipad,mcichange);
          mcimod:=0;
          mcichange:=0;
          mcipad:='';
          end;
        3:begin
          s:=centered(mcipad,mcichange);
          mcimod:=0;
          mcichange:=0;
          mcipad:='';
          end;
        else s:='';
  end;
  end else
  if (allcaps(s2)='NOABORT') then begin
        if (printingfile) then allowabort:=false;
        s:='';
  end;
{  if (mcimod<>0) then begin
        mcipad:=mcipad+s;
        s:='';
  end;}
  if (newmod<>0) then begin
        mcimod:=newmod;
        mcichange:=newchange;
  end;
  if (s='#NEXUS#') then begin
        s:=#28+s2+'|';
        ok:=FALSE;
  end else ok:=TRUE;
  smci3:=s;
end;

function smci4(s2:string;var ok:boolean):string;
var c2:char;
    s:string;
    j,i:integer;
    l:longint;
    i2,r:real;
    add:addrtype;
    newmod:byte;
    newchange:integer;
    done:boolean;


begin
  newmod:=0;
  s:='#NEXUS#';
  if (noshowmci) then begin
        smci4:=#28+s2;
	exit;
  end;
  case s2[1] of
        'C':case s2[2] of
                'A':begin
                        if (spd='KB') then s:='0' else
                        if not(modemr^.lockport) then begin
                                s:=cstrl(answerbaud);
                        end else begin
                                s:=cstrl(modemr^.waitbaud);
                        end;
                    end;
                'B':if (not(incom) and not(outcom)) then s:=cstrl(0)
                        else s:=cstrl(answerbaud);
                'L':begin
                        if (modemr^.lockport) then begin
                                s:=cstrl(modemr^.waitbaud);
                        end else begin
                                s:=cstrl(answerbaud);
                        end;
                    end;
                'N':s:=cstr(cnode);
            end;
        'X':case s2[2] of
                'L':if (mcimod=0) then begin
                        newmod:=1;
                        newchange:=value(copy(s2,3,length(s2)-2));
                        if (newchange=0) then newmod:=0;
                        s:='';
                    end;
                'X':begin
                          case mcimod of
                                1:begin
                                  s:=mln(mcipad,mcichange);
                                  mcimod:=0;
                                  mcichange:=0;
                                  mcipad:='';
                                  end;
                                2:begin
                                  s:=mrn(mcipad,mcichange);
                                  mcimod:=0;
                                  mcichange:=0;
                                  mcipad:='';
                                  end;
                                3:begin
                                  s:=centered(mcipad,mcichange);
                                  mcimod:=0;
                                  mcichange:=0;
                                  mcipad:='';
                                  end;
                                else s:='';
                          end;
                    end;
                end;
       end;
  if (newmod<>0) then begin
        mcimod:=newmod;
        mcichange:=newchange;
  end;
  if (s='#NEXUS#') then begin
        s:=#28+s2;
        ok:=FALSE;
  end else ok:=TRUE;
  smci4:=s;
end;

function extonly(s:string):string;
var
 x : integer;
 done : boolean;
begin
 x := length(s);
 done:=FALSE;
 while (x > 1) and not (done) do begin
       if s[x] = '.' then begin
          done := true;
       end;
       dec(x);
 end;
 if not(done) then s:='' else
 s := copy(s,x+2,length(s));
 extonly := s;
end;


procedure shelldos(bat:boolean; cl:string; var rcode:integer);
var t:text;
    s,s2:string;
    i:integer;
    bb:byte;
    f:file;
    swaptype:integer;
    speed:longint;
    emsswap:boolean;
    regs:registers;
begin
  bb:=curco;
  nosound;
  if (pos(' ',cl)<>0) then begin
          s2:=copy(cl,1,pos(' ',cl)-1);
          if (exist(s2)) then s2:=fexpand(s2);
          cl:=copy(cl,pos(' ',cl)+1,length(cl));
  end else begin
          s2:=cl;
          if (exist(s2)) then s2:=fexpand(s2);
  end;
  if (s2='') then begin
          s2:=getenv('COMSPEC');
          cl:='';
  end else
  if (allcaps(extonly(s2))<>'EXE') and (allcaps(extonly(s2))<>'COM') then begin
    assign(t,adrv(systat^.temppath)+'~NXT'+cstrn(cnode)+'.BAT');
    rewrite(t);
    writeln(t,'@ECHO OFF');
    if (extonly(s2)='') then
    writeln(t,s2+' '+cl)
    else
    writeln(t,'CALL '+s2+' '+cl);
    writeln(t,'IF ERRORLEVEL '+cstr(rcode)+' ECHO '+cstr(rcode)+' > '+adrv(systat^.temppath)+'ERLV'+cstrn(cnode)+'.DAT');
    close(t);
    s2:=getenv('COMSPEC');
    cl:='/c '+adrv(systat^.temppath)+'~NXT'+cstrn(cnode)+'.BAT';
    bat:=TRUE;
  end;
  If not(exist(s2)) then s2 := FSearch(s2, getenv('PATH'));

  remove_port;
  emsswap:=FALSE;
  swapvectors;
  if (currentswap>0) then 
  begin
        case currentswap of
		1:swaptype:=swap_disk;
		2:swaptype:=swap_xms;
                3:swaptype:=swap_ems;
		4:swaptype:=swap_all;
	end;
        Init_spawno(copy(newswap,1,length(newswap)-1),swaptype,20,0);
        rcode:=spawn(s2,cl,0);
        if (rcode=-1) then begin
                case spawno_error of
                        2:sl1('!','SWAP: Cannot Find PROGRAM to Run');
                        3:sl1('!','SWAP: Cannot Fine Path');
                        5:sl1('!','SWAP: Access Denied');
                        8:sl1('!','SWAP: Insufficient Memory');
                        20:sl1('!','SWAP: Program Too Large');
                        29:sl1('!','SWAP: Write Fault Error');
                        else sl1('!','SWAP: Unknown Error');
                end;
	end; 
  end else begin
        writeln(s2);
        writeln(cl);
        exec(s2,cl);
        rcode:=lo(dosexitcode);
        writeln(rcode);
        pausescr;
  end;
  swapvectors;
  if (bat) then begin
    assign(t,adrv(systat^.temppath)+'~NXT'+cstrn(cnode)+'.BAT');
    {$I-} erase(t); {$I+}
    if (ioresult<>0) then ;
    if (exist(adrv(systat^.temppath)+'ERLV'+cstrn(cnode)+'.DAT')) then begin
    assign(t,adrv(systat^.temppath)+'ERLV'+cstrn(cnode)+'.DAT');
    {$I-} erase(t); {$I+}
    if (ioresult<>0) then ;
    rcode:=0;
    end else rcode:=1;
  end;
  iport;
  if not(sysopshelling) then
        if (exist(adrv(systat^.semaphorepath)+'RETURN.'+cstrnfile(cnode))) then begin
		filemode:=66;
                {runprogram(adrv(systat^.semaphorepath)+'RETURN.'+cstrnfile(cnode));}
                doscript(adrv(systat^.semaphorepath)+'RETURN.'+cstrnfile(cnode),'');
                assign(f,adrv(systat^.semaphorepath)+'RETURN.'+cstrnfile(cnode));
		{$I-} erase(f); {$I-}
                if ioresult<>0 then begin end;
	end;
  clearansi;
  curco:=7;
  setc(bb);
end;


procedure scaninput(var s:string; allowed:string; lfeed:boolean);
  var os:string;
      i:integer;
      c:char;
      gotcmd:boolean;
      oldco:byte;
  begin
    gotcmd:=FALSE; s:='';
    oldco:=lastco;
    mpl(5);
    repeat
      getkey(c); c:=upcase(c);
      os:=s;
      if ((pos(c,allowed)<>0) and (s='')) then begin gotcmd:=TRUE; s:=c; end
      else
      if (pos(c,'0123456789')<>0) then begin
	if (length(s)<5) then s:=s+c;
      end
      else
      if ((s<>'') and (c=^H)) then s:=copy(s,1,length(s)-1)
      else
      if (c=^X) then begin
        for i:=1 to length(s) do prompt(^H' '^H);
	s:=''; os:='';
      end
      else
      if (c=#13) then gotcmd:=TRUE;

      if (length(s)<length(os)) then prompt(^H' '^H);
      if (length(s)>length(os)) then prompt(copy(s,length(s),1));
    until ((gotcmd) or (hangup));
    setc(oldco);
    if (lfeed) then nl;
  end;




procedure DisableInterrupts;
begin
  inline($FA);  {cli}
end;

procedure EnableInterrupts;
begin
  inline($FB);  {sti}
end;

procedure LogOfCallers(x:integer);
  var 
  hilc,z:integer;
  lcallf: File of Lcallers; 

Begin
  assign(lcallf,adrv(systat^.gfilepath)+'LASTON.DAT');
  filemode:=66; 
  {$I-} reset(lcallf); {$I+}
  
  if (ioresult<>0) then	Begin
                rewrite(lcallf); lcall.node:=0;
		for z:=0 to 9 do write(lcallf,lcall);
  End;
  lcall.node:=0; z:=0; hilc:=9;
  for z:=0 to 9 do begin
		seek(lcallf,z); read(lcallf,lcall);
                if (lcall.node=0) and (hilc=9) then hilc:=z-1;
  end;
  sprompt(gstring(156));
  sprompt(gstring(157));
  sprompt(gstring(158));
  if (hilc<>-1) then begin
                for z:=hilc downto 0 do begin
				seek(lcallf,z); read(lcallf,lcall);
                                sprompt(gstring(159));
                end;
  end else sprompt(gstring(160));
  close(lcallf);
end;

function lenn(s:string):integer;
var i,len:integer;
begin
  len:=length(s); i:=1;
  while (i<=length(s)) do begin
    if (s[i]='%') then
      if (i<length(s)) then begin 
	if s[i]='%' then if (i+4<=length(s)) then begin
		if (s[i+4]='%') then
		if (s[i+1] in ['0'..'9']) and
			(s[i+2] in ['0'..'9']) and
			(s[i+3] in ['0'..'9']) then begin
			dec(len,5); inc(i,4); end;
		end;
	end;
    inc(i);
  end;
  lenn:=len;
end;



procedure loaduboard(i:integer);
var ulfo:boolean;
    x,x2:integer;
begin
  if (readuboard<>i) then begin
    ulfo:=(filerec(ulf).mode<>fmclosed);
    filemode:=66;
    if (not ulfo) then begin
        {$I-} reset(ulf); {$I+}
        if (ioresult<>0) then begin
                sl1('!','Error reading FBASES.DAT');
                exit;
        end;
    end;
    if ((i>=0) and (i<=maxulb)) then begin
      seek(ulf,i);
      read(ulf,memuboard);
    end else begin
            if (not ulfo) then close(ulf);
            exit;
    end;
    readuboard:=i;
    if (not ulfo) then close(ulf);
    if (memuboard.cdrom) then begin
           x:=1;
           x2:=0;
           while (x<=26) do begin
           if (memuboard.cdnum=cdavail[x]) then x2:=x;
           inc(x);
           end;
           if (x2<>0) then
           if (memuboard.cdnum=cdavail[x2]) then begin
                        if (memuboard.dlpath='') then begin
                                memuboard.dlpath:=chr(x2+64)+':\';
                        end else
                        if memuboard.dlpath[1]='\' then memuboard.dlpath:=chr(x2+64)+':'+memuboard.dlpath
                                else
                        if memuboard.dlpath[2]=':' then memuboard.dlpath[1]:=chr(x2+64) else
                                if memuboard.dlpath[1]<>'\' then memuboard.dlpath:=chr(x2+64)+
                                        ':\'+memuboard.dlpath;
           end;
    end;
  end;
end;

procedure loadboard(i:integer);
var bfo:boolean;
    tnum:integer;
begin
  if (readboard<>i) then begin
    tnum:=0;
    bfo:=(filerec(bf).mode<>fmclosed);
    filemode:=66; 
    if (not bfo) then begin
    {$I-} reset(bf); {$I+}
    if (ioresult<>0) then begin tnum:=-1; end;
    end;
    if (tnum<>-1) then begin 
    if ((i-1<0) or (i>filesize(bf)-1)) then i:=0;
    seek(bf,i); read(bf,memboard);
    readboard:=i;
    if (not bfo) then close(bf);
    end;
  end;
end;

procedure lcmds(len,c:byte; c1,c2:string);
var s:string;
begin
  s:=copy(c1,2,lenn(c1)-1);
  if (c2<>'') then s:=mln(s,len-1);
  sprompt('%150%'+c1[1]+'%030%'+s);
  if (c2<>'') then sprompt('%150%'+c2[1]+'%030%'+copy(c2,2,lenn(c2)-1));
  nl;
end;

procedure tc(n:integer);
begin
  textcolor(n);
end;

function mso:boolean;
var i:byte;
    b:boolean;
begin
  b:=FALSE;
  if board<>0 then for i:=1 to 20 do
    if (board=thisuser.boardsysop[i]) then b:=TRUE;
  mso:=((cso) or (aacs(systat^.msop)) or (b));
end;

function fso:boolean;
var i:byte;
    b:boolean;
begin
  b:=FALSE;
  if fileboard<>0 then for i:=1 to 20 do
    if (fileboard=thisuser.uboardsysop[i]) then b:=TRUE;
  fso:=((cso) or (aacs(systat^.fsop)) or (b));
end;

function cso:boolean;
begin
  cso:=((so) or (aacs(systat^.csop)));
end;

function so:boolean;
begin
  so:=(aacs(systat^.sop));
end;

function timer:real;
var r:registers;
    h,m,s,t:real;
begin
  r.ax:=44*256;
  msdos(dos.registers(r));
  h:=(r.cx div 256); m:=(r.cx mod 256); s:=(r.dx div 256); t:=(r.dx mod 256);
  timer:=h*3600+m*60+s+t/100;
end;

function fbaseac(b:integer):boolean;
begin
  fbaseac:=FALSE;
  if (b<0) or (b>maxulb) then exit;
  loaduboard(b);
  if (infconf(b)) then begin
  fbaseac:=aacs(memuboard.acs);
  end;
end;

function mbaseac(nb:integer):boolean;
begin
  mbaseac:=FALSE;
  if ((nb<0) or (nb>numboards)) then exit;
  loadboard(nb);
  if inmconf(nb) then begin
  mbaseac:=aacs(memboard.acs);
  end;
end;

procedure changefileboard(b:integer);
var s:string[20];
    go:boolean;
begin
  go:=FALSE;
  if ((b>=0) and (b<=maxulb)) then begin
    if (fbaseac(b)) then begin{ fbaseac loads memuboard itself ... }
      if (memuboard.password='') then go:=TRUE
      else begin
        nl; sprint('File Base ['+cstr(b)+'] %030%'+
                   +memuboard.name);
        sprompt(gstring(4)); mpl(20); input(s,20);
        if (s=memuboard.password) then go:=TRUE else sprompt(gstring(6));
      end;
      end;
    end;
  if (go) then begin 
  fileboard:=b; 
  end;
end;

procedure changeboard(b:integer);
var s:string[20];
    go:boolean;
begin
  go:=FALSE;
  if (b>=0) and (b<=numboards) then
    if (mbaseac(b)) then { mbaseac loads memboard itself ... }
      if (memboard.password='') then go:=TRUE
      else begin
        nl; sprint('Message Base ['+cstr(b)+'] %030%'+
                   +memboard.name);
        sprompt(gstring(4)); mpl(20); input(s,20);
        if (s=memboard.password) then go:=TRUE else sprompt(gstring(6));
      end;
  if (go) then begin board:=b; thisuser.lastmsg:=board; end;
end;

Function DriveSize(d:byte):Longint; { -1 not found, 1=>1 Giga }
Var
  R : Registers;
Begin
  With R Do
  Begin
    ah:=$36; dl:=d; Intr($21,R);
    If AX=$FFFF Then DriveSize:=-1 { Drive not found }
    Else If (DX=$FFFF) or (Longint(ax)*cx*dx=1073725440) Then DriveSize:=1
    Else DriveSize:=Longint(ax)*cx*dx;
  End;
End;

Function DriveFree(d:byte):Longint; { -1 not found, 1=>1 Giga }
Var
  R : Registers;
Begin
  With R Do
  Begin
    ah:=$36; dl:=d; Intr($21,R);
    If AX=$FFFF Then DriveFree:=-1 { Drive not found }
    Else If (BX=$FFFF) or (Longint(ax)*bx*cx=1073725440) Then DriveFree:=1
    Else DriveFree:=Longint(ax)*bx*cx;
  End;
End;

function freek(d:integer):longint;
var lng:longint;
begin
  lng:=drivefree(d);
  if (lng=1) then freek:=1048576 else
  freek:=lng div 1024;
end;

function nma:integer;
begin
  nma:=utimeleft;
end;

function nsl:real;
var ddt,dt:datetimerec;
    beenon:real;
begin
  if (useron) then begin
    getdatetime(dt);
    timediff(ddt,timeon,dt);
    beenon:=dt2r(ddt);
    nsl:=((nma*60.0+extratime+freetime)-(beenon+choptime));
  end else
    nsl:=3600.0
end;

procedure checkhangup;
begin
  if (not com_carrier) then
    if ((outcom) and (not hangup2)) then begin
      hangup2:=TRUE; hungup:=TRUE;
    end;
end;

function hangup:boolean;
begin
checkhangup;
if (hangup2) then hangup:=TRUE else hangup:=FALSE;
end;

function waitackfile(s:string):boolean;
var rl:real;
begin
  pr1('f'+s+';');
  rl:=timer;
  waitackfile:=TRUE;
  repeat
    if (not com_rx_empty) then
      case com_rx of
	#6:exit;                                  { ACK }
	#21:begin waitackfile:=FALSE; exit; end;  { NAK }
      end;
  until (timer-rl>10.0);
  waitackfile:=FALSE;
end;

procedure sendfilep(s:string);
var f:file of char;
    ps:string[67];
    ns:string[8];
    es:string[4];
    c:char;
begin
  assign(f,s);
  filemode:=66; 
  {$I-} reset(f); {$I+}
  if (ioresult<>0) then begin
    pr('');
    pr(''+s+' : File Not Found.');
    pr('');
  end else begin
    fsplit(s,ps,ns,es);
    if (waitackfile(ns+es)) then begin
      while (not eof(f)) do begin read(f,c); com_tx(c); end;
      pr1(^Z^Z^Z);
    end;
    close(f);
  end;
end;

function cinkey:char;
var c:char;
begin
  checkhangup;
  if (skipcommand) then begin
        cinkey:=#13;
        skipcommand:=FALSE;
        exit;
  end;
  if (recom1(c)) then begin
    cinkey:=c;
  end else
    cinkey:=#0;
end;

procedure o(c:char);
begin
  if ((outcom) and (c<>#1)) then sendcom1(c);
end;

function intime(tim:real; tim1,tim2:integer):boolean;
(* "tim" is seconds (timer) time; tim1/tim2 are minutes time. *)
begin
  intime:=TRUE;
  while (tim>=24.0*60.0*60.0) do tim:=tim-24.0*60.0*60.0;
  if (tim1<>tim2) then
    if (tim2>tim1) then
      if (tim<=tim1*60.0) or (tim>=tim2*60.0) then
	intime:=FALSE
      else
    else
      if (tim<=tim1*60.0) and (tim>=tim2*60.0) then
	intime:=FALSE;
end;

function sysop1:boolean;
var a:byte absolute $0000:$0417;
begin
  if (a and 16)=0 then sysop1:=TRUE else sysop1:=FALSE;
end;

function sysop:boolean;
var s:boolean;
begin
  s:=sysop1;
  if (not intime(timer,modemr^.lowtime[getdow+1],modemr^.hitime[getdow+1])) then s:=FALSE;
  if (rchat in thisuser.ac) then s:=FALSE;
  sysop:=s;
end;

procedure opensysopf;
begin
  filemode:=66;
  {$I-} reset(sysopf,1); {$I+}
  if (ioresult<>0) then begin
    rewrite(sysopf,1);
  end;
  {$I-} seek(sysopf,filesize(sysopf)); {$I+}
  if (ioresult<>0) then begin end;
end;

function stripcolor(o:string):string;
var s,s2:string;
    count,i:integer;
    lc:boolean;
begin
  s2:=o;
  s:='';
  count:=0;
  i:=1;
  while (i<=length(o)-4) do begin
       if (o[i]='%') and (o[i+4]='%') and (o[i+1] in ['0'..'9']) and
                (o[i+2] in ['0'..'9']) and (o[i+3] in ['0'..'9']) then inc(i,4) else
       if (o[i]='|') and (o[i+1] in ['0'..'9']) and (o[i+2] in ['0'..'9']) then
          inc(i,2) else
			s:=s+o[i];
       inc(i);
  end;
  if (length(o)>4) {and (i<length(o))} then begin
    if not((o[length(o)-4]='%') and (o[length(o)]='%') and (o[length(o)-3] in ['0'..'9'])
        and (o[length(o)-2] in ['0'..'9']) and (o[length(o)-1] in ['0'..'9'])) then begin
        for count:=i to (length(o)) do begin
                s:=s+(o[count]);
        end;
    end;
  end else begin
  s:=s2;
  end;
  stripcolor:=s;
end;

procedure blockwritestr(var f:file;s:string);
begin
blockwrite(f,s[1],length(s));
end;

procedure sl1(c:char;s:string);
begin
  if (slogging) then begin
    s:=stripcolor(s);
    filemode:=66;
    if not(wantout) then begin
	textcolor(15);
	write('   ',c);
	textcolor(14);
	write('  ',time);
	textcolor(11);
	writeln('  ',copy(s,1,60));
	textcolor(7);
	topscr;
    end;
    opensysopf;
    blockwritestr(sysopf,c+' '+time+' '+s+#13#10);
{    if ((thisuser.slogseperate) and (textrec(sysopf1).mode=fmoutput)) then begin
      blockwritestr(sysopf,c+' '+time+' '+s+#13#10);}
  close(sysopf);
  end;
end;

procedure sl2(level:byte; c:char; s:string);
begin
{ check modemr log levels to determine which types to log

  10 - CD-ROM related
}
case level of
        10:begin end;
        else sl1(c,s);
end;
end;

procedure sysophead;
var s:string;
begin
  s:='';
  s:=' (Node '+cstr(cnode)+')';
  if (slogging) then begin
    opensysopf;
    blockwritestr(sysopf,''+#13#10);
    blockwritestr(sysopf,'--- Created by Nexus v'+ver+s+' on '+date+' '+time+#13#10);
    blockwritestr(sysopf,''+#13#10);
    {if ((thisuser.slogseperate) and (textrec(sysopf1).mode=fmoutput)) then begin
      writeln(sysopf);
      writeln(sysopf1,'--- Created by Nexus v',ver,s,' (Node ',cstr(cnode),') on ',datelong,' ',time);
      writeln(sysopf);
      end;}

  end;
end;




function nam:string;
begin
  if (systat^.aliasprimary) then
  nam:=caps(thisuser.name) else
  nam:=caps(thisuser.realname);
end;

function ageuser(bday:string):integer;
var i:integer;
begin
  i:=value(copy(datelong,7,4))-value(copy(bday,7,4));
  if (daynum(copy(bday,1,6)+copy(datelong,7,4))>daynum(datelong)) then dec(i);
  ageuser:=i;
end;

function allcaps(s:string):string;
var i:integer;
begin
  for i:=1 to length(s) do s[i]:=upcase(s[i]);
  allcaps:=s;
end;

function caps(s:string):string;
var i:integer;
begin
  for i:=1 to length(s) do
    if (s[i] in ['A'..'Z']) then s[i]:=chr(ord(s[i])+32);
  for i:=1 to length(s) do
    if (not (s[i] in ['A'..'Z','a'..'z'])) then
      if (s[i+1] in ['a'..'z']) then s[i+1]:=upcase(s[i+1]);
  s[1]:=upcase(s[1]);
  caps:=s;
end;

function leapyear(yr:integer):boolean;
begin
  leapyear:=(yr mod 4=0) and ((yr mod 100<>0) or (yr mod 400=0));
end;

function days(mo,yr:integer):integer;
var d:integer;
begin
  d:=value(copy('312831303130313130313031',1+(mo-1)*2,2));
  if ((mo=2) and (leapyear(yr))) then inc(d);
  days:=d;
end;

function daycount(mo,yr:integer):integer;
var m,t:integer;
begin
  t:=0;
  for m:=1 to (mo-1) do t:=t+days(m,yr);
  daycount:=t;
end;

function daynum(dt:string):integer;
var d,m,y,t,c:integer;
begin
  t:=0;
  m:=value(copy(dt,1,2));
  d:=value(copy(dt,4,2));
  y:=value(copy(dt,7,4));
  for c:=1970 to y-1 do
    if (leapyear(c)) then inc(t,366) else inc(t,365);
  t:=t+daycount(m,y)+(d-1);
  daynum:=t;
  if y<1970 then daynum:=0;
end;

function dat:string;
const mon:array [1..12] of string[3] =
	  ('Jan','Feb','Mar','Apr','May','Jun',
	   'Jul','Aug','Sep','Oct','Nov','Dec');
var ap,x,y:string; i:integer;
    year,month,day,dayofweek,hour,minute,second,sec100:word;
begin
  getdate(year,month,day,dayofweek);
  gettime(hour,minute,second,sec100);

  if (hour<12) then ap:='am'
  else begin
    ap:='pm';
    if (hour>12) then dec(hour,12);
  end;
  if (hour=0) then hour:=12;

  dat:=cstr(hour)+':'+tch(cstr(minute))+' '+ap+'  '+
       copy('SunMonTueWedThuFriSat',dayofweek*3+1,3)+' '+
       mon[month]+' '+cstr(day)+', '+cstr(year);
(*  5:43 pm  Fri Jul 28, 1989  *)
end;

procedure pr1(s:string);
var i:integer;
begin
  for i:=1 to length(s) do sendcom1(s[i]);
end;

procedure pr(s:string);
begin
  pr1(s+#13);
end;

procedure scc;    {* make local textcolor( = curco *}
var f:integer;
begin
  if (okansi) then begin
    if (okcolor) then begin
        f:=curco and 7;
        if (curco and 8)<>0 then inc(f,8);
        if (curco and 128)<>0 then inc(f,16);
        tc(f);
        textbackground((curco shr 4) and 7);
    end else begin
    if (((curco shr 4) and 7)<>0) then begin
        tc(0);
        textbackground(7);
    end else begin
        tc(7);
        textbackground(0);
    end;
    end;
    clearansi;
  end;
end;

procedure sde; { restore curco colors (DOS and tc) loc. after local }
var c:byte;
    b:boolean;
begin
  if (okansi) then begin
    c:=curco; curco:=255-curco;
    b:=outcom; outcom:=FALSE;
    clearansi;
    setc(c);
    outcom:=b;
  end;
end;

procedure sdc; { restore curco colors (DOS and tc) loc/rem after loc/rem }
var c:byte;
begin
  if (okansi) then begin
    c:=curco; curco:=255-curco;
    clearansi;
    setc(c);
  end;
end;

procedure stsc;
begin
  tc(11); textbackground(0);
end;


procedure setc(c:byte);
var s:string;
    i:integer;
begin
  if (c<>curco) then begin
    if (okansi) then begin
              if not(okcolor) then begin
                if (((c shr 4) and 7)<>0) then begin
                        c:=(0 or (7 shl 4));
                end else begin
                        c:=7;
                end;
              end;
              s:=getc(c); curco:=c;
              if (outcom) then begin
                pr1(s);
              end;
              if (wantout) then begin
                textattr:=c;
              end;
    end;
{    scc; }
  end;
end;

function sqoutsp(s:string):string;
begin
  while (pos(' ',s)>0) do delete(s,pos(' ',s),1);
  sqoutsp:=s;
end;

function exdrv(s:string):byte;
begin
  s:=fexpand(s);
  exdrv:=ord(s[1])-64;
end;

function mlnnomci(s:string; l:integer):string;
begin
  while (length(s)<l) do s:=s+' ';
  if (length(s)>l) then
    repeat s:=copy(s,1,length(s)-1) until (length(s)=l) or (length(s)=0);
  mlnnomci:=s;
end;

function lennmci(s:string):integer;
begin
  s:=processMCI(s);
  lennmci:=lenn(s);
end;

function mlnmci(s:string; l:integer):string;
begin
  while (lennmci(s)<l) do s:=s+' ';
  if (lennmci(s)>l) then
    repeat s:=copy(s,1,length(s)-1) until (lennmci(s)=l) or (length(s)=0);
  mlnmci:=s;
end;

function mln(s:string; l:integer):string;
var i,i2:integer;
    s2:string;
begin
  s2:='';
  while (lenn(s)<l) do s:=s+' ';
  if (lenn(s)>l) then
  if (length(s)<=4) then begin
        s:=copy(s,1,l);
  end else begin
  i:=1;
  i2:=0;
  while (i<=length(s)-4) and (i2<l) do begin
    if (s[i]='%') and (s[i+4]='%') and
         (s[i+1] in ['0'..'9']) and (s[i+2] in ['0'..'9']) and
                (s[i+3] in ['0'..'9']) then begin
                        s2:=s2+s[i]+s[i+1]+s[i+2]+s[i+3]+s[i+4];
                        inc(i,4);
    end else begin
        s2:=s2+s[i];
        inc(i2);
    end;
    inc(i);
  end;
  if not((s[length(s)-4]='%') and (s[length(s)]='%')
         and (s[i+1] in ['0'..'9']) and (s[i+2] in ['0'..'9']) and
                (s[i+3] in ['0'..'9'])) then begin
        if (i2<l) then begin
                inc(i2);
                s2:=s2+s[length(s)-3];
        end;
        if (i2<l) then begin
                inc(i2);
                s2:=s2+s[length(s)-2];
        end;
        if (i2<l) then begin
                inc(i2);
                s2:=s2+s[length(s)-1];
        end;
        if (i2<l) then begin
                inc(i2);
                s2:=s2+s[length(s)];
        end;
  end;
  s:=s2;
  end;
  mln:=s;
end;


function mrn(s:string; l:integer):string;
begin
  while lenn(s)<l do s:=' '+s;
  if lenn(s)>l then s:=copy(s,1,l);
  mrn:=s;
end;

function mn(i,l:longint):string;
begin
  mn:=mln(cstr(i),l);
end;

procedure dosansi(c:char);
begin
{DISPLAY ANSI LOCAL}
if (okansi) then 
Display_ANSI(c) else
write(c);
end;

procedure lpromptc(c:char);
var ss:string;
    bb:byte;
    x:integer;
begin
  if (c=^G) then exit;
  case c of
    ^H:begin
        if (wantout) then begin
                dosansi(^H);
                dosansi(' ');
        end;
        if (pap>0) then dec(pap);
        end;
    ^J:begin
{         if ((not ch) and (not write_msg) and (not reading_a_msg)) then
           if (not ctrljoff) then begin
             if ((outcom) and (okansi)) then
               setc(7 or (0 shl 4));
           end else
             lil:=0; }
         if (wantout) then dosansi(^J);
         inc(lil);
         if not(listing_files) then
	 if (lil>=thisuser.pagelen-1) then begin
	   lil:=0;
           if ((reading_a_msg) and not(ch)) then begin
		if (pause in thisuser.ac) then begin
			pausescr;
		end;
           end else begin
           if not(printingfile) then mpausescr:=false;
	   if (reading_a_msg) then write_msg:=false;
	   if ((pause in thisuser.ac) and not(write_msg) and not(ch)) then pausescr;
           end;
	 end;
	 exit;
       end;
    ^L:lil:=0;
    ^M:pap:=0;
    else inc(pap);
  end;
  if (wantout) then dosansi(c);
end;

procedure prompt(s:string);
var s1,s2:string;
    i:integer;
    bb:byte;
begin
  checkhangup;
  if (hangup) then exit;
  if (outcom) then begin
    s1:=stripcolor(s);
    while (pos(^J,s1)<>0) do begin
      i:=pos(^J,s1);
      s2:=copy(s,1,i-1); s1:=copy(s1,i+1,length(s1)-i);
      for i:=1 to length(s2) do sendcom1(s2[i]);
      setc(7 or (0 shl 4));
{      if ((not ch) and (not write_msg) and (not reading_a_msg)) then
        if (not ctrljoff) then begin
          if (okansi) then
             setc(7 or (0 shl 4));
	end else
          lil:=0;}
      sendcom1(^J);
    end;
    for i:=1 to length(s1) do sendcom1(s1[i]);
  end;
  for i:=1 to length(s) do lpromptc(s[i]);
  if (trapping) then
    if (copy(s,length(s)-1,2)=^M^J) then
      writeln(trapfile,copy(s,1,length(s)-2))
    else
      write(trapfile,s);
end;

procedure print(s:string);
begin
  prompt(s+^M^J);
end;

procedure nl;
begin
  prompt(^M^J);
end;

procedure prt(s:string);
begin
  sprompt('%090%'+s+'%030%');
end;

procedure ynq(s:string);
var ss,sss:string;
    ps1,ps2,bb,i,p1,p2,x,z:integer;
    c,mc:char;
    done,xx:boolean;
begin
  checkhangup;
  if (hangup) then exit;
  if (dyny) then ss:=s+gstring(100) else
        ss:=s+gstring(102);
  sprompt(ss);
end;



procedure mpl(c:integer);
var i,x:integer;
    opap:integer;
begin
  opap:=pap;
  if (okansi) then begin
    x:=wherex;
    if (outcom) then for i:=1 to c do sendcom1(' ');
    if (wantout) then for i:=1 to c do write(' ');
    gotoxy(x,wherey);
    if (outcom) then begin
      pr1(#27+'['+cstr(c)+'D');
    end;
  end;
  pap:=opap;
end;

function processMCI(ss:string):string;
var ss3,ss4:^string;
    ps1:integer;
    b:byte;
    ok:boolean;
begin
  new(ss3); new(ss4);
  ok:=false;
  ss4^:='';
  mcipad:='';
  while not(ok) do begin  
	ps1:=pos('|',ss);
	if (ps1<>0) then begin
                if (mcimod<>0) then begin
                mcipad:=mcipad+copy(ss,1,ps1-1);
                end else begin
                ss4^:=ss4^+copy(ss,1,ps1-1);
                end;
                ss:=copy(ss,ps1,length(ss));
                ss[1]:=#28;
                ps1:=pos('|',ss);
                if (ps1<>0) then begin
                        ss3^:=smci3(copy(ss,2,ps1-2),ok);
                        if (ok) then begin
                                if (mcimod<>0) then begin
                                        mcipad:=mcipad+ss3^;
                                end else begin
                                        ss4^:=ss4^+ss3^;
                                end;
                                ss:=copy(ss,ps1+1,length(ss));
                        end else begin
                                if (mcimod<>0) then begin
                                        mcipad:=mcipad+copy(ss3^,1,length(ss3^)-1);
                                end else begin
                                        ss4^:=ss4^+copy(ss3^,1,length(ss3^)-1);
                                end;
                                ss:=copy(ss,ps1,length(ss));
                        end;
                end;
	end;
        ok:=FALSE;
        if (pos('|',ss)=0) then ok:=TRUE;
  end;
  if (ss<>'') then ss4^:=ss4^+ss;
  ss:=ss4^;
  for ps1:=1 to length(ss) do if ss[ps1]=#28 then ss[ps1]:='|';


(*  ok:=false;
  ss4^:='';
  mcipad:='';
  while not(ok) do begin  
        ps1:=pos('~',ss);
	if (ps1<>0) then begin
                if (mcimod<>0) then begin
                        mcipad:=mcipad+copy(ss,1,ps1-1);
                end else begin
                        ss4^:=ss4^+copy(ss,1,ps1-1);
                end;
                ss:=copy(ss,ps1,length(ss));
                ss[1]:=#28;
                        ss3^:=copy(ss,2,2);
                        b:=4;
                        if (allcaps(ss3^)='EC') or
                           (allcaps(ss3^)='EE') or
                           (allcaps(ss3^)='EL') or
                           (allcaps(ss3^)='EF') or
                           (allcaps(ss3^)='XE') or
                           (allcaps(ss3^)='XL') or
                           (allcaps(ss3^)='XF') or
                           (allcaps(ss3^)='XC') or
                           (allcaps(ss3^)='XR') or
                           (allcaps(ss3^)='ER') then begin
                           b:=4;
                           if (allcaps(ss3^)='EF') or (allcaps(ss3^)='XF') then begin
                                ss3^:=ss3^+copy(ss,4,1);
                                b:=5;
                           end;
                           while (ss[b] in ['0'..'9']) do begin
                                ss3^:=ss3^+ss[b];
                                inc(b);
                           end;
                        end else if (allcaps(ss3^)='EP') or (allcaps(ss3^)='XP') then begin
                           ss3^:=ss3^+ss[4]+ss[5];
                        end;
                        ss3^:=smci4(ss3^,ok);
                        if (mcimod<>0) then begin
                                        mcipad:=mcipad+ss3^;
                        end else begin
                                        ss4^:=ss4^+ss3^;
                        end;
                        ss:=copy(ss,b,length(ss));
	end;
        ok:=FALSE;
        if (pos('~',ss)=0) then ok:=TRUE;
  end;
  if (ss<>'') then ss4^:=ss4^+ss;
  ss:=ss4^;
  for ps1:=1 to length(ss) do if ss[ps1]=#28 then ss[ps1]:='~'; *)

  dispose(ss3); dispose(ss4);

  processMCI:=ss;
end;

function processcolor(ss:string):string;
var sss:^string;
    back,ps1,p1,p2,colr:integer;
    c:char;

begin
     new(sss);
     sss^:='';
     if (pos('|',ss)<>0) then begin
     while (ss<>'') and (pos('|',ss)<>0) do begin
        if (noshowpipe) then begin
            sss^:=ss; ss:='';
        end else begin
            p1:=pos('|',ss);
            if (p1<>0) then begin
                  ss[p1]:=#28;
                  if (ss[p1+1] in ['0'..'9']) and
                     (ss[p1+2] in ['0'..'9']) then begin
                        colr:=value(ss[p1+1]+ss[p1+2]);
                        sss^:=sss^+copy(ss,1,p1-1);
                        if (colr>=16) and (colr<=23) then begin
                              sss^:=sss^+#3+#6+chr(colr);
                        end else if (colr>=24) and (colr<=31) then begin
                              sss^:=sss^+#3+#5+chr(colr);
                        end else begin
                              sss^:=sss^+#3+#5+chr(colr);
                        end;
                        ss:=copy(ss,p1+3,length(ss));
                  end;
            end else begin
                  sss^:=sss^+ss; ss:='';
            end;
        end;
     end;
     if (ss<>'') then begin
           sss^:=sss^+ss;
           ss:='';
     end;
     for p1:=1 to length(sss^) do if (sss^[p1]=#28) then sss^[p1]:='|';
     ss:=sss^;
     end;
     sss^:='';
     while (ss<>'') and (pos('%',ss)<>0) do begin
        if (noshowpipe) then begin
            sss^:=ss; ss:='';
        end else begin
            p1:=pos('%',ss);
            if (p1<>0) then begin
                ss[p1]:=#28;
                p2:=pos('%',ss);
                if (p2<>0) and (p2-p1=4) then begin
                        if (ss[p1+1] in ['0'..'9']) and
                           (ss[p1+2] in ['0'..'9']) and
                           (ss[p1+3] in ['0'..'9']) then
                        begin
                                colr:=value(copy(ss,p1+1,2));
                                back:=value(copy(ss,p2-1,1));
                                if (hardback<>255) then back:=hardback;
                                sss^:=sss^+copy(ss,1,p1-1)+#3#5+chr(colr)+#3#6+chr(back);
                                ss:=copy(ss,p2+1,length(ss));
                        end else begin
                                sss^:=sss^+copy(ss,1,p1);
                                ss:=copy(ss,p1+1,length(ss));
                        end;
                end else begin
                        sss^:=sss^+ss;
                        ss:='';
                end;
            end else begin
                sss^:=sss^+ss; ss:='';
            end;
        end;

      end; {while}
      if (ss<>'') then begin
            sss^:=sss^+ss;
            ss:='';
      end;
      for p1:=1 to length(sss^) do if (sss^[p1]=#28) then sss^[p1]:='%';
      if (sss^<>'') then ss:=sss^;
      dispose(sss);
      processcolor:=ss;
end;

procedure sprompt(s:string);
var ss:^string;
    x,ps1:integer;
    c:char;
    oldpf,dd:boolean;
begin
  new(ss);
  checkhangup;
  if (hangup) then exit;
  ss^:=processMCI(s);
  if (length(ss^)>2) then begin
     if (allcaps(copy(ss^,1,6))='|FILE|') then begin
                while (pos(#13,ss^)<>0) do begin
                        delete(ss^,pos(#13,ss^),1);
                end;
                while (pos(#10,ss^)<>0) do begin
                        delete(ss^,pos(#10,ss^),1);
                end;
                printf(copy(ss^,7,length(ss^)-6));
                exit;
     end;
     if (allcaps(copy(ss^,1,5))='|NXE|') then begin
                while (pos(#13,ss^)<>0) do begin
                        delete(ss^,pos(#13,ss^),1);
                end;
                while (pos(#10,ss^)<>0) do begin
                        delete(ss^,pos(#10,ss^),1);
                end;
                runprogram(copy(ss^,6,length(ss^)-5));
                exit;
     end;
     if (allcaps(copy(ss^,1,5))='|NPX|') then begin
                while (pos(#13,ss^)<>0) do begin
                        delete(ss^,pos(#13,ss^),1);
                end;
                while (pos(#10,ss^)<>0) do begin
                        delete(ss^,pos(#10,ss^),1);
                end;
                doscript(copy(ss^,6,length(ss^)-5),'');
                exit;
     end;
     if (allcaps(copy(ss^,1,6))='|DOOR|') then begin
                while (pos(#13,ss^)<>0) do begin
                        delete(ss^,pos(#13,ss^),1);
                end;
                while (pos(#10,ss^)<>0) do begin
                        delete(ss^,pos(#10,ss^),1);
                end;
                currentswap:=modemr^.swapdoor;
                dodoorfunc(copy(ss^,7,length(ss^)-6),FALSE);
                currentswap:=0;
                exit;
     end;
 end;

if (trapping) then write(trapfile,stripcolor(ss^));
if not(okansi) then begin
    ss^:=stripcolor(ss^);
end else begin
    ss^:=processcolor(ss^);
end;

    ps1:=1;
    dd:=false;
    while (ps1<=length(ss^)) and not(dd) do begin
        if (ss^[ps1]=#3) then begin
                inc(ps1);
                if (ps1<=length(ss^)) then begin
                        case ss^[ps1] of
                                #1:cls;
                                #2:begin
                                        oldpf:=mpausescr;
                                        mpausescr:=FALSE;
                                        pausescr;
                                        mpausescr:=oldpf;
                                   end;
                                #3:begin
                                        oldpf:=mpausescr;
                                        mpausescr:=TRUE;
                                        pausescr;
                                        if (mabort) then begin
                                                dd:=true;
                                                ss^:='';
                                        end;
                                        mpausescr:=oldpf;
                                   end;
                                #4:begin
                                        inc(ps1);
                                        delay(ord(ss^[ps1])*1000);
                                   end;
                                #5:begin
                                        inc(ps1);
                                        textcolor(ord(ss^[ps1]));
                                        lastco:=curco;
                                        setc(textattr);
                                   end;
                                #6:begin
                                        inc(ps1);
                                        textbackground(ord(ss^[ps1]));
                                        lastco:=curco;
                                        setc(textattr);
                                   end;
                                end;
                end;
        end else begin
                if (outcom) then sendcom1(ss^[ps1]);
                lpromptc(ss^[ps1]);
        end;
        inc(ps1);
      end;
      dispose(ss);
end;

procedure sprint(s:string);
begin
  sprompt(s+#13#10);
end;

procedure prestrict(u:userrec);
var r:uflags;
begin
  for r:=rlogon to rmsg do
    if (r in u.ac) then write(copy('LCVBA*PEKM',ord(r)+1,1)) else write('-');
  writeln;
end;

function empty:boolean;
var e:boolean;
begin
  e:=(not keypressed);
  if ((incom) and (e)) then e:=(com_rx_empty);
  if (hangup) and (spd<>'KB') then begin com_flush_rx; e:=TRUE; end;
  empty:=e;
end;

function inkey:char;
var c:char;
begin
  c:=#0; inkey:=#0;
  checkhangup;
  if (keypressed) or (skipcommand) then begin
    if (skipcommand) then begin
        skipcommand:=FALSE;
        c:=#13;
    end else c:=readkey;
    if ((c=#0) and (keypressed)) then begin
      c:=readkey;
      skey1(c);
      case ord(c) of
        77:c:='C';
        75:c:='D';
        72:c:='A';
        80:c:='B';
        else begin
              if (c=#46) then c:=#1 else c:=#0;
              if (buf<>'') then begin
                c:=buf[1];
                buf:=copy(buf,2,length(buf)-1);
              end;
        end;
      end;
    end;
    inkey:=c;
  end else
    if (incom) then inkey:=cinkey;
{      if ((async_buffer_head<>async_buffer_tail) and (incom)) then
      inkey:=cinkey;}
  skipcommand:=FALSE;
end;

procedure outtrap(c:char);
begin
  if (c<>^G) then write(trapfile,c);
end;

procedure docc2(c:char);
var i:integer;
begin
  case c of
    ^G:if (outcom) then for i:=1 to 4 do sendcom1(#0);
    ^J:begin
	 if (wantout) then write(^J);
	 inc(pap);
       end;
    ^L:begin
	 if (wantout) then clrscr;
	 lil:=0;
       end;
  end;
end;

procedure outkey(c:char);
var s:string;
begin
  if (c=#29) then exit;
  if (c=#27) then sprompt(^H);
  if (not echo) and (systat^.localscreensec) then
    if (c in [#32..#255]) then begin
        s:=gstring(5);
        if (s<>'') then c:=s[1] else c:=#0;
    end;
  if (not (c in [^J,^L])) and (not (((c=^G) or (c=#27)) and (incom))) then begin
  if ((c<>#0) and (not nopfile) and (wantout)) then begin
      if (c=^H) then begin
        dosansi(^H);
        dosansi(' ');
      end;
      dosansi(c);
  end;
  if (not echo) then
    if (c in [#32..#255]) then begin
        s:=gstring(5);
        if (s<>'') then c:=s[1] else c:=#0;
    end;
  if (outcom) then begin
        if (c=^H) then begin
        sendcom1(^H);
        sendcom1(' ');
        end;
        sendcom1(c);
  end;
  if (c<#32) then docc2(c);
  end;
end;


procedure dm(i:string; var c:char);
begin
  buf:=i;
  if (buf<>'') then begin
    c:=buf[1];
    buf:=copy(buf,2,length(buf)-1);
  end;
end;


procedure getkey(var c:char);
var dt,ddt,ddt2:datetimerec;
    aphase,e:integer;
    f:file;
    nmf:file of nodemsgrec;
    nm:nodemsgrec;
    dd,dd3:longint;
    dosdt:datetime;
    b,tf,t1:boolean;
begin
  if (trapping) and not(pause in thisuser.ac) then write(trapfile,'***NO PAUSE***');
  lil:=0; 
  if (buf<>'') then begin
    c:=buf[1];
    buf:=copy(buf,2,length(buf)-1);
  end else begin
    if (not empty) then begin
      if (ch) then c:=chinkey else c:=inkey;
    end else begin
      getdatetime(tim);
      getdatetime(ddt2);
      t1:=FALSE; tf:=FALSE;
      c:=#0;
      if (alert in thisuser.ac) then aphase:=1 else aphase:=0;
      while ((c=#0) and not(skipcommand) and (not hangup)) do begin
	if (aphase<>0) then begin
	  case aphase of
	    1:begin sound(1000); delay(30); end;
	    2:begin sound(1000); delay(60); end;
	    3:begin sound(1000); delay(30); end;
	    4:begin sound(1000); delay(30); end;
	    5:begin sound(1000); delay(60); end;
	  end;
	  aphase:=aphase mod 5+1;
	end;
	TimeSlice;
        dd:=getdosdate;
        unpacktime(dd,dosdt);
        dosdt.sec:=0;
        dos.packtime(dosdt,dd3);
        if (dosdt.min mod 5=0) and (dd3<>lastupdatetime) then begin
        lastupdatetime:=dd3;
        assign(f,adrv(systat^.semaphorepath)+'INUSE.'+cstrnfile(cnode));
        rewrite(f);
        close(f);
        end;
        getdatetime(dt);
        timediff(ddt,ddt2,dt);
        if (semaphore) and ((ddt.hour>0) or (ddt.min>0) or (ddt.sec>15)) then begin
        getdatetime(ddt2);
        if (exist(adrv(systat^.semaphorepath)+'MXUPDATE.'+cstrnfile(cnode))) then begin
                sl1('!','Reload of MATRIX.DAT requested by MXUPDATE semaphore');
		filemode:=66;
		{$I-} reset(systatf); {$I-}
		if ioresult<>0 then sl1('!','Error Re-reading MATRIX.DAT - MXUPDATE.xxx')
		else begin
                        read(systatf,systat^);
			close(systatf);
                        assign(f,adrv(systat^.semaphorepath)+'MXUPDATE.'+cstrnfile(cnode));
			{$I-} erase(f); {$I-}
                        if ioresult<>0 then begin end;
		end;
        end;
        if (exist(adrv(systat^.semaphorepath)+'READLANG.'+cstrnfile(cnode))) then begin
                sl1('!','Reload of language requested by READLANG semaphore');
                getlang(clanguage);
                menufname:=allcaps(langr.menuname);
                if (menufname='') then menufname:='ENGLISH';
                sl1('!','Reload of language complete');
                assign(f,adrv(systat^.semaphorepath)+'READLANG.'+cstrnfile(cnode));
                {$I-} erase(f); {$I-}
                if ioresult<>0 then begin end;
        end;
        if (exist(adrv(systat^.semaphorepath)+'READSYS.'+cstrnfile(cnode))) then begin
                sl1('!','Reload of SYSTEM.DAT requested by READSYS semaphore');
                assign(systemf,adrv(systat^.gfilepath)+'SYSTEM.DAT');
                filemode:=66;
                {$I-} reset(systemf); {$I+}
                if (ioresult<>0) then begin
                      sl1('!','Error Re-reading SYSTEM.DAT - READSYS.xxx');
                      displaybox('Error opening SYSTEM.DAT... exiting.',3000);
                      halt(exiterrors);
                end;
                read(systemf,syst);
                close(systemf);
                assign(f,adrv(systat^.semaphorepath)+'READSYS.'+cstrnfile(cnode));
                {$I-} erase(f); {$I-}
                if ioresult<>0 then begin end;
	end;
        if (exist(adrv(systat^.semaphorepath)+'AUTORUN.'+cstrnfile(cnode))) then begin
		filemode:=66;
                semaphore:=FALSE;
                {runprogram(adrv(systat^.semaphorepath)+'AUTORUN.'+cstrnfile(cnode));}
                doscript(adrv(systat^.semaphorepath)+'AUTORUN.'+cstrnfile(cnode),'');
                semaphore:=TRUE;
                assign(f,adrv(systat^.semaphorepath)+'AUTORUN.'+cstrnfile(cnode));
		{$I-} erase(f); {$I-}
                if ioresult<>0 then begin end;
                skipcommand:=TRUE;
	end;
        if (exist(adrv(systat^.semaphorepath)+'SHUTDOWN.'+cstrnfile(cnode))) then begin
                sl1('!','System shutdown requested by SHUTDOWN semaphore');
		nl;
		sprint('%120%This Node must be shut down due to a systemwide shutdown request.');
		sprint('%120%Please call back later.');
		delay(1500);
                hangup2:=TRUE;
                quitafterdone:=TRUE;
                assign(f,adrv(systat^.semaphorepath)+'SHUTDOWN.'+cstrnfile(cnode));
		{$I-} erase(f); {$I+}
                if ioresult<>0 then begin end; 
	end;
        if (exist(adrv(systat^.semaphorepath)+'LOGOFF.'+cstrnfile(cnode))) then begin
                sl1('!','User logoff requested by LOGOFF semaphore');
		nl;
                sprint('%120%This node has been issued a logoff command.  Please try back later.');
		delay(1500);
                hangup2:=TRUE;
                assign(f,adrv(systat^.semaphorepath)+'LOGOFF.'+cstrnfile(cnode));
		{$I-} erase(f); {$I+}
                if ioresult<>0 then begin end; 
	end;
        if (exist(adrv(systat^.semaphorepath)+'TERMUSER.'+cstrnfile(cnode))) then begin
                sl1('!','User logoff requested by TERMUSER semaphore');
                hangup2:=TRUE;
                assign(f,adrv(systat^.semaphorepath)+'TERMUSER.'+cstrnfile(cnode));
		{$I-} erase(f); {$I+}
                if ioresult<>0 then begin end; 
	end;
        if (exist(adrv(systat^.semaphorepath)+'SCANMAIL.'+cstrnfile(cnode))) then begin
                assign(f,adrv(systat^.semaphorepath)+'SCANMAIL.'+cstrnfile(cnode));
		{$I-} erase(f); {$I+}
                if ioresult<>0 then begin end;
                elevel:=exitnetworkmail;
	end;
        if (exist(adrv(systat^.semaphorepath)+'READUSER.'+cstrnfile(cnode))) then begin
                sl1('!','Reload of user record requested by READUSER semaphore');
                rereaduf;
                assign(f,adrv(systat^.semaphorepath)+'READUSER.'+cstrnfile(cnode));
		{$I-} erase(f); {$I+}
                if ioresult<>0 then begin end;
        end;
        { Short inter-node Messages}
        if (exist(adrv(systat^.semaphorepath)+'NODEMSG.'+cstrnfile(cnode))) then begin
                assign(nmf,adrv(systat^.semaphorepath)+'NODEMSG.'+cstrnfile(cnode));
                {$I-} reset(nmf); {$I+}
                if (ioresult=0) then begin
                        read(nmf,nodemsg);
                        while not(eof(nmf)) do begin
                                read(nmf,nm);
                                seek(nmf,filepos(nmf)-2);
                                write(nmf,nm);
                                seek(nmf,filepos(nmf)+1);
                        end;
                        seek(nmf,filesize(nmf)-1);
                        truncate(nmf);
                        if (filesize(nmf)=0) then begin
                                close(nmf);
                                {$I-} erase(nmf); {$I+}
                                if (ioresult<>0) then begin end;
                        end else begin
                        close(nmf);
                        end;
                        sprompt(gstring(800));
                        sprompt(gstring(801));
                        skipcommand:=TRUE;
                end;
        end;
                
    end;
        if (ch) then c:=chinkey else c:=inkey;
        getdatetime(dt);
        timediff(ddt,tim,dt);
        tleft2;
        if ((systat^.timeout<>-1) and (dt2r(ddt)>systat^.timeout*60)
           and (c=#0) and ((spd<>'KB') or ((spd='KB') and (systat^.timeoutlocal))))
           and not(noexit) then begin
              nl; nl;
              printf('TIMEDOUT');
              if (nofile) then
                print('You have been idle too long.  Logging off at '+time+'.');
              nl; nl;
              hangup2:=TRUE;
              sl1('!','User idle too long.  Logged off.');
        end;
        if ((systat^.timeoutbell<>-1) and (dt2r(ddt)>systat^.timeoutbell*60)
           and (c=#0) and (not tf) and ((spd<>'KB') or ((spd='KB') and (systat^.timeoutlocal))))
           and (useron) and not(noexit) then begin
              tf:=TRUE;
              outkey(^G);
              delay(100);
              outkey(^G);
           end;
        checkhangup;
      end;
      nosound;
    end;
  end;
  if (checkit) then
    if (ord(c) and 128>0) then checkit:=FALSE;
end;

procedure cls;
begin
  if (wantout) then begin
        inuserwindow;
  end;
  if (okansi) then begin
    if (outcom) then begin
      pr(#27+'[2J');
    end;
    if (wantout) then clrscr;
  end else
    outkey(^L);
  if (trapping) then writeln(trapfile,^L);
  curco:=255-curco;
  setc(7 or (0 shl 4));
  lil:=0;
end;

procedure swac(var u:userrec; r:uflags);
begin
  if (r in u.ac) then
    u.ac:=u.ac-[r] else u.ac:=u.ac+[r];
end;

procedure acch(c:char; var u:userrec);
begin
  swac(u,tacch(c));
end;

function aonoff(b:boolean; s1,s2:string):string;
begin
  if (b) then aonoff:=s1 else aonoff:=s2;
end;

function onoff(b:boolean):string;
begin
  if (b) then onoff:=gstring(104) else onoff:=gstring(105);
end;

function syn(b:boolean):string;
begin
  if (b) then syn:=gstring(95) else syn:=gstring(96);
end;
  
procedure pyn(b:boolean);
begin
  print(syn(b));
end;

function yn:boolean;
var c:char;
    s:string;
    yynn,dn:boolean;
begin
  yynn:=dyny;
  if (not hangup) then begin
    dn:=FALSE;
    s:=allcaps(GString(99));
    if (length(s)<4) then s:='YNCD';
    s:=s+^M;
    repeat
    c:=#0;
    repeat
      getkey(c);
      c:=upcase(c);
    until (pos(c,s)<>0) or (hangup);
    if (c=s[5]) then begin
      if not(noynnl) then print('');
      if (yynn) then yn:=TRUE else yn:=FALSE;
      dn:=TRUE;
    end;
    if (c=s[1]) then begin
      if not(yynn) then begin
            sprompt(gstring(103));
            sprompt(gstring(100));
      end;
      if not(noynnl) then print('');
      yn:=TRUE;
      dn:=TRUE;
    end;
    if (c=s[2]) then begin
      if (yynn) then begin
            sprompt(gstring(101));
            sprompt(gstring(102));
      end;
      if not(noynnl) then print('');
      yn:=FALSE;
      dn:=TRUE;
    end;
    if (c=s[3]) then begin
      if (yynn) then begin
            sprompt(gstring(101));
            sprompt(gstring(102));
            yynn:=FALSE;
      end;
    end;
    if (c=s[4]) then begin
      if not(yynn) then begin
            sprompt(gstring(103));
            sprompt(gstring(100));
            yynn:=TRUE;
      end;
    end;
    if (hangup) then begin
      yn:=FALSE;
      dn:=TRUE;
    end;
    until (dn);
  end;
  dyny:=FALSE;
end;

function pynq(s:string):boolean;
begin
  ynq(s);
  pynq:=yn;
end;

procedure onek(var c:char; ch:string);
var s:string;
begin
  repeat
    if (not (onekey in thisuser.ac)) then begin
      input(s,3);
      if length(s)>=1 then c:=s[1] else
	if (s='') and (pos(^M,ch)<>0) then c:=^M else
	  c:=' ';
    end else begin
      mpl(1);
      getkey(c);
      c:=upcase(c);
    end;
  until (pos(c,ch)>0) or (hangup);
  if (hangup) then c:=ch[1];
  if (onekey in thisuser.ac) then begin
    if (onekda) then
      if (c in [#13,#32..#255]) then begin
	outkey(c);
	if (trapping) then write(trapfile,c);
      end;
    if (onekcr) then nl;
  end;
  onekcr:=TRUE;
  onekda:=TRUE;
end;


function centre(s:string):string;
var i,j:integer;
begin
  if (pap<>0) then nl;
  if (s[1]=#2) then s:=copy(s,2,length(s)-1);
  i:=length(s); j:=1;
  if i<80 then
    s:=copy('                                               ',1,
      (80-i) div 2)+s;
  centre:=s;
end;

procedure wkey(var abort,next:boolean);
var c:char;
    x,x2:integer;
    s:string;
begin
  if (empty) then exit;
  if ((abort) or (hangup)) then exit;

  x:=lil;
  getkey(c);
  case upcase(c) of
    #27,' ',^C,^X,^K:abort:=TRUE;
	  'N',^N:begin abort:=TRUE; next:=TRUE; end;
          'P',^S:begin
                s:=gstring(22);
                sprompt(s);
                getkey(c);
                for x2:=1 to lenn(s) do begin
                        prompt(^H' '^H);
                end;
               end;
  end;
  lil:=x;
  if (not allowabort) then begin abort:=FALSE; next:=FALSE; end;
  if (abort) then begin
        if (incom) then com_purge_tx;
        sprompt(gstring(23));
  end;
end;

procedure wkey2(var ch:char; var abort,next:boolean);
var c:char;
    x,x2:integer;
    s:string;
begin
  ch:=#0;
  if (empty) then exit;
  if ((abort) or (hangup)) then exit;

  x:=lil;
  getkey(c);
  case upcase(c) of
    #27,' ',^C,^X,^K:abort:=TRUE;
          ^N:begin abort:=TRUE; next:=TRUE; end;
          ^S:begin
                s:=gstring(22);
                sprompt(s);
                getkey(c);
                for x2:=1 to lenn(s) do begin
                        prompt(^H' '^H);
                end;
               end;
        else begin
                ch:=c;
        end;
  end;
  lil:=x;
  if (not allowabort) then begin abort:=FALSE; next:=FALSE; end;
  if (abort) then begin
        if (incom) then com_purge_tx;
        sprompt(gstring(23));
  end;
  if (ch<>#0) and not(abort) and (incom) then com_purge_tx;
end;


{ load account "i" if i<>usernum; else use "thisuser" account }
procedure loadurec(var u:userrec; i:integer);
var ufo:boolean;
begin
  ufo:=(filerec(uf).mode<>fmclosed);
  filemode:=66; 
  if (not ufo) then reset(uf);
  if (i<>usernum) then begin
    seek(uf,i);
    read(uf,u);
  end else
    u:=thisuser;
  if (not ufo) then close(uf);
end;

{ save account "i" if i<>usernum; save data into "thisuser" account if same }
procedure saveurec(u:userrec; i:integer);
var ufo:boolean;
begin
  ufo:=(filerec(uf).mode<>fmclosed);
  filemode:=66; 
  if (not ufo) then reset(uf);
  seek(uf,i); write(uf,u);
  if (i=usernum) then thisuser:=u;
  if (not ufo) then close(uf);
end;

function aacs1(u:userrec; un:Longint; s:string):boolean;
var s1,s2:string;
    p1,p2,i,j:integer;
    c,c1,c2:char;
    b:boolean;

  procedure getrest;
  begin
    s1:=c;
    p1:=i;
    if ((i<>1) and (s[i-1]='!')) then begin s1:='!'+s1; dec(p1); end;
    if (c in ['E','F','G','M','Q','R','V','X']) then begin
      s1:=s1+s[i+1];
      inc(i);
    end else begin
      j:=i+1;
      repeat
	if (s[j] in ['0'..'9']) then begin
	  s1:=s1+s[j];
	  inc(j);
	end;
      until ((j>length(s)) or (not (s[j] in ['0'..'9'])));
      i:=j-1;
    end;
    p2:=i;
  end;

  function argstat(s:string):boolean;
  var vs:string;
      year,month,day,dayofweek,hour,minute,second,sec100:word;
      x:integer;
      vsi:longint;
      boolstate,res:boolean;
  begin
    boolstate:=(s[1]<>'!');
    if (not boolstate) then s:=copy(s,2,length(s)-1);
    vs:=copy(s,2,length(s)-1); vsi:=value(vs);
    case s[1] of
      'A':begin
          unixtodt(thisuser.bday,fddt);
          res:=(ageuser(formatteddate(fddt,'MM/DD/YYYY'))>=vsi);
          end;
      'B':res:=((value(spd)>=value(vs+'00')) or (spd='KB'));
      'E':res:=(upcase(vs[1]) in u.ar);
      'F':res:=(upcase(vs[1]) in u.ar2);
      'G':res:=(u.sex=upcase(vs[1]));
      'H':begin
	    gettime(hour,minute,second,sec100);
	    res:=(hour=vsi);
	  end;
      'N':res:=(cnode=vsi);
      'Q':res:=(upcase(vs[1]) in u.ar);
      'P':res:=(u.filepoints>=vsi);
      'R':res:=(tacch(upcase(vs[1])) in u.ac);
      'S':res:=(u.sl>=vsi);
      'T':res:=(trunc(nsl) div 60>=vsi);
      'U':res:=(un=vsi);
      'W':begin
	    getdate(year,month,day,dayofweek);
	    res:=(dayofweek=ord(s[1])-48);
	  end;
      'X':begin
		res:=false;
		for x:=1 to 26 do begin
			if (cdavail[x]=vsi) then res:=true;
		end;
	  end;
      'Y':res:=(((lastyesno) and (vsi=1)) or (not(lastyesno) and (vsi=2)));
      {'Y':res:=(trunc(timer) div 60>=vsi);}
      'Z':begin 
		case (memboard.mbtype) of
		     0:if vs='L' then res:=true else res:=false;
		     1:if vs='E' then res:=true else res:=false;
               2:if vs='N' then res:=true else res:=false;
               3:if vs='I' then res:=true else res:=false;
		end;
         end;
         else res:=TRUE;
    end;
    if (not boolstate) then res:=not res;
    argstat:=res;
  end;

begin
  s:=allcaps(s);
  i:=0;
  while (i<length(s)) do begin
    inc(i);
    c:=s[i];
    if (c in ['A'..'Z']) and (i<>length(s)) then begin
      getrest;
      b:=argstat(s1);
      delete(s,p1,length(s1));
      if (b) then s2:='^' else s2:='%';
      insert(s2,s,p1);
      dec(i,length(s1)-1);
    end;
  end;
  s:='('+s+')';
  while (pos('&',s)<>0) do delete(s,pos('&',s),1);
  while (pos('^^',s)<>0) do delete(s,pos('^^',s),1);
  while (pos('(',s)<>0) do begin
    i:=1;
    while ((s[i]<>')') and (i<=length(s))) do begin
      if (s[i]='(') then p1:=i;
      inc(i);
    end;
    p2:=i;
    s1:=copy(s,p1+1,(p2-p1)-1);
    while (pos('|',s1)<>0) do begin
      i:=pos('|',s1);
      c1:=s1[i-1]; c2:=s1[i+1];
      s2:='%';
      if ((c1 in ['%','^']) and (c2 in ['%','^'])) then begin
	if ((c1='^') or (c2='^')) then s2:='^';
	delete(s1,i-1,3);
	insert(s2,s1,i-1);
      end else
	delete(s1,i,1);
    end;
    while(pos('%%',s1)<>0) do delete(s1,pos('%%',s1),1);   {leave only "%"}
    while(pos('^^',s1)<>0) do delete(s1,pos('^^',s1),1);   {leave only "^"}
    while(pos('%^',s1)<>0) do delete(s1,pos('%^',s1)+1,1); {leave only "%"}
    while(pos('^%',s1)<>0) do delete(s1,pos('^%',s1),1);   {leave only "%"}
    delete(s,p1,(p2-p1)+1);
    insert(s1,s,p1);
  end;
  aacs1:=(not (pos('%',s)<>0));
end;

begin
ll:='';
irt:='';
end.

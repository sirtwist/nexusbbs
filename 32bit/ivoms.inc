{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
{ 굇굇� 굇굇�   굇굇�     Intuitive Vision Software                          }
{ 굇굇� 굇굇�  굇굇�      P.O. Box 257773                                    }
{  賽賽 굇굇� 굇굇�       Chicago, IL 60625-7773                             }
{ 굇굇� 굇굇旁굇글        (312) 583-2480                                     }
{ 굇굇� 굇굇굇굇�                                                            }
{ 굇굇� 굇굇굇글                                                             }
{ 굇굇� 굇굇글�           "Today's Leader in Sensible Software Solutions"    }
{  賽賽  賽賽�                                                               }
{ S O F T W A R E (tm)                                                       }
{                                                                            }
{ ivOMS - Offline Mail System                                                }
{                                                                            }
{ Data Structures (Turbo Pascal Format)                                      }
{ INTERNAL USE ONLY                                                          }
{                                                                            }
{ All Material Contained Herein Is Copyright 1995 Intuitive Vision Software. }
{ All Rights Reserved.                                                       }
{                                                                            }
{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}

TYPE

ConfigREC=
RECORD
        BBSName         : STRING[80];
        Sysopname       : STRING[36];
        DataPath        : STRING[80];
        Zone,
        Net,
        Node,
        Point           : WORD;
END;

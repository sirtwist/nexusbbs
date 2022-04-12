{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
{ ±±±±Ü ±±±±Ü   ±±±±Ü     Intuitive Vision Software                          }
{ ±±±±Û ±±±±Û  ±±±±Û      P.O. Box 257773                                    }
{  ßßßß ±±±±Û ±±±±Û       Chicago, IL 60625-7773                             }
{ ±±±±Ü ±±±±Û±±±±Û        (312) 583-2480                                     }
{ ±±±±Û ±±±±±±±±Û                                                            }
{ ±±±±Û ±±±±±±±Û                                                             }
{ ±±±±Û ±±±±±Ûß           "Today's Leader in Sensible Software Solutions"    }
{  ßßßß  ßßßßß                                                               }
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
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}

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

{����������������������������������������������������������������������������}
{ ����� �����   �����     Intuitive Vision Software                          }
{ ����� �����  �����      P.O. Box 257773                                    }
{  ���� ����� �����       Chicago, IL 60625-7773                             }
{ ����� ����۱����        (312) 583-2480                                     }
{ ����� ���������                                                            }
{ ����� ��������                                                             }
{ ����� �������           "Today's Leader in Sensible Software Solutions"    }
{  ����  �����                                                               }
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
{����������������������������������������������������������������������������}

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
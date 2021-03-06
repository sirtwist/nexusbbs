{浜様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様融}
{?      -- THIS FILE IS PART OF THE LIVESYSTEMS COMPRESSOR TOOLBOX. --      ?}
{?          ALL RIGHTS RESERVED  (C) COPYRIGHTED G. HOOGTERP 1994           ?}
{?                                                                          ?}
{?             See the documentation for details on the license.            ?}
{?                                                                          ?}
{藩様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様夕}
Type MagicTypes     = (None,
                       ARC_Type,ARJ_Type,  DWC_Type, HYP_Type,
                       LHA_Type,MDCD_Type, ZIP_Type, SQZ_Type,
                       ZOO_Type,RAR_Type,  SIT_Type
                      );

Type PlatformID            = (
                              ID_IBM,      { IBM and compatibles        }
                              ID_MAC,      { MacIntosh                  }
                              ID_MULTI,    { Platform independend       }
                              ID_OS2,      { OS/2 RAR executable        }
                              ID_DOS       { DOS Executable             }
                             );

     TimeString            = String[20];
     CRCString             = String[8];
     NameString            = String[20];
     CompressorID          = String[4];
     InfoBlock             = Array[1..255] Of Byte;

     IBM                   = Record        { Typecasting record for IBM }
        FileName           : ComStr;       { platform                   }
        OriginalSize       : LongInt;
        CompressedSize     : LongInt;
        CompressionName    : NameString;
        FileCRC            : CRCString;
        FileDate           : TimeString;
        SaveID             : String[3];
        Extra              : String[63];
     End; {Record}

     InfoArray   = Array[0..3] Of Char;
     MacName     = String[63];

     MAC       = Record                    { Typecasting record for MAC }
      ResName      : MacName;              { platform                   }
      ResCompSize  : LongInt;
      ResRealSize  : LongInt;
      ResourceType : Byte;
      DataCompSize : LongInt;
      DataRealSize : LongInt;
      DataType     : Byte;
      FileTyp      : InfoArray;
      FileCreator  : InfoArray;
      Filler       : Array[1..165] Of Byte;
     End;

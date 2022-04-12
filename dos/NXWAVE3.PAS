unit nxwave3;

interface

uses crt,dos,ivmodem,nxwave2,nxwave4,multi;

procedure domailsetup(config:boolean);

implementation

uses nxwave1;

procedure domailsetup(config:boolean);
  var protf:file of protrec;
      prot:protrec;
      s:string;
      c:char;
      x,x2:integer;
      next,abort,done:boolean;

        function cform(w:word):string;
        var s:string;
        begin
           s:='';        
           if (nxwu.format=w) then s:=' %080%(%150%Current%080%)';
           cform:=s;
        end;

        function showprot(i:integer):string;
        begin
                assign(protf,adrv(systat.gfilepath)+'PROTOCOL.DAT');
                filemode:=66;
                {$I-} reset(protf); {$I+}
                if ioresult<>0 then begin
                        showprot:='';
                        exit;
                end;
                if (i<filesize(protf)) then begin
                seek(protf,i);
                read(protf,prot);
                close(protf);
                showprot:=prot.descr;
                end else showprot:='None';
        end;

        function showarc(i:integer):string;
        var af:file of archiverrec;
            a:archiverrec;
        begin
        assign(af,adrv(systat.gfilepath)+'ARCHIVER.DAT');
        {$I-} reset(af); {$I+}
        if (ioresult<>0) then begin
                ivwriteln('%120%No Archivers Available!');
                exit;
        end;
        if (i>filesize(af)-1) then begin
                showarc:='None';
                close(af);
                exit;
        end;
        seek(af,i);
        read(af,a);
        if (a.active) then showarc:=allcaps(a.extension)+'  '+a.name else
            showarc:='';
        close(af);
        end;

        function showform(w:word):string;
        begin
        if (w=0) then showform:='QWK Compatible' else showform:='Blue Wave Compatible';
        end;

        procedure getprot;
        var s:string;
            done:boolean;
        begin
                s:='';
                assign(protf,adrv(systat.gfilepath)+'PROTOCOL.DAT');
                filemode:=66;
                {$I-} reset(protf); {$I+}
                if ioresult<>0 then begin
                        ivwriteln('Error Opening PROTOCOL.DAT!');
                        exit;
                end;
                done:=FALSE;
                repeat
                cls;
                ivwriteln('%090%Available Protocols:');
                ivwriteln('');
                seek(protf,0);
                while not(eof(protf)) do begin
                        read(protf,prot);
                        if (prot.ulcmd<>'') and
                        (prot.dlcmd<>'') and (aacs(prot.acs)) and (xbactive in prot.xbstat) then begin
                        ivwrite(prot.descr);
                        if (nxwu.protocol=filepos(protf)-1) then ivwriteln('  %080%(%150%Current%080%)')
                                else ivwriteln('');
                        end;
                end;
                seek(protf,0);
                ivwriteln('');
                ivwrite('%090%Protocol (%150%Q%090%=Quit) : %150%');
                repeat
                while not(ivKeypressed) do begin doslice; end;
                s[1]:=upcase(ivreadchar);
                until (s[1]<>#0);
                if (s[1]='Q') then done:=true else begin
                        while not(eof(protf)) and not(done) do begin
                                read(protf,prot);
                                if (prot.ulcmd<>'') and (prot.dlcmd<>'') and
                                (aacs(prot.acs)) and (xbactive in prot.xbstat) then begin
                                if (upcase(s[1])=upcase(prot.ckeys)) and 
                                        ((prot.ulcmd<>'') and (prot.dlcmd<>''))
                                        and (aacs(prot.acs))
                                        then begin
                                        nxwu.protocol:=filepos(protf)-1;
                                        done:=true;
                                end;
                                end;
                        end;
                end;
                if not(done) then ivwriteln('Invalid Selection.');
        until (done);
        close(protf);
        end;
        
        procedure gettwits;
        var done:boolean;
            x:integer;
            c:char;
            s:string;
        begin
        done:=false;
        repeat
        cls;
        ivwriteln('%090%Twit Filters');
        ivwriteln('');
        ivwriteln('%090%Twit Filters allow you to filter out messages written by certain people');
        ivwriteln('%090%that you may not want to read messages from.');
        ivwriteln('');
        for x:=1 to 5 do
        ivwriteln('%080%(%150%'+cstr(x)+'%080%) %090%'+nxwu.twits[x]);
        ivwriteln('');
        ivwrite('%090%Selection (%150%Q%090%=Quit) : %150%');
        repeat
        while not(ivKeypressed) do begin doslice; end;
        c:=upcase(ivreadchar);
        until (c<>#0);
        case c of
                '1'..'5':begin
                        ivwriteln('%090%New name to twit out:');
                        ivwrite('%090%> ');
                        s:='';
                        ivreadln(s,30,'U');
                        if (s=' ') then if pynq('Set to empty string? ') then
                                begin
                                s:='';
                                nxwu.twits[ord(c)-48]:='';
                                end;
                        if (s<>'') then nxwu.twits[ord(c)-48]:=s;
                        end;
                'Q':done:=true;
        end;
        until (done);
        end;

        procedure getmacros;
        var done:boolean;
            x:integer;
            c:char;
            s:string;
        begin
        done:=false;
        repeat
        cls;
        ivwriteln('%090%User Macros');
        ivwriteln('');
        ivwriteln('%090%Macros allow you to have a predefined set of commands ready and waiting');
        ivwriteln('%090%for nxWAVE to use.  All you have to do is tell it which one!');
        ivwriteln('');
        for x:=1 to 3 do
        ivwriteln('%080%(%150%'+cstr(x)+'%080%) %090%'+copy(nxwu.macros[x],1,77));
        ivwriteln('');
        ivwrite('%090%Selection (%150%Q%090%=Quit) : %150%');
        repeat
        while not(ivKeypressed) do begin doslice; end;
        c:=upcase(ivreadchar);
        until (c<>#0);
        case c of
                '1'..'3':begin
                        ivwriteln('%090%New Macro:');
                        ivwrite('%090%> ');
                        s:='';
                        ivreadln(s,78,'U');
                        if (s=' ') then if pynq('Set to empty string? ') then
                                begin
                                s:='';
                                nxwu.macros[ord(c)-48]:='';
                                end;
                        if (s<>'') then nxwu.macros[ord(c)-48]:=s;
                        end;
                'Q':done:=true;
        end;
        until (done);
        end;

        procedure getkeywords;
        var done:boolean;
            x:integer;
            c:char;
            s:string;
        begin
        done:=false;
        repeat
        cls;
        ivwriteln('%090%User Keywords');
        ivwriteln('');
        ivwriteln('%090%Keywords allow you to define certain words that determine whether a message');
        ivwriteln('%090%is downloaded or not.  If the keyword is in the message, it is downloaded.');
        ivwriteln('');
        for x:=1 to 10 do
        ivwriteln('%080%(%150%'+cstr(x)+'%080%) %090%'+nxwu.keywords[x]);
        ivwriteln('');
        ivwrite('%090%Selection (%150%Q%090%=Quit) : %150%');
        repeat
        while not(ivKeypressed) do begin doslice; end;
        c:=upcase(ivreadchar);
        until (c<>#0);
        case c of
                '0'..'9':begin
                        ivwrite('%090%New keyword: %150%');
                        s:='';
                        ivreadln(s,20,'U');
                        if (s=' ') then if pynq('Set to empty string? ') then
                                begin
                                s:='';
                                if (c='0') then nxwu.keywords[10]:='' else
                                nxwu.keywords[ord(c)-48]:='';
                                end;
                        if (s<>'') then 
                        if (c='0') then nxwu.keywords[10]:=s else
                        nxwu.keywords[ord(c)-48]:=s;
                        end;
                'Q':done:=true;
        end;
        until (done);
        end;

        procedure getfilters;
        var done:boolean;
            x:integer;
            c:char;
            s:string;
        begin
        done:=false;
        repeat
        cls;
        ivwriteln('%090%User Filters');
        ivwriteln('');
        ivwriteln('%090%Filters allow you to define certain words that determine whether a message');
        ivwriteln('%090%is downloaded or not.  If the filter is in the message, it is NOT downloaded.');
        ivwriteln('');
        for x:=1 to 10 do
        ivwriteln('%080%(%150%'+cstr(x)+'%080%) %090%'+nxwu.filters[x]);
        ivwriteln('');
        ivwrite('%090%Selection (%150%Q%090%=Quit) : %150%');
        repeat
        while not(ivKeypressed) do begin doslice; end;
        c:=upcase(ivreadchar);
        until (c<>#0);
        case c of
                '0'..'9':begin
                        ivwrite('%090%New filter: %150%');
                        s:='';
                        ivreadln(s,20,'U');
                        if (s=' ') then if pynq('Set to empty string? ') then
                                begin
                                s:='';
                                if (c='0') then nxwu.filters[10]:='' else
                                nxwu.filters[ord(c)-48]:='';
                                end;
                        if (s<>'') then 
                        if (c='0') then nxwu.filters[10]:=s else
                        nxwu.filters[ord(c)-48]:=s;
                        end;
                'Q':done:=true;
        end;
        until (done);
        end;


        procedure getarc;
        var s,s2,s3:string;
            i,ha:integer;
            done:boolean;
        begin
                s:='';
                done:=FALSE;
                repeat
                cls;
                i:=1;
                ivwriteln('%090%Available Archivers:');
                ivwriteln('');
                while (s2<>'None') do begin
                        s2:=showarc(i);
                        if (s2<>'') and (s2<>'None') then begin
                                ivwriteln('%080%(%150%'+mln(cstr(i),3)+'%080%) %090%'+s2);
                                ha:=i;
                        end;
                        inc(i);
                end;
                ivwrite('%090%Archiver (%150%Q%090%=Quit) : %150%');
                s:='';
                ivreadln(s,3,'U');
                if (s[1]='Q') then done:=true else 
                                begin
                                        if (value(s)<=ha) and (value(s)>0) then begin
                                                nxwu.archiver:=value(s);
                                                done:=true;
                                        end;
                                end;
                if not(done) then ivwriteln('Invalid Selection.');
                until (done);
        end;

  begin
      assign(nxwuf,adrv(systat.gfilepath)+'OMSUSER.DAT');
      assign(nxwf,adrv(systat.gfilepath)+'NXWAVE.DAT');
      filemode:=66;
      {$I-} reset(nxwf); {$I+}
      if (ioresult<>0) then begin
        with nxw do begin          
                Packetname:='';
                LocalDLPath:='C:\';
                LocalULPath:='C:\';
                DefaultProtocol:=0;
                DefaultArchiver:=0;
                DefaultFormat:=0;
                for x:=1 to 5 do news[x]:='';
                LocalTempPath:=systat.temppath;
                MaxFREQ:=10;
                NewFiles:=TRUE;
                suppressprotocol:=0;
                suppressarchiver:=0;
                maxmsgs:=0;
                maxk:=0;
                freqacs:='';
                log:=true;
                lastupd:=0;
                for x:=1 to 669 do res[x]:=0;
                crc:=227;
        end;
        rewrite(nxwf);
        write(nxwf,nxw);
      end;
      seek(nxwf,0);
      read(nxwf,nxw);
      close(nxwf);
      {$I-} reset(nxwuf); {$I+}
      if (ioresult<>0) then begin
                {$I-} rewrite(nxwuf); {$I+}
                if (ioresult<>0) then begin
                        writeln('Error creating OMSUSER.DAT');
                        halt;
                end;
                writeln(adrv(systat.gfilepath)+'OMSUSER.DAT');
                        with nxwu do begin
                            numdl:=0;
                            for x2:=1 to 10 do keywords[x2]:='';
                            for x2:=1 to 10 do filters[x2]:='';
                            for x2:=1 to 3 do macros[x2]:='';
                            archiver:=nxw.defaultarchiver;
                            protocol:=nxw.defaultprotocol;
                            format:=nxw.defaultformat;
                            bundlefrom:=FALSE;
                            password:='';
                            newfiles:=nxw.newfiles;
                            lastrun:=0;
                            for x2:=1 to 5 do twits[x2]:='';
                            totalposts:=0;
                            totalmsgs:=0;
                            totalk:=0;
                            totalfreq:=0;
                            for x2:=1 to sizeof(res) do res[x2]:=0;
                            crc:=227;
                        end;
                        write(nxwuf,nxwu);
                end;
      if filesize(nxwuf)-1<thisuser.userid then begin
                for x:=filesize(nxwuf) to thisuser.userid do begin
                        seek(nxwuf,x);
                        with nxwu do begin
                            numdl:=0;
                            for x2:=1 to 10 do keywords[x2]:='';
                            for x2:=1 to 10 do filters[x2]:='';
                            for x2:=1 to 3 do macros[x2]:='';
                            archiver:=nxw.defaultarchiver;
                            protocol:=nxw.defaultprotocol;
                            format:=nxw.defaultformat;
                            bundlefrom:=FALSE;
                            password:='';
                            newfiles:=nxw.newfiles;
                            lastrun:=0;
                            for x2:=1 to 5 do twits[x2]:='';
                            totalposts:=0;
                            totalmsgs:=0;
                            totalk:=0;
                            totalfreq:=0;
                            for x2:=1 to sizeof(res) do res[x2]:=0;
                            crc:=227;
                        end;
                        write(nxwuf,nxwu);
                end;
      end;
      seek(nxwuf,thisuser.userid);
      read(nxwuf,nxwu);
      done:=false;
      abort:=false;
      if (config) then
      while not(done) do begin
        cls;
        ivwriteln('%090%Offline Mail Configuration');
        ivwriteln('');
        with nxwu do begin
        while not(abort) do begin

ivwriteln('%090%(%150%C%090%)hoose message bases for download');
ivwriteln('');
ivwriteln('%090%(%150%K%090%)eywords                            %090%(%150%F%090%)ilters');
ivwriteln('%090%(%150%M%090%)acros                              %090%(%150%T%090%)wit Filters');
ivwriteln('');
ivwriteln('%090%(%150%A%090%)rchiver                : %150%'+showarc(archiver));
ivwriteln('%090%(%150%P%090%)rotocol                : %150%'+showprot(protocol));
ivwriteln('%090%(%150%$%090%) Access key            : %150%'+allcaps(password));
ivwriteln('%090%(%150%B%090%)undle mail from you    : %150%'+onoff(bundlefrom));
ivwriteln('%090%(%150%N%090%) Include new file list : %150%'+onoff(newfiles));
ivwriteln('');
ivwriteln('%090%(%150%R%090%)eset pointers in all tagged bases');
        abort:=true;
        end;
        abort:=false;
        ivwriteln('');
        ivwrite('%090%Selection (%150%Q%090%=Quit) : %150%');
        repeat
        while not(ivKeypressed) do begin doslice; end;
        c:=upcase(ivreadchar);
        until (c<>#0);
        case upcase(c) of
                'C':getbases;
                'A':getarc;
                'P':getprot;
                '$':begin
                        ivwriteln('');
                        ivwrite('%070%Access Key: %150%');
                        s:=password;
                        ivreadln(s,20,'U');
                        if (s=' ') then if pynq('Set to Empty String? ') then
                                begin
                                password:='';
                                s:='';
                                end;
                        if (s<>'') then password:=s;
                    end;
                'B':bundlefrom:=not bundlefrom;
{                'N':newfiles:=not newfiles;
                'K':getkeywords;
                'F':getfilters;
                'M':getmacros; }
                'T':gettwits;
                'R':resetpointers;
                'Q':done:=true;
        end;
        end;
        end;
        nxwu.hasconfig:=TRUE;
        seek(nxwuf,thisuser.userid);
        write(nxwuf,nxwu);
        close(nxwuf);
end;

end.


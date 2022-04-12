{$A+,B+,D-,E+,F+,I+,L-,N-,O+,R-,S+,V-}
unit archive2;

interface

uses
  crt, dos,
  myio3,
  archive1, file0, file1, file4, file9, file11,
  execbat,
  common;

procedure doarccommand(cc:char; fn:astr);

implementation

const
  maxdoschrline=127;

procedure doarccommand(cc:char; fn:astr);
var s,s1,s2,os1:astr;
    atype,numfl,rn,pl:integer;
    i,j,x:integer;
    c:char;
    abort,next,done,ok,ok1:boolean;
    ok2:integer;
    fnx:boolean;    
    fil1,fil2:boolean;    {* whether listed/unlisted files in list *}
    wenttosysop,delbad,savpause:boolean;
    rfpts:real;
    fi:file of byte;
    dstr,nstr,estr:astr;
    bb:byte;
    c_files,c_oldsiz,c_newsiz,oldsiz,newsiz:longint;
    af:file of archiverrec;
    a:archiverrec;
    thisonly:boolean;

  function stripname(i:astr):astr;
  var i1:astr; n:integer;

    function nextn:integer;
    var n:integer;
    begin
      n:=pos(':',i1);
      if (n=0) then n:=pos('\',i1);
      if (n=0) then n:=pos('/',i1);
      nextn:=n;
    end;

  begin
    i1:=i;
    while nextn<>0 do i1:=copy(i1,nextn+1,80);
    stripname:=i1;
  end;


  procedure testfiles(b:integer; fn:astr; delbad:boolean; var abort,next:boolean);
  var fi:file of byte;
      oldboard,pl,rn,atype:integer;
      ok:boolean;
  begin
    oldboard:=fileboard;
    if (fileboard<>b) then changefileboard(b);
    if (fileboard=b) then begin
      recno(align(fn),pl,rn); { loads in memuboard }
      abort:=FALSE; next:=FALSE;
      while (fn<>'') and (rn<>0) and (not abort) and (not hangup) do begin
        NXF.Seekfile(rn); NXF.Readheader;
        fn:=adrv(memuboard.dlpath)+NXF.Fheader.filename;
        if (afound(fn)) then begin
          sprompt('%030%Testing %150%'+sqoutsp(fn));
          ok:=TRUE;
          if (not exist(fn)) then begin
            sprompt('%120%File %150%'+sqoutsp(fn)+'%120% doesn''t exist.');
            ok:=FALSE;
          end else begin
            arcintegritytest(ok,atype,sqoutsp(fn));
            if (not ok) then begin
              sprompt('%120%File %150%'+sqoutsp(fn)+'%120% didn''t pass integrity test.');
              if (delbad) then begin
                NXF.Deletefile(rn);
                pl:=NXF.Numfiles;
                assign(fi,fn);
                {$I-} erase(fi); {$I+}
                if (ioresult<>0) then sprompt('%120%Error erasing %150%'+sqoutsp(fn)+'%120%!');
              end;
            end;
          end;
        end;
        nrecno(align(fn),pl,rn);
        wkey(abort,next);
      end;
    end;
    fileboard:=oldboard;
  end;

  procedure cmtfiles(b:integer; fn:astr; var abort,next:boolean);
  var fi:file of byte;
      oldboard,pl,rn,atype:integer;
      ok:boolean;
  begin
    oldboard:=fileboard;
    if (fileboard<>b) then changefileboard(b);
    if (fileboard=b) then begin
      recno(align(fn),pl,rn); { loads in memuboard }
      abort:=FALSE; next:=FALSE;
      while (fn<>'') and (rn<>0) and (not abort) and (not hangup) do begin
        NXF.Seekfile(rn); NXF.Readheader;
        fn:=adrv(memuboard.dlpath)+NXF.Fheader.filename;
        if (afound(fn)) then begin
          sprompt('%030%Commenting %150%'+sqoutsp(fn));
          ok:=TRUE;
          if (not exist(fn)) then begin
            sprompt('%120%File %150%'+sqoutsp(fn)+'%120% doesn''t exist.');
            ok:=FALSE;
          end
          else arccomment(ok,atype,memuboard.cmttype,sqoutsp(fn));
        end;
        nrecno(align(fn),pl,rn);
        wkey(abort,next);
      end;
    end;
    fileboard:=oldboard;
  end;

  procedure cvtfiles(b:integer; fn:astr; toa:integer;
                     var c_files,c_oldsiz,c_newsiz:longint;
                     var abort,next:boolean);
  var fi:file of byte;
      s:astr;
      oldboard,pl,rn,atype:integer;
      ok:boolean;
      ok2:integer;
  begin
    oldboard:=fileboard;
    if (fileboard<>b) then changefileboard(b);
    if (fileboard=b) then begin
      recno(align(fn),pl,rn); { loads in memuboard }
      abort:=FALSE; next:=FALSE;
      while (fn<>'') and (rn<>0) and (not abort) and (not hangup) do begin
        NXF.Seekfile(rn); NXF.Readheader;
        fn:=adrv(memuboard.dlpath)+NXF.Fheader.filename;
        if (afound(fn)) then begin
          sprint('%030%Converting %150%'+sqoutsp(fn));
          ok:=FALSE;
          if (not exist(fn)) then
            sprompt('%120%File %150%'+sqoutsp(fn)+'%120% doesn''t exist.')
          else begin
            assign(fi,sqoutsp(fn));
            {$I-} reset(fi); {$I+}
            ok:=(ioresult=0);
            if (ok) then begin
                oldsiz:=trunc(filesize(fi));
                close(fi);
            end else
                sprompt('%120%Unable to access %150%'+sqoutsp(fn));
            if not(ok) then exit;
            ok:=TRUE;
            seek(af,toa);
            read(af,a);
            if (fn[pos('.',fn)+2] in ['0'..'9']) then begin
            s:=copy(fn,1,pos('.',fn))+a.extension[1]+copy(fn,length(fn)-1,2);
            end else begin
            s:=copy(fn,1,pos('.',fn))+a.extension;
            end;
            nl;
            sprompt('%030%Converting archive... ');
            conva(ok2,atype,bb,newtemp,sqoutsp(fn),sqoutsp(s));
            ok:=FALSE;
      case ok2 of
        0:begin
                sprompt('%150%Finished!|LF|');
                ok:=TRUE;
          end;
        1:begin
                sprompt('%120%ERROR! Not converted!|LF|');
                sl1('!','Error converting!');
          end;
        3:begin
                sprompt('%150%No conversion necessary.|LF|');
                sl1('!','Archive skipped.  No conversion necessary.');
          end;
        4:begin
                sprompt('%150%Archive AV stamped.  Not converted.|LF|');
                sl1('!','Archive AV stamped.  No conversion necessary.');
          end;
        end;
            nl;
            if (ok) then begin
                if (not exist(sqoutsp(s))) then begin
                  sprompt('%120%Unable to access %150%'+sqoutsp(s));
                  sl1('!','Unable to access '+sqoutsp(s));
                  ok:=FALSE;
                end;
            end;
            if (ok) then begin
              NXF.Fheader.Filename:=stripname(sqoutsp(s));

              assign(fi,sqoutsp(s));
              {$I-} reset(fi); {$I+}
              ok:=(ioresult=0);
              if (not ok) then begin
                sprint('%120%Unable to access %150%'+sqoutsp(s));
                sl1('!','Unable to access '+sqoutsp(s));
              end else begin
                newsiz:=trunc(filesize(fi));
                NXF.Fheader.Filesize:=filesize(fi);
                close(fi);
              end;
              NXF.Rewriteheader(NXF.Fheader);

              if (ok) then begin
                inc(c_oldsiz,oldsiz);
                inc(c_newsiz,newsiz);
                inc(c_files);
                sprint('%070%Original Total Space : %030%'+cstrl(oldsiz)+' bytes');
                sprint('%070%New Total Space      : %030%'+cstrl(newsiz)+' bytes');
                if (oldsiz-newsiz>0) then
                sprint('%070%Space Saved          : %030%'+cstrl(oldsiz-newsiz)+' bytes')
                else
                sprint('%070%Space Wasted         : %030%'+cstrl(newsiz-oldsiz)+' bytes');
                sl1('!','Converted archive '+sqoutsp(fn)+' to '+stripname(sqoutsp(s)));
              end;
            end else begin
              sl1('!','Unable to convert '+sqoutsp(fn)+'.');
              sprint('%120%Unable to convert '+sqoutsp(fn)+'.');
            end;
          end;
        end;
        nrecno(align(fn),pl,rn);
        wkey(abort,next);
      end;
    end;
    fileboard:=oldboard;
  end;

begin
  savpause:=(pause in thisuser.ac);
  thisonly:=(fn<>'');
  if (savpause) then thisuser.ac:=thisuser.ac-[pause];
  numfl:=0;
  fiscan(pl); { loads in memuboard }
  assign(af,adrv(systat^.gfilepath)+'ARCHIVER.DAT');
  filemode:=66;
  {$I-} reset(af); {$I+}
  if (ioresult<>0) then begin
        sprint('%120%Error Opening Archiver Information!');
        exit;
  end;
  case cc of
    '1':begin
          if (fn='') then begin
          nl;
          sprint('%030%Convert Archives');
          nl;
          sprint('%030%Filespec: ');
          fn:='*.*';
          sprompt(gstring(19)); mpl(70); input(fn,70);
          end;
          c_files:=0; c_oldsiz:=0; c_newsiz:=0;
          if (fn<>'') then begin
            nl;
            abort:=FALSE; next:=FALSE;
            listarctypes;
            repeat
              sprompt('%030%Archive format to use [%150%? %030%List] : %150%'); scaninput(s,'?'^M,TRUE);
              if (s='?') then begin nl; listarctypes; end;
            until (s<>'?');
            if (s='') then exit;
            if (value(s)<>0) then bb:=value(s);
            if (bb<>0) then begin
              sl1(':','Conversion process began at '+date+' '+time+'.');
              if (isul(fn)) then begin
                fsplit(fn,dstr,nstr,estr); s:=dstr;
                findfirst(fn,AnyFile-Directory-VolumeID,dirinfo);
                abort:=FALSE; next:=FALSE;
                while (doserror=0) and (not abort) and (not hangup) do begin
                  fn:=fexpand(sqoutsp(dstr+dirinfo.name));
                  if (afound(fn)) then begin
                      assign(fi,sqoutsp(fn));
                      {$I-} reset(fi); {$I+}
                      ok:=(ioresult=0);
                      if (ok) then begin
                        oldsiz:=trunc(filesize(fi));
                        close(fi);
                      end else
                        sprint('%120%Unable to access '+sqoutsp(fn)+'.');
                      if not(ok) then exit;
                      nl;
                    sprint('%030%Converting '+fn+'...');
                    ok:=TRUE;
                    seek(af,bb);
                    read(af,a);
            if (fn[pos('.',fn)+2] in ['0'..'9']) then begin
            s:=copy(fn,1,pos('.',fn))+a.extension[1]+copy(fn,length(fn)-1,2);
            end else begin
            s:=copy(fn,1,pos('.',fn))+a.extension;
            end;
                    conva(ok2,atype,bb,newtemp,fn,s);
            ok:=FALSE;
      case ok2 of
        0:begin
                sprompt('%150%Finished!|LF|');
                ok:=TRUE;
          end;
        1:begin
                sprompt('%120%ERROR! Not converted!|LF|');
                sl1('!','Error converting!');
          end;
        3:begin
                sprompt('%150%No conversion necessary.|LF|');
                sl1('!','Archive skipped.  No conversion necessary.');
          end;
        4:begin
                sprompt('%150%Archive AV stamped.  Not converted.|LF|');
                sl1('!','Archive AV stamped.  No conversion necessary.');
          end;
        end;
                    if (ok) then begin
                        if (not exist(sqoutsp(s))) then begin
                          sprint('%120%Unable to access '+sqoutsp(s)+'.');
                          sl1('!','Unable to access '+sqoutsp(s)+'.');
                          ok:=FALSE;
                        end;
                    end;
                    if (ok) then begin
                      assign(fi,sqoutsp(s));
                      {$I-} reset(fi); {$I+}
                      ok:=(ioresult=0);
                      if (ok) then begin
                        newsiz:=trunc(filesize(fi));
                        close(fi);
                      end else
                        sprint('%120%Unable to access '+sqoutsp(s)+'.');

                      if (ok) then begin
                        inc(c_oldsiz,oldsiz);
                        inc(c_newsiz,newsiz);
                        inc(c_files);
                        nl;
                        sprint('%070%Original Total Space : %030%'+cstrl(oldsiz)+' bytes');
                        sprint('%070%New Total Space      : %030%'+cstrl(newsiz)+' bytes');
                        if (oldsiz-newsiz>0) then
                        sprint('%070%Space Saved          : %030%'+cstrl(oldsiz-newsiz)+' bytes')
                        else
                        sprint('%070%Space Wasted         : %030%'+cstrl(newsiz-oldsiz)+' bytes');
                      end;
                    end else begin
                      sl1('!','Unable to convert '+sqoutsp(fn)+'.');
                      sprint('%120%Unable to convert '+sqoutsp(fn)+'.');
                    end;
                  end;
                  findnext(dirinfo);
                  wkey(abort,next);
                end;
                if (abort) then sprint('|LF|%120%Conversion Aborted.');
              end else begin
                if (thisonly) then ok1:=FALSE else begin
                ok1:=pynq('%030%Search all file bases? %150%');
                nl;
                end;
                if (ok1) then begin
                  i:=0; abort:=FALSE; next:=FALSE;
                  while (not abort) and (i<=maxulb) and (not hangup) do begin
                    if (fbaseac(i)) and not(memuboard.cdrom) then
                      cvtfiles(i,fn,bb,c_files,c_oldsiz,c_newsiz,abort,next);
                    inc(i);
                    wkey(abort,next);
                    if (next) then abort:=FALSE;
                  end;
                end else if not(memuboard.cdrom) then begin
                  nl;
                  cvtfiles(fileboard,fn,bb,c_files,c_oldsiz,c_newsiz,
                           abort,next);
                end;
              end;
              sl1(':','Conversion process ended at '+date+' '+time+'.');
              if not(thisonly) then begin
              nl;
              sprint('%070%Archives Converted   : %120%'+cstr(c_files));
              sprint('%070%Original Total Space : %120%'+cstrl(c_oldsiz)+' bytes');
              sprint('%070%New Total Space      : %120%'+cstrl(c_newsiz)+' bytes');
              if (c_oldsiz-c_newsiz>0) then
              sprint('%070%Space Saved          : %120%'+cstrl(c_oldsiz-c_newsiz)+' bytes')
              else
              sprint('%070%Space Wasted         : %120%'+cstrl(c_newsiz-c_oldsiz)+' bytes');
              sl1('!','Converted '+cstr(c_files)+' Archives-Old Size='+
                       cstrl(c_oldsiz)+'b, New Size='+cstrl(c_newsiz)+'b');
              end;
            end;
          end;
        end;
    '2':begin
          nl;
          sprint('%030%Archive Comment Update');
          nl;
          sprint('%030%Filespec:');
          sprompt(gstring(19)); mpl(70); input(fn,70);
          if (fn<>'') then begin
            nl;
            abort:=FALSE; next:=FALSE;
            if (isul(fn)) then begin
              defaultst:='1';
              sprompt('%030%Comment File To Use [%150%1%030%-%150%3,%150%Enter%030%=None] : %150%');
              inil(bb);
              if (badini) then bb:=1;
              if (bb<0) or (bb>3) then bb:=1;
              fsplit(fn,dstr,nstr,estr); s:=dstr;
              findfirst(fn,AnyFile-Directory-VolumeID,dirinfo);
              abort:=FALSE; next:=FALSE;
              while (doserror=0) and (not abort) and (not hangup) do begin
                fn:=fexpand(sqoutsp(dstr+dirinfo.name));
                if (afound(fn)) then begin
                  sprint('%030%Commenting '+fn+'...');
                  ok:=TRUE;
                  arccomment(ok,atype,bb,fn);
                end;
                findnext(dirinfo);
                wkey(abort,next);
              end;
              if (abort) then sprint('|LF|%120%Comment Update Aborted.');
            end else begin
              ok1:=pynq('%030%Search All File Bases? %150%');
              nl;
              if (ok1) then begin
                i:=0; abort:=FALSE; next:=FALSE;
                while (not abort) and (i<=maxulb) and (not hangup) do begin
                  if (fbaseac(i)) then cmtfiles(i,fn,abort,next);
                  inc(i);
                  wkey(abort,next);
                  if (next) then abort:=FALSE;
                end;
              end else
                cmtfiles(fileboard,fn,abort,next);
            end;
          end;
        end;
    '3':begin
          nl;
          sprint('%030%Archive Integrity Test');
          nl;
          sprint('%030%FileMask:');
          sprompt(gstring(19)); mpl(70); input(fn,70);
          if (fn<>'') then begin
            nl;
            delbad:=pynq('%120%Delete files that don''t pass testing? ');
            nl;
            abort:=FALSE; next:=FALSE;
            if (isul(fn)) then begin
              fsplit(fn,dstr,nstr,estr); s:=dstr;
              findfirst(fn,AnyFile-Directory-VolumeID,dirinfo);
              abort:=FALSE; next:=FALSE;
              while (doserror=0) and (not abort) and (not hangup) do begin
                fn:=fexpand(sqoutsp(dstr+dirinfo.name));
                if (afound(fn)) then begin
                  sprint('%030%Testing '+fn+'...');
                  ok:=TRUE;
                  arcintegritytest(ok,atype,fn);
                  if (not ok) then begin
                    sprint('File '+fn+' Failed Integrity Test.');
                    if (delbad) then begin
                      sprompt('%030%Deleting '+fn+'... ');
                      assign(fi,fn);
                      {$I-} erase(fi); {$I+}
                      if (ioresult<>0) then sprint('%120%Error.')
                        else sprint('%150%Ok.');
                    end;
                  end;
                end;
                findnext(dirinfo);
                wkey(abort,next);
              end;
              if (abort) then sprint('|LF|%120%Integrity testing aborted.');
            end else begin
              ok1:=pynq('%030%Search all file bases? %150%');
              nl;
              if (ok1) then begin
                i:=0; abort:=FALSE; next:=FALSE;
                while (not abort) and (i<=maxulb) and (not hangup) do begin
                  if (fbaseac(i)) then testfiles(i,fn,delbad,abort,next);
                  inc(i);
                  wkey(abort,next);
                  if (next) then abort:=FALSE;
                end;
              end else
                testfiles(fileboard,fn,delbad,abort,next);
            end;
          end;
        end;
    '0':begin {* add files *}
        end;
    '4':begin {* extract *}
        end;
  end;
  close(af);
  if (savpause) then thisuser.ac:=thisuser.ac+[pause];
end;

end.

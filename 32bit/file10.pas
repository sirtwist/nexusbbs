{$A+,B+,D-,E+,F+,I+,L+,N-,O+,R-,S+,V-}
unit file10;

interface

uses
  crt,dos,
  myio3,
  file0, file1, file2, file4, file9,
  common;

procedure validatefiles;

implementation

uses
  miscx,file11;


procedure creditfile(var u:userrec; un:integer; var f:fheaderrec; credit:boolean);
var rfpts:real;
    gotpts:longint;
begin
  if (not systat^.fileptratio) then
    gotpts:=0
  else begin
    rfpts:=(f.filesize/1024)/systat^.fileptcompbasesize;
    gotpts:=round(rfpts*systat^.fileptcomp);
    if (gotpts<1) then gotpts:=1;
  end;
  if (credit) then
    sprompt('%140%Awarding Upload Credits: ')
  else
    sprompt('%140%Taking Away Upload Credits: ');
  prompt('1 file, '+cstrl(f.filesize div 1024)+'k');
  if (credit) then begin
    inc(u.uploads);
    inc(u.uk,f.filesize div 1024);
  end else begin
    dec(u.uploads);
    dec(u.uk,f.filesize div 1024);
  end;
  if (systat^.fileptratio) then begin
    prompt(', '+cstrl(gotpts)+' file points');
    if (credit) then
      inc(u.filepoints,gotpts)
    else
      dec(u.filepoints,gotpts);
  end;
  print('.');
  saveurec(u,un);
end;

procedure validatefiles;
var i:integer;
    c:char;
    abort,next,isglobal,ispoints,isprompt:boolean;

  procedure valfiles(b:integer; var abort,next:boolean);
  var u:userrec;
      s:astr;
      s2:string;
      x:integer;
      lng:longint;
      oldboard,pl,rn:integer;
      shownalready:boolean;
  begin
    oldboard:=fileboard;
    if (fileboard<>b) then changefileboard(b);
    if (fileboard=b) then begin
      recno(align('*.*'),pl,rn);
      shownalready:=FALSE; abort:=FALSE; next:=FALSE;
      while (rn<>0) and (not abort) and (not hangup) do begin
        NXF.Seekfile(rn);
        NXF.Readheader;
        if (ffnotval in NXF.Fheader.fileflags) and
           (not (ffresumelater in NXF.Fheader.fileflags)) then begin
          if (not shownalready) then begin
            nl;
            sprint('Validating %140%'+memuboard.name+'%140% #'+
                   cstr(fileboard)); 
            nl;
            shownalready:=TRUE;
          end;

          lng:=NXF.Fheader.filesize;
          sprint('Filename   : %030%'+NXF.Fheader.filename);
          NXF.DescStartup;
          x:=1;
          s2:='';
          while ((s2<>#1+'EOF'+#1) and (x<11))do begin
          s2:=NXF.GetDescLine;
          if (x=1) then begin
                  sprint('Description: %030%'+s2);
          end else begin
                  sprint('           : %030%'+s2);
          end;
          inc(x);
          end;
          sprint('Size/points: %030%'+cstrl(lng)+' bytes / '+
                 cstr(NXF.Fheader.filepoints)+' pts');
          sprint('Uploaded By :%030% '+caps(NXF.Fheader.Uploadedby));
          nl;
          if (isprompt) then begin
            if (ispoints) then begin
              sprompt('%090%Points For File [%150%Enter %090%to Skip, %150%Q%090%uit] : %150%'); input(s,5);
              if (s='Q') then abort:=TRUE;
              if ((s<>'') and (s<>'Q')) then begin
                NXF.Fheader.filepoints:=value(s);
                NXF.Fheader.fileflags:=NXF.Fheader.fileflags-[ffnotval];
                NXF.Rewriteheader(NXF.Fheader);
                {if (not aacs1(u,f.owner,systat^.ulvalreq)) then
                  creditfile(u,f.owner,f,TRUE);
                sprompt('Points For %140%'+caps(f.stowner)+'%090% [%150%-999 %090%to %150%999] : %150%');
                input(s,5);
                if (s<>'') then
                  if (f.owner=usernum) then
                    inc(thisuser.filepoints,value(s))
                  else begin
                    inc(u.filepoints,value(s));
                    saveurec(u,f.owner);
                  end;}
              end;
              nl;
            end else begin
              repeat
                dyny:=false;
                ynq('%030%Validate? [%150%Y%030%es,%150%N%030%o,%150%V%030%iew,%150%Q%030%uit] : %150%');
                onekda:=false;
                onekcr:=false;
                onek(c,'QNVY');
                onekda:=true;
                onekcr:=true;
                case c of
                  'Q':begin
                        abort:=TRUE;
                        sprompt(^H' '^H^H' '^H);
                        sprint('%150%Quit');
                      end;
                  'V':begin
                        abort:=FALSE; next:=FALSE;
                        sprompt(^H' '^H^H' '^H);
                        sprint('%150%View');
                        lfi(sqoutsp(adrv(memuboard.dlpath)+NXF.Fheader.filename),abort,next);
                        abort:=FALSE; next:=FALSE;
                      end;
                  'Y':begin
                        NXF.Fheader.fileflags:=NXF.Fheader.fileflags-[ffnotval];
                        sprompt(^H' '^H^H' '^H);
                        sprint('%150%Yes');
                        NXF.Rewriteheader(NXF.Fheader);
                        {if (not aacs1(u,f.owner,systat^.ulvalreq)) then
                          creditfile(u,f.owner,f,TRUE);}
                      end;
                   'N':nl;
                end;
              until ((c<>'V') or (hangup));
              nl;
            end;
          end else begin
            NXF.Fheader.fileflags:=NXF.Fheader.fileflags-[ffnotval];
            NXF.Rewriteheader(NXF.Fheader);
            {if (not aacs1(u,f.owner,systat^.ulvalreq)) then
              creditfile(u,f.owner,f,TRUE);}
          end;
        end;

        nrecno(align('*.*'),pl,rn);
        wkey(abort,next);
      end;
    end;
    fileboard:=oldboard;
  end;

begin
  nl;
  onekda:=false;
  onekcr:=false;
  dyny:=true;
  ynq('%030%Prompt for validation [%150%Y%030%es,%150%N%030%o,%150%P%030%oints Validation,%150%Q%030%uit] : %150%');
  onek(c,'QNPY');
  if (c<>'Y') then sprompt(^H' '^H^H' '^H^H' '^H);
  case c of
        'Q':sprint('%150%Quit');
        'P':sprint('%150%Points');
        'N':sprint('%150%No');
  end;
  if (c='Q') then exit;

  ispoints:=(c='P');
  isprompt:=(c<>'N');
  isglobal:=pynq('%030%Search All Bases? %150%');
  nl;

  abort:=FALSE; next:=FALSE;
  if (isglobal) then begin
    i:=0;
    while (i<=maxulb) and (not abort) and (not hangup) do begin
      if (fbaseac(i)) then valfiles(i,abort,next);
      inc(i);
      wkey(abort,next);
      if (next) then abort:=FALSE;
    end;
  end else
    valfiles(fileboard,abort,next);
end;

end.

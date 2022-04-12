{$A+,B+,D-,E+,F+,I+,L+,N-,O+,R-,S+,V-}
unit ivHelp3;

interface

uses dos,crt,myio,common;

{$I Func.pas}

var helppath:string;

procedure showhelp(helpname:string; topic,x1,y1,x2,y2,fg1,b1,tp1:integer;shadow:boolean);

implementation

procedure showhelp(helpname:string; topic,x1,y1,x2,y2,fg1,b1,tp1:integer;shadow:boolean);
type htxt1=array[1..200] of helplinerec;
     htxt2=^htxt1;
     hjump1=array[1..30] of helpjumprec;
     hjump2=^hjump1;
var hidxf:file of helpidx;
    hidx:helpidx;
    hcon:helpcontrolrec;
    htxt:htxt2;
    hjump:hjump2;
    backtopics:array[1..200] of RECORD
        tpic:integer;
        cc,cl,tl:byte;
    END;
    numback:byte;
    cline,cchar:integer;
    starttopic:integer;
    maxlines,maxwidth,topline:integer;
    l:integer;
    c:char;
    f:file;
    x,numread,x15,y15,z15:integer;
    showinghelp,update,done:boolean;


        procedure updatescreen;
        var x8:integer;
            stop:boolean;
        begin
        x8:=1;
        cursoron(FALSE);
        textcolor(7);
        textbackground(0);
        while (x8<=maxlines) do begin
                gotoxy(2,x8+1);
                if (((topline-1)+x8)>hcon.numlines) then begin
                cwrite(mln('',76));
                end else
                cwrite(mln(htxt^[(topline-1)+x8].dline,76));
                inc(x8);
        end;
        cursoron(TRUE);
        end;


        function inhotspot(cc,cl:integer):integer;
        var x8,x9:integer;
        begin
        x9:=0;
        x8:=1;
        while (x8<=hcon.numjumps) and (x9=0) do begin
                        if ((cc>=hjump^[x8].x1) and (cc<=hjump^[x8].x2)) and
                        ((cl>=hjump^[x8].y1) and (cl<=hjump^[x8].y2))
                        then x9:=hjump^[x8].jumpto;
                        {writeln(hjump^[x8].x1,' ',hjump^[x8].y1,' ',
                                hjump^[x8].x2,' ',hjump^[x8].y2);}
                        inc(x8);
        end;
        inhotspot:=x9;
        end;

begin
        titlefore:=15;
        titleback:=4;
        setwindow2(w,x1,y1,x2,y2,fg1,b1,tp1,'','ivHELP',shadow);
        titlefore:=14;
        titleback:=1;
        numback:=0;
        for x:=1 to 200 do backtopics[x].tpic:=0;
        for x:=1 to 200 do backtopics[x].cc:=0;
        for x:=1 to 200 do backtopics[x].cl:=0;
        for x:=1 to 200 do backtopics[x].tl:=0;
        showinghelp:=FALSE;
        cchar:=2;
        cline:=2;
        topline:=1;
        repeat
        update:=FALSE;
        done:=FALSE;
        assign(hidxf,helppath+helpname+'.HDX');
        {$I-} reset(hidxf); {$I+}
        if (ioresult<>0) then begin
                displaybox('Error accessing '+helppath+helpname+'.HDX',3000);
                removewindow(w);
                exit;
        end;     
        if (topic>filesize(hidxf)-1) then begin
                displaybox('Invalid Help Topic.',3000);
                removewindow(w);
                exit;
        end;
        seek(hidxf,topic);
        read(hidxf,hidx);
        close(hidxf);
        new(htxt);
        new(hjump);
        assign(f,helppath+helpname+'.HLP');
        {$I-} reset(f,1); {$I+}
        if (ioresult<>0) then begin
                displaybox('Error accessing '+helppath+helpname+'.HLP',3000);
                removewindow(w);
                exit;
        end;
        if (hidx.controlblock*sizeof(helpcontrolrec)>filesize(f)-1) then begin
                displaybox('Invalid Help Topic.',3000);
                removewindow(w);
                exit;
        end;
        seek(f,hidx.controlblock*sizeof(helpcontrolrec));
        blockread(f,hcon,sizeof(hcon));
        maxlines:=(y2-y1)-3;
        for x:=1 to hcon.numlines do begin
        blockread(f,htxt^[x],sizeof(helplinerec));
        end;
        for x:=1 to hcon.numjumps do begin
        blockread(f,hjump^[x],sizeof(helpjumprec));
        end;
        close(f);
        titlefore:=15;
        titleback:=4;
        setwindow3(w,x1,y1,x2,y2,fg1,b1,tp1,hidx.topic,'ivHELP',shadow);
        titlefore:=14;
        titleback:=1;
        window(1,1,80,25);
        gotoxy(1,25);
        clreol;
        textcolor(14);
        textbackground(0);
        write('Esc');
        textcolor(7);
        if (showinghelp) then
        write('=Back ')
        else begin
        write('=Exit ');
        textcolor(14);
        write('F1');
        textcolor(7);
        write('=Help on ivHELP ');
        end;
        if (numback<>0) and not(showinghelp) then begin
        textcolor(14);
        write('Alt-F1');
        textcolor(7);
        write('=Previous Topic');
        end;
        window(x1+1,y1+1,x2-1,y2-1);
        updatescreen;
        gotoxy(cchar,cline);
        cursoron(TRUE);
        repeat
        while not(keypressed) do begin end;
        c:=readkey;
        case c of
                #9:begin        { tab }
                     y15:=topline+(cline-2);
                     z15:=0;
                     x15:=cchar-1;
                     while (y15<=hcon.numlines) and (z15=0) do begin
                        while (x15<=76) and (z15=0) do begin
                                l:=inhotspot(x15,y15);
                                if (l<>0) then begin
                                        if (x15=cchar-1) and (y15=topline+(cline-2))
                                        then begin
                                                while (l<>0) do begin
                                                inc(x15);
                                                l:=inhotspot(x15,y15);
                                                end;
                                        end else z15:=1;
                                end;
                                if (z15=0) then inc(x15);
                        end;
                        if (z15=0) then begin
                                x15:=1;
                                inc(y15);
                        end;
                     end;
                     if (z15<>0) then begin
                        cchar:=x15+1;
                        if (y15>topline+(maxlines-1)) then begin
                                cline:=2;
                                topline:=y15;
                                updatescreen;
                        end else begin
                        cline:=(y15-topline)+2;
                        end;
                        gotoxy(cchar,cline);
                     end;
                   end;
                #0:begin
                        c:=readkey;
                        case c of
                        #15:begin        { shift-tab}
                     y15:=topline+(cline-2);
                     z15:=0;
                     x15:=cchar-1;
                     while (y15>=1) and (z15=0) do begin
                        while (x15>=1) and (z15=0) do begin
                                l:=inhotspot(x15,y15);
                                if (l<>0) then begin
                                        if (x15=cchar-1) and (y15=topline+(cline-2))
                                        then begin
                                        while (l<>0) do begin
                                                dec(x15);
                                                l:=inhotspot(x15,y15);
                                        end;
                                        end else begin
                                        z15:=1;
                                        while (l<>0) do begin
                                                dec(x15);
                                                l:=inhotspot(x15,y15);
                                        end;
                                        inc(x15);
                                        end;
                                end;
                                if (z15=0) then dec(x15);
                        end;
                        if (z15=0) then begin
                                x15:=75;
                                dec(y15);
                        end;
                     end;
                     if (z15<>0) then begin
                        cchar:=x15+1;
                        if (y15<topline) then begin
                                cline:=2;
                                topline:=y15;
                                updatescreen;
                        end else begin
                        cline:=(y15-topline)+2;
                        end;
                        gotoxy(cchar,cline);
                     end;
                           end;
                        chr(alt_F1):begin
                                if (numback<>0) then begin
                                        topic:=backtopics[numback].tpic;
                                        cchar:=backtopics[numback].cc;
                                        cline:=backtopics[numback].cl;
                                        topline:=backtopics[numback].tl;
                                        dec(numback);
                                        update:=TRUE;
                                end;
                              end;
                       chr(f1):begin
                                inc(numback);
                                backtopics[numback].tpic:=topic;
                                backtopics[numback].cc:=cchar;
                                backtopics[numback].cl:=cline;
                                backtopics[numback].tl:=topline;
                                starttopic:=topic;
                                topic:=1;
                                cchar:=2;
                                cline:=2;
                                topline:=1;
                                update:=TRUE;
                                showinghelp:=TRUE;
                              end;
                #71:begin
                        cchar:=2;
                        gotoxy(cchar,cline);
                    end;
                #72:begin
                        dec(cline);
                        if (cline<2) then begin
                                cline:=2;
                                dec(topline);
                                if (topline<1) then topline:=1;
                                updatescreen;
                        end;
                        gotoxy(cchar,cline);
                    end;
                #73:begin
                        if ((cline+topline)-(maxlines+2)<1) then begin
                                        cline:=2; 
                                        topline:=1;
                        end else begin
                                        if (topline-(maxlines+2)<1) then topline:=1
                                        else dec(topline,maxlines);
                        end;
                        updatescreen;
                        gotoxy(cchar,cline);
                    end;
                #81:begin
                                if (topline+maxlines+1>hcon.numlines) then begin
                                        cline:=maxlines+1; 
                                end else inc(topline,maxlines);
                                updatescreen;
                                gotoxy(cchar,cline);
                    end;
               #119:begin
                        cline:=2;
                        topline:=1;
                        updatescreen;
                        gotoxy(cchar,cline);
                    end;
               #117:begin
                        cline:=(maxlines+1);
                        topline:=hcon.numlines-(maxlines-1);
                        if (topline<1) then topline:=1;
                        updatescreen;
                        gotoxy(cchar,cline);
                    end;
                #75:begin
                        dec(cchar);
                        if (cchar<2) then cchar:=2;
                        gotoxy(cchar,cline);
                    end;
                #77:begin
                        inc(cchar);
                        if (cchar>76) then cchar:=76;
                        gotoxy(cchar,cline);
                    end;
                #79:begin
                        cchar:=76;
                        gotoxy(cchar,cline);
                    end;
                #80:begin
                        inc(cline);
                        if (cline>(maxlines+1)) then begin
                                if ((cline+topline)-2<=hcon.numlines) then begin
                                cline:=(maxlines+1);
                                inc(topline);
                                updatescreen;
                                end else dec(cline);
                        end;
                        gotoxy(cchar,cline);
                    end;
                    end;
                  end;
                #13:begin
                        l:=inhotspot(cchar-1,topline+(cline-2));
                        if (l<>0) then begin
                                inc(numback);
                                backtopics[numback].tpic:=topic;
                                backtopics[numback].cc:=cchar;
                                backtopics[numback].cl:=cline;
                                backtopics[numback].tl:=topline;
                                topic:=l;
                                cchar:=2;
                                topline:=1;
                                cline:=2;
                                update:=TRUE;
                        end;
                    end;
                #27:begin
                    if (showinghelp) then begin
                        topic:=backtopics[numback].tpic;
                        cchar:=backtopics[numback].cc;
                        cline:=backtopics[numback].cl;
                        topline:=backtopics[numback].tl;
                        dec(numback);
                        update:=TRUE;
                        if (topic=starttopic) then showinghelp:=FALSE;
                    end else begin
                        done:=TRUE;
                        update:=TRUE;
                    end;
                    end;
        end;
        until (update);
        dispose(htxt);
        dispose(hjump);
        until (done);
        removewindow(w);
end;

end.

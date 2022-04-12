{$A+ Word Align Data}
{$B+ Complete Boolean Eval}
{$D+ Debug Information}
{$E+ Numeric Processing Emulation}
{$F+ Force Far Calls}
{$G+ Generate 286 Instructions}
{$I+ Input/Output Checking}
{$L+ Local Symbol Information}
{$N+ Numeric Coprocessor}
{$O+ Overlay Code Generation}
{$P+ Open String Parameters}
{$Q+ Numerical Overflow Checking}
{$R+ Range Checking}
{$S+ Stack-Overflow Checking}
{$T+ Type-Checked Pointers}
{$V+ Var-String Checking}
{$X+ Extended Syntax}
{$Y+ Symbol Reference Imformation}
unit extract;

interface

uses
  dos,crt,myio;

const sdir:string='';

procedure extractfiles(x1,y1,x2,y2,c1,c2,c3:integer;desc:string;shadow:boolean;dfile,epath,dspec:string);

implementation

 {$F+}
 procedure NewInt29h(Flags, CS, IP, AX, BX, CX, DX, SI, DI, DS, ES, BP: Word);
  interrupt;

  begin
   asm
     cli
   end;
   write(char(lo(AX)));
   asm
     sti
   end;
  end;
 {$F-}

procedure extractfiles(x1,y1,x2,y2,c1,c2,c3:integer;desc:string;shadow:boolean;dfile,epath,dspec:string);
var
  OldInt29h : procedure;
  ox,oy: byte;
  rcode:integer;
  w:windowrec;
  c:char;

begin
  if (dspec<>'') then dspec:=' '+dspec;
  ox:=wherex;
  oy:=wherey;
  {Save the old Int29 handler adress so we can restore it}
  getintvec($29, @OldInt29h);
  {Set our own Int29 handler}
  setintvec($29, @NewInt29h);
  {Create a fancy window with border}
  setwindow(w,x1,y1,x2,y2,c1,c2,c3,desc,shadow);
  textcolor(White);
  textbackground(Black);
  { Now that the border is drawn, just reduce the window by 1 caracters on
    each side so our writes don't mess the border }
  window(x1+1,y1+1,x2-1,y2-1);
  clrscr;
  swapvectors;
  exec(sdir+'EXTRACT.EXE','-o -C '+dfile+dspec+' -d '+epath);
  swapvectors;
  setintvec($29, @OldInt29h);    {Restore old Int 29h}
  removewindow(w);
  window(1,1,80,25);
  gotoxy(ox,oy);
end;

end.

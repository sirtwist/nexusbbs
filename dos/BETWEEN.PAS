unit between;

interface

uses dos,crt;


type string8 = string[8];

function check_date(stream1,stream2:string8):integer;

implementation

function check_date(stream1,stream2:string8):integer;
var
  internal1,internal2:longint;
  JNUM:real;
  cd,month,day,year: integer;
  out:string[25];

    function Jul( mo, da, yr: integer): real;
    var
      i, j, k, j2, ju: real;
    begin
         i := yr;     j := mo;     k := da;
         j2 := int( (j - 14)/12 );
         ju := k - 32075 + int(1461 * ( i + 4800 + j2 ) / 4 );
         ju := ju + int( 367 * (j - 2 - j2 * 12) / 12);
         ju := ju - int(3 * int( (i + 4900 + j2) / 100) / 4);
         Jul := ju;
    end;

begin
  out:=copy(stream1,1,2);
  if copy(out,1,1)='0' then delete(out,1,1);
  val(out,month,cd);
  out:=copy(stream1,4,2);
  if copy(out,1,1)='0' then delete(out,1,1);
  val(out,day,cd);
  out:=copy(stream1,7,2);
  if copy(out,1,1)='0' then delete(out,1,1);
  val(out,year,cd);
  jnum:=jul(month,day,year);
  str(jnum:10:0,out);
  val(out,internal1,cd);
  out:=copy(stream2,1,2);
  if copy(out,1,1)='0' then delete(out,1,1);
  val(out,month,cd);
  out:=copy(stream2,4,2);
  if copy(out,1,1)='0' then delete(out,1,1);
  val(out,day,cd);
  out:=copy(stream2,7,2);
  if copy(out,1,1)='0' then delete(out,1,1);
  val(out,year,cd);
  jnum:=jul(month,day,year);
  str(jnum:10:0,out);
  val(out,internal2,cd);
  check_date:=internal1-internal2;
end;

end.

pragma Ada_2022;

with Ada.Text_IO; use Ada.Text_IO;
with Number_Grid; use Number_Grid;

procedure Tests is
   Pass, Fail : Natural := 0;
   procedure Check (Cond : Boolean; Name : String) is
   begin
      if Cond then
         Pass := Pass + 1;
      else
         Fail := Fail + 1;
         Put_Line ("FAIL: " & Name);
      end if;
   end Check;

   G_Ok : constant Grid (1 .. 2, 1 .. 2) :=
     [1 => [1 => 1, 2 => 2],
      2 => [1 => 3, 2 => 4]];
   Rows : constant Sum_Vector (1 .. 2) := [3, 7];
   Cols : constant Sum_Vector (1 .. 2) := [4, 6];
   Bad_Rows : constant Sum_Vector (1 .. 2) := [3, 8];
begin
   Check (In_Bounds (G_Ok), "bounds");
   Check (Row_Sums_Ok (G_Ok, Rows), "rows ok");
   Check (Col_Sums_Ok (G_Ok, Cols), "cols ok");
   Check (Solution_Ok (G_Ok, Rows, Cols), "solution ok");
   Check (not Solution_Ok (G_Ok, Bad_Rows, Cols), "bad rows");
   Put_Line ("PASS=" & Pass'Image & " FAIL=" & Fail'Image);
   if Fail /= 0 then
      raise Program_Error;
   end if;
end Tests;

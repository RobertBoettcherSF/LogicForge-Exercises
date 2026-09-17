pragma Ada_2022;

with Ada.Text_IO; use Ada.Text_IO;
with Path_Plan; use Path_Plan;

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

   M : constant Map (1 .. 3, 1 .. 3) :=
     [1 => [Open, Open, Wall],
      2 => [Open, Wall, Open],
      3 => [Open, Open, Open]];
   Ok : constant Path :=
     [(R => 1, C => 1), (R => 2, C => 1), (R => 3, C => 1), (R => 3, C => 2)];
   Through_Wall : constant Path :=
     [(R => 1, C => 1), (R => 1, C => 2), (R => 1, C => 3)];
   Jump : constant Path :=
     [(R => 1, C => 1), (R => 3, C => 1)];
begin
   Check (Is_Valid_Path (M, Ok), "ok path");
   Check (not Is_Valid_Path (M, Through_Wall), "wall");
   Check (not Is_Valid_Path (M, Jump), "non-adjacent");
   Put_Line ("PASS=" & Pass'Image & " FAIL=" & Fail'Image);
   if Fail /= 0 then
      raise Program_Error;
   end if;
end Tests;

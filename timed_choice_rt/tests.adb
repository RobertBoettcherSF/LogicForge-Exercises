pragma Ada_2022;

with Ada.Text_IO; use Ada.Text_IO;
with Timed_Choice_RT; use Timed_Choice_RT;

procedure Tests is
   Pass, Fail : Natural := 0;
   procedure Check (Cond : Boolean; Name : String) is
   begin
      if Cond then Pass := Pass + 1;
      else Fail := Fail + 1; Put_Line ("FAIL: " & Name); end if;
   end Check;
begin
   Check (Trial_Score ((1, 1, 800)) = 2, "fast correct");
   Check (Trial_Score ((1, 1, 2000)) = 1, "slow correct");
   Check (Trial_Score ((1, 2, 100)) = 0, "wrong");
   Check (Is_Correct ((2, 2, 9999)), "is correct");
   Put_Line ("PASS=" & Pass'Image & " FAIL=" & Fail'Image);
   if Fail /= 0 then raise Program_Error; end if;
end Tests;

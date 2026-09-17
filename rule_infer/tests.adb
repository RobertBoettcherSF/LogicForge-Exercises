pragma Ada_2022;

with Ada.Text_IO; use Ada.Text_IO;
with Rule_Infer; use Rule_Infer;

procedure Tests is
   Pass, Fail : Natural := 0;
   procedure Check (Cond : Boolean; Name : String) is
   begin
      if Cond then Pass := Pass + 1;
      else Fail := Fail + 1; Put_Line ("FAIL: " & Name); end if;
   end Check;
   R_Even : constant Rule := (Even, 0);
   R_Ge5  : constant Rule := (At_Least, 5);
   R_Mod3 : constant Rule := (Multiple_Of, 3);
begin
   Check (Obeys (R_Even, 4), "even");
   Check (not Obeys (R_Even, 5), "not even");
   Check (Obeys (R_Ge5, 5), "ge5");
   Check (not Obeys (R_Ge5, 4), "lt5");
   Check (Obeys (R_Mod3, 9), "mod3");
   Check (Trial_Score (R_Even, 2, True) = 1, "score hit");
   Check (Trial_Score (R_Even, 2, False) = 0, "score miss");
   Put_Line ("PASS=" & Pass'Image & " FAIL=" & Fail'Image);
   if Fail /= 0 then raise Program_Error; end if;
end Tests;

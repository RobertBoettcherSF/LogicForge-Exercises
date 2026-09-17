pragma Ada_2022;

with Ada.Text_IO; use Ada.Text_IO;
with Recall_Span; use Recall_Span;

procedure Tests is
   Pass, Fail : Natural := 0;
   procedure Check (Cond : Boolean; Name : String) is
   begin
      if Cond then Pass := Pass + 1;
      else Fail := Fail + 1; Put_Line ("FAIL: " & Name); end if;
   end Check;
   P : constant Sequence := [1, 2, 3, 4];
   R1 : constant Sequence := [1, 2, 3, 4];
   R2 : constant Sequence := [1, 2, 9];
   R3 : constant Sequence := [9, 2, 3, 4];
begin
   Check (Exact_Match (P, R1), "exact");
   Check (not Exact_Match (P, R2), "len/content");
   Check (Prefix_Span (P, R2) = 2, "prefix 2");
   Check (Prefix_Span (P, R3) = 0, "prefix 0");
   Check (Prefix_Span (P, R1) = 4, "prefix full");
   Put_Line ("PASS=" & Pass'Image & " FAIL=" & Fail'Image);
   if Fail /= 0 then raise Program_Error; end if;
end Tests;

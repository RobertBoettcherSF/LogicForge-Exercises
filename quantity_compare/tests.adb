pragma Ada_2022;
with Ada.Text_IO; use Ada.Text_IO;
with Quantity_Compare; use Quantity_Compare;
procedure Tests is
   Pass_Count, Fail_Count : Natural := 0;
   procedure Check (Label : String; OK : Boolean) is
   begin
      if OK then Put_Line ("  PASS — " & Label); Pass_Count := Pass_Count + 1;
      else Put_Line ("  FAIL — " & Label); Fail_Count := Fail_Count + 1; end if;
   end Check;
begin

   Put_Line ("TEST 1 — Decide");
   Check ("1.1 left", Decide (5, 3) = Left);
   Check ("1.2 right", Decide (2, 9) = Right);
   Check ("1.3 equal", Decide (4, 4) = Equal);
   Put_Line ("TEST 2 — Trial_Score");
   Check ("2.1 hit", Trial_Score (Left, Left) = 1);
   Check ("2.2 miss", Trial_Score (Left, Right) = 0);
   Check ("2.3 equal", Trial_Score (Equal, Equal) = 1);
   Put_Line ("TEST 3 — Config_Ok");
   Check ("3.1 valid", Config_Ok ((10, 1)));
   Check ("3.2 bad", not Config_Ok ((Max_Trials + 1, 1)));
   Check ("3.3 seed0", Config_Ok ((4, 0)));
   Put_Line ("TEST 4 — Build");
   declare
      T : Trial_List; C : Natural;
   begin
      Build_Session ((10, 5), T, C);
      Check ("4.1 count", C = 10);
      Check ("4.2 answer", T (1).Answer = Decide (T (1).Left, T (1).Right));
      Check ("4.3 ok", Config_Ok ((10, 5)));
   end;
   Put_Line ("TEST 5 — Perfect");
   declare
      T : Trial_List; C : Natural; A : Answer_List; R : Session_Result;
   begin
      Build_Session ((10, 5), T, C);
      for I in 1 .. C loop A (I) := T (I).Answer; end loop;
      R := Score_Session ((10, 5), T, C, A);
      Check ("5.1 full", R.Score = R.Max_Score);
      Check ("5.2 max", R.Max_Score = 10);
      Check ("5.3 run", R.Trials_Run = 10);
   end;
   Put_Line ("TEST 6 — Wrong");
   declare
      T : Trial_List; C : Natural; A : Answer_List; R : Session_Result;
   begin
      Build_Session ((10, 5), T, C);
      for I in 1 .. C loop
         if T (I).Answer = Left then A (I) := Right;
         else A (I) := Left; end if;
      end loop;
      R := Score_Session ((10, 5), T, C, A);
      Check ("6.1 zero", R.Score = 0);
      Check ("6.2 max", R.Max_Score = 10);
      Check ("6.3 bound", R.Score <= R.Max_Score);
   end;
   Put_Line ("TEST 7 — Determinism");
   declare
      A, B : Trial_List; CA, CB : Natural;
   begin
      Build_Session ((8, 9), A, CA);
      Build_Session ((8, 9), B, CB);
      Check ("7.1 count", CA = CB);
      Check ("7.2 left", A (1).Left = B (1).Left);
      Check ("7.3 answer", A (1).Answer = B (1).Answer);
   end;
   Put_Line ("TEST 8 — Seed 0");
   declare
      T : Trial_List; C : Natural;
   begin
      Build_Session ((5, 0), T, C);
      Check ("8.1 count", C = 5);
      Check ("8.2 ok", Config_Ok ((5, 0)));
      Check ("8.3 decide", T (1).Answer = Decide (T (1).Left, T (1).Right));
   end;
   Put_Line ("TEST 9 — Invalid");
   declare
      Bad : constant Session_Config := (Max_Trials + 1, 1);
      T : Trial_List; C : Natural; Raised : Boolean := False;
   begin
      begin Build_Session (Bad, T, C);
      exception when Invalid_Argument => Raised := True; when others => Raised := False; end;
      Check ("9.1 raises", Raised);
      Check ("9.2 cfg", not Config_Ok (Bad));
      Check ("9.3 key", Instruction_Key'Length > 5);
   end;
   Put_Line ("TEST 10 — Keys");
   Check ("10.1 instruction", Instruction_Key'Length >= 10);
   Check ("10.2 prompt", Prompt_Key'Length >= 10);
   Check ("10.3 prefix", Instruction_Key (1 .. 16) = "quantity_compare");
   Put_Line ("TEST 11 — Partial");
   declare
      T : Trial_List; C : Natural; A : Answer_List; R : Session_Result;
   begin
      Build_Session ((10, 5), T, C);
      for I in 1 .. C loop
         if I mod 2 = 0 then A (I) := T (I).Answer; else A (I) := Equal; end if;
      end loop;
      R := Score_Session ((10, 5), T, C, A);
      Check ("11.1 mid", R.Score <= C);
      Check ("11.2 max", R.Max_Score = C);
      Check ("11.3 run", R.Trials_Run = C);
   end;
   Put_Line ("TEST 12 — Equals appear");
   declare
      T : Trial_List; C : Natural;
   begin
      Build_Session ((32, 1), T, C);
      Check ("12.1 built", C = 32);
      Check ("12.2 count", C = 32);
      Check ("12.3 decide", T (1).Answer = Decide (T (1).Left, T (1).Right));
   end;
   Put_Line ("TEST 13 — Full");
   declare
      T : Trial_List; C : Natural; A : Answer_List; R : Session_Result;
   begin
      Build_Session ((10, 5), T, C);
      for I in 1 .. C loop A (I) := T (I).Answer; end loop;
      R := Score_Session ((10, 5), T, C, A);
      Check ("13.1 full", R.Score = 10);
      Check ("13.2 eq", R.Score = R.Max_Score);
      Check ("13.3 run", R.Trials_Run = 10);
   end;

   New_Line;
   Put_Line ("=== " & Pass_Count'Image & " passed, " & Fail_Count'Image & " failed ===");
   pragma Assert (Fail_Count = 0);
end Tests;

pragma Ada_2022;
with Ada.Text_IO; use Ada.Text_IO;
with Multiply_Drill; use Multiply_Drill;
procedure Tests is
   Pass_Count, Fail_Count : Natural := 0;
   procedure Check (Label : String; OK : Boolean) is
   begin
      if OK then Put_Line ("  PASS — " & Label); Pass_Count := Pass_Count + 1;
      else Put_Line ("  FAIL — " & Label); Fail_Count := Fail_Count + 1; end if;
   end Check;
begin

   Put_Line ("TEST 1 — Trial_Score");
   Check ("1.1 hit", Trial_Score (12, 12) = 1);
   Check ("1.2 miss", Trial_Score (12, 11) = 0);
   Check ("1.3 zero", Trial_Score (0, 0) = 1);
   Put_Line ("TEST 2 — Config_Ok");
   Check ("2.1 valid", Config_Ok ((10, 12, 1)));
   Check ("2.2 bad trials", not Config_Ok ((Max_Trials + 1, 12, 1)));
   Check ("2.3 bad factor", not Config_Ok ((8, 21, 1)));
   Put_Line ("TEST 3 — Build");
   declare
      T : Trial_List; C : Natural;
   begin
      Build_Session ((10, 12, 5), T, C);
      Check ("3.1 count", C = 10);
      Check ("3.2 product", T (1).Product = T (1).A * T (1).B);
      Check ("3.3 factors", T (1).A <= 12 and then T (1).B <= 12);
   end;
   Put_Line ("TEST 4 — Perfect");
   declare
      T : Trial_List; C : Natural; A : Answer_List; R : Session_Result;
   begin
      Build_Session ((10, 12, 5), T, C);
      for I in 1 .. C loop A (I) := T (I).Product; end loop;
      R := Score_Session ((10, 12, 5), T, C, A);
      Check ("4.1 full", R.Score = R.Max_Score);
      Check ("4.2 max", R.Max_Score = 10);
      Check ("4.3 run", R.Trials_Run = 10);
   end;
   Put_Line ("TEST 5 — Wrong");
   declare
      T : Trial_List; C : Natural; A : Answer_List; R : Session_Result;
   begin
      Build_Session ((10, 12, 5), T, C);
      for I in 1 .. C loop A (I) := T (I).Product + 1; end loop;
      R := Score_Session ((10, 12, 5), T, C, A);
      Check ("5.1 zero", R.Score = 0);
      Check ("5.2 max", R.Max_Score = 10);
      Check ("5.3 bound", R.Score <= R.Max_Score);
   end;
   Put_Line ("TEST 6 — Determinism");
   declare
      A, B : Trial_List; CA, CB : Natural;
   begin
      Build_Session ((8, 10, 9), A, CA);
      Build_Session ((8, 10, 9), B, CB);
      Check ("6.1 count", CA = CB);
      Check ("6.2 a", A (1).A = B (1).A);
      Check ("6.3 product", A (1).Product = B (1).Product);
   end;
   Put_Line ("TEST 7 — Seed 0");
   declare
      T : Trial_List; C : Natural;
   begin
      Build_Session ((5, 9, 0), T, C);
      Check ("7.1 count", C = 5);
      Check ("7.2 ok", Config_Ok ((5, 9, 0)));
      Check ("7.3 product", T (1).Product = T (1).A * T (1).B);
   end;
   Put_Line ("TEST 8 — Invalid");
   declare
      Bad : constant Session_Config := (Max_Trials + 1, 12, 1);
      T : Trial_List; C : Natural; Raised : Boolean := False;
   begin
      begin Build_Session (Bad, T, C);
      exception when Invalid_Argument => Raised := True; when others => Raised := False; end;
      Check ("8.1 raises", Raised);
      Check ("8.2 cfg", not Config_Ok (Bad));
      Check ("8.3 key", Instruction_Key'Length > 5);
   end;
   Put_Line ("TEST 9 — Keys");
   Check ("9.1 instruction", Instruction_Key'Length >= 10);
   Check ("9.2 prompt", Prompt_Key'Length >= 10);
   Check ("9.3 prefix", Instruction_Key (1 .. 14) = "multiply_drill");
   Put_Line ("TEST 10 — Partial");
   declare
      T : Trial_List; C : Natural; A : Answer_List; R : Session_Result;
   begin
      Build_Session ((10, 12, 5), T, C);
      for I in 1 .. C loop
         if I mod 2 = 0 then A (I) := T (I).Product; else A (I) := 0; end if;
      end loop;
      R := Score_Session ((10, 12, 5), T, C, A);
      Check ("10.1 mid", R.Score <= C);
      Check ("10.2 max", R.Max_Score = C);
      Check ("10.3 run", R.Trials_Run = C);
   end;
   Put_Line ("TEST 11 — Ones");
   declare
      Soft : constant Session_Config := (6, 1, 2);
      T : Trial_List; C : Natural; Ok : Boolean := True;
   begin
      Build_Session (Soft, T, C);
      for I in 1 .. C loop
         if T (I).A /= 1 or else T (I).B /= 1 then Ok := False; end if;
      end loop;
      Check ("11.1 ones", Ok);
      Check ("11.2 product1", T (1).Product = 1);
      Check ("11.3 count", C = 6);
   end;
   Put_Line ("TEST 12 — Another seed");
   declare
      T : Trial_List; C : Natural;
   begin
      Build_Session ((4, 7, 11), T, C);
      Check ("12.1 count", C = 4);
      Check ("12.2 a bound", T (2).A <= 7);
      Check ("12.3 b bound", T (2).B <= 7);
   end;
   Put_Line ("TEST 13 — Full again");
   declare
      T : Trial_List; C : Natural; A : Answer_List; R : Session_Result;
   begin
      Build_Session ((10, 12, 5), T, C);
      for I in 1 .. C loop A (I) := T (I).Product; end loop;
      R := Score_Session ((10, 12, 5), T, C, A);
      Check ("13.1 full", R.Score = 10);
      Check ("13.2 eq", R.Score = R.Max_Score);
      Check ("13.3 run", R.Trials_Run = 10);
   end;

   New_Line;
   Put_Line ("=== " & Pass_Count'Image & " passed, " & Fail_Count'Image & " failed ===");
   pragma Assert (Fail_Count = 0);
end Tests;

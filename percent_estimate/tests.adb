pragma Ada_2022;
with Ada.Text_IO; use Ada.Text_IO;
with Percent_Estimate; use Percent_Estimate;

procedure Tests is
   Pass_Count, Fail_Count : Natural := 0;
   procedure Check (Label : String; OK : Boolean) is
   begin
      if OK then
         Put_Line ("  PASS — " & Label);
         Pass_Count := Pass_Count + 1;
      else
         Put_Line ("  FAIL — " & Label);
         Fail_Count := Fail_Count + 1;
      end if;
   end Check;
begin

   Put_Line ("TEST 1 — Exact_Percent");
   Check ("1.1 half", Exact_Percent (50, 100) = 50);
   Check ("1.2 quarter", Exact_Percent (1, 4) = 25);
   Check ("1.3 zero", Exact_Percent (0, 10) = 0);

   Put_Line ("TEST 2 — Trial_Score");
   Check ("2.1 exact", Trial_Score (50, 50, 5) = 1);
   Check ("2.2 within", Trial_Score (50, 53, 5) = 1);
   Check ("2.3 outside", Trial_Score (50, 60, 5) = 0);

   Put_Line ("TEST 3 — Config_Ok");
   Check ("3.1 valid", Config_Ok ((8, 5, 1)));
   Check ("3.2 bad trials", not Config_Ok ((Max_Trials + 1, 5, 1)));
   Check ("3.3 bad tol", not Config_Ok ((8, 51, 1)));

   Put_Line ("TEST 4 — Build");
   declare
      T : Trial_List; C : Natural;
   begin
      Build_Session ((8, 5, 3), T, C);
      Check ("4.1 count", C = 8);
      Check ("4.2 exact", T (1).Exact = Exact_Percent (T (1).Part, T (1).Whole));
      Check ("4.3 whole", T (1).Whole >= 11);
   end;

   Put_Line ("TEST 5 — Perfect");
   declare
      T : Trial_List; C : Natural; A : Answer_List; R : Session_Result;
   begin
      Build_Session ((8, 5, 3), T, C);
      for I in 1 .. C loop A (I) := T (I).Exact; end loop;
      R := Score_Session ((8, 5, 3), T, C, A);
      Check ("5.1 full", R.Score = R.Max_Score);
      Check ("5.2 max", R.Max_Score = 8);
      Check ("5.3 run", R.Trials_Run = 8);
   end;

   Put_Line ("TEST 6 — Far wrong");
   declare
      T : Trial_List; C : Natural; A : Answer_List; R : Session_Result;
   begin
      Build_Session ((8, 5, 3), T, C);
      for I in 1 .. C loop A (I) := 999; end loop;
      R := Score_Session ((8, 5, 3), T, C, A);
      Check ("6.1 zero", R.Score = 0);
      Check ("6.2 max", R.Max_Score = 8);
      Check ("6.3 bound", R.Score <= R.Max_Score);
   end;

   Put_Line ("TEST 7 — Determinism");
   declare
      A, B : Trial_List; CA, CB : Natural;
   begin
      Build_Session ((6, 5, 9), A, CA);
      Build_Session ((6, 5, 9), B, CB);
      Check ("7.1 count", CA = CB);
      Check ("7.2 part", A (1).Part = B (1).Part);
      Check ("7.3 exact", A (1).Exact = B (1).Exact);
   end;

   Put_Line ("TEST 8 — Tolerance band");
   Check ("8.1 edge", Trial_Score (40, 45, 5) = 1);
   Check ("8.2 just out", Trial_Score (40, 46, 5) = 0);
   Check ("8.3 below", Trial_Score (40, 35, 5) = 1);

   Put_Line ("TEST 9 — Invalid");
   declare
      Bad : constant Session_Config := (Max_Trials + 1, 5, 1);
      T : Trial_List; C : Natural; Raised : Boolean := False;
   begin
      begin
         Build_Session (Bad, T, C);
      exception
         when Invalid_Argument => Raised := True;
         when others => Raised := False;
      end;
      Check ("9.1 raises", Raised);
      Check ("9.2 cfg", not Config_Ok (Bad));
      Check ("9.3 key", Instruction_Key'Length > 5);
   end;

   Put_Line ("TEST 10 — Keys");
   Check ("10.1 instruction", Instruction_Key'Length >= 10);
   Check ("10.2 prompt", Prompt_Key'Length >= 10);
   Check ("10.3 prefix", Instruction_Key (1 .. 16) = "percent_estimate");

   Put_Line ("TEST 11 — Seed 0");
   declare
      T : Trial_List; C : Natural;
   begin
      Build_Session ((5, 5, 0), T, C);
      Check ("11.1 count", C = 5);
      Check ("11.2 ok", Config_Ok ((5, 5, 0)));
      Check ("11.3 exact", T (1).Exact = Exact_Percent (T (1).Part, T (1).Whole));
   end;

   Put_Line ("TEST 12 — Partial");
   declare
      T : Trial_List; C : Natural; A : Answer_List; R : Session_Result;
   begin
      Build_Session ((8, 5, 3), T, C);
      for I in 1 .. C loop
         if I mod 2 = 0 then A (I) := T (I).Exact; else A (I) := 0; end if;
      end loop;
      R := Score_Session ((8, 5, 3), T, C, A);
      Check ("12.1 mid", R.Score <= C);
      Check ("12.2 max", R.Max_Score = C);
      Check ("12.3 run", R.Trials_Run = C);
   end;

   Put_Line ("TEST 13 — Rounding");
   Check ("13.1 1/3", Exact_Percent (1, 3) in 33 .. 34);
   Check ("13.2 2/3", Exact_Percent (2, 3) in 66 .. 67);
   Check ("13.3 3/3", Exact_Percent (3, 3) = 100);

   New_Line;
   Put_Line ("=== " & Pass_Count'Image & " passed, "
             & Fail_Count'Image & " failed ===");
   pragma Assert (Fail_Count = 0);
end Tests;

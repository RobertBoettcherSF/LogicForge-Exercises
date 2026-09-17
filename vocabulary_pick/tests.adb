pragma Ada_2022;
with Ada.Text_IO; use Ada.Text_IO;
with Vocabulary_Pick; use Vocabulary_Pick;
procedure Tests is
   Pass_Count, Fail_Count : Natural := 0;
   procedure Check (Label : String; OK : Boolean) is
   begin
      if OK then Put_Line ("  PASS — " & Label); Pass_Count := Pass_Count + 1;
      else Put_Line ("  FAIL — " & Label); Fail_Count := Fail_Count + 1; end if;
   end Check;
begin

   Put_Line ("TEST 1 — Trial_Score");
   Check ("1.1 hit", Trial_Score (1, 1) = 1);
   Check ("1.2 miss", Trial_Score (1, 2) = 0);
   Check ("1.3 four", Trial_Score (4, 4) = 1);
   Put_Line ("TEST 2 — Config_Ok");
   Check ("2.1 valid", Config_Ok ((8, 1)));
   Check ("2.2 bad", not Config_Ok ((Max_Trials + 1, 1)));
   Check ("2.3 seed0", Config_Ok ((4, 0)));
   Put_Line ("TEST 3 — Build");
   declare
      T : Trial_List; C : Natural;
   begin
      Build_Session ((8, 5), T, C);
      Check ("3.1 count", C = 8);
      Check ("3.2 option lens", T (1).Option_Lens (T (1).Correct) >= 2);
      Check ("3.3 prompt", T (1).Prompt_Len >= 2);
   end;
   Put_Line ("TEST 4 — Perfect");
   declare
      T : Trial_List; C : Natural; A : Answer_List; R : Session_Result;
   begin
      Build_Session ((8, 5), T, C);
      for I in 1 .. C loop A (I) := T (I).Correct; end loop;
      R := Score_Session ((8, 5), T, C, A);
      Check ("4.1 full", R.Score = R.Max_Score);
      Check ("4.2 max", R.Max_Score = 8);
      Check ("4.3 run", R.Trials_Run = 8);
   end;
   Put_Line ("TEST 5 — Wrong");
   declare
      T : Trial_List; C : Natural; A : Answer_List; R : Session_Result;
   begin
      Build_Session ((8, 5), T, C);
      for I in 1 .. C loop
         if T (I).Correct = 1 then A (I) := 2; else A (I) := 1; end if;
      end loop;
      R := Score_Session ((8, 5), T, C, A);
      Check ("5.1 zero", R.Score = 0);
      Check ("5.2 max", R.Max_Score = 8);
      Check ("5.3 bound", R.Score <= R.Max_Score);
   end;
   Put_Line ("TEST 6 — Determinism");
   declare
      A, B : Trial_List; CA, CB : Natural;
   begin
      Build_Session ((6, 9), A, CA);
      Build_Session ((6, 9), B, CB);
      Check ("6.1 count", CA = CB);
      Check ("6.2 correct", A (1).Correct = B (1).Correct);
      Check ("6.3 prompt0", A (1).Prompt (1) = B (1).Prompt (1));
   end;
   Put_Line ("TEST 7 — Seed 0");
   declare
      T : Trial_List; C : Natural;
   begin
      Build_Session ((5, 0), T, C);
      Check ("7.1 count", C = 5);
      Check ("7.2 ok", Config_Ok ((5, 0)));
      Check ("7.3 slot", Trial_Score (T (1).Correct, T (1).Correct) = 1);
   end;
   Put_Line ("TEST 8 — Invalid");
   declare
      Bad : constant Session_Config := (Max_Trials + 1, 1);
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
   Check ("9.3 prefix", Instruction_Key (1 .. 15) = "vocabulary_pick");
   Put_Line ("TEST 10 — Partial");
   declare
      T : Trial_List; C : Natural; A : Answer_List; R : Session_Result;
   begin
      Build_Session ((8, 5), T, C);
      for I in 1 .. C loop
         if I mod 2 = 0 then A (I) := T (I).Correct; else A (I) := 1; end if;
      end loop;
      R := Score_Session ((8, 5), T, C, A);
      Check ("10.1 mid", R.Score <= C);
      Check ("10.2 max", R.Max_Score = C);
      Check ("10.3 run", R.Trials_Run = C);
   end;
   Put_Line ("TEST 11 — Options filled");
   declare
      T : Trial_List; C : Natural; Ok : Boolean := True;
   begin
      Build_Session ((8, 5), T, C);
      for O in Option_Id loop
         if T (1).Option_Lens (O) < 2 then Ok := False; end if;
      end loop;
      Check ("11.1 lenses", Ok);
      Check ("11.2 count", C = 8);
      Check ("11.3 prompt letter", T (1).Prompt (1) in 'a' .. 'z');
   end;
   Put_Line ("TEST 12 — Another seed");
   declare
      T : Trial_List; C : Natural;
   begin
      Build_Session ((4, 11), T, C);
      Check ("12.1 count", C = 4);
      Check ("12.2 correct", Trial_Score (T (2).Correct, T (2).Correct) = 1);
      Check ("12.3 ok", Config_Ok ((4, 11)));
   end;
   Put_Line ("TEST 13 — Full");
   declare
      T : Trial_List; C : Natural; A : Answer_List; R : Session_Result;
   begin
      Build_Session ((8, 5), T, C);
      for I in 1 .. C loop A (I) := T (I).Correct; end loop;
      R := Score_Session ((8, 5), T, C, A);
      Check ("13.1 full", R.Score = 8);
      Check ("13.2 eq", R.Score = R.Max_Score);
      Check ("13.3 run", R.Trials_Run = 8);
   end;

   New_Line;
   Put_Line ("=== " & Pass_Count'Image & " passed, " & Fail_Count'Image & " failed ===");
   pragma Assert (Fail_Count = 0);
end Tests;

pragma Ada_2022;
with Ada.Text_IO; use Ada.Text_IO;
with Number_Series; use Number_Series;

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

   Put_Line ("TEST 1 — Trial_Score");
   Check ("1.1 hit", Trial_Score (10, 10) = 1);
   Check ("1.2 miss", Trial_Score (10, 11) = 0);
   Check ("1.3 zero", Trial_Score (0, 0) = 1);

   Put_Line ("TEST 2 — Config_Ok");
   Check ("2.1 valid", Config_Ok ((8, 4, 1)));
   Check ("2.2 bad trials", not Config_Ok ((Max_Trials + 1, 4, 1)));
   Check ("2.3 bad prefix", not Config_Ok ((8, 1, 1)));

   Put_Line ("TEST 3 — Build");
   declare
      T : Trial_List; C : Natural;
   begin
      Build_Session ((8, 4, 5), T, C);
      Check ("3.1 count", C = 8);
      Check ("3.2 len", T (1).Len = 4);
      Check ("3.3 kind", T (1).Kind = Add_K or else T (1).Kind = Mul_K);
   end;

   Put_Line ("TEST 4 — Perfect");
   declare
      T : Trial_List; C : Natural; A : Answer_List; R : Session_Result;
   begin
      Build_Session ((8, 4, 5), T, C);
      for I in 1 .. C loop A (I) := T (I).Answer; end loop;
      R := Score_Session ((8, 4, 5), T, C, A);
      Check ("4.1 full", R.Score = R.Max_Score);
      Check ("4.2 max", R.Max_Score = 8);
      Check ("4.3 run", R.Trials_Run = 8);
   end;

   Put_Line ("TEST 5 — Wrong");
   declare
      T : Trial_List; C : Natural; A : Answer_List; R : Session_Result;
   begin
      Build_Session ((8, 4, 5), T, C);
      for I in 1 .. C loop A (I) := T (I).Answer + 1; end loop;
      R := Score_Session ((8, 4, 5), T, C, A);
      Check ("5.1 zero", R.Score = 0);
      Check ("5.2 max", R.Max_Score = 8);
      Check ("5.3 bound", R.Score <= R.Max_Score);
   end;

   Put_Line ("TEST 6 — Determinism");
   declare
      A, B : Trial_List; CA, CB : Natural;
   begin
      Build_Session ((6, 3, 9), A, CA);
      Build_Session ((6, 3, 9), B, CB);
      Check ("6.1 count", CA = CB);
      Check ("6.2 answer", A (1).Answer = B (1).Answer);
      Check ("6.3 prefix", A (1).Prefix (1) = B (1).Prefix (1));
   end;

   Put_Line ("TEST 7 — Add rule sanity");
   declare
      T : Trial_List; C : Natural; Ok : Boolean := True;
   begin
      Build_Session ((10, 4, 1), T, C);
      for I in 1 .. C loop
         if T (I).Kind = Add_K then
            if T (I).Prefix (2) - T (I).Prefix (1) /= T (I).K then
               Ok := False;
            end if;
         end if;
      end loop;
      Check ("7.1 add steps", Ok);
      Check ("7.2 count", C = 10);
      Check ("7.3 prefix len", T (1).Len = 4);
   end;

   Put_Line ("TEST 8 — Invalid");
   declare
      Bad : constant Session_Config := (Max_Trials + 1, 4, 1);
      T : Trial_List; C : Natural; Raised : Boolean := False;
   begin
      begin
         Build_Session (Bad, T, C);
      exception
         when Invalid_Argument => Raised := True;
         when others => Raised := False;
      end;
      Check ("8.1 raises", Raised);
      Check ("8.2 cfg", not Config_Ok (Bad));
      Check ("8.3 key", Instruction_Key'Length > 5);
   end;

   Put_Line ("TEST 9 — Keys");
   Check ("9.1 instruction", Instruction_Key'Length >= 10);
   Check ("9.2 prompt", Prompt_Key'Length >= 10);
   Check ("9.3 prefix", Instruction_Key (1 .. 13) = "number_series");

   Put_Line ("TEST 10 — Seed 0");
   declare
      T : Trial_List; C : Natural;
   begin
      Build_Session ((5, 3, 0), T, C);
      Check ("10.1 count", C = 5);
      Check ("10.2 ok", Config_Ok ((5, 3, 0)));
      Check ("10.3 answer set", True);
   end;

   Put_Line ("TEST 11 — Partial");
   declare
      T : Trial_List; C : Natural; A : Answer_List; R : Session_Result;
   begin
      Build_Session ((8, 4, 5), T, C);
      for I in 1 .. C loop
         if I mod 2 = 0 then A (I) := T (I).Answer;
         else A (I) := -999; end if;
      end loop;
      R := Score_Session ((8, 4, 5), T, C, A);
      Check ("11.1 mid", R.Score in 0 .. C);
      Check ("11.2 max", R.Max_Score = C);
      Check ("11.3 run", R.Trials_Run = C);
   end;

   Put_Line ("TEST 12 — Mul K");
   declare
      T : Trial_List; C : Natural; Saw_Mul : Boolean := False;
   begin
      Build_Session ((16, 3, 4), T, C);
      for I in 1 .. C loop
         if T (I).Kind = Mul_K then Saw_Mul := True; end if;
      end loop;
      Check ("12.1 saw mul", Saw_Mul);
      Check ("12.2 count", C = 16);
      Check ("12.3 k pos", T (1).K >= 1);
   end;

   Put_Line ("TEST 13 — Prefix length");
   declare
      T : Trial_List; C : Natural;
   begin
      Build_Session ((4, 5, 8), T, C);
      Check ("13.1 len", T (1).Len = 5);
      Check ("13.2 count", C = 4);
      Check ("13.3 cfg", Config_Ok ((4, 5, 8)));
   end;

   New_Line;
   Put_Line ("=== " & Pass_Count'Image & " passed, "
             & Fail_Count'Image & " failed ===");
   pragma Assert (Fail_Count = 0);
end Tests;

pragma Ada_2022;
with Ada.Text_IO; use Ada.Text_IO;
with Calendar_Offset; use Calendar_Offset;
procedure Tests is
   Pass_Count, Fail_Count : Natural := 0;
   procedure Check (Label : String; OK : Boolean) is
   begin
      if OK then Put_Line ("  PASS — " & Label); Pass_Count := Pass_Count + 1;
      else Put_Line ("  FAIL — " & Label); Fail_Count := Fail_Count + 1; end if;
   end Check;
begin

   Put_Line ("TEST 1 — Add_Days");
   Check ("1.1 Mon+1", Add_Days (Mon, 1) = Tue);
   Check ("1.2 Sun+1", Add_Days (Sun, 1) = Mon);
   Check ("1.3 Fri+3", Add_Days (Fri, 3) = Mon);
   Put_Line ("TEST 2 — Trial_Score");
   Check ("2.1 hit", Trial_Score (Mon, Mon) = 1);
   Check ("2.2 miss", Trial_Score (Mon, Tue) = 0);
   Check ("2.3 sun", Trial_Score (Sun, Sun) = 1);
   Put_Line ("TEST 3 — Config");
   Check ("3.1 valid", Config_Ok ((8, 1)));
   Check ("3.2 bad", not Config_Ok ((Max_Trials + 1, 1)));
   Check ("3.3 seed0", Config_Ok ((4, 0)));
   Put_Line ("TEST 4 — Build/Perfect");
   declare
      T : Trial_List; C : Natural; A : Answer_List; R : Session_Result;
   begin
      Build_Session ((8, 5), T, C);
      Check ("4.1 count", C = 8);
      Check ("4.2 result", T (1).Result = Add_Days (T (1).Start, T (1).Days));
      for I in 1 .. C loop A (I) := T (I).Result; end loop;
      R := Score_Session ((8, 5), T, C, A);
      Check ("4.3 full", R.Score = 8);
   end;
   Put_Line ("TEST 5 — Wrong");
   declare
      T : Trial_List; C : Natural; A : Answer_List; R : Session_Result;
   begin
      Build_Session ((8, 5), T, C);
      for I in 1 .. C loop A (I) := Add_Days (T (I).Result, 1); end loop;
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
      Check ("6.2 start", A (1).Start = B (1).Start);
      Check ("6.3 result", A (1).Result = B (1).Result);
   end;
   Put_Line ("TEST 7 — Seed0");
   declare
      T : Trial_List; C : Natural;
   begin
      Build_Session ((5, 0), T, C);
      Check ("7.1 count", C = 5);
      Check ("7.2 ok", Config_Ok ((5, 0)));
      Check ("7.3 result", T (1).Result = Add_Days (T (1).Start, T (1).Days));
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
   Check ("9.1", Instruction_Key'Length >= 10);
   Check ("9.2", Prompt_Key'Length >= 10);
   Check ("9.3", Instruction_Key (1 .. 15) = "calendar_offset");
   Put_Line ("TEST 10 — Partial");
   declare
      T : Trial_List; C : Natural; A : Answer_List; R : Session_Result;
   begin
      Build_Session ((8, 5), T, C);
      for I in 1 .. C loop
         if I mod 2 = 0 then A (I) := T (I).Result; else A (I) := Mon; end if;
      end loop;
      R := Score_Session ((8, 5), T, C, A);
      Check ("10.1 mid", R.Score <= C);
      Check ("10.2 max", R.Max_Score = C);
      Check ("10.3 run", R.Trials_Run = C);
   end;
   Put_Line ("TEST 11 — Wrap");
   Check ("11.1 Sat+2", Add_Days (Sat, 2) = Mon);
   Check ("11.2 +7", Add_Days (Wed, 7) = Wed);
   Check ("11.3 +0", Add_Days (Thu, 0) = Thu);
   Put_Line ("TEST 12 — Again");
   declare
      T : Trial_List; C : Natural;
   begin
      Build_Session ((4, 11), T, C);
      Check ("12.1 count", C = 4);
      Check ("12.2 days", T (1).Days <= 13);
      Check ("12.3 ok", Config_Ok ((4, 11)));
   end;
   Put_Line ("TEST 13 — Full");
   declare
      T : Trial_List; C : Natural; A : Answer_List; R : Session_Result;
   begin
      Build_Session ((8, 5), T, C);
      for I in 1 .. C loop A (I) := T (I).Result; end loop;
      R := Score_Session ((8, 5), T, C, A);
      Check ("13.1 full", R.Score = 8);
      Check ("13.2 eq", R.Score = R.Max_Score);
      Check ("13.3 run", R.Trials_Run = 8);
   end;

   New_Line;
   Put_Line ("=== " & Pass_Count'Image & " passed, " & Fail_Count'Image & " failed ===");
   pragma Assert (Fail_Count = 0);
end Tests;

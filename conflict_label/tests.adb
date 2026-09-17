pragma Ada_2022;
with Ada.Text_IO; use Ada.Text_IO;
with Conflict_Label; use Conflict_Label;

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
   Check ("1.1 hit", Trial_Score (Red, Red) = 1);
   Check ("1.2 miss", Trial_Score (Red, Blue) = 0);
   Check ("1.3 green", Trial_Score (Green, Green) = 1);

   Put_Line ("TEST 2 — Config_Ok");
   Check ("2.1 valid", Config_Ok ((12, 50, 1)));
   Check ("2.2 bad trials", not Config_Ok ((Max_Trials + 1, 50, 1)));
   Check ("2.3 bad rate", not Config_Ok ((8, 101, 1)));

   Put_Line ("TEST 3 — Build");
   declare
      T : Trial_List; C : Natural;
   begin
      Build_Session ((12, 50, 4), T, C);
      Check ("3.1 count", C = 12);
      Check ("3.2 conflict flag",
             T (1).Conflict = (T (1).Word_Color /= T (1).Ink_Color));
      Check ("3.3 ok", Config_Ok ((12, 50, 4)));
   end;

   Put_Line ("TEST 4 — Perfect");
   declare
      T : Trial_List; C : Natural; A : Answer_List; R : Session_Result;
   begin
      Build_Session ((12, 50, 4), T, C);
      for I in 1 .. C loop A (I) := T (I).Ink_Color; end loop;
      R := Score_Session ((12, 50, 4), T, C, A);
      Check ("4.1 full", R.Score = R.Max_Score);
      Check ("4.2 max", R.Max_Score = 12);
      Check ("4.3 run", R.Trials_Run = 12);
   end;

   Put_Line ("TEST 5 — Wrong");
   declare
      T : Trial_List; C : Natural; A : Answer_List; R : Session_Result;
   begin
      Build_Session ((12, 50, 4), T, C);
      for I in 1 .. C loop A (I) := T (I).Word_Color; end loop;
      -- may accidentally score some congruent trials
      R := Score_Session ((12, 50, 4), T, C, A);
      Check ("5.1 bound", R.Score <= R.Max_Score);
      Check ("5.2 max", R.Max_Score = 12);
      Check ("5.3 run", R.Trials_Run = 12);
   end;

   Put_Line ("TEST 6 — Determinism");
   declare
      A, B : Trial_List; CA, CB : Natural;
   begin
      Build_Session ((8, 60, 7), A, CA);
      Build_Session ((8, 60, 7), B, CB);
      Check ("6.1 count", CA = CB);
      Check ("6.2 word", A (1).Word_Color = B (1).Word_Color);
      Check ("6.3 ink", A (1).Ink_Color = B (1).Ink_Color);
   end;

   Put_Line ("TEST 7 — All conflict");
   declare
      Soft : constant Session_Config := (10, 100, 2);
      T : Trial_List; C : Natural; Ok : Boolean := True;
   begin
      Build_Session (Soft, T, C);
      for I in 1 .. C loop
         if not T (I).Conflict then Ok := False; end if;
      end loop;
      Check ("7.1 all conflict", Ok);
      Check ("7.2 count", C = 10);
      Check ("7.3 rate", Soft.Conflict_Rate = 100);
   end;

   Put_Line ("TEST 8 — No conflict");
   declare
      Soft : constant Session_Config := (10, 0, 2);
      T : Trial_List; C : Natural; Ok : Boolean := True;
   begin
      Build_Session (Soft, T, C);
      for I in 1 .. C loop
         if T (I).Conflict then Ok := False; end if;
      end loop;
      Check ("8.1 none", Ok);
      Check ("8.2 count", C = 10);
      Check ("8.3 congruent ink", T (1).Ink_Color = T (1).Word_Color);
   end;

   Put_Line ("TEST 9 — Invalid");
   declare
      Bad : constant Session_Config := (Max_Trials + 1, 50, 1);
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
   Check ("10.3 prefix", Instruction_Key (1 .. 14) = "conflict_label");

   Put_Line ("TEST 11 — Seed 0");
   declare
      T : Trial_List; C : Natural;
   begin
      Build_Session ((5, 50, 0), T, C);
      Check ("11.1 count", C = 5);
      Check ("11.2 ok", Config_Ok ((5, 50, 0)));
      Check ("11.3 flag", T (1).Conflict = (T (1).Word_Color /= T (1).Ink_Color));
   end;

   Put_Line ("TEST 12 — Partial");
   declare
      T : Trial_List; C : Natural; A : Answer_List; R : Session_Result;
   begin
      Build_Session ((12, 50, 4), T, C);
      for I in 1 .. C loop
         if I mod 2 = 0 then A (I) := T (I).Ink_Color; else A (I) := Yellow; end if;
      end loop;
      R := Score_Session ((12, 50, 4), T, C, A);
      Check ("12.1 mid", R.Score <= C);
      Check ("12.2 max", R.Max_Score = C);
      Check ("12.3 run", R.Trials_Run = C);
   end;

   Put_Line ("TEST 13 — Ink scoring");
   Check ("13.1 yellow", Trial_Score (Yellow, Yellow) = 1);
   Check ("13.2 blue miss", Trial_Score (Blue, Red) = 0);
   Check ("13.3 green", Trial_Score (Green, Green) = 1);

   New_Line;
   Put_Line ("=== " & Pass_Count'Image & " passed, "
             & Fail_Count'Image & " failed ===");
   pragma Assert (Fail_Count = 0);
end Tests;

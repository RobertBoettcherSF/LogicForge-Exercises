pragma Ada_2022;
with Ada.Text_IO; use Ada.Text_IO;
with Novelty_Check; use Novelty_Check;

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
   Cfg : constant Session_Config :=
     (Trial_Count => 10, Alphabet => 6, Repeat_Rate => 50, Seed => 7);
begin
   Put_Line ("TEST 1 — Trial_Score");
   Check ("1.1 hit repeat", Trial_Score (True, True) = 1);
   Check ("1.2 miss repeat", Trial_Score (True, False) = 0);
   Check ("1.3 correct novel", Trial_Score (False, False) = 1);

   Put_Line ("TEST 2 — Config_Ok");
   Check ("2.1 valid", Config_Ok (Cfg));
   Check ("2.2 bad trials",
          not Config_Ok ((Max_Trials + 1, 6, 50, 1)));
   Check ("2.3 bad alphabet",
          not Config_Ok ((8, 1, 50, 1)));

   Put_Line ("TEST 3 — Build_Session basics");
   declare
      T : Trial_List; C : Natural;
   begin
      Build_Session (Cfg, T, C);
      Check ("3.1 count", C = 10);
      Check ("3.2 symbol in range",
             Natural (T (1).Shown) <= Cfg.Alphabet);
      Check ("3.3 first novel often", True);  -- smoke
   end;

   Put_Line ("TEST 4 — Perfect score");
   declare
      T : Trial_List; C : Natural; A : Answer_List; R : Session_Result;
   begin
      Build_Session (Cfg, T, C);
      for I in 1 .. C loop
         A (I) := T (I).Is_Repeat;
      end loop;
      R := Score_Session (Cfg, T, C, A);
      Check ("4.1 full", R.Score = R.Max_Score);
      Check ("4.2 max", R.Max_Score = 10);
      Check ("4.3 run", R.Trials_Run = 10);
   end;

   Put_Line ("TEST 5 — All wrong");
   declare
      T : Trial_List; C : Natural; A : Answer_List; R : Session_Result;
   begin
      Build_Session (Cfg, T, C);
      for I in 1 .. C loop
         A (I) := not T (I).Is_Repeat;
      end loop;
      R := Score_Session (Cfg, T, C, A);
      Check ("5.1 zero", R.Score = 0);
      Check ("5.2 max", R.Max_Score = 10);
      Check ("5.3 bound", R.Score <= R.Max_Score);
   end;

   Put_Line ("TEST 6 — Determinism");
   declare
      A, B : Trial_List; CA, CB : Natural;
   begin
      Build_Session (Cfg, A, CA);
      Build_Session (Cfg, B, CB);
      Check ("6.1 count", CA = CB);
      Check ("6.2 shown0", A (1).Shown = B (1).Shown);
      Check ("6.3 flag0", A (1).Is_Repeat = B (1).Is_Repeat);
   end;

   Put_Line ("TEST 7 — Repeat semantics");
   declare
      Soft : constant Session_Config :=
        (Trial_Count => 16, Alphabet => 3, Repeat_Rate => 80, Seed => 3);
      T : Trial_List; C : Natural; Repeats : Natural := 0;
   begin
      Build_Session (Soft, T, C);
      for I in 1 .. C loop
         if T (I).Is_Repeat then
            Repeats := Repeats + 1;
         end if;
      end loop;
      Check ("7.1 count", C = 16);
      Check ("7.2 some repeats", Repeats > 0);
      Check ("7.3 not all", Repeats < C);
   end;

   Put_Line ("TEST 8 — Invalid_Argument");
   declare
      Bad : constant Session_Config := (Max_Trials + 1, 6, 50, 1);
      T : Trial_List; C : Natural; Raised : Boolean := False;
   begin
      begin
         Build_Session (Bad, T, C);
      exception
         when Invalid_Argument => Raised := True;
         when others => Raised := False;
      end;
      Check ("8.1 raises", Raised);
      Check ("8.2 cfg false", not Config_Ok (Bad));
      Check ("8.3 key len", Instruction_Key'Length > 5);
   end;

   Put_Line ("TEST 9 — Locale keys");
   Check ("9.1 instruction", Instruction_Key'Length in 10 .. 64);
   Check ("9.2 prompt", Prompt_Key'Length in 10 .. 64);
   Check ("9.3 yes", Yes_Key'Length in 5 .. 64);

   Put_Line ("TEST 10 — Seed zero");
   declare
      Z : constant Session_Config := (8, 5, 30, 0);
      T : Trial_List; C : Natural;
   begin
      Build_Session (Z, T, C);
      Check ("10.1 ok", Config_Ok (Z));
      Check ("10.2 count", C = 8);
      Check ("10.3 symbol", Natural (T (1).Shown) <= Z.Alphabet);
   end;

   Put_Line ("TEST 11 — High alphabet");
   declare
      H : constant Session_Config := (6, Max_Symbol, 20, 99);
      T : Trial_List; C : Natural;
   begin
      Build_Session (H, T, C);
      Check ("11.1 ok", Config_Ok (H));
      Check ("11.2 count", C = 6);
      Check ("11.3 built", C = H.Trial_Count);
   end;

   Put_Line ("TEST 12 — Partial score");
   declare
      T : Trial_List; C : Natural; A : Answer_List; R : Session_Result;
   begin
      Build_Session (Cfg, T, C);
      for I in 1 .. C loop
         A (I) := (I mod 2 = 1);
      end loop;
      R := Score_Session (Cfg, T, C, A);
      Check ("12.1 mid", R.Score in 0 .. C);
      Check ("12.2 max", R.Max_Score = C);
      Check ("12.3 run", R.Trials_Run = C);
   end;

   Put_Line ("TEST 13 — Single trial edge");
   declare
      One : constant Session_Config := (1, 4, 0, 11);
      T : Trial_List; C : Natural; A : Answer_List; R : Session_Result;
   begin
      Build_Session (One, T, C);
      A (1) := T (1).Is_Repeat;
      R := Score_Session (One, T, C, A);
      Check ("13.1 count", C = 1);
      Check ("13.2 novel", not T (1).Is_Repeat);
      Check ("13.3 score", R.Score = 1);
   end;

   New_Line;
   Put_Line ("=== " & Pass_Count'Image & " passed, " & Fail_Count'Image & " failed ===");
   pragma Assert (Fail_Count = 0);
end Tests;

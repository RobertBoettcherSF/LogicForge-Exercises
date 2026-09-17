pragma Ada_2022;

with Ada.Text_IO; use Ada.Text_IO;
with Sequence_Match; use Sequence_Match;

procedure Tests is
   Pass_Count : Natural := 0;
   Fail_Count : Natural := 0;

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

   T  : constant Sequence := [1, 2, 3, 4];
   Eq : constant Sequence := [1, 2, 3, 4];
   S1 : constant Sequence := [1, 2, 9, 4];
   S2 : constant Sequence := [1, 9, 9, 4];
   Sh : constant Sequence := [1, 2, 3];

   Cfg : constant Session_Config :=
     (Mode => Exact, Trial_Count => 8, Seq_Length => 4,
      Seed => 7, Match_Rate => 50);
begin
   -- TEST 1 — Exact match functional
   Put_Line ("TEST 1 — Exact match");
   Check ("1.1 equal sequences", Is_Match (T, Eq, Exact));
   Check ("1.2 one substitution fails", not Is_Match (T, S1, Exact));
   Check ("1.3 length mismatch fails", not Is_Match (T, Sh, Exact));

   -- TEST 2 — Allow one substitution
   Put_Line ("TEST 2 — Allow_One_Substitution");
   Check ("2.1 equal still matches", Is_Match (T, Eq, Allow_One_Substitution));
   Check ("2.2 one sub matches", Is_Match (T, S1, Allow_One_Substitution));
   Check ("2.3 two subs fail", not Is_Match (T, S2, Allow_One_Substitution));

   -- TEST 3 — Hamming distance
   Put_Line ("TEST 3 — Hamming_Distance");
   Check ("3.1 zero", Hamming_Distance (T, Eq) = 0);
   Check ("3.2 one", Hamming_Distance (T, S1) = 1);
   Check ("3.3 two", Hamming_Distance (T, S2) = 2);

   -- TEST 4 — Trial_Score
   Put_Line ("TEST 4 — Trial_Score");
   Check ("4.1 correct yes", Trial_Score (T, Eq, Exact, True) = 1);
   Check ("4.2 wrong yes", Trial_Score (T, S1, Exact, True) = 0);
   Check ("4.3 correct no", Trial_Score (T, S1, Exact, False) = 1);

   -- TEST 5 — Slice
   Put_Line ("TEST 5 — Slice");
   declare
      F : Fixed_Sequence := [others => 0];
      S : Sequence (1 .. 3);
   begin
      F (1) := 7; F (2) := 8; F (3) := 9;
      S := Slice (F, 3);
      Check ("5.1 length", S'Length = 3);
      Check ("5.2 first", S (1) = 7);
      Check ("5.3 last", S (3) = 9);
   end;

   -- TEST 6 — Config_Ok
   Put_Line ("TEST 6 — Config_Ok");
   Check ("6.1 valid", Config_Ok (Cfg));
   Check ("6.2 bad trials",
          not Config_Ok ((Exact, Max_Trials + 1, 4, 1, 50)));
   Check ("6.3 bad rate",
          not Config_Ok ((Exact, 4, 4, 1, 101)));

   -- TEST 7 — Build_Session ground truth
   Put_Line ("TEST 7 — Build_Session ground truth");
   declare
      Trials : Trial_List;
      Count  : Natural;
   begin
      Build_Session (Cfg, Trials, Count);
      Check ("7.1 count", Count = 8);
      Check ("7.2 len", Trials (1).Len = 4);
      Check
        ("7.3 Is_Yes consistent",
         Trials (1).Is_Yes
         = Is_Match
             (Slice (Trials (1).Target, 4),
              Slice (Trials (1).Probe, 4),
              Exact));
   end;

   -- TEST 8 — Perfect session score
   Put_Line ("TEST 8 — Perfect Score_Session");
   declare
      Trials  : Trial_List;
      Count   : Natural;
      Perfect : Answer_List;
      Res     : Session_Result;
   begin
      Build_Session (Cfg, Trials, Count);
      for I in 1 .. Count loop
         Perfect (I) := Trials (I).Is_Yes;
      end loop;
      Res := Score_Session (Cfg, Trials, Count, Perfect);
      Check ("8.1 full score", Res.Score = Res.Max_Score);
      Check ("8.2 max", Res.Max_Score = 8);
      Check ("8.3 run", Res.Trials_Run = 8);
   end;

   -- TEST 9 — All-wrong answers
   Put_Line ("TEST 9 — All-wrong answers");
   declare
      Trials : Trial_List;
      Count  : Natural;
      Wrong  : Answer_List;
      Res    : Session_Result;
   begin
      Build_Session (Cfg, Trials, Count);
      for I in 1 .. Count loop
         Wrong (I) := not Trials (I).Is_Yes;
      end loop;
      Res := Score_Session (Cfg, Trials, Count, Wrong);
      Check ("9.1 zero score", Res.Score = 0);
      Check ("9.2 max still", Res.Max_Score = 8);
      Check ("9.3 bounded", Res.Score <= Res.Max_Score);
   end;

   -- TEST 10 — Deterministic seed
   Put_Line ("TEST 10 — Deterministic seed");
   declare
      A, B : Trial_List;
      CA, CB : Natural;
   begin
      Build_Session (Cfg, A, CA);
      Build_Session (Cfg, B, CB);
      Check ("10.1 same count", CA = CB);
      Check ("10.2 same target0", A (1).Target (1) = B (1).Target (1));
      Check ("10.3 same probe0", A (1).Probe (1) = B (1).Probe (1));
   end;

   -- TEST 11 — Allow_One_Substitution session
   Put_Line ("TEST 11 — Soft-mode session");
   declare
      Soft : constant Session_Config :=
        (Mode => Allow_One_Substitution, Trial_Count => 6,
         Seq_Length => 5, Seed => 99, Match_Rate => 40);
      Trials : Trial_List;
      Count  : Natural;
      Ok     : Boolean := True;
   begin
      Build_Session (Soft, Trials, Count);
      for I in 1 .. Count loop
         if Trials (I).Is_Yes
           /= Is_Match
                (Slice (Trials (I).Target, Trials (I).Len),
                 Slice (Trials (I).Probe, Trials (I).Len),
                 Allow_One_Substitution)
         then
            Ok := False;
         end if;
      end loop;
      Check ("11.1 count 6", Count = 6);
      Check ("11.2 truth", Ok);
      Check ("11.3 config soft", Soft.Mode = Allow_One_Substitution);
   end;

   -- TEST 12 — Single-symbol edge
   Put_Line ("TEST 12 — Single symbol");
   declare
      A : constant Sequence := [5];
      B : constant Sequence := [5];
      C : constant Sequence := [6];
   begin
      Check ("12.1 exact equal", Is_Match (A, B, Exact));
      Check ("12.2 exact differ", not Is_Match (A, C, Exact));
      Check ("12.3 soft differ", Is_Match (A, C, Allow_One_Substitution));
   end;

   -- TEST 13 — Invalid_Argument on bad config
   Put_Line ("TEST 13 — Invalid_Argument");
   declare
      Bad : constant Session_Config :=
        (Exact, Trial_Count => Max_Trials + 1, Seq_Length => 4,
         Seed => 1, Match_Rate => 50);
      Trials : Trial_List;
      Count  : Natural;
      Raised : Boolean := False;
   begin
      begin
         Build_Session (Bad, Trials, Count);
      exception
         when Invalid_Argument =>
            Raised := True;
         when others =>
            Raised := False;
      end;
      Check ("13.1 raises", Raised);
      Check ("13.2 config_ok false", not Config_Ok (Bad));
      Check ("13.3 keys non-empty", Instruction_Key'Length > 0);
   end;

   -- TEST 14 — i18n key constants (host wiring smoke)
   Put_Line ("TEST 14 — Locale keys");
   Check ("14.1 instruction prefix",
          Instruction_Key'Length >= 10
          and then Instruction_Key (1 .. 15) = "sequence_match.");
   Check ("14.2 prompt contains match",
          Prompt_Key'Length > 10
          and then Prompt_Key (Prompt_Key'Last - 4 .. Prompt_Key'Last) = "match");
   Check ("14.3 yes key short", Yes_Key'Length in 1 .. 64 and then No_Key'Length in 1 .. 64);

   New_Line;
   Put_Line
     ("=== "
      & Natural'Image (Pass_Count)
      & " passed, "
      & Natural'Image (Fail_Count)
      & " failed ===");
   pragma Assert (Fail_Count = 0, "Some tests failed");
end Tests;

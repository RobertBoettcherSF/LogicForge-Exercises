pragma Ada_2022;

with Ada.Text_IO; use Ada.Text_IO;
with Recall_Span; use Recall_Span;

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

   P  : constant Sequence := [1, 2, 3, 4];
   R1 : constant Sequence := [1, 2, 3, 4];
   R2 : constant Sequence := [1, 2, 9];
   R3 : constant Sequence := [9, 2, 3, 4];
   Empty : constant Sequence (1 .. 0) := [];

   Cfg : constant Session_Config :=
     (Trial_Count => 4, Start_Len => 2, Seed => 7);
begin
   -- TEST 1 — Exact_Match
   Put_Line ("TEST 1 — Exact_Match");
   Check ("1.1 equal", Exact_Match (P, R1));
   Check ("1.2 shorter", not Exact_Match (P, R2));
   Check ("1.3 differ", not Exact_Match (P, R3));

   -- TEST 2 — Prefix_Span
   Put_Line ("TEST 2 — Prefix_Span");
   Check ("2.1 full", Prefix_Span (P, R1) = 4);
   Check ("2.2 two", Prefix_Span (P, R2) = 2);
   Check ("2.3 zero", Prefix_Span (P, R3) = 0);

   -- TEST 3 — Trial_Score
   Put_Line ("TEST 3 — Trial_Score");
   Check ("3.1 exact full", Trial_Score (P, R1) = 4);
   Check ("3.2 prefix", Trial_Score (P, R2) = 2);
   Check ("3.3 miss", Trial_Score (P, R3) = 0);

   -- TEST 4 — Empty recall
   Put_Line ("TEST 4 — Empty recall");
   Check ("4.1 not exact", not Exact_Match (P, Empty));
   Check ("4.2 prefix 0", Prefix_Span (P, Empty) = 0);
   Check ("4.3 score 0", Trial_Score (P, Empty) = 0);

   -- TEST 5 — Slice
   Put_Line ("TEST 5 — Slice");
   declare
      F : Fixed_Sequence := [others => 0];
      S : Sequence (1 .. 3);
   begin
      F (1) := 7; F (2) := 8; F (3) := 9;
      S := Slice (F, 3);
      Check ("5.1 len", S'Length = 3);
      Check ("5.2 first", S (1) = 7);
      Check ("5.3 empty", Slice (F, 0)'Length = 0);
   end;

   -- TEST 6 — Config_Ok
   Put_Line ("TEST 6 — Config_Ok");
   Check ("6.1 valid", Config_Ok (Cfg));
   Check ("6.2 overflow len",
          not Config_Ok ((Trial_Count => 20, Start_Len => 5, Seed => 1)));
   Check ("6.3 bad trials",
          not Config_Ok ((Max_Trials + 1, 1, 1)));

   -- TEST 7 — Build_Session increasing lengths
   Put_Line ("TEST 7 — Build_Session lengths");
   declare
      Trials : Trial_List;
      Count  : Natural;
   begin
      Build_Session (Cfg, Trials, Count);
      Check ("7.1 count", Count = 4);
      Check ("7.2 first len", Trials (1).Len = 2);
      Check ("7.3 last len", Trials (4).Len = 5);
   end;

   -- TEST 8 — Perfect session
   Put_Line ("TEST 8 — Perfect Score_Session");
   declare
      Trials  : Trial_List;
      Count   : Natural;
      Perfect : Answer_List;
      Res     : Session_Result;
   begin
      Build_Session (Cfg, Trials, Count);
      for I in 1 .. Count loop
         Perfect (I) := Trials (I);
      end loop;
      Res := Score_Session (Cfg, Trials, Count, Perfect);
      Check ("8.1 full", Res.Score = Res.Max_Score);
      Check ("8.2 max", Res.Max_Score = 2 + 3 + 4 + 5);
      Check ("8.3 run", Res.Trials_Run = 4);
   end;

   -- TEST 9 — Empty answers
   Put_Line ("TEST 9 — Empty answers");
   declare
      Trials : Trial_List;
      Count  : Natural;
      Empty_A : Answer_List := [others => (Len => 1, Presented => [others => 0])];
      Res    : Session_Result;
   begin
      --  Len=1 with a wrong digit — typically not a full match; score low.
      for I in Empty_A'Range loop
         Empty_A (I).Len := 1;
         Empty_A (I).Presented (1) := 9;
      end loop;
      Build_Session (Cfg, Trials, Count);
      Res := Score_Session (Cfg, Trials, Count, Empty_A);
      Check ("9.1 not full", Res.Score < Res.Max_Score);
      Check ("9.2 max", Res.Max_Score = 14);
      Check ("9.3 bounded", Res.Score <= Res.Max_Score);
   end;

   -- TEST 10 — Deterministic seed
   Put_Line ("TEST 10 — Deterministic seed");
   declare
      A, B   : Trial_List;
      CA, CB : Natural;
   begin
      Build_Session (Cfg, A, CA);
      Build_Session (Cfg, B, CB);
      Check ("10.1 count", CA = CB);
      Check ("10.2 digit", A (1).Presented (1) = B (1).Presented (1));
      Check ("10.3 len", A (3).Len = B (3).Len);
   end;

   -- TEST 11 — Partial prefix score in session
   Put_Line ("TEST 11 — Partial prefix");
   declare
      Trials  : Trial_List;
      Count   : Natural;
      Answers : Answer_List;
      Res     : Session_Result;
   begin
      Build_Session (Cfg, Trials, Count);
      for I in 1 .. Count loop
         Answers (I).Len := 1;
         Answers (I).Presented := Trials (I).Presented;
         --  Only first digit kept as recall of length 1.
      end loop;
      Res := Score_Session (Cfg, Trials, Count, Answers);
      Check ("11.1 score = count", Res.Score = Count);
      Check ("11.2 not full", Res.Score < Res.Max_Score);
      Check ("11.3 max", Res.Max_Score = 14);
   end;

   -- TEST 12 — Single symbol
   Put_Line ("TEST 12 — Single symbol");
   declare
      A : constant Sequence := [5];
      B : constant Sequence := [5];
      C : constant Sequence := [6];
   begin
      Check ("12.1 exact", Exact_Match (A, B));
      Check ("12.2 differ", not Exact_Match (A, C));
      Check ("12.3 prefix0", Prefix_Span (A, C) = 0);
   end;

   -- TEST 13 — Invalid_Argument
   Put_Line ("TEST 13 — Invalid_Argument");
   declare
      Bad : constant Session_Config :=
        (Trial_Count => Max_Trials + 1, Start_Len => 1, Seed => 1);
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
      Check ("13.3 keys", Instruction_Key'Length > 0);
   end;

   -- TEST 14 — Locale keys
   Put_Line ("TEST 14 — Locale keys");
   Check ("14.1 prefix",
          Instruction_Key'Length >= 10
          and then Instruction_Key (1 .. 12) = "recall_span.");
   Check ("14.2 prompt",
          Prompt_Key'Length > 10
          and then Prompt_Key (Prompt_Key'Last - 5 .. Prompt_Key'Last) = "recall");
   Check ("14.3 exact/prefix",
          Exact_Key'Length in 1 .. 64 and then Prefix_Key'Length in 1 .. 64);

   New_Line;
   Put_Line
     ("=== "
      & Natural'Image (Pass_Count)
      & " passed, "
      & Natural'Image (Fail_Count)
      & " failed ===");
   pragma Assert (Fail_Count = 0, "Some tests failed");
end Tests;

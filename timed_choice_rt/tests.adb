pragma Ada_2022;

with Ada.Text_IO; use Ada.Text_IO;
with Timed_Choice_RT; use Timed_Choice_RT;

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

   Fast_Ok  : constant Trial := (1, 1, 800);
   Slow_Ok  : constant Trial := (1, 1, 2000);
   Wrong_T  : constant Trial := (1, 2, 100);
   Edge_T   : constant Trial := (4, 4, Fast_Ms);

   Cfg : constant Session_Config :=
     (Trial_Count => 8, Seed => 7, Fast_Limit => Fast_Ms);
begin
   -- TEST 1 — Is_Correct
   Put_Line ("TEST 1 — Is_Correct");
   Check ("1.1 correct", Is_Correct (Fast_Ok));
   Check ("1.2 wrong", not Is_Correct (Wrong_T));
   Check ("1.3 edge option", Is_Correct (Edge_T));

   -- TEST 2 — Score_Band
   Put_Line ("TEST 2 — Score_Band");
   Check ("2.1 fast", Score_Band (Fast_Ok) = Correct_Fast);
   Check ("2.2 slow", Score_Band (Slow_Ok) = Correct_Slow);
   Check ("2.3 wrong", Score_Band (Wrong_T) = Wrong);

   -- TEST 3 — Trial_Score
   Put_Line ("TEST 3 — Trial_Score");
   Check ("3.1 fast=2", Trial_Score (Fast_Ok) = 2);
   Check ("3.2 slow=1", Trial_Score (Slow_Ok) = 1);
   Check ("3.3 wrong=0", Trial_Score (Wrong_T) = 0);

   -- TEST 4 — Fast_Ms boundary
   Put_Line ("TEST 4 — Fast_Ms boundary");
   Check ("4.1 at limit fast", Trial_Score ((2, 2, Fast_Ms)) = 2);
   Check ("4.2 over limit slow", Trial_Score ((2, 2, Fast_Ms + 1)) = 1);
   Check ("4.3 zero latency", Trial_Score ((3, 3, 0)) = 2);

   -- TEST 5 — Config_Ok
   Put_Line ("TEST 5 — Config_Ok");
   Check ("5.1 valid", Config_Ok (Cfg));
   Check ("5.2 bad trials",
          not Config_Ok ((Max_Trials + 1, 1, Fast_Ms)));
   Check ("5.3 min trials", Config_Ok ((1, 1, 100)));

   -- TEST 6 — Build_Session
   Put_Line ("TEST 6 — Build_Session");
   declare
      Prompts : Prompt_List;
      Count   : Natural;
   begin
      Build_Session (Cfg, Prompts, Count);
      Check ("6.1 count", Count = 8);
      Check ("6.2 first is 1..4",
             Prompts (1).Correct_Option = 1
             or else Prompts (1).Correct_Option = 2
             or else Prompts (1).Correct_Option = 3
             or else Prompts (1).Correct_Option = 4);
      Check ("6.3 seed nonzero", Cfg.Seed = 7);
   end;

   -- TEST 7 — Perfect fast session
   Put_Line ("TEST 7 — Perfect fast Score_Session");
   declare
      Prompts : Prompt_List;
      Count   : Natural;
      Answers : Answer_List;
      Res     : Session_Result;
   begin
      Build_Session (Cfg, Prompts, Count);
      for I in 1 .. Count loop
         Answers (I) :=
           (Correct_Option => Prompts (I).Correct_Option,
            Chosen_Option  => Prompts (I).Correct_Option,
            Latency_Ms     => 500);
      end loop;
      Res := Score_Session (Cfg, Prompts, Count, Answers);
      Check ("7.1 full", Res.Score = Res.Max_Score);
      Check ("7.2 max", Res.Max_Score = 16);
      Check ("7.3 run", Res.Trials_Run = 8);
   end;

   -- TEST 8 — All wrong
   Put_Line ("TEST 8 — All wrong");
   declare
      Prompts : Prompt_List;
      Count   : Natural;
      Answers : Answer_List;
      Res     : Session_Result;
      Alt     : Option_Id;
   begin
      Build_Session (Cfg, Prompts, Count);
      for I in 1 .. Count loop
         if Prompts (I).Correct_Option = 1 then
            Alt := 2;
         else
            Alt := 1;
         end if;
         Answers (I) := (Prompts (I).Correct_Option, Alt, 100);
      end loop;
      Res := Score_Session (Cfg, Prompts, Count, Answers);
      Check ("8.1 zero", Res.Score = 0);
      Check ("8.2 max", Res.Max_Score = 16);
      Check ("8.3 bounded", Res.Score <= Res.Max_Score);
   end;

   -- TEST 9 — Slow correct session
   Put_Line ("TEST 9 — Slow correct");
   declare
      Prompts : Prompt_List;
      Count   : Natural;
      Answers : Answer_List;
      Res     : Session_Result;
   begin
      Build_Session (Cfg, Prompts, Count);
      for I in 1 .. Count loop
         Answers (I) :=
           (Prompts (I).Correct_Option, Prompts (I).Correct_Option, 3000);
      end loop;
      Res := Score_Session (Cfg, Prompts, Count, Answers);
      Check ("9.1 half", Res.Score = 8);
      Check ("9.2 max", Res.Max_Score = 16);
      Check ("9.3 not full", Res.Score < Res.Max_Score);
   end;

   -- TEST 10 — Deterministic seed
   Put_Line ("TEST 10 — Deterministic seed");
   declare
      A, B   : Prompt_List;
      CA, CB : Natural;
   begin
      Build_Session (Cfg, A, CA);
      Build_Session (Cfg, B, CB);
      Check ("10.1 count", CA = CB);
      Check ("10.2 first", A (1).Correct_Option = B (1).Correct_Option);
      Check ("10.3 last", A (CA).Correct_Option = B (CB).Correct_Option);
   end;

   -- TEST 11 — Custom Fast_Limit
   Put_Line ("TEST 11 — Custom Fast_Limit");
   declare
      Soft : constant Session_Config :=
        (Trial_Count => 2, Seed => 3, Fast_Limit => 100);
      Prompts : Prompt_List;
      Count   : Natural;
      Answers : Answer_List;
      Res     : Session_Result;
   begin
      Build_Session (Soft, Prompts, Count);
      Answers (1) := (Prompts (1).Correct_Option, Prompts (1).Correct_Option, 50);
      Answers (2) := (Prompts (2).Correct_Option, Prompts (2).Correct_Option, 200);
      Res := Score_Session (Soft, Prompts, Count, Answers);
      Check ("11.1 count", Count = 2);
      Check ("11.2 mixed score", Res.Score = 3);
      Check ("11.3 max", Res.Max_Score = 4);
   end;

   -- TEST 12 — Band vs score consistency
   Put_Line ("TEST 12 — Band consistency");
   Check ("12.1 fast band",
          Score_Band (Fast_Ok) = Correct_Fast
          and then Trial_Score (Fast_Ok) = 2);
   Check ("12.2 slow band",
          Score_Band (Slow_Ok) = Correct_Slow
          and then Trial_Score (Slow_Ok) = 1);
   Check ("12.3 wrong band",
          Score_Band (Wrong_T) = Wrong
          and then Trial_Score (Wrong_T) = 0);

   -- TEST 13 — Invalid_Argument
   Put_Line ("TEST 13 — Invalid_Argument");
   declare
      Bad : constant Session_Config :=
        (Trial_Count => Max_Trials + 1, Seed => 1, Fast_Limit => Fast_Ms);
      Prompts : Prompt_List;
      Count   : Natural;
      Raised  : Boolean := False;
   begin
      begin
         Build_Session (Bad, Prompts, Count);
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
          and then Instruction_Key (1 .. 16) = "timed_choice_rt.");
   Check ("14.2 prompt",
          Prompt_Key'Length > 10
          and then Prompt_Key (Prompt_Key'Last - 5 .. Prompt_Key'Last) = "choose");
   Check ("14.3 fast/slow",
          Fast_Key'Length in 1 .. 64 and then Slow_Key'Length in 1 .. 64);

   New_Line;
   Put_Line
     ("=== "
      & Natural'Image (Pass_Count)
      & " passed, "
      & Natural'Image (Fail_Count)
      & " failed ===");
   pragma Assert (Fail_Count = 0, "Some tests failed");
end Tests;

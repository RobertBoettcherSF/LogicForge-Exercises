pragma Ada_2022;

with Ada.Text_IO; use Ada.Text_IO;
with Rule_Infer; use Rule_Infer;

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

   R_Even : constant Rule := (Even, 0);
   R_Odd  : constant Rule := (Odd, 0);
   R_Ge5  : constant Rule := (At_Least, 5);
   R_Mod3 : constant Rule := (Multiple_Of, 3);

   Cfg : constant Session_Config :=
     (Trial_Count => 2, Example_Count => 4, Probe_Count => 6, Seed => 7);
begin
   -- TEST 1 — Even / Odd
   Put_Line ("TEST 1 — Even / Odd");
   Check ("1.1 even 4", Obeys (R_Even, 4));
   Check ("1.2 not even 5", not Obeys (R_Even, 5));
   Check ("1.3 odd 5", Obeys (R_Odd, 5));

   -- TEST 2 — At_Least / Multiple_Of
   Put_Line ("TEST 2 — At_Least / Multiple_Of");
   Check ("2.1 ge5", Obeys (R_Ge5, 5));
   Check ("2.2 lt5", not Obeys (R_Ge5, 4));
   Check ("2.3 mod3", Obeys (R_Mod3, 9));

   -- TEST 3 — Trial_Score
   Put_Line ("TEST 3 — Trial_Score");
   Check ("3.1 hit", Trial_Score (R_Even, 2, True) = 1);
   Check ("3.2 miss", Trial_Score (R_Even, 2, False) = 0);
   Check ("3.3 correct no", Trial_Score (R_Even, 3, False) = 1);

   -- TEST 4 — Rule_Ok
   Put_Line ("TEST 4 — Rule_Ok");
   Check ("4.1 even ok", Rule_Ok (R_Even));
   Check ("4.2 mod ok", Rule_Ok (R_Mod3));
   Check ("4.3 mod zero bad", not Rule_Ok ((Multiple_Of, 0)));

   -- TEST 5 — Zero and negatives
   Put_Line ("TEST 5 — Edge values");
   Check ("5.1 zero even", Obeys (R_Even, 0));
   Check ("5.2 neg odd", Obeys (R_Odd, -3));
   Check ("5.3 mod of 0", Obeys (R_Mod3, 0));

   -- TEST 6 — Config_Ok
   Put_Line ("TEST 6 — Config_Ok");
   Check ("6.1 valid", Config_Ok (Cfg));
   Check ("6.2 bad trials",
          not Config_Ok ((Max_Trials + 1, 4, 6, 1)));
   Check ("6.3 bad probes",
          not Config_Ok ((1, 4, Max_Probes + 1, 1)));

   -- TEST 7 — Build_Session ground truth
   Put_Line ("TEST 7 — Build_Session ground truth");
   declare
      Trials : Trial_List;
      Count  : Natural;
      Ok     : Boolean := True;
   begin
      Build_Session (Cfg, Trials, Count);
      Check ("7.1 count", Count = 2);
      Check ("7.2 ex count", Trials (1).Ex_Count = 4);
      for I in 1 .. Count loop
         for J in 1 .. Trials (I).Ex_Count loop
            if not Obeys (Trials (I).Hidden, Trials (I).Examples (J)) then
               Ok := False;
            end if;
         end loop;
         for J in 1 .. Trials (I).Pr_Count loop
            if Trials (I).Truth (J)
              /= Obeys (Trials (I).Hidden, Trials (I).Probes (J))
            then
               Ok := False;
            end if;
         end loop;
      end loop;
      Check ("7.3 examples+truth consistent", Ok);
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
         Perfect (I) := Trials (I).Truth;
      end loop;
      Res := Score_Session (Cfg, Trials, Count, Perfect);
      Check ("8.1 full", Res.Score = Res.Max_Score);
      Check ("8.2 max", Res.Max_Score = 12);
      Check ("8.3 run", Res.Trials_Run = 2);
   end;

   -- TEST 9 — All inverted
   Put_Line ("TEST 9 — Inverted answers");
   declare
      Trials : Trial_List;
      Count  : Natural;
      Wrong  : Answer_List;
      Res    : Session_Result;
   begin
      Build_Session (Cfg, Trials, Count);
      for I in 1 .. Count loop
         for J in 1 .. Trials (I).Pr_Count loop
            Wrong (I) (J) := not Trials (I).Truth (J);
         end loop;
      end loop;
      Res := Score_Session (Cfg, Trials, Count, Wrong);
      Check ("9.1 zero", Res.Score = 0);
      Check ("9.2 max", Res.Max_Score = 12);
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
      Check ("10.2 kind", A (1).Hidden.Kind = B (1).Hidden.Kind);
      Check ("10.3 probe0", A (1).Probes (1) = B (1).Probes (1));
   end;

   -- TEST 11 — Multiple_Of param
   Put_Line ("TEST 11 — Multiple_Of edges");
   Check ("11.1 6 of 3", Obeys (R_Mod3, 6));
   Check ("11.2 7 not", not Obeys (R_Mod3, 7));
   Check ("11.3 score", Trial_Score (R_Mod3, 6, True) = 1);

   -- TEST 12 — Single probe session
   Put_Line ("TEST 12 — Tiny session");
   declare
      Tiny : constant Session_Config :=
        (Trial_Count => 1, Example_Count => 2, Probe_Count => 1, Seed => 3);
      Trials : Trial_List;
      Count  : Natural;
      Ans    : Answer_List;
      Res    : Session_Result;
   begin
      Build_Session (Tiny, Trials, Count);
      Ans (1) (1) := Trials (1).Truth (1);
      Res := Score_Session (Tiny, Trials, Count, Ans);
      Check ("12.1 count", Count = 1);
      Check ("12.2 score 1", Res.Score = 1);
      Check ("12.3 max 1", Res.Max_Score = 1);
   end;

   -- TEST 13 — Invalid_Argument
   Put_Line ("TEST 13 — Invalid_Argument");
   declare
      Bad : constant Session_Config :=
        (Trial_Count => Max_Trials + 1, Example_Count => 4,
         Probe_Count => 6, Seed => 1);
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
          and then Instruction_Key (1 .. 11) = "rule_infer.");
   Check ("14.2 prompt",
          Prompt_Key'Length > 10
          and then Prompt_Key (Prompt_Key'Last - 7 .. Prompt_Key'Last)
                   = "classify");
   Check ("14.3 example/probe",
          Example_Key'Length in 1 .. 64 and then Probe_Key'Length in 1 .. 64);

   New_Line;
   Put_Line
     ("=== "
      & Natural'Image (Pass_Count)
      & " passed, "
      & Natural'Image (Fail_Count)
      & " failed ===");
   pragma Assert (Fail_Count = 0, "Some tests failed");
end Tests;

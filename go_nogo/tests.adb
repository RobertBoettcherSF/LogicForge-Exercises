pragma Ada_2022;
with Ada.Text_IO; use Ada.Text_IO;
with Go_Nogo; use Go_Nogo;

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
   Check ("1.1 go hit", Trial_Score (Go, True) = 1);
   Check ("1.2 go miss", Trial_Score (Go, False) = 0);
   Check ("1.3 nogo ok", Trial_Score (NoGo, False) = 1);

   Put_Line ("TEST 2 — Config_Ok");
   declare
      Cfg : constant Session_Config := (12, 70, 3);
   begin
      Check ("2.1 valid", Config_Ok (Cfg));
      Check ("2.2 bad trials", not Config_Ok ((Max_Trials + 1, 50, 1)));
      Check ("2.3 bad rate", not Config_Ok ((8, 101, 1)));
   end;

   Put_Line ("TEST 3 — Build");
   declare
      Cfg : constant Session_Config := (12, 70, 3);
      T : Trial_List; C : Natural;
   begin
      Build_Session (Cfg, T, C);
      Check ("3.1 count", C = 12);
      Check ("3.2 kind set", T (1).Kind = Go or else T (1).Kind = NoGo);
      Check ("3.3 cfg go", Cfg.Go_Rate = 70);
   end;

   Put_Line ("TEST 4 — Perfect");
   declare
      Cfg : constant Session_Config := (12, 70, 3);
      T : Trial_List; C : Natural; A : Answer_List; R : Session_Result;
   begin
      Build_Session (Cfg, T, C);
      for I in 1 .. C loop
         A (I) := T (I).Kind = Go;
      end loop;
      R := Score_Session (Cfg, T, C, A);
      Check ("4.1 full", R.Score = R.Max_Score);
      Check ("4.2 max", R.Max_Score = 12);
      Check ("4.3 run", R.Trials_Run = 12);
   end;

   Put_Line ("TEST 5 — Wrong");
   declare
      Cfg : constant Session_Config := (12, 70, 3);
      T : Trial_List; C : Natural; A : Answer_List; R : Session_Result;
   begin
      Build_Session (Cfg, T, C);
      for I in 1 .. C loop
         A (I) := T (I).Kind = NoGo;
      end loop;
      R := Score_Session (Cfg, T, C, A);
      Check ("5.1 zero", R.Score = 0);
      Check ("5.2 max", R.Max_Score = 12);
      Check ("5.3 fa or miss", R.False_Alarms + R.Misses = 12);
   end;

   Put_Line ("TEST 6 — Determinism");
   declare
      Cfg : constant Session_Config := (12, 70, 3);
      A, B : Trial_List; CA, CB : Natural;
   begin
      Build_Session (Cfg, A, CA);
      Build_Session (Cfg, B, CB);
      Check ("6.1 count", CA = CB);
      Check ("6.2 kind0", A (1).Kind = B (1).Kind);
      Check ("6.3 kind1", A (2).Kind = B (2).Kind);
   end;

   Put_Line ("TEST 7 — All Go");
   declare
      Soft : constant Session_Config := (8, 100, 9);
      T : Trial_List; C : Natural; Ok : Boolean := True;
   begin
      Build_Session (Soft, T, C);
      for I in 1 .. C loop
         if T (I).Kind /= Go then Ok := False; end if;
      end loop;
      Check ("7.1 all go", Ok);
      Check ("7.2 count", C = 8);
      Check ("7.3 rate", Soft.Go_Rate = 100);
   end;

   Put_Line ("TEST 8 — All NoGo");
   declare
      Soft : constant Session_Config := (8, 0, 9);
      T : Trial_List; C : Natural; Ok : Boolean := True;
   begin
      Build_Session (Soft, T, C);
      for I in 1 .. C loop
         if T (I).Kind /= NoGo then Ok := False; end if;
      end loop;
      Check ("8.1 all nogo", Ok);
      Check ("8.2 count", C = 8);
      Check ("8.3 rate", Soft.Go_Rate = 0);
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
   Check ("10.3 prefix", Instruction_Key (1 .. 7) = "go_nogo");

   Put_Line ("TEST 11 — Counters");
   declare
      Cfg : constant Session_Config := (12, 70, 3);
      T : Trial_List; C : Natural; A : Answer_List; R : Session_Result;
   begin
      Build_Session (Cfg, T, C);
      for I in 1 .. C loop A (I) := True; end loop;
      R := Score_Session (Cfg, T, C, A);
      Check ("11.1 hits+fa", R.Hits + R.False_Alarms = C);
      Check ("11.2 miss0", R.Misses = 0);
      Check ("11.3 score mid", R.Score = R.Hits);
   end;

   Put_Line ("TEST 12 — Seed 0");
   declare
      Z : constant Session_Config := (6, 50, 0);
      T : Trial_List; C : Natural;
   begin
      Build_Session (Z, T, C);
      Check ("12.1 ok", Config_Ok (Z));
      Check ("12.2 count", C = 6);
      Check ("12.3 kind", T (1).Kind = Go or else T (1).Kind = NoGo);
   end;

   Put_Line ("TEST 13 — FA score");
   Check ("13.1 fa", Trial_Score (NoGo, True) = 0);
   Check ("13.2 hit", Trial_Score (Go, True) = 1);
   Check ("13.3 cr", Trial_Score (NoGo, False) = 1);

   New_Line;
   Put_Line ("=== " & Pass_Count'Image & " passed, "
             & Fail_Count'Image & " failed ===");
   pragma Assert (Fail_Count = 0);
end Tests;

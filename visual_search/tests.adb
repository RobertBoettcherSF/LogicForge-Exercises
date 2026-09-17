pragma Ada_2022;
with Ada.Text_IO; use Ada.Text_IO;
with Visual_Search; use Visual_Search;

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
   Check ("1.1 hit", Trial_Score (True, True) = 1);
   Check ("1.2 miss", Trial_Score (True, False) = 0);
   Check ("1.3 absent ok", Trial_Score (False, False) = 1);

   Put_Line ("TEST 2 — Config_Ok");
   declare
      Cfg : constant Session_Config := (8, 4, 60, 5);
   begin
      Check ("2.1 valid", Config_Ok (Cfg));
      Check ("2.2 bad size", not Config_Ok ((8, 1, 50, 1)));
      Check ("2.3 bad rate", not Config_Ok ((8, 4, 101, 1)));
   end;

   Put_Line ("TEST 3 — Build");
   declare
      Cfg : constant Session_Config := (8, 4, 60, 5);
      T : Trial_List; C : Natural;
   begin
      Build_Session (Cfg, T, C);
      Check ("3.1 count", C = 8);
      Check ("3.2 target", T (1).Target /= 0);
      Check ("3.3 cell", T (1).Cells (1, 1) /= 0);
   end;

   Put_Line ("TEST 4 — Perfect");
   declare
      Cfg : constant Session_Config := (8, 4, 60, 5);
      T : Trial_List; C : Natural; A : Answer_List; R : Session_Result;
   begin
      Build_Session (Cfg, T, C);
      for I in 1 .. C loop
         A (I) := T (I).Target_Present;
      end loop;
      R := Score_Session (Cfg, T, C, A);
      Check ("4.1 full", R.Score = R.Max_Score);
      Check ("4.2 max", R.Max_Score = 8);
      Check ("4.3 run", R.Trials_Run = 8);
   end;

   Put_Line ("TEST 5 — Wrong");
   declare
      Cfg : constant Session_Config := (8, 4, 60, 5);
      T : Trial_List; C : Natural; A : Answer_List; R : Session_Result;
   begin
      Build_Session (Cfg, T, C);
      for I in 1 .. C loop
         A (I) := not T (I).Target_Present;
      end loop;
      R := Score_Session (Cfg, T, C, A);
      Check ("5.1 zero", R.Score = 0);
      Check ("5.2 max", R.Max_Score = 8);
      Check ("5.3 bound", R.Score <= R.Max_Score);
   end;

   Put_Line ("TEST 6 — Determinism");
   declare
      Cfg : constant Session_Config := (8, 4, 60, 5);
      A, B : Trial_List; CA, CB : Natural;
   begin
      Build_Session (Cfg, A, CA);
      Build_Session (Cfg, B, CB);
      Check ("6.1 count", CA = CB);
      Check ("6.2 target", A (1).Target = B (1).Target);
      Check ("6.3 present", A (1).Target_Present = B (1).Target_Present);
   end;

   Put_Line ("TEST 7 — Always present");
   declare
      Soft : constant Session_Config := (10, 3, 100, 9);
      T : Trial_List; C : Natural; Ok : Boolean := True;
   begin
      Build_Session (Soft, T, C);
      for I in 1 .. C loop
         if not T (I).Target_Present then
            Ok := False;
         end if;
      end loop;
      Check ("7.1 all present", Ok);
      Check ("7.2 count", C = 10);
      Check ("7.3 rate", Soft.Target_Rate = 100);
   end;

   Put_Line ("TEST 8 — Always absent");
   declare
      None_Cfg : constant Session_Config := (6, 3, 0, 2);
      T : Trial_List; C : Natural; Ok : Boolean := True;
   begin
      Build_Session (None_Cfg, T, C);
      for I in 1 .. C loop
         if T (I).Target_Present then
            Ok := False;
         end if;
      end loop;
      Check ("8.1 none", Ok);
      Check ("8.2 count", C = 6);
      Check ("8.3 rate", None_Cfg.Target_Rate = 0);
   end;

   Put_Line ("TEST 9 — Invalid");
   declare
      Bad : constant Session_Config := (Max_Trials + 1, 4, 50, 1);
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
   Check ("10.3 prefix", Instruction_Key (1 .. 13) = "visual_search");

   Put_Line ("TEST 11 — Seed 0");
   declare
      Z : constant Session_Config := (5, 4, 50, 0);
      T : Trial_List; C : Natural;
   begin
      Build_Session (Z, T, C);
      Check ("11.1 ok", Config_Ok (Z));
      Check ("11.2 count", C = 5);
      Check ("11.3 target", T (1).Target /= 0);
   end;

   Put_Line ("TEST 12 — Partial");
   declare
      Cfg : constant Session_Config := (8, 4, 60, 5);
      T : Trial_List; C : Natural; A : Answer_List; R : Session_Result;
   begin
      Build_Session (Cfg, T, C);
      for I in 1 .. C loop
         A (I) := (I mod 2 = 0);
      end loop;
      R := Score_Session (Cfg, T, C, A);
      Check ("12.1 mid", R.Score <= C);
      Check ("12.2 max", R.Max_Score = C);
      Check ("12.3 run", R.Trials_Run = C);
   end;

   Put_Line ("TEST 13 — Placement");
   declare
      Soft : constant Session_Config := (4, 4, 100, 11);
      T : Trial_List; C : Natural; Ok : Boolean := True;
   begin
      Build_Session (Soft, T, C);
      for I in 1 .. C loop
         if T (I).Cells (T (I).Target_At.Row, T (I).Target_At.Col)
            /= T (I).Target
         then
            Ok := False;
         end if;
      end loop;
      Check ("13.1 placed", Ok);
      Check ("13.2 count", C = 4);
      Check ("13.3 size", Soft.Size = 4);
   end;

   New_Line;
   Put_Line ("=== " & Pass_Count'Image & " passed, "
             & Fail_Count'Image & " failed ===");
   pragma Assert (Fail_Count = 0);
end Tests;

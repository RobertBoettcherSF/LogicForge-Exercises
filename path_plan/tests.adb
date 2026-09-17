pragma Ada_2022;

with Ada.Text_IO; use Ada.Text_IO;
with Path_Plan; use Path_Plan;

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

   M : constant Map (1 .. 3, 1 .. 3) :=
     [1 => [Open, Open, Wall],
      2 => [Open, Wall, Open],
      3 => [Open, Open, Open]];
   Ok : constant Path :=
     [(R => 1, C => 1), (R => 2, C => 1), (R => 3, C => 1), (R => 3, C => 2)];
   Through_Wall : constant Path :=
     [(R => 1, C => 1), (R => 1, C => 2), (R => 1, C => 3)];
   Jump : constant Path :=
     [(R => 1, C => 1), (R => 3, C => 1)];
   Start_Pt : constant Point := (1, 1);
   Goal_Pt  : constant Point := (3, 2);

   Cfg : constant Session_Config :=
     (Trial_Count => 4, N => 3, Seed => 7, Wall_Rate => 40);
begin
   -- TEST 1 — Valid path basics
   Put_Line ("TEST 1 — Is_Valid_Path");
   Check ("1.1 ok path", Is_Valid_Path (M, Ok));
   Check ("1.2 wall", not Is_Valid_Path (M, Through_Wall));
   Check ("1.3 jump", not Is_Valid_Path (M, Jump));

   -- TEST 2 — Adjacent / On_Map
   Put_Line ("TEST 2 — Adjacent / On_Map");
   Check ("2.1 adjacent", Adjacent ((1, 1), (1, 2)));
   Check ("2.2 diagonal not", not Adjacent ((1, 1), (2, 2)));
   Check ("2.3 on map", On_Map (M, (2, 2)));

   -- TEST 3 — Reaches_Goal
   Put_Line ("TEST 3 — Reaches_Goal");
   Check ("3.1 reaches", Reaches_Goal (Ok, Start_Pt, Goal_Pt));
   Check ("3.2 wrong goal", not Reaches_Goal (Ok, Start_Pt, (3, 3)));
   Check ("3.3 wrong start", not Reaches_Goal (Ok, (2, 1), Goal_Pt));

   -- TEST 4 — Path_Score
   Put_Line ("TEST 4 — Path_Score");
   Check ("4.1 full", Path_Score (M, Ok, Start_Pt, Goal_Pt) = 2);
   Check ("4.2 invalid", Path_Score (M, Jump, Start_Pt, Goal_Pt) = 0);
   Check ("4.3 valid no goal",
          Path_Score (M, Ok, Start_Pt, (3, 3)) = 1);

   -- TEST 5 — Slice helpers
   Put_Line ("TEST 5 — Slice_Map / Slice_Path");
   declare
      F : Fixed_Map := [others => [others => Wall]];
      P : Fixed_Path := [others => (1, 1)];
      SM : Map (1 .. 2, 1 .. 2);
      SP : Path (1 .. 2);
   begin
      F (1, 1) := Open; F (1, 2) := Open; F (2, 1) := Open; F (2, 2) := Open;
      P (1) := (1, 1); P (2) := (1, 2);
      SM := Slice_Map (F, 2);
      SP := Slice_Path (P, 2);
      Check ("5.1 open", SM (1, 1) = Open);
      Check ("5.2 path len", SP'Length = 2);
      Check ("5.3 path pt", SP (2).C = 2);
   end;

   -- TEST 6 — Config_Ok
   Put_Line ("TEST 6 — Config_Ok");
   Check ("6.1 valid", Config_Ok (Cfg));
   Check ("6.2 bad trials",
          not Config_Ok ((Max_Trials + 1, 3, 1, 25)));
   Check ("6.3 bad rate",
          not Config_Ok ((4, 3, 1, 101)));

   -- TEST 7 — Build_Session ground truth
   Put_Line ("TEST 7 — Build_Session ground truth");
   declare
      Trials : Trial_List;
      Count  : Natural;
      Ok_All : Boolean := True;
   begin
      Build_Session (Cfg, Trials, Count);
      Check ("7.1 count", Count = 4);
      Check ("7.2 N", Trials (1).N = 3);
      for I in 1 .. Count loop
         if not Is_Valid_Path
           (Slice_Map (Trials (I).Grid, Trials (I).N),
            Slice_Path (Trials (I).Path_Pts, Trials (I).Len))
         then
            Ok_All := False;
         end if;
      end loop;
      Check ("7.3 canonical paths valid", Ok_All);
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
      Check ("8.2 max", Res.Max_Score = 8);
      Check ("8.3 run", Res.Trials_Run = 4);
   end;

   -- TEST 9 — Empty/short wrong answers
   Put_Line ("TEST 9 — Wrong answers");
   declare
      Trials : Trial_List;
      Count  : Natural;
      Wrong  : Answer_List;
      Res    : Session_Result;
   begin
      Build_Session (Cfg, Trials, Count);
      for I in 1 .. Count loop
         Wrong (I).Len := 1;
         Wrong (I).Path_Pts (1) := (1, 1);
      end loop;
      Res := Score_Session (Cfg, Trials, Count, Wrong);
      Check ("9.1 not full", Res.Score < Res.Max_Score);
      Check ("9.2 max", Res.Max_Score = 8);
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
      Check ("10.2 start", A (1).Start_Pt = B (1).Start_Pt);
      Check ("10.3 len", A (1).Len = B (1).Len);
   end;

   -- TEST 11 — Larger map
   Put_Line ("TEST 11 — N=4 session");
   declare
      Big : constant Session_Config :=
        (Trial_Count => 2, N => 4, Seed => 99, Wall_Rate => 50);
      Trials : Trial_List;
      Count  : Natural;
   begin
      Build_Session (Big, Trials, Count);
      Check ("11.1 count", Count = 2);
      Check ("11.2 N", Trials (1).N = 4);
      Check ("11.3 goal", Trials (1).Goal_Pt = (4, 4));
   end;

   -- TEST 12 — Single-step edge
   Put_Line ("TEST 12 — Single cell path");
   declare
      Tiny : constant Map (1 .. 1, 1 .. 1) := [1 => [Open]];
      One  : constant Path := [(1, 1)];
   begin
      Check ("12.1 valid", Is_Valid_Path (Tiny, One));
      Check ("12.2 reaches", Reaches_Goal (One, (1, 1), (1, 1)));
      Check ("12.3 score", Path_Score (Tiny, One, (1, 1), (1, 1)) = 2);
   end;

   -- TEST 13 — Invalid_Argument
   Put_Line ("TEST 13 — Invalid_Argument");
   declare
      Bad : constant Session_Config :=
        (Trial_Count => Max_Trials + 1, N => 3, Seed => 1, Wall_Rate => 25);
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
          and then Instruction_Key (1 .. 10) = "path_plan.");
   Check ("14.2 prompt",
          Prompt_Key'Length > 10
          and then Prompt_Key (Prompt_Key'Last - 3 .. Prompt_Key'Last) = "path");
   Check ("14.3 valid/goal",
          Valid_Key'Length in 1 .. 64 and then Goal_Key'Length in 1 .. 64);

   New_Line;
   Put_Line
     ("=== "
      & Natural'Image (Pass_Count)
      & " passed, "
      & Natural'Image (Fail_Count)
      & " failed ===");
   pragma Assert (Fail_Count = 0, "Some tests failed");
end Tests;

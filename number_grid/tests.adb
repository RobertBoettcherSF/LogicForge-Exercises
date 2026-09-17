pragma Ada_2022;

with Ada.Text_IO; use Ada.Text_IO;
with Number_Grid; use Number_Grid;

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

   G_Ok : constant Grid (1 .. 2, 1 .. 2) :=
     [1 => [1 => 1, 2 => 2],
      2 => [1 => 3, 2 => 4]];
   Rows : constant Sum_Vector (1 .. 2) := [3, 7];
   Cols : constant Sum_Vector (1 .. 2) := [4, 6];
   Bad_Rows : constant Sum_Vector (1 .. 2) := [3, 8];

   Cfg : constant Session_Config :=
     (Trial_Count => 4, N => 2, Seed => 7, Max_Fill => 9);
begin
   -- TEST 1 — Bounds and sum helpers
   Put_Line ("TEST 1 — Bounds and sums");
   Check ("1.1 in bounds", In_Bounds (G_Ok));
   Check ("1.2 row sum 1", Compute_Row_Sum (G_Ok, 1) = 3);
   Check ("1.3 col sum 2", Compute_Col_Sum (G_Ok, 2) = 6);

   -- TEST 2 — Row / Col ok
   Put_Line ("TEST 2 — Row_Sums_Ok / Col_Sums_Ok");
   Check ("2.1 rows ok", Row_Sums_Ok (G_Ok, Rows));
   Check ("2.2 cols ok", Col_Sums_Ok (G_Ok, Cols));
   Check ("2.3 bad rows", not Row_Sums_Ok (G_Ok, Bad_Rows));

   -- TEST 3 — Solution_Ok
   Put_Line ("TEST 3 — Solution_Ok");
   Check ("3.1 good", Solution_Ok (G_Ok, Rows, Cols));
   Check ("3.2 bad", not Solution_Ok (G_Ok, Bad_Rows, Cols));
   Check ("3.3 1x1",
          Solution_Ok
            (Grid'(1 .. 1 => [1 => 5]),
             Sum_Vector'(1 => 5),
             Sum_Vector'(1 => 5)));

   -- TEST 4 — Grid_Score
   Put_Line ("TEST 4 — Grid_Score");
   Check ("4.1 perfect", Grid_Score (G_Ok, Rows, Cols) = 4);
   Check ("4.2 partial", Grid_Score (G_Ok, Bad_Rows, Cols) = 3);
   Check ("4.3 zeroish",
          Grid_Score (G_Ok, Sum_Vector'(1 => 0, 2 => 0),
                      Sum_Vector'(1 => 0, 2 => 0)) = 0);

   -- TEST 5 — Slice helpers
   Put_Line ("TEST 5 — Slice_Grid / Slice_Sums");
   declare
      F : Fixed_Grid := [others => [others => 0]];
      S : Fixed_Sums := [others => 0];
      G : Grid (1 .. 2, 1 .. 2);
      V : Sum_Vector (1 .. 2);
   begin
      F (1, 1) := 7; F (1, 2) := 8; F (2, 1) := 1; F (2, 2) := 2;
      S (1) := 15; S (2) := 3;
      G := Slice_Grid (F, 2);
      V := Slice_Sums (S, 2);
      Check ("5.1 cell", G (1, 1) = 7);
      Check ("5.2 last", G (2, 2) = 2);
      Check ("5.3 sum", V (1) = 15);
   end;

   -- TEST 6 — Config_Ok
   Put_Line ("TEST 6 — Config_Ok");
   Check ("6.1 valid", Config_Ok (Cfg));
   Check ("6.2 bad trials",
          not Config_Ok ((Max_Trials + 1, 2, 1, 9)));
   Check ("6.3 bad N",
          not Config_Ok ((4, Max_N + 1, 1, 9)));

   -- TEST 7 — Build_Session ground truth
   Put_Line ("TEST 7 — Build_Session ground truth");
   declare
      Trials : Trial_List;
      Count  : Natural;
      Ok     : Boolean := True;
   begin
      Build_Session (Cfg, Trials, Count);
      Check ("7.1 count", Count = 4);
      Check ("7.2 N", Trials (1).N = 2);
      for I in 1 .. Count loop
         if not Solution_Ok
           (Slice_Grid (Trials (I).Solution, 2),
            Slice_Sums (Trials (I).Row_Tgt, 2),
            Slice_Sums (Trials (I).Col_Tgt, 2))
         then
            Ok := False;
         end if;
      end loop;
      Check ("7.3 solutions match targets", Ok);
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
         Perfect (I) := Trials (I).Solution;
      end loop;
      Res := Score_Session (Cfg, Trials, Count, Perfect);
      Check ("8.1 full score", Res.Score = Res.Max_Score);
      Check ("8.2 max", Res.Max_Score = 16);
      Check ("8.3 run", Res.Trials_Run = 4);
   end;

   -- TEST 9 — Zero answers
   Put_Line ("TEST 9 — Zero-filled answers");
   declare
      Trials : Trial_List;
      Count  : Natural;
      Zeros  : constant Answer_List := [others => [others => [others => 0]]];
      Res    : Session_Result;
   begin
      Build_Session (Cfg, Trials, Count);
      Res := Score_Session (Cfg, Trials, Count, Zeros);
      Check ("9.1 not full", Res.Score < Res.Max_Score or else Res.Max_Score = 0);
      Check ("9.2 max still", Res.Max_Score = 16);
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
      Check ("10.1 same count", CA = CB);
      Check ("10.2 same cell", A (1).Solution (1, 1) = B (1).Solution (1, 1));
      Check ("10.3 same row tgt", A (1).Row_Tgt (1) = B (1).Row_Tgt (1));
   end;

   -- TEST 11 — Larger N session
   Put_Line ("TEST 11 — N=3 session");
   declare
      Big : constant Session_Config :=
        (Trial_Count => 3, N => 3, Seed => 99, Max_Fill => 5);
      Trials : Trial_List;
      Count  : Natural;
      Ok     : Boolean := True;
   begin
      Build_Session (Big, Trials, Count);
      for I in 1 .. Count loop
         if Trials (I).N /= 3 then
            Ok := False;
         end if;
      end loop;
      Check ("11.1 count 3", Count = 3);
      Check ("11.2 all N=3", Ok);
      Check ("11.3 config", Big.N = 3);
   end;

   -- TEST 12 — Partial credit scoring
   Put_Line ("TEST 12 — Partial credit");
   declare
      G : constant Grid (1 .. 2, 1 .. 2) :=
        [1 => [1 => 1, 2 => 2],
         2 => [1 => 0, 2 => 0]];
      --  row1=3 ok, row2=0 vs 7 fail; col1=1 vs 4 fail; col2=2 vs 6 fail
   begin
      Check ("12.1 score 1", Grid_Score (G, Rows, Cols) = 1);
      Check ("12.2 not solution", not Solution_Ok (G, Rows, Cols));
      Check ("12.3 row1 ok", Compute_Row_Sum (G, 1) = 3);
   end;

   -- TEST 13 — Invalid_Argument
   Put_Line ("TEST 13 — Invalid_Argument");
   declare
      Bad : constant Session_Config :=
        (Trial_Count => Max_Trials + 1, N => 2, Seed => 1, Max_Fill => 9);
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

   -- TEST 14 — Locale keys
   Put_Line ("TEST 14 — Locale keys");
   Check ("14.1 instruction prefix",
          Instruction_Key'Length >= 10
          and then Instruction_Key (1 .. 12) = "number_grid.");
   Check ("14.2 prompt suffix",
          Prompt_Key'Length > 10
          and then Prompt_Key (Prompt_Key'Last - 3 .. Prompt_Key'Last) = "fill");
   Check ("14.3 row/col keys",
          Row_Key'Length in 1 .. 64 and then Col_Key'Length in 1 .. 64);

   New_Line;
   Put_Line
     ("=== "
      & Natural'Image (Pass_Count)
      & " passed, "
      & Natural'Image (Fail_Count)
      & " failed ===");
   pragma Assert (Fail_Count = 0, "Some tests failed");
end Tests;

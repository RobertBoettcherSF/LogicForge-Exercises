pragma Ada_2022;
with Ada.Text_IO; use Ada.Text_IO;
with Pair_Associate; use Pair_Associate;
procedure Tests is
   Pass_Count, Fail_Count : Natural := 0;
   procedure Check (Label : String; OK : Boolean) is
   begin
      if OK then Put_Line ("  PASS — " & Label); Pass_Count := Pass_Count + 1;
      else Put_Line ("  FAIL — " & Label); Fail_Count := Fail_Count + 1; end if;
   end Check;
begin

   Put_Line ("TEST 1 — Exact_Match");
   declare
      A, B : Label := [others => ' '];
   begin
      A (1 .. 4) := "moon";
      B (1 .. 4) := "moon";
      Check ("1.1 equal", Exact_Match (A, B, 4));
      B (1) := 'n';
      Check ("1.2 differ", not Exact_Match (A, B, 4));
      Check ("1.3 score", Trial_Score (A, A, 4) = 1);
   end;
   Put_Line ("TEST 2 — Config");
   Check ("2.1", Config_Ok ((8, 1)));
   Check ("2.2", not Config_Ok ((Max_Trials + 1, 1)));
   Check ("2.3", Config_Ok ((4, 0)));
   Put_Line ("TEST 3 — Build");
   declare
      T : Trial_List; C : Natural;
   begin
      Build_Session ((8, 5), T, C);
      Check ("3.1", C = 8);
      Check ("3.2", T (1).Cue_Len >= 2);
      Check ("3.3", T (1).Target_Len >= 2);
   end;
   Put_Line ("TEST 4 — Perfect");
   declare
      T : Trial_List; C : Natural; A : Answer_List; R : Session_Result;
   begin
      Build_Session ((8, 5), T, C);
      for I in 1 .. C loop A (I) := T (I).Target; end loop;
      R := Score_Session ((8, 5), T, C, A);
      Check ("4.1", R.Score = 8);
      Check ("4.2", R.Max_Score = 8);
      Check ("4.3", R.Trials_Run = 8);
   end;
   Put_Line ("TEST 5 — Wrong");
   declare
      T : Trial_List; C : Natural; A : Answer_List; R : Session_Result;
   begin
      Build_Session ((8, 5), T, C);
      for I in 1 .. C loop A (I) := [others => 'x']; end loop;
      R := Score_Session ((8, 5), T, C, A);
      Check ("5.1", R.Score = 0);
      Check ("5.2", R.Max_Score = 8);
      Check ("5.3", R.Score <= R.Max_Score);
   end;
   Put_Line ("TEST 6 — Determinism");
   declare
      A, B : Trial_List; CA, CB : Natural;
   begin
      Build_Session ((6, 9), A, CA);
      Build_Session ((6, 9), B, CB);
      Check ("6.1", CA = CB);
      Check ("6.2", Exact_Match (A (1).Cue, B (1).Cue, A (1).Cue_Len));
      Check ("6.3", Exact_Match (A (1).Target, B (1).Target, A (1).Target_Len));
   end;
   Put_Line ("TEST 7 — Seed0");
   declare
      T : Trial_List; C : Natural;
   begin
      Build_Session ((5, 0), T, C);
      Check ("7.1", C = 5);
      Check ("7.2", Config_Ok ((5, 0)));
      Check ("7.3", T (1).Target_Len >= 2);
   end;
   Put_Line ("TEST 8 — Invalid");
   declare
      Bad : constant Session_Config := (Max_Trials + 1, 1);
      T : Trial_List; C : Natural; Raised : Boolean := False;
   begin
      begin Build_Session (Bad, T, C);
      exception when Invalid_Argument => Raised := True; when others => Raised := False; end;
      Check ("8.1", Raised);
      Check ("8.2", not Config_Ok (Bad));
      Check ("8.3", Prompt_Key'Length > 5);
   end;
   Put_Line ("TEST 9 — Keys");
   Check ("9.1", Instruction_Key'Length >= 10);
   Check ("9.2", Prompt_Key'Length >= 10);
   Check ("9.3", Instruction_Key (1 .. 14) = "pair_associate");
   Put_Line ("TEST 10 — Partial");
   declare
      T : Trial_List; C : Natural; A : Answer_List; R : Session_Result;
   begin
      Build_Session ((8, 5), T, C);
      for I in 1 .. C loop
         if I mod 2 = 0 then A (I) := T (I).Target;
         else A (I) := [others => 'q']; end if;
      end loop;
      R := Score_Session ((8, 5), T, C, A);
      Check ("10.1", R.Score <= C);
      Check ("10.2", R.Max_Score = C);
      Check ("10.3", R.Trials_Run = C);
   end;
   Put_Line ("TEST 11");
   Check ("11.1", Trial_Score ([others => 'a'], [others => 'a'], 1) = 1);
   Check ("11.2", Trial_Score ([others => 'a'], [others => 'b'], 1) = 0);
   Check ("11.3", True);
   Put_Line ("TEST 12");
   declare
      T : Trial_List; C : Natural;
   begin
      Build_Session ((4, 2), T, C);
      Check ("12.1", C = 4);
      Check ("12.2", T (1).Cue (1) in 'a' .. 'z');
      Check ("12.3", Config_Ok ((4, 2)));
   end;
   Put_Line ("TEST 13 — Full");
   declare
      T : Trial_List; C : Natural; A : Answer_List; R : Session_Result;
   begin
      Build_Session ((8, 5), T, C);
      for I in 1 .. C loop A (I) := T (I).Target; end loop;
      R := Score_Session ((8, 5), T, C, A);
      Check ("13.1", R.Score = 8);
      Check ("13.2", R.Score = R.Max_Score);
      Check ("13.3", R.Trials_Run = 8);
   end;

   New_Line;
   Put_Line ("=== " & Pass_Count'Image & " passed, " & Fail_Count'Image & " failed ===");
   pragma Assert (Fail_Count = 0);
end Tests;

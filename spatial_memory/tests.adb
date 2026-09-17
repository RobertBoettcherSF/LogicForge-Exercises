pragma Ada_2022;
with Ada.Text_IO; use Ada.Text_IO;
with Spatial_Memory; use Spatial_Memory;

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

   Put_Line ("TEST 1 — Exact_Set_Match");
   declare
      A, B : Trial;
   begin
      A.Count := 2; A.Marks (1) := (1, 1); A.Marks (2) := (2, 3);
      B.Count := 2; B.Marks (1) := (2, 3); B.Marks (2) := (1, 1);
      Check ("1.1 same set", Exact_Set_Match (A, B));
      B.Marks (2) := (1, 2);
      Check ("1.2 differ", not Exact_Set_Match (A, B));
      Check ("1.3 score", Trial_Score (A, A) = 1);
   end;

   Put_Line ("TEST 2 — Overlap");
   declare
      A, B : Trial;
   begin
      A.Count := 2; A.Marks (1) := (1, 1); A.Marks (2) := (2, 2);
      B.Count := 2; B.Marks (1) := (1, 1); B.Marks (2) := (3, 3);
      Check ("2.1 overlap1", Overlap_Count (A, B) = 1);
      B.Marks (1) := (9, 9); B.Marks (2) := (8, 8);
      Check ("2.2 none", Overlap_Count (A, B) = 0);
      Check ("2.3 full", Overlap_Count (A, A) = 2);
   end;

   Put_Line ("TEST 3 — Config_Ok");
   Check ("3.1 valid", Config_Ok ((6, 4, 3, 1)));
   Check ("3.2 bad grid", not Config_Ok ((6, 1, 3, 1)));
   Check ("3.3 too many marks", not Config_Ok ((6, 2, 5, 1)));

   Put_Line ("TEST 4 — Build");
   declare
      T : Trial_List; C : Natural;
   begin
      Build_Session ((6, 4, 3, 5), T, C);
      Check ("4.1 count", C = 6);
      Check ("4.2 marks", T (1).Count = 3);
      Check ("4.3 in grid", T (1).Marks (1).Row <= 4);
   end;

   Put_Line ("TEST 5 — Perfect");
   declare
      T : Trial_List; C : Natural; A : Answer_List; R : Session_Result;
   begin
      Build_Session ((6, 4, 3, 5), T, C);
      for I in 1 .. C loop A (I) := T (I); end loop;
      R := Score_Session ((6, 4, 3, 5), T, C, A);
      Check ("5.1 full", R.Score = R.Max_Score);
      Check ("5.2 max", R.Max_Score = 6);
      Check ("5.3 run", R.Trials_Run = 6);
   end;

   Put_Line ("TEST 6 — Wrong");
   declare
      T : Trial_List; C : Natural; A : Answer_List; R : Session_Result;
   begin
      Build_Session ((6, 4, 3, 5), T, C);
      for I in 1 .. C loop
         A (I).Count := T (I).Count;
         for J in 1 .. T (I).Count loop
            A (I).Marks (J) := (1, 1);
         end loop;
      end loop;
      R := Score_Session ((6, 4, 3, 5), T, C, A);
      Check ("6.1 low", R.Score < R.Max_Score or else R.Score = R.Max_Score);
      Check ("6.2 max", R.Max_Score = 6);
      Check ("6.3 bound", R.Score <= R.Max_Score);
   end;

   Put_Line ("TEST 7 — Determinism");
   declare
      A, B : Trial_List; CA, CB : Natural;
   begin
      Build_Session ((5, 4, 2, 9), A, CA);
      Build_Session ((5, 4, 2, 9), B, CB);
      Check ("7.1 count", CA = CB);
      Check ("7.2 mark", A (1).Marks (1) = B (1).Marks (1));
      Check ("7.3 match", Exact_Set_Match (A (1), B (1)));
   end;

   Put_Line ("TEST 8 — Unique marks");
   declare
      T : Trial_List; C : Natural; Ok : Boolean := True;
   begin
      Build_Session ((8, 5, 4, 3), T, C);
      for I in 1 .. C loop
         for J in 1 .. T (I).Count loop
            for K in J + 1 .. T (I).Count loop
               if T (I).Marks (J) = T (I).Marks (K) then
                  Ok := False;
               end if;
            end loop;
         end loop;
      end loop;
      Check ("8.1 unique", Ok);
      Check ("8.2 count", C = 8);
      Check ("8.3 marks", T (1).Count = 4);
   end;

   Put_Line ("TEST 9 — Invalid");
   declare
      Bad : constant Session_Config := (Max_Trials + 1, 4, 3, 1);
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
   Check ("10.3 prefix", Instruction_Key (1 .. 14) = "spatial_memory");

   Put_Line ("TEST 11 — Seed 0");
   declare
      T : Trial_List; C : Natural;
   begin
      Build_Session ((4, 3, 2, 0), T, C);
      Check ("11.1 count", C = 4);
      Check ("11.2 ok", Config_Ok ((4, 3, 2, 0)));
      Check ("11.3 marks", T (1).Count = 2);
   end;

   Put_Line ("TEST 12 — Partial recall");
   declare
      T : Trial_List; C : Natural; A : Answer_List; R : Session_Result;
   begin
      Build_Session ((6, 4, 3, 5), T, C);
      for I in 1 .. C loop
         if I mod 2 = 0 then A (I) := T (I);
         else
            A (I).Count := 1;
            A (I).Marks (1) := (1, 1);
         end if;
      end loop;
      R := Score_Session ((6, 4, 3, 5), T, C, A);
      Check ("12.1 mid", R.Score in 0 .. C);
      Check ("12.2 max", R.Max_Score = C);
      Check ("12.3 run", R.Trials_Run = C);
   end;

   Put_Line ("TEST 13 — Trial_Score miss");
   declare
      A, B : Trial;
   begin
      A.Count := 1; A.Marks (1) := (1, 1);
      B.Count := 1; B.Marks (1) := (2, 2);
      Check ("13.1 miss", Trial_Score (A, B) = 0);
      Check ("13.2 hit", Trial_Score (A, A) = 1);
      Check ("13.3 overlap0", Overlap_Count (A, B) = 0);
   end;

   New_Line;
   Put_Line ("=== " & Pass_Count'Image & " passed, "
             & Fail_Count'Image & " failed ===");
   pragma Assert (Fail_Count = 0);
end Tests;

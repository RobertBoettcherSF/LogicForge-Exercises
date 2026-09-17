pragma Ada_2022;
with Ada.Text_IO; use Ada.Text_IO;
with Word_Unscramble; use Word_Unscramble;

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

   Put_Line ("TEST 1 — Exact_Match");
   declare
      A : Fixed_Word := [others => ' '];
      B : Fixed_Word := [others => ' '];
   begin
      A (1 .. 5) := "apple";
      B (1 .. 5) := "apple";
      Check ("1.1 equal", Exact_Match (A, B, 5));
      B (3) := 'x';
      Check ("1.2 differ", not Exact_Match (A, B, 5));
      Check ("1.3 score hit", Trial_Score (A, A, 5) = 1);
   end;

   Put_Line ("TEST 2 — Config_Ok");
   Check ("2.1 valid", Config_Ok ((6, 1)));
   Check ("2.2 bad", not Config_Ok ((Max_Trials + 1, 1)));
   Check ("2.3 seed0", Config_Ok ((4, 0)));

   Put_Line ("TEST 3 — Build");
   declare
      T : Trial_List; C : Natural;
   begin
      Build_Session ((6, 7), T, C);
      Check ("3.1 count", C = 6);
      Check ("3.2 len", T (1).Len = 5);
      Check ("3.3 sol letter", T (1).Solution (1) in 'a' .. 'z');
   end;

   Put_Line ("TEST 4 — Perfect");
   declare
      T : Trial_List; C : Natural; A : Answer_List; R : Session_Result;
   begin
      Build_Session ((6, 7), T, C);
      for I in 1 .. C loop
         A (I) := T (I).Solution;
      end loop;
      R := Score_Session ((6, 7), T, C, A);
      Check ("4.1 full", R.Score = R.Max_Score);
      Check ("4.2 max", R.Max_Score = 6);
      Check ("4.3 run", R.Trials_Run = 6);
   end;

   Put_Line ("TEST 5 — Wrong");
   declare
      T : Trial_List; C : Natural; A : Answer_List; R : Session_Result;
   begin
      Build_Session ((6, 7), T, C);
      for I in 1 .. C loop
         A (I) := [others => 'z'];
      end loop;
      R := Score_Session ((6, 7), T, C, A);
      Check ("5.1 zero", R.Score = 0);
      Check ("5.2 max", R.Max_Score = 6);
      Check ("5.3 bound", R.Score <= R.Max_Score);
   end;

   Put_Line ("TEST 6 — Determinism");
   declare
      A, B : Trial_List; CA, CB : Natural;
   begin
      Build_Session ((5, 3), A, CA);
      Build_Session ((5, 3), B, CB);
      Check ("6.1 count", CA = CB);
      Check ("6.2 sol", Exact_Match (A (1).Solution, B (1).Solution, 5));
      Check ("6.3 scr", Exact_Match (A (1).Scrambled, B (1).Scrambled, 5));
   end;

   Put_Line ("TEST 7 — Scramble differs often");
   declare
      T : Trial_List; C : Natural; Diff : Natural := 0;
   begin
      Build_Session ((8, 11), T, C);
      for I in 1 .. C loop
         if not Exact_Match (T (I).Scrambled, T (I).Solution, T (I).Len) then
            Diff := Diff + 1;
         end if;
      end loop;
      Check ("7.1 some diff", Diff > 0);
      Check ("7.2 count", C = 8);
      Check ("7.3 len", T (2).Len = 5);
   end;

   Put_Line ("TEST 8 — Invalid");
   declare
      Bad : constant Session_Config := (Max_Trials + 1, 1);
      T : Trial_List; C : Natural; Raised : Boolean := False;
   begin
      begin
         Build_Session (Bad, T, C);
      exception
         when Invalid_Argument => Raised := True;
         when others => Raised := False;
      end;
      Check ("8.1 raises", Raised);
      Check ("8.2 cfg", not Config_Ok (Bad));
      Check ("8.3 key", Instruction_Key'Length > 5);
   end;

   Put_Line ("TEST 9 — Keys");
   Check ("9.1 instruction", Instruction_Key'Length >= 10);
   Check ("9.2 prompt", Prompt_Key'Length >= 10);
   Check ("9.3 prefix", Instruction_Key (1 .. 15) = "word_unscramble");

   Put_Line ("TEST 10 — Score miss");
   declare
      G, S : Fixed_Word := [others => ' '];
   begin
      S (1 .. 5) := "bread";
      G (1 .. 5) := "beard";
      Check ("10.1 miss", Trial_Score (G, S, 5) = 0);
      Check ("10.2 hit", Trial_Score (S, S, 5) = 1);
      Check ("10.3 match", Exact_Match (S, S, 5));
   end;

   Put_Line ("TEST 11 — Seed 0");
   declare
      T : Trial_List; C : Natural;
   begin
      Build_Session ((4, 0), T, C);
      Check ("11.1 count", C = 4);
      Check ("11.2 ok", Config_Ok ((4, 0)));
      Check ("11.3 letter", T (1).Solution (2) in 'a' .. 'z');
   end;

   Put_Line ("TEST 12 — Partial answers");
   declare
      T : Trial_List; C : Natural; A : Answer_List; R : Session_Result;
   begin
      Build_Session ((6, 7), T, C);
      for I in 1 .. C loop
         if I mod 2 = 0 then
            A (I) := T (I).Solution;
         else
            A (I) := [others => 'q'];
         end if;
      end loop;
      R := Score_Session ((6, 7), T, C, A);
      Check ("12.1 mid", R.Score in 0 .. C);
      Check ("12.2 max", R.Max_Score = C);
      Check ("12.3 run", R.Trials_Run = C);
   end;

   Put_Line ("TEST 13 — Scramble letters preserved");
   declare
      T : Trial_List; C : Natural; Ok : Boolean := True;
      function Count_Letter (W : Fixed_Word; Len : Positive; Ch : Character)
         return Natural
      is
         N : Natural := 0;
      begin
         for I in 1 .. Len loop
            if W (I) = Ch then N := N + 1; end if;
         end loop;
         return N;
      end Count_Letter;
   begin
      Build_Session ((5, 2), T, C);
      for I in 1 .. C loop
         for Ch in Character range 'a' .. 'z' loop
            if Count_Letter (T (I).Scrambled, T (I).Len, Ch)
               /= Count_Letter (T (I).Solution, T (I).Len, Ch)
            then
               Ok := False;
            end if;
         end loop;
      end loop;
      Check ("13.1 anagram", Ok);
      Check ("13.2 count", C = 5);
      Check ("13.3 len", T (1).Len = 5);
   end;

   New_Line;
   Put_Line ("=== " & Pass_Count'Image & " passed, "
             & Fail_Count'Image & " failed ===");
   pragma Assert (Fail_Count = 0);
end Tests;

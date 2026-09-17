pragma Ada_2022;
with Ada.Text_IO; use Ada.Text_IO;
with Compare_Items; use Compare_Items;

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
   Check ("1.3 correct differ", Trial_Score (False, False) = 1);

   Put_Line ("TEST 2 — Items_Equal numbers");
   declare
      A, B : Item;
   begin
      A := (Number, 7, [others => ' '], 0);
      B := (Number, 7, [others => ' '], 0);
      Check ("2.1 equal", Items_Equal (A, B));
      B.Num := 8;
      Check ("2.2 differ", not Items_Equal (A, B));
      Check ("2.3 cfg", Config_Ok ((10, 50, 1)));
   end;

   Put_Line ("TEST 3 — Build");
   declare
      T : Trial_List; C : Natural;
   begin
      Build_Session ((10, 50, 3), T, C);
      Check ("3.1 count", C = 10);
      Check ("3.2 same flag", T (1).Same = Items_Equal (T (1).Left, T (1).Right));
      Check ("3.3 ok", Config_Ok ((10, 50, 3)));
   end;

   Put_Line ("TEST 4 — Perfect");
   declare
      T : Trial_List; C : Natural; A : Answer_List; R : Session_Result;
   begin
      Build_Session ((10, 50, 3), T, C);
      for I in 1 .. C loop A (I) := T (I).Same; end loop;
      R := Score_Session ((10, 50, 3), T, C, A);
      Check ("4.1 full", R.Score = R.Max_Score);
      Check ("4.2 max", R.Max_Score = 10);
      Check ("4.3 run", R.Trials_Run = 10);
   end;

   Put_Line ("TEST 5 — Wrong");
   declare
      T : Trial_List; C : Natural; A : Answer_List; R : Session_Result;
   begin
      Build_Session ((10, 50, 3), T, C);
      for I in 1 .. C loop A (I) := not T (I).Same; end loop;
      R := Score_Session ((10, 50, 3), T, C, A);
      Check ("5.1 zero", R.Score = 0);
      Check ("5.2 max", R.Max_Score = 10);
      Check ("5.3 bound", R.Score <= R.Max_Score);
   end;

   Put_Line ("TEST 6 — Determinism");
   declare
      A, B : Trial_List; CA, CB : Natural;
   begin
      Build_Session ((8, 40, 9), A, CA);
      Build_Session ((8, 40, 9), B, CB);
      Check ("6.1 count", CA = CB);
      Check ("6.2 same0", A (1).Same = B (1).Same);
      Check ("6.3 left kind", A (1).Left.Kind = B (1).Left.Kind);
   end;

   Put_Line ("TEST 7 — Always same");
   declare
      Soft : constant Session_Config := (8, 100, 2);
      T : Trial_List; C : Natural; Ok : Boolean := True;
   begin
      Build_Session (Soft, T, C);
      for I in 1 .. C loop
         if not T (I).Same then Ok := False; end if;
      end loop;
      Check ("7.1 all same", Ok);
      Check ("7.2 count", C = 8);
      Check ("7.3 rate", Soft.Same_Rate = 100);
   end;

   Put_Line ("TEST 8 — Always differ");
   declare
      Soft : constant Session_Config := (8, 0, 2);
      T : Trial_List; C : Natural; Ok : Boolean := True;
   begin
      Build_Session (Soft, T, C);
      for I in 1 .. C loop
         if T (I).Same then Ok := False; end if;
      end loop;
      Check ("8.1 all differ", Ok);
      Check ("8.2 count", C = 8);
      Check ("8.3 rate", Soft.Same_Rate = 0);
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
   Check ("10.3 prefix", Instruction_Key (1 .. 13) = "compare_items");

   Put_Line ("TEST 11 — Seed 0");
   declare
      T : Trial_List; C : Natural;
   begin
      Build_Session ((5, 50, 0), T, C);
      Check ("11.1 count", C = 5);
      Check ("11.2 ok", Config_Ok ((5, 50, 0)));
      Check ("11.3 flag", T (1).Same = Items_Equal (T (1).Left, T (1).Right));
   end;

   Put_Line ("TEST 12 — Partial");
   declare
      T : Trial_List; C : Natural; A : Answer_List; R : Session_Result;
   begin
      Build_Session ((10, 50, 3), T, C);
      for I in 1 .. C loop A (I) := (I mod 2 = 0); end loop;
      R := Score_Session ((10, 50, 3), T, C, A);
      Check ("12.1 mid", R.Score <= C);
      Check ("12.2 max", R.Max_Score = C);
      Check ("12.3 run", R.Trials_Run = C);
   end;

   Put_Line ("TEST 13 — Words equal");
   declare
      A, B : Item;
   begin
      A := (Word, 0, [others => ' '], 3);
      A.Word (1 .. 3) := "cat";
      B := A;
      Check ("13.1 equal", Items_Equal (A, B));
      B.Word (3) := 'r';
      Check ("13.2 differ", not Items_Equal (A, B));
      Check ("13.3 cross", not Items_Equal (A, (Number, 1, [others => ' '], 0)));
   end;

   New_Line;
   Put_Line ("=== " & Pass_Count'Image & " passed, "
             & Fail_Count'Image & " failed ===");
   pragma Assert (Fail_Count = 0);
end Tests;

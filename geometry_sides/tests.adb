pragma Ada_2022;
with Ada.Text_IO; use Ada.Text_IO;
with Geometry_Sides; use Geometry_Sides;
procedure Tests is
   Pass_Count, Fail_Count : Natural := 0;
   procedure Check (Label : String; OK : Boolean) is
   begin
      if OK then Put_Line ("  PASS — " & Label); Pass_Count := Pass_Count + 1;
      else Put_Line ("  FAIL — " & Label); Fail_Count := Fail_Count + 1; end if;
   end Check;
begin

   Put_Line ("TEST 1 — Side_Count");
   Check ("1.1 tri", Side_Count (Triangle) = 3);
   Check ("1.2 sq", Side_Count (Square) = 4);
   Check ("1.3 hex", Side_Count (Hexagon) = 6);
   Put_Line ("TEST 2 — Score/Config");
   Check ("2.1 hit", Trial_Score (3, 3) = 1);
   Check ("2.2 miss", Trial_Score (3, 4) = 0);
   Check ("2.3 cfg", Config_Ok ((8, 1)));
   Put_Line ("TEST 3 — Bad cfg");
   Check ("3.1 bad", not Config_Ok ((Max_Trials + 1, 1)));
   Check ("3.2 seed0", Config_Ok ((4, 0)));
   Check ("3.3 key", Instruction_Key'Length > 5);
   Put_Line ("TEST 4 — Perfect");
   declare
      T : Trial_List; C : Natural; A : Answer_List; R : Session_Result;
   begin
      Build_Session ((8, 5), T, C);
      Check ("4.1 count", C = 8);
      Check ("4.2 sides", T (1).Sides = Side_Count (T (1).Kind));
      for I in 1 .. C loop A (I) := T (I).Sides; end loop;
      R := Score_Session ((8, 5), T, C, A);
      Check ("4.3 full", R.Score = 8);
   end;
   Put_Line ("TEST 5 — Wrong");
   declare
      T : Trial_List; C : Natural; A : Answer_List; R : Session_Result;
   begin
      Build_Session ((8, 5), T, C);
      for I in 1 .. C loop A (I) := T (I).Sides + 1; end loop;
      R := Score_Session ((8, 5), T, C, A);
      Check ("5.1 zero", R.Score = 0);
      Check ("5.2 max", R.Max_Score = 8);
      Check ("5.3 bound", R.Score <= R.Max_Score);
   end;
   Put_Line ("TEST 6 — Determinism");
   declare
      A, B : Trial_List; CA, CB : Natural;
   begin
      Build_Session ((6, 9), A, CA);
      Build_Session ((6, 9), B, CB);
      Check ("6.1", CA = CB);
      Check ("6.2", A (1).Kind = B (1).Kind);
      Check ("6.3", A (1).Sides = B (1).Sides);
   end;
   Put_Line ("TEST 7 — Seed0");
   declare
      T : Trial_List; C : Natural;
   begin
      Build_Session ((5, 0), T, C);
      Check ("7.1", C = 5);
      Check ("7.2", Config_Ok ((5, 0)));
      Check ("7.3", T (1).Sides = Side_Count (T (1).Kind));
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
   Check ("9.3", Instruction_Key (1 .. 14) = "geometry_sides");
   Put_Line ("TEST 10 — Partial");
   declare
      T : Trial_List; C : Natural; A : Answer_List; R : Session_Result;
   begin
      Build_Session ((8, 5), T, C);
      for I in 1 .. C loop
         if I mod 2 = 0 then A (I) := T (I).Sides; else A (I) := 99; end if;
      end loop;
      R := Score_Session ((8, 5), T, C, A);
      Check ("10.1", R.Score <= C);
      Check ("10.2", R.Max_Score = C);
      Check ("10.3", R.Trials_Run = C);
   end;
   Put_Line ("TEST 11 — Pentagon");
   Check ("11.1", Side_Count (Pentagon) = 5);
   Check ("11.2", Trial_Score (5, 5) = 1);
   Check ("11.3", Trial_Score (5, 6) = 0);
   Put_Line ("TEST 12 — Again");
   declare
      T : Trial_List; C : Natural;
   begin
      Build_Session ((4, 2), T, C);
      Check ("12.1", C = 4);
      Check ("12.2", T (1).Sides in 3 .. 6);
      Check ("12.3", Config_Ok ((4, 2)));
   end;
   Put_Line ("TEST 13 — Full");
   declare
      T : Trial_List; C : Natural; A : Answer_List; R : Session_Result;
   begin
      Build_Session ((8, 5), T, C);
      for I in 1 .. C loop A (I) := T (I).Sides; end loop;
      R := Score_Session ((8, 5), T, C, A);
      Check ("13.1", R.Score = 8);
      Check ("13.2", R.Score = R.Max_Score);
      Check ("13.3", R.Trials_Run = 8);
   end;

   New_Line;
   Put_Line ("=== " & Pass_Count'Image & " passed, " & Fail_Count'Image & " failed ===");
   pragma Assert (Fail_Count = 0);
end Tests;

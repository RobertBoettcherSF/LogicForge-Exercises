pragma Ada_2022;
with Ada.Text_IO; use Ada.Text_IO;
with Category_Decide; use Category_Decide;

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
   Check ("1.1 hit", Trial_Score (Animal, Animal) = 1);
   Check ("1.2 miss", Trial_Score (Animal, Plant) = 0);
   Check ("1.3 place", Trial_Score (Place, Place) = 1);

   Put_Line ("TEST 2 — Config_Ok");
   Check ("2.1 valid", Config_Ok ((8, 1)));
   Check ("2.2 bad", not Config_Ok ((Max_Trials + 1, 1)));
   Check ("2.3 seed0", Config_Ok ((4, 0)));

   Put_Line ("TEST 3 — Build");
   declare
      T : Trial_List; C : Natural;
   begin
      Build_Session ((8, 5), T, C);
      Check ("3.1 count", C = 8);
      Check ("3.2 len", T (1).Len >= 3);
      Check ("3.3 letter", T (1).Label (1) in 'a' .. 'z');
   end;

   Put_Line ("TEST 4 — Perfect");
   declare
      T : Trial_List; C : Natural; A : Answer_List; R : Session_Result;
   begin
      Build_Session ((8, 5), T, C);
      for I in 1 .. C loop A (I) := T (I).Expected; end loop;
      R := Score_Session ((8, 5), T, C, A);
      Check ("4.1 full", R.Score = R.Max_Score);
      Check ("4.2 max", R.Max_Score = 8);
      Check ("4.3 run", R.Trials_Run = 8);
   end;

   Put_Line ("TEST 5 — Wrong");
   declare
      T : Trial_List; C : Natural; A : Answer_List; R : Session_Result;
   begin
      Build_Session ((8, 5), T, C);
      for I in 1 .. C loop
         if T (I).Expected = Animal then A (I) := Plant;
         else A (I) := Animal; end if;
      end loop;
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
      Check ("6.1 count", CA = CB);
      Check ("6.2 cat", A (1).Expected = B (1).Expected);
      Check ("6.3 label", A (1).Label (1) = B (1).Label (1));
   end;

   Put_Line ("TEST 7 — Categories appear");
   declare
      T : Trial_List; C : Natural;
      Saw : array (Category) of Boolean := [others => False];
      N : Natural := 0;
   begin
      Build_Session ((24, 1), T, C);
      for I in 1 .. C loop Saw (T (I).Expected) := True; end loop;
      for K in Category loop
         if Saw (K) then N := N + 1; end if;
      end loop;
      Check ("7.1 multi", N >= 2);
      Check ("7.2 count", C = 24);
      Check ("7.3 ok", Config_Ok ((24, 1)));
   end;

   Put_Line ("TEST 8 — Label length");
   declare
      T : Trial_List; C : Natural; Ok : Boolean := True;
   begin
      Build_Session ((8, 5), T, C);
      for I in 1 .. C loop
         if T (I).Len < 3 then Ok := False; end if;
      end loop;
      Check ("8.1 lens", Ok);
      Check ("8.2 count", C = 8);
      Check ("8.3 first", T (1).Label (1) /= ' ');
   end;

   Put_Line ("TEST 9 — Invalid");
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
      Check ("9.1 raises", Raised);
      Check ("9.2 cfg", not Config_Ok (Bad));
      Check ("9.3 key", Instruction_Key'Length > 5);
   end;

   Put_Line ("TEST 10 — Keys");
   Check ("10.1 instruction", Instruction_Key'Length >= 10);
   Check ("10.2 prompt", Prompt_Key'Length >= 10);
   Check ("10.3 prefix", Instruction_Key (1 .. 15) = "category_decide");

   Put_Line ("TEST 11 — Seed 0");
   declare
      T : Trial_List; C : Natural;
   begin
      Build_Session ((5, 0), T, C);
      Check ("11.1 count", C = 5);
      Check ("11.2 ok", Config_Ok ((5, 0)));
      Check ("11.3 cat set", T (1).Expected = Animal
              or else T (1).Expected = Plant
              or else T (1).Expected = Object
              or else T (1).Expected = Place);
   end;

   Put_Line ("TEST 12 — Partial");
   declare
      T : Trial_List; C : Natural; A : Answer_List; R : Session_Result;
   begin
      Build_Session ((8, 5), T, C);
      for I in 1 .. C loop
         if I mod 2 = 0 then A (I) := T (I).Expected; else A (I) := Object; end if;
      end loop;
      R := Score_Session ((8, 5), T, C, A);
      Check ("12.1 mid", R.Score <= C);
      Check ("12.2 max", R.Max_Score = C);
      Check ("12.3 run", R.Trials_Run = C);
   end;

   Put_Line ("TEST 13 — All score variants");
   Check ("13.1 plant", Trial_Score (Plant, Plant) = 1);
   Check ("13.2 object miss", Trial_Score (Object, Place) = 0);
   Check ("13.3 place", Trial_Score (Place, Place) = 1);

   New_Line;
   Put_Line ("=== " & Pass_Count'Image & " passed, "
             & Fail_Count'Image & " failed ===");
   pragma Assert (Fail_Count = 0);
end Tests;

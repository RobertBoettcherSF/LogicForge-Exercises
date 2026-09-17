pragma Ada_2022;
with Ada.Text_IO; use Ada.Text_IO;
with Compass_Orient; use Compass_Orient;

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

   Put_Line ("TEST 1 — Apply_Turn");
   Check ("1.1 N right", Apply_Turn (N, Right) = E);
   Check ("1.2 E left", Apply_Turn (E, Left) = N);
   Check ("1.3 S around", Apply_Turn (S, Around) = N);

   Put_Line ("TEST 2 — Trial_Score");
   Check ("2.1 hit", Trial_Score (N, N) = 1);
   Check ("2.2 miss", Trial_Score (N, E) = 0);
   Check ("2.3 W", Trial_Score (W, W) = 1);

   Put_Line ("TEST 3 — Config_Ok");
   Check ("3.1 valid", Config_Ok ((10, 1)));
   Check ("3.2 bad", not Config_Ok ((Max_Trials + 1, 1)));
   Check ("3.3 seed0", Config_Ok ((4, 0)));

   Put_Line ("TEST 4 — Build");
   declare
      T : Trial_List; C : Natural;
   begin
      Build_Session ((10, 5), T, C);
      Check ("4.1 count", C = 10);
      Check ("4.2 result", T (1).Result = Apply_Turn (T (1).Facing, T (1).Action));
      Check ("4.3 ok", Config_Ok ((10, 5)));
   end;

   Put_Line ("TEST 5 — Perfect");
   declare
      T : Trial_List; C : Natural; A : Answer_List; R : Session_Result;
   begin
      Build_Session ((10, 5), T, C);
      for I in 1 .. C loop A (I) := T (I).Result; end loop;
      R := Score_Session ((10, 5), T, C, A);
      Check ("5.1 full", R.Score = R.Max_Score);
      Check ("5.2 max", R.Max_Score = 10);
      Check ("5.3 run", R.Trials_Run = 10);
   end;

   Put_Line ("TEST 6 — Wrong");
   declare
      T : Trial_List; C : Natural; A : Answer_List; R : Session_Result;
   begin
      Build_Session ((10, 5), T, C);
      for I in 1 .. C loop A (I) := Apply_Turn (T (I).Result, Right); end loop;
      R := Score_Session ((10, 5), T, C, A);
      Check ("6.1 zero", R.Score = 0);
      Check ("6.2 max", R.Max_Score = 10);
      Check ("6.3 bound", R.Score <= R.Max_Score);
   end;

   Put_Line ("TEST 7 — Determinism");
   declare
      A, B : Trial_List; CA, CB : Natural;
   begin
      Build_Session ((8, 9), A, CA);
      Build_Session ((8, 9), B, CB);
      Check ("7.1 count", CA = CB);
      Check ("7.2 facing", A (1).Facing = B (1).Facing);
      Check ("7.3 result", A (1).Result = B (1).Result);
   end;

   Put_Line ("TEST 8 — None turn");
   Check ("8.1 none", Apply_Turn (W, None) = W);
   Check ("8.2 left W", Apply_Turn (W, Left) = S);
   Check ("8.3 right W", Apply_Turn (W, Right) = N);

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
   Check ("10.3 prefix", Instruction_Key (1 .. 14) = "compass_orient");

   Put_Line ("TEST 11 — Seed 0");
   declare
      T : Trial_List; C : Natural;
   begin
      Build_Session ((5, 0), T, C);
      Check ("11.1 count", C = 5);
      Check ("11.2 ok", Config_Ok ((5, 0)));
      Check ("11.3 result", T (1).Result = Apply_Turn (T (1).Facing, T (1).Action));
   end;

   Put_Line ("TEST 12 — Partial");
   declare
      T : Trial_List; C : Natural; A : Answer_List; R : Session_Result;
   begin
      Build_Session ((10, 5), T, C);
      for I in 1 .. C loop
         if I mod 2 = 0 then A (I) := T (I).Result; else A (I) := N; end if;
      end loop;
      R := Score_Session ((10, 5), T, C, A);
      Check ("12.1 mid", R.Score <= C);
      Check ("12.2 max", R.Max_Score = C);
      Check ("12.3 run", R.Trials_Run = C);
   end;

   Put_Line ("TEST 13 — Cycle");
   Check ("13.1 N LLLL", Apply_Turn (Apply_Turn (Apply_Turn (Apply_Turn (N, Left), Left), Left), Left) = N);
   Check ("13.2 E RRRR", Apply_Turn (Apply_Turn (Apply_Turn (Apply_Turn (E, Right), Right), Right), Right) = E);
   Check ("13.3 S AA", Apply_Turn (Apply_Turn (S, Around), Around) = S);

   New_Line;
   Put_Line ("=== " & Pass_Count'Image & " passed, "
             & Fail_Count'Image & " failed ===");
   pragma Assert (Fail_Count = 0);
end Tests;

pragma Ada_2022;

package body Number_Grid is

   type U32 is mod 2 ** 32;

   procedure Next_Rand
     (State : in out U32; Value : out Natural; Limit : Positive)
   is
   begin
      --  Numerical Recipes LCG — deterministic educational PRNG.
      State := State * 1664525 + 1013904223;
      Value := Natural (State mod U32 (Limit)) + 1;
   end Next_Rand;

   function Compute_Row_Sum (G : Grid; Row : Positive) return Natural is
      S : Natural := 0;
   begin
      for C in G'Range (2) loop
         S := S + Natural (G (Row, C));
      end loop;
      return S;
   end Compute_Row_Sum;

   function Compute_Col_Sum (G : Grid; Col : Positive) return Natural is
      S : Natural := 0;
   begin
      for R in G'Range (1) loop
         S := S + Natural (G (R, Col));
      end loop;
      return S;
   end Compute_Col_Sum;

   function Row_Sums_Ok (G : Grid; Targets : Sum_Vector) return Boolean is
   begin
      for R in G'Range (1) loop
         if Compute_Row_Sum (G, R) /= Targets (R) then
            return False;
         end if;
      end loop;
      return True;
   end Row_Sums_Ok;

   function Col_Sums_Ok (G : Grid; Targets : Sum_Vector) return Boolean is
   begin
      for C in G'Range (2) loop
         if Compute_Col_Sum (G, C) /= Targets (C) then
            return False;
         end if;
      end loop;
      return True;
   end Col_Sums_Ok;

   function Solution_Ok
     (G : Grid; Row_Targets, Col_Targets : Sum_Vector) return Boolean is
   begin
      return Row_Sums_Ok (G, Row_Targets)
        and then Col_Sums_Ok (G, Col_Targets);
   end Solution_Ok;

   function Grid_Score
     (G : Grid; Row_Targets, Col_Targets : Sum_Vector) return Natural
   is
      Score : Natural := 0;
   begin
      for R in G'Range (1) loop
         if Compute_Row_Sum (G, R) = Row_Targets (R) then
            Score := Score + 1;
         end if;
      end loop;
      for C in G'Range (2) loop
         if Compute_Col_Sum (G, C) = Col_Targets (C) then
            Score := Score + 1;
         end if;
      end loop;
      return Score;
   end Grid_Score;

   function Slice_Grid (F : Fixed_Grid; N : Positive) return Grid is
      R : Grid (1 .. N, 1 .. N);
   begin
      for I in 1 .. N loop
         for J in 1 .. N loop
            R (I, J) := F (I, J);
         end loop;
      end loop;
      return R;
   end Slice_Grid;

   function Slice_Sums (F : Fixed_Sums; N : Positive) return Sum_Vector is
      R : Sum_Vector (1 .. N);
   begin
      for I in 1 .. N loop
         R (I) := F (I);
      end loop;
      return R;
   end Slice_Sums;

   procedure Fill_Puzzle
     (State : in out U32;
      N     : Positive;
      Max_F : Cell_Value;
      T     : out Trial)
   is
      V : Natural;
      G : Grid (1 .. N, 1 .. N);
   begin
      T.N := N;
      T.Solution := [others => [others => 0]];
      T.Row_Tgt := [others => 0];
      T.Col_Tgt := [others => 0];

      for I in 1 .. N loop
         for J in 1 .. N loop
            Next_Rand (State, V, Natural (Max_F) + 1);
            T.Solution (I, J) := Cell_Value (V - 1);
         end loop;
      end loop;

      G := Slice_Grid (T.Solution, N);
      for I in 1 .. N loop
         T.Row_Tgt (I) := Compute_Row_Sum (G, I);
         T.Col_Tgt (I) := Compute_Col_Sum (G, I);
      end loop;
   end Fill_Puzzle;

   procedure Build_Session
     (Cfg    : Session_Config;
      Trials : out Trial_List;
      Count  : out Natural)
   is
      State : U32;
   begin
      if not Config_Ok (Cfg) then
         raise Invalid_Argument;
      end if;

      if Cfg.Seed = 0 then
         State := 1;
      else
         State := U32 (Cfg.Seed);
      end if;

      Count := Cfg.Trial_Count;
      Trials := [others => <>];

      for I in 1 .. Count loop
         Fill_Puzzle (State, Cfg.N, Cfg.Max_Fill, Trials (I));
      end loop;
   end Build_Session;

   function Score_Session
     (Cfg     : Session_Config;
      Trials  : Trial_List;
      Count   : Natural;
      Answers : Answer_List) return Session_Result
   is
      R : Session_Result;
      N : constant Positive := Cfg.N;
   begin
      if not Config_Ok (Cfg) or else Count /= Cfg.Trial_Count then
         raise Invalid_Argument;
      end if;

      R.Config := Cfg;
      R.Trials_Run := Count;
      R.Max_Score := Count * 2 * N;
      R.Score := 0;

      for I in 1 .. Count loop
         R.Score :=
           R.Score
           + Grid_Score
               (Slice_Grid (Answers (I), N),
                Slice_Sums (Trials (I).Row_Tgt, N),
                Slice_Sums (Trials (I).Col_Tgt, N));
      end loop;
      return R;
   end Score_Session;

end Number_Grid;

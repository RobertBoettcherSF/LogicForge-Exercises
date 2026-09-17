pragma Ada_2022;

package body Path_Plan is

   type U32 is mod 2 ** 32;

   procedure Next_Rand
     (State : in out U32; Value : out Natural; Limit : Positive)
   is
   begin
      State := State * 1664525 + 1013904223;
      Value := Natural (State mod U32 (Limit)) + 1;
   end Next_Rand;

   function On_Map (M : Map; Pt : Point) return Boolean is
     (Pt.R in M'Range (1) and then Pt.C in M'Range (2));

   function Adjacent (A, B : Point) return Boolean is
     ((abs (Integer (A.R) - Integer (B.R))
       + abs (Integer (A.C) - Integer (B.C))) = 1);

   function Is_Valid_Path (M : Map; P : Path) return Boolean is
   begin
      for I in P'Range loop
         if not On_Map (M, P (I)) then
            return False;
         end if;
         if M (P (I).R, P (I).C) = Wall then
            return False;
         end if;
         if I > P'First and then not Adjacent (P (I - 1), P (I)) then
            return False;
         end if;
      end loop;
      return True;
   end Is_Valid_Path;

   function Reaches_Goal
     (P : Path; Start_Pt, Goal_Pt : Point) return Boolean is
   begin
      return P (P'First) = Start_Pt and then P (P'Last) = Goal_Pt;
   end Reaches_Goal;

   function Path_Score
     (M : Map; P : Path; Start_Pt, Goal_Pt : Point) return Natural is
   begin
      if not Is_Valid_Path (M, P) then
         return 0;
      elsif Reaches_Goal (P, Start_Pt, Goal_Pt) then
         return 2;
      else
         return 1;
      end if;
   end Path_Score;

   function Slice_Map (F : Fixed_Map; N : Positive) return Map is
      R : Map (1 .. N, 1 .. N);
   begin
      for I in 1 .. N loop
         for J in 1 .. N loop
            R (I, J) := F (I, J);
         end loop;
      end loop;
      return R;
   end Slice_Map;

   function Slice_Path (F : Fixed_Path; Len : Positive) return Path is
      R : Path (1 .. Len);
   begin
      for I in 1 .. Len loop
         R (I) := F (I);
      end loop;
      return R;
   end Slice_Path;

   procedure Fill_Trial
     (State : in out U32;
      N     : Positive;
      Rate  : Natural;
      T     : out Trial)
   is
      Roll : Natural;
      Len  : Natural := 0;
   begin
      T.N := N;
      T.Grid := [others => [others => Wall]];
      T.Path_Pts := [others => (1, 1)];
      T.Start_Pt := (1, 1);
      T.Goal_Pt := (N, N);

      --  Canonical L-shaped open corridor: down column 1, then across row N.
      for R in 1 .. N loop
         T.Grid (R, 1) := Open;
      end loop;
      for C in 1 .. N loop
         T.Grid (N, C) := Open;
      end loop;

      --  Sprinkle extra Open cells; keep corridor intact.
      for R in 1 .. N loop
         for C in 1 .. N loop
            if T.Grid (R, C) = Wall then
               Next_Rand (State, Roll, 100);
               if Roll > Rate then
                  T.Grid (R, C) := Open;
               end if;
            end if;
         end loop;
      end loop;

      --  Build the L-path into Path_Pts.
      for R in 1 .. N loop
         Len := Len + 1;
         T.Path_Pts (Len) := (R, 1);
      end loop;
      for C in 2 .. N loop
         Len := Len + 1;
         T.Path_Pts (Len) := (N, C);
      end loop;
      T.Len := Len;
   end Fill_Trial;

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
         Fill_Trial (State, Cfg.N, Cfg.Wall_Rate, Trials (I));
      end loop;
   end Build_Session;

   function Score_Session
     (Cfg     : Session_Config;
      Trials  : Trial_List;
      Count   : Natural;
      Answers : Answer_List) return Session_Result
   is
      R : Session_Result;
   begin
      if not Config_Ok (Cfg) or else Count /= Cfg.Trial_Count then
         raise Invalid_Argument;
      end if;

      R.Config := Cfg;
      R.Trials_Run := Count;
      R.Max_Score := Count * 2;
      R.Score := 0;

      for I in 1 .. Count loop
         declare
            Len : Positive := Answers (I).Len;
         begin
            if Len > Max_Path then
               Len := Max_Path;
            end if;
            R.Score :=
              R.Score
              + Path_Score
                  (Slice_Map (Trials (I).Grid, Trials (I).N),
                   Slice_Path (Answers (I).Path_Pts, Len),
                   Trials (I).Start_Pt,
                   Trials (I).Goal_Pt);
         end;
      end loop;
      return R;
   end Score_Session;

end Path_Plan;

pragma Ada_2022;

package body Spatial_Memory is

   type U32 is mod 2 ** 32;

   procedure Next_Rand (S : in out U32; V : out Natural; Limit : Positive) is
   begin
      S := S * 1664525 + 1013904223;
      V := Natural (S mod U32 (Limit)) + 1;
   end Next_Rand;

   function Contains (T : Trial; P : Point) return Boolean is
   begin
      for I in 1 .. T.Count loop
         if T.Marks (I).Row = P.Row and then T.Marks (I).Col = P.Col then
            return True;
         end if;
      end loop;
      return False;
   end Contains;

   function Exact_Set_Match (A, B : Trial) return Boolean is
   begin
      if A.Count /= B.Count then
         return False;
      end if;
      for I in 1 .. A.Count loop
         if not Contains (B, A.Marks (I)) then
            return False;
         end if;
      end loop;
      return True;
   end Exact_Set_Match;

   function Overlap_Count (A, B : Trial) return Natural is
      N : Natural := 0;
   begin
      for I in 1 .. A.Count loop
         if Contains (B, A.Marks (I)) then
            N := N + 1;
         end if;
      end loop;
      return N;
   end Overlap_Count;

   function Trial_Score (Target, Recall : Trial) return Natural is
   begin
      if Exact_Set_Match (Target, Recall) then
         return 1;
      end if;
      return 0;
   end Trial_Score;

   procedure Build_Session
     (Cfg : Session_Config; Trials : out Trial_List; Count : out Natural)
   is
      State : U32;
      R, C  : Natural;
      P     : Point;
      Guard : Natural;
      Partial : Trial;
   begin
      if not Config_Ok (Cfg) then
         raise Invalid_Argument;
      end if;
      State := U32 (if Cfg.Seed = 0 then 1 else Cfg.Seed);
      Count := Cfg.Trial_Count;
      Trials := [others => <>];
      for I in 1 .. Count loop
         Trials (I).Count := Cfg.Mark_Count;
         Trials (I).Marks := [others => <>];
         for J in 1 .. Cfg.Mark_Count loop
            Guard := 0;
            loop
               Next_Rand (State, R, Cfg.Grid_N);
               Next_Rand (State, C, Cfg.Grid_N);
               P := (R, C);
               Guard := Guard + 1;
               if J = 1 then
                  exit;
               end if;
               Partial := Trials (I);
               Partial.Count := J - 1;
               exit when not Contains (Partial, P) or else Guard > 100;
            end loop;
            Trials (I).Marks (J) := P;
         end loop;
      end loop;
   end Build_Session;

   function Score_Session
     (Cfg : Session_Config; Trials : Trial_List; Count : Natural;
      Answers : Answer_List) return Session_Result
   is
      R : Session_Result;
   begin
      if not Config_Ok (Cfg) or else Count /= Cfg.Trial_Count then
         raise Invalid_Argument;
      end if;
      R.Config := Cfg;
      R.Trials_Run := Count;
      R.Max_Score := Count;
      R.Score := 0;
      for I in 1 .. Count loop
         R.Score := R.Score + Trial_Score (Trials (I), Answers (I));
      end loop;
      return R;
   end Score_Session;

end Spatial_Memory;

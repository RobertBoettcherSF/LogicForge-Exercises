pragma Ada_2022;

package body Rule_Infer is

   type U32 is mod 2 ** 32;

   procedure Next_Rand
     (State : in out U32; Value : out Natural; Limit : Positive)
   is
   begin
      State := State * 1664525 + 1013904223;
      Value := Natural (State mod U32 (Limit)) + 1;
   end Next_Rand;

   function Obeys (R : Rule; X : Integer) return Boolean is
   begin
      case R.Kind is
         when Even =>
            return X rem 2 = 0;
         when Odd =>
            return X rem 2 /= 0;
         when At_Least =>
            return X >= R.Param;
         when Multiple_Of =>
            return R.Param /= 0 and then X rem R.Param = 0;
      end case;
   end Obeys;

   function Trial_Score
     (R : Rule; X : Integer; User_Says_Yes : Boolean) return Natural is
   begin
      if User_Says_Yes = Obeys (R, X) then
         return 1;
      end if;
      return 0;
   end Trial_Score;

   procedure Make_Rule (State : in out U32; R : out Rule) is
      Kind_V, Param_V : Natural;
   begin
      Next_Rand (State, Kind_V, 4);
      case Kind_V is
         when 1 =>
            R := (Even, 0);
         when 2 =>
            R := (Odd, 0);
         when 3 =>
            Next_Rand (State, Param_V, 10);
            R := (At_Least, Integer (Param_V));  -- 1..10
         when others =>
            Next_Rand (State, Param_V, 5);
            R := (Multiple_Of, Integer (Param_V) + 1);  -- 2..6
      end case;
   end Make_Rule;

   procedure Fill_Trial
     (State : in out U32;
      Ex_N  : Positive;
      Pr_N  : Positive;
      T     : out Trial)
   is
      V     : Natural;
      Cand  : Integer;
      Filled : Natural;
   begin
      Make_Rule (State, T.Hidden);
      T.Ex_Count := Ex_N;
      T.Pr_Count := Pr_N;
      T.Examples := [others => 0];
      T.Probes := [others => 0];
      T.Truth := [others => False];

      --  Positive examples that obey the rule.
      Filled := 0;
      while Filled < Ex_N loop
         Next_Rand (State, V, Value_Max + 1);
         Cand := Integer (V - 1);
         if Obeys (T.Hidden, Cand) then
            Filled := Filled + 1;
            T.Examples (Filled) := Cand;
         end if;
      end loop;

      --  Probes: mix of yes/no.
      for I in 1 .. Pr_N loop
         Next_Rand (State, V, Value_Max + 1);
         Cand := Integer (V - 1);
         T.Probes (I) := Cand;
         T.Truth (I) := Obeys (T.Hidden, Cand);
      end loop;
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
         Fill_Trial
           (State, Cfg.Example_Count, Cfg.Probe_Count, Trials (I));
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
      R.Max_Score := Count * Cfg.Probe_Count;
      R.Score := 0;

      for I in 1 .. Count loop
         for J in 1 .. Trials (I).Pr_Count loop
            R.Score :=
              R.Score
              + Trial_Score
                  (Trials (I).Hidden,
                   Trials (I).Probes (J),
                   Answers (I) (J));
         end loop;
      end loop;
      return R;
   end Score_Session;

end Rule_Infer;

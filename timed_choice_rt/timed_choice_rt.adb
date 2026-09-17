pragma Ada_2022;

package body Timed_Choice_RT is

   type U32 is mod 2 ** 32;

   procedure Next_Rand
     (State : in out U32; Value : out Natural; Limit : Positive)
   is
   begin
      State := State * 1664525 + 1013904223;
      Value := Natural (State mod U32 (Limit)) + 1;
   end Next_Rand;

   function Is_Correct (T : Trial) return Boolean is
     (T.Chosen_Option = T.Correct_Option);

   function Score_Band (T : Trial) return Band is
   begin
      if not Is_Correct (T) then
         return Wrong;
      elsif T.Latency_Ms <= Fast_Ms then
         return Correct_Fast;
      else
         return Correct_Slow;
      end if;
   end Score_Band;

   function Trial_Score (T : Trial) return Natural is
   begin
      case Score_Band (T) is
         when Wrong         => return 0;
         when Correct_Slow  => return 1;
         when Correct_Fast  => return 2;
      end case;
   end Trial_Score;

   procedure Build_Session
     (Cfg     : Session_Config;
      Prompts : out Prompt_List;
      Count   : out Natural)
   is
      State : U32;
      V     : Natural;
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
      Prompts := [others => <>];

      for I in 1 .. Count loop
         Next_Rand (State, V, 4);
         Prompts (I).Correct_Option := Option_Id (V);
      end loop;
   end Build_Session;

   function Score_Session
     (Cfg     : Session_Config;
      Prompts : Prompt_List;
      Count   : Natural;
      Answers : Answer_List) return Session_Result
   is
      R : Session_Result;
      T : Trial;
   begin
      if not Config_Ok (Cfg) or else Count /= Cfg.Trial_Count then
         raise Invalid_Argument;
      end if;

      R.Config := Cfg;
      R.Trials_Run := Count;
      R.Max_Score := Count * 2;
      R.Score := 0;

      for I in 1 .. Count loop
         T.Correct_Option := Prompts (I).Correct_Option;
         T.Chosen_Option := Answers (I).Chosen_Option;
         T.Latency_Ms := Answers (I).Latency_Ms;
         --  Honour per-session Fast_Limit by remapping Latency relative band.
         if T.Chosen_Option = T.Correct_Option then
            if T.Latency_Ms <= Cfg.Fast_Limit then
               R.Score := R.Score + 2;
            else
               R.Score := R.Score + 1;
            end if;
         end if;
      end loop;
      return R;
   end Score_Session;

end Timed_Choice_RT;

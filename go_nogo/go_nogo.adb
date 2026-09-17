pragma Ada_2022;
package body Go_Nogo is
   type U32 is mod 2 ** 32;
   procedure Next_Rand (S : in out U32; V : out Natural; Limit : Positive) is
   begin
      S := S * 1664525 + 1013904223;
      V := Natural (S mod U32 (Limit)) + 1;
   end Next_Rand;

   function Trial_Score (Kind : Stimulus_Kind; Responded : Boolean) return Natural is
   begin
      case Kind is
         when Go =>
            if Responded then return 1; else return 0; end if;
         when NoGo =>
            if not Responded then return 1; else return 0; end if;
      end case;
   end Trial_Score;

   procedure Build_Session
     (Cfg : Session_Config; Trials : out Trial_List; Count : out Natural)
   is
      State : U32; Roll : Natural;
   begin
      if not Config_Ok (Cfg) then raise Invalid_Argument; end if;
      State := U32 (if Cfg.Seed = 0 then 1 else Cfg.Seed);
      Count := Cfg.Trial_Count;
      Trials := [others => <>];
      for I in 1 .. Count loop
         Next_Rand (State, Roll, 100);
         if Roll <= Cfg.Go_Rate then
            Trials (I).Kind := Go;
         else
            Trials (I).Kind := NoGo;
         end if;
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
      R.Config := Cfg; R.Trials_Run := Count; R.Max_Score := Count;
      R.Score := 0; R.Hits := 0; R.Correct_Rejects := 0;
      R.Misses := 0; R.False_Alarms := 0;
      for I in 1 .. Count loop
         R.Score := R.Score + Trial_Score (Trials (I).Kind, Answers (I));
         case Trials (I).Kind is
            when Go =>
               if Answers (I) then R.Hits := R.Hits + 1;
               else R.Misses := R.Misses + 1; end if;
            when NoGo =>
               if Answers (I) then R.False_Alarms := R.False_Alarms + 1;
               else R.Correct_Rejects := R.Correct_Rejects + 1; end if;
         end case;
      end loop;
      return R;
   end Score_Session;
end Go_Nogo;

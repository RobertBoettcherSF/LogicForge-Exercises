pragma Ada_2022;

package body Timed_Choice_RT is

   function Trial_Score (T : Trial) return Natural is
   begin
      if not Is_Correct (T) then
         return 0;
      elsif T.Latency_Ms <= Fast_Ms then
         return 2;
      else
         return 1;
      end if;
   end Trial_Score;

end Timed_Choice_RT;

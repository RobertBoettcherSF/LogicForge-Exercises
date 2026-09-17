pragma Ada_2022;

package body Number_Series is

   type U32 is mod 2 ** 32;

   procedure Next_Rand (S : in out U32; V : out Natural; Limit : Positive) is
   begin
      S := S * 1664525 + 1013904223;
      V := Natural (S mod U32 (Limit)) + 1;
   end Next_Rand;

   function Trial_Score (Expected, Given : Integer) return Natural is
   begin
      if Expected = Given then
         return 1;
      end if;
      return 0;
   end Trial_Score;

   procedure Build_Session
     (Cfg : Session_Config; Trials : out Trial_List; Count : out Natural)
   is
      State : U32;
      Start, K, Kind_Roll, Cur : Natural;
   begin
      if not Config_Ok (Cfg) then
         raise Invalid_Argument;
      end if;
      State := U32 (if Cfg.Seed = 0 then 1 else Cfg.Seed);
      Count := Cfg.Trial_Count;
      Trials := [others => <>];
      for I in 1 .. Count loop
         Next_Rand (State, Start, 9);
         Next_Rand (State, K, 5);
         Next_Rand (State, Kind_Roll, 2);
         Trials (I).Len := Cfg.Prefix_Len;
         Trials (I).K := Integer (K);
         if Kind_Roll = 1 then
            Trials (I).Kind := Add_K;
         else
            Trials (I).Kind := Mul_K;
            if Trials (I).K <= 1 then
               Trials (I).K := 2;
            end if;
         end if;
         Cur := Start;
         Trials (I).Prefix := [others => 0];
         for J in 1 .. Cfg.Prefix_Len loop
            Trials (I).Prefix (J) := Integer (Cur);
            case Trials (I).Kind is
               when Add_K =>
                  Cur := Cur + Natural (Trials (I).K);
               when Mul_K =>
                  Cur := Cur * Natural (Trials (I).K);
            end case;
            if Cur > 10_000 then
               Cur := Cur rem 997 + 1;
            end if;
         end loop;
         Trials (I).Answer := Integer (Cur);
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
         R.Score := R.Score + Trial_Score (Trials (I).Answer, Answers (I));
      end loop;
      return R;
   end Score_Session;

end Number_Series;

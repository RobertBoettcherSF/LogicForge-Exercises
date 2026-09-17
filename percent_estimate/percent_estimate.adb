pragma Ada_2022;
package body Percent_Estimate is
   type U32 is mod 2 ** 32;
   procedure Next_Rand (S : in out U32; V : out Natural; Limit : Positive) is
   begin
      S := S * 1664525 + 1013904223;
      V := Natural (S mod U32 (Limit)) + 1;
   end Next_Rand;

   function Exact_Percent (Part : Natural; Whole : Positive) return Natural is
   begin
      return Natural ((Part * 100 + Whole / 2) / Whole);
   end Exact_Percent;

   function Trial_Score
     (Exact, Given : Natural; Tolerance : Natural) return Natural
   is
      Diff : Natural;
   begin
      if Exact >= Given then Diff := Exact - Given;
      else Diff := Given - Exact; end if;
      if Diff <= Tolerance then return 1; end if;
      return 0;
   end Trial_Score;

   procedure Build_Session
     (Cfg : Session_Config; Trials : out Trial_List; Count : out Natural)
   is
      State : U32; Whole, Part : Natural;
   begin
      if not Config_Ok (Cfg) then raise Invalid_Argument; end if;
      State := U32 (if Cfg.Seed = 0 then 1 else Cfg.Seed);
      Count := Cfg.Trial_Count;
      Trials := [others => <>];
      for I in 1 .. Count loop
         Next_Rand (State, Whole, 50);
         Whole := Whole + 10;  -- 11 .. 60
         Next_Rand (State, Part, Whole);
         Part := Part - 1;  -- 0 .. Whole-1
         Trials (I).Whole := Whole;
         Trials (I).Part := Part;
         Trials (I).Exact := Exact_Percent (Part, Whole);
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
      R.Config := Cfg; R.Trials_Run := Count; R.Max_Score := Count; R.Score := 0;
      for I in 1 .. Count loop
         R.Score := R.Score
           + Trial_Score (Trials (I).Exact, Answers (I), Cfg.Tolerance);
      end loop;
      return R;
   end Score_Session;
end Percent_Estimate;

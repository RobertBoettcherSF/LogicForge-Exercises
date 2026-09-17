pragma Ada_2022;
package body Balance_Scale is

   type U32 is mod 2 ** 32;
   procedure Next_Rand (S : in out U32; V : out Natural; Limit : Positive) is
   begin
      S := S * 1664525 + 1013904223;
      V := Natural (S mod U32 (Limit)) + 1;
   end Next_Rand;

   function Trial_Score (Expected, Given : Natural) return Natural is
   begin
      if Expected = Given then return 1; end if;
      return 0;
   end Trial_Score;
   procedure Build_Session
     (Cfg : Session_Config; Trials : out Trial_List; Count : out Natural)
   is
      State : U32;
   begin
      if not Config_Ok (Cfg) then raise Invalid_Argument; end if;
      State := U32 (if Cfg.Seed = 0 then 1 else Cfg.Seed);
      Count := Cfg.Trial_Count;
      Trials := [others => <>];
      for I in 1 .. Count loop
         declare
            LA, LB, RA, RB : Natural;
            L, R : Natural;
         begin
            Next_Rand (State, LA, 20);
            Next_Rand (State, LB, 20);
            Next_Rand (State, RA, 20);
            Next_Rand (State, RB, 20);
            Trials (I).Left_A := LA;
            Trials (I).Left_B := LB;
            Trials (I).Right_A := RA;
            Trials (I).Right_B := RB;
            L := LA + LB;
            R := RA + RB;
            if L > R then
               Trials (I).Verdict := 0;
            elsif L = R then
               Trials (I).Verdict := 1;
            else
               Trials (I).Verdict := 2;
            end if;
         end;
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
         R.Score := R.Score + Trial_Score (Trials (I).Verdict, Answers (I));
      end loop;
      return R;
   end Score_Session;
end Balance_Scale;

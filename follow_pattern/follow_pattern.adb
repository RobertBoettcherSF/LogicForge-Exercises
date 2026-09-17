pragma Ada_2022;
package body Follow_Pattern is

   type U32 is mod 2 ** 32;
   procedure Next_Rand (S : in out U32; V : out Natural; Limit : Positive) is
   begin
      S := S * 1664525 + 1013904223;
      V := Natural (S mod U32 (Limit)) + 1;
   end Next_Rand;

   function Trial_Score (Expected, Given : Character) return Natural is
   begin
      if Expected = Given then return 1; end if;
      return 0;
   end Trial_Score;
   procedure Build_Session
     (Cfg : Session_Config; Trials : out Trial_List; Count : out Natural)
   is
      State : U32; Start, Step, Cur : Natural;
      Ch : Character;
   begin
      if not Config_Ok (Cfg) then raise Invalid_Argument; end if;
      State := U32 (if Cfg.Seed = 0 then 1 else Cfg.Seed);
      Count := Cfg.Trial_Count;
      Trials := [others => <>];
      for I in 1 .. Count loop
         Next_Rand (State, Start, 20);
         Next_Rand (State, Step, 3);
         Cur := Start - 1;  -- 0..19
         Trials (I).Len := Cfg.Prefix_Len;
         Trials (I).Prefix := [others => 'A'];
         for J in 1 .. Cfg.Prefix_Len loop
            Ch := Character'Val (Character'Pos ('A') + (Cur rem 26));
            Trials (I).Prefix (J) := Ch;
            Cur := Cur + Step;
         end loop;
         Trials (I).Next_Letter :=
           Character'Val (Character'Pos ('A') + (Cur rem 26));
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
           + Trial_Score (Trials (I).Next_Letter, Answers (I));
      end loop;
      return R;
   end Score_Session;
end Follow_Pattern;

pragma Ada_2022;
package body Conflict_Label is
   type U32 is mod 2 ** 32;
   procedure Next_Rand (S : in out U32; V : out Natural; Limit : Positive) is
   begin
      S := S * 1664525 + 1013904223;
      V := Natural (S mod U32 (Limit)) + 1;
   end Next_Rand;

   Palette : constant array (1 .. 4) of Color_Id := [Red, Green, Blue, Yellow];

   function Trial_Score (Ink, Given : Color_Id) return Natural is
   begin
      if Ink = Given then return 1; end if;
      return 0;
   end Trial_Score;

   procedure Build_Session
     (Cfg : Session_Config; Trials : out Trial_List; Count : out Natural)
   is
      State : U32; W, Ink, Roll : Natural;
   begin
      if not Config_Ok (Cfg) then raise Invalid_Argument; end if;
      State := U32 (if Cfg.Seed = 0 then 1 else Cfg.Seed);
      Count := Cfg.Trial_Count;
      Trials := [others => <>];
      for I in 1 .. Count loop
         Next_Rand (State, W, 4);
         Trials (I).Word_Color := Palette (W);
         Next_Rand (State, Roll, 100);
         if Roll <= Cfg.Conflict_Rate then
            loop
               Next_Rand (State, Ink, 4);
               exit when Palette (Ink) /= Trials (I).Word_Color;
            end loop;
            Trials (I).Ink_Color := Palette (Ink);
            Trials (I).Conflict := True;
         else
            Trials (I).Ink_Color := Trials (I).Word_Color;
            Trials (I).Conflict := False;
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
      R.Config := Cfg; R.Trials_Run := Count; R.Max_Score := Count; R.Score := 0;
      for I in 1 .. Count loop
         R.Score := R.Score + Trial_Score (Trials (I).Ink_Color, Answers (I));
      end loop;
      return R;
   end Score_Session;
end Conflict_Label;

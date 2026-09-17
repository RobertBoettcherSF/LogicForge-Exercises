pragma Ada_2022;
package body Calendar_Offset is

   type U32 is mod 2 ** 32;
   procedure Next_Rand (S : in out U32; V : out Natural; Limit : Positive) is
   begin
      S := S * 1664525 + 1013904223;
      V := Natural (S mod U32 (Limit)) + 1;
   end Next_Rand;

   Ord : constant array (Weekday) of Natural :=
     [Mon => 0, Tue => 1, Wed => 2, Thu => 3, Fri => 4, Sat => 5, Sun => 6];
   Unord : constant array (0 .. 6) of Weekday :=
     [Mon, Tue, Wed, Thu, Fri, Sat, Sun];
   function Add_Days (D : Weekday; N : Natural) return Weekday is
   begin
      return Unord ((Ord (D) + (N rem 7)) rem 7);
   end Add_Days;
   function Trial_Score (Expected, Given : Weekday) return Natural is
   begin
      if Expected = Given then return 1; end if;
      return 0;
   end Trial_Score;
   procedure Build_Session
     (Cfg : Session_Config; Trials : out Trial_List; Count : out Natural)
   is
      State : U32; S, N : Natural;
   begin
      if not Config_Ok (Cfg) then raise Invalid_Argument; end if;
      State := U32 (if Cfg.Seed = 0 then 1 else Cfg.Seed);
      Count := Cfg.Trial_Count;
      Trials := [others => <>];
      for I in 1 .. Count loop
         Next_Rand (State, S, 7);
         Next_Rand (State, N, 14);
         Trials (I).Start := Unord (S - 1);
         Trials (I).Days := N - 1;
         Trials (I).Result := Add_Days (Trials (I).Start, Trials (I).Days);
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
         R.Score := R.Score + Trial_Score (Trials (I).Result, Answers (I));
      end loop;
      return R;
   end Score_Session;
end Calendar_Offset;

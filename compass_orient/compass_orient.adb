pragma Ada_2022;
package body Compass_Orient is
   type U32 is mod 2 ** 32;
   procedure Next_Rand (S : in out U32; V : out Natural; Limit : Positive) is
   begin
      S := S * 1664525 + 1013904223;
      V := Natural (S mod U32 (Limit)) + 1;
   end Next_Rand;

   function Apply_Turn (Facing : Cardinal; Action : Turn) return Cardinal is
      Idx : constant array (Cardinal) of Natural := [N => 0, E => 1, S => 2, W => 3];
      Ord : constant array (0 .. 3) of Cardinal := [N, E, S, W];
      I   : Natural := Idx (Facing);
   begin
      case Action is
         when None => null;
         when Right => I := (I + 1) rem 4;
         when Left => I := (I + 3) rem 4;
         when Around => I := (I + 2) rem 4;
      end case;
      return Ord (I);
   end Apply_Turn;

   function Trial_Score (Expected, Given : Cardinal) return Natural is
   begin
      if Expected = Given then return 1; end if;
      return 0;
   end Trial_Score;

   procedure Build_Session
     (Cfg : Session_Config; Trials : out Trial_List; Count : out Natural)
   is
      State : U32; F, A : Natural;
      Faces : constant array (1 .. 4) of Cardinal := [N, E, S, W];
      Acts  : constant array (1 .. 4) of Turn := [Left, Right, Around, None];
   begin
      if not Config_Ok (Cfg) then raise Invalid_Argument; end if;
      State := U32 (if Cfg.Seed = 0 then 1 else Cfg.Seed);
      Count := Cfg.Trial_Count;
      Trials := [others => <>];
      for I in 1 .. Count loop
         Next_Rand (State, F, 4);
         Next_Rand (State, A, 4);
         Trials (I).Facing := Faces (F);
         Trials (I).Action := Acts (A);
         Trials (I).Result := Apply_Turn (Trials (I).Facing, Trials (I).Action);
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
end Compass_Orient;

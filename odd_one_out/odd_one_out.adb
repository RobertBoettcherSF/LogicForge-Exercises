pragma Ada_2022;
package body Odd_One_Out is

   type U32 is mod 2 ** 32;
   procedure Next_Rand (S : in out U32; V : out Natural; Limit : Positive) is
   begin
      S := S * 1664525 + 1013904223;
      V := Natural (S mod U32 (Limit)) + 1;
   end Next_Rand;

   procedure Copy (Src : String; Dest : out Label; Len : out Positive) is
   begin
      Dest := [others => ' '];
      Len := Positive'Min (Src'Length, 8);
      for I in 1 .. Len loop
         Dest (I) := Src (Src'First + I - 1);
      end loop;
      while Len > 1 and then Dest (Len) = ' ' loop
         Len := Len - 1;
      end loop;
   end Copy;
   Same_Set : constant array (1 .. 4) of String (1 .. 8) :=
     ["apple   ", "pear    ", "grape   ", "plum    "];
   Odd_Set : constant array (1 .. 4) of String (1 .. 8) :=
     ["chair   ", "hammer  ", "cloud   ", "brick   "];
   function Trial_Score (Expected, Given : Option_Id) return Natural is
   begin
      if Expected = Given then return 1; end if;
      return 0;
   end Trial_Score;
   procedure Build_Session
     (Cfg : Session_Config; Trials : out Trial_List; Count : out Natural)
   is
      State : U32; Odd_Slot, Same_Pick, Odd_Pick : Natural;
      L : Positive;
   begin
      if not Config_Ok (Cfg) then raise Invalid_Argument; end if;
      State := U32 (if Cfg.Seed = 0 then 1 else Cfg.Seed);
      Count := Cfg.Trial_Count;
      Trials := [others => <>];
      for I in 1 .. Count loop
         Next_Rand (State, Odd_Slot, 4);
         Trials (I).Odd := Option_Id (Odd_Slot);
         Next_Rand (State, Same_Pick, 4);
         for O in Option_Id loop
            if O = Trials (I).Odd then
               Next_Rand (State, Odd_Pick, 4);
               Copy (Odd_Set (Odd_Pick), Trials (I).Options (O), L);
            else
               Copy (Same_Set (Same_Pick), Trials (I).Options (O), L);
            end if;
            Trials (I).Option_Lens (O) := L;
         end loop;
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
         R.Score := R.Score + Trial_Score (Trials (I).Odd, Answers (I));
      end loop;
      return R;
   end Score_Session;
end Odd_One_Out;

pragma Ada_2022;
package body Pair_Associate is

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
   Pairs : constant array (1 .. 8, 1 .. 2) of String (1 .. 8) :=
     [["sun     ", "moon    "],
      ["pen     ", "ink     "],
      ["key     ", "lock    "],
      ["bread   ", "butter  "],
      ["shoe    ", "sock    "],
      ["cup     ", "saucer  "],
      ["needle  ", "thread  "],
      ["salt    ", "pepper  "]];
   function Exact_Match (A, B : Label; Len : Positive) return Boolean is
   begin
      for I in 1 .. Len loop
         if A (I) /= B (I) then return False; end if;
      end loop;
      return True;
   end Exact_Match;
   function Trial_Score (Guess, Target : Label; Len : Positive) return Natural is
   begin
      if Exact_Match (Guess, Target, Len) then return 1; end if;
      return 0;
   end Trial_Score;
   procedure Build_Session
     (Cfg : Session_Config; Trials : out Trial_List; Count : out Natural)
   is
      State : U32; Pick : Natural;
   begin
      if not Config_Ok (Cfg) then raise Invalid_Argument; end if;
      State := U32 (if Cfg.Seed = 0 then 1 else Cfg.Seed);
      Count := Cfg.Trial_Count;
      Trials := [others => <>];
      for I in 1 .. Count loop
         Next_Rand (State, Pick, 8);
         Copy (Pairs (Pick, 1), Trials (I).Cue, Trials (I).Cue_Len);
         Copy (Pairs (Pick, 2), Trials (I).Target, Trials (I).Target_Len);
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
           + Trial_Score (Answers (I), Trials (I).Target, Trials (I).Target_Len);
      end loop;
      return R;
   end Score_Session;
end Pair_Associate;

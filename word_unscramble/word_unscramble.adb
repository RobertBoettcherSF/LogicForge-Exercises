pragma Ada_2022;
package body Word_Unscramble is
   type U32 is mod 2 ** 32;
   procedure Next_Rand (S : in out U32; V : out Natural; Limit : Positive) is
   begin
      S := S * 1664525 + 1013904223;
      V := Natural (S mod U32 (Limit)) + 1;
   end Next_Rand;

   -- Built-in clean-room word bank (short common English lemmas).
   Lexicon : constant array (1 .. 12) of String (1 .. 5) :=
     ["apple", "bread", "crane", "dream", "eagle", "flame",
      "grape", "house", "ivory", "jelly", "knife", "lemon"];

   function Exact_Match (A, B : Fixed_Word; Len : Positive) return Boolean is
   begin
      for I in 1 .. Len loop
         if A (I) /= B (I) then return False; end if;
      end loop;
      return True;
   end Exact_Match;

   function Trial_Score (Guess, Solution : Fixed_Word; Len : Positive) return Natural is
   begin
      if Exact_Match (Guess, Solution, Len) then return 1; end if;
      return 0;
   end Trial_Score;

   procedure Scramble (State : in out U32; W : in out Fixed_Word; Len : Positive) is
      I, J : Natural; Tmp : Character;
   begin
      for K in 1 .. Len * 3 loop
         Next_Rand (State, I, Len);
         Next_Rand (State, J, Len);
         Tmp := W (I); W (I) := W (J); W (J) := Tmp;
      end loop;
   end Scramble;

   procedure Build_Session
     (Cfg : Session_Config; Trials : out Trial_List; Count : out Natural)
   is
      State : U32; Pick : Natural; Src : String (1 .. 5);
   begin
      if not Config_Ok (Cfg) then raise Invalid_Argument; end if;
      State := U32 (if Cfg.Seed = 0 then 1 else Cfg.Seed);
      Count := Cfg.Trial_Count;
      Trials := [others => <>];
      for I in 1 .. Count loop
         Next_Rand (State, Pick, Lexicon'Length);
         Src := Lexicon (Pick);
         Trials (I).Len := 5;
         Trials (I).Solution := [others => ' '];
         Trials (I).Scrambled := [others => ' '];
         for J in 1 .. 5 loop
            Trials (I).Solution (J) := Src (J);
            Trials (I).Scrambled (J) := Src (J);
         end loop;
         Scramble (State, Trials (I).Scrambled, 5);
         -- ensure not identical (re-scramble once if needed)
         if Exact_Match (Trials (I).Scrambled, Trials (I).Solution, 5) then
            Scramble (State, Trials (I).Scrambled, 5);
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
         R.Score := R.Score
           + Trial_Score (Answers (I), Trials (I).Solution, Trials (I).Len);
      end loop;
      return R;
   end Score_Session;
end Word_Unscramble;

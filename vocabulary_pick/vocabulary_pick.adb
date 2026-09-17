pragma Ada_2022;
package body Vocabulary_Pick is
   type U32 is mod 2 ** 32;
   procedure Next_Rand (S : in out U32; V : out Natural; Limit : Positive) is
   begin
      S := S * 1664525 + 1013904223;
      V := Natural (S mod U32 (Limit)) + 1;
   end Next_Rand;

   procedure Copy_Str (Src : String; Dest : out Label; Len : out Positive) is
   begin
      Dest := [others => ' '];
      Len := Positive'Min (Src'Length, 12);
      for I in 1 .. Len loop
         Dest (I) := Src (Src'First + I - 1);
      end loop;
      -- trim trailing spaces for Len
      while Len > 1 and then Dest (Len) = ' ' loop
         Len := Len - 1;
      end loop;
   end Copy_Str;

   type Pair is record
      Cue, Target : String (1 .. 12);
   end record;
   Bank : constant array (1 .. 8) of Pair :=
     [("big         ", "large       "),
      ("small       ", "tiny        "),
      ("happy       ", "glad        "),
      ("sad         ", "unhappy     "),
      ("fast        ", "quick       "),
      ("slow        ", "sluggish    "),
      ("start       ", "begin       "),
      ("end         ", "finish      ")];
   Distractors : constant array (1 .. 6) of String (1 .. 12) :=
     ["table       ", "window      ", "river       ",
      "orange      ", "silver      ", "planet      "];

   function Trial_Score (Expected, Given : Option_Id) return Natural is
   begin
      if Expected = Given then return 1; end if;
      return 0;
   end Trial_Score;

   procedure Build_Session
     (Cfg : Session_Config; Trials : out Trial_List; Count : out Natural)
   is
      State : U32; Pick, Slot, D : Natural;
      Correct_Slot : Option_Id;
      L : Positive;
   begin
      if not Config_Ok (Cfg) then raise Invalid_Argument; end if;
      State := U32 (if Cfg.Seed = 0 then 1 else Cfg.Seed);
      Count := Cfg.Trial_Count;
      Trials := [others => <>];
      for I in 1 .. Count loop
         Next_Rand (State, Pick, Bank'Length);
         Copy_Str (Bank (Pick).Cue, Trials (I).Prompt, Trials (I).Prompt_Len);
         Next_Rand (State, Slot, 4);
         Correct_Slot := Option_Id (Slot);
         Trials (I).Correct := Correct_Slot;
         for O in Option_Id loop
            Trials (I).Options (O) := [others => ' '];
            Trials (I).Option_Lens (O) := 1;
         end loop;
         Copy_Str (Bank (Pick).Target, Trials (I).Options (Correct_Slot), L);
         Trials (I).Option_Lens (Correct_Slot) := L;
         for O in Option_Id loop
            if O /= Correct_Slot then
               Next_Rand (State, D, Distractors'Length);
               Copy_Str (Distractors (D), Trials (I).Options (O), L);
               Trials (I).Option_Lens (O) := L;
            end if;
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
         R.Score := R.Score + Trial_Score (Trials (I).Correct, Answers (I));
      end loop;
      return R;
   end Score_Session;
end Vocabulary_Pick;

pragma Ada_2022;
package body Category_Decide is
   type U32 is mod 2 ** 32;
   procedure Next_Rand (S : in out U32; V : out Natural; Limit : Positive) is
   begin
      S := S * 1664525 + 1013904223;
      V := Natural (S mod U32 (Limit)) + 1;
   end Next_Rand;

   type Entry_Rec is record
      Name : String (1 .. 10);
      Len  : Positive;
      Cat  : Category;
   end record;

   Lexicon : constant array (1 .. 12) of Entry_Rec :=
     [( "dog       ", 3, Animal),
      ( "cat       ", 3, Animal),
      ( "oak       ", 3, Plant),
      ( "rose      ", 4, Plant),
      ( "chair     ", 5, Object),
      ( "hammer    ", 6, Object),
      ( "paris     ", 5, Place),
      ( "river     ", 5, Place),
      ( "bird      ", 4, Animal),
      ( "moss      ", 4, Plant),
      ( "spoon     ", 5, Object),
      ( "harbor    ", 6, Place)];

   function Trial_Score (Expected, Given : Category) return Natural is
   begin
      if Expected = Given then return 1; end if;
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
         Next_Rand (State, Pick, Lexicon'Length);
         Trials (I).Label := Lexicon (Pick).Name;
         Trials (I).Len := Lexicon (Pick).Len;
         Trials (I).Expected := Lexicon (Pick).Cat;
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
         R.Score := R.Score + Trial_Score (Trials (I).Expected, Answers (I));
      end loop;
      return R;
   end Score_Session;
end Category_Decide;

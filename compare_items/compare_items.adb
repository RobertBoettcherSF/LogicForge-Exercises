pragma Ada_2022;
package body Compare_Items is
   type U32 is mod 2 ** 32;
   procedure Next_Rand (S : in out U32; V : out Natural; Limit : Positive) is
   begin
      S := S * 1664525 + 1013904223;
      V := Natural (S mod U32 (Limit)) + 1;
   end Next_Rand;

   Words : constant array (1 .. 8) of String (1 .. 4) :=
     ["cat ", "dog ", "tree", "moon", "book", "rain", "star", "wind"];

   function Items_Equal (A, B : Item) return Boolean is
   begin
      if A.Kind /= B.Kind then return False; end if;
      case A.Kind is
         when Number => return A.Num = B.Num;
         when Word =>
            if A.Len /= B.Len then return False; end if;
            for I in 1 .. A.Len loop
               if A.Word (I) /= B.Word (I) then return False; end if;
            end loop;
            return True;
      end case;
   end Items_Equal;

   function Trial_Score (Same, User_Says_Same : Boolean) return Natural is
   begin
      if Same = User_Says_Same then return 1; end if;
      return 0;
   end Trial_Score;

   procedure Fill_Item (State : in out U32; It : out Item) is
      Roll, Pick : Natural;
   begin
      Next_Rand (State, Roll, 2);
      if Roll = 1 then
         It.Kind := Number;
         Next_Rand (State, Pick, 20);
         It.Num := Integer (Pick);
         It.Len := 0;
         It.Word := [others => ' '];
      else
         It.Kind := Word;
         Next_Rand (State, Pick, Words'Length);
         It.Word := [others => ' '];
         It.Len := 4;
         for I in 1 .. 4 loop
            It.Word (I) := Words (Pick) (I);
         end loop;
         It.Num := 0;
      end if;
   end Fill_Item;

   procedure Build_Session
     (Cfg : Session_Config; Trials : out Trial_List; Count : out Natural)
   is
      State : U32; Roll : Natural; Want_Same : Boolean;
   begin
      if not Config_Ok (Cfg) then raise Invalid_Argument; end if;
      State := U32 (if Cfg.Seed = 0 then 1 else Cfg.Seed);
      Count := Cfg.Trial_Count;
      Trials := [others => <>];
      for I in 1 .. Count loop
         Fill_Item (State, Trials (I).Left);
         Next_Rand (State, Roll, 100);
         Want_Same := Roll <= Cfg.Same_Rate;
         if Want_Same then
            Trials (I).Right := Trials (I).Left;
         else
            loop
               Fill_Item (State, Trials (I).Right);
               exit when not Items_Equal (Trials (I).Left, Trials (I).Right);
            end loop;
         end if;
         Trials (I).Same := Items_Equal (Trials (I).Left, Trials (I).Right);
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
         R.Score := R.Score + Trial_Score (Trials (I).Same, Answers (I));
      end loop;
      return R;
   end Score_Session;
end Compare_Items;

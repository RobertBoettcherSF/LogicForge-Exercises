pragma Ada_2022;

package body Novelty_Check is

   type U32 is mod 2 ** 32;

   procedure Next_Rand
     (State : in out U32; Value : out Natural; Limit : Positive)
   is
   begin
      State := State * 1664525 + 1013904223;
      Value := Natural (State mod U32 (Limit)) + 1;
   end Next_Rand;

   function Trial_Score
     (Is_Repeat : Boolean; User_Says_Seen : Boolean) return Natural is
   begin
      if User_Says_Seen = Is_Repeat then
         return 1;
      end if;
      return 0;
   end Trial_Score;

   procedure Build_Session
     (Cfg : Session_Config; Trials : out Trial_List; Count : out Natural)
   is
      State : U32;
      Seen  : array (Symbol_Id) of Boolean := [others => False];
      Any_Seen : Boolean := False;
      Roll, Pick : Natural;
      Want_Repeat : Boolean;
      S : Symbol_Id;
      Tries : Natural;
   begin
      if not Config_Ok (Cfg) then
         raise Invalid_Argument;
      end if;
      if Cfg.Seed = 0 then
         State := 1;
      else
         State := U32 (Cfg.Seed);
      end if;
      Count := Cfg.Trial_Count;
      Trials := [others => <>];

      for I in 1 .. Count loop
         Next_Rand (State, Roll, 100);
         Want_Repeat := Any_Seen and then Roll <= Cfg.Repeat_Rate;

         if Want_Repeat then
            -- pick a previously shown symbol
            Tries := 0;
            loop
               Next_Rand (State, Pick, Cfg.Alphabet);
               S := Symbol_Id (Pick);
               Tries := Tries + 1;
               exit when Seen (S) or else Tries > 40;
            end loop;
            if not Seen (S) then
               -- fallback: first seen
               for J in 1 .. Symbol_Id (Cfg.Alphabet) loop
                  if Seen (J) then
                     S := J;
                     exit;
                  end if;
               end loop;
            end if;
            Trials (I).Shown := S;
            Trials (I).Is_Repeat := True;
         else
            Next_Rand (State, Pick, Cfg.Alphabet);
            S := Symbol_Id (Pick);
            Trials (I).Shown := S;
            Trials (I).Is_Repeat := Seen (S);
            Seen (S) := True;
            Any_Seen := True;
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
      R.Config := Cfg;
      R.Trials_Run := Count;
      R.Max_Score := Count;
      R.Score := 0;
      for I in 1 .. Count loop
         R.Score := R.Score
           + Trial_Score (Trials (I).Is_Repeat, Answers (I));
      end loop;
      return R;
   end Score_Session;

end Novelty_Check;

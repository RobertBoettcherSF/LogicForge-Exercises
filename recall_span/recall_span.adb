pragma Ada_2022;

package body Recall_Span is

   type U32 is mod 2 ** 32;

   procedure Next_Rand
     (State : in out U32; Value : out Natural; Limit : Positive)
   is
   begin
      State := State * 1664525 + 1013904223;
      Value := Natural (State mod U32 (Limit)) + 1;
   end Next_Rand;

   function Exact_Match (Presented, Recalled : Sequence) return Boolean is
   begin
      if Presented'Length /= Recalled'Length then
         return False;
      end if;
      for I in Presented'Range loop
         if Presented (I) /= Recalled (I) then
            return False;
         end if;
      end loop;
      return True;
   end Exact_Match;

   function Prefix_Span (Presented, Recalled : Sequence) return Natural is
      N : constant Natural :=
        Natural'Min (Presented'Length, Recalled'Length);
   begin
      for I in 1 .. N loop
         if Presented (I) /= Recalled (I) then
            return I - 1;
         end if;
      end loop;
      return N;
   end Prefix_Span;

   function Trial_Score (Presented, Recalled : Sequence) return Natural is
   begin
      if Exact_Match (Presented, Recalled) then
         return Presented'Length;
      end if;
      return Prefix_Span (Presented, Recalled);
   end Trial_Score;

   function Slice (T : Fixed_Sequence; Len : Natural) return Sequence is
   begin
      if Len = 0 then
         declare
            Empty : Sequence (1 .. 0);
         begin
            return Empty;
         end;
      end if;
      declare
         R : Sequence (1 .. Len);
      begin
         for I in 1 .. Len loop
            R (I) := T (I);
         end loop;
         return R;
      end;
   end Slice;

   procedure Build_Session
     (Cfg    : Session_Config;
      Trials : out Trial_List;
      Count  : out Natural)
   is
      State : U32;
      V     : Natural;
      Len   : Positive;
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
         Len := Cfg.Start_Len + I - 1;
         Trials (I).Len := Len;
         Trials (I).Presented := [others => 0];
         for J in 1 .. Len loop
            Next_Rand (State, V, 10);
            Trials (I).Presented (J) := Symbol (V - 1);
         end loop;
      end loop;
   end Build_Session;

   function Score_Session
     (Cfg     : Session_Config;
      Trials  : Trial_List;
      Count   : Natural;
      Answers : Answer_List) return Session_Result
   is
      R   : Session_Result;
      Max : Natural := 0;
   begin
      if not Config_Ok (Cfg) or else Count /= Cfg.Trial_Count then
         raise Invalid_Argument;
      end if;

      R.Config := Cfg;
      R.Trials_Run := Count;
      R.Score := 0;

      for I in 1 .. Count loop
         Max := Max + Trials (I).Len;
         R.Score :=
           R.Score
           + Trial_Score
               (Slice (Trials (I).Presented, Trials (I).Len),
                Slice (Answers (I).Presented, Answers (I).Len));
      end loop;
      R.Max_Score := Max;
      return R;
   end Score_Session;

end Recall_Span;

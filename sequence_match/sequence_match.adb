pragma Ada_2022;

package body Sequence_Match is

   type U32 is mod 2 ** 32;

   procedure Next_Rand
     (State : in out U32; Value : out Natural; Limit : Positive)
   is
   begin
      State := State * 1664525 + 1013904223;
      Value := Natural (State mod U32 (Limit)) + 1;
   end Next_Rand;

   function Is_Match
     (Target, Probe : Sequence; Mode : Match_Mode) return Boolean
   is
      Diffs : Natural := 0;
   begin
      if Target'Length /= Probe'Length then
         return False;
      end if;

      for I in Target'Range loop
         if Target (I) /= Probe (I) then
            Diffs := Diffs + 1;
            if Mode = Exact then
               return False;
            elsif Diffs > 1 then
               return False;
            end if;
         end if;
      end loop;

      case Mode is
         when Exact =>
            return True;
         when Allow_One_Substitution =>
            return Diffs <= 1;
      end case;
   end Is_Match;

   function Trial_Score
     (Target, Probe : Sequence;
      Mode          : Match_Mode;
      User_Says_Match : Boolean) return Natural
   is
      Actual : constant Boolean := Is_Match (Target, Probe, Mode);
   begin
      if User_Says_Match = Actual then
         return 1;
      else
         return 0;
      end if;
   end Trial_Score;

   function Slice (T : Fixed_Sequence; Len : Positive) return Sequence is
      R : Sequence (1 .. Len);
   begin
      for I in 1 .. Len loop
         R (I) := T (I);
      end loop;
      return R;
   end Slice;

   procedure Fill_Random_Seq
     (State : in out U32; Len : Positive; Out_S : out Fixed_Sequence)
   is
      V : Natural;
   begin
      Out_S := [others => 0];
      for I in 1 .. Len loop
         Next_Rand (State, V, 10);
         Out_S (I) := Symbol (V - 1);
      end loop;
   end Fill_Random_Seq;

   procedure Make_Mismatch
     (State  : in out U32;
      Mode   : Match_Mode;
      Len    : Positive;
      Target : Fixed_Sequence;
      Probe  : in out Fixed_Sequence)
   is
      Pos, New_V, Pos2 : Natural;
      S, S2            : Symbol;
   begin
      Probe := Target;
      Next_Rand (State, Pos, Len);
      Next_Rand (State, New_V, 10);
      S := Symbol (New_V - 1);
      if S = Target (Pos) then
         S := Symbol ((Natural (S) + 1) rem 10);
      end if;
      Probe (Pos) := S;

      if Mode = Allow_One_Substitution then
         Next_Rand (State, Pos2, Len);
         if Pos2 = Pos and then Len > 1 then
            Pos2 := (Pos rem Len) + 1;
         end if;
         S2 := Symbol ((Natural (Probe (Pos2)) + 3) rem 10);
         if S2 = Target (Pos2) then
            S2 := Symbol ((Natural (S2) + 1) rem 10);
         end if;
         Probe (Pos2) := S2;
      end if;
   end Make_Mismatch;

   procedure Build_Session
     (Cfg    : Session_Config;
      Trials : out Trial_List;
      Count  : out Natural)
   is
      State : U32 := U32 (if Cfg.Seed = 0 then 1 else Cfg.Seed);
      Roll  : Natural;
      Want_Match : Boolean;
   begin
      Count := Cfg.Trial_Count;
      Trials := [others => <>];

      for I in 1 .. Count loop
         Trials (I).Len := Cfg.Seq_Length;
         Fill_Random_Seq (State, Cfg.Seq_Length, Trials (I).Target);

         Next_Rand (State, Roll, 100);
         Want_Match := Roll <= Cfg.Match_Rate;

         if Want_Match then
            Trials (I).Probe := Trials (I).Target;
         else
            Make_Mismatch
              (State, Cfg.Mode, Cfg.Seq_Length,
               Trials (I).Target, Trials (I).Probe);
         end if;

         Trials (I).Is_Yes :=
           Is_Match
             (Slice (Trials (I).Target, Trials (I).Len),
              Slice (Trials (I).Probe, Trials (I).Len),
              Cfg.Mode);
      end loop;
   end Build_Session;

   function Score_Session
     (Cfg     : Session_Config;
      Trials  : Trial_List;
      Count   : Natural;
      Answers : Answer_List) return Session_Result
   is
      R : Session_Result;
   begin
      R.Config := Cfg;
      R.Trials_Run := Count;
      R.Max_Score := Count;
      R.Score := 0;
      for I in 1 .. Count loop
         R.Score :=
           R.Score
           + Trial_Score
               (Slice (Trials (I).Target, Trials (I).Len),
                Slice (Trials (I).Probe, Trials (I).Len),
                Cfg.Mode,
                Answers (I));
      end loop;
      return R;
   end Score_Session;

end Sequence_Match;

pragma Ada_2022;

with Ada.Text_IO; use Ada.Text_IO;
with Sequence_Match; use Sequence_Match;

procedure Tests is
   Pass : Natural := 0;
   Fail : Natural := 0;

   procedure Check (Cond : Boolean; Name : String) is
   begin
      if Cond then
         Pass := Pass + 1;
      else
         Fail := Fail + 1;
         Put_Line ("FAIL: " & Name);
      end if;
   end Check;

   T1 : constant Sequence := [1, 2, 3, 4];
   P1 : constant Sequence := [1, 2, 3, 4];
   P2 : constant Sequence := [1, 2, 9, 4];
   P3 : constant Sequence := [1, 9, 9, 4];
   P4 : constant Sequence := [1, 2, 3];

   Cfg : constant Session_Config :=
     (Mode => Exact, Trial_Count => 8, Seq_Length => 4,
      Seed => 7, Match_Rate => 50);
   Trials  : Trial_List;
   Count   : Natural;
   Answers : constant Answer_List := [others => False];
   Perfect : Answer_List;
   Res     : Session_Result;
begin
   Check (Is_Match (T1, P1, Exact), "exact equal");
   Check (not Is_Match (T1, P2, Exact), "exact rejects one sub");
   Check (Is_Match (T1, P2, Allow_One_Substitution), "one sub ok");
   Check (not Is_Match (T1, P3, Allow_One_Substitution), "two subs reject");
   Check (not Is_Match (T1, P4, Exact), "length mismatch");
   Check (Trial_Score (T1, P1, Exact, True) = 1, "score hit");
   Check (Trial_Score (T1, P2, Exact, True) = 0, "score miss");

   Build_Session (Cfg, Trials, Count);
   Check (Count = 8, "session count");
   for I in 1 .. Count loop
      Check
        (Trials (I).Is_Yes
         = Is_Match
             (Slice (Trials (I).Target, Trials (I).Len),
              Slice (Trials (I).Probe, Trials (I).Len),
              Cfg.Mode),
         "ground truth" & I'Image);
      Perfect (I) := Trials (I).Is_Yes;
   end loop;

   Res := Score_Session (Cfg, Trials, Count, Perfect);
   Check (Res.Score = Res.Max_Score, "perfect session");

   Res := Score_Session (Cfg, Trials, Count, Answers);
   Check (Res.Score <= Res.Max_Score, "zero-ish session bounded");

   --  Same seed => same first trial target (determinism)
   declare
      Trials2 : Trial_List;
      Count2  : Natural;
   begin
      Build_Session (Cfg, Trials2, Count2);
      Check
        (Trials (1).Target (1 .. 4) = Trials2 (1).Target (1 .. 4),
         "deterministic seed");
   end;

   Put_Line ("PASS=" & Pass'Image & " FAIL=" & Fail'Image);
   if Fail /= 0 then
      raise Program_Error;
   end if;
end Tests;

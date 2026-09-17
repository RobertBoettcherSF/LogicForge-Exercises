pragma Ada_2022;

with Ada.Text_IO;          use Ada.Text_IO;
with Ada.Integer_Text_IO;  use Ada.Integer_Text_IO;
with Sequence_Match;       use Sequence_Match;

--  Minimal CLI host for Sequence Match session loop.
procedure Play is

   function Image_Seq (T : Fixed_Sequence; Len : Positive) return String is
      Buf : String (1 .. Len * 2);
      P   : Natural := 0;
   begin
      for I in 1 .. Len loop
         P := P + 1;
         Buf (P) := Character'Val (Character'Pos ('0') + Natural (T (I)));
         if I < Len then
            P := P + 1;
            Buf (P) := ' ';
         end if;
      end loop;
      return Buf (1 .. P);
   end Image_Seq;

   Cfg     : constant Session_Config :=
     (Mode => Exact, Trial_Count => 5, Seq_Length => 4,
      Seed => 42, Match_Rate => 50);
   Trials  : Trial_List;
   Count   : Natural;
   Answers : Answer_List := [others => False];
   Line    : String (1 .. 80);
   Last    : Natural;
   Result  : Session_Result;
begin
   Put_Line ("[" & Instruction_Key & "]");
   Put_Line ("Watch the first sequence, then say if the second matches (y/n).");
   Put_Line ("Mode: Exact  Trials:" & Cfg.Trial_Count'Image);

   Build_Session (Cfg, Trials, Count);

   for I in 1 .. Count loop
      New_Line;
      Put_Line ("Trial" & I'Image);
      Put_Line ("Target: " & Image_Seq (Trials (I).Target, Trials (I).Len));
      Put_Line ("Probe:  " & Image_Seq (Trials (I).Probe, Trials (I).Len));
      Put ("[" & Prompt_Key & "] match? (y/n): ");
      Get_Line (Line, Last);
      if Last >= 1 and then (Line (1) = 'y' or else Line (1) = 'Y') then
         Answers (I) := True;
      else
         Answers (I) := False;
      end if;
   end loop;

   Result := Score_Session (Cfg, Trials, Count, Answers);
   New_Line;
   Put ("Score: ");
   Put (Result.Score, 0);
   Put (" / ");
   Put (Result.Max_Score, 0);
   New_Line;
end Play;

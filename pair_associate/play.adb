pragma Ada_2022;
with Ada.Text_IO; use Ada.Text_IO;
with Pair_Associate; use Pair_Associate;
procedure Play is

   Cfg : constant Session_Config := (5, 42);
   Trials : Trial_List; Count : Natural;
   Answers : Answer_List := [others => [others => ' ']];
   Line : String (1 .. 80); Last : Natural; Result : Session_Result;
begin
   Put_Line ("[" & Instruction_Key & "]");
   Put_Line ("Study pairs, then recall the associate for each cue.");
   Build_Session (Cfg, Trials, Count);
   Put_Line ("-- Study --");
   for I in 1 .. Count loop
      Put ("  ");
      for J in 1 .. Trials (I).Cue_Len loop Put (Trials (I).Cue (J)); end loop;
      Put (" -> ");
      for J in 1 .. Trials (I).Target_Len loop Put (Trials (I).Target (J)); end loop;
      New_Line;
   end loop;
   Put_Line ("Press Enter to recall...");
   Get_Line (Line, Last);
   for I in 1 .. Count loop
      New_Line;
      Put ("Cue: ");
      for J in 1 .. Trials (I).Cue_Len loop Put (Trials (I).Cue (J)); end loop;
      New_Line;
      Put ("[" & Prompt_Key & "]: ");
      Get_Line (Line, Last);
      Answers (I) := [others => ' '];
      for J in 1 .. Trials (I).Target_Len loop
         if J <= Last then Answers (I) (J) := Line (J); end if;
      end loop;
   end loop;
   Result := Score_Session (Cfg, Trials, Count, Answers);
   Put_Line ("Score:" & Result.Score'Image & " /" & Result.Max_Score'Image);

end Play;

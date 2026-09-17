pragma Ada_2022;
with Ada.Text_IO; use Ada.Text_IO;
with Follow_Pattern; use Follow_Pattern;
procedure Play is

   Cfg : constant Session_Config := (5, 4, 42);
   Trials : Trial_List; Count : Natural;
   Answers : Answer_List := [others => 'A'];
   Line : String (1 .. 80); Last : Natural; Result : Session_Result;
begin
   Put_Line ("[" & Instruction_Key & "]");
   Put_Line ("Give the next letter in the arithmetic sequence.");
   Build_Session (Cfg, Trials, Count);
   for I in 1 .. Count loop
      New_Line;
      Put ("Trial" & I'Image & ": ");
      for J in 1 .. Trials (I).Len loop Put (Trials (I).Prefix (J) & " "); end loop;
      New_Line;
      Put ("[" & Prompt_Key & "]: ");
      Get_Line (Line, Last);
      if Last >= 1 then Answers (I) := Line (1); end if;
   end loop;
   Result := Score_Session (Cfg, Trials, Count, Answers);
   Put_Line ("Score:" & Result.Score'Image & " /" & Result.Max_Score'Image);

end Play;

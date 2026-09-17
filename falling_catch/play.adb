pragma Ada_2022;
with Ada.Text_IO; use Ada.Text_IO;
with Falling_Catch; use Falling_Catch;
procedure Play is
   Cfg : constant Session_Config := (5, 42);
   Trials : Trial_List; Count : Natural;
   Answers : Answer_List := [others => 0];
   Line : String (1 .. 80); Last : Natural; Result : Session_Result;
begin
   Put_Line ("[" & Instruction_Key & "]");
   Put_Line ("Catch count = how many of 5 fall in zone (value<=3).");
   Build_Session (Cfg, Trials, Count);
   for I in 1 .. Count loop
      New_Line;
      Put_Line ("Trial" & I'Image & ": falls" & Trials (I).A'Image & Trials (I).B'Image & Trials (I).C'Image & Trials (I).D'Image & Trials (I).E'Image);
      Put ("[" & Prompt_Key & "]: ");
      Get_Line (Line, Last);
      begin Answers (I) := Natural'Value (Line (1 .. Last));
      exception when others => Answers (I) := 0; end;
   end loop;
   Result := Score_Session (Cfg, Trials, Count, Answers);
   Put_Line ("Score:" & Result.Score'Image & " /" & Result.Max_Score'Image);
end Play;

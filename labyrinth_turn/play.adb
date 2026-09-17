pragma Ada_2022;
with Ada.Text_IO; use Ada.Text_IO;
with Labyrinth_Turn; use Labyrinth_Turn;
procedure Play is
   Cfg : constant Session_Config := (5, 42);
   Trials : Trial_List; Count : Natural;
   Answers : Answer_List := [others => 0];
   Line : String (1 .. 80); Last : Natural; Result : Session_Result;
begin
   Put_Line ("[" & Instruction_Key & "]");
   Put_Line ("Turns needed = abs(facing-target) mod 4 (min turns 0..2).");
   Build_Session (Cfg, Trials, Count);
   for I in 1 .. Count loop
      New_Line;
      Put_Line ("Trial" & I'Image & ": face" & Trials (I).Facing'Image & " target" & Trials (I).Target'Image);
      Put ("[" & Prompt_Key & "]: ");
      Get_Line (Line, Last);
      begin Answers (I) := Natural'Value (Line (1 .. Last));
      exception when others => Answers (I) := 0; end;
   end loop;
   Result := Score_Session (Cfg, Trials, Count, Answers);
   Put_Line ("Score:" & Result.Score'Image & " /" & Result.Max_Score'Image);
end Play;

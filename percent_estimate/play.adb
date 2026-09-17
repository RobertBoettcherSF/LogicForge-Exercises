pragma Ada_2022;
with Ada.Text_IO; use Ada.Text_IO;
with Percent_Estimate; use Percent_Estimate;

procedure Play is

   Cfg : constant Session_Config := (5, 5, 42);
   Trials : Trial_List; Count : Natural;
   Answers : Answer_List := [others => 0];
   Line : String (1 .. 80); Last : Natural; Result : Session_Result;
begin
   Put_Line ("[" & Instruction_Key & "]");
   Put_Line ("Estimate percent (tolerance +/-5).");
   Build_Session (Cfg, Trials, Count);
   for I in 1 .. Count loop
      New_Line;
      Put_Line ("Trial" & I'Image & " Part=" & Trials (I).Part'Image
                & " of Whole=" & Trials (I).Whole'Image);
      Put ("[" & Prompt_Key & "]: ");
      Get_Line (Line, Last);
      begin
         Answers (I) := Natural'Value (Line (1 .. Last));
      exception
         when others => Answers (I) := 0;
      end;
   end loop;
   Result := Score_Session (Cfg, Trials, Count, Answers);
   Put_Line ("Score:" & Result.Score'Image & " /" & Result.Max_Score'Image);

end Play;

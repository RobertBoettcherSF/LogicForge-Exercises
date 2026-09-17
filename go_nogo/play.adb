pragma Ada_2022;
with Ada.Text_IO; use Ada.Text_IO;
with Go_Nogo; use Go_Nogo;

procedure Play is

   Cfg : constant Session_Config := (10, 70, 42);
   Trials : Trial_List;
   Count : Natural;
   Answers : Answer_List := [others => False];
   Line : String (1 .. 80);
   Last : Natural;
   Result : Session_Result;
begin
   Put_Line ("[" & Instruction_Key & "]");
   Put_Line ("GO = press y; NOGO = press n (withhold).");
   Build_Session (Cfg, Trials, Count);
   for I in 1 .. Count loop
      New_Line;
      Put_Line ("Trial" & I'Image & " stimulus: " & Trials (I).Kind'Image);
      Put ("[" & Prompt_Key & "] (y=respond / n=withhold): ");
      Get_Line (Line, Last);
      Answers (I) := Last >= 1 and then (Line (1) = 'y' or else Line (1) = 'Y');
   end loop;
   Result := Score_Session (Cfg, Trials, Count, Answers);
   Put_Line ("Score:" & Result.Score'Image & " /" & Result.Max_Score'Image);
   Put_Line ("Hits:" & Result.Hits'Image
             & " CR:" & Result.Correct_Rejects'Image
             & " Miss:" & Result.Misses'Image
             & " FA:" & Result.False_Alarms'Image);

end Play;

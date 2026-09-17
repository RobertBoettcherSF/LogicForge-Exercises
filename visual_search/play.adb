pragma Ada_2022;
with Ada.Text_IO; use Ada.Text_IO;
with Visual_Search; use Visual_Search;

procedure Play is

   Cfg : constant Session_Config := (5, 3, 60, 42);
   Trials : Trial_List;
   Count : Natural;
   Answers : Answer_List := [others => False];
   Line : String (1 .. 80);
   Last : Natural;
   Result : Session_Result;
begin
   Put_Line ("[" & Instruction_Key & "]");
   Put_Line ("Is the target present in the grid? y/n");
   Build_Session (Cfg, Trials, Count);
   for I in 1 .. Count loop
      New_Line;
      Put_Line ("Trial" & I'Image & " target:" & Trials (I).Target'Image);
      for R in 1 .. Cfg.Size loop
         for C in 1 .. Cfg.Size loop
            Put (Trials (I).Cells (R, C)'Image);
         end loop;
         New_Line;
      end loop;
      Put ("[" & Prompt_Key & "] (y/n): ");
      Get_Line (Line, Last);
      Answers (I) := Last >= 1 and then (Line (1) = 'y' or else Line (1) = 'Y');
   end loop;
   Result := Score_Session (Cfg, Trials, Count, Answers);
   Put_Line ("Score:" & Result.Score'Image & " /" & Result.Max_Score'Image);

end Play;

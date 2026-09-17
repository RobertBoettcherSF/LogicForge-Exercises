pragma Ada_2022;
with Ada.Text_IO; use Ada.Text_IO;
with Scan_Count; use Scan_Count;
procedure Play is

   Cfg : constant Session_Config := (5, 10, 42);
   Trials : Trial_List; Count : Natural;
   Answers : Answer_List := [others => 0];
   Line : String (1 .. 80); Last : Natural; Result : Session_Result;
begin
   Put_Line ("[" & Instruction_Key & "]");
   Put_Line ("Count how many times the target appears.");
   Build_Session (Cfg, Trials, Count);
   for I in 1 .. Count loop
      New_Line;
      Put ("Trial" & I'Image & " Target:" & Trials (I).Target'Image & " Row:");
      for J in 1 .. Trials (I).Len loop
         Put (Trials (I).Cells (J)'Image);
      end loop;
      New_Line;
      Put ("[" & Prompt_Key & "]: ");
      Get_Line (Line, Last);
      begin Answers (I) := Natural'Value (Line (1 .. Last));
      exception when others => Answers (I) := 0; end;
   end loop;
   Result := Score_Session (Cfg, Trials, Count, Answers);
   Put_Line ("Score:" & Result.Score'Image & " /" & Result.Max_Score'Image);

end Play;

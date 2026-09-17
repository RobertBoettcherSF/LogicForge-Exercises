pragma Ada_2022;
with Ada.Text_IO; use Ada.Text_IO;
with Novelty_Check; use Novelty_Check;

procedure Play is
   Cfg : constant Session_Config :=
     (Trial_Count => 8, Alphabet => 5, Repeat_Rate => 45, Seed => 42);
   Trials : Trial_List;
   Count  : Natural;
   Answers : Answer_List := [others => False];
   Line : String (1 .. 80);
   Last : Natural;
   Result : Session_Result;
begin
   Put_Line ("[" & Instruction_Key & "]");
   Put_Line ("Was this symbol shown earlier? y = seen, n = new.");
   Build_Session (Cfg, Trials, Count);
   for I in 1 .. Count loop
      New_Line;
      Put_Line ("Trial" & I'Image & "  Symbol:" & Trials (I).Shown'Image);
      Put ("[" & Prompt_Key & "] (y/n): ");
      Get_Line (Line, Last);
      Answers (I) := Last >= 1 and then (Line (1) = 'y' or else Line (1) = 'Y');
   end loop;
   Result := Score_Session (Cfg, Trials, Count, Answers);
   New_Line;
   Put_Line ("Score:" & Result.Score'Image & " /" & Result.Max_Score'Image);
end Play;

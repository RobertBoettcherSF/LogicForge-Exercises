pragma Ada_2022;
with Ada.Text_IO; use Ada.Text_IO;
with Odd_One_Out; use Odd_One_Out;
procedure Play is

   Cfg : constant Session_Config := (5, 42);
   Trials : Trial_List; Count : Natural;
   Answers : Answer_List := [others => 1];
   Line : String (1 .. 80); Last : Natural; Result : Session_Result;
begin
   Put_Line ("[" & Instruction_Key & "]");
   Put_Line ("Which option is the odd one out? (1-4)");
   Build_Session (Cfg, Trials, Count);
   for I in 1 .. Count loop
      New_Line;
      Put_Line ("Trial" & I'Image);
      for O in Option_Id loop
         Put (O'Image & ") ");
         for J in 1 .. Trials (I).Option_Lens (O) loop
            Put (Trials (I).Options (O) (J));
         end loop;
         New_Line;
      end loop;
      Put ("[" & Prompt_Key & "]: ");
      Get_Line (Line, Last);
      if Last >= 1 and then Line (1) in '1' .. '4' then
         Answers (I) := Option_Id (Character'Pos (Line (1)) - Character'Pos ('0'));
      end if;
   end loop;
   Result := Score_Session (Cfg, Trials, Count, Answers);
   Put_Line ("Score:" & Result.Score'Image & " /" & Result.Max_Score'Image);

end Play;

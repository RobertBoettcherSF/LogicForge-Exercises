pragma Ada_2022;
with Ada.Text_IO; use Ada.Text_IO;
with Word_Unscramble; use Word_Unscramble;

procedure Play is

   Cfg : constant Session_Config := (5, 42);
   Trials : Trial_List;
   Count : Natural;
   Answers : Answer_List := [others => [others => ' ']];
   Line : String (1 .. 80);
   Last : Natural;
   Result : Session_Result;
begin
   Put_Line ("[" & Instruction_Key & "]");
   Put_Line ("Unscramble each letter set into a word.");
   Build_Session (Cfg, Trials, Count);
   for I in 1 .. Count loop
      New_Line;
      Put ("Trial" & I'Image & " scrambled: ");
      for J in 1 .. Trials (I).Len loop
         Put (Trials (I).Scrambled (J));
      end loop;
      New_Line;
      Put ("[" & Prompt_Key & "]: ");
      Get_Line (Line, Last);
      Answers (I) := [others => ' '];
      for J in 1 .. Trials (I).Len loop
         if J <= Last then
            Answers (I) (J) := Line (J);
         end if;
      end loop;
   end loop;
   Result := Score_Session (Cfg, Trials, Count, Answers);
   Put_Line ("Score:" & Result.Score'Image & " /" & Result.Max_Score'Image);

end Play;

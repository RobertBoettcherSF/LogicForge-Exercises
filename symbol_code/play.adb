pragma Ada_2022;
with Ada.Text_IO; use Ada.Text_IO;
with Symbol_Code; use Symbol_Code;

procedure Play is

   Cfg : constant Session_Config := (8, 42);
   Trials : Trial_List; Count : Natural;
   Answers : Answer_List := [others => 'A'];
   Line : String (1 .. 80); Last : Natural; Result : Session_Result;
begin
   Put_Line ("[" & Instruction_Key & "]");
   Put_Line ("Map digit 0..9 to letters A..J.");
   Build_Session (Cfg, Trials, Count);
   for I in 1 .. Count loop
      New_Line;
      Put_Line ("Trial" & I'Image & " Digit:" & Trials (I).Shown'Image);
      Put ("[" & Prompt_Key & "] (A-J): ");
      Get_Line (Line, Last);
      if Last >= 1 then Answers (I) := Line (1); end if;
   end loop;
   Result := Score_Session (Cfg, Trials, Count, Answers);
   Put_Line ("Score:" & Result.Score'Image & " /" & Result.Max_Score'Image);

end Play;

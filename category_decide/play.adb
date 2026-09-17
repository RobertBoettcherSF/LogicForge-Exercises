pragma Ada_2022;
with Ada.Text_IO; use Ada.Text_IO;
with Category_Decide; use Category_Decide;

procedure Play is

   Cfg : constant Session_Config := (6, 42);
   Trials : Trial_List; Count : Natural;
   Answers : Answer_List := [others => Animal];
   Line : String (1 .. 80); Last : Natural; Result : Session_Result;
begin
   Put_Line ("[" & Instruction_Key & "]");
   Put_Line ("Classify each word: A=animal P=plant O=object L=place");
   Build_Session (Cfg, Trials, Count);
   for I in 1 .. Count loop
      New_Line;
      Put_Line ("Trial" & I'Image & " Word: "
                & Trials (I).Label (1 .. Trials (I).Len));
      Put ("[" & Prompt_Key & "] (A/P/O/L): ");
      Get_Line (Line, Last);
      if Last >= 1 then
         case Line (1) is
            when 'A' | 'a' => Answers (I) := Animal;
            when 'P' | 'p' => Answers (I) := Plant;
            when 'O' | 'o' => Answers (I) := Object;
            when 'L' | 'l' => Answers (I) := Place;
            when others => Answers (I) := Animal;
         end case;
      end if;
   end loop;
   Result := Score_Session (Cfg, Trials, Count, Answers);
   Put_Line ("Score:" & Result.Score'Image & " /" & Result.Max_Score'Image);

end Play;

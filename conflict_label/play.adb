pragma Ada_2022;
with Ada.Text_IO; use Ada.Text_IO;
with Conflict_Label; use Conflict_Label;

procedure Play is

   Cfg : constant Session_Config := (6, 60, 42);
   Trials : Trial_List; Count : Natural;
   Answers : Answer_List := [others => Red];
   Line : String (1 .. 80); Last : Natural; Result : Session_Result;
begin
   Put_Line ("[" & Instruction_Key & "]");
   Put_Line ("Report the INK color (R/G/B/Y), not the word meaning.");
   Build_Session (Cfg, Trials, Count);
   for I in 1 .. Count loop
      New_Line;
      Put_Line ("Trial" & I'Image & " WORD=" & Trials (I).Word_Color'Image
                & " (ink hidden in CLI — answer is Ink="
                & Trials (I).Ink_Color'Image & " for demo)");
      Put ("[" & Prompt_Key & "] (R/G/B/Y): ");
      Get_Line (Line, Last);
      if Last >= 1 then
         case Line (1) is
            when 'R' | 'r' => Answers (I) := Red;
            when 'G' | 'g' => Answers (I) := Green;
            when 'B' | 'b' => Answers (I) := Blue;
            when 'Y' | 'y' => Answers (I) := Yellow;
            when others => Answers (I) := Red;
         end case;
      end if;
   end loop;
   Result := Score_Session (Cfg, Trials, Count, Answers);
   Put_Line ("Score:" & Result.Score'Image & " /" & Result.Max_Score'Image);

end Play;

pragma Ada_2022;
with Ada.Text_IO; use Ada.Text_IO;
with Compass_Orient; use Compass_Orient;

procedure Play is

   Cfg : constant Session_Config := (6, 42);
   Trials : Trial_List; Count : Natural;
   Answers : Answer_List := [others => N];
   Line : String (1 .. 80); Last : Natural; Result : Session_Result;
begin
   Put_Line ("[" & Instruction_Key & "]");
   Put_Line ("Given facing + turn, report new facing (N/E/S/W).");
   Build_Session (Cfg, Trials, Count);
   for I in 1 .. Count loop
      New_Line;
      Put_Line ("Trial" & I'Image & " Facing=" & Trials (I).Facing'Image
                & " Turn=" & Trials (I).Action'Image);
      Put ("[" & Prompt_Key & "] (N/E/S/W): ");
      Get_Line (Line, Last);
      if Last >= 1 then
         case Line (1) is
            when 'N' | 'n' => Answers (I) := N;
            when 'E' | 'e' => Answers (I) := E;
            when 'S' | 's' => Answers (I) := S;
            when 'W' | 'w' => Answers (I) := W;
            when others => Answers (I) := N;
         end case;
      end if;
   end loop;
   Result := Score_Session (Cfg, Trials, Count, Answers);
   Put_Line ("Score:" & Result.Score'Image & " /" & Result.Max_Score'Image);

end Play;

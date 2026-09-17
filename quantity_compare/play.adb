pragma Ada_2022;
with Ada.Text_IO; use Ada.Text_IO;
with Quantity_Compare; use Quantity_Compare;
procedure Play is

   Cfg : constant Session_Config := (6, 42);
   Trials : Trial_List; Count : Natural;
   Answers : Answer_List := [others => Equal];
   Line : String (1 .. 80); Last : Natural; Result : Session_Result;
begin
   Put_Line ("[" & Instruction_Key & "]");
   Put_Line ("Which is larger? L=left R=right E=equal");
   Build_Session (Cfg, Trials, Count);
   for I in 1 .. Count loop
      New_Line;
      Put_Line ("Trial" & I'Image & " Left=" & Trials (I).Left'Image
                & " Right=" & Trials (I).Right'Image);
      Put ("[" & Prompt_Key & "] (L/R/E): ");
      Get_Line (Line, Last);
      if Last >= 1 then
         case Line (1) is
            when 'L' | 'l' => Answers (I) := Left;
            when 'R' | 'r' => Answers (I) := Right;
            when others => Answers (I) := Equal;
         end case;
      end if;
   end loop;
   Result := Score_Session (Cfg, Trials, Count, Answers);
   Put_Line ("Score:" & Result.Score'Image & " /" & Result.Max_Score'Image);

end Play;

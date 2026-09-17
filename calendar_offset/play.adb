pragma Ada_2022;
with Ada.Text_IO; use Ada.Text_IO;
with Calendar_Offset; use Calendar_Offset;
procedure Play is

   Cfg : constant Session_Config := (5, 42);
   Trials : Trial_List; Count : Natural;
   Answers : Answer_List := [others => Mon];
   Line : String (1 .. 80); Last : Natural; Result : Session_Result;
begin
   Put_Line ("[" & Instruction_Key & "]");
   Put_Line ("Start day + N days → which weekday? (Mon..Sun or 1-7)");
   Build_Session (Cfg, Trials, Count);
   for I in 1 .. Count loop
      New_Line;
      Put_Line ("Trial" & I'Image & " " & Trials (I).Start'Image
                & " +" & Trials (I).Days'Image);
      Put ("[" & Prompt_Key & "]: ");
      Get_Line (Line, Last);
      if Last >= 3 then
         declare
            S : constant String := Line (1 .. Last);
         begin
            if S (1 .. 3) = "Mon" or else S (1 .. 3) = "mon" then Answers (I) := Mon;
            elsif S (1 .. 3) = "Tue" or else S (1 .. 3) = "tue" then Answers (I) := Tue;
            elsif S (1 .. 3) = "Wed" or else S (1 .. 3) = "wed" then Answers (I) := Wed;
            elsif S (1 .. 3) = "Thu" or else S (1 .. 3) = "thu" then Answers (I) := Thu;
            elsif S (1 .. 3) = "Fri" or else S (1 .. 3) = "fri" then Answers (I) := Fri;
            elsif S (1 .. 3) = "Sat" or else S (1 .. 3) = "sat" then Answers (I) := Sat;
            else Answers (I) := Sun;
            end if;
         end;
      end if;
   end loop;
   Result := Score_Session (Cfg, Trials, Count, Answers);
   Put_Line ("Score:" & Result.Score'Image & " /" & Result.Max_Score'Image);

end Play;

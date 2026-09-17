pragma Ada_2022;
with Ada.Text_IO; use Ada.Text_IO;
with Spatial_Memory; use Spatial_Memory;

procedure Play is

   Cfg : constant Session_Config := (3, 3, 2, 42);
   Trials : Trial_List;
   Count : Natural;
   Answers : Answer_List;
   Line : String (1 .. 120);
   Last : Natural;
   Result : Session_Result;
   R1, C1, R2, C2 : Integer;
begin
   Put_Line ("[" & Instruction_Key & "]");
   Put_Line ("Remember marked cells, then re-enter them as r,c pairs.");
   Build_Session (Cfg, Trials, Count);
   for I in 1 .. Count loop
      New_Line;
      Put_Line ("Trial" & I'Image & " — study marks:");
      for J in 1 .. Trials (I).Count loop
         Put_Line ("  (" & Trials (I).Marks (J).Row'Image & ","
                   & Trials (I).Marks (J).Col'Image & " )");
      end loop;
      Put_Line ("Press Enter to recall...");
      Get_Line (Line, Last);
      Put_Line ("Enter two points as: r1 c1 r2 c2");
      Put ("[" & Prompt_Key & "]: ");
      Get_Line (Line, Last);
      Answers (I).Count := 2;
      begin
         -- naive parse: four integers
         declare
            First : Natural := 1;
            procedure Next_Int (Val : out Integer) is
               L, R : Natural;
            begin
               while First <= Last and then Line (First) = ' ' loop
                  First := First + 1;
               end loop;
               L := First;
               while First <= Last and then Line (First) /= ' ' loop
                  First := First + 1;
               end loop;
               R := First - 1;
               Val := Integer'Value (Line (L .. R));
            end Next_Int;
         begin
            Next_Int (R1); Next_Int (C1); Next_Int (R2); Next_Int (C2);
            Answers (I).Marks (1) := (Positive (R1), Positive (C1));
            Answers (I).Marks (2) := (Positive (R2), Positive (C2));
         end;
      exception
         when others =>
            Answers (I).Marks (1) := (1, 1);
            Answers (I).Marks (2) := (1, 1);
      end;
   end loop;
   Result := Score_Session (Cfg, Trials, Count, Answers);
   Put_Line ("Score:" & Result.Score'Image & " /" & Result.Max_Score'Image);

end Play;

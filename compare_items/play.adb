pragma Ada_2022;
with Ada.Text_IO; use Ada.Text_IO;
with Compare_Items; use Compare_Items;

procedure Play is

   Cfg : constant Session_Config := (6, 50, 42);
   Trials : Trial_List; Count : Natural;
   Answers : Answer_List := [others => False];
   Line : String (1 .. 80); Last : Natural; Result : Session_Result;
begin
   Put_Line ("[" & Instruction_Key & "]");
   Put_Line ("Are Left and Right the same? y/n");
   Build_Session (Cfg, Trials, Count);
   for I in 1 .. Count loop
      New_Line;
      Put ("Trial" & I'Image & " Left=");
      if Trials (I).Left.Kind = Number then
         Put (Trials (I).Left.Num'Image);
      else
         Put (Trials (I).Left.Word (1 .. Trials (I).Left.Len));
      end if;
      Put (" Right=");
      if Trials (I).Right.Kind = Number then
         Put (Trials (I).Right.Num'Image);
      else
         Put (Trials (I).Right.Word (1 .. Trials (I).Right.Len));
      end if;
      New_Line;
      Put ("[" & Prompt_Key & "] (y/n): ");
      Get_Line (Line, Last);
      Answers (I) := Last >= 1 and then (Line (1) = 'y' or else Line (1) = 'Y');
   end loop;
   Result := Score_Session (Cfg, Trials, Count, Answers);
   Put_Line ("Score:" & Result.Score'Image & " /" & Result.Max_Score'Image);

end Play;

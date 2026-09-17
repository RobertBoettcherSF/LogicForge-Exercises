pragma Ada_2022;

with Ada.Text_IO;         use Ada.Text_IO;
with Ada.Integer_Text_IO; use Ada.Integer_Text_IO;
with Path_Plan;           use Path_Plan;

procedure Play is
   Cfg : constant Session_Config :=
     (Trial_Count => 2, N => 3, Seed => 42, Wall_Rate => 30);
   Trials  : Trial_List;
   Count   : Natural;
   Answers : Answer_List;
   Result  : Session_Result;
   Len     : Integer;
   R, C    : Integer;
begin
   Put_Line ("[" & Instruction_Key & "]");
   Put_Line ("Propose a 4-neighbour path from Start to Goal on Open cells.");
   Build_Session (Cfg, Trials, Count);

   for I in 1 .. Count loop
      New_Line;
      Put_Line ("Trial" & I'Image);
      Put_Line ("Map (O=open . =wall):");
      for Row in 1 .. Trials (I).N loop
         for Col in 1 .. Trials (I).N loop
            if Trials (I).Grid (Row, Col) = Open then
               Put ('O');
            else
               Put ('.');
            end if;
         end loop;
         New_Line;
      end loop;
      Put_Line ("Start: (" & Trials (I).Start_Pt.R'Image & ","
                & Trials (I).Start_Pt.C'Image & ")");
      Put_Line ("Goal:  (" & Trials (I).Goal_Pt.R'Image & ","
                & Trials (I).Goal_Pt.C'Image & ")");
      Put ("[" & Prompt_Key & "] path length: ");
      Get (Len);
      if Len < 1 then Len := 1; end if;
      if Len > Max_Path then Len := Max_Path; end if;
      Answers (I).Len := Len;
      for K in 1 .. Len loop
         Put ("  step" & K'Image & " R C: ");
         Get (R); Get (C);
         if R < 1 then R := 1; end if;
         if C < 1 then C := 1; end if;
         Answers (I).Path_Pts (K) := (Positive (R), Positive (C));
      end loop;
   end loop;

   Result := Score_Session (Cfg, Trials, Count, Answers);
   New_Line;
   Put ("Score: ");
   Put (Result.Score, 0);
   Put (" / ");
   Put (Result.Max_Score, 0);
   New_Line;
end Play;

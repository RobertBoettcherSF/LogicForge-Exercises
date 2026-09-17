pragma Ada_2022;

with Ada.Text_IO;         use Ada.Text_IO;
with Ada.Integer_Text_IO; use Ada.Integer_Text_IO;
with Number_Grid;         use Number_Grid;

--  Optional interactive host (not required by make test).
procedure Play is
   Cfg : constant Session_Config :=
     (Trial_Count => 3, N => 2, Seed => 42, Max_Fill => 5);
   Trials  : Trial_List;
   Count   : Natural;
   Answers : Answer_List := [others => [others => [others => 0]]];
   Result  : Session_Result;
   Val     : Integer;
begin
   Put_Line ("[" & Instruction_Key & "]");
   Put_Line ("Fill each cell so row/col sums match the targets.");
   Build_Session (Cfg, Trials, Count);

   for I in 1 .. Count loop
      New_Line;
      Put_Line ("Trial" & I'Image & "  (N=" & Trials (I).N'Image & ")");
      Put ("Row targets:");
      for R in 1 .. Trials (I).N loop
         Put (Trials (I).Row_Tgt (R), 0);
         Put (" ");
      end loop;
      New_Line;
      Put ("Col targets:");
      for C in 1 .. Trials (I).N loop
         Put (Trials (I).Col_Tgt (C), 0);
         Put (" ");
      end loop;
      New_Line;
      Put_Line ("[" & Prompt_Key & "] enter" &
                Integer'Image (Trials (I).N * Trials (I).N) & " cells:");
      for R in 1 .. Trials (I).N loop
         for C in 1 .. Trials (I).N loop
            Put ("  (" & R'Image & "," & C'Image & "): ");
            Get (Val);
            if Val < 0 then
               Val := 0;
            elsif Val > 99 then
               Val := 99;
            end if;
            Answers (I) (R, C) := Cell_Value (Val);
         end loop;
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

pragma Ada_2022;

with Ada.Text_IO;         use Ada.Text_IO;
with Ada.Integer_Text_IO; use Ada.Integer_Text_IO;
with Rule_Infer;          use Rule_Infer;

procedure Play is
   Cfg : constant Session_Config :=
     (Trial_Count => 1, Example_Count => 4, Probe_Count => 5, Seed => 42);
   Trials  : Trial_List;
   Count   : Natural;
   Answers : Answer_List := [others => [others => False]];
   Result  : Session_Result;
   Line    : String (1 .. 80);
   Last    : Natural;
begin
   Put_Line ("[" & Instruction_Key & "]");
   Put_Line ("Infer the hidden rule from positive examples, then classify probes.");
   Build_Session (Cfg, Trials, Count);

   for I in 1 .. Count loop
      New_Line;
      Put_Line ("Game" & I'Image);
      Put_Line ("[" & Example_Key & "] positives:");
      for E in 1 .. Trials (I).Ex_Count loop
         Put (Trials (I).Examples (E), 0);
         Put (" ");
      end loop;
      New_Line;
      for P in 1 .. Trials (I).Pr_Count loop
         Put ("[" & Prompt_Key & "] does ");
         Put (Trials (I).Probes (P), 0);
         Put (" obey? (y/n): ");
         Get_Line (Line, Last);
         Answers (I) (P) :=
           Last >= 1 and then (Line (1) = 'y' or else Line (1) = 'Y');
      end loop;
      Put_Line ("(Hidden was "
                & Rule_Kind'Image (Trials (I).Hidden.Kind)
                & " param"
                & Trials (I).Hidden.Param'Image
                & ")");
   end loop;

   Result := Score_Session (Cfg, Trials, Count, Answers);
   New_Line;
   Put ("Score: ");
   Put (Result.Score, 0);
   Put (" / ");
   Put (Result.Max_Score, 0);
   New_Line;
end Play;

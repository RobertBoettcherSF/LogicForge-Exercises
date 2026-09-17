pragma Ada_2022;

with Ada.Text_IO;         use Ada.Text_IO;
with Ada.Integer_Text_IO; use Ada.Integer_Text_IO;
with Timed_Choice_RT;     use Timed_Choice_RT;

procedure Play is
   Cfg : constant Session_Config :=
     (Trial_Count => 5, Seed => 42, Fast_Limit => Fast_Ms);
   Prompts : Prompt_List;
   Count   : Natural;
   Answers : Answer_List;
   Result  : Session_Result;
   Choice  : Integer;
   Lat     : Integer;
begin
   Put_Line ("[" & Instruction_Key & "]");
   Put_Line ("Pick option 1..4. Host asks you to invent a latency_ms.");
   Build_Session (Cfg, Prompts, Count);

   for I in 1 .. Count loop
      New_Line;
      Put_Line ("Trial" & I'Image);
      Put_Line ("(Educational demo — correct option is hidden in a real host.)");
      Put_Line ("Hint for local play: correct ="
                & Prompts (I).Correct_Option'Image);
      Put ("[" & Prompt_Key & "] choice 1..4: ");
      Get (Choice);
      if Choice < 1 then Choice := 1; end if;
      if Choice > 4 then Choice := 4; end if;
      Put ("latency_ms: ");
      Get (Lat);
      if Lat < 0 then Lat := 0; end if;
      Answers (I) :=
        (Correct_Option => Prompts (I).Correct_Option,
         Chosen_Option  => Option_Id (Choice),
         Latency_Ms     => Natural (Lat));
   end loop;

   Result := Score_Session (Cfg, Prompts, Count, Answers);
   New_Line;
   Put ("Score: ");
   Put (Result.Score, 0);
   Put (" / ");
   Put (Result.Max_Score, 0);
   New_Line;
end Play;

pragma Ada_2022;

with Ada.Text_IO;         use Ada.Text_IO;
with Ada.Integer_Text_IO; use Ada.Integer_Text_IO;
with Recall_Span;         use Recall_Span;

procedure Play is

   function Image_Seq (T : Fixed_Sequence; Len : Positive) return String is
      Buf : String (1 .. Len * 2);
      P   : Natural := 0;
   begin
      for I in 1 .. Len loop
         P := P + 1;
         Buf (P) := Character'Val (Character'Pos ('0') + Natural (T (I)));
         if I < Len then
            P := P + 1;
            Buf (P) := ' ';
         end if;
      end loop;
      return Buf (1 .. P);
   end Image_Seq;

   Cfg : constant Session_Config :=
     (Trial_Count => 4, Start_Len => 2, Seed => 42);
   Trials  : Trial_List;
   Count   : Natural;
   Answers : Answer_List;
   Result  : Session_Result;
   Line    : String (1 .. 80);
   Last    : Natural;
   Dig     : Natural;
begin
   Put_Line ("[" & Instruction_Key & "]");
   Put_Line ("Memorize the digits, then type them back separated by spaces.");
   Build_Session (Cfg, Trials, Count);

   for I in 1 .. Count loop
      New_Line;
      Put_Line ("Trial" & I'Image & "  length" & Trials (I).Len'Image);
      Put_Line ("Presented: " & Image_Seq (Trials (I).Presented, Trials (I).Len));
      Put_Line ("(Look away, then recall…)");
      Put ("[" & Prompt_Key & "] recall: ");
      Get_Line (Line, Last);
      Answers (I).Presented := [others => 0];
      Dig := 0;
      for K in 1 .. Last loop
         if Line (K) in '0' .. '9' then
            Dig := Dig + 1;
            if Dig <= Max_Len then
               Answers (I).Presented (Dig) :=
                 Symbol (Character'Pos (Line (K)) - Character'Pos ('0'));
            end if;
         end if;
      end loop;
      if Dig = 0 then
         Answers (I).Len := 1;
         Answers (I).Presented (1) := 0;
      elsif Dig > Max_Len then
         Answers (I).Len := Max_Len;
      else
         Answers (I).Len := Dig;
      end if;
   end loop;

   Result := Score_Session (Cfg, Trials, Count, Answers);
   New_Line;
   Put ("Score: ");
   Put (Result.Score, 0);
   Put (" / ");
   Put (Result.Max_Score, 0);
   New_Line;
end Play;

pragma Ada_2022;

package Conflict_Label is
   Max_Trials : constant Positive := 32;

   type Color_Id is (Red, Green, Blue, Yellow);

   Invalid_Argument : exception;

   type Session_Config is record
      Trial_Count   : Positive := 12;
      Conflict_Rate : Natural := 50;
      Seed          : Natural := 1;
   end record;

   function Config_Ok (Cfg : Session_Config) return Boolean is
     (Cfg.Trial_Count <= Max_Trials and then Cfg.Conflict_Rate <= 100);

   type Trial is record
      Word_Color : Color_Id := Red;  -- printed word meaning
      Ink_Color  : Color_Id := Red;  -- display ink
      Conflict   : Boolean := False;
   end record;

   type Trial_List is array (1 .. Max_Trials) of Trial;
   type Answer_List is array (1 .. Max_Trials) of Color_Id;  -- report ink

   type Session_Result is record
      Config : Session_Config;
      Trials_Run, Score, Max_Score : Natural := 0;
   end record;

   Instruction_Key : constant String := "conflict_label.instruction";
   Prompt_Key      : constant String := "conflict_label.prompt_ink";

   function Trial_Score (Ink, Given : Color_Id) return Natural
   with Post => Trial_Score'Result in 0 .. 1, Global => null;

   procedure Build_Session
     (Cfg : Session_Config; Trials : out Trial_List; Count : out Natural)
   with Pre => Config_Ok (Cfg), Post => Count = Cfg.Trial_Count, Global => null;

   function Score_Session
     (Cfg : Session_Config; Trials : Trial_List; Count : Natural;
      Answers : Answer_List) return Session_Result
   with
     Pre => Config_Ok (Cfg) and then Count = Cfg.Trial_Count
            and then Count <= Max_Trials,
     Post => Score_Session'Result.Trials_Run = Count
             and then Score_Session'Result.Max_Score = Count
             and then Score_Session'Result.Score <= Count,
     Global => null;
end Conflict_Label;

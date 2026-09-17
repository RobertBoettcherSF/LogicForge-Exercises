pragma Ada_2022;

package Percent_Estimate is
   Max_Trials : constant Positive := 24;

   Invalid_Argument : exception;

   type Session_Config is record
      Trial_Count : Positive := 8;
      Tolerance   : Natural := 5;  -- acceptable absolute error
      Seed        : Natural := 1;
   end record;

   function Config_Ok (Cfg : Session_Config) return Boolean is
     (Cfg.Trial_Count <= Max_Trials and then Cfg.Tolerance <= 50);

   type Trial is record
      Part   : Natural := 0;
      Whole  : Positive := 1;
      Exact  : Natural := 0;  -- round(100*Part/Whole)
   end record;

   type Trial_List is array (1 .. Max_Trials) of Trial;
   type Answer_List is array (1 .. Max_Trials) of Natural;

   type Session_Result is record
      Config : Session_Config;
      Trials_Run, Score, Max_Score : Natural := 0;
   end record;

   Instruction_Key : constant String := "percent_estimate.instruction";
   Prompt_Key      : constant String := "percent_estimate.prompt_pct";

   function Exact_Percent (Part : Natural; Whole : Positive) return Natural
   with Global => null;

   function Trial_Score
     (Exact, Given : Natural; Tolerance : Natural) return Natural
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
end Percent_Estimate;

pragma Ada_2022;

package Go_Nogo is
   Max_Trials : constant Positive := 48;

   type Stimulus_Kind is (Go, NoGo);

   Invalid_Argument : exception;

   type Session_Config is record
      Trial_Count : Positive := 16;
      Go_Rate     : Natural := 75;  -- % Go trials
      Seed        : Natural := 1;
   end record;

   function Config_Ok (Cfg : Session_Config) return Boolean is
     (Cfg.Trial_Count <= Max_Trials and then Cfg.Go_Rate <= 100);

   type Trial is record
      Kind : Stimulus_Kind := Go;
   end record;

   type Trial_List is array (1 .. Max_Trials) of Trial;
   -- True = user responded (pressed); False = withheld
   type Answer_List is array (1 .. Max_Trials) of Boolean;

   type Session_Result is record
      Config     : Session_Config;
      Trials_Run : Natural := 0;
      Score      : Natural := 0;
      Max_Score  : Natural := 0;
      Hits       : Natural := 0;  -- Go + respond
      Correct_Rejects : Natural := 0;  -- NoGo + withhold
      Misses     : Natural := 0;
      False_Alarms : Natural := 0;
   end record;

   Instruction_Key : constant String := "go_nogo.instruction";
   Prompt_Key      : constant String := "go_nogo.prompt_respond";

   function Trial_Score (Kind : Stimulus_Kind; Responded : Boolean) return Natural
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
end Go_Nogo;

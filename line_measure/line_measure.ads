pragma Ada_2022;
package Line_Measure is
   Max_Trials : constant Positive := 24;
   Max_Len : constant Positive := 16;
   type Cell is (Empty, Filled);
   type Row is array (1 .. Max_Len) of Cell;
   Invalid_Argument : exception;
   type Session_Config is record
      Trial_Count : Positive := 8;
      Len : Positive := 10;
      Seed : Natural := 1;
   end record;
   function Config_Ok (Cfg : Session_Config) return Boolean is
     (Cfg.Trial_Count <= Max_Trials and then Cfg.Len in 2 .. Max_Len);
   type Trial is record
      Cells : Row := [others => Empty];
      Len : Positive := 2;
      Length : Natural := 0;
   end record;
   type Trial_List is array (1 .. Max_Trials) of Trial;
   type Answer_List is array (1 .. Max_Trials) of Natural;
   type Session_Result is record
      Config : Session_Config;
      Trials_Run, Score, Max_Score : Natural := 0;
   end record;
   Instruction_Key : constant String := "line_measure.instruction";
   Prompt_Key : constant String := "line_measure.prompt_len";
   function Count_Filled (Cells : Row; Len : Positive) return Natural
   with Pre => Len <= Max_Len, Global => null;
   function Trial_Score (Expected, Given : Natural) return Natural
   with Post => Trial_Score'Result in 0 .. 1, Global => null;
   procedure Build_Session
     (Cfg : Session_Config; Trials : out Trial_List; Count : out Natural)
   with Pre => Config_Ok (Cfg), Post => Count = Cfg.Trial_Count, Global => null;
   function Score_Session
     (Cfg : Session_Config; Trials : Trial_List; Count : Natural;
      Answers : Answer_List) return Session_Result
   with Pre => Config_Ok (Cfg) and then Count = Cfg.Trial_Count
               and then Count <= Max_Trials,
        Post => Score_Session'Result.Trials_Run = Count
                and then Score_Session'Result.Max_Score = Count
                and then Score_Session'Result.Score <= Count,
        Global => null;
end Line_Measure;

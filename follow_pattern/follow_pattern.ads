pragma Ada_2022;
package Follow_Pattern is
   Max_Trials : constant Positive := 24;
   Max_Len : constant Positive := 8;
   type Letter is range Character'Pos ('A') .. Character'Pos ('Z');
   type Seq is array (1 .. Max_Len) of Character;
   Invalid_Argument : exception;
   type Session_Config is record
      Trial_Count : Positive := 8;
      Prefix_Len : Positive := 4;
      Seed : Natural := 1;
   end record;
   function Config_Ok (Cfg : Session_Config) return Boolean is
     (Cfg.Trial_Count <= Max_Trials
      and then Cfg.Prefix_Len in 2 .. Max_Len - 1);
   type Trial is record
      Prefix : Seq := [others => 'A'];
      Len : Positive := 2;
      Next_Letter : Character := 'A';
   end record;
   type Trial_List is array (1 .. Max_Trials) of Trial;
   type Answer_List is array (1 .. Max_Trials) of Character;
   type Session_Result is record
      Config : Session_Config;
      Trials_Run, Score, Max_Score : Natural := 0;
   end record;
   Instruction_Key : constant String := "follow_pattern.instruction";
   Prompt_Key : constant String := "follow_pattern.prompt_next";
   function Trial_Score (Expected, Given : Character) return Natural
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
end Follow_Pattern;

pragma Ada_2022;

package Compass_Orient is
   Max_Trials : constant Positive := 32;

   type Cardinal is (N, E, S, W);
   type Turn is (Left, Right, Around, None);

   Invalid_Argument : exception;

   type Session_Config is record
      Trial_Count : Positive := 10;
      Seed        : Natural := 1;
   end record;

   function Config_Ok (Cfg : Session_Config) return Boolean is
     (Cfg.Trial_Count <= Max_Trials);

   type Trial is record
      Facing : Cardinal := N;
      Action : Turn := None;
      Result : Cardinal := N;
   end record;

   type Trial_List is array (1 .. Max_Trials) of Trial;
   type Answer_List is array (1 .. Max_Trials) of Cardinal;

   type Session_Result is record
      Config : Session_Config;
      Trials_Run, Score, Max_Score : Natural := 0;
   end record;

   Instruction_Key : constant String := "compass_orient.instruction";
   Prompt_Key      : constant String := "compass_orient.prompt_facing";

   function Apply_Turn (Facing : Cardinal; Action : Turn) return Cardinal
   with Global => null;

   function Trial_Score (Expected, Given : Cardinal) return Natural
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
end Compass_Orient;

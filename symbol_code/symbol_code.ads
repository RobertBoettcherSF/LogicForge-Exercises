pragma Ada_2022;

package Symbol_Code is
   Max_Trials : constant Positive := 32;
   Max_Map    : constant Positive := 10;

   type Digit is range 0 .. 9;
   type Code_Char is range Character'Pos ('A') .. Character'Pos ('J');

   Invalid_Argument : exception;

   type Session_Config is record
      Trial_Count : Positive := 10;
      Seed        : Natural := 1;
   end record;

   function Config_Ok (Cfg : Session_Config) return Boolean is
     (Cfg.Trial_Count <= Max_Trials);

   type Trial is record
      Shown  : Digit := 0;
      Answer : Character := 'A';
   end record;

   type Trial_List is array (1 .. Max_Trials) of Trial;
   type Answer_List is array (1 .. Max_Trials) of Character;

   type Session_Result is record
      Config : Session_Config;
      Trials_Run, Score, Max_Score : Natural := 0;
   end record;

   Instruction_Key : constant String := "symbol_code.instruction";
   Prompt_Key      : constant String := "symbol_code.prompt_code";

   function Code_Of (D : Digit) return Character
   with Global => null;
   -- Fixed educational mapping: 0->A .. 9->J

   function Trial_Score (Expected, Given : Character) return Natural
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
end Symbol_Code;

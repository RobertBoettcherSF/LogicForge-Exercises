pragma Ada_2022;

--  Novelty_Check — Logic Forge clean-room CLI core.
--  Decide whether the current symbol appeared earlier in the session.

package Novelty_Check is

   Max_Trials : constant Positive := 32;
   Max_Symbol : constant Positive := 20;

   type Symbol_Id is range 1 .. Max_Symbol;

   Invalid_Argument : exception;

   type Session_Config is record
      Trial_Count : Positive := 12;
      Alphabet    : Positive := 8;   -- distinct symbols in play
      Repeat_Rate : Natural := 40;   -- % of trials that are repeats
      Seed        : Natural := 1;
   end record;

   function Config_Ok (Cfg : Session_Config) return Boolean is
     (Cfg.Trial_Count <= Max_Trials
      and then Cfg.Alphabet in 2 .. Max_Symbol
      and then Cfg.Repeat_Rate <= 100);

   type Trial is record
      Shown     : Symbol_Id := 1;
      Is_Repeat : Boolean := False;
   end record;

   type Trial_List is array (1 .. Max_Trials) of Trial;
   type Answer_List is array (1 .. Max_Trials) of Boolean;

   type Session_Result is record
      Config     : Session_Config;
      Trials_Run : Natural := 0;
      Score      : Natural := 0;
      Max_Score  : Natural := 0;
   end record;

   Instruction_Key : constant String := "novelty_check.instruction";
   Prompt_Key      : constant String := "novelty_check.prompt_seen";
   Yes_Key         : constant String := "novelty_check.yes";
   No_Key          : constant String := "novelty_check.no";

   function Trial_Score
     (Is_Repeat : Boolean; User_Says_Seen : Boolean) return Natural
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

end Novelty_Check;

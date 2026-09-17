--  Timed_Choice_RT — Logic Forge clean-room cognitive exercise core.
--  Ada 2023 (ISO/IEC 8652:2023). Host supplies latency_ms; score
--  correct+fast / correct+slow / wrong across multi-choice trials.

pragma Ada_2022;

package Timed_Choice_RT
  with SPARK_Mode => Off
is

   Max_Trials : constant Positive := 32;
   Fast_Ms    : constant Natural := 1500;

   type Option_Id is range 1 .. 4;

   type Band is (Wrong, Correct_Slow, Correct_Fast);

   type Trial is record
      Correct_Option : Option_Id := 1;
      Chosen_Option  : Option_Id := 1;
      Latency_Ms     : Natural := 0;
   end record;

   Invalid_Argument : exception;

   ---------------------------------------------------------------------------
   -- Single-trial API
   ---------------------------------------------------------------------------

   function Is_Correct (T : Trial) return Boolean
   with Global => null;

   function Score_Band (T : Trial) return Band
   with Global => null;
   --  Wrong / Correct_Slow / Correct_Fast from correctness + Fast_Ms.

   --  2 = correct and fast, 1 = correct but slow, 0 = incorrect.
   function Trial_Score (T : Trial) return Natural
   with
     Post   => Trial_Score'Result in 0 .. 2,
     Global => null;

   ---------------------------------------------------------------------------
   -- Session API (deterministic correct-option generation)
   ---------------------------------------------------------------------------

   type Session_Config is record
      Trial_Count : Positive := 8;
      Seed        : Natural := 1;
      Fast_Limit  : Natural := Fast_Ms;
   end record;

   function Config_Ok (Cfg : Session_Config) return Boolean is
     (Cfg.Trial_Count in 1 .. Max_Trials);

   type Prompt_Trial is record
      Correct_Option : Option_Id := 1;
   end record;

   type Prompt_List is array (1 .. Max_Trials) of Prompt_Trial;
   type Answer_List is array (1 .. Max_Trials) of Trial;
   --  Answers carry Chosen_Option + Latency_Ms (Correct_Option ignored).

   type Session_Result is record
      Config     : Session_Config;
      Trials_Run : Natural := 0;
      Score      : Natural := 0;
      Max_Score  : Natural := 0;
   end record;

   Instruction_Key : constant String := "timed_choice_rt.instruction";
   Prompt_Key      : constant String := "timed_choice_rt.prompt_choose";
   Fast_Key        : constant String := "timed_choice_rt.fast";
   Slow_Key        : constant String := "timed_choice_rt.slow";

   procedure Build_Session
     (Cfg     : Session_Config;
      Prompts : out Prompt_List;
      Count   : out Natural)
   with
     Pre    => Config_Ok (Cfg),
     Post   => Count = Cfg.Trial_Count,
     Global => null;

   function Score_Session
     (Cfg     : Session_Config;
      Prompts : Prompt_List;
      Count   : Natural;
      Answers : Answer_List) return Session_Result
   with
     Pre    => Config_Ok (Cfg)
               and then Count = Cfg.Trial_Count
               and then Count in 1 .. Max_Trials,
     Post   => Score_Session'Result.Trials_Run = Count
               and then Score_Session'Result.Max_Score = Count * 2
               and then Score_Session'Result.Score
                        <= Score_Session'Result.Max_Score,
     Global => null;

end Timed_Choice_RT;

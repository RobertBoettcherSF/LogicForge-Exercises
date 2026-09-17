--  Rule_Infer — Logic Forge clean-room cognitive exercise core.
--  Ada 2023 (ISO/IEC 8652:2023). Hidden rule (Even/Odd/At_Least/Multiple_Of);
--  show examples; score probe classifications via session API.

pragma Ada_2022;

package Rule_Infer
  with SPARK_Mode => Off
is

   Max_Examples : constant Positive := 8;
   Max_Probes   : constant Positive := 16;
   Max_Trials   : constant Positive := 32;
   Value_Max    : constant Integer := 30;

   type Rule_Kind is (Even, Odd, At_Least, Multiple_Of);

   type Rule is record
      Kind  : Rule_Kind := Even;
      Param : Integer := 0;  -- threshold or modulus when relevant
   end record;

   type Int_List is array (Positive range <>) of Integer;

   Invalid_Argument : exception;

   ---------------------------------------------------------------------------
   -- Single-probe API
   ---------------------------------------------------------------------------

   function Rule_Ok (R : Rule) return Boolean is
     (case R.Kind is
         when Even | Odd => True,
         when At_Least   => True,
         when Multiple_Of => R.Param > 0);

   function Obeys (R : Rule; X : Integer) return Boolean
   with
     Pre    => Rule_Ok (R),
     Global => null;

   function Trial_Score
     (R : Rule; X : Integer; User_Says_Yes : Boolean) return Natural
   with
     Pre    => Rule_Ok (R),
     Post   => Trial_Score'Result in 0 .. 1,
     Global => null;

   ---------------------------------------------------------------------------
   -- Session API (hidden rule + examples + probes)
   ---------------------------------------------------------------------------

   type Session_Config is record
      Trial_Count   : Positive := 1;   -- number of hidden-rule games
      Example_Count : Positive := 4;
      Probe_Count   : Positive := 6;
      Seed          : Natural := 1;
   end record;

   function Config_Ok (Cfg : Session_Config) return Boolean is
     (Cfg.Trial_Count in 1 .. Max_Trials
      and then Cfg.Example_Count in 1 .. Max_Examples
      and then Cfg.Probe_Count in 1 .. Max_Probes);

   type Fixed_Ints is array (1 .. Max_Examples) of Integer;
   type Fixed_Probes is array (1 .. Max_Probes) of Integer;
   type Fixed_Answers is array (1 .. Max_Probes) of Boolean;

   type Trial is record
      Hidden   : Rule := (Even, 0);
      Ex_Count : Positive := 1;
      Examples : Fixed_Ints := [others => 0];  -- positive examples only
      Pr_Count : Positive := 1;
      Probes   : Fixed_Probes := [others => 0];
      Truth    : Fixed_Answers := [others => False];
   end record;

   type Trial_List is array (1 .. Max_Trials) of Trial;
   type Answer_List is array (1 .. Max_Trials) of Fixed_Answers;

   type Session_Result is record
      Config     : Session_Config;
      Trials_Run : Natural := 0;
      Score      : Natural := 0;
      Max_Score  : Natural := 0;
   end record;

   Instruction_Key : constant String := "rule_infer.instruction";
   Prompt_Key      : constant String := "rule_infer.prompt_classify";
   Example_Key     : constant String := "rule_infer.example";
   Probe_Key       : constant String := "rule_infer.probe";

   procedure Build_Session
     (Cfg    : Session_Config;
      Trials : out Trial_List;
      Count  : out Natural)
   with
     Pre    => Config_Ok (Cfg),
     Post   => Count = Cfg.Trial_Count,
     Global => null;

   function Score_Session
     (Cfg     : Session_Config;
      Trials  : Trial_List;
      Count   : Natural;
      Answers : Answer_List) return Session_Result
   with
     Pre    => Config_Ok (Cfg)
               and then Count = Cfg.Trial_Count
               and then Count in 1 .. Max_Trials,
     Post   => Score_Session'Result.Trials_Run = Count
               and then Score_Session'Result.Max_Score
                        = Count * Cfg.Probe_Count
               and then Score_Session'Result.Score
                        <= Score_Session'Result.Max_Score,
     Global => null;

end Rule_Infer;

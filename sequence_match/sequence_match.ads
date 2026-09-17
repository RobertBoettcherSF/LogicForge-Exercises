--  Sequence_Match — Logic Forge clean-room cognitive exercise core.
--  Ada 2023 (ISO/IEC 8652:2023). Present a short digit sequence, then a
--  probe; decide whether they match under Exact or Allow_One_Substitution.
--  Variants: single-trial scoring and multi-trial seeded sessions.

pragma Ada_2022;

package Sequence_Match
  with SPARK_Mode => Off
is

   Max_Len    : constant Positive := 16;
   Max_Trials : constant Positive := 32;

   type Symbol is range 0 .. 9;
   type Sequence is array (Positive range <>) of Symbol;

   type Match_Mode is (Exact, Allow_One_Substitution);

   Invalid_Argument : exception;
   --  Raised when length / mode / session parameters are outside educational
   --  bounds (mirrors Pre; useful when callers disable assertions).

   ---------------------------------------------------------------------------
   -- Single-trial API
   ---------------------------------------------------------------------------

   function Is_Match
     (Target, Probe : Sequence; Mode : Match_Mode) return Boolean
   with
     Pre    => Target'First = 1
               and then Probe'First = 1
               and then Target'Length in 1 .. Max_Len
               and then Probe'Length in 1 .. Max_Len,
     Global => null;
   --  True iff Probe matches Target under Mode.
   --  Exact: same length and all symbols equal.
   --  Allow_One_Substitution: same length and Hamming distance <= 1.

   function Hamming_Distance (Target, Probe : Sequence) return Natural
   with
     Pre    => Target'First = 1
               and then Probe'First = 1
               and then Target'Length = Probe'Length
               and then Target'Length in 1 .. Max_Len,
     Post   => Hamming_Distance'Result <= Target'Length,
     Global => null;
   --  Count of positions where symbols differ (equal lengths only).

   function Trial_Score
     (Target, Probe     : Sequence;
      Mode              : Match_Mode;
      User_Says_Match   : Boolean) return Natural
   with
     Pre    => Target'First = 1
               and then Probe'First = 1
               and then Target'Length in 1 .. Max_Len
               and then Probe'Length in 1 .. Max_Len,
     Post   => Trial_Score'Result in 0 .. 1,
     Global => null;
   --  1 if the user's yes/no equals Is_Match; otherwise 0.

   ---------------------------------------------------------------------------
   -- Session API (deterministic task generation)
   ---------------------------------------------------------------------------

   type Session_Config is record
      Mode        : Match_Mode := Exact;
      Trial_Count : Positive := 8;
      Seq_Length  : Positive := 4;
      Seed        : Natural := 1;
      Match_Rate  : Natural := 50;  -- percent of trials that are true matches
   end record;

   function Config_Ok (Cfg : Session_Config) return Boolean is
     (Cfg.Trial_Count <= Max_Trials
      and then Cfg.Seq_Length <= Max_Len
      and then Cfg.Match_Rate <= 100);

   type Fixed_Sequence is array (1 .. Max_Len) of Symbol;

   type Trial is record
      Len    : Positive := 1;
      Target : Fixed_Sequence := [others => 0];
      Probe  : Fixed_Sequence := [others => 0];
      Is_Yes : Boolean := True;
   end record;

   type Trial_List is array (1 .. Max_Trials) of Trial;
   type Answer_List is array (1 .. Max_Trials) of Boolean;

   type Session_Result is record
      Config     : Session_Config;
      Trials_Run : Natural := 0;
      Score      : Natural := 0;
      Max_Score  : Natural := 0;
   end record;

   --  Locale key ids for a future JSON i18n host (not product copy).
   Instruction_Key : constant String := "sequence_match.instruction";
   Prompt_Key      : constant String := "sequence_match.prompt_match";
   Yes_Key         : constant String := "sequence_match.yes";
   No_Key          : constant String := "sequence_match.no";

   function Slice (T : Fixed_Sequence; Len : Positive) return Sequence
   with
     Pre    => Len in 1 .. Max_Len,
     Post   => Slice'Result'First = 1 and then Slice'Result'Length = Len,
     Global => null;

   procedure Build_Session
     (Cfg    : Session_Config;
      Trials : out Trial_List;
      Count  : out Natural)
   with
     Pre    => Config_Ok (Cfg),
     Post   => Count = Cfg.Trial_Count,
     Global => null;
   --  Fill Trials (1 .. Count) using a seeded LCG. Raises Invalid_Argument
   --  if Config_Ok is False when contracts are not checked.

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
               and then Score_Session'Result.Max_Score = Count
               and then Score_Session'Result.Score <= Count,
     Global => null;

end Sequence_Match;

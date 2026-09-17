--  Sequence_Match — Logic Forge educational exercise (plain Ada 2022).
--  Clean-room design: present a short symbol sequence, then ask whether
--  a probe sequence matches (exact or with one allowed edit, by mode).
--  Includes a playable session loop API for the host / CLI.
--  No third-party product names or copied task text.

pragma Ada_2022;

package Sequence_Match is

   Max_Len    : constant Positive := 16;
   Max_Trials : constant Positive := 32;

   type Symbol is range 0 .. 9;
   type Sequence is array (Positive range <>) of Symbol;

   type Match_Mode is (Exact, Allow_One_Substitution);

   ---------------------------------------------------------------------------
   -- Core match / score
   ---------------------------------------------------------------------------

   function Is_Match
     (Target, Probe : Sequence; Mode : Match_Mode) return Boolean
   with
     Pre => Target'Length in 1 .. Max_Len
       and then Probe'Length in 1 .. Max_Len
       and then Target'First = 1
       and then Probe'First = 1;

   function Trial_Score
     (Target, Probe : Sequence;
      Mode          : Match_Mode;
      User_Says_Match : Boolean) return Natural
   with
     Pre => Target'Length in 1 .. Max_Len
       and then Probe'Length in 1 .. Max_Len
       and then Target'First = 1
       and then Probe'First = 1,
     Post => Trial_Score'Result in 0 .. 1;

   ---------------------------------------------------------------------------
   -- Session (deterministic task generation + scoring)
   ---------------------------------------------------------------------------

   type Session_Config is record
      Mode        : Match_Mode := Exact;
      Trial_Count : Positive := 8;
      Seq_Length  : Positive := 4;
      Seed        : Natural := 1;
      Match_Rate  : Natural := 50;  -- percent of trials that are true matches
   end record
   with Dynamic_Predicate =>
     Session_Config.Trial_Count in 1 .. Max_Trials
     and then Session_Config.Seq_Length in 1 .. Max_Len
     and then Session_Config.Match_Rate <= 100;

   type Fixed_Sequence is array (1 .. Max_Len) of Symbol;

   type Trial is record
      Len     : Positive := 1;
      Target  : Fixed_Sequence := [others => 0];
      Probe   : Fixed_Sequence := [others => 0];
      Is_Yes  : Boolean := True;  -- ground-truth: sequences match under Mode
   end record;

   type Trial_List is array (1 .. Max_Trials) of Trial;
   type Answer_List is array (1 .. Max_Trials) of Boolean;

   type Session_Result is record
      Config       : Session_Config;
      Trials_Run   : Natural := 0;
      Score        : Natural := 0;  -- sum of Trial_Score
      Max_Score    : Natural := 0;
   end record;

   --  i18n key ids (host maps these via JSON locales)
   Instruction_Key : constant String := "sequence_match.instruction";
   Prompt_Key      : constant String := "sequence_match.prompt_match";
   Yes_Key         : constant String := "sequence_match.yes";
   No_Key          : constant String := "sequence_match.no";

   procedure Build_Session
     (Cfg    : Session_Config;
      Trials : out Trial_List;
      Count  : out Natural)
   with Pre => Cfg.Trial_Count in 1 .. Max_Trials
          and then Cfg.Seq_Length in 1 .. Max_Len;

   function Score_Session
     (Cfg     : Session_Config;
      Trials  : Trial_List;
      Count   : Natural;
      Answers : Answer_List) return Session_Result
   with Pre => Count in 1 .. Max_Trials
          and then Count = Cfg.Trial_Count;

   function Slice (T : Fixed_Sequence; Len : Positive) return Sequence
   with Pre => Len in 1 .. Max_Len;

end Sequence_Match;

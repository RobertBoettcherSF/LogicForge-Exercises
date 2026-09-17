--  Recall_Span — Logic Forge clean-room cognitive exercise core.
--  Ada 2023 (ISO/IEC 8652:2023). Present a digit sequence; score
--  Exact_Match and Prefix_Span on trainee recall. Sessions increase length.

pragma Ada_2022;

package Recall_Span
  with SPARK_Mode => Off
is

   Max_Len    : constant Positive := 12;
   Max_Trials : constant Positive := 32;

   type Symbol is range 0 .. 9;
   type Sequence is array (Positive range <>) of Symbol;

   Invalid_Argument : exception;

   ---------------------------------------------------------------------------
   -- Single-trial API
   ---------------------------------------------------------------------------

   function Exact_Match (Presented, Recalled : Sequence) return Boolean
   with
     Pre    => Presented'First = 1
               and then Recalled'First = 1
               and then Presented'Length in 1 .. Max_Len
               and then Recalled'Length in 0 .. Max_Len,
     Global => null;

   function Prefix_Span (Presented, Recalled : Sequence) return Natural
   with
     Pre    => Presented'First = 1
               and then Recalled'First = 1
               and then Presented'Length in 1 .. Max_Len
               and then Recalled'Length in 0 .. Max_Len,
     Post   => Prefix_Span'Result <= Presented'Length
               and then Prefix_Span'Result <= Recalled'Length,
     Global => null;

   --  Exact match → full length points; else Prefix_Span points.
   function Trial_Score (Presented, Recalled : Sequence) return Natural
   with
     Pre    => Presented'First = 1
               and then Recalled'First = 1
               and then Presented'Length in 1 .. Max_Len
               and then Recalled'Length in 0 .. Max_Len,
     Post   => Trial_Score'Result <= Presented'Length,
     Global => null;

   ---------------------------------------------------------------------------
   -- Session API (increasing lengths, seeded sequences)
   ---------------------------------------------------------------------------

   type Session_Config is record
      Trial_Count : Positive := 6;
      Start_Len   : Positive := 2;
      Seed        : Natural := 1;
   end record;

   function Config_Ok (Cfg : Session_Config) return Boolean is
     (Cfg.Trial_Count in 1 .. Max_Trials
      and then Cfg.Start_Len in 1 .. Max_Len
      and then Cfg.Start_Len + Cfg.Trial_Count - 1 <= Max_Len);

   type Fixed_Sequence is array (1 .. Max_Len) of Symbol;

   type Trial is record
      Len       : Positive := 1;
      Presented : Fixed_Sequence := [others => 0];
   end record;

   type Trial_List is array (1 .. Max_Trials) of Trial;
   type Answer_List is array (1 .. Max_Trials) of Trial;
   --  Answers use Len + Presented as the recalled digits.

   type Session_Result is record
      Config     : Session_Config;
      Trials_Run : Natural := 0;
      Score      : Natural := 0;
      Max_Score  : Natural := 0;
   end record;

   Instruction_Key : constant String := "recall_span.instruction";
   Prompt_Key      : constant String := "recall_span.prompt_recall";
   Exact_Key       : constant String := "recall_span.exact";
   Prefix_Key      : constant String := "recall_span.prefix";

   function Slice (T : Fixed_Sequence; Len : Natural) return Sequence
   with
     Pre    => Len <= Max_Len,
     Post   => (if Len = 0 then Slice'Result'Length = 0
                else Slice'Result'First = 1
                     and then Slice'Result'Length = Len),
     Global => null;

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
               and then Score_Session'Result.Score
                        <= Score_Session'Result.Max_Score,
     Global => null;

end Recall_Span;

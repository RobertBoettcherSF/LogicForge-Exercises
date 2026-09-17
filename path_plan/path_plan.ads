--  Path_Plan — Logic Forge clean-room cognitive exercise core.
--  Ada 2023 (ISO/IEC 8652:2023). Validate / generate a path on a small
--  Open/Wall grid map. Trainee proposes a path; score validity and
--  optionally whether it reaches start→goal.

pragma Ada_2022;

package Path_Plan
  with SPARK_Mode => Off
is

   Max_N      : constant Positive := 8;
   Max_Path   : constant Positive := 32;
   Max_Trials : constant Positive := 32;

   type Cell is (Open, Wall);
   type Map is array (Positive range <>, Positive range <>) of Cell;
   type Point is record
      R, C : Positive := 1;
   end record;
   type Path is array (Positive range <>) of Point;

   Invalid_Argument : exception;

   ---------------------------------------------------------------------------
   -- Single-path API
   ---------------------------------------------------------------------------

   function In_Bounds_Map (M : Map) return Boolean is
     (M'First (1) = 1 and then M'First (2) = 1
      and then M'Last (1) in 1 .. Max_N
      and then M'Last (2) in 1 .. Max_N);

   function On_Map (M : Map; Pt : Point) return Boolean
   with
     Pre    => In_Bounds_Map (M),
     Global => null;

   function Adjacent (A, B : Point) return Boolean
   with Global => null;
   --  4-neighbour (Manhattan distance exactly 1).

   function Is_Valid_Path (M : Map; P : Path) return Boolean
   with
     Pre    => In_Bounds_Map (M)
               and then P'First = 1
               and then P'Length in 1 .. Max_Path,
     Global => null;
   --  Every step on Open cells, in bounds, and adjacent to the previous.

   function Reaches_Goal
     (P : Path; Start_Pt, Goal_Pt : Point) return Boolean
   with
     Pre    => P'First = 1 and then P'Length in 1 .. Max_Path,
     Global => null;
   --  True iff P'First = Start_Pt and P'Last = Goal_Pt.

   --  2 = valid and reaches goal, 1 = valid only, 0 = invalid.
   function Path_Score
     (M : Map; P : Path; Start_Pt, Goal_Pt : Point) return Natural
   with
     Pre    => In_Bounds_Map (M)
               and then P'First = 1
               and then P'Length in 1 .. Max_Path,
     Post   => Path_Score'Result in 0 .. 2,
     Global => null;

   ---------------------------------------------------------------------------
   -- Session API
   ---------------------------------------------------------------------------

   type Session_Config is record
      Trial_Count : Positive := 4;
      N           : Positive := 3;
      Seed        : Natural := 1;
      Wall_Rate   : Natural := 25;  -- percent chance a non-corridor cell is Wall
   end record;

   function Config_Ok (Cfg : Session_Config) return Boolean is
     (Cfg.Trial_Count in 1 .. Max_Trials
      and then Cfg.N in 2 .. Max_N
      and then Cfg.Wall_Rate <= 100);

   type Fixed_Map is array (1 .. Max_N, 1 .. Max_N) of Cell;
   type Fixed_Path is array (1 .. Max_Path) of Point;

   type Trial is record
      N        : Positive := 2;
      Len      : Positive := 1;
      Grid     : Fixed_Map := [others => [others => Open]];
      Path_Pts : Fixed_Path := [others => (1, 1)];
      Start_Pt : Point := (1, 1);
      Goal_Pt  : Point := (1, 1);
   end record;

   type Trial_List is array (1 .. Max_Trials) of Trial;
   type Answer_List is array (1 .. Max_Trials) of Trial;
   --  Answer Len + Path_Pts used; other fields ignored when scoring.

   type Session_Result is record
      Config     : Session_Config;
      Trials_Run : Natural := 0;
      Score      : Natural := 0;
      Max_Score  : Natural := 0;
   end record;

   Instruction_Key : constant String := "path_plan.instruction";
   Prompt_Key      : constant String := "path_plan.prompt_path";
   Valid_Key       : constant String := "path_plan.valid";
   Goal_Key        : constant String := "path_plan.goal";

   function Slice_Map (F : Fixed_Map; N : Positive) return Map
   with
     Pre    => N in 1 .. Max_N,
     Post   => Slice_Map'Result'First (1) = 1
               and then Slice_Map'Result'Last (1) = N,
     Global => null;

   function Slice_Path (F : Fixed_Path; Len : Positive) return Path
   with
     Pre    => Len in 1 .. Max_Path,
     Post   => Slice_Path'Result'First = 1
               and then Slice_Path'Result'Length = Len,
     Global => null;

   procedure Build_Session
     (Cfg    : Session_Config;
      Trials : out Trial_List;
      Count  : out Natural)
   with
     Pre    => Config_Ok (Cfg),
     Post   => Count = Cfg.Trial_Count,
     Global => null;
   --  Generate open corridor maps with a canonical start→goal path.

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
               and then Score_Session'Result.Max_Score = Count * 2
               and then Score_Session'Result.Score
                        <= Score_Session'Result.Max_Score,
     Global => null;

end Path_Plan;

--  Number_Grid — Logic Forge clean-room cognitive exercise core.
--  Ada 2023 (ISO/IEC 8652:2023). Fill / check a small NxN grid against
--  row and column sum targets. Variants: single-grid scoring and
--  multi-trial seeded puzzle sessions.

pragma Ada_2022;

package Number_Grid
  with SPARK_Mode => Off
is

   Max_N      : constant Positive := 4;
   Max_Trials : constant Positive := 32;

   type Cell_Value is range 0 .. 99;
   Max_Cell   : constant Cell_Value := 9;
   type Grid is array (Positive range <>, Positive range <>) of Cell_Value;
   type Sum_Vector is array (Positive range <>) of Natural;

   Invalid_Argument : exception;
   --  Raised when size / session parameters are outside educational bounds.

   ---------------------------------------------------------------------------
   -- Single-grid API
   ---------------------------------------------------------------------------

   function In_Bounds (G : Grid) return Boolean is
     (G'First (1) = 1 and then G'First (2) = 1
      and then G'Last (1) in 1 .. Max_N
      and then G'Last (2) = G'Last (1));

   function Row_Sums_Ok (G : Grid; Targets : Sum_Vector) return Boolean
   with
     Pre    => In_Bounds (G)
               and then Targets'First = 1
               and then Targets'Last = G'Last (1),
     Global => null;

   function Col_Sums_Ok (G : Grid; Targets : Sum_Vector) return Boolean
   with
     Pre    => In_Bounds (G)
               and then Targets'First = 1
               and then Targets'Last = G'Last (2),
     Global => null;

   function Solution_Ok
     (G : Grid; Row_Targets, Col_Targets : Sum_Vector) return Boolean
   with
     Pre    => In_Bounds (G)
               and then Row_Targets'First = 1
               and then Row_Targets'Last = G'Last (1)
               and then Col_Targets'First = 1
               and then Col_Targets'Last = G'Last (2),
     Global => null;
   --  True iff every row and every column meets its target sum.

   function Compute_Row_Sum (G : Grid; Row : Positive) return Natural
   with
     Pre    => In_Bounds (G) and then Row in G'Range (1),
     Global => null;

   function Compute_Col_Sum (G : Grid; Col : Positive) return Natural
   with
     Pre    => In_Bounds (G) and then Col in G'Range (2),
     Global => null;

   --  One point per correct row sum plus one per correct column sum.
   function Grid_Score
     (G : Grid; Row_Targets, Col_Targets : Sum_Vector) return Natural
   with
     Pre    => In_Bounds (G)
               and then Row_Targets'First = 1
               and then Row_Targets'Last = G'Last (1)
               and then Col_Targets'First = 1
               and then Col_Targets'Last = G'Last (2),
     Post   => Grid_Score'Result <= 2 * G'Last (1),
     Global => null;

   ---------------------------------------------------------------------------
   -- Session API (deterministic puzzle generation)
   ---------------------------------------------------------------------------

   type Session_Config is record
      Trial_Count : Positive := 4;
      N           : Positive := 2;
      Seed        : Natural := 1;
      Max_Fill    : Cell_Value := 9;
   end record;

   function Config_Ok (Cfg : Session_Config) return Boolean is
     (Cfg.Trial_Count in 1 .. Max_Trials
      and then Cfg.N in 1 .. Max_N
      and then Cfg.Max_Fill in 1 .. 9);

   type Fixed_Grid is array (1 .. Max_N, 1 .. Max_N) of Cell_Value;
   type Fixed_Sums is array (1 .. Max_N) of Natural;

   type Trial is record
      N         : Positive := 1;
      Solution  : Fixed_Grid := [others => [others => 0]];
      Row_Tgt   : Fixed_Sums := [others => 0];
      Col_Tgt   : Fixed_Sums := [others => 0];
   end record;

   type Trial_List is array (1 .. Max_Trials) of Trial;
   --  Trainee answers: filled grids (one per trial).
   type Answer_List is array (1 .. Max_Trials) of Fixed_Grid;

   type Session_Result is record
      Config     : Session_Config;
      Trials_Run : Natural := 0;
      Score      : Natural := 0;
      Max_Score  : Natural := 0;
   end record;

   Instruction_Key : constant String := "number_grid.instruction";
   Prompt_Key      : constant String := "number_grid.prompt_fill";
   Row_Key         : constant String := "number_grid.row_sum";
   Col_Key         : constant String := "number_grid.col_sum";

   function Slice_Grid (F : Fixed_Grid; N : Positive) return Grid
   with
     Pre    => N in 1 .. Max_N,
     Post   => Slice_Grid'Result'First (1) = 1
               and then Slice_Grid'Result'First (2) = 1
               and then Slice_Grid'Result'Last (1) = N
               and then Slice_Grid'Result'Last (2) = N,
     Global => null;

   function Slice_Sums (F : Fixed_Sums; N : Positive) return Sum_Vector
   with
     Pre    => N in 1 .. Max_N,
     Post   => Slice_Sums'Result'First = 1
               and then Slice_Sums'Result'Last = N,
     Global => null;

   procedure Build_Session
     (Cfg    : Session_Config;
      Trials : out Trial_List;
      Count  : out Natural)
   with
     Pre    => Config_Ok (Cfg),
     Post   => Count = Cfg.Trial_Count,
     Global => null;
   --  Fill Trials (1 .. Count) with seeded LCG puzzles. Raises
   --  Invalid_Argument if Config_Ok is False when contracts are off.

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
               and then Score_Session'Result.Max_Score = Count * 2 * Cfg.N
               and then Score_Session'Result.Score
                        <= Score_Session'Result.Max_Score,
     Global => null;
   --  Score each trainee grid against that trial's row/col targets.

end Number_Grid;

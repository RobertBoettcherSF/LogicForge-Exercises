pragma Ada_2022;

package Spatial_Memory is
   Max_Trials : constant Positive := 24;
   Max_N      : constant Positive := 6;
   Max_Marks  : constant Positive := 8;

   type Point is record Row, Col : Positive := 1; end record;
   type Point_List is array (1 .. Max_Marks) of Point;

   Invalid_Argument : exception;

   type Session_Config is record
      Trial_Count : Positive := 6;
      Grid_N      : Positive := 4;
      Mark_Count  : Positive := 3;
      Seed        : Natural := 1;
   end record;

   function Config_Ok (Cfg : Session_Config) return Boolean is
     (Cfg.Trial_Count <= Max_Trials
      and then Cfg.Grid_N in 2 .. Max_N
      and then Cfg.Mark_Count in 1 .. Max_Marks
      and then Cfg.Mark_Count <= Cfg.Grid_N * Cfg.Grid_N);

   type Trial is record
      Marks : Point_List := [others => <>];
      Count : Positive := 1;
   end record;

   type Trial_List is array (1 .. Max_Trials) of Trial;
   type Answer_List is array (1 .. Max_Trials) of Trial;

   type Session_Result is record
      Config     : Session_Config;
      Trials_Run : Natural := 0;
      Score      : Natural := 0;
      Max_Score  : Natural := 0;
   end record;

   Instruction_Key : constant String := "spatial_memory.instruction";
   Prompt_Key      : constant String := "spatial_memory.prompt_marks";

   function Exact_Set_Match (A, B : Trial) return Boolean
   with Global => null;

   function Overlap_Count (A, B : Trial) return Natural
   with Global => null;

   function Trial_Score (Target, Recall : Trial) return Natural
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
end Spatial_Memory;

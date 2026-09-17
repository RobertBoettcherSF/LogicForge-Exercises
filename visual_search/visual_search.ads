pragma Ada_2022;

package Visual_Search is
   Max_Trials : constant Positive := 32;
   Max_Grid   : constant Positive := 8;
   Max_Symbol : constant Positive := 9;

   type Symbol_Id is range 0 .. Max_Symbol;  -- 0 = empty
   type Grid is array (1 .. Max_Grid, 1 .. Max_Grid) of Symbol_Id;
   type Point is record Row, Col : Positive := 1; end record;

   Invalid_Argument : exception;

   type Session_Config is record
      Trial_Count : Positive := 8;
      Size        : Positive := 4;
      Target_Rate : Natural := 70;  -- % trials where target present
      Seed        : Natural := 1;
   end record;

   function Config_Ok (Cfg : Session_Config) return Boolean is
     (Cfg.Trial_Count <= Max_Trials
      and then Cfg.Size in 2 .. Max_Grid
      and then Cfg.Target_Rate <= 100);

   type Trial is record
      Cells         : Grid := [others => [others => 0]];
      Target        : Symbol_Id := 1;
      Target_Present : Boolean := True;
      Target_At     : Point := (1, 1);
   end record;

   type Trial_List is array (1 .. Max_Trials) of Trial;
   type Answer_List is array (1 .. Max_Trials) of Boolean;  -- True = says found

   type Session_Result is record
      Config     : Session_Config;
      Trials_Run : Natural := 0;
      Score      : Natural := 0;
      Max_Score  : Natural := 0;
   end record;

   Instruction_Key : constant String := "visual_search.instruction";
   Prompt_Key      : constant String := "visual_search.prompt_found";

   function Trial_Score (Present, User_Says_Found : Boolean) return Natural
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
end Visual_Search;

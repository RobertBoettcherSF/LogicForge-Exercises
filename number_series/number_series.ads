pragma Ada_2022;

package Number_Series is
   Max_Trials : constant Positive := 24;
   Max_Len    : constant Positive := 8;

   type Rule_Kind is (Add_K, Mul_K);

   Invalid_Argument : exception;

   type Session_Config is record
      Trial_Count : Positive := 8;
      Prefix_Len  : Positive := 4;
      Seed        : Natural := 1;
   end record;

   function Config_Ok (Cfg : Session_Config) return Boolean is
     (Cfg.Trial_Count <= Max_Trials
      and then Cfg.Prefix_Len in 2 .. Max_Len - 1);

   type Int_Seq is array (1 .. Max_Len) of Integer;

   type Trial is record
      Len    : Positive := 3;
      Prefix : Int_Seq := [others => 0];
      Answer : Integer := 0;
      Kind   : Rule_Kind := Add_K;
      K      : Integer := 1;
   end record;

   type Trial_List is array (1 .. Max_Trials) of Trial;
   type Answer_List is array (1 .. Max_Trials) of Integer;

   type Session_Result is record
      Config     : Session_Config;
      Trials_Run : Natural := 0;
      Score      : Natural := 0;
      Max_Score  : Natural := 0;
   end record;

   Instruction_Key : constant String := "number_series.instruction";
   Prompt_Key      : constant String := "number_series.prompt_next";

   function Trial_Score (Expected, Given : Integer) return Natural
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
end Number_Series;

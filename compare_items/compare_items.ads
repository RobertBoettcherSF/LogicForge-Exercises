pragma Ada_2022;

package Compare_Items is
   Max_Trials : constant Positive := 32;

   type Item_Kind is (Number, Word);
   type Item is record
      Kind : Item_Kind := Number;
      Num  : Integer := 0;
      Word : String (1 .. 8) := [others => ' '];
      Len  : Natural := 0;
   end record;

   Invalid_Argument : exception;

   type Session_Config is record
      Trial_Count : Positive := 10;
      Same_Rate   : Natural := 50;
      Seed        : Natural := 1;
   end record;

   function Config_Ok (Cfg : Session_Config) return Boolean is
     (Cfg.Trial_Count <= Max_Trials and then Cfg.Same_Rate <= 100);

   type Trial is record
      Left, Right : Item;
      Same        : Boolean := False;
   end record;

   type Trial_List is array (1 .. Max_Trials) of Trial;
   type Answer_List is array (1 .. Max_Trials) of Boolean;

   type Session_Result is record
      Config : Session_Config;
      Trials_Run, Score, Max_Score : Natural := 0;
   end record;

   Instruction_Key : constant String := "compare_items.instruction";
   Prompt_Key      : constant String := "compare_items.prompt_same";

   function Items_Equal (A, B : Item) return Boolean with Global => null;

   function Trial_Score (Same, User_Says_Same : Boolean) return Natural
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
end Compare_Items;

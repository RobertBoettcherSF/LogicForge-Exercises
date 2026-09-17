pragma Ada_2022;

package Word_Unscramble is
   Max_Trials : constant Positive := 24;
   Max_Len    : constant Positive := 8;

   type Letter is range Character'Pos ('a') .. Character'Pos ('z');
   type Word is array (Positive range <>) of Character;
   type Fixed_Word is array (1 .. Max_Len) of Character;

   Invalid_Argument : exception;

   type Session_Config is record
      Trial_Count : Positive := 6;
      Seed        : Natural := 1;
   end record;

   function Config_Ok (Cfg : Session_Config) return Boolean is
     (Cfg.Trial_Count <= Max_Trials);

   type Trial is record
      Len       : Positive := 3;
      Scrambled : Fixed_Word := [others => ' '];
      Solution  : Fixed_Word := [others => ' '];
   end record;

   type Trial_List is array (1 .. Max_Trials) of Trial;
   type Answer_List is array (1 .. Max_Trials) of Fixed_Word;
   type Len_List is array (1 .. Max_Trials) of Positive;

   type Session_Result is record
      Config     : Session_Config;
      Trials_Run : Natural := 0;
      Score      : Natural := 0;
      Max_Score  : Natural := 0;
   end record;

   Instruction_Key : constant String := "word_unscramble.instruction";
   Prompt_Key      : constant String := "word_unscramble.prompt_word";

   function Exact_Match (A, B : Fixed_Word; Len : Positive) return Boolean
   with Pre => Len <= Max_Len, Global => null;

   function Trial_Score (Guess, Solution : Fixed_Word; Len : Positive) return Natural
   with Pre => Len <= Max_Len, Post => Trial_Score'Result in 0 .. 1, Global => null;

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
end Word_Unscramble;

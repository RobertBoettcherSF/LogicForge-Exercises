pragma Ada_2022;
package Pair_Associate is
   Max_Trials : constant Positive := 24;
   type Label is array (1 .. 8) of Character;
   Invalid_Argument : exception;
   type Session_Config is record
      Trial_Count : Positive := 8;
      Seed : Natural := 1;
   end record;
   function Config_Ok (Cfg : Session_Config) return Boolean is
     (Cfg.Trial_Count <= Max_Trials);
   type Trial is record
      Cue : Label := [others => ' '];
      Cue_Len : Positive := 1;
      Target : Label := [others => ' '];
      Target_Len : Positive := 1;
   end record;
   type Trial_List is array (1 .. Max_Trials) of Trial;
   type Answer_List is array (1 .. Max_Trials) of Label;
   type Len_List is array (1 .. Max_Trials) of Positive;
   type Session_Result is record
      Config : Session_Config;
      Trials_Run, Score, Max_Score : Natural := 0;
   end record;
   Instruction_Key : constant String := "pair_associate.instruction";
   Prompt_Key : constant String := "pair_associate.prompt_pair";
   function Exact_Match (A, B : Label; Len : Positive) return Boolean
   with Pre => Len <= 8, Global => null;
   function Trial_Score (Guess, Target : Label; Len : Positive) return Natural
   with Pre => Len <= 8, Post => Trial_Score'Result in 0 .. 1, Global => null;
   procedure Build_Session
     (Cfg : Session_Config; Trials : out Trial_List; Count : out Natural)
   with Pre => Config_Ok (Cfg), Post => Count = Cfg.Trial_Count, Global => null;
   function Score_Session
     (Cfg : Session_Config; Trials : Trial_List; Count : Natural;
      Answers : Answer_List) return Session_Result
   with Pre => Config_Ok (Cfg) and then Count = Cfg.Trial_Count
               and then Count <= Max_Trials,
        Post => Score_Session'Result.Trials_Run = Count
                and then Score_Session'Result.Max_Score = Count
                and then Score_Session'Result.Score <= Count,
        Global => null;
end Pair_Associate;

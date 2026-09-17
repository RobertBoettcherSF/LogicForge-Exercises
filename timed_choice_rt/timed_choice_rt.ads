--  Timed_Choice_RT — Logic Forge educational exercise (plain Ada 2022).
--  Clean-room: score a timed multiple-choice trial (correctness + latency
--  band). Timing is supplied by the host; this package only scores.
--  No third-party product names or copied task text.

pragma Ada_2022;

package Timed_Choice_RT is

   type Option_Id is range 1 .. 4;

   type Trial is record
      Correct_Option : Option_Id;
      Chosen_Option  : Option_Id;
      Latency_Ms     : Natural;
   end record;

   --  Soft latency ceiling for "fast enough" bonus band (educational).
   Fast_Ms : constant Natural := 1500;

   function Is_Correct (T : Trial) return Boolean is
     (T.Chosen_Option = T.Correct_Option);

   --  2 = correct and fast, 1 = correct but slow, 0 = incorrect.
   function Trial_Score (T : Trial) return Natural
   with Post => Trial_Score'Result in 0 .. 2;

end Timed_Choice_RT;

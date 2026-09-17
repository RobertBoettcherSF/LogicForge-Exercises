--  Rule_Infer — Logic Forge educational exercise (plain Ada 2022).
--  Clean-room: classify whether a probe integer obeys a simple hidden rule
--  learned from positive examples (parity / threshold / mod class).
--  No third-party product names or copied task text.

pragma Ada_2022;

package Rule_Infer is

   type Rule_Kind is (Even, Odd, At_Least, Multiple_Of);

   type Rule is record
      Kind  : Rule_Kind := Even;
      Param : Integer := 0;  -- threshold or modulus when relevant
   end record;

   function Obeys (R : Rule; X : Integer) return Boolean;

   --  Trainee classification score for one probe.
   function Trial_Score
     (R : Rule; X : Integer; User_Says_Yes : Boolean) return Natural
   with Post => Trial_Score'Result in 0 .. 1;

end Rule_Infer;

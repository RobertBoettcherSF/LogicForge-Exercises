--  Recall_Span — Logic Forge educational exercise (plain Ada 2022).
--  Clean-room: compare a presented symbol sequence to the trainee recall
--  (exact prefix length / full match). No third-party product names.

pragma Ada_2022;

package Recall_Span is

   Max_Len : constant Positive := 12;

   type Symbol is range 0 .. 9;
   type Sequence is array (Positive range <>) of Symbol;

   function Exact_Match (Presented, Recalled : Sequence) return Boolean
   with Pre => Presented'First = 1 and then Recalled'First = 1
          and then Presented'Length in 1 .. Max_Len
          and then Recalled'Length in 0 .. Max_Len;

   --  Longest matching prefix length.
   function Prefix_Span (Presented, Recalled : Sequence) return Natural
   with Pre => Presented'First = 1 and then Recalled'First = 1
          and then Presented'Length in 1 .. Max_Len
          and then Recalled'Length in 0 .. Max_Len,
       Post => Prefix_Span'Result <= Presented'Length
          and then Prefix_Span'Result <= Recalled'Length;

end Recall_Span;

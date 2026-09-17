pragma Ada_2022;

package body Recall_Span is

   function Exact_Match (Presented, Recalled : Sequence) return Boolean is
   begin
      if Presented'Length /= Recalled'Length then
         return False;
      end if;
      for I in Presented'Range loop
         if Presented (I) /= Recalled (I) then
            return False;
         end if;
      end loop;
      return True;
   end Exact_Match;

   function Prefix_Span (Presented, Recalled : Sequence) return Natural is
      N : constant Natural :=
        Natural'Min (Presented'Length, Recalled'Length);
   begin
      for I in 1 .. N loop
         if Presented (I) /= Recalled (I) then
            return I - 1;
         end if;
      end loop;
      return N;
   end Prefix_Span;

end Recall_Span;

pragma Ada_2022;

package body Number_Grid is

   function Row_Sums_Ok (G : Grid; Targets : Sum_Vector) return Boolean is
   begin
      for R in G'Range (1) loop
         declare
            S : Natural := 0;
         begin
            for C in G'Range (2) loop
               S := S + Natural (G (R, C));
            end loop;
            if S /= Targets (R) then
               return False;
            end if;
         end;
      end loop;
      return True;
   end Row_Sums_Ok;

   function Col_Sums_Ok (G : Grid; Targets : Sum_Vector) return Boolean is
   begin
      for C in G'Range (2) loop
         declare
            S : Natural := 0;
         begin
            for R in G'Range (1) loop
               S := S + Natural (G (R, C));
            end loop;
            if S /= Targets (C) then
               return False;
            end if;
         end;
      end loop;
      return True;
   end Col_Sums_Ok;

   function Solution_Ok
     (G : Grid; Row_Targets, Col_Targets : Sum_Vector) return Boolean is
   begin
      return Row_Sums_Ok (G, Row_Targets) and then Col_Sums_Ok (G, Col_Targets);
   end Solution_Ok;

end Number_Grid;

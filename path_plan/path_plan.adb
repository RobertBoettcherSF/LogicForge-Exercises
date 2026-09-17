pragma Ada_2022;

package body Path_Plan is

   function On_Map (M : Map; Pt : Point) return Boolean is
     (Pt.R in M'Range (1) and then Pt.C in M'Range (2));

   function Adjacent (A, B : Point) return Boolean is
     ((abs (Integer (A.R) - Integer (B.R))
       + abs (Integer (A.C) - Integer (B.C))) = 1);

   function Is_Valid_Path (M : Map; P : Path) return Boolean is
   begin
      for I in P'Range loop
         if not On_Map (M, P (I)) then
            return False;
         end if;
         if M (P (I).R, P (I).C) = Wall then
            return False;
         end if;
         if I > P'First and then not Adjacent (P (I - 1), P (I)) then
            return False;
         end if;
      end loop;
      return True;
   end Is_Valid_Path;

end Path_Plan;

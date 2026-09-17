--  Number_Grid — Logic Forge educational exercise (plain Ada 2022).
--  Clean-room: fill / check a small numeric grid under simple constraints
--  (row/column sums). No third-party product names or copied task text.

pragma Ada_2022;

package Number_Grid is

   Max_N : constant Positive := 4;

   type Cell_Value is range 0 .. 99;
   type Grid is array (Positive range <>, Positive range <>) of Cell_Value;
   type Sum_Vector is array (Positive range <>) of Natural;

   function In_Bounds (G : Grid) return Boolean is
     (G'First (1) = 1 and then G'First (2) = 1
      and then G'Last (1) in 1 .. Max_N
      and then G'Last (2) = G'Last (1));

   function Row_Sums_Ok (G : Grid; Targets : Sum_Vector) return Boolean
   with Pre => In_Bounds (G)
          and then Targets'First = 1
          and then Targets'Last = G'Last (1);

   function Col_Sums_Ok (G : Grid; Targets : Sum_Vector) return Boolean
   with Pre => In_Bounds (G)
          and then Targets'First = 1
          and then Targets'Last = G'Last (2);

   function Solution_Ok
     (G : Grid; Row_Targets, Col_Targets : Sum_Vector) return Boolean
   with Pre => In_Bounds (G)
          and then Row_Targets'First = 1 and then Row_Targets'Last = G'Last (1)
          and then Col_Targets'First = 1 and then Col_Targets'Last = G'Last (2);

end Number_Grid;

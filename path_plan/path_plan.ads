--  Path_Plan — Logic Forge educational exercise (plain Ada 2022).
--  Clean-room: decide if a path on a small grid is valid (stay in bounds,
--  no wall cells, adjacent steps). No third-party product names.

pragma Ada_2022;

package Path_Plan is

   Max_N : constant Positive := 8;
   Max_Path : constant Positive := 32;

   type Cell is (Open, Wall);
   type Map is array (Positive range <>, Positive range <>) of Cell;
   type Point is record R, C : Positive; end record;
   type Path is array (Positive range <>) of Point;

   function In_Bounds_Map (M : Map) return Boolean is
     (M'First (1) = 1 and then M'First (2) = 1
      and then M'Last (1) in 1 .. Max_N
      and then M'Last (2) in 1 .. Max_N);

   function Is_Valid_Path (M : Map; P : Path) return Boolean
   with Pre => In_Bounds_Map (M)
          and then P'First = 1
          and then P'Length in 1 .. Max_Path;

end Path_Plan;

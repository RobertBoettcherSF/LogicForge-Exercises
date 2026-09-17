pragma Ada_2022;

package body Rule_Infer is

   function Obeys (R : Rule; X : Integer) return Boolean is
   begin
      case R.Kind is
         when Even =>
            return X rem 2 = 0;
         when Odd =>
            return X rem 2 /= 0;
         when At_Least =>
            return X >= R.Param;
         when Multiple_Of =>
            return R.Param /= 0 and then X rem R.Param = 0;
      end case;
   end Obeys;

   function Trial_Score
     (R : Rule; X : Integer; User_Says_Yes : Boolean) return Natural is
   begin
      if User_Says_Yes = Obeys (R, X) then
         return 1;
      else
         return 0;
      end if;
   end Trial_Score;

end Rule_Infer;

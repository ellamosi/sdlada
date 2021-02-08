with Ada.Text_IO; use Ada.Text_IO;
with Ada.Unchecked_Conversion;

package body Audio_Support is

   procedure Callback
     (User        : in SDL.Audio.Devices.User_Data_Access;
      Buffer      : out Buffer_Type;
      Byte_Length : in Positive)
   is
      UD : constant Support_User_Data_Access := Support_User_Data_Access (User);
   begin
      Put_Line ("CB " & UD.Frame_Count'Img & " Len" & Byte_Length'Img & " S" & Integer'Image (Buffer_Type'Last));
      for BI in Buffer'Range loop
         Buffer (BI) := Pulse_Frames (UD.State);
         UD.Frame_Count := UD.Frame_Count + 1;
         if UD.Frame_Count = 100 then
            UD.State := (if UD.State = High then Low else High);
            UD.Frame_Count := 0;
         end if;
      end loop;
   end Callback;

end Audio_Support;

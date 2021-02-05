with Ada.Text_IO; use Ada.Text_IO;
with Interfaces;
with Ada.Unchecked_Conversion;

package body Audio_Support is

   --  TODO: Figure out how to define the buffer types if at all
   type S16SYS_Sample is new Interfaces.Integer_16 with
      Convention => C;

   type S16SYS_2CH_Frame is record
      Left, Right : S16SYS_Sample;
   end record with
     Convention => C;

   type S16SYS_Buffer is array (0 .. 4096 - 1) of S16SYS_2CH_Frame with
     Convention => C;

   type S16SYS_Buffer_Pointer is access S16SYS_Buffer with
     Convention => C;

   function To_Buffer is new Ada.Unchecked_Conversion
     (Source => System.Address,
      Target => S16SYS_Buffer_Pointer);

   procedure Callback
     (User        : in SDL.Audio.Devices.User_Data_Access;
      Stream      : in out System.Address; -- BAD
      Byte_Length : in Positive)
   is
      pragma Unreferenced (Byte_Length);
      UD : constant Support_User_Data_Access := Support_User_Data_Access (User);
      B : constant S16SYS_Buffer_Pointer := To_Buffer (Stream);
      Pulse_Frames : constant array (Pulse_State) of S16SYS_2CH_Frame :=
        (Low  => (S16SYS_Sample'First, S16SYS_Sample'First),
         High => (S16SYS_Sample'Last,  S16SYS_Sample'Last));
   begin
      Put_Line ("CB " & UD.Frame_Count'Img);
      for BI in S16SYS_Buffer'Range loop
         B (BI) := Pulse_Frames (UD.State);
         UD.Frame_Count := UD.Frame_Count + 1;
         if UD.Frame_Count = 100 then
            UD.State := (if UD.State = High then Low else High);
            UD.Frame_Count := 0;
         end if;
      end loop;
   end Callback;

end Audio_Support;

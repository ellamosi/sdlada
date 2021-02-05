with SDL.Audio.Devices;
with System;

package Audio_Support is

   type Support_User_Data is new SDL.Audio.Devices.User_Data with private;

   procedure Callback
     (User        : in SDL.Audio.Devices.User_Data_Access;
      Stream      : in out System.Address; -- BAD
      Byte_Length : in Positive);

private

   type Pulse_State is (Low, High);

   type Support_User_Data is new SDL.Audio.Devices.User_Data with record
      Frame_Count : Natural := 0;
      State       : Pulse_State := Low;
   end record;

   type Support_User_Data_Access is access all Support_User_Data;

end Audio_Support;

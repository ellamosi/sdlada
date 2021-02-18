with SDL.Audio.Devices;
with SDL.Audio.Sample_Formats;
with Interfaces;

package Audio_Support is

   type Support_User_Data is new SDL.Audio.Devices.User_Data with private;

   type Buffer_Type is private;

   Sample_Format : constant SDL.Audio.Sample_Formats.Sample_Format :=
     SDL.Audio.Sample_Formats.Sample_Format_S16SYS;

   Buffer_Size : constant := 2 ** 12;

   procedure Callback
     (User        : in SDL.Audio.Devices.User_Data_Access;
      Buffer      : out Buffer_Type;
      Byte_Length : in Positive)
     with Convention => C;

private

   subtype Sample is Interfaces.Integer_16;

   type Frames is record
      L, R : Sample;
   end record with
     Convention => C;

   type Buffer_Type is array (1 .. Buffer_Size) of Frames with
     Convention => C;

   type Pulse_State is (Low, High);

   Pulse_Frames : constant array (Pulse_State) of Frames :=
     (Low  => (Sample'First, Sample'First),
      High => (Sample'Last,  Sample'Last));

   type Support_User_Data is new SDL.Audio.Devices.User_Data with record
      Frame_Count : Natural := 0;
      State       : Pulse_State := Low;
   end record;

   type Support_User_Data_Access is access all Support_User_Data;

end Audio_Support;

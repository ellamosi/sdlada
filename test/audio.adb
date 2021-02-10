with SDL;
with SDL.Log;
with SDL.Audio;
with SDL.Audio.Devices;
with Audio_Support;

procedure Audio is
   Total_Drivers : Positive;
   Total_Devices : Positive;
   Success : Boolean;

   package Buffered_Devices is new SDL.Audio.Devices.Buffered
     (Buffer_T => Audio_Support.Buffer_Type);

   --  Desired : aliased Buffered_Devices.Spec;
   Desired  : aliased Buffered_Devices.Desired_Spec;
   Obtained : aliased Buffered_Devices.Obtained_Spec;
   --  Desired, Obtained : aliased Buffered_Devices.Spec (Mode => Buffered_Devices.Obtained);
   --  Desired, Obtained : aliased Buffered_Devices.Spec;

   State : aliased Audio_Support.Support_User_Data;
begin
   SDL.Log.Set (Category => SDL.Log.Application, Priority => SDL.Log.Debug);

   Total_Drivers := SDL.Audio.Total_Drivers;
   SDL.Log.Put_Debug ("Total Drivers       : " & Total_Drivers'Img);
   for i in 1 .. Total_Drivers loop
      SDL.Log.Put_Debug ("Driver" & i'Img & "   : " & SDL.Audio.Driver_Name (i));
   end loop;

   Success := SDL.Initialise;
   SDL.Log.Put_Debug ("SDL Init      : " & Success'Img);

   Total_Devices := SDL.Audio.Devices.Total_Devices (False);
   SDL.Log.Put_Debug ("Total Devices       : " & Total_Devices'Img);
   for i in 1 .. Total_Devices loop
      SDL.Log.Put_Debug ("Device" & i'Img & "   : " & SDL.Audio.Devices.Get_Name (i));
   end loop;

   Desired.Frequency := 48_000;
   --  Desired.Frequency := 1_048_576;
   Desired.Format    := Audio_Support.Sample_Format;
   Desired.Channels  := 1;
   Desired.Samples   := Audio_Support.Buffer_Size;
   Desired.Callback  := Audio_Support.Callback'Access;
   Desired.User_Data := State'Unchecked_Access;

   SDL.Log.Put_Debug ("Desired - Frequency : " & Desired.Frequency'Img);
   SDL.Log.Put_Debug ("Desired - Format/Bit_Size : " & Desired.Format.Bit_Size'Img);
   SDL.Log.Put_Debug ("Desired - Format/Float : " & Desired.Format.Float'Img);
   SDL.Log.Put_Debug ("Desired - Format/Big_Endian : " & Desired.Format.Endianness'Img);
   SDL.Log.Put_Debug ("Desired - Format/Signed : " & Desired.Format.Signed'Img);
   SDL.Log.Put_Debug ("Desired - Channels : " & Desired.Channels'Img);
   SDL.Log.Put_Debug ("Desired - Samples : " & Desired.Samples'Img);

   Buffered_Devices.Open
     (Desired  => Desired,
      Obtained => Obtained);

   SDL.Log.Put_Debug ("Obtained - Frequency : " & Obtained.Frequency'Img);
   SDL.Log.Put_Debug ("Obtained - Format/Bit_Size : " & Obtained.Format.Bit_Size'Img);
   SDL.Log.Put_Debug ("Obtained - Format/Float : " & Obtained.Format.Float'Img);
   SDL.Log.Put_Debug ("Obtained - Format/Big_Endian : " & Obtained.Format.Endianness'Img);
   SDL.Log.Put_Debug ("Obtained - Format/Signed : " & Obtained.Format.Signed'Img);
   SDL.Log.Put_Debug ("Obtained - Channels : " & Obtained.Channels'Img);
   SDL.Log.Put_Debug ("Obtained - Samples : " & Obtained.Samples'Img);
   SDL.Log.Put_Debug ("Obtained - Silence : " & Obtained.Silence'Img);
   SDL.Log.Put_Debug ("Obtained - Size : " & Obtained.Size'Img);

   SDL.Audio.Devices.Pause (2, False);

   delay 2.0;

   SDL.Finalise;
end Audio;

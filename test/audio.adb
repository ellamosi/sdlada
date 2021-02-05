with SDL;
with SDL.Log;
with SDL.Audio;
with SDL.Audio.Devices;
with Audio_Support;

procedure Audio is
   Total_Drivers : Positive;
   Total_Devices : Positive;
   Success : Boolean;
   Requested, Obtained : aliased SDL.Audio.Devices.Spec;
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

   Requested.Frequency := 48_000;
      --  Frequency => 1_048_576,
   Requested.Format    := (Bit_Size => 16, Float => False, Big_Endian => False, Signed => True);
   Requested.Channels  := 2;
   Requested.Silence   := 0;
   Requested.Samples   := 4096;
   Requested.Padding   := 0;
   Requested.Callback  := Audio_Support.Callback'Access;
   Requested.User_Data := State'Unchecked_Access;

   SDL.Log.Put_Debug ("Requested - Frequency : " & Requested.Frequency'Img);
   SDL.Log.Put_Debug ("Requested - Format/Bit_Size : " & Requested.Format.Bit_Size'Img);
   SDL.Log.Put_Debug ("Requested - Format/Float : " & Requested.Format.Float'Img);
   SDL.Log.Put_Debug ("Requested - Format/Big_Endian : " & Requested.Format.Big_Endian'Img);
   SDL.Log.Put_Debug ("Requested - Format/Signed : " & Requested.Format.Signed'Img);
   SDL.Log.Put_Debug ("Requested - Channels : " & Requested.Channels'Img);
   SDL.Log.Put_Debug ("Requested - Samples : " & Requested.Samples'Img);
   SDL.Log.Put_Debug ("Requested - Padding : " & Requested.Padding'Img);

   SDL.Audio.Devices.Open
     (Desired  => Requested,
      Obtained => Obtained);

   SDL.Log.Put_Debug ("Obtained - Frequency : " & Obtained.Frequency'Img);
   SDL.Log.Put_Debug ("Obtained - Format/Bit_Size : " & Obtained.Format.Bit_Size'Img);
   SDL.Log.Put_Debug ("Obtained - Format/Float : " & Obtained.Format.Float'Img);
   SDL.Log.Put_Debug ("Obtained - Format/Big_Endian : " & Obtained.Format.Big_Endian'Img);
   SDL.Log.Put_Debug ("Obtained - Format/Signed : " & Obtained.Format.Signed'Img);
   SDL.Log.Put_Debug ("Obtained - Channels : " & Obtained.Channels'Img);
   SDL.Log.Put_Debug ("Obtained - Samples : " & Obtained.Samples'Img);
   SDL.Log.Put_Debug ("Obtained - Padding : " & Obtained.Padding'Img);
   SDL.Log.Put_Debug ("Obtained - Silence : " & Obtained.Silence'Img);
   SDL.Log.Put_Debug ("Obtained - Size : " & Obtained.Size'Img);

   SDL.Audio.Devices.Pause (2, False);

   delay 2.0;

   SDL.Finalise;
end Audio;

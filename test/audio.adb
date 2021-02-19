with SDL;
with SDL.Log;
with SDL.Audio;
with SDL.Audio.Devices;
with Audio_Support;
with System;

procedure Audio is
   Total_Drivers : Positive;
   Total_Devices : Positive;
   Success : Boolean;

   package Buffered_Devices is new SDL.Audio.Devices.Buffered
     (Buffer_T => Audio_Support.Buffer_Type);

   Desired, Obtained : aliased Buffered_Devices.Audio_Spec;

   State : aliased Audio_Support.Support_User_Data;
   Device : SDL.Audio.Devices.ID;

   Buffer : aliased Audio_Support.Buffer_Type;
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
   Desired.Format    := Audio_Support.Sample_Format;
   Desired.Channels  := 2;
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

   SDL.Log.Put_Debug ("Opening Device : " & SDL.Audio.Devices.Get_Name (1));
   Device :=
     Buffered_Devices.Open
       (Name     => SDL.Audio.Devices.Get_Name (1),
        Desired  => Desired,
        Obtained => Obtained);
   SDL.Log.Put_Debug ("Opened Device: " & Device'Img);
   SDL.Log.Put_Debug ("Device Status: " & SDL.Audio.Devices.Get_Status (Device)'Img);

   SDL.Log.Put_Debug ("Obtained - Frequency : " & Obtained.Frequency'Img);
   SDL.Log.Put_Debug ("Obtained - Format/Bit_Size : " & Obtained.Format.Bit_Size'Img);
   SDL.Log.Put_Debug ("Obtained - Format/Float : " & Obtained.Format.Float'Img);
   SDL.Log.Put_Debug ("Obtained - Format/Big_Endian : " & Obtained.Format.Endianness'Img);
   SDL.Log.Put_Debug ("Obtained - Format/Signed : " & Obtained.Format.Signed'Img);
   SDL.Log.Put_Debug ("Obtained - Channels : " & Obtained.Channels'Img);
   SDL.Log.Put_Debug ("Obtained - Samples : " & Obtained.Samples'Img);
   SDL.Log.Put_Debug ("Obtained - Silence : " & Obtained.Silence'Img);
   SDL.Log.Put_Debug ("Obtained - Size : " & Obtained.Size'Img);

   SDL.Log.Put_Debug ("Unpausing Device: " & SDL.Audio.Devices.Get_Status (Device)'Img);
   SDL.Audio.Devices.Pause (Device, False);
   SDL.Log.Put_Debug ("Device Status: " & SDL.Audio.Devices.Get_Status (Device)'Img);

   delay 2.0;

   SDL.Log.Put_Debug ("Closing Device : " & SDL.Audio.Devices.Get_Name (1));
   SDL.Audio.Devices.Close (Device);
   SDL.Log.Put_Debug ("Device Status: " & SDL.Audio.Devices.Get_Status (Device)'Img);

   delay 1.0;

   --  Now attempt using an adio queue
   Desired.Callback := null;

   Device :=
     Buffered_Devices.Open
       (Name     => SDL.Audio.Devices.Get_Name (1),
        Desired  => Desired,
        Obtained => Obtained);

   SDL.Log.Put_Debug ("Unpausing Device: " & SDL.Audio.Devices.Get_Status (Device)'Img);
   SDL.Audio.Devices.Pause (Device, False);
   SDL.Log.Put_Debug ("Device Status: " & SDL.Audio.Devices.Get_Status (Device)'Img);

   for i in 1 .. 20 loop
      Audio_Support.Callback (State'Unchecked_Access, Buffer, Buffer'Size / System.Storage_Unit);
      Buffered_Devices.Queue
        (Device => Device,
         Data   => Buffer);
      delay 0.05;
   end loop;

   SDL.Finalise;
end Audio;

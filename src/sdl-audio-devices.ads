--------------------------------------------------------------------------------------------------------------------
--  Copyright (c) 2021, Eduard Llamosí
--
--  This software is provided 'as-is', without any express or implied
--  warranty. In no event will the authors be held liable for any damages
--  arising from the use of this software.
--
--  Permission is granted to anyone to use this software for any purpose,
--  including commercial applications, and to alter it and redistribute it
--  freely, subject to the following restrictions:
--
--     1. The origin of this software must not be misrepresented; you must not
--     claim that you wrote the original software. If you use this software
--     in a product, an acknowledgment in the product documentation would be
--     appreciated but is not required.
--
--     2. Altered source versions must be plainly marked as such, and must not be
--     misrepresented as being the original software.
--
--     3. This notice may not be removed or altered from any source
--     distribution.
--------------------------------------------------------------------------------------------------------------------
--  SDL.Audio.Devices
--
--  Operating system audio device access and control.
--------------------------------------------------------------------------------------------------------------------
with Ada.Finalization;
with SDL.Audio.Sample_Formats;

package SDL.Audio.Devices is

   Audio_Device_Error : exception;

   type ID is mod 2 ** 32 with
     Convention => C;

   type Audio_Status is (Stopped, Playing, Paused) with Convention => C;

   type Allowed_Changes is mod 2 ** 32 with
     Convention => C,
     Size       => C.int'Size;

   Frequency : constant Allowed_Changes := 16#0000_0001#;
   Format    : constant Allowed_Changes := 16#0000_0002#;
   Channels  : constant Allowed_Changes := 16#0000_0004#;
   Samples   : constant Allowed_Changes := 16#0000_0008#;
   Any       : constant Allowed_Changes := Frequency or Format or Channels or Samples;

   --  Allow users to derive new types from this.
   type User_Data is tagged private;

   type User_Data_Access is access all User_Data'Class;
   pragma No_Strict_Aliasing (User_Data_Access);

   --
   --  The calculated values in this structure are calculated by SDL_OpenAudio().
   --
   --  For multi-channel audio, the default SDL channel mapping is:
   --  2:  FL FR                       (stereo)
   --  3:  FL FR LFE                   (2.1 surround)
   --  4:  FL FR BL BR                 (quad)
   --  5:  FL FR FC BL BR              (quad + center)
   --  6:  FL FR FC LFE SL SR          (5.1 surround - last two can also be BL BR)
   --  7:  FL FR FC LFE BC SL SR       (6.1 surround)
   --  8:  FL FR FC LFE BL BR SL SR    (7.1 surround)
   --
   subtype Channel_Counts is Interfaces.Unsigned_8 with
     Static_Predicate => Channel_Counts in 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8;

   generic
      type Buffer_T is private;
   package Buffered is

      type Audio_Callback is access procedure
        (User        : in User_Data_Access;
         Stream      : out Buffer_T;
         Byte_Length : in Positive)
        with Convention => C;

      type Audio_Spec is record
         Frequency : C.int;
         Format    : SDL.Audio.Sample_Formats.Sample_Format;
         Channels  : Channel_Counts;
         Silence   : Interfaces.Unsigned_8;
         Samples   : Interfaces.Unsigned_16;
         Padding   : Interfaces.Unsigned_16;
         Size      : Interfaces.Unsigned_32;
         Callback  : Audio_Callback;
         User_Data : User_Data_Access;
      end record with
        Convention => C;

      type Audio_Spec_Pointer is access all Audio_Spec with
        Convention => C;

      function Open
        (Desired  : aliased in Audio_Spec;
         Obtained : aliased out Audio_Spec)
         return ID;

      function Open
        (Name       : in String;
         Is_Capture : in Boolean := False;
         Desired    : aliased in Audio_Spec;
         Obtained   : aliased out Audio_Spec)
         return ID;

      procedure Queue
        (Device : in ID;
         Data   : aliased in Buffer_T);

   end Buffered;

   function Total_Devices (Is_Capture : in Boolean := False) return Positive;

   function Get_Name
     (Index : in Positive;
      Is_Capture : in Boolean := False)
      return String;

   function Get_Status (Device : in ID) return Audio_Status with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetAudioDeviceStatus";

   procedure Pause (Pause : in Boolean);

   procedure Pause (Device : in ID; Pause : in Boolean);

   function Get_Queued_Size (Device : in ID) return Interfaces.Unsigned_32;

   procedure Clear_Queued (Device : in ID);

   procedure Close;

   procedure Close (Device : in ID);

private

   type User_Data is new Ada.Finalization.Controlled with null record;

end SDL.Audio.Devices;

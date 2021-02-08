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
--  private with SDL.C_Pointers;
with Ada.Finalization;
with System;
with SDL.Audio.Frame_Formats;

package SDL.Audio.Devices is

   Audio_Device_Error : exception;

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

   type Audio_Callback is access procedure
     (User        : in User_Data_Access;
      Stream      : in out System.Address; -- BAD
      Byte_Length : in Positive);



   type Spec is record
      Frequency : Integer;
      Format    : SDL.Audio.Frame_Formats.Sample_Format;
      Channels  : Interfaces.Unsigned_8;
      Silence   : Interfaces.Unsigned_8;
      Samples   : Interfaces.Unsigned_16;
      Padding   : Interfaces.Unsigned_16;
      Size      : Interfaces.Unsigned_32;
      Callback  : Audio_Callback;
      User_Data : User_Data_Access;
   end record with
     Convention => C;

   generic
      type Buffer_T is private;
   package Buffered is

      type Audio_Callback is access procedure
        (User        : in User_Data_Access;
         Stream      : out Buffer_T;
         Byte_Length : in Positive)
        with Convention => C;

      type Spec is record
         Frequency : C.int;
         Format    : SDL.Audio.Frame_Formats.Sample_Format;
         Channels  : Interfaces.Unsigned_8;
         Silence   : Interfaces.Unsigned_8;
         Samples   : Interfaces.Unsigned_16;
         Padding   : Interfaces.Unsigned_16;
         Size      : Interfaces.Unsigned_32;
         Callback  : Audio_Callback;
         User_Data : User_Data_Access;
      end record with
        Convention => C;

      type Spec_Pointer is access all Spec with
        Convention => C;

      procedure Open
        (Name       : in String := "";
         Is_Capture : in Boolean := False;
         Desired    : aliased in Spec;
         Obtained   : aliased out Spec);

   end Buffered;

--     type Device is new Ada.Finalization.Limited_Controlled with private;

   function Total_Devices (Is_Capture : in Boolean := False) return Positive;

   function Get_Name (Index : in Positive; Is_Capture : in Boolean := False) return String;

   procedure Open
     (Name       : in String := "";
      Is_Capture : in Boolean := False;
      Desired    : aliased in Spec;
      Obtained   : aliased out Spec);

   type Device_Id is mod 2 ** 32 with
     Convention => C;

   procedure Pause (Device : in Device_Id; Pause : in Boolean);

private

   type User_Data is new Ada.Finalization.Controlled with null record;

--     type Device is new Ada.Finalization.Limited_Controlled with
--        record
--           Internal : SDL.C_Pointers.Audio_Spec_Pointer := null;  --  System.Address := System.Null_Address;
--           Owns     : Boolean                        := True;  --  Does this Window type own the Internal data?
--        end record;

   type Spec_Pointer is access all Spec with
     Convention => C;

end SDL.Audio.Devices;

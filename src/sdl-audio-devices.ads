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

package SDL.Audio.Devices is

   Audio_Device_Error : exception;

   type Allowed_Changes is mod 2 ** 32 with
     Convention => C;

   Frequency : constant Allowed_Changes := 16#0000_0001#;
   Format    : constant Allowed_Changes := 16#0000_0002#;
   Channels  : constant Allowed_Changes := 16#0000_0004#;
   Samples   : constant Allowed_Changes := 16#0000_0008#;
   Any       : constant Allowed_Changes := Frequency or Format or Channels or Samples;

   --  Allow users to derive new types from this.
   type User_Data is tagged private;

   type User_Data_Access is access all User_Data'Class;
   pragma No_Strict_Aliasing (User_Data_Access);

   type Sample_Bit_Size is mod 2 ** 8 with
     Convention => C;

   type Sample_Format is record
      Bit_Size   : Sample_Bit_Size;
      Float      : Boolean;
      Big_Endian : Boolean;
      Signed     : Boolean;
   end record with
     Convention => C;
   for Sample_Format use record
      Bit_Size   at 0 range 0 .. 7;
      Float      at 1 range 0 .. 0;
      Big_Endian at 1 range 4 .. 4;
      Signed     at 1 range 7 .. 7;
   end record;

--  /**
--   *  \name Audio format flags
--   *
--   *  Defaults to LSB byte order.
--   */
--  /* @{ */
--  #define AUDIO_U8        0x0008  /**< Unsigned 8-bit samples */
--  #define AUDIO_S8        0x8008  /**< Signed 8-bit samples */
--  #define AUDIO_U16LSB    0x0010  /**< Unsigned 16-bit samples */
--  #define AUDIO_S16LSB    0x8010  /**< Signed 16-bit samples */
--  #define AUDIO_U16MSB    0x1010  /**< As above, but big-endian byte order */
--  #define AUDIO_S16MSB    0x9010  /**< As above, but big-endian byte order */
--  #define AUDIO_U16       AUDIO_U16LSB
--  #define AUDIO_S16       AUDIO_S16LSB
--  /* @} */
--
--  /**
--   *  \name int32 support
--   */
--  /* @{ */
--  #define AUDIO_S32LSB    0x8020  /**< 32-bit integer samples */
--  #define AUDIO_S32MSB    0x9020  /**< As above, but big-endian byte order */
--  #define AUDIO_S32       AUDIO_S32LSB
--  /* @} */
--
--  /**
--   *  \name float32 support
--   */
--  /* @{ */
--  #define AUDIO_F32LSB    0x8120  /**< 32-bit floating point samples */
--  #define AUDIO_F32MSB    0x9120  /**< As above, but big-endian byte order */
--  #define AUDIO_F32       AUDIO_F32LSB
--  /* @} */
--
--  /**
--   *  \name Native audio byte ordering
--   */
--  /* @{ */
--  #if SDL_BYTEORDER == SDL_LIL_ENDIAN
--  #define AUDIO_U16SYS    AUDIO_U16LSB
--  #define AUDIO_S16SYS    AUDIO_S16LSB
--  #define AUDIO_S32SYS    AUDIO_S32LSB
--  #define AUDIO_F32SYS    AUDIO_F32LSB
--  #else
--  #define AUDIO_U16SYS    AUDIO_U16MSB
--  #define AUDIO_S16SYS    AUDIO_S16MSB
--  #define AUDIO_S32SYS    AUDIO_S32MSB
--  #define AUDIO_F32SYS    AUDIO_F32MSB
--  #endif
--  /* @} */

   type Sample_Format_Bis is
     (Format_U8,
      Format_S8,
      Format_U16LSB,
      Format_S16LSB,
      Format_U16MSB,
      Format_S16MSB,
      Format_U16,
      Format_S16,
      Format_S32LSB,
      Format_S32MSB,
      Format_S32,
      Format_F32LSB,
      Format_F32MSB,
      Format_F32,
      Format_U16SYS,
      Format_S16SYS,
      Format_S32SYS,
      Format_F32SYS);

   --  Format_U8 : Sample_Format := (, , 8);

   type Audio_Callback is access procedure
     (User        : in User_Data_Access;
      Stream      : in out System.Address; -- BAD
      Byte_Length : in Positive);

   type Spec is record
      Frequency : Integer;
      Format    : Sample_Format;
      Channels  : Interfaces.Unsigned_8;
      Silence   : Interfaces.Unsigned_8;
      Samples   : Interfaces.Unsigned_16;
      Padding   : Interfaces.Unsigned_16;
      Size      : Interfaces.Unsigned_32;
      Callback  : Audio_Callback;
      User_Data : User_Data_Access;
   end record with
     Convention => C;

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

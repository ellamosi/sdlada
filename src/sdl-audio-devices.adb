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
with Interfaces.C.Strings;
with SDL.Error;
with Ada.Text_IO; use Ada.Text_IO;

package body SDL.Audio.Devices is
   package C renames Interfaces.C;

   --  use type SDL.C_Pointers.Audio_Spec_Pointer;

   function Total_Devices (Is_Capture : in Boolean := False) return Positive is
      function SDL_Get_Num_Audio_Devices (Is_Capture : in SDL_Bool) return C.int with
        Import        => True,
        Convention    => C,
        External_Name => "SDL_GetNumAudioDevices";

      Num : constant C.int := SDL_Get_Num_Audio_Devices (To_Bool (Is_Capture));
   begin
      Put_Line ("SDL_Get_Num_Audio_Devices: " & Num'Img);
      if Num < 0 then
         raise Audio_Device_Error with SDL.Error.Get;
      end if;

      return Positive (Num);
   end Total_Devices;

   function Get_Name (Index : in Positive; Is_Capture : in Boolean := False) return String is
      function SDL_Get_Audio_Device_Name (Index : in C.int; Is_Capture : in SDL_Bool) return C.Strings.chars_ptr with
        Import        => True,
        Convention    => C,
        External_Name => "SDL_GetAudioDeviceName";

      --  Index is zero based, so need to subtract 1 to correct it.
      C_Str : constant C.Strings.chars_ptr := SDL_Get_Audio_Device_Name
        (C.int (Index) - 1, To_Bool (Is_Capture));
   begin
      return C.Strings.Value (C_Str);
   end Get_Name;

   package body Buffered is
      procedure Open
        (Name       : in String := "";
         Is_Capture : in Boolean := False;
         Desired    : aliased in Audio_Spec;
         Obtained   : aliased out Audio_Spec)

      is
         function SDL_Open_Audio_Device
           (C_Name     : in C.Strings.chars_ptr;
            Is_Capture : SDL_Bool;
            D          : in Audio_Spec_Pointer;
            O          : in Audio_Spec_Pointer;
            Allowed_Changes : C.int)
         return C.int
           with
             Import        => True,
             Convention    => C,
             External_Name => "SDL_OpenAudioDevice";

         C_Str  : C.Strings.chars_ptr := C.Strings.Null_Ptr;
         Result : C.int;
      begin
         if Name /= "" then
            C_Str := C.Strings.New_String (Name);

            Result := SDL_Open_Audio_Device
              (C_Name          => C_Str,
               Is_Capture      => To_Bool (Is_Capture),
               D               => Desired'Unrestricted_Access,
               O               => Obtained'Unchecked_Access,
               Allowed_Changes => 0);

            C.Strings.Free (C_Str);
         else
            Result := SDL_Open_Audio_Device
              (C_Name          => C.Strings.Null_Ptr,
               Is_Capture      => To_Bool (Is_Capture),
               D               => Desired'Unrestricted_Access,
               O               => Obtained'Unchecked_Access,
               Allowed_Changes => 0);
         end if;
         Put_Line ("SDL_Open_Audio_Device" & Result'Img);
      end Open;
   end Buffered;

   procedure Pause (Device : in Device_Id; Pause : in Boolean) is
      procedure SDL_Pause_Audio_Device (Dev : in Device_Id; P : in SDL_Bool)
      with
        Import        => True,
        Convention    => C,
        External_Name => "SDL_PauseAudioDevice";
   begin
      SDL_Pause_Audio_Device (Device, To_Bool (Pause));
   end Pause;
end SDL.Audio.Devices;

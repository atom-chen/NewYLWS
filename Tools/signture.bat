@echo off
set base=%1%
set stmp=%base%\stmp
set tmp=%base%\tmp
cd %base%
set src=%2%
set dest=%3%

FilesSignature.exe %src% %tmp%
::move %stmp% %tmp%

::enc_lua_scripts.py %src% %dest%
enc_lua_scripts.py %tmp% %dest%

::pause
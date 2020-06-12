@rem  Run this from within the top-level dir: deploy\clean-build-and-package
@echo on

@set /p VERSION=<version.h
@set VERSION=%VERSION:#define PACK_VERSION "=%
set VERSION=%VERSION:"=%

@echo(
@set YN=y
@set /p YN="Proceed to clean, rebuild, package, and sign version %VERSION% [Yn] ?"

@if "%YN%" == "Y" set YN=y
@if "%YN%" neq "y" exit /b 3

@echo Proceeding

@echo Building 32-bit
del /q /s out
del /q /s build_win32
call .\deploy\win64\build-32.bat sign
if %errorlevel% neq 0 exit /b %errorlevel%

@echo Building 64-bit
del /q /s out
del /q /s build_win64
call .\deploy\win64\build-64.bat sign
if %errorlevel% neq 0 exit /b %errorlevel%

mkdir packages
copy "build_win32\release\Vamp Plugin Pack Installer.exe" "packages\Vamp Plugin Pack Installer %VERSION% 32-bit.exe"
copy "build_win64\release\Vamp Plugin Pack Installer.exe" "packages\Vamp Plugin Pack Installer %VERSION%.exe"

@echo(
@echo Done

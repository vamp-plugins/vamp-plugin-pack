rem  Run this from within the top-level SV dir: deploy\win32\build-32.bat
rem  To build from clean, delete the folder build_win32 first

echo on

set STARTPWD=%CD%

rem  Using Qt Base module thus (in MSVC 2015 developer prompt with x86 vars set):
rem  .\configure -static -static-runtime -release -platform win32-msvc -no-opengl -no-angle -nomake examples -prefix C:\Qt\5.14.1-static-32bit
rem  nmake
rem  nmake install
rem 
rem  Note you also need the Qt SVG module, in which:
rem  c:\qt\5.14.1-static-32bit\bin\qmake.exe qtsvg.pro -r -spec win32-msvc
rem  nmake
rem  nmake install

set QTDIR=C:\Qt\5.14.1-static-msvc2015-32bit
if not exist %QTDIR% (
@   echo Could not find 32-bit Qt in %QTDIR%
@   exit /b 2
)

rem  Not 2019! Its APIs are too new for use in our static build
rem set vcvarsall="C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\VC\Auxiliary\Build\vcvarsall.bat"
set vcvarsall="C:\Program Files (x86)\Microsoft Visual Studio 14.0\VC\vcvarsall.bat"

if not exist %vcvarsall% (
@   echo "Could not find MSVC vars batch file"
@   exit /b 2
)

set SMLNJDIR=C:\Program Files (x86)\SMLNJ
if not exist "%SMLNJDIR%\bin" (
@   echo Could not find SML/NJ, required for Repoint
@   exit /b 2
)

call %vcvarsall% x86
if %errorlevel% neq 0 exit /b %errorlevel%

set ORIGINALPATH=%PATH%
set PATH=%PATH%;%SMLNJDIR%\bin;%QTDIR%\bin
set NAME=Open Source Developer, Christopher Cannam

set ARG=%1
shift
if "%ARG%" == "sign" (
@   echo NOTE: sign option specified, will attempt to codesign exe and msi
@   echo NOTE: starting by codesigning an unrelated executable, so we know
@   echo NOTE: whether it'll work before doing the entire build
copy "%SMLNJDIR%\bin\.run\run.x86-win32.exe" signtest.exe
signtool sign /v /n "%NAME%" /t http://time.certum.pl /fd sha1 /a signtest.exe
if errorlevel 1 exit /b %errorlevel%
signtool verify /pa signtest.exe
if errorlevel 1 exit /b %errorlevel%
del signtest.exe
@   echo NOTE: success
) else (
@   echo NOTE: sign option not specified, will not codesign anything
)

cd %STARTPWD%

call .\repoint install
if %errorlevel% neq 0 exit /b %errorlevel%

rem This is the same as in the 64-bit build
PowerShell -NoProfile -ExecutionPolicy Bypass -Command "& 'deploy\win64\copy-metadata.ps1' "
if %errorlevel% neq 0 exit /b %errorlevel%

rem So is this
call .\deploy\win64\generate-qrc installer.qrc
if %errorlevel% neq 0 exit /b %errorlevel%

mkdir build_win32
cd build_win32

qmake -spec win32-msvc -r -tp vc ..\get-version.pro
if %errorlevel% neq 0 exit /b %errorlevel%

qmake -spec win32-msvc -r -tp vc ..\plugins.pro
if %errorlevel% neq 0 exit /b %errorlevel%

mkdir o

msbuild get-version.vcxproj /t:Build /p:Configuration=Release
if %errorlevel% neq 0 exit /b %errorlevel%
copy release\out\get-version.exe ..\out\

msbuild plugins.sln /t:Build /p:Configuration=Release
if %errorlevel% neq 0 exit /b %errorlevel%
copy release\out\*.dll ..\out\

if "%ARG%" == "sign" (
@echo Signing plugins and version helper
signtool sign /v /n "%NAME%" /t http://time.certum.pl /fd sha1 /a ..\out\*.dll ..\out\*.exe
signtool verify /pa ..\out\*.dll ..\out\*.exe
if %errorlevel% neq 0 exit /b %errorlevel%
)

%QTDIR%\bin\rcc ..\installer.qrc -o o\qrc_installer.cpp
if %errorlevel% neq 0 exit /b %errorlevel%

qmake -spec win32-msvc -r -tp vc ..\installer.pro
if %errorlevel% neq 0 exit /b %errorlevel%

msbuild "Vamp Plugin Pack Installer.vcxproj" /t:Build /p:Configuration=Release
if %errorlevel% neq 0 exit /b %errorlevel%

rem copy %QTDIR%\bin\Qt5Core.dll .\release
rem copy %QTDIR%\bin\Qt5Gui.dll .\release
rem copy %QTDIR%\bin\Qt5Widgets.dll .\release
rem copy %QTDIR%\bin\Qt5Network.dll .\release
rem copy %QTDIR%\bin\Qt5Xml.dll .\release
rem copy %QTDIR%\bin\Qt5Svg.dll .\release
rem copy %QTDIR%\bin\Qt5Test.dll .\release
rem copy %QTDIR%\plugins\platforms\qminimal.dll .\release
rem copy %QTDIR%\plugins\platforms\qwindows.dll .\release
rem copy %QTDIR%\plugins\styles\qwindowsvistastyle.dll .\release

if "%ARG%" == "sign" (
@echo Signing application
signtool sign /v /n "%NAME%" /t http://time.certum.pl /fd sha1 /a release\*.exe release\*.dll
signtool verify /pa "release\Vamp Plugin Pack Installer.exe"
if %errorlevel% neq 0 exit /b %errorlevel%
)

cd ..

set PATH=%ORIGINALPATH%

rem  Run this from within the top-level SV dir: deploy\win64\build-64.bat
rem  To build from clean, delete the folder build_win64 first

echo on

set STARTPWD=%CD%

set QTDIR=C:\Qt\5.13.2\msvc2017_64
if not exist %QTDIR% (
@   echo Could not find 64-bit Qt in %QTDIR%
@   exit /b 2
)

set vcvarsall="C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\VC\Auxiliary\Build\vcvarsall.bat"

if not exist %vcvarsall% (
@   echo "Could not find MSVC vars batch file"
@   exit /b 2
)

call %vcvarsall% amd64

set ORIGINALPATH=%PATH%
set PATH=%PATH%;C:\Program Files (x86)\SMLNJ\bin;%QTDIR%\bin

cd %STARTPWD%

call .\repoint install
if %errorlevel% neq 0 exit /b %errorlevel%

mkdir build_win64
cd build_win64

qmake -spec win32-msvc -r -tp vc ..\vamp-plugin-pack.pro
if %errorlevel% neq 0 exit /b %errorlevel%

msbuild vamp-plugin-pack.sln /t:Build /p:Configuration=Release
if %errorlevel% neq 0 exit /b %errorlevel%

cd ..

set PATH=%ORIGINALPATH%

@echo off

set ME=%0
set DIR=%1
shift

if not defined DIR (
@   echo "Usage: %ME% <directory>"
@   exit /b 2
)

@echo on

@if not exist %DIR% (
@    echo Could not find directory %DIR%, trying release\%DIR%
@    set DIR=release\%DIR%
)

@if not exist %DIR% (
@       echo Could not find directory %DIR%
@       exit /b 2
)

echo( > %DIR%\.something-to-sign

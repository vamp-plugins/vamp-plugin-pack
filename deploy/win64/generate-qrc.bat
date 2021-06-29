@echo off

set ME=%0
set QRC=%1
shift

set IN=%QRC%.in

if not exist %IN% (
    echo Could not find input file %IN%
    exit /b 2
)

@echo on

powershell -Command "(Get-Content %IN%) -replace '@GETVERSION_PRIMARY@', -replace '@SUFFIX@', '.dll' -replace '@EXESUFFIX@', '.exe' | Out-File -encoding ASCII %QRC%"

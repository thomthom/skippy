@echo off
REM This is used to be able to run Skippy directly from source.
REM Add its location to the system PATH.
REM
REM %~dp0 returns the path for this batch file.
REM http://stackoverflow.com/a/659672/486990
REM
REM %* forwards all command arguments to Ruby.
ruby %~dp0../bin/skippy %*

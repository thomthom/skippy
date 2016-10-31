@echo off
REM %~dp0 returns the path for this batch file.
REM http://stackoverflow.com/a/659672/486990
REM
REM %* forwards all command arguments to Ruby.
ruby %~dp0\..\thor\boot.rb %*

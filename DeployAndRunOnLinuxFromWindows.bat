@echo off
  :: E.g. C:\path\to\executable\on\windows\runsOnLinux username@ip.address.or.dns /folder/path/on/linux/
set SRC_PATH=%1
SET SRC_FILENAME=%~nx1 
set REMOTE_SSH=%2
set REMOTE_DEST=%3

scp -p %SRC_PATH% %REMOTE_SSH%:%REMOTE_DEST%
ssh %REMOTE_SSH% chmod 776 %REMOTE_DEST%/%SRC_FILENAME%
ssh %REMOTE_SSH% %REMOTE_DEST%/%SRC_FILENAME%

pause
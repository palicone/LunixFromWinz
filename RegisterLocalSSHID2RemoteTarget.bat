  :: Short info
  :: Pvt/Pub key authentication works by registring your ID public key on a remote machine.
  :: Keys on the local and remote machine are usually stored in .ssh subfolder of the user home folder.
  ::   id_rsa          file contains user's ID pvt key
  ::   id_rsa.pub      file contains user's ID pub key
  ::   authorized_keys file file containes public keys off all users which are registered and allowed to make an inbound SSH connection
  :: SSH login must be done with username on the remote machine and one of the public keys in that user's authorized_keys file.
  
  :: Usage
  :: RegisterLocalSSHID2RemoteTarget.bat <remote address> <remote user name>
  
  :: Example 
  :: RegisterLocalSSHID2RemoteTarget.bat rpi-homeserver pi
  :: RegisterLocalSSHID2RemoteTarget.bat 192.168.7.7 admn
  :: RegisterLocalSSHID2RemoteTarget.bat homeserver.myhome.com admin
  
@ECHO OFF  
SET REMOTE_DESTINATION=%1
SET LOCAL_IDENTITY=%USERNAME%@%COMPUTERNAME%
SET HOME_SSH_FOLDER=%USERPROFILE%\.ssh\
SET SSH_IDENTITY_FILE=%HOME_SSH_FOLDER%id_rsa
SET SSH_PUBLIC_KEY=%HOME_SSH_FOLDER%id_rsa.pub
SET REMOTE_USERNAME=%2

IF NOT EXIST "%HOME_SSH_FOLDER%" MKDIR "%HOME_SSH_FOLDER%"

IF NOT EXIST "%SSH_IDENTITY_FILE%" (
  echo Own SSH identity not found. Creating one...
  ssh-keygen -b 2048 -t rsa -f "%SSH_IDENTITY_FILE%" -q -N ""
) ELSE (
  echo Using existing SSH identity
)

IF NOT EXIST "%SSH_PUBLIC_KEY%" (
  echo SSH public key not found. This is weird - what are you doing. Creating it...
  ssh-keygen -f "%SSH_IDENTITY_FILE%" -y -C %LOCAL_IDENTITY% > "%SSH_PUBLIC_KEY%"
)

IF [%REMOTE_DESTINATION%] EQU [] (
  echo Remote destination not provided
  goto end
) 

IF [%REMOTE_USERNAME%] EQU [] (
  echo Remote username not provided
  goto end
) 

ssh-keygen -R %REMOTE_DESTINATION%

  :: sed -i -e to add newlines at the end (it adds two newlines - don't know why)
ssh %REMOTE_USERNAME%@%REMOTE_DESTINATION% "mkdir -p ~/.ssh && chmod 700 ~/.ssh && touch ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys && sed -i -e '$a\' ~/.ssh/authorized_keys && cat >> ~/.ssh/authorized_keys" < "%SSH_PUBLIC_KEY%"

  :: sort -r to sort to remove identical entries; reverese (-r) to avoid newlines at the start of the authorized_keys
ssh %REMOTE_USERNAME%@%REMOTE_DESTINATION% "cp ~/.ssh/authorized_keys ~/.ssh/authorized_keys.bckp && sort -r ~/.ssh/authorized_keys.bckp | uniq > ~/.ssh/authorized_keys && rm ~/.ssh/authorized_keys.bckp"

ssh %REMOTE_USERNAME%@%REMOTE_DESTINATION% "echo Hellow from SSH without password"

echo "Now use 'ssh %REMOTE_USERNAME%@%REMOTE_DESTINATION%' to start SSH session"

  :: ssh %REMOTE_USERNAME%@%REMOTE_DESTINATION%

:end
exit /b
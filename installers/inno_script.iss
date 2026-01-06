[Setup]
; NOTE: The value of AppId uniquely identifies this application. Do not use the same AppId value in installers for other applications.
; (To generate a new GUID, click Tools | Generate GUID inside the IDE.)
AppId={{22814835-D6A8-4107-B6DF-90518D4D6B9C}
AppName=InvoBharat
AppVersion=1.0
;AppVerName=InvoBharat 1.0
AppPublisher=InvoBharat Team
DefaultDirName={autopf}\InvoBharat
DisableProgramGroupPage=yes
; Remove the following line to run in administrative install mode (install for all users.)
PrivilegesRequired=lowest
OutputDir=.
OutputBaseFilename=InvoBharat_Setup
Compression=lzma
SolidCompression=yes
WizardStyle=modern
SetupIconFile=..\windows\runner\resources\app_icon.ico

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
; IMPORTANT: check the path to your build output. 
; For Flutter, it is usually build\windows\x64\runner\Release\ (for x64)
Source: "..\build\windows\x64\runner\Release\invobharat.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs
; NOTE: Don't use "Flags: ignoreversion" on any shared system files

[Icons]
Name: "{autoprograms}\InvoBharat"; Filename: "{app}\invobharat.exe"
Name: "{autodesktop}\InvoBharat"; Filename: "{app}\invobharat.exe"; Tasks: desktopicon

[Run]
Filename: "{app}\invobharat.exe"; Description: "{cm:LaunchProgram,InvoBharat}"; Flags: nowait postinstall skipifsilent

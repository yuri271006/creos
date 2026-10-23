#define AppName "CreOS"
#ifndef AppVersion
  #define AppVersion "1.3.0"
#endif
#define AppExe "CreOS.exe"
#ifndef BundleDir
  #define BundleDir "..\\..\\dist\\CreOS"
#endif
#ifndef OutputRoot
  #define OutputRoot "..\\..\\dist"
#endif

[Setup]
AppId={{C7CF1438-26B0-45C9-AC30-64C86220D147}
AppName={#AppName}
AppVersion={#AppVersion}
AppPublisher=CreOS Project
AppPublisherURL=https://github.com/yuri271006/creos
AppSupportURL=https://github.com/yuri271006/creos/issues
DefaultDirName={localappdata}\Programs\CreOS
DefaultGroupName=CreOS
DisableProgramGroupPage=yes
PrivilegesRequired=lowest
ArchitecturesAllowed=x64compatible
OutputDir={#OutputRoot}
OutputBaseFilename=CreOS-Setup-{#AppVersion}
Compression=lzma2
SolidCompression=yes
WizardStyle=modern
UninstallDisplayIcon={app}\{#AppExe}
CloseApplications=yes
RestartApplications=no

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "Create desktop shortcut"; GroupDescription: "Shortcuts:"; Flags: unchecked

[Files]
Source: "{#BundleDir}\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{autoprograms}\CreOS"; Filename: "{app}\{#AppExe}"
Name: "{autodesktop}\CreOS"; Filename: "{app}\{#AppExe}"; Tasks: desktopicon

[Run]
Filename: "{app}\{#AppExe}"; Description: "Open CreOS"; Flags: nowait postinstall skipifsilent

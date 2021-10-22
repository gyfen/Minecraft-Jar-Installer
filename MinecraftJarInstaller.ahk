#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

; Get Programfiles(x86) path
EnvGet, pf86, ProgramFiles(x86)

FileCreateDir, %A_AppData%\Minecraft Jar Installer

; Create an .ini file if it doesn't already exist
IfNotExist, %A_AppData%\Minecraft Jar Installer\config.ini
{
FileAppend,
(
[settings]
; default path: C:\Program Files (x86)\Minecraft Launcher\runtime\java-runtime-alpha\windows-x64\java-runtime-alpha\bin\java.exe
path=%pf86%\Minecraft Launcher\runtime\java-runtime-alpha\windows-x64\java-runtime-alpha\bin\java.exe
), %A_AppData%\Minecraft Jar Installer\config.ini
}

; Create README
IfNotExist, %A_AppData%\Minecraft Jar Installer\README.txt
{
FileAppend,
(
Minecraft Jar Installer by Gyfen
--------------------------------

Hello! This program was made to avoid having to install Java when you've already gotten it bundled with Minecraft.
This program was made using Autohotkey and was designed for Windows 10. This may or may not work on newer or older Windows versions.

Have fun! - Gyfen

--------------------------------

USAGE

1) Right-click a .jar file.
2) Hover over "Open with".
3) Click on "Choose another app".
4) Tick the box saying "Always use this app to open .jar files".
5) Click on "More apps".
6) Scroll to the bottom of the list.
7) Click on "Look for another app on this PC".
8) Now browse to the location where you installed this script. By default it is named "MinecraftJarInstaller.exe".
9) Select it and click on "Open" (or double-click the file).
10) Now you might get an error saying "You must set this program as default." Ignore it and click okay.
11) Now open any .jar file from within file explorer and it should work.

--------------------------------

CHANGING THE JAVA EXECUTABLE PATH

The default path for the Java executable bundled with minecraft is "C:\Program Files (x86)\Minecraft Launcher\runtime\java-runtime-alpha\windows-x64\java-runtime-alpha\bin\java.exe".
Your Java executable may be located somewhere else, if you did a custom install.
In that case you would need to find and enter the correct path.

Do the following:
1) Browse to the location where you installed this script. By default it is named "MinecraftJarInstaller.exe".
2) Open the program.
3) On the message box, click "Yes".
4) Browse to the folder where you installed Minecraft.
5) Enter the folder named "runtime".
6) Enter the folder named "java-runtime-alpha".
7) Enter the folder named "windows-x64".
8) Enter the folder named "java-runtime-alpha".
9) Enter the folder named "bin".
10) Search for a file named "java.exe" and click on it.
11) Now click on "Save".

), %A_AppData%\Minecraft Jar Installer\README.txt
}

; Didn't select any file.
if (!Explorer_GetSelection()) {
    Gui, +OwnDialogs ; A GUI needs to own the dialogbox
    OnMessage(0x0053, "WM_HELP") ; Call WM_HELP when the help button is clicked
    MsgBox, 16400, Minecraft Jar Installer, Error: You must set this program as default, and then open a .jar file from within file explorer.
    ExitApp
}

For itemNum, item in Explorer_GetSelection()
    ; Correct filetype
    If (item ~= "\.jar$") {
        IniRead, pathToJar, %A_AppData%\Minecraft Jar Installer\config.ini, settings, path
        Try {
            Run, %pathToJar% -jar "%item%"
        }
        Catch e {
            Gui, +OwnDialogs ; A GUI needs to own the dialogbox
            OnMessage(0x0053, "WM_HELP") ; Call WM_HELP when the help button is clicked
            MsgBox, 16400, Minecraft Jar Installer, Error: The path "%pathToJar%" to the Java executable is invalid.
        }
    }
    ; Opened the script itself
    Else If (item == A_ScriptFullPath) {
        Gui, +OwnDialogs ; A GUI needs to own the dialogbox
        OnMessage(0x0053, "WM_HELP") ; Call WM_HELP when the help button is clicked
        MsgBox, 16452, Minecraft Jar Installer, Would you like to change the path to the Java executable?`nIf you don't know how to progam works, click "Help".
        IfMsgBox Yes
        {
            FileSelectFile, newPathToJar, S, , Please select the a Java executable, java.exe
            IniWrite, %newPathToJar%, %A_AppData%\Minecraft Jar Installer\config.ini, settings, path ; new path gets stored in .ini file.
        }
    }
    ; Incorrect filetype
    Else {
        Gui, +OwnDialogs ; A GUI needs to own the dialogbox
        OnMessage(0x0053, "WM_HELP") ; Call WM_HELP when the help button is clicked
        MsgBox, 16400, Minecraft Jar Installer, Error: Incorrect filetype (must be .jar).
    }
ExitApp

; Triggered when the Help button is clicked
WM_HELP() {
    Run, %A_AppData%\Minecraft Jar Installer\README.txt
    ExitApp
}

Explorer_GetSelection() {
    ; https://www.autohotkey.com/boards/viewtopic.php?style=17&t=60403#p255256

    sel := []
    WinGetClass, winClass, % "ahk_id" . hWnd := WinExist("A")
    If !(winClass ~= "Progman|WorkerW|(Cabinet|Explore)WClass")
        Return

    shellWindows := ComObjCreate("Shell.Application").Windows
    If !(winClass ~= "Progman|WorkerW") {
        For window in shellWindows
            If (hWnd = window.HWND) && (shellFolderView := window.Document)
        Break
    }
    Else shellFolderView := shellWindows.FindWindowSW(0, 0, SWC_DESKTOP := 8, 0, SWFO_NEEDDISPATCH := 1).Document
    For item in shellFolderView.SelectedItems
        sel.Push(item.Path)
    Return sel
}
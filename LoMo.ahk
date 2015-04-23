#NoEnv
#SingleInstance Force
Coordmode, Mouse, Relative
CoordMode, Pixel, Relative
champs := "Ahri|Akali|Alistar|Amumu|Anivia|Annie|Ashe|Blitzcrank|Brand|Braum|Caitlyn|Cassiopeia|Cho'Gath|Corki|Darius|Diana|Dr. Mundo|Draven|Elise|Evelynn|Ezreal|Fiddlesticks|Fiora|Fizz|Galio|Gangplank|Garen|Gragas|Graves|Hecarim|Heimerdinger|Irelia|Janna|Jarvan IV|Jax|Jayce|Jinx|Karma|Karthus|Kassadin|Katarina|Kayle|Kennen|Kha'Zix|Kog'Maw|LeBlanc|Lee|Leona|Lucian|Lulu|Lux Mage|Malphite|Malzahar|Maokai|Master Yi|Miss ortune|Mordekaiser|Morgana|Nami|Nasus|Nautilus|Nidalee|Nocturne|Nunu|Olaf|Orianna|Pantheon|Poppy|Quinn and Valor|Rammus|Renekton|Rengar|Riven|Rumble|Ryze|Sejuani|Shaco|Shen|Shyvana|Singed|Sion|Sivir|Skarner|Sona|Soraka|Swain|Syndra|Talon|Taric|Teemo|Thresh|Tristana|Trundle|Tryndamere|Twisted ate|Twitch|Udyr|Urgot|Varus|Vayne|Veigar|Vel'Koz|Vi|Viktor|Vladimir|Volibear|Warwick|Wukong|Xerath|Xin Zhao|Yasuo|Yorick|Zed|Ziggs|Zilean|Zyra"
, lanes := "ADC|Top|Middle|Bottom|Jungle|Support"
, settings := A_Temp "\lomo_settings.ini"
IniRead, champ, %settings%, settings, champ
IniRead, lane, %settings%, settings, lane
IniRead, lock, %settings%, settings, lock, 0
IniRead, wx, %settings%, settings, wx, 400
IniRead, wy, %settings%, settings, wy, 400

IfInString, champs, %champ%
	StringReplace, champs, champs, %champ%, %champ%|
IfInString, lanes, %lane%
	StringReplace, lanes, lanes, %lane%, %lane%|

gui, add, text, , Select Champion:`n`t*must own*
gui, add, DropDownList, vChamp r30, %champs%
gui, add, text, , Select Lane:
gui, add, DropDownList, vLane r6, %lanes%
gui, add, checkbox, vAutoLock, Autolock champion?
gui, add, checkbox, vAnnounceLane, Announce Lane?
if(lock)
	guicontrol, , autolock, 1
gui, add, button, w120 gStartMonitor , Start Montior
gui, add, button, w120 gExit, Exit
gui, +AlwaysOnTop
gui, show, x400 y400, LoMo
Loop {
	If(A_Index = 1)
		file := "accept"
	Else If(A_Index = 2)
		file := "friendly"
	Else If(A_Index = 3)
		file := "helpful"
	Else If(A_Index = 4)
		file := "teamwork"
	Else If(A_Index = 5)
		file := "honorableopponent"
	Else If(A_Index = 6)
		file := "thumbsup"
	Else Break
	IfExist, %A_Temp%\%file%.png
		Extract_%file%("",1)
	Else Extract_%file%(A_Temp "\" file ".png",1)
}

Return
StartMonitor:
	gui, submit
	If(lane = "") or (champ = ""){
		msgbox, Please select a champion and a lane!
		gui, show, x%wx% y%wy%, LoMo
		Return
	}
	IniWrite, %Champ%, %settings%, settings, champ
	IniWrite, %Lane%, %settings%, settings, lane
	IniWrite, %AutoLock%, %settings%, settings, lock
	WriteIni()
	QueueFailed:
	QueuePop()
	, Start := A_TickCount
	, QueueFailed := 0
	Loop {
		ToolTip, Waiting for Champion Select...,1,1
		PixelSearch, px, py,870, 122, 870, 122, 0xFFFFFF, 0, Fast
		If(ErrorLevel){
			If(A_TickCount - Start > 13000){
				; Queue check has gone for 13 seconds without finding the search box
				ToolTip, Queue Failed - Watching for Another,1,1
				sleep 500
				QueueFailed := 1
				Break
			}
		}
		If (ErrorLevel) or (!WinActive("ahk_class ApolloRuntimeContentWindow")) {
			Continue
		} Else {
			temp := clipboard
			, clipboard := lane "!"
			ToolTip, Found Searchbox!  --  Picking Champ!,1,1
			sleep 300
			If(AnnounceLane)
			{
				Click, 300, 740
				Send, ^v
				sleep 100
				Send, {enter}
			}	
			click, 870, 122
			SendInput, %Champ%
			clipboard := temp
			, temp := ""
			sleep 700
			Click, 325, 200
			If (AutoLock) {
				sleep 350
				click, 820, 500
			}
			ToolTip
			Break
		}
	}
	If(QueueFailed)
		Goto, QueueFailed
	ToolTip, Announced your champ`n`nEnjoy your game!,1,1
	SetTimer, ClearTT, 3000
	gui, show, center, LoMo
	gui, +LastFound
	WinMinimize
Return

Exit:
GuiClose:
	Gui, +LastFound
	WinGetPos, wx, wy
	WriteIni()
	ExitApp
Return




ClearTT:
ToolTip
SetTimer, ClearTT, Off
Return

/*
1220, 75
1220, 95
1220, 123
1220, 150
1220, 173
*/


WriteIni(){
	Global
	IniWrite, wx, %settings%, settings, wx
	IniWrite, wy, %settings%, settings, wy
}

QueuePop(){
	Start := A_TickCount
	LookAgain:
	ImageSearch, x, y, 470, 300, 800, 480, %A_Temp%\lomo_accept.png
	if(ErrorLevel){
		ToolTip, Waiting for Queue to Pop...,1,1
		if(A_TickCount - Start > 300000){
			MsgBox % "Queue took longer than 5 min - there is a problem..`n`RELOADING..."
			Reload
		} Else goto, lookagain
	} Else {
		ToolTip, Found Accept!  --  Clicking!,1,1
		sleep 500
		Click, %x%, %y%
		Return
	}
	Return
}

accept_Get(_What)
{
	Static Size = 1608, Name = "accept.png", Extension = "png", Directory = "C:\Users\Dan\Documents\AHK\LoL"
	, Options = "Size,Name,Extension,Directory"
	;This function returns the size(in bytes), name, filename, extension or directory of the file stored depending on what you ask for.
	If (InStr("," Options ",", "," _What ","))
		Return %_What%
}

Extract_accept(_Filename, _DumpData = 0)
{
	;This function "extracts" the file to the location+name you pass to it.
	Static HasData = 1, Out_Data, Ptr
	Static 1 = "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"
	
	If (!HasData)
		Return -1
	
	If (!Out_Data){
		Ptr := A_IsUnicode ? "Ptr" : "UInt"
		, VarSetCapacity(TD, 2203 * (A_IsUnicode ? 2 : 1))
		
		Loop, 1
			TD .= %A_Index%, %A_Index% := ""
		
		VarSetCapacity(Out_Data, Bytes := 1608, 0)
		, DllCall("Crypt32.dll\CryptStringToBinary" (A_IsUnicode ? "W" : "A"), Ptr, &TD, "UInt", 0, "UInt", 1, Ptr, &Out_Data, A_IsUnicode ? "UIntP" : "UInt*", Bytes, "Int", 0, "Int", 0, "CDECL Int")
		, TD := ""
	}
	
	IfExist, %_Filename%
		FileDelete, %_Filename%
	
	h := DllCall("CreateFile", Ptr, &_Filename, "Uint", 0x40000000, "Uint", 0, "UInt", 0, "UInt", 4, "Uint", 0, "UInt", 0)
	, DllCall("WriteFile", Ptr, h, Ptr, &Out_Data, "UInt", 1608, "UInt", 0, "UInt", 0)
	, DllCall("CloseHandle", Ptr, h)
	
	If (_DumpData)
		VarSetCapacity(Out_Data, 1608, 0)
		, VarSetCapacity(Out_Data, 0)
		, HasData := 0
}

friendly_Get(_What)
{
	Static Size = 1139, Name = "friendly.png", Extension = "png", Directory = "C:\Users\Dan\Documents\AHK\LoL"
	, Options = "Size,Name,Extension,Directory"
	;This function returns the size(in bytes), name, filename, extension or directory of the file stored depending on what you ask for.
	If (InStr("," Options ",", "," _What ","))
		Return %_What%
}

Extract_friendly(_Filename, _DumpData = 0)
{
	;This function "extracts" the file to the location+name you pass to it.
	Static HasData = 1, Out_Data, Ptr
	Static 1 = "iVBORw0KGgoAAAANSUhEUgAAAD4AAAAWCAIAAAAXXLhIAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAJcEhZcwAADsMAAA7DAcdvqGQAAAQISURBVFhH1ZbJL2ZZGIf9D4ZSWrfuYEORIBJBYkjEEFSEnYgxFoL/wLDCwlAJEsNSFRZEghgjhoiVMdgRwUL/Gf1853e+rw7X7SbprlQ/i8/7vue95z733HNPhMV6+NWH3/4W22TQPH51l188xDh8NLhxtOGD4R3qfvgp+tVdrK+DRIV03fgf1P2w9/fgp+hXd7G+DhIV0nXjZ+r2Cgc7qwd7fw9+in51F3tLB4kK6brxM3WutxMH0aQ/Hil6Ych9Kj0DfF91Xf8DsPcLkpWVVVpaWllZiVZhYWF9fb0UQ9g+r7pyO2jQ2jc3N//psLa2prrL7Ozs+Pi4Td6MvU2Q/Pz8p6enpqYm4vPzc+ZU/QXylLS2zSurrhskJCRgjFl6enpubu7o6KjqLicnJ/Pz8zZ5M5JwQb2xsRGH7e1tr7pt8mx3373OF8aMY2NjSkVycnJJSQlBXl6e0qKiIjMSICcnp7W1lV+bx8YmJSUVFxcTZGdnf/r0SUUrEhPDJCkpKQRSJ9ja2kL9D4NpCfB7kJC0+H44WvHgCyVgRhZbqbi6upqZmaF+dnZGenp6uri4qKG5ubmbm5v19XX3Kr2Wvb09ijAxMUGRlautrX14eFCRGfhtaGigjvq3b986OjqodHZ2mlX+WFFRQdrS0hLyjjKEaRjsMwbhYQITG25vb1XkhZJWV1dXVVWRrq6ucmOCoaGhi4sL0xLz+fNn9RCvrKwQU0lMTOzr6yPmQ0xNTSX48uWL7js5OUmKOk5SJzg6Ojo8PDSeH2pqamh44Q1h9q9BY+a1RHNjLhgZGWGjt7W1qYg636tiQH1hYYHg/v5+Y2ODJRdcODAwQB31/f190xvN3qDO4nV1dUlFsJFIUUcA9a9fvxK0t7dTLCgoIOZhpqen6ZReQDQqKjIy8pm6C61cPDw8bHMDU7MBbBIVhRnq7Es6WXg2ugsNy8vL9KiZrUIbBxdyj4+PKgrqnIkEIXXMKLLBeC0EfGARERHhz/kX1AnY5Zubmyq6vKre3d1NkJGRoTqQetXZUdRZ/svLS7zfoa4Thg/O5gY/ddnwq3pmZiZHE8Gr6kgTLC0t8bqoc/iQuup4A5NQ39nZ6e3tfZ96XV0dVx4cHNjccH197VY4QPieFA8ODtIPbAZ+2cEUj4+P6VFDeXk59f7+fmJE7+7uTHtAml8up84Jtru7K3WYmppiiM/6dXXb5UGfP9jc8KKi1IgFiIuLKysr07cFoQa3GZRCWloaZ4BNDKEGufKcfP2KwSoH8VV/OxL1YoffD5YcR9ownMLyBqsc5KdTR5HtHthJT089PT0oyhtkHOLnUpdifHy8/t2QooqgNMQr6vbOHuzwf4b8bGJS62jQqFDlf6seHv4XGUswMUyav2IAAAAASUVORK5CYII="
	
	If (!HasData)
		Return -1
	
	If (!Out_Data){
		Ptr := A_IsUnicode ? "Ptr" : "UInt"
		, VarSetCapacity(TD, 1561 * (A_IsUnicode ? 2 : 1))
		
		Loop, 1
			TD .= %A_Index%, %A_Index% := ""
		
		VarSetCapacity(Out_Data, Bytes := 1139, 0)
		, DllCall("Crypt32.dll\CryptStringToBinary" (A_IsUnicode ? "W" : "A"), Ptr, &TD, "UInt", 0, "UInt", 1, Ptr, &Out_Data, A_IsUnicode ? "UIntP" : "UInt*", Bytes, "Int", 0, "Int", 0, "CDECL Int")
		, TD := ""
	}
	
	IfExist, %_Filename%
		FileDelete, %_Filename%
	
	h := DllCall("CreateFile", Ptr, &_Filename, "Uint", 0x40000000, "Uint", 0, "UInt", 0, "UInt", 4, "Uint", 0, "UInt", 0)
	, DllCall("WriteFile", Ptr, h, Ptr, &Out_Data, "UInt", 1139, "UInt", 0, "UInt", 0)
	, DllCall("CloseHandle", Ptr, h)
	
	If (_DumpData)
		VarSetCapacity(Out_Data, 1139, 0)
		, VarSetCapacity(Out_Data, 0)
		, HasData := 0
}

helpful_Get(_What)
{
	Static Size = 1127, Name = "helpful.png", Extension = "png", Directory = "C:\Users\Dan\Documents\AHK\LoL"
	, Options = "Size,Name,Extension,Directory"
	;This function returns the size(in bytes), name, filename, extension or directory of the file stored depending on what you ask for.
	If (InStr("," Options ",", "," _What ","))
		Return %_What%
}

Extract_helpful(_Filename, _DumpData = 0)
{
	;This function "extracts" the file to the location+name you pass to it.
	Static HasData = 1, Out_Data, Ptr
	Static 1 = "iVBORw0KGgoAAAANSUhEUgAAAEMAAAAVCAIAAACSf8TOAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAJcEhZcwAADsMAAA7DAcdvqGQAAAP8SURBVFhH5ZXJSmRJFIZ9Bru1uzq72wkUSsGFulARcUJxAhVRF46oOOADKOJKxIUKTuBCERxB3OiiHEEcFrpwIQ6giCAu0sfoL+OczIrrzSyzqOrqhvoWyTknzo34/xs3IiP+DJu/QvC3QROD9Ieq23hc/GHxwWDHvxt+M9gxROgEFrqIC5XjIpTiUHUbXdJCdAui3o5t9XYMvj3RdfzIGj8eUeyGIdukWALUR1t83hOZ7geg67kQoW50OJiTAD4nMqy9Bt2ab6OwsLC1tVUTJ7qMIS0tra6urqmpSXMnmZmZZWVlJSUlxKJTPMh3FUDMBNkTXdDQ2dn5+vp6fn6uuWFpaYni2NiY5sG4urpaX1/XxIlogp6eHq/Xe3R0VFNTQ6o6LAoKCmhoaGiQftsG0iUI8M45SUxMZK65uTnNDb29vRSrq6s1D8bBwcHa2pomTkQWPD099fX1aRKM+Ph4cfLGgyCpQPr5FlYfzt2PiYlhrunpac0NHR0dFMvLyzX3eLKzs9m9rKwszT0ecUKQlJRUXFxMQE9ubi6ByCJgkra2tri4OFJeWX5+vgzFxsYmJyfn5OQwRE99fT3FgGKQIy4xSBohD4O+Bydco8w1NTWldg3t7e0U+YKlB8WPj487OzvSKcX9/X3qBHd3d4uLiycnJy8vLzRcXl5ijOX6+/tJBdLb29vt7W1RRgNFvj15jzhx2wgQ5SdCCwZplccEdJu1glBaWkrD+Pg4R0KaKyoqqPPVEeNkdXWV4PDwkKKoYU8eHh4uLi6I5R1xKxCQsodbW1uqIzqaoe7ubukJ6kTlR0X96sfhxA0vlbkmJycREYBPgiJXCg3Pz8+7u7uf/FAfHR2ljpOVlRUCJBL75jKgjx4mQRlBS0uL1OlxO+FTJ6itrRWtvziJdBKuE80NASfyHbMtHBIbemwnm5ub5jkfRUVFPNLY2Pj/ckLMCdnb25O6je1kY2NDiiDPBt2T4+NjiRMSEhj6zk64RphrdnZWc0NXVxfFyspK4qGhIWJ+ZSgjI2NmZobgjRPEEaenp3PiGSJ+44SnSKuqqjjlAwMDxDiRUxquEz04IWhubmaus7MzzQ3z8/MUR0ZGJOUvkhTkdkpJSUHZzc0Nf3mMipOFhYX7+3tGOVRcuNTZUtLh4WEzRxSv7PT01DeL1zsxMcHv8vIyFz3B4ODgd3Bi7mcfmhu05C+imxfJVZaXl2ferw8+S2kQJwT8P6SmpponfMgMoLmBLeXsiW5g3wRJ1YEfdeDnHSfhoNpdyGjASZiIaEEUa/KfO7m+vuZvUeJ3UckG1fstTlSICx3+Sj4aNPkiIlcTk6pkg4wKUlEHfv51J+EjKjX5eZ1ERv4DSj0pxbsEXHcAAAAASUVORK5CYII="
	
	If (!HasData)
		Return -1
	
	If (!Out_Data){
		Ptr := A_IsUnicode ? "Ptr" : "UInt"
		, VarSetCapacity(TD, 1544 * (A_IsUnicode ? 2 : 1))
		
		Loop, 1
			TD .= %A_Index%, %A_Index% := ""
		
		VarSetCapacity(Out_Data, Bytes := 1127, 0)
		, DllCall("Crypt32.dll\CryptStringToBinary" (A_IsUnicode ? "W" : "A"), Ptr, &TD, "UInt", 0, "UInt", 1, Ptr, &Out_Data, A_IsUnicode ? "UIntP" : "UInt*", Bytes, "Int", 0, "Int", 0, "CDECL Int")
		, TD := ""
	}
	
	IfExist, %_Filename%
		FileDelete, %_Filename%
	
	h := DllCall("CreateFile", Ptr, &_Filename, "Uint", 0x40000000, "Uint", 0, "UInt", 0, "UInt", 4, "Uint", 0, "UInt", 0)
	, DllCall("WriteFile", Ptr, h, Ptr, &Out_Data, "UInt", 1127, "UInt", 0, "UInt", 0)
	, DllCall("CloseHandle", Ptr, h)
	
	If (_DumpData)
		VarSetCapacity(Out_Data, 1127, 0)
		, VarSetCapacity(Out_Data, 0)
		, HasData := 0
}

teamwork_Get(_What)
{
	Static Size = 1526, Name = "teamwork.png", Extension = "png", Directory = "C:\Users\Dan\Documents\AHK\LoL"
	, Options = "Size,Name,Extension,Directory"
	;This function returns the size(in bytes), name, filename, extension or directory of the file stored depending on what you ask for.
	If (InStr("," Options ",", "," _What ","))
		Return %_What%
}

Extract_teamwork(_Filename, _DumpData = 0)
{
	;This function "extracts" the file to the location+name you pass to it.
	Static HasData = 1, Out_Data, Ptr
	Static 1 = "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"
	
	If (!HasData)
		Return -1
	
	If (!Out_Data){
		Ptr := A_IsUnicode ? "Ptr" : "UInt"
		, VarSetCapacity(TD, 2091 * (A_IsUnicode ? 2 : 1))
		
		Loop, 1
			TD .= %A_Index%, %A_Index% := ""
		
		VarSetCapacity(Out_Data, Bytes := 1526, 0)
		, DllCall("Crypt32.dll\CryptStringToBinary" (A_IsUnicode ? "W" : "A"), Ptr, &TD, "UInt", 0, "UInt", 1, Ptr, &Out_Data, A_IsUnicode ? "UIntP" : "UInt*", Bytes, "Int", 0, "Int", 0, "CDECL Int")
		, TD := ""
	}
	
	IfExist, %_Filename%
		FileDelete, %_Filename%
	
	h := DllCall("CreateFile", Ptr, &_Filename, "Uint", 0x40000000, "Uint", 0, "UInt", 0, "UInt", 4, "Uint", 0, "UInt", 0)
	, DllCall("WriteFile", Ptr, h, Ptr, &Out_Data, "UInt", 1526, "UInt", 0, "UInt", 0)
	, DllCall("CloseHandle", Ptr, h)
	
	If (_DumpData)
		VarSetCapacity(Out_Data, 1526, 0)
		, VarSetCapacity(Out_Data, 0)
		, HasData := 0
}

honorableopponent_Get(_What)
{
	Static Size = 2376, Name = "honorableopponent.png", Extension = "png", Directory = "C:\Users\Dan\Documents\AHK\LoL"
	, Options = "Size,Name,Extension,Directory"
	;This function returns the size(in bytes), name, filename, extension or directory of the file stored depending on what you ask for.
	If (InStr("," Options ",", "," _What ","))
		Return %_What%
}

Extract_honorableopponent(_Filename, _DumpData = 0)
{
	;This function "extracts" the file to the location+name you pass to it.
	Static HasData = 1, Out_Data, Ptr
	Static 1 = "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"
	
	If (!HasData)
		Return -1
	
	If (!Out_Data){
		Ptr := A_IsUnicode ? "Ptr" : "UInt"
		, VarSetCapacity(TD, 3256 * (A_IsUnicode ? 2 : 1))
		
		Loop, 1
			TD .= %A_Index%, %A_Index% := ""
		
		VarSetCapacity(Out_Data, Bytes := 2376, 0)
		, DllCall("Crypt32.dll\CryptStringToBinary" (A_IsUnicode ? "W" : "A"), Ptr, &TD, "UInt", 0, "UInt", 1, Ptr, &Out_Data, A_IsUnicode ? "UIntP" : "UInt*", Bytes, "Int", 0, "Int", 0, "CDECL Int")
		, TD := ""
	}
	
	IfExist, %_Filename%
		FileDelete, %_Filename%
	
	h := DllCall("CreateFile", Ptr, &_Filename, "Uint", 0x40000000, "Uint", 0, "UInt", 0, "UInt", 4, "Uint", 0, "UInt", 0)
	, DllCall("WriteFile", Ptr, h, Ptr, &Out_Data, "UInt", 2376, "UInt", 0, "UInt", 0)
	, DllCall("CloseHandle", Ptr, h)
	
	If (_DumpData)
		VarSetCapacity(Out_Data, 2376, 0)
		, VarSetCapacity(Out_Data, 0)
		, HasData := 0
}

thumbsup_Get(_What)
{
	Static Size = 458, Name = "thumbsup.png", Extension = "png", Directory = "C:\Users\Dan\Documents\AHK\LoL"
	, Options = "Size,Name,Extension,Directory"
	;This function returns the size(in bytes), name, filename, extension or directory of the file stored depending on what you ask for.
	If (InStr("," Options ",", "," _What ","))
		Return %_What%
}

Extract_thumbsup(_Filename, _DumpData = 0)
{
	;This function "extracts" the file to the location+name you pass to it.
	Static HasData = 1, Out_Data, Ptr
	Static 1 = "iVBORw0KGgoAAAANSUhEUgAAAAsAAAAKCAIAAADtkjPUAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAJcEhZcwAADsMAAA7DAcdvqGQAAAFfSURBVChTAVQBq/4AMocxMYYwInYnf55aZYpFDV8ZM4cxM4kyM4kyM4gzM4kyADGCMCuELAFZFN/Zj97dkwBGDhhpITGALyl9LTCGMjGFMAATZBwYYCAAQhCJom3//7fLznsnYiYZZSEncCkgaiQrfCsAS3c3s8N+v8OHyc+S+/KU//+eo7JsVHEvpZdFK1YcG2ojAH+XVP//t///sP/6ofztjf/1huLeg4aMRO+2WGJwLQhaHAAdViDx4I3/+Jf/9Ij/8YX/+Ijm4HhvgDresVVsdjACVBcAAj8PqaNW/+1+/u18//GA/+l60r5ecn844bVYYnEtBFIWAAFCDzRgJPDFYv/OZv/QaP/TabmMO2hyMOG0WE9oKAZQFgAUWBwAQhFGXyGJeDCHeDCRejFJWR0cShZSZSYeUBoSVhoAFlcZEVEYAEMRAD8PAEEPAD0NAEMSDUkVAEAPDEsVFVcbFC6KDfEyrNAAAAAASUVORK5CYII="
	
	If (!HasData)
		Return -1
	
	If (!Out_Data){
		Ptr := A_IsUnicode ? "Ptr" : "UInt"
		, VarSetCapacity(TD, 628 * (A_IsUnicode ? 2 : 1))
		
		Loop, 1
			TD .= %A_Index%, %A_Index% := ""
		
		VarSetCapacity(Out_Data, Bytes := 458, 0)
		, DllCall("Crypt32.dll\CryptStringToBinary" (A_IsUnicode ? "W" : "A"), Ptr, &TD, "UInt", 0, "UInt", 1, Ptr, &Out_Data, A_IsUnicode ? "UIntP" : "UInt*", Bytes, "Int", 0, "Int", 0, "CDECL Int")
		, TD := ""
	}
	
	IfExist, %_Filename%
		FileDelete, %_Filename%
	
	h := DllCall("CreateFile", Ptr, &_Filename, "Uint", 0x40000000, "Uint", 0, "UInt", 0, "UInt", 4, "Uint", 0, "UInt", 0)
	, DllCall("WriteFile", Ptr, h, Ptr, &Out_Data, "UInt", 458, "UInt", 0, "UInt", 0)
	, DllCall("CloseHandle", Ptr, h)
	
	If (_DumpData)
		VarSetCapacity(Out_Data, 458, 0)
		, VarSetCapacity(Out_Data, 0)
		, HasData := 0
}


f12::Reload



; example of simplified Windows programming using complex macro features

include 'd:\Документы\coding\github.com\Oberon07ru\tools\fasmw\INCLUDE\WIN32AX.INC' ; you can simply switch between win32ax, win32wx, win64ax and win64wx here

.code

  start:
	push eax
	pop eax
	invoke	MessageBox,HWND_DESKTOP,"Hi! I'm the example program!",invoke GetCommandLine,MB_OK
	invoke	ExitProcess,0

.end start

/*******************************************************************************
*	Copyright Erik Pilsits 2008 - 2009
********************************************************************************
*	some functions based on work by Donald Miller and
*	Phoenix1701@gmail.com
********************************************************************************
*	Usage in script:
*
*	!include ProcFunc.nsh
*	!insertmacro ProcessFunction
*
*	[Section|Function]
*		${ProcessFunction} "arg1" "arg2" "..." $var
*	[SectionEnd|FunctionEnd]
********************************************************************************
*	${ProcessExists} "[process]" $var
*
*	"[process]"			"name_of_process.exe"
*						"process_pid" (integer)
*	
*	$var(return)		-2 - EnumProcesses failed
*						0 - process does not exist
*						[pid] - process pid
********************************************************************************
*	${GetProcessPath} "[process]" $var
*
*	"[process]"			"name_of_process.exe"
*						"process_pid" (integer)
*	
*	$var(return)		-2 - EnumProcesses failed
*						0 - process does not exist
*						[path] - path to process
********************************************************************************
*	${GetProcessName} "[PID]" $var
*
*	"[PID]"				"process_pid" (integer)
*
*	$var(return)		-2 - EnumProcesses failed
*						0 - process does not exist
*						[pid] - process pid
********************************************************************************
*	${EnumProcessPaths} "[user_func]" $var
*
*	$var(return)		-2 - EnumProcesses failed
*						1 - success
*
*	Function "user_func"
*		Pop $var1			; matching path string
*		Pop $var2			; matching process PID
*		...user commands
*		Push [1/0]			; must return 1 on the stack to continue
*							; must return some value or corrupt the stack
*							; DO NOT save data in $0-$8
*	FunctionEnd
********************************************************************************
*	${ProcessWait} "[process]" "[timeout]" $var
*
*	"[process]"			"name_of_process.exe"
*
*	"[timeout]"			-1 - do not timeout
*						> 0 - timeout value in milliseconds
*
*	$var(return)		-2 - EnumProcesses failed
*						-1 - operation timed out
*						[pid] - pid of process
********************************************************************************
*	${ProcessWait2} "[process]" "[timeout]" $var
*
*	"[process]"			"name_of_process.exe"
*
*	"[timeout]"			-1 - do not timeout
*						> 0 - timeout value in milliseconds
*
*	$var(return)		-1 - operation timed out
*						[pid] - pid of process
********************************************************************************
*	${ProcessWaitClose} "[process]" "[timeout]" $var
*
*	"[process]"			"name_of_process.exe"
*						"process_pid" (integer)
*
*	"[timeout]"			-1 - do not timeout
*						> 0 - timeout value in milliseconds
*
*	$var(return)		-1 - operation timed out
*						0 - process does not exist
*						[pid] - pid of ended process
********************************************************************************
*	${CloseProcess} "[process]" $var
*
*	"[process]"			"name_of_process.exe"
*						"process_pid" (integer)
*
*	$var(return)		0 - process does not exist
*						[pid] - pid of ended process
********************************************************************************
*	${TerminateProcess} "[process]" $var
*
*	"[process]"			"name_of_process.exe"
*						"process_pid" (integer)
*
*	$var(return)		-1 - operation failed
*						0 - process does not exist
*						[pid] - pid of ended process
********************************************************************************
*	${Execute} "[cmdline]" "[working_dir]" $var
*
*	"[cmdline]"			'"X:\path\to\prog.exe" arg1 arg2 "arg3 with space"'
*
*	"[working_dir]"		"X:\path\to\dir"
*						"" (if not needed)
*
*	$var(return)		0 - failed to create process
*						[pid] - pid of new process
********************************************************************************/

!ifndef PROCFUNC_INCLUDED
!define PROCFUNC_INCLUDED

!include LogicLib.nsh

!define PROCESS_QUERY_INFORMATION 0x0400
!define PROCESS_TERMINATE 0x0001
!define PROCESS_VM_READ 0x0010
!define SYNCHRONIZE 0x00100000L

!define WAIT_TIMEOUT 0x00000102L

!macro ProcessExists
	!ifndef ProcessExists
		!insertmacro ProcFuncs
		!define ProcessExists "!insertmacro _ProcessExistsCall"
	!endif
!macroend

!macro _ProcessExistsCall process outVar
	Push 0
	Push `${process}`
	Call ProcFuncs
	Pop ${outVar}
!macroend

!macro GetProcessPath
	!ifndef GetProcessPath
		!insertmacro ProcFuncs
		!define GetProcessPath "!insertmacro _GetProcessPathCall"
	!endif
!macroend

!macro _GetProcessPathCall process outVar
	Push 1
	Push `${process}`
	Call ProcFuncs
	Pop ${outVar}
!macroend

!macro GetProcessName
	!ifndef GetProcessName
		!insertmacro ProcFuncs
		!define GetProcessName "!insertmacro _GetProcessNameCall"
	!endif
!macroend

!macro _GetProcessNameCall process outVAR
	Push 4
	Push `${process}`
	Call ProcFuncs
	Pop ${outVar}
!macroend

!macro _EnumProcessPathsCall user_func outVar
	Push $0
	GetFunctionAddress $0 `${user_func}`
	Push `$0`
	Call EnumProcessPaths
	Exch
	Pop $0
	Pop ${outVar}
!macroend

!macro _ProcessWaitCall process timeout outVar
	Push `${timeout}`
	Push `${process}`
	Call ProcessWait
	Pop ${outVar}
!macroend

!macro _ProcessWait2Call process timeout outVar
	Push `${timeout}`
	Push `${process}`
	Call ProcessWait2
	Pop ${outVar}
!macroend

!macro _ProcessWaitCloseCall process timeout outVar
	Push `${timeout}`
	Push `${process}`
	Call ProcessWaitClose
	Pop ${outVar}
!macroend

!macro _CloseProcessCall process outVar
	Push `${process}`
	Call CloseProcess
	Pop ${outVar}
!macroend

!macro _TerminateProcessCall process outVar
	Push `${process}`
	Call TerminateProcess
	Pop ${outVar}
!macroend

!macro _ExecuteCall cmdline wrkdir outVar
	Push `${wrkdir}`
	Push `${cmdline}`
	Call Execute
	Pop ${outVar}
!macroend

!macro ProcFuncs
	!ifndef ProcFuncs
		!define ProcFuncs
		Function ProcFuncs
			Exch $0 ; process / PID
			Exch
			Exch $1 ; mode
			Push $2
			Push $3
			Push $4
			Push $5
			Push $6
			Push $7
			
			Push 0 ; set return value if not found
			
			; set mode of operation in $1
			${Select} $1 ; mode 0 = ProcessExists, mode 1 = GetProcessPath
				${Case} 0
					StrCpy $2 $0 4 -4
					${If} $2 == ".exe"
						; exists from process name
						StrCpy $1 0
					${Else}
						; exists from pid
						StrCpy $1 2
					${EndIf}
				${Case} 1
					StrCpy $2 $0 4 -4
					${If} $2 == ".exe"
						; get path from process name
						StrCpy $1 1
					${Else}
						; get path from pid
						StrCpy $1 3
					${EndIf}
			${EndSelect}
			
			${Select} $1
				; ProcessExists or GetProcessPath from process name
				${Case2} 0 1
					System::Alloc 1024
					Pop $2 ; process list buffer
					
					; get an array of all process ids
					System::Call 'psapi::EnumProcesses(i r2, i 1024, *i .r3)i .r4' ; $3 = sizeof buffer
					
					${Unless} $4 = 0
						IntOp $3 $3 / 4 ; Divide by sizeof(DWORD) to get $3 process count
						IntOp $3 $3 - 1 ; decr for 0 base loop
						
						${For} $4 0 $3
							; get a PID from the array
							IntOp $5 $4 * 4 ; calculate offset
							IntOp $5 $5 + $2 ; add offset to original buffer address
							System::Call '*$5(i .r5)' ; Get next PID = $5
							
							${Unless} $5 = 0
								System::Call 'kernel32::OpenProcess(i "${PROCESS_QUERY_INFORMATION}|${PROCESS_VM_READ}", i 0, i r5)i .r6'
								
								${Unless} $6 = 0 ; $6 is hProcess
									; get BaseName; params: Pid, hMod, szBuffer, sizeof(szBuffer)
									System::Call 'psapi::GetModuleBaseName(i r6, i 0, t .r7, i ${NSIS_MAX_STRLEN})i'
									
									; is this process one we are looking for?
									${If} $7 == $0
										${Select} $1 ; mode 0 = ProcessExists, mode 1 = GetProcessPath
											${Case} 0
												; return pid
												Pop $7 ; old return value
												Push $5 ; process pid
											${Case} 1
												; full path to stack
												Pop $7 ; old return value
												System::Call 'psapi::GetModuleFileNameEx(i r6, i 0, t .s, i ${NSIS_MAX_STRLEN})i'
										${EndSelect}
										System::Call 'kernel32::CloseHandle(i r6)'
										${Break}
									${EndIf}
									System::Call 'kernel32::CloseHandle(i r6)'
								${EndUnless}
							${EndUnless}
						${Next}
					${Else}
						Pop $7
						Push -2 ; function failure return value
					${EndUnless}
					
					System::Free $2 ; free buffer, unload System DLL
					
				; ProcessExists or GetProcessPath from process pid / GetProcessName from PID
				${Case3} 2 3 4
					System::Call 'kernel32::OpenProcess(i "${PROCESS_QUERY_INFORMATION}|${PROCESS_VM_READ}", i 0, i r0)i .r2'
					${Unless} $2 = 0 ; $2 is hProcess
						${Select} $1 ; mode 2 = ProcessExists, mode 3 = GetProcessPath, mode 4 = GetProcessName
							${Case} 2
								; PID to stack
								Pop $3 ; old return value
								Push $0 ; PID
							${Case} 3
								; full path to stack
								Pop $3 ; old return value
								System::Call 'psapi::GetModuleFileNameEx(i r2, i 0, t .s, i ${NSIS_MAX_STRLEN})i'
							${Case} 4
								; basename to stack
								Pop $3 ; old return val
								System::Call 'psapi::GetModuleBaseName(i r2, i 0, t .s, i ${NSIS_MAX_STRLEN})i'
						${EndSelect}
						System::Call 'kernel32::CloseHandle(i r2)'
					${EndUnless}
			${EndSelect}
			
			Exch 8 ; place return value at bottom of stack
			; restore registers
			Pop $0 ; pop $0 first because of Exch 8
			Pop $7
			Pop $6
			Pop $5
			Pop $4
			Pop $3
			Pop $2
			Pop $1
		FunctionEnd
	!endif
!macroend

!macro EnumProcessPaths
	!ifndef EnumProcessPaths
		!define EnumProcessPaths "!insertmacro _EnumProcessPathsCall"
		Function EnumProcessPaths
			Exch $0 ; user_func
			Push $1
			Push $2
			Push $3
			Push $4
			Push $5
			Push $6
			Push $7
			Push $8
			
			StrCpy $1 1 ; OK to loop
			
			System::Alloc 1024
			Pop $2 ; process list buffer
			
			; get an array of all process ids
			System::Call 'psapi::EnumProcesses(i r2, i 1024, *i .r3)i .r4' ; $3 = sizeof buffer
			
			${Unless} $4 = 0
				IntOp $3 $3 / 4 ; Divide by sizeof(DWORD) to get $4 process count
				IntOp $3 $3 - 1 ; decr for 0 base loop
				
				${For} $4 0 $3
					${IfThen} $1 != 1 ${|} ${Break} ${|}
					; get a PID from the array
					IntOp $5 $4 * 4 ; calculate offset
					IntOp $5 $5 + $2 ; add offset to original buffer address
					System::Call '*$5(i .r5)' ; get next PID = $5
					
					${Unless} $5 = 0
						System::Call 'kernel32::OpenProcess(i "${PROCESS_QUERY_INFORMATION}|${PROCESS_VM_READ}", i 0, i r5)i .r6'
						
						${Unless} $6 = 0 ; $6 is hProcess
							; get full path
							System::Call 'psapi::GetModuleFileNameEx(i r6, i 0, t .r7, i ${NSIS_MAX_STRLEN})i .r8' ; $7 = path
							${Unless} $8 = 0 ; no path
								Push $0 ; save registers
								Push $1
								Push $3
								Push $4
								Push $5
								Push $6
								Push $7
								Push $5 ; PID to stack
								Push $7 ; path to stack
								Call $0 ; user func must return 1 on the stack to continue looping
								Pop $1 ; continue?
								Pop $7 ; restore registers
								Pop $6
								Pop $5
								Pop $4
								Pop $3
								Pop $1
								Pop $0
							${EndUnless}
							System::Call 'kernel32::CloseHandle(i r6)'
						${EndUnless}
					${EndUnless}
				${Next}
				Push 1 ; return value
			${Else}
				Push -2 ; function failure return value
			${EndUnless}
			
			System::Free $2 ; free buffer, unload System DLL
			
			Exch 9
			Pop $0
			Pop $8
			Pop $7
			Pop $6
			Pop $5
			Pop $4
			Pop $3
			Pop $2
			Pop $1
		FunctionEnd
	!endif
!macroend

!macro ProcessWait
	!ifndef ProcessWait
		!define ProcessWait "!insertmacro _ProcessWaitCall"
		Function ProcessWait
			Exch $0 ; process
			Exch
			Exch $1 ; timeout
			Push $2
			Push $3
			Push $4
			Push $5
			Push $6
			Push $7
			Push $8
			Push $9
			
			StrCpy $8 1 ; initialize loop
			StrCpy $9 0 ; initialize timeout counter
				
			System::Alloc 1024
			Pop $2 ; process list buffer
			
			${DoWhile} $8 = 1 ; processwait loop
				; get an array of all process ids
				System::Call 'psapi::EnumProcesses(i r2, i 1024, *i .r3)i .r4' ; $3 = sizeof buffer
				
				${Unless} $4 = 0
					IntOp $3 $3 / 4 ; Divide by sizeof(DWORD) to get $3 process count
					IntOp $3 $3 - 1 ; decr for 0 base loop
					
					${For} $4 0 $3
						; get a PID from the array
						IntOp $5 $4 * 4 ; calculate offset
						IntOp $5 $5 + $2 ; add offset to original buffer address
						System::Call '*$5(i .r5)' ; Get next PID = $5
						
						${Unless} $5 = 0
							System::Call 'kernel32::OpenProcess(i "${PROCESS_QUERY_INFORMATION}|${PROCESS_VM_READ}", i 0, i r5)i .r6'
							
							${Unless} $6 = 0 ; $6 is hProcess
								; get BaseName; params: Pid, hMod, szBuffer, sizeof(szBuffer)
								System::Call 'psapi::GetModuleBaseName(i r6, i 0, t .r7, i ${NSIS_MAX_STRLEN})i'
								System::Call 'kernel32::CloseHandle(i r6)'
								; is this process one we are looking for?
								${If} $7 == $0
									; exists, return pid
									Push $5 ; process pid
									StrCpy $8 0 ; end loop
									${Break}
								${EndIf}
							${EndUnless}
						${EndUnless}
					${Next}
					; timeout loop
					${If} $8 = 1
						${If} $1 >= 0
							IntOp $9 $9 + 500 ; increment timeout counter
						${AndIf} $9 >= $1 ; timed out, break loop
							Push -1 ; timeout return value
							${Break} ; end loop if timeout
						${EndIf}
						Sleep 500 ; pause before looping
					${EndIf}
				${Else}
					Push -2 ; function failure return value
					${Break} ; end if enumprocesses fails
				${EndUnless}
			${Loop} ; processwaitloop
			
			System::Free $2 ; free buffer, unload System DLL
			
			Exch 10 ; place return value at bottom of stack
			; restore registers
			Pop $0 ; pop $0 first
			Pop $9
			Pop $8
			Pop $7
			Pop $6
			Pop $5
			Pop $4
			Pop $3
			Pop $2
			Pop $1
		FunctionEnd
	!endif
!macroend

!macro ProcessWait2
	!ifndef ProcessWait2
		!define ProcessWait2 "!insertmacro _ProcessWait2Call"
		!insertmacro ProcessExists
		Function ProcessWait2
			Exch $0 ; process
			Exch
			Exch $1 ; timeout
			Push $2
			Push $R0 ; FindProcDLL return value
			
			StrCpy $2 0 ; initialize timeout counter
			
			${Do}
				FindProcDLL::FindProc $0
				${If} $1 >= 0
					IntOp $2 $2 + 250
				${AndIf} $2 >= $1
					Push -1 ; timeout return value
					${Break}
				${EndIf}
				Sleep 250
			${LoopUntil} $R0 = 1
			
			${If} $R0 = 1 ; success, get pid
				${ProcessExists} $0 $0
				Push $0 ; return pid
			${EndIf}
			
			Exch 4
			Pop $0
			Pop $R0
			Pop $2
			Pop $1
		FunctionEnd
	!endif
!macroend

!macro ProcessWaitClose
	!ifndef ProcessWaitClose
		!define ProcessWaitClose "!insertmacro _ProcessWaitCloseCall"
		!insertmacro ProcessExists
		Function ProcessWaitClose
			Exch $0 ; process / PID
			Exch
			Exch $1 ; timeout
			Push $2
			
			; passed process name or pid
			StrCpy $2 $0 4 -4
			${If} $2 == ".exe"
				; get process pid
				${ProcessExists} $0 $0
			${EndIf}
			
			; else passed pid directly
			
			${Unless} $0 = 0
				System::Call 'kernel32::OpenProcess(i "${SYNCHRONIZE}", i 0, i r0)i .r2'
				${Unless} $2 = 0 ; $2 is hProcess
					System::Call 'kernel32::WaitForSingleObject(i r2, i $1)i .r1'
					${If} $1 = "${WAIT_TIMEOUT}"
						Push -1 ; timed out
					${Else}
						Push $0 ; return pid of ended process
					${EndIf}
					System::Call 'kernel32::CloseHandle(i r2)'
				${Else}
					Push 0 ; failure return value
				${EndUnless}
			${Else}
				Push 0 ; failure return value
			${EndUnless}
			
			Exch 3
			Pop $0
			Pop $2
			Pop $1
		FunctionEnd
	!endif
!macroend

!macro CloseProcess
	!ifndef CloseProcess
		!define CloseProcess "!insertmacro _CloseProcessCall"
		!insertmacro ProcessExists
		Function CloseProcess
			Exch $0 ; process / PID
			Push $1
			Push $2
			Push $3
			Push $4
			
			; passed process name or pid
			StrCpy $1 $0 4 -4
			${If} $1 == ".exe"
				; get process pid
				${ProcessExists} $0 $0
			${EndIf}
			
			; else passed pid directly
			
			${Unless} $0 = 0 ; $0 = target pid
				Push $0 ; return pid of process
				; use EnumWindows and a callback
				System::Get '(i .r1, i)i sr4' ; $1 = hwnd, $4 = callback#, s (stack) = source for return value
				Pop $3 ; $3 = callback address
				System::Call 'user32::EnumWindows(k r3, i)i' ; enumerate top-level windows
				${DoWhile} $4 == "callback1"
					System::Call 'user32::GetWindowThreadProcessId(i r1, *i .r2)i' ; $2 = pid that created the window
					${If} $2 = $0 ; match to target pid
						SendMessage $1 16 0 0 /TIMEOUT=1  ; send WM_CLOSE to all top-level windows owned by process, timeout immediately
					${EndIf}
					Push 1 ; callback return value; keep enumerating windows (returning 0 stops)
					StrCpy $4 "" ; clear callback#
					System::Call '$3' ; return from callback
				${Loop}
				System::Free $3 ; free callback
			${Else}
				Push 0 ; failure return value
			${EndUnless}
			
			Exch 5
			Pop $0
			Pop $4
			Pop $3
			Pop $2
			Pop $1
		FunctionEnd
	!endif
!macroend

!macro TerminateProcess
	!ifndef TerminateProcess
		!define TerminateProcess "!insertmacro _TerminateProcessCall"
		!insertmacro ProcessExists
		Function TerminateProcess
			Exch $0 ; process / PID
			Push $1
			Push $2
			
			; passed process name or pid
			StrCpy $1 $0 4 -4
			${If} $1 == ".exe"
				; get process pid
				${ProcessExists} $0 $0
			${EndIf}
			
			; else passed pid directly
			
			${Unless} $0 = 0
				System::Call 'kernel32::OpenProcess(i "${PROCESS_TERMINATE}", i 0, i r0)i .r1'
				${Unless} $1 = 0 ; $1 is hProcess
					System::Call 'kernel32::TerminateProcess(i r1, i 0)i .r1'
					${If} $1 = 0 ; fail
						Push -1
					${Else}
						Push $0 ; return pid of ended process
					${EndIf}
					System::Call 'kernel32::CloseHandle(i r1)'
				${Else}
					Push 0 ; failure return value
				${EndUnless}
			${Else}
				Push 0 ; failure return value
			${EndUnless}
			
			Exch 3
			Pop $0
			Pop $2
			Pop $1
		FunctionEnd
	!endif
!macroend

!macro Execute
	!ifndef Execute
		!define Execute "!insertmacro _ExecuteCall"
		Function Execute
			Exch $0 ; cmdline
			Exch
			Exch $1 ; wrkdir
			Push $2
			Push $3
			Push $4
			Push $5
			Push $6
			
			System::Alloc 68 ; 4*16 + 2*2 / STARTUPINFO structure = $2
			Pop $2
			System::Call '*$2(i 68)' ; set cb = sizeof(STARTUPINFO)
			System::Call '*(i, i, i, i)i .r3' ; PROCESS_INFORMATION structure = $3
			
			${If} $1 == ""
				StrCpy $1 "i"
			${Else}
				StrCpy $1 't "$1"'
			${EndIf}
			
			System::Call `kernel32::CreateProcess(i, t '$0', i, i, i 0, i 0, i, $1, i r2, i r3)i .r4` ; return 0 if fail
			${Unless} $4 = 0 ; failed to create process
				System::Call '*$3(i .r4, i .r5, i .r6)' ; read handles and PID
				System::Call 'kernel32::CloseHandle(i $4)' ; close hProcess
				System::Call 'kernel32::CloseHandle(i $5)' ; close hThread
				Push $6 ; return PID
			${Else}
				Push 0 ; return val if failed
			${EndUnless}
			
			System::Free $2 ; free STARTUPINFO struct
			System::Free $3 ; free PROCESS_INFORMATION struct
			
			Exch 7
			Pop $0
			Pop $6
			Pop $5
			Pop $4
			Pop $3
			Pop $2
			Pop $1
		FunctionEnd
	!endif
!macroend

!endif ; PROCFUNC_INCLUDED

/****************************************************************************
	Functions
	=========
	
	HANDLE WINAPI OpenProcess(
	__in  DWORD dwDesiredAccess,
	__in  BOOL bInheritHandle,
	__in  DWORD dwProcessId
	);
	
	BOOL WINAPI CreateProcess(
	__in_opt     LPCTSTR lpApplicationName,
	__inout_opt  LPTSTR lpCommandLine,
	__in_opt     LPSECURITY_ATTRIBUTES lpProcessAttributes,
	__in_opt     LPSECURITY_ATTRIBUTES lpThreadAttributes,
	__in         BOOL bInheritHandles,
	__in         DWORD dwCreationFlags,
	__in_opt     LPVOID lpEnvironment,
	__in_opt     LPCTSTR lpCurrentDirectory,
	__in         LPSTARTUPINFO lpStartupInfo,
	__out        LPPROCESS_INFORMATION lpProcessInformation
	);
	
	typedef struct _STARTUPINFO {
	DWORD cb;
	LPTSTR lpReserved;
	LPTSTR lpDesktop;
	LPTSTR lpTitle;
	DWORD dwX;
	DWORD dwY;
	DWORD dwXSize;
	DWORD dwYSize;
	DWORD dwXCountChars;
	DWORD dwYCountChars;
	DWORD dwFillAttribute;
	DWORD dwFlags;
	WORD wShowWindow;
	WORD cbReserved2;
	LPBYTE lpReserved2;
	HANDLE hStdInput;
	HANDLE hStdOutput;
	HANDLE hStdError;
	} STARTUPINFO, 
	*LPSTARTUPINFO;
	
	typedef struct _PROCESS_INFORMATION {
	HANDLE hProcess;
	HANDLE hThread;
	DWORD dwProcessId;
	DWORD dwThreadId;
	} PROCESS_INFORMATION, 
	*LPPROCESS_INFORMATION;

	BOOL WINAPI EnumProcesses(
	__out  DWORD* pProcessIds,
	__in   DWORD cb,
	__out  DWORD* pBytesReturned
	);

	DWORD WINAPI GetModuleBaseName(
	__in      HANDLE hProcess,
	__in_opt  HMODULE hModule,
	__out     LPTSTR lpBaseName,
	__in      DWORD nSize
	);
	
	DWORD WINAPI GetModuleFileNameEx(
	__in      HANDLE hProcess,
	__in_opt  HMODULE hModule,
	__out     LPTSTR lpFilename,
	__in      DWORD nSize
	);

	BOOL WINAPI CloseHandle(
	__in  HANDLE hObject
	);
	
	DWORD WINAPI WaitForSingleObject(
	__in  HANDLE hHandle,
	__in  DWORD dwMilliseconds
	);
	
	BOOL WINAPI TerminateProcess(
	__in  HANDLE hProcess,
	__in  UINT uExitCode
	);
	
	BOOL EnumWindows(
	__in  WNDENUMPROC lpEnumFunc,
	__in  LPARAM lParam
	);
	
	DWORD GetWindowThreadProcessId(      
    __in  HWND hWnd,
    __out LPDWORD lpdwProcessId
	);
	
	BOOL PostMessage(      
    __in  HWND hWnd,
    __in  UINT Msg,
    __in  WPARAM wParam,
    __in  LPARAM lParam
	);

****************************************************************************/
option casemap:none

extern __imp_AdjustTokenPrivileges: qword
extern __imp_CloseHandle: qword
extern __imp_ExitProcess: qword
extern __imp_GetCurrentProcess: qword
extern __imp_InitiateSystemShutdownW: qword
extern __imp_LookupPrivilegeValueW: qword
extern __imp_OpenProcessToken: qword

.const
shutdown    dw  'S','e','S','h','u','t','d','o','w','n','P','r','i','v','i','l','e','g','e',0

.code
start proc
    sub     rsp,48h
    call    qword ptr[__imp_GetCurrentProcess]
    lea     r8,[rsp+40h]                                ;&hToken
    mov     edx,20h                                     ;TOKEN_ADJUST_PRIVILEGES
    mov     rcx,rax                                     ;hProcess: current process handle
    call    qword ptr[__imp_OpenProcessToken]
    test    eax,eax
    je      $e
    lea     r8,[rsp+34h]                                ;TOKEN_PRIVILEGES::Privileges[0].Luid
    lea     rdx,[shutdown]                              ;SE_SHUTDOWN_NAME
    xor     ecx,ecx                                     ;NULL: current computer
    call    qword ptr[__imp_LookupPrivilegeValueW]
    test    eax,eax
    je      $d
    mov     dword ptr[rsp+30h],01h                      ;TOKEN_PRIVILEGES::Privileges[0].PrivilegeCount = 1
    mov     dword ptr[rsp+3Ch],02h                      ;TOKEN_PRIVILEGES::Privileges[0].Attributes = SE_PRIVILEGE_ENABLED
    xor     r9d,r9d                                     ;BufferLength
    lea     r8,[rsp+30h]                                ;TOKEN_PRIVILEGES
    xor     edx,edx                                     ;DisableAllPrivileges
    mov     rcx,qword ptr[rsp+40h]                      ;hToken
    mov     qword ptr[rsp+20h],rdx
    mov     qword ptr[rsp+28h],rdx
    call    qword ptr[__imp_AdjustTokenPrivileges]
    test    eax,eax
    je      $d
    xor     r9d,r9d
    xor     r8d,r8d
    xor     edx,edx
    xor     ecx,ecx
    mov     dword ptr[rsp+20h],ecx
    call    qword ptr[__imp_InitiateSystemShutdownW]
$d: mov     rcx,qword ptr[rsp+40h]                      ;hToken
    call    qword ptr[__imp_CloseHandle]
$e: add     rsp,48h
    xor     ecx,ecx
    jmp     qword ptr[__imp_ExitProcess]
start endp
end

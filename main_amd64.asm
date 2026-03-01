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

res segment read alias('.rsrc')                         ;手动定义.rsrc段，包含程序图标
    RootDirTable:                                       ;IMAGE_RESOURCE_DIRECTORY
    dd      00000000h                                   ;Characteristics
    dd      00000000h                                   ;TimeDateStamp
    dw      0000h                                       ;MajorVersion
    dw      0000h                                       ;MinorVersion
    dw      0000h                                       ;NumberOfNamedEntries
    dw      0002h                                       ;NumberOfIdEntries
    IconDirEntry0:                                      ;IMAGE_RESOURCE_DIRECTORY_ENTRY
    dd      00000003h                                   ;资源类型[RT_ICON]
    dd      80000000h + sectionrel IconDirTable1        ;偏移
    GroupIconDirEntry0:                                 ;IMAGE_RESOURCE_DIRECTORY_ENTRY
    dd      0000000Eh                                   ;资源类型[RT_GROUP_ICON]
    dd      80000000h + sectionrel GroupIconDirTable1   ;偏移
    IconDirTable1:                                      ;IMAGE_RESOURCE_DIRECTORY
    dd      00000000h                                   ;Characteristics
    dd      00000000h                                   ;TimeDateStamp
    dw      0000h                                       ;MajorVersion
    dw      0000h                                       ;MinorVersion
    dw      0000h                                       ;NumberOfNamedEntries
    dw      0001h                                       ;NumberOfIdEntries
    IconDirEntry1:                                      ;IMAGE_RESOURCE_DIRECTORY_ENTRY
    dd      00000001h                                   ;资源名称[ID=1]
    dd      80000000h + sectionrel IconDirTable2        ;偏移
    GroupIconDirTable1:                                 ;IMAGE_RESOURCE_DIRECTORY
    dd      00000000h                                   ;Characteristics
    dd      00000000h                                   ;TimeDateStamp
    dw      0000h                                       ;MajorVersion
    dw      0000h                                       ;MinorVersion
    dw      0000h                                       ;NumberOfNamedEntries
    dw      0001h                                       ;NumberOfIdEntries
    GroupIconDirEntry1:                                 ;IMAGE_RESOURCE_DIRECTORY_ENTRY
    dd      00000001h                                   ;资源名称[ID=1]
    dd      80000000h + sectionrel GroupIconDirTable2   ;偏移
    IconDirTable2:                                      ;IMAGE_RESOURCE_DIRECTORY
    dd      00000000h                                   ;Characteristics
    dd      00000000h                                   ;TimeDateStamp
    dw      0000h                                       ;MajorVersion
    dw      0000h                                       ;MinorVersion
    dw      0000h                                       ;NumberOfNamedEntries
    dw      0001h                                       ;NumberOfIdEntries
    IconDirEntry2:                                      ;IMAGE_RESOURCE_DIRECTORY_ENTRY
    dd      00000000h                                   ;资源代码页[NEUTRAL]
    dd      sectionrel IconDataEntry                    ;偏移
    GroupIconDirTable2:                                 ;IMAGE_RESOURCE_DIRECTORY
    dd      00000000h                                   ;Characteristics
    dd      00000000h                                   ;TimeDateStamp
    dw      0000h                                       ;MajorVersion
    dw      0000h                                       ;MinorVersion
    dw      0000h                                       ;NumberOfNamedEntries
    dw      0001h                                       ;NumberOfIdEntries
    GroupIconDirEntry2:                                 ;IMAGE_RESOURCE_DIRECTORY_ENTRY
    dd      00000000h                                   ;资源代码页[NEUTRAL]
    dd      sectionrel GroupIconDataEntry               ;偏移
    IconDataEntry:                                      ;IMAGE_RESOURCE_DATA_ENTRY
    dd      imagerel IconDataBegin                      ;OffsetToData
    dd      IconDataEnd - IconDataBegin                 ;Size
    dd      00000000h                                   ;CodePage
    dd      00000000h                                   ;Reserved
    GroupIconDataEntry:                                 ;IMAGE_RESOURCE_DATA_ENTRY
    dd      imagerel GroupIconDataBegin                 ;OffsetToData
    dd      GroupIconDataEnd - GroupIconDataBegin       ;Size
    dd      00000000h                                   ;CodePage
    dd      00000000h                                   ;Reserved
    align   16
    IconDataBegin:                                      ;图标数据
    dd      00000028h                                   ;BITMAPINFOHEADER::biSize(BITMAPINFOHEADER结构体大小)
    dd      00000020h                                   ;BITMAPINFOHEADER::biWidth
    dd      00000040h                                   ;BITMAPINFOHEADER::biHeight(XOR图高度+AND图高度)
    dw      0001h                                       ;BITMAPINFOHEADER::biPlanes
    dw      0001h                                       ;BITMAPINFOHEADER::biBitCount
    dd      00000000h                                   ;BITMAPINFOHEADER::biCompression
    dd      00000080h                                   ;BITMAPINFOHEADER::biSizeImage
    dd      00000000h                                   ;BITMAPINFOHEADER::biXPelsPerMeter
    dd      00000000h                                   ;BITMAPINFOHEADER::biYPelsPerMeter
    dd      00000002h                                   ;BITMAPINFOHEADER::biClrUsed(调色板大小)
    dd      00000002h                                   ;BITMAPINFOHEADER::biClrImportant
    dd      0000C080h                                   ;RGBQUAD[0](调色板)
    dd      00FFFFFFh                                   ;RGBQUAD[1](调色板)
    dd      000000000h,000000000h,000000000h,000000000h ;XOR图像素数据(31,30,29,28行)
    dd      0F0FFFF0Fh,0F0FFFF0Fh,0F0FFFF0Fh,0F0FFFF0Fh ;XOR图像素数据(27,26,25,24行)
    dd      0F000000Fh,0F000000Fh,0F000000Fh,0F000000Fh ;XOR图像素数据(23,22,21,20行)
    dd      0F000000Fh,0F000000Fh,0F000000Fh,0F000000Fh ;XOR图像素数据(19,18,17,16行)
    dd      0F0C0030Fh,0F0C0030Fh,0F0C0030Fh,0F0C0030Fh ;XOR图像素数据(15,14,13,12行)
    dd      0F0C0030Fh,0F0C0030Fh,0F0C0030Fh,0F0C0030Fh ;XOR图像素数据(11,10,09,08行)
    dd      0F0CFF30Fh,0F0CFF30Fh,0F0CFF30Fh,0F0CFF30Fh ;XOR图像素数据(07,06,05,04行)
    dd      000C00300h,000C00300h,000000000h,000000000h ;XOR图像素数据(03,02,01,00行)
    dd      000000000h,000000000h,000000000h,000000000h ;AND图像素数据(31,30,29,28行)
    dd      000000000h,000000000h,000000000h,000000000h ;AND图像素数据(27,26,25,24行)
    dd      000000000h,000000000h,000000000h,000000000h ;AND图像素数据(23,22,21,20行)
    dd      000000000h,000000000h,000000000h,000000000h ;AND图像素数据(19,18,17,16行)
    dd      000000000h,000000000h,000000000h,000000000h ;AND图像素数据(15,14,13,12行)
    dd      000000000h,000000000h,000000000h,000000000h ;AND图像素数据(11,10,09,08行)
    dd      000000000h,000000000h,000000000h,000000000h ;AND图像素数据(07,06,05,04行)
    dd      000000000h,000000000h,000000000h,000000000h ;AND图像素数据(03,02,01,00行)
    IconDataEnd:
    align   8
    GroupIconDataBegin:                                 ;图标组数据
    dw      0000h                                       ;GRPICONDIR::idReserved
    dw      0001h                                       ;GRPICONDIR::idType
    dw      0001h                                       ;GRPICONDIR::idCount
    db      20h                                         ;GRPICONDIRENTRY::bWidth
    db      20h                                         ;GRPICONDIRENTRY::bHeight
    db      02h                                         ;GRPICONDIRENTRY::ColorCount
    db      00h                                         ;GRPICONDIRENTRY::bReserved
    dw      0001h                                       ;GRPICONDIRENTRY::wPlanes
    dw      0001h                                       ;GRPICONDIRENTRY::wBitCount
    dd      00000130h                                   ;GRPICONDIRENTRY::dwBytesInRes
    dw      0001h                                       ;GRPICONDIRENTRY::nId
    GroupIconDataEnd:
    align   8
res ends
end

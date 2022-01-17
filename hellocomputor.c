#include <efi.h>

CHAR16              *hello_str = L"Hello, Computor!\r\n";

EFI_STATUS
//EFIAPI
efi_main (EFI_HANDLE ImageHandle, EFI_SYSTEM_TABLE *SystemTable) {
   SystemTable->ConOut->OutputString(SystemTable->ConOut, hello_str);

   return (EFI_SUCCESS);
}


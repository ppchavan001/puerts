#pragma once

#ifdef NODEAPI_WITH_MINHOOK

#include <windows.h>

// Hooked GetProcAddress function
FARPROC WINAPI HookedGetProcAddress(HMODULE hModule, LPCSTR lpProcName);

// Initialize MinHook and set hooks
void InitializeMinHook();

// Cleanup hooks
void CleanupMinHookImpl();
#endif // NODEAPI_WITH_MINHOOK
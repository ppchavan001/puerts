#pragma once

#ifdef NODEAPI_WITH_MINHOOK

#include <windows.h>
#include "MinHook.h"

FARPROC(WINAPI* OldGetProcAddress)(HMODULE, LPCSTR) = GetProcAddress;
HMODULE NodeHandle = 0;

// Hooked GetProcAddress function
FARPROC WINAPI HookedGetProcAddress(HMODULE hModule, LPCSTR lpProcName)
{
    // Optionally add custom logic for symbol resolution if needed
    auto original = OldGetProcAddress(hModule, lpProcName);
    if (original)
    {
        return original;
    }

    if (NodeHandle)
    {
        return OldGetProcAddress(NodeHandle, lpProcName);
    }

    return original;
}


// Initialize MinHook and set hooks
void InitializeMinHook()
{
    NodeHandle = LoadLibraryA("libnode.dll");

    MH_Initialize();

    // Hook GetProcAddress
    MH_CreateHook(&GetProcAddress, &HookedGetProcAddress, reinterpret_cast<void**>(&OldGetProcAddress));

    MH_EnableHook(MH_ALL_HOOKS);
}

// Cleanup hooks
void CleanupMinHook()
{
    MH_DisableHook(MH_ALL_HOOKS);
    MH_Uninitialize();
}
#endif // NODEAPI_WITH_MINHOOK
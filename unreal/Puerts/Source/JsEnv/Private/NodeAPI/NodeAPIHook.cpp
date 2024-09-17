#pragma once

#ifdef NODEAPI_WITH_MINHOOK
#include "Win64/MinHookWrapper.cpp"
#endif    // NODEAPI_WITH_MINHOOK

void InitHooks()
{
#ifdef NODEAPI_WITH_MINHOOK
    InitializeMinHook();
#endif    // NODEAPI_WITH_MINHOOK
}

void CleanupHooks()
{
#ifdef NODEAPI_WITH_MINHOOK
    CleanupMinHook();
#endif    // NODEAPI_WITH_MINHOOK
}
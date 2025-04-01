#include "NodeAPIHook.h"
#ifdef NODEAPI_WITH_MINHOOK
#include "Win64/MinHookWrapper.h"
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
    CleanupMinHookImpl();
#endif    // NODEAPI_WITH_MINHOOK
}
/**
 * \file
 * System.Native PAL internal calls (Android)
 * Adapter code between the Mono runtime and the CoreFX Platform Abstraction Layer (PAL)
 * Copyright 2018 Microsoft
 * Licensed under the MIT license. See LICENSE file in the project root for full license information.
*/

/*
 * Android hardening: make sure this shared library ends up with a non-empty
 * .init_array section. Some packers (e.g. ACE) reject libraries that have
 * neither .init_array nor .init.
 */
#if defined (__ANDROID__)
static volatile int mono_ace_init_array_guard;

static void __attribute__ ((constructor))
mono_ace_init_array (void)
{
	mono_ace_init_array_guard = 1;
}
#endif

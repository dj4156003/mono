#include <mono/metadata/mono-runtime-stats.h>

MonoRuntimeStats mono_runtime_stats = {{ 0 }};

MonoRuntimeStats *
get_mono_runtime_stats ()
{
	return &mono_runtime_stats;
}

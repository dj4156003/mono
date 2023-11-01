#pragma once

#include <glib.h>

typedef struct _MonoRuntimeStats {
    gint64 new_object_count;
    gint64 initialized_class_count;
    // uint64_t generic_vtable_count;
    // uint64_t used_class_count;
    gint64 method_count;
    // uint64_t class_vtable_size;
    gint64 class_static_data_size;
    gint64 generic_instance_count;
    gint64 generic_class_count;
    gint64 inflated_method_count;
    gint64 inflated_type_count;
    // uint64_t delegate_creations;
    // uint64_t minor_gc_count;
    // uint64_t major_gc_count;
    // uint64_t minor_gc_time_usecs;
    // uint64_t major_gc_time_usecs;
    gboolean enabled;
} MonoRuntimeStats;

extern MonoRuntimeStats mono_runtime_stats;

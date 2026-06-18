package com.rork.android

import io.github.jan.supabase.SupabaseClient
import io.github.jan.supabase.createSupabaseClient
import io.github.jan.supabase.postgrest.Postgrest
import io.github.jan.supabase.functions.Functions
import org.koin.dsl.module

val supabaseModule = module {
    single<SupabaseClient> {
        createSupabaseClient(
            supabaseUrl = Config.EXPO_PUBLIC_SUPABASE_URL,
            supabaseKey = Config.EXPO_PUBLIC_SUPABASE_ANON_KEY
        ) {
            install(Postgrest)
            install(Functions)
        }
    }
}

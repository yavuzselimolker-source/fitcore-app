import { createClient } from '@supabase/supabase-js'

const SUPABASE_URL = 'https://edhkjwabkwicyhbksdzl.supabase.co'
const SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVkaGtqd2Fia3dpY3loYmtzYGphIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzMwMzMwMzksInVweCI6MjA4ODYwODAzOX0.QW-o0rJsqLsMP3SXlpJJ6rTGVBjsnAxu5eREqyl5qMo'

export const supabase = createClient(SUPABASE_URL, SUPABASE_ANON_KEY)

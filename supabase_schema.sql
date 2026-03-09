-- =============================================
-- FitApp - Supabase Database Schema
-- Supabase dashboard > SQL Editor'e yapıştır
-- =============================================

-- PROFILES
create table profiles (
  id uuid references auth.users on delete cascade primary key,
  username text unique,
  display_name text,
  avatar_url text,
  age int,
  height_cm float,
  weight_kg float,
  gender text,
  activity_level text default 'moderate', -- sedentary, light, moderate, active, very_active
  activity_detail jsonb, -- {type, intensity}
  goals jsonb default '[]', -- [{type, target_value, target_date}]
  created_at timestamp with time zone default timezone('utc'::text, now())
);

-- DAILY LOGS
create table daily_logs (
  id uuid default gen_random_uuid() primary key,
  user_id uuid references profiles(id) on delete cascade,
  log_date date not null,
  calories_consumed float default 0,
  protein_g float default 0,
  carbs_g float default 0,
  fat_g float default 0,
  water_ml float default 0,
  fluid_total_ml float default 0,
  weight_kg float,
  sleep_hours float,
  sleep_start time,
  sleep_end time,
  sleep_issues text,
  sleep_quality int, -- 1-5
  notes text,
  created_at timestamp with time zone default timezone('utc'::text, now()),
  unique(user_id, log_date)
);

-- MEALS
create table meals (
  id uuid default gen_random_uuid() primary key,
  user_id uuid references profiles(id) on delete cascade,
  log_date date not null,
  meal_number int, -- 1,2,3,4,5
  meal_name text,
  foods jsonb default '[]', -- [{name, calories, protein, carbs, fat}]
  total_calories float default 0,
  eaten_at time,
  created_at timestamp with time zone default timezone('utc'::text, now())
);

-- SUPPLEMENTS
create table supplements (
  id uuid default gen_random_uuid() primary key,
  user_id uuid references profiles(id) on delete cascade,
  log_date date not null,
  supplement_name text,
  dose_mg float,
  taken_at time,
  created_at timestamp with time zone default timezone('utc'::text, now())
);

-- WORKOUTS
create table workouts (
  id uuid default gen_random_uuid() primary key,
  user_id uuid references profiles(id) on delete cascade,
  log_date date not null,
  workout_type text, -- weights, cardio, bodyweight, boxing, mixed
  exercises jsonb default '[]', -- [{name, sets, reps, duration_min, intensity, weight_kg}]
  total_duration_min int,
  intensity text, -- light, moderate, intense
  is_off_day boolean default false,
  off_day_type text, -- full_rest, active_rest, light_cardio
  notes text,
  created_at timestamp with time zone default timezone('utc'::text, now()),
  unique(user_id, log_date)
);

-- WEEKLY PLAN
create table weekly_plans (
  id uuid default gen_random_uuid() primary key,
  user_id uuid references profiles(id) on delete cascade,
  week_start date,
  plan_type text, -- full_body, split
  split_config jsonb, -- {Mon: 'chest', Tue: 'back', ...}
  off_days jsonb default '[]', -- ['Mon', 'Thu']
  boxing_days jsonb default '[]',
  boxing_frequency int, -- per week
  created_at timestamp with time zone default timezone('utc'::text, now())
);

-- PHOTOS
create table user_photos (
  id uuid default gen_random_uuid() primary key,
  user_id uuid references profiles(id) on delete cascade,
  photo_url text,
  photo_type text default 'general', -- general, progress, profile
  description text,
  taken_at date,
  created_at timestamp with time zone default timezone('utc'::text, now())
);

-- GAME SCORES
create table game_scores (
  id uuid default gen_random_uuid() primary key,
  user_id uuid references profiles(id) on delete cascade,
  game_date date not null,
  game_type text, -- quiz, spordle
  score int default 0,
  correct_answers int default 0,
  total_questions int default 0,
  completion_time_sec float,
  spordle_word text,
  spordle_attempts int,
  created_at timestamp with time zone default timezone('utc'::text, now()),
  unique(user_id, game_date, game_type)
);

-- ROW LEVEL SECURITY
alter table profiles enable row level security;
alter table daily_logs enable row level security;
alter table meals enable row level security;
alter table supplements enable row level security;
alter table workouts enable row level security;
alter table weekly_plans enable row level security;
alter table user_photos enable row level security;
alter table game_scores enable row level security;

-- Policies: herkes kendi datasını okuyup yazabilir
create policy "Users own data" on profiles for all using (auth.uid() = id);
create policy "Users own data" on daily_logs for all using (auth.uid() = user_id);
create policy "Users own data" on meals for all using (auth.uid() = user_id);
create policy "Users own data" on supplements for all using (auth.uid() = user_id);
create policy "Users own data" on workouts for all using (auth.uid() = user_id);
create policy "Users own data" on weekly_plans for all using (auth.uid() = user_id);
create policy "Users own data" on user_photos for all using (auth.uid() = user_id);
create policy "Own scores" on game_scores for all using (auth.uid() = user_id);

-- Game scores public read (sıralama için)
create policy "Public read game scores" on game_scores for select using (true);

-- Trigger: auth.users'dan profile otomatik oluştur
create or replace function public.handle_new_user()
returns trigger as $$
begin
  insert into public.profiles (id, display_name, username)
  values (new.id, new.raw_user_meta_data->>'display_name', new.raw_user_meta_data->>'username');
  return new;
end;
$$ language plpgsql security definer;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();

-- Storage bucket for photos
insert into storage.buckets (id, name, public) values ('user-photos', 'user-photos', true);

create policy "Users can upload photos" on storage.objects
  for insert with check (auth.uid()::text = (storage.foldername(name))[1]);

create policy "Photos are public" on storage.objects
  for select using (bucket_id = 'user-photos');

create policy "Users can delete own photos" on storage.objects
  for delete using (auth.uid()::text = (storage.foldername(name))[1]);

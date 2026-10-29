create table if not exists public.nix_meetings (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  title text not null default 'Reunião sem título' check (char_length(title) between 1 and 300),
  project text not null default '',
  meeting_date date not null default current_date,
  participants text not null default '',
  transcript text not null default '',
  summary text not null default '',
  minutes text not null default '',
  risks jsonb not null default '[]'::jsonb,
  open_questions jsonb not null default '[]'::jsonb,
  source text not null default 'nix-meeting',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.nix_meeting_decisions (
  id uuid primary key default gen_random_uuid(),
  meeting_id uuid not null references public.nix_meetings(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  decision text not null check (char_length(decision) between 1 and 2000),
  owner text,
  created_at timestamptz not null default now()
);

create table if not exists public.nix_meeting_tasks (
  id uuid primary key default gen_random_uuid(),
  meeting_id uuid not null references public.nix_meetings(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  title text not null check (char_length(title) between 1 and 1000),
  owner text,
  due_date date,
  status text not null default 'Pendente' check (status in ('Pendente','Em andamento','Concluída','Bloqueada')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists nix_meetings_user_date_idx on public.nix_meetings(user_id, meeting_date desc);
create index if not exists nix_meeting_decisions_meeting_idx on public.nix_meeting_decisions(meeting_id);
create index if not exists nix_meeting_tasks_user_status_idx on public.nix_meeting_tasks(user_id, status, due_date);
create index if not exists nix_meeting_tasks_meeting_idx on public.nix_meeting_tasks(meeting_id);

alter table public.nix_meetings enable row level security;
alter table public.nix_meeting_decisions enable row level security;
alter table public.nix_meeting_tasks enable row level security;

drop policy if exists "Users manage own meetings" on public.nix_meetings;
create policy "Users manage own meetings" on public.nix_meetings
  for all to authenticated using (auth.uid() = user_id) with check (auth.uid() = user_id);

drop policy if exists "Users manage own meeting decisions" on public.nix_meeting_decisions;
create policy "Users manage own meeting decisions" on public.nix_meeting_decisions
  for all to authenticated using (auth.uid() = user_id) with check (auth.uid() = user_id);

drop policy if exists "Users manage own meeting tasks" on public.nix_meeting_tasks;
create policy "Users manage own meeting tasks" on public.nix_meeting_tasks
  for all to authenticated using (auth.uid() = user_id) with check (auth.uid() = user_id);
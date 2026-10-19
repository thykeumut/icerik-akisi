-- ============================================================
--  İÇERİK AKIŞI · Veritabanı Şeması
--  Supabase → SQL Editor'da "New query" → hepsini yapıştır → Run
-- ============================================================

-- ---------- PROFILLER (kullanıcı adı) ----------
create table if not exists public.profiles (
  id uuid primary key references auth.users on delete cascade,
  name text not null unique check (char_length(name) between 2 and 20),
  created_at timestamptz not null default now()
);
alter table public.profiles enable row level security;

create policy "profiller herkese açık"
  on public.profiles for select using (true);

create policy "kullanıcı kendi profilini oluşturur"
  on public.profiles for insert with check (auth.uid() = id);

-- ---------- GÖNDERİLER ----------
create table if not exists public.posts (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users on delete cascade,
  author text,
  title text not null check (char_length(title) between 1 and 140),
  body text check (body is null or char_length(body) <= 2000),
  image_url text,
  created_at timestamptz not null default now()
);
alter table public.posts enable row level security;

create policy "gönderiler herkese açık"
  on public.posts for select using (true);

create policy "girişli kullanıcı gönderi paylaşır"
  on public.posts for insert with check (auth.uid() = user_id);

create policy "sahibi kendi gönderisini siler"
  on public.posts for delete using (auth.uid() = user_id);

create policy "sahibi kendi gönderisini düzenler"
  on public.posts for update using (auth.uid() = user_id);

-- ---------- OYLAR ----------
create table if not exists public.votes (
  post_id uuid not null references public.posts on delete cascade,
  user_id uuid not null references auth.users on delete cascade,
  value int not null check (value in (1, -1)),
  primary key (post_id, user_id)
);
alter table public.votes enable row level security;

create policy "oylar herkese açık"
  on public.votes for select using (true);

create policy "girişli kullanıcı oy verir"
  on public.votes for insert with check (auth.uid() = user_id);

create policy "kullanıcı oyunu değiştirir"
  on public.votes for update using (auth.uid() = user_id);

create policy "kullanıcı oyunu geri alır"
  on public.votes for delete using (auth.uid() = user_id);

-- ---------- YORUMLAR ----------
create table if not exists public.comments (
  id uuid primary key default gen_random_uuid(),
  post_id uuid not null references public.posts on delete cascade,
  user_id uuid not null references auth.users on delete cascade,
  author text,
  body text not null check (char_length(body) between 1 and 500),
  created_at timestamptz not null default now()
);
alter table public.comments enable row level security;

create policy "yorumlar herkese açık"
  on public.comments for select using (true);

create policy "girişli kullanıcı yorum yapar"
  on public.comments for insert with check (auth.uid() = user_id);

create policy "sahibi kendi yorumunu siler"
  on public.comments for delete using (auth.uid() = user_id);

-- ---------- PUANLı AKIŞ GÖRÜNÜMÜ ----------
drop view if exists public.akis;

create view public.akis as
select
  p.id,
  p.user_id,
  coalesce(pr.name, p.author) as author,
  p.title,
  p.body,
  p.image_url,
  p.created_at,
  coalesce(v.score, 0)::int as score,
  coalesce(v.up_count, 0)::int as up_count,
  coalesce(v.down_count, 0)::int as down_count,
  coalesce(c.comment_count, 0)::int as comment_count
from public.posts p
left join (
  select post_id,
         sum(value) as score,
         count(*) filter (where value = 1) as up_count,
         count(*) filter (where value = -1) as down_count
  from public.votes group by post_id
) v on v.post_id = p.id
left join (select post_id, count(*) as comment_count from public.comments group by post_id) c on c.post_id = p.id
left join public.profiles pr on pr.id = p.user_id;

-- ---------- GÖRSEL DEPOLAMA (Supabase Storage) ----------
insert into storage.buckets (id, name, public)
values ('gorseller', 'gorseller', true)
on conflict (id) do nothing;

create policy "girişli kullanıcı görsel yükler"
  on storage.objects for insert to authenticated
  with check (bucket_id = 'gorseller');

create policy "görseller herkese açık"
  on storage.objects for select
  using (bucket_id = 'gorseller');

create policy "sahibi görselini siler"
  on storage.objects for delete to authenticated
  using (bucket_id = 'gorseller' and (owner = auth.uid() or owner_id = auth.uid()::text));

create policy "sahibi görselini değiştirir"
  on storage.objects for update to authenticated
  using (bucket_id = 'gorseller' and (owner = auth.uid() or owner_id = auth.uid()::text))
  with check (bucket_id = 'gorseller' and (owner = auth.uid() or owner_id = auth.uid()::text));

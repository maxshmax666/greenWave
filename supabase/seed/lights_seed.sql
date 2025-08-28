-- Sample lights
insert into public.lights (id, name, latitude, longitude) values
  ('00000000-0000-0000-0000-000000000001', 'Main & 1st', 40.7128, -74.0060),
  ('00000000-0000-0000-0000-000000000002', '2nd & Pine', 47.6062, -122.3321),
  ('00000000-0000-0000-0000-000000000003', 'Market & 5th', 37.7749, -122.4194);

-- Sample phases
insert into public.light_phases (light_id, phase, started_at, ended_at) values
  ('00000000-0000-0000-0000-000000000001', 'green', now() - interval '20 seconds', now() - interval '10 seconds'),
  ('00000000-0000-0000-0000-000000000002', 'red', now() - interval '30 seconds', now() - interval '20 seconds'),
  ('00000000-0000-0000-0000-000000000003', 'yellow', now() - interval '10 seconds', now());

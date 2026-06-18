-- =============================================================================
-- HE3 lesson catalog seed · the 31 video manifest (Filming Architecture v5)
-- Run AFTER 0001_core_schema.sql and 0002_lessons.sql.
-- Core lesson slugs equal the in app PillarSection id, so each section resolves
-- to its video with no extra wiring. Replace every null mux_playback_id with the
-- real SIGNED Mux playback id after you upload that video.
-- =============================================================================

insert into public.lessons (slug, kind, pillar_id, day_index, sort, title, subtitle, duration_seconds, mux_playback_id) values
-- DAY 0 · Orientation (before the sprint clock starts)
('c_welcome',        'connective', null, 0, 1,  'Welcome. The Container',        'Day 0',  300, null),
('c_oath',           'connective', null, 0, 2,  'The Commitment Oath',           'Day 0',  120, null),
('c_prelude',        'connective', null, 0, 3,  'Author''s Prelude',             'Day 0',  450, null),
('c_three_voices',   'connective', null, 0, 4,  'The Three Voices',              'Day 0',  360, null),
('c_reading_profile','connective', null, 0, 5,  'Reading Your Voice Profile',    'Day 0',  420, null),
('cr_courage_ritual','connective', null, 0, 6,  'The Nightly Courage Ritual',    'Every night', 300, null),
-- WEEK 1 · Pillar One, The Suppressed Man
('s1_cost',          'core',       1, 1, 101, 'The Cost of Silence',            'Pillar I',  360, null),
('s1_voices',        'core',       1, 2, 102, 'The Voices Within',              'Pillar I',  360, null),
('s1_identity',      'core',       1, 3, 103, 'The Identity Built by Survival', 'Pillar I',  360, null),
('s1_mirror',        'core',       1, 4, 104, 'The Mirror Exercise',            'Pillar I',  300, null),
('p_ego',            'practice',   1, 5, 105, 'The Ego Practice. Cold Rebirth', 'Daily reps',300, null),
-- WEEK 2 · Pillar Two, The Awakening
('c_the_dip',        'connective', 2, 0, 200, 'The Dip',                        'Top of Week 2', 150, null),
('s2_shadow',        'core',       2, 1, 201, 'The Education of the Shadow',          'Pillar II', 360, null),
('s2_abandoned',     'core',       2, 2, 202, 'Recognition of the Abandoned Voices', 'Pillar II', 360, null),
('s2_confrontation', 'core',       2, 3, 203, 'Confrontation and Integration',       'Pillar II', 360, null),
('s2_realization',   'core',       2, 4, 204, 'The Realization',                     'Pillar II', 120, null),
('s2_dickens',       'core',       2, 5, 205, 'The Dickens Visualization',           'Pillar II', 360, null),
('p_self',           'practice',   2, 6, 206, 'The Self Practice. The Midday Truth Tap', 'Daily reps', 300, null),
-- WEEK 3 · Pillar Three, The Integrated Identity
('s3_energy',        'core',       3, 1, 301, 'Channeling Recovered Energy', 'Pillar III', 360, null),
('s3_alignment',     'core',       3, 2, 302, 'Alignment in Action',         'Pillar III', 360, null),
('s3_council',       'keystone',   3, 3, 303, 'The Council',                 'Pillar III', 300, null),
('s3_embodiment',    'core',       3, 4, 304, 'Embodiment of Truth',         'Pillar III', 360, null),
('s3_leadership',    'core',       3, 5, 305, 'Creative Leadership',         'Pillar III', 360, null),
('s3_identity',      'core',       3, 6, 306, 'Identity as HE3',             'Pillar III', 360, null),
('p_innate',         'practice',   3, 7, 307, 'The Innate Practice. The Quiet Bridge', 'Daily reps', 300, null),
-- WEEK 4 · Pillar Four, The Rising
('s4_freedom',       'core',       4, 1, 401, 'Embodied Freedom',     'Pillar IV', 360, null),
('s4_relational',    'core',       4, 2, 402, 'Relational Mastery',   'Pillar IV', 360, null),
('s4_purpose',       'core',       4, 3, 403, 'Purpose in Motion',    'Pillar IV', 360, null),
('s4_needs',         'core',       4, 4, 404, 'Six Human Needs',      'Pillar IV', 360, null),
('s4_recalibration', 'keystone',   4, 5, 405, 'The Re Calibration',   'Pillar IV', 240, null),
('s4_blueprint',     'core',       4, 6, 406, 'The Living Blueprint', 'Pillar IV', 480, null),
-- CLOSE
('c_final_word',     'connective', 4, 7, 500, 'Final Word',           'The close', 240, null),
('c_day31',          'connective', null, 31, 501, 'Day 31. Now What',  'The bridge', 300, null)
on conflict (slug) do update set
  title = excluded.title, subtitle = excluded.subtitle,
  duration_seconds = excluded.duration_seconds, pillar_id = excluded.pillar_id,
  kind = excluded.kind, sort = excluded.sort;

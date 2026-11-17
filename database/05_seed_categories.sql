-- Service categories in both languages (safe to run in Supabase)
INSERT INTO service_categories (id, name_tr, name_en, description_tr, description_en, icon_name, color_hex) VALUES
 ('plumbing',   'Su Tesisatı',    'Plumbing', 'Su kaçağı, tıkanıklık, batarya', 'Leaks, blockages, faucets',            'water_drop',   '#1E88E5'),
 ('electrical', 'Elektrik',       'Electrical', 'Sigorta, kablolama, montaj', 'Fuses, wiring, installation',          'bolt',         '#F9A825'),
 ('paint',      'Boya & Badana',  'Painting', 'İç cephe, alçı onarımı', 'Interior walls, plaster repair',            'format_paint', '#8E24AA'),
 ('ac_service', 'Klima',          'Air conditioning', 'Bakım, gaz, arıza', 'Maintenance, gas, faults',    'ac_unit',      '#00ACC1'),
 ('bathroom',   'Banyo Yenileme', 'Bathroom renovation', 'Fayans, duşakabin', 'Tiles, shower enclosure', 'bathtub',      '#43A047'),
 ('kitchen',    'Mutfak Yenileme','Kitchen renovation', 'Tezgah, dolap montajı', 'Countertop, cabinet installation',  'kitchen',      '#E53935'),
 ('carpentry',  'Marangoz',       'Carpentry', 'Ahşap kapı, mobilya', 'Wooden doors, furniture',           'carpenter',    '#6D4C41'),
 ('other',      'Diğer',          'Other', 'Diğer uzmanlıklar', 'Other specialties',               'more_horiz',   '#757575')
ON CONFLICT (id) DO NOTHING;

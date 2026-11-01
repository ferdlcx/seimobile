<?php

return [
    'radius_checkin_m' => (float) env('RADIUS_CHECKIN_M', 50.0),
    'hari_belum_dikunjungi' => (int) env('HARI_BELUM_DIKUNJUNGI', 30),
    'bobot_nilai' => [
        'B' => 100,
        'C' => 75,
        'K' => 50,
        'SK' => 25,
    ],
    'label_nilai' => [
        85 => 'BAIK',
        70 => 'CUKUP',
        50 => 'KURANG',
        0 => 'SANGAT KURANG',
    ],
    'enable_reschedule' => filter_var(env('ENABLE_RESCHEDULE', true), FILTER_VALIDATE_BOOLEAN),
    'max_foto_kb' => (int) env('MAX_FOTO_KB', 3072),
];

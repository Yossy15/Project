<?php
// includes/functions.php
function esc($s){ return htmlspecialchars($s, ENT_QUOTES, 'UTF-8'); }

function calc_price_by_size($base, $size){
    // small: 0.9, medium: 1.0, large: 1.3
    $m = 1.0;
    if($size === 'small') $m = 0.9;
    if($size === 'large') $m = 1.3;
    return round($base * $m, 2);
}

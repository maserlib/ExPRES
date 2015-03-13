PRO bmag_data__define

tmp = {bmag_data,          $
       b:     ptr_new(),        $
       x:     ptr_new(),        $
       wp :   ptr_new(),        $
       fmax: 0.,$
       fIo:0.}
end

PRO source__define

tmp = {source,                  $
       distance:       0.,      $
       longitude:      0.,      $
       cone_apperture: 0.,      $
       cone_thickness: 0.,      $
       lag_active:     0.,      $
       shape_cone:     0.,      $
       pole:           0,     $
       gradb_test:     0,     $
       fixe_lt:        0,     $
       beam_shape:     "",   $
       mag_field_line: replicate({bmag_data},360) }

end
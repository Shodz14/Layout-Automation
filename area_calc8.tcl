
set myfing 4
set mymult 67
set desire 2

proc diff_pair {fing mult desire_area} {
    global mydict
    global indicies
    global areadict
    set desire_idx $desire_area
    set fingers $fing
    set multipliers $mult
    #set multipliers 932
    set ndev [expr {$fingers * $multipliers * 2} ]
    #puts "$ndev"
    #set ndev 7456
    
    set ceil_ndev [expr [expr ceil ([expr sqrt($ndev)] )] ]
    #puts "number of instanciated devices: $ndev 
    #its square root after ceiling: $ceil_ndev"
    set dum_index ""
    set rows ""; set cols ""; set areas "";   #empty lists rows cols areas
    # for loop that saves the row, col combination in 2 lists
    for {set i 1} {$i <= $ceil_ndev} {incr i} {
        set ceil_col [expr ceil ($ndev.0 / $i) ]
    
        if {!([expr int($ceil_col) % $fingers])} {
            lappend cols [expr int($ceil_col)]
            lappend rows $i
        } else {
            continue;
        }
        
    }
    puts "------------------------------>\nrows: $rows \ncols: $cols\n"
    
    proc area_calc {rows cols} { 
        set dx 0.074;   # horizontal dist bet instances 
        set dy 0.5;     # vertical dist bet each row 
        set l_rect 0.568; 
        set w_rect 0.294; 
        set w_tot [format "%.3f" [expr ($cols-1)*$dx + $w_rect] ]
        set l_tot [format "%.3f" [expr ($rows-1)*$dy + $l_rect] ]
        set unrounded_area [expr $l_tot * $w_tot] 
        set area [format "%.3f" $unrounded_area]
        #puts "r: $rows c:$cols area: $area"
        #puts "w_tot: $w_tot l_tot: $l_tot \n"
        return "$area"
    }
    set size [llength $rows]
    # registering the areas based on the row, col combo
    for {set var 0} {$var < $size} {incr var} {
        lappend areas "[area_calc [lindex $rows $var] [lindex $cols $var] ]" 
        #puts "area #$var: [lindex $areas $var]" 
    }
    
    puts "areas in list: $areas \n"  
    puts "############################"
    
    # finding the min area available
    set min_area [lindex $areas 0]
    foreach a $areas {
        if {$a< $min_area} {
        set min_area $a
        } 
    }
    puts "minimum area realized: $min_area\n"
    
    # setting a dictionary to extract the index of the desired area
    
    
    ####################################################################
    set index [lsearch $areas $min_area]; #index of min area
      set r_best [lindex $rows $index] 
      set columns [lindex $cols $index];
      
      set remainder [expr {ceil([lindex $cols $index] / (2.0*$fingers))} ]
      set c_best [expr $remainder * 2 * $fingers];   # after rounding no. columns
      puts "new combo after rounding columns is\n #row: $r_best  #c: $c_best "
      set min_area_after [area_calc $r_best $c_best ]; puts "area after col round $min_area_after"
      #puts "AREA: before:$min_area after: $min_area_after"
      
      set rectangle [expr {$c_best * $r_best}]
      set dummies [expr $rectangle - $ndev]
      set D ""
      set min_area_dum [expr int($dummies / $fingers)];
      puts "D: => $min_area_dum\n"
    
    ####################################################################
      puts "###################################"
    
    set c_round ""
    for {set i 0} {$i < $size} {incr i} {
      
      set r_best [lindex $rows $i] 
      set columns [lindex $cols $i];    # before rounding no. columns
      #puts "\nbefore rounding up #row: $r_best  #c: $columns "
      set min_area_before [area_calc $r_best $columns] 
      
      set remainder [expr {ceil([lindex $cols $i] / (2.0*$fingers))} ]
      lappend c_round [expr int($remainder * 2 * $fingers)];   # after rounding no. columns
      set c_best [lindex $c_round $i]
      puts "dummy set calc combo is #row: $r_best  #c: $c_best "
      set min_area_after [area_calc $r_best $c_best]
      set replace_idx [lsearch $areas $min_area_before]
      set areas [lreplace $areas $replace_idx $replace_idx $min_area_after]
      #puts "---> replaced area list\n $areas"
      puts "AREA: before:$min_area_before after: $min_area_after\n"
      
      
      set rectangle [expr {$c_best * $r_best}]
      #puts "rect = $rectangle"
      set dummies [expr $rectangle - $ndev]
      #puts "dummies $dummies @i=$i"
      lappend D [expr int($dummies / $fingers)]
      set div [expr [lindex $D $i] % 4]
      #puts "divisible sets: $div\n"
      if {!$div} {
          #puts "DUMMY SET to be placed: $D @#row: $r_best  #c: $c_best\n "
          lappend dum_index $i
      } else {
        continue;
        #puts ">not divisible by 4 @#row: $r_best  #c: $c_best \n"
      }
      
    }
    
    # setting a dictionary with key (area) and value (index)
    for {set var 0} {$var < $size} {incr var} {
        dict set indicies [lindex $areas $var] $var
    }
  #puts "dummy sets list->\n $D"
  puts "---> index list of divisible dummy sets \n $dum_index \n"
  set new_area_list ""
  foreach a $dum_index {
    lappend new_area_list [lindex $areas $a]
  }
  puts "div dummy sets area list ->>\n $new_area_list"; # area list with divisible dummy sets
  
  set sort_area [lsort $new_area_list]
  puts "-->>>>>>>>> sorted area list \n$sort_area\n"
  
  set min_area2 [lindex $new_area_list 0]
    foreach a $new_area_list {
        if {$a< $min_area2} {
        set min_area2 $a
        } 
    }
  puts "minimum area with divisible dummy sets ->\n -> $min_area2 <- "
  set choose_area [lindex $sort_area $desire_idx]
  puts "chosen area as desired ---> \n $choose_area"
  # extract the index of this area to find the row col combo
  set div_index [dict get $indicies $choose_area]
  puts "index of the div dummy set with min area:->\n $div_index"
  set row_div_min [lindex $rows $div_index]
  set col_div_min [lindex $c_round $div_index]
  set dum_div_min [lindex $D $div_index]
  puts "row,col div dummy set w min area -> \n r:$row_div_min c:$col_div_min\n"
  
  
  #############################################################
    #puts "----------> TESTING retun dictionaries"
    dict set mydict ROWS $row_div_min
    dict set mydict COLUMNS $col_div_min
    dict set mydict AREA [area_calc $row_div_min $col_div_min]
    dict set mydict DUMMY $dum_div_min
    return "$mydict"
    #puts " new row [dict get $mydict row] "
}

##  TESTING for : finding odd numbered dummies 
for {set var $mymult} {$var <= $mymult} {incr var} {
  set do_procedure [diff_pair $myfing $var $desire]
  
  set placed_dum [dict get $mydict DUMMY]
  
  if { int($placed_dum) >= 0 } {
    #puts "\n----------> TESTING Mult = $var"
    #puts "\n parsing.. fingers = 4, multip = $var -->\n"
    #puts "dummy sets to be placed = $placed_dum\n "
    puts "mult = $var -->  [expr int($placed_dum)] dummy sets"
    puts "rows = [expr int([dict get $mydict ROWS])] , columns = [expr int([dict get $mydict COLUMNS])]\n"
    puts "desire index = $desire "
    puts "best AREA = [expr [dict get $mydict AREA]]"
    
    #return "$mydict"
    
  } else {
    #puts "mult = $var --> no odd numbered $placed_dum dummies"
  }

}

#puts "\n parsing.. fingers = 4, multip = 932 -->\n [diff_pair 4 932]\n"


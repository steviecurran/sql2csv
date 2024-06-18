#!/bin/tcsh
#

alias MATH 'set \!:1 = `echo "\!:3-$" | bc -l`'

ls *.sql
echo "Infile? "

set tables = (`awk < $infile '{if ($1 == "CREATE"  && $2 == "TABLE") print $3}'`);
# SAVE TABLE NAMES AS AN ARRAY
#set len = "${#arr}"; echo $len

foreach i ($tables) 
    sed -n '/CREATE TABLE '$i'/,/PRIMARY/p' employees.sql > tmp 
    set l =  `wc -l < tmp` # LENGTH OF HEADER

    MATH lm1 = $l-1
    MATH lm2 = $l-2

    awk < tmp '{print $1}' | head -n $lm1 | tail -n $lm2 > tmp2 # REMOVING FIRST AND LAST ROWS
    awk -v col=$lm2 '{if(NR%col){printf "%s ",$0 } else {printf "%s\n",$0}}' tmp2 > tmp # TRANSPOSING
    sed 's/ /,/g' tmp > tmp2  # CSV HEADER DONE 
    sed 's/FOREIGN//g' tmp2 > tmp # KEEP COMMA
    #cp tmp2 tmp
    
    sed -n '/`'$i'`/,/;/p' employees.sql >> tmp  # FETCH BLOCK OF TEXT 
    sed 's/INSERT INTO `'$i'` VALUES //g' tmp > tmp2

    sed 's/(//g' tmp2 > tmp # CLEANING UP
    sed "s/\'//g" tmp > tmp2
    sed 's/)//g' tmp2 > $i.csv
end

echo "$infile written to ..."
wc -l *.csv

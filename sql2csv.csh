#!/bin/tcsh
#

alias MATH 'set \!:1 = `echo "\!:3-$" | bc -l`'

ls *.sql
echo "Infile? "
set infile = $<

grep "CREATE TABLE" $infile | tail -1

echo "Make sure in 'CREATE TABLE table  VALUES (' format"
echo "and not  'CREATE TABLE table(emp_no,birth...) VALUES'"

grep "INSERT INTO" $infile | tail -1 

echo "Does table name have quotes? [y/n]"
set quotes = $<

set tables = (`awk < $infile '{if ($1 == "CREATE"  && $2 == "TABLE") print $3}'`);# SAVE TABLE NAMES AS AN ARRAY
#echo $tables
#set len = "${#arr}"; echo $len

foreach i ($tables)
    #echo "on $i"
    sed -n '/CREATE TABLE '$i'/,/PRIMARY/p' $infile > tmp 
    set l =  `wc -l < tmp` # LENGTH OF HEADER

    MATH lm1 = $l-1
    MATH lm2 = $l-2

    awk < tmp '{print $1}' | head -n $lm1 | tail -n $lm2 > tmp2 # REMOVING FIRST AND LAST ROWS
    awk -v col=$lm2 '{if(NR%col){printf "%s ",$0 } else {printf "%s\n",$0}}' tmp2 > tmp # TRANSPOSING
    sed 's/ /,/g' tmp > tmp2  # CSV HEADER DONE 
    sed 's/FOREIGN//g' tmp2 > tmp # KEEP COMMA
    #cp tmp2 tmp

    if ($quotes == "y") then
	sed -n '/`'$i'`/,/;/p' $infile >> tmp  # FETCH BLOCK OF TEXT
     else
	sed -n '/'$i'/,/;/p' $infile >> tmp # WITHOUT
    endif
	
    sed 's/INSERT INTO `'$i'` VALUES //g' tmp > tmp2 
    
    sed 's/(//g' tmp2 > tmp # CLEANING UP
    sed "s/\'//g" tmp > tmp2
    sed 's/)//g' tmp2 > $i.csv
    
    #sed 's/)//g' tmp2 > $infile-$i.csv # USE THIS INSTEAD OF PREVIOUS LINE IF THERE ARE OTHER SQL 
                                        # FILES WITH SAME TABLE NAMES IN THE DIRECTORY/FOLDER
end

echo "$infile written to ..."
wc -l *.csv

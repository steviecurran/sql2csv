# sql2csv

C shell script to convert an SQL file to CSVs (one for each table). Especially useful when running into errors like "Parse error: file is not a database" and would rather query the database in python (or anything else apart from SQL).

E.g.  ./sql2csv.csh  WILL GIVE 

employees.sql written to 

      11 departments.csv
      
  331604 dept_emp.csv
  
      49 dept_manager.csv
      
  300025 employees.csv
  
  967331 salaries.csv
  
  443309 titles.csv


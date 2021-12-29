# JuliaDataAnalysis
# Goal:
The goal of this project is to 
1) Load the data into a SQLite database from zip archive downloaded from Data.gov.
2) Take a database, a name  and the sex as an argument and produce a plot over time of the frequency of the name.
3) Find boy and girl names that are the most similar in terms of historical frequency. 

# Steps to run:

- <b> PrepareData.jl </b>: This code assumes that names.zip is in the same folder as the file.
   To run, type- julia prepare.jl names.zip names.db

- <b> PlotData.jl : This code takes input from prepare.jl file.
   To run, type- julia plot.jl names.db <name> <sex>
   (Enter any name and sex. In the database, all names start with Uppercase. So in the argument, provide name with the first letter in uppercase)
  
- <b> FindSimilarNames.jl : Open terminal and type-
                         • (For MacOS) export JULIA_NUM_THREADS=4 
                           (FOR Windows) set JULIA_NUM_THREADS=4
                         • julia FindSimilarNames.jl
   
# File Description:  
- PrepareData.jl: 
  1) Read the name of the input file and output file from the command line.
  2) Use the Julia ZipFile.jl library to scan the input zip file. 
  3) Use SQlite.jl library to interface with SQLite3.
  4) Create the BabyNames table using SQLite.jl.  
  5) Scan the input zip file, find files with names "yob????.txt"
  6) For each such file, scan the content using the CSV.jl package 
  7) For each entry in the data file, write an entry in the table "names" recording the "year" (from the file name), "name", "sex" and "num" from the file content.
  8) Close the zip scanner and database connection
  
  

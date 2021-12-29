# JuliaDataAnalysis
# Goal:
The goal of this project is to 
1) Load the data into a SQLite database from zip archive downloaded from Data.gov.
2) Take a database, a name  and the sex as an argument and produce a plot over time of the frequency of the name.
3) Find boy and girl names that are the most similar in terms of historical frequency. 

# Steps to run:

- <b> PrepareData.jl </b>: This code assumes that names.zip is in the same folder as the file.
   To run, type- julia prepare.jl names.zip names.db

- <b> PlotData.jl </b> : This code takes input from prepare.jl file.
   To run, type- julia plot.jl names.db <name> <sex>
   (Enter any name and sex. In the database, all names start with Uppercase. So in the argument, provide name with the first letter in uppercase)
  
- <b> FindSimilarNames.jl </b> : Open terminal and type-
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
 
- PlotData.jl:
  1) Parse the command line arguments to extract the input.
  2) Establish database connection to the database file using SQLite.jl library.
  3) Query the database to get the year, num pair for the provided name and sex.
  4) Sort the data on year.
  5) Plot the data using Gadfly library.
   
 - SimilarBabyNames:
   1) Load the data from names.db into a DataFrame.
   2) Determine the total number of distinct boy and girl names (using DataFrame). Let these counts be Nb (number of boy names) and Ng(number of girl names) and Ny(number of years)
   3) Build a bidirectional map from boy_name => boy_index, boy_index => boy_name (and the same for girl and year). These maps indicate at what position in the Fb matrix, the frequencies for a specific boy name is stored
   4) Initialize two matrices: Fb(Nb x Ny) and Fg(Ng x Ny). These matrices will contain the frequency of all the baby names
   5) Scan the DataFrame and add counts to matrices Fb and Fg. The name frequencies are now succinctly recorded
   6) Compute the total number of children born in each year. Represent it as the vector Ty (indexed using the year indexing)
   7) Compute the matrices Pb and Pg that contain the probability (ratio of the frequency of the name w.r.t. the total number of children in that year) of a given name per year. These normalized matrices take into account the differences between population sizes over time. Notice that normalization is per year (i.e you are ensuring that the sum of all values of Pb and Pg for the same year is 1)
  8) Further, compute matrices Qb and Qg that normalize the values across years such that the L2 norm of all row vectors is 1. This ensures that the cosine distance computation in the next step is much easier
  9) Compute the cosine distance (i.e the dot product) of all pairs of boy and girl names. Specifically, form index pairs from Qb and Qg and compute the dot product of the vectors Qb[i] and Qg[j]. Keep track of the larges value you encounter (maximum) and the index pair where the maximum is achieved.
 10) Display the names (not indexes) of the boy, girl pair with the largest cosine distance 
  

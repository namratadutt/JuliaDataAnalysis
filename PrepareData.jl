using ZipFile
using CSV
using DataFrames
using SQLite

##############################################
############   Assignment 2   ################
##############################################
###      Created By: Namrata Dutt           ##
###    Date: Thursday, Feb 10, 2021         ##
###  Course: Intro to Data Science          ##
##############################################

# get inputs from command line
inputfile= ARGS[1]
outputfile= ARGS[2]



# create empty DataFrame
df1=DataFrame(  name= String[], sex= String[], num=Int[], year=Int[])

# read zipfile
r = ZipFile.Reader(string("./", inputfile))  
files=r.files

# create database
db = SQLite.DB("names")

# drop temporary table in which data is stored from dataframe
SQLite.execute(db, "drop table if exists tempname")

SQLite.execute(db, "drop table if exists BabyNames")

# create table
SQLite.execute(db, "create table if not exists BabyNames (
name TEXT,
sex TEXT,
num INTEGER, year INTEGER)")


# read each file and concatenate into dataframes
for i in 1:length(files)

    println(i,"/",length(files))

    # extract name of file 
    fname=string(files[i].name)

    # check if file contains txt extension
    if occursin(".txt", fname)!= true
        continue
    end
    
    # Read file
    cv=CSV.File(files[i], header= false)     

     # Convert file contents to dataframe
    df= DataFrame(cv)    

    # Rename columns
    df=select(df, "Column1" => "name", "Column2" => "sex", "Column3"=> "num") 

    # Extract year from filename
    fname=replace(fname,"yob"=>"")
    fname=replace(fname,".txt"=>"")
    
    # Create column for year
    n= size(df,1)
    yob= repeat([fname], n)
    df.year= yob

    # Concatenate all dataframes into one dataframe    
    global df1= vcat(df1,df)
    
end


# Load data into temporary table from dataframe
SQLite.load!(df1,db,"tempname", temp=false) 

# Insert data into BabyNames from temporary table
SQLite.execute(db, "INSERT INTO BabyNames SELECT * FROM tempname")

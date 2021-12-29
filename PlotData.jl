using SQLite
using Gadfly
using Query
using DataFrames
using RDatasets

##############################################
############   Assignment 2   ################
##############################################
###      Created By: Namrata Dutt           ##
###    Date: Thursday, Feb 10, 2021         ##
###  Course: Intro to Data Structure        ##
##############################################


# get inputs from command line
input1=ARGS[1]
input2= ARGS[2]
input3=ARGS[3]


# replace the name of input databse
fname=replace(input1,".db"=>"")

# connect to database  
db= SQLite.DB(fname)

# create query to get year and num
query1=string("SELECT year, num FROM BabyNames WHERE name='" ,input2,"'" , " AND sex='",input3,"'")

# execute query
res_df=DataFrame(DBInterface.execute(db,query1))

# sort the data by year
res_df=sort(res_df, (:year))

# plot the data 
display(plot(res_df, x="year", y="num", Geom.line))






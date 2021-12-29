using ZipFile
using CSV
using DataFrames
using SQLite
using IterableTables
using StatsBase
using DataFramesMeta
using SharedArrays
using Distributed
using Distances


##############################################
############   Assignment 3   ################
##############################################
###      Created By: Namrata Dutt           ##
###    Date: Thursday, Feb , 2021         ##
###  Course: Intro to Data Structure        ##
##############################################



@time begin

    # get inputs from command line

    # Read from database names
    db = SQLite.DB("names")

    # Read from BabyNames table
    Q = "SELECT * FROM BabyNames"
    dfnew = DataFrames.DataFrame(DBInterface.execute(db, Q))
    
    # Select males only from dataframe
    df_male = dfnew[(dfnew.sex .== "M"), :]
    unique_boys = unique(df_male, "name")

    # Select females only from dataframe
    df_female = dfnew[(dfnew.sex .== "F"), :]    
    unique_girls = unique(df_female, "name")

    # Get dataframe sorted by year

    df_years = sort(unique(dfnew, "year"), [:year])

    Nb = size(unique_boys)[1]
    Ng = size(unique_girls)[1]
    Ny = size(df_years)[1]

    # Create birectional map of boys
    boys_bmap = Dict{Integer, String}(i => unique_boys.name[i] for i in 1:Nb)
    boys_bmap_inv = Dict{String, Integer}(values(boys_bmap) .=> keys(boys_bmap))

    # Create birectional map of girls
    girls_bmap = Dict{Integer, String}(i => unique_girls.name[i] for i in 1:Ng)
    girls_bmap_inv = Dict{String, Integer}(values(girls_bmap) .=> keys(girls_bmap))

    # Create birectional map of years
    year_bmap = Dict{Integer, Integer}(i => df_years.year[i] for i in 1:Ny)
    


    # Initialize empty Fb matrix
    Fb = zeros(Integer, Ng, Ny)
    year_keys = keys(sort(year_bmap))

    for i in year_keys
        res = df_male[(df_male.year .== year_bmap[i]), [:name, :num]]
        for val in eachrow(res)
            curr_name = val.name
            curr_num = val.num
            Fb[boys_bmap_inv[curr_name], i] = curr_num
        end
    end



    # Initialize empty Fg matrix
    Fg = zeros(Integer, Ng, Ny)
    for i in year_keys
        res = df_female[(df_female.year .== year_bmap[i]), [:name, :num]]
        for val in eachrow(res)
            curr_name = val.name
            curr_num = val.num
            Fg[girls_bmap_inv[val.name], i] = val.num
        end
    end

    # Create matrix Ty 
    Ty_b= sum(Fb, dims=1)
    Ty_g= sum(Fg,dims=1)
    Ty = broadcast.(+, Ty_b, Ty_g)
    

    # create matrix Pb and Pg
    Pb = broadcast.(/, Fb, Ty_b)
    Pg = broadcast.(/, Fg, Ty_g)

    # println("part 5 completed")
    # create matrix Qb and Qg
    norms_b = sqrt.(sum(Pb.^2,dims=2))
    Qb=broadcast.(/, Pb, norms_b)

    norms_g = sqrt.(sum(Pg.^2,dims=2))
    Qg=broadcast.(/, Pg, norms_g)
    




    # compute pairwise dot product
    
    global dot_prod = Array{Float64}

    max_pairs= []
    glob_max_val=0
    glob_max_name=[]
    counter = 0
    part_Qb = []
    part_size = convert(Int32, round(size(Qb)[1]/100))
    counter = 1
    for i in 1:100

        push!(part_Qb, [Qb[counter:min(part_size+counter, size(Qb)[1]),:], counter])
        global counter = counter + part_size + 1
    end

    
    pairs = []
    part_Qg = []
    part_size1 = convert(Int32, round(size(Qg)[1]/100))
    counter = 1
    for i in 1:100

        push!(part_Qg,[Qg[counter:min(part_size1+counter, size(Qg)[1]),:], counter])
        for j in 1:length(part_Qb) 
            push!(pairs, [part_Qb[j], last(part_Qg)])
        end
        global counter = counter + part_size1 + 1

    end


    function DotProd(vec1, vec2, boy_ind, girl_ind)

        result = []
        maximum = -1
        bind = 0
        gind = 0
        names_pair = []
        for i in 1: size(vec1)[1]
            curr1 = vec1[i]'
            for j in 1:size(vec2)[1]
                curr2 = vec2[j]
                p = curr1 * curr2
                # p = round(p, digits=1)
                if p > maximum 
                    maximum = p
                    bind = i+boy_ind-1
                    gind = j+girl_ind-1
                    names_pair = [boys_bmap[bind], girls_bmap[gind]]
                end
            end
    
    
        end
        return [maximum, bind, gind, names_pair]
    end
    

    max_val = -1
    max_bind = []
    max_gind = []
    max_bnames = []
    max_gnames = []
    max_name_pairs = []
    max_prod = []
    new_val = []
    new_pair = []

    Threads.@threads for i in 1:length(pairs) 

        curr = pairs[i]
        x, boy_ind = curr[1]
        y, girl_ind = curr[2]
        res = DotProd(x,y,boy_ind, girl_ind)
        val, bind, gind, name_pairs = res
        bind = Int(floor(bind))
        gind = Int(floor(gind))

        push!(new_val, val)
        push!(new_pair, name_pairs)
        # print(new_val, new_pair)
        # println("Current max val ", max_val, " ", val)
        if val > max_val 
            global max_val = val
            global max_prod = [val]
            global max_bnames = [boys_bmap[bind]]
            global max_gnames = [girls_bmap[gind]]           
            global max_bind = [bind]
            global max_gind = [gind]           
            global max_name_pairs = [[boys_bmap[bind], girls_bmap[gind]]]

        elseif val == max_val 
            # println("yes")
            push!(max_prod, val)
            push!(max_bnames, boys_bmap[bind])
            push!(max_gnames, girls_bmap[gind])
            push!(max_bind, bind)
            push!(max_gind, gind)
            push!(max_name_pairs, [boys_bmap[bind], girls_bmap[gind]])

        end

    end

    
    # max_val = round(max_val, digits=1)
    # indices = [x for x in 1:length(max_prod) if max_prod[x] == max_val ]    
    C = sort(collect(zip(new_val, new_pair)); rev=true, by=first)
    max_name_pairs = [x[2] for x in C]
    # print(max_name_pairs)
    max_len = min(1000, length(new_val))
    max_name_pairs = max_name_pairs[1:1000]
    println("OUTPUT: ")
    # println("Maximum distance ", max_val)
    println("Boys and girls pairs ", max_name_pairs)

end






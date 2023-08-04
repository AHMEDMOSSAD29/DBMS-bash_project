#!/bin/bash
shopt -s extglob

PS3="
Enter your option >>> "  
clear
# Function to create a new database
create_database() {
    read -p "
              Enter the name of the new database: " database_name
    
    regex="^[a-zA-Z][a-zA-Z0-9_]*$"
    
    if ! [[ $database_name =~ $regex ]]; then
	
        echo "
	       Invalid,The name should only contain alphanumeric characters and underscores.
	     "
	
        return
    elif [[ -d $database_name ]]; then

        echo "
	           Database[ $database_name ]already exists. Please choose a different name.
	     "
	
        return
    else
    
    mkdir $database_name
    clear
   
    echo "
                                Database[ $database_name ]created successfully!
	 "
    
    fi
}

# Function to list all existing databases
list_databases() {
clear
        echo " 
	                *---------------------List of Databases----------------------*
	     "
     for db in */
    do
        if [[ -d $db ]]

        then
                
                echo "
		                           Database Name=[${db%/}]
		     "
	      
	else
         	clear
                echo "
	         	                    No Databases avilable    
	             "
               
        fi
    done
}

# Function to drop a database
drop_database() {
    read -p "
    Enter the name of the database to drop (separated by spaces if more than one): " db_names
    for db_name in $db_names
    do
        if [[ ! -d $db_name ]]
        then
	clear
                echo "
	        	              Database[ $db_name ]does not exist!
		     "
                         read -p "Would you like to list all Databases? (y/n) " ans
                         if [[ "$ans" =~ ^Y$|^y$ ]]
                         then
                          list_databases
                         fi

	        
        else
            rm -rf $db_name
	    clear
	    
            echo "
	                           Database[ $db_name ]dropped successfully!
	         "
	   

        fi
    done
}
 
#function to create table 
create_table(){
	read -p "Enter the table name (str): " table_name
     if [[ ! "$table_name" =~ ^[a-zA-Z_]+$ ]]
    then
	    clear
        echo "
	          Error: The table name can only contain letters, underscores."
        return 1
    fi

    if [ -f "$table_name" ]
    then
        read -p "Table [$table_name] exists. Would you like to list all tables? (y/n): " ans1
        if [[ "$ans1" =~ ^[Yy]$ ]]
        then
            list_table
        fi
    else
        touch "$table_name"
        touch "$table_name.metadata"
        read -p "Enter number of columns (int): " column_count
	if [[ "$column_count" =~ ^[0-9]*$ ]]; then
		echo "number of columns: $column_count" >> "$table_name.metadata"
            else
                    clear
                echo "
		           Error: The number of columns must be numbers "
                return 1
            fi
	    primary_key_set=false
            primary_key=""

for ((i=1; i<=$column_count; i++))
do
    read -p "Enter the name of column $i (str): " column_name
    echo "name of column $i: $column_name" >> "$table_name.metadata"
    read -p "Enter the datatype of column $i :" column_type
    echo "type of column $i: $column_type" >> "$table_name.metadata"

    if ! $primary_key_set; then
        while true; do
            read -p "Is $column_name the primary key? [yes/no]: " is_primary
            case $is_primary in
                [yY]es )
                    primary_key=$column_name
                    primary_key_set=true
                    break ;;
                [nN]o )
                    break ;;
                * )
                    echo "Please answer yes or no." ;;
            esac
        done
    fi
done

# Write primary key information to metadata file
echo "primary key: $primary_key" > "$table_name.metadata.tmp"
cat "$table_name.metadata" >> "$table_name.metadata.tmp"
mv "$table_name.metadata.tmp" "$table_name.metadata"


	awk -F': ' 'NR>2 && NR % 2 == 1 {print $2}' $table_name.metadata >>tmp
	awk '{printf " %s |",$0}' tmp > $table_name
	rm -rf tmp

        echo "Table [$table_name] created successfully"
    fi
}

list_table() {
	clear
 echo "
                               * -----------------List of Tables---------------- *
        "
	dir=$(pwd)

    if [ "$(ls -A $dir)" ]
    then
	    echo "`ls $dir`"
    else
        echo "
	                                         No tables exist 
	     "
        read -p "Would you like to create new table? (y/n) " ans
        if [[ "$ans" =~ ^Y$|^y$ ]]
        then
            create_table
        else
            echo "
	                                         No table created
	    "
	    clear
        fi
    fi
}

drop_table() {
    read -p "
               Enter the name(s) of the table(s) to drop: " -a table_names
    for table_name in "${table_names[@]}"
    do
        if [ -f "$table_name" ]
        then
            rm -rf "$table_name"
	    rm -rf "$table_name.metadata"
	    clear
            echo "
	                             table [$table_name] dropped successfully.
	               "
		     
        else
		clear
		      read -p "
               Table[$table_name]doesnt exist,Would you like to list all Tables? (y/n) " ans
                         if [[ "$ans" =~ ^Y$|^y$ ]]
                         then
                          list_table
                         fi
 
        fi
    done
}

#function to insert into table
insert_into_table(){
    read -p "Enter the table name you want to insert into (str): " table_name

    if [ ! -f "$table_name" ]; then
        clear
        read -p "Table [$table_name] doesn't exist. Would you like to list all tables? (y/n) " ans
        if [[ "$ans" =~ ^[Yy]$ ]]; then
            list_table
        fi
        return 1
    fi

 
}
# function to select data from a table

#function to show table metadata
show_data(){

	read -p "Enter table name : " table_name
	if [ -f "$table_name" ]
        then
		clear
		echo " 
		     *-----------------Metadata of Table[$table_name]----------------*
				      "
		sed -n '1,$p' $table_name.metadata | sed G | awk '{printf("%60s\n",$0)}'

        else
                clear
                      read -p "
               Table[$table_name]doesnt exist,Would you like to list all Tables? (y/n) " ans
                         if [[ "$ans" =~ ^Y$|^y$ ]]
                         then
                          list_table
                         fi

        fi



}

# Function to connect to a database
connect_to_database() {
    read -p "
                 Enter the name of the database to connect : " database_name
    if [[ ! -d $database_name ]]
    then
	    clear
       read -p "
              Database [$database_name] doesnt exist,Would you like to list all Databases? (y/n) " ans
                         if [[ "$ans" =~ ^Y$|^y$ ]]
                         then
                          list_databases
                         fi

                          return   
    fi
    cd $database_name
    clear
   
    echo "
                            Connected to Database[$database_name].
         "
   



while true
do

        echo "======================================================================================="
        echo "           	                  Database Menu  		                     "
        echo "======================================================================================="
	    

    select n in  "press c to Create a table" "press l to List tables"\
                 "press d to drop table" "press i to insert into table"\
                 "press s to select from table" "press D to Delete from table"\
		 "press u to update table" "press w to show tables metadata"\
		 "press q to return to main menu"
    do
        case $REPLY in
            c)
                create_table 
                break ;;
                
            l)
                list_table
                break ;;
            d)
                drop_table
                break ;;
            i)
                insert_into_table
                break ;;
            D)
                delete_table
                break ;;
	    u)
		update_table
		break ;;
	    w)
		show_data
		break ;;

	    s) 
		select_from_table
		break ;;
	    q)
		cd ..
		clear
                
                echo "
		                                 Returned to Main Menu.
		     "
               
                break 2 ;;
            *)

		    
                    echo " 
	 	                                    Invalid option           
		         "
                    
		 ;;   
        esac
    done
done
 
}



# Main menu 

ahmed=$(cat << "EOF"
                   _                              _     __  __                                     _ 
           /\     | |                            | |   |  \/  |                                   | |
          /  \    | |__    _ __ ___     ___    __| |   | \  / |   ___    ___    __ _    __ _    __| |
         / /\ \   | '_ \  | '_ ` _ \   / _ \  / _` |   | |\/| |  / _ \  / __|  / _` |  / _` |  / _` |
        / ____ \  | | | | | | | | | | |  __/ | (_| |   | |  | | | (_) | \__ \ | (_| | | (_| | | (_| |
       /_/    \_\ |_| |_| |_| |_| |_|  \___|  \__,_|   |_|  |_|  \___/  |___/  \__,_|  \__,_|  \__,_|
                                                                                               
                                                                                               
                                            Welcome to my database 
EOF
)
echo "$ahmed "

while true
do

	echo "================================================================================================"
	echo "                                         Main Menu                                              "
        echo "================================================================================================"

    select n in  "press C to Create a database" "press l to List all databases"\
		  "press c to connect to a database"\
		  "press d to Drop a database" "press q to Quit"
    do
        case $REPLY in
            C)
                create_database
                break ;;
            l)
                list_databases
                break ;;
            c)
                connect_to_database
                break ;;
            d)
                drop_database
                break ;;
            q)
		clear
                exit ;;
            *)
                    echo " 
	               	                             Invalid option   
	  	         " 
		;;
        esac
    done
done








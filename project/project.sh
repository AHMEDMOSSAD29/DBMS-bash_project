#!/bin/bash
shopt -s extglob

PS3="
Enter your option >>> "  


# Function to create a new database
create_database() {
    read -p "Enter the name of the new database: " database_name
    
    regex="^[a-zA-Z][a-zA-Z0-9_]*$"
    
    if ! [[ $database_name =~ $regex ]]; then
	echo "                                                                             "
        echo "Invalid,The name should only contain alphanumeric characters and underscores."
	echo "                                                                             "
        return
    elif [[ -d $database_name ]]; then
	echo "                                                                       "
        echo "Database[ $database_name ]already exists. Please choose a different name."
	echo "                                                                       "
        return
    else
    
    mkdir $database_name
    echo "                                             "
    echo "Database[ $database_name ]created successfully!"
    echo "                                             "
    fi
}

# Function to list all existing databases
list_databases() {

	echo "========================================================================="
        echo "                             List of Databases                           "
        echo "========================================================================="
     for db in */
    do
        if [[ -d $db ]]

        then
                echo "                           "
                echo    "Database Name=[ ${db%/} ]"
	        echo "                           "
	else
         	echo "                               "
                echo "     No Databases avilable     "
                echo "                               "
        fi
    done
}

# Function to drop a database
drop_database() {
    read -p "Enter the name of the database to drop (separated by spaces if more than one): " db_names
    for db_name in $db_names
    do
        if [[ ! -d $db_name ]]
        then
		echo "                                 "
                echo "Database[ $db_name ]does not exist."
	        echo "                                 "
        else
            rm -rf $db_name
	    echo "                                       "
            echo "Database[ $db_name ]dropped successfully!"
	    echo "                                       "

        fi
    done
}
 
 create_table() {
    # Prompt user for table name
    while true; do 
        read -p "Enter the table name: " table_name
        if ! [[ "$table_name" =~ ^[a-zA-Z]+$ ]]; then
            echo "Invalid table name. Please choose another one."
        elif [ -f "$table_name" ]; then
            echo "Table already exists."
        else
            touch "$table_name.csv"
            echo "Table [$table_name] created successfully."
            break
        fi
    done

    # Prompt user for column details
    while true; do 
        read -p "Enter column name (leave empty to finish): " column_name
        if [ -z "$column_name" ]; then
            break
        elif ! [[ "$column_name" =~ ^[a-zA-Z0-9]+$ ]]; then
            echo "Invalid column name. Please choose another one."
        else
            # Prompt user for column data type
            read -p "Enter column data type: " column_type

            # Prompt user for primary key status
            read -p "Is this column a primary key? (y/n): " is_primary_key
            if [[ "$is_primary_key" =~ ^y$|^Y$ ]]; then
                column_type="$column_type:PRIMARY KEY"
            fi

            # Add column to table
            echo "Adding column [$column_name] with type [$column_type]."
            echo "$column_name:$column_type" >> "$table_name.csv"
        fi
    done
}




# Function to connect to a database
connect_to_database() {
    read -p "Enter the name of the database to connect to: " database_name
    if [[ ! -d $database_name ]]
    then
        echo "                                                                       "
        echo "Database[ $database_name ]does not exist. Please choose a different name."
        echo "                                                                       "
        return
    fi
    cd $database_name
    echo "                                     "
    echo "Connected to database[ $database_name ]."
    echo "                                     "



while true
do

        echo "========================================================================="
        echo "                              Database Menu                                  "
        echo "========================================================================="

    select n in  "press c to Create a table" "press l to List tables"\
                 "press d to drop table" "press i to insert into table"\
                 "press s to select from table" "press D to Delete from table"\
		 "press u to update table" "press q to return to main menu"
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
                insert_table
                break ;;
            D)
                delete_table
                break ;;
	    u)
		update_table
		break ;;

	    s) 
		select_table
		break ;;
	    q)
		cd ..
                echo "                      "
                echo "Returned to Main Menu."
                echo "                      "
                break 2 ;;
            *)

		    echo "                                       "
                    echo "            Invalid option             "
                    echo "                                       "
		 ;;   
        esac
    done
done

 
}



# Main menu loop
while true
do

	echo "========================================================================="
        echo "                              Main Menu                                  "
        echo "========================================================================="

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
                exit ;;
            *)
		    echo "                                       "
                    echo "            Invalid option             " 
	            echo "                                       "
		;;
        esac
    done
done








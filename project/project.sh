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
	---------------------List of Databases----------------------
	     "
     for db in */
    do
        if [[ -d $db ]]

        then
                
                echo "
		        Database Name=[ ${db%/} ]
		     "
	      
	else
         	
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
		
                echo "
	        	Database[ $db_name ]does not exist.
		     "
	        
        else
            rm -rf $db_name
	    clear
	    
            echo "
	              Database[ $db_name ]dropped successfully!
	         "
	   

        fi
    done
}
 

create_table() {

read -p "
           Enter a name for the table: " table_name
	if [[ -f "$table_name" ]];then
		echo "
	 	     table already exists
		"
		
		
	else
		read -p "Enter number of columns :" cols;
		if [[ $cols -eq 0 ]];then
			echo "
			      Cannot create a table without columns 
			      "
			
		fi
		 touch $table_name
		 touch $table_name.metadata
		 echo "Table Name:"$table_name >>$table_name.metadata
		 echo "Number of columns:"$cols >>$table_name.metadata
		

		for (( i = 1; i <= cols; i++ )); do
			if [[ i -eq 1 ]];then
				read -p "Enter column $i name as a primary key: " name;
				echo "The primary key for this table is: "$name >>$table_name.metadata
				echo "Names of columns: " >>$table_name.metadata
				echo -n $name"," >>$table_name.metadata

			elif [[ i -eq cols ]];then
				read -p "Enter column $i name: " name;
				echo -n $name >>$table_name.metadata
			else
				read -p "Enter column $i name: " name;
				echo -n $name"," >>$table_name.metadata
			fi 
		done 
		clear

		echo " 
	            	Table created sucsessfully  "
			
		
	fi
}



#function to list tables
list_table() {
	clear
 echo "
        -----------------list of tables----------------
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
            rm -r "$table_name"
	    rm -r "$table_name.metadata"
	    clear
            echo "
	              table [$table_name] dropped successfully.
	               "
		     
        else
		clear
            echo "
	               table [$table_name] does not exist, cannot be dropped.
	               "
		       
        fi
    done
}

insert_into_table() {

read -p "Enter the table name: " table_name
	if [[ -f "$table_name" ]]; then
	typeset -i cols=`awk -F, '{if(NR==5){print NF}}' $table_name.metadata`
	
	for (( i = 1; i <= $cols; i++ ));
       	do
	 	colname=`awk -F, -v"i=$i" '{if(NR==5){print $i}}' $table_name.metadata`
		read -p "
		           Enter $colname: " value

		if [[ $colname -eq id ]];then
				 pks=`sed -n '1,$'p $table_name| cut -f1 -d,`
				for j in $pks 
				do					
					 if [[ $j -eq $value ]]; then 

					        read -p "Cannot use redundant primary key value. Do you want to  show primary keys? (y/n) " answer 
					   if [[ "$answer" =~ ^Y$|^y$ ]]; then

					        awk -F, '{print $1}' $table_name
						return
					   else
						   return	
					   fi 

					 fi
				done
		fi 
			if [[ $i != $cols ]]; then
				echo -n $value"," >>$table_name
			else	
				echo $value >>$table_name
			fi
	done 
	echo "
	       Data has been sorted successfully
	       "
 	
	else
		read -p "
		table [$table_name] doesn't exist! list tables (y/n) :" ans
		       if [[ "$ans" =~ ^Y$|^y$ ]]
                           then
                             list_table
                       fi

		       
		
	fi	
}

# function to select data from a table
select_from_table() {
  # read the number of fields from the user
  read -p "Enter name of table want to select from :" table_name
  read -p "Enter the number of fields you want to select: " num_fields

  # read the field numbers from the user
  read -p "Enter the field numbers you want to select (separated by commas): " fields

  # format the field numbers into a cut command string
  cut_string=$(echo "$fields" | tr ',' ' ' | awk '{for(i=1;i<=NF;i++) printf "$%s ",$i}')

  # display the selected data
  printf "%-10s\n" $(echo "$fields" | tr ',' '\t')
  cut -d $'\t' -f$cut_string < "$table_name" | column -t
}


# Function to connect to a database
connect_to_database() {
    read -p "
                 Enter the name of the database to connect : " database_name
    if [[ ! -d $database_name ]]
    then
       
        echo "
	       Database[ $database_name ]does not exist. Please choose a different name.
	     "
        
        return
    fi
    cd $database_name
    clear
   
    echo "
           Connected to Database[ $database_name ].
         "
   



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
                insert_into_table
                break ;;
            D)
                delete_table
                break ;;
	    u)
		update_table
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

echo "
          _________________________ Welcome to ITI Database ____________________________
"
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








#!/bin/bash
#Done by: Saniya
#this will store the number of records in text file to use in functions
size=$(wc -l < "$1")
#function to check if user entered ID is 7 digits ling
function IDvalidation(){
#regex is used to make sure that the user enters a 7 digit ID 
validation='^[0-9]{7}$'
  if [[ ! "$id" =~ $validation ]]
  then
    #erorr will be shown in red, tag -e "\e[1;31mA B C\e[0m" is used to display text in color while 31m is to indicated red color
    echo -e "\e[1;31mID should be 7 digits long!\e[0m"
    existingValidation
  fi
}

#function to check if user ented ID already exists
function existingValidation(){
  echo Please enter ID:
  read id
  #call validation function to see if ID is 7 digits long
  IDvalidation
  for i in ${IDs[@]}
  do  
    if [ $id -eq $i ]
    then 
      echo -e "\e[1;31mThis ID already exists!\e[0m"
      #calls function again to give loop till condition is satisfied
      existingValidation
    fi
  done
}

#function to allow user to enter details and add a new employee
function add_Employee(){
  echo "Enter 1 to add a Full-time employee and 2 for Part-time employee"
  read opt
  #first validate the ID entered
  existingValidation
  echo Please enter name:
  read name
  echo Please enter salary:
  read salary
  echo Please enter revenue:
  read revenue
  echo Please enter commission:
  read commission
  #details entered will be added to the arrays
  IDs+=("$id")
  names+=("$name")
  salaries+=("$salary")
  revenues+=("$revenue")
  commission+=("$commission")
  if [ $opt -eq 1 ]
  then
    #details entered will be written to the file as a Full-time employee
    echo $id $name Full-time $salary $revenue $commission >> employees.txt
    status+=("Full-time")
  else
    echo Please enter hours worked:
    read hrs
    #details entered will be written to the file as a part-time employee
    echo $id $name Part-time $salary $revenue $commission $hrs>> employees.txt
    status+=("Part-time")
    hrs_worked+=("$hrs")
  fi
  size=$((size+1))
}

#function to remove the employee that user wants to delete
function remove_employee(){
  flag2=0
  for i in "${!IDs[@]}"
  do
    if [[ ${IDs[i]} = $1 ]] 
    then
      #unset is used to remove the employee details from the arrays
      unset 'IDs[i]' 'names[i]' 'status[i]' 'salaries[i]' 'revenues[i]' 'commission[i]' 'hrs_worked[i]'
      #sed will be used to remove the employee from the file via the argument which is the employee ID
      sed -i "/$1/d" employees.txt
      echo -e "\e[1;32mEmployee has been successfully removed!\e[0m"
      break
    else
      #if entered ID does not exist in array increment flag2
      flag2=$(($flag2+1))
    fi
  done
  #validation to check if entered ID exists: if flag2 is equal to number of records then entered ID does not exist in file
  if [[ $flag2 -eq $size ]]
  then
    echo -e "\e[1;31mID entered does not exist!\e[0m"
  fi
}

#function to display part-time employees from file
function get_part_time_employees(){
  #grep is used to match employees who are part timers in the argument whichi is the filename
  grep -E "Part-time" $1
}

#function to display full-time employees from file
function get_full_time_employees(){
  #grep is used to match employees who are full timers in the argument whichi is the filename
  grep -E "Full-time" $1
}

#function to calculate total salary for each employee
function total_sal(){
  #salaries/wages will be calculated for each employee and added into the array 
  percent=25
  #${!IDs[@]} will take index numbers of the array
  for k in "${!IDs[@]}"
  do 
  month_salary=$((48*${salaries[$k]}))
    if [[ "${status[$k]}" = "Full-time" ]]
    then
    sal_full=$((${salaries[$k]}+(${revenues[$k]}*${commission[$k]})))
    totalSalaries+=("$sal_full")
    fi
    if [[ "${status[$k]}" = "Part-time" ]]
    then
      if [[ ${hrs_worked[$k]} -gt 48 ]]
      then
        sal=`expr ${salaries[$k]} / 100`
        pct=$( expr $sal \* $percent )
        overtime=$(((${hrs_worked[$k]}-48)*$pct))
        sal_part1=$(($month_salary+$overtime+(${revenues[$k]}*${commission[$k]})))
        totalSalaries+=("$sal_part1")
      elif [[ "${hrs_worked[$k]}" -eq 48 ]]
      then
        Sal_part2=$(($month_salary+(${revenues[$k]}*${commission[$k]})))
        totalSalaries+=("$Sal_part2")
      else
        Sal_part3=$(((${hrs_worked[$k]}*${salaries[$k]})+(${revenues[$k]}*${commission[$k]})))
        totalSalaries+=("$Sal_part3")
      fi
    fi
  done
}

#function to display all employees with total salary and colors
function list_AllEmployees()
{
  # function called to calculate salaries
  total_sal
  for j in "${!IDs[@]}"
  do
    if [ "${status[$j]}" = "Part-time" ]
    then
      if [ ${hrs_worked[$j]} -gt 48 ]
      then 
        echo -e "\e[1;92m"${IDs[$j]} ${names[$j]} ${totalSalaries[$j]}"\e[0m"
      elif [ ${hrs_worked[j]} -lt 12 ]
      then 
        echo -e "\e[1;96m"${IDs[$j]} ${names[$j]} ${totalSalaries[$j]}"\e[0m"
      else
        echo -e "\e[1;95m"${IDs[$j]} ${names[j]} ${totalSalaries[$j]}"\e[0m"
      fi
    elif [ "${status[$j]}" = "Full-time" ]
    then
      if [ ${revenues[$j]} -lt 100000 ]
      then 
        echo -e "\e[1;93m"${IDs[$j]} ${names[$j]} ${totalSalaries[$j]}"\e[0m"
      else
        echo -e "\e[1;95m"${IDs[$j]} ${names[$j]} ${totalSalaries[$j]}"\e[0m"
      fi
    fi
  done
}

#function to increase commission for employee user wants to 
function increase_commission_rate()
{
	printf "Enter New Commission Rate: "
	read NewCommission
	flag=0
  flag2=0

	# Validating New commission
	while [[ $flag -ne 1 ]]; do
		if [[ $NewCommission -le 0 ]]; then
			printf "${RED}Invalid Commission Rate. Try Again\n"
			read NewCommission
		else
			flag=1
			break
		fi
	done

  #to update arrays with new commission
  for i in "${!IDs[@]}"
  do  
    if [[ "${IDs[i]}" -eq "$1" ]]
    then
      commission[$i]=$NewCommission
    fi
  done 

  #to update file with new commission with sed
	while read ID NAME STATUS SALARY REVENUE COMMISSION HRS_WORKED
	do
		if [[ $ID == $1 ]]; then
			sed -i "s/$COMMISSION/$NewCommission/" employees.txt
			echo -e "\e[1;32mValue Updated Successfully\e[0m"
    		else
      		flag2=$(($flag2+1))
		fi
	done < employees.txt
  #validation to check if entered ID exists:
  if [[ $flag2 -eq $size ]]
  then
    echo -e "\e[1;31mID entered does not exist!\e[0m"
  fi
}

#function to increase hourly wage for employee user wants to 
function increase_hourly_wage()
{
	echo "Enter percentage by which you want to increase Hourly Wage: "
	read percentage
	flag=0
  flag2=0

	# Validating New Value
	while [[ $flag -ne 1 ]]; do
		if [[ $percentage -le 0 ]]; then
			echo -e "\e[1;31mInvalid Hourly Wage. Try Again\e[0m"
			read percentage
		else
			flag=1
			break
		fi
	done

  #to update file with new wage
	while read ID NAME STATUS SALARY REVENUE COMMISSION HRS_WORKED
	do
		if [[ $ID == $1 ]]; then
			if [[ "$STATUS" == "Full-time" ]]; then
				echo -e "\e[1;33mWages don't apply to Full-time Employees\e[0m"
				break
			fi
      #calculate the new wage with entered percentage
			old_wage=`expr $SALARY / 100`
			mid=$( expr $old_wage \* $percentage )
			new_wage=$(( $SALARY + $mid ))
      #to update file with new wage with sed
			sed -i "s/$SALARY/$new_wage/" employees.txt
      echo -e "\e[1;32mValue Updated Successfully\e[0m"
    else
      flag2=$(($flag2+1))
		fi
	done < employees.txt

  #to update arrays with new wage
  for i in "${!IDs[@]}"
  do  
    if [[ "${IDs[i]}" -eq "$1" ]]
    then
      salaries[$i]=$new_wage
    fi
  done 
  #validation to check if entered ID exists:
  if [[ $flag2 -eq $size ]]
  then
    echo -e "\e[1;31mID entered does not exist!\e[0m"
  fi
}

#function to increase base salary for employee user wants to 
function increase_base_salary()
{
	echo "Enter percentage by which you want to increase Base Salary: "
	read percent

	flag=0
  flag2=0
	# Validating New Value
	while [[ $flag -ne 1 ]]; do
		if [[ $percent -le 0 ]]; then
			echo -e "\e[1;31mInvalid Base Salary. Try Again\e[0m"
			read percent
			#statements
		else
			flag=1
			break
		fi
	done

  #to update file with new salary
	while read ID NAME STATUS SALARY REVENUE COMMISSION HRS_WORKED
	do
		if [[ $ID == $id ]]; then
      if [[ "$STATUS" == "Part-time" ]]; then
				echo -e "\e[1;33mSalaries don't apply to Part-time Employees\e[0m"
				break
			fi
      #calculate the new salary with entered percentage
			old_salary=`expr $SALARY / 100`
			mid=$( expr $old_salary \* $percent )
			new_salary=$(( $SALARY + $mid ))
      #to update file with new salary with sed
			sed -i "s/$SALARY/$new_salary/" employees.txt
      echo -e "\e[1;32mValue Updated Successfully\e[0m"
    else
      flag2=$(($flag2+1))
		fi
	done < employees.txt

  #to update arrays with new salary
  for i in "${!IDs[@]}"
  do  
    if [[ "${IDs[i]}" -eq "$1" ]]
    then
      salaries[$i]=$new_salary
    fi
  done 
  #validation to check if entered ID exists:
  if [[ $flag2 -eq $size ]]
  then
    echo -e "\e[1;31mID entered does not exist!\e[0m"
  fi
}

#this is the argument from the call for shell which will be the file name 
filename=$1
#loop will read the file and store its details into the arrays
while read ID name statuses salary revenue commissions hrs_works
do
    IDs+=("$ID")
    names+=("$name")
    status+=("$statuses")
    salaries+=("$salary")
    revenues+=("$revenue")
    commission+=("$commissions")
    if [ -z "$hrs_works" ]
    then
    hrs_worked+=(0)
    else
    hrs_worked+=("$hrs_works")
    fi
done < $filename

#loop to display the menu till user chooses to quit the program
while true
do
  echo -e "\e[1;36m=========================================================================\e[0m"
  echo -e "\e[1;93m              Welcome to Mee Town Employee Management System\e[0m"
  echo  -e "\e[1;36m--------------------------------------------------------------------------\e[0m"
  echo 1. Add a new employee 
  echo 2. Remove existing employee 
  echo 3. List only part time employees 
  echo 4. List only full time employees
  echo 5. List all employees with total calculated salary
  echo 6. Increase commission rate for an employee
  echo 7. Increase hourly wage or base salary of an employee by some percentage
  echo 8. Quit
  echo  -e "\e[1;36m--------------------------------------------------------------------------\e[0m"
  echo Please enter the option of you want to choose:
  read option
  echo  -e "\e[1;36m--------------------------------------------------------------------------\e[0m"
  #switch case to manoeuvre the various functions that user may want to run
  case $option in
    "1") add_Employee
        echo -e "\e[1;32mEmployee has been successfully added!\e[0m"
    ;;
    "2") echo Enter ID:
        read id
        remove_employee $id
    ;;
    "3") get_part_time_employees employees.txt
    ;;
    "4") get_full_time_employees employees.txt
    ;;
    "5") echo -e "\e[1;92m1) Part time employees with hours worked more than 48 will be displayed in green\e[0m"
        echo -e "\e[1;96m2) Part time employees with hours worked less than 12 will be displayed in cyan\e[0m"
        echo -e "\e[1;93m3) Full time employees with revenue less than AED 100,000 will be displayed in yellow\e[0m"
        echo -e "\e[1;95m4) Other employees will be displayed in purple\n\e[0m"
        list_AllEmployees
    ;;
    "6") echo Enter ID:
          read id
          increase_commission_rate $id
    ;;
    "7") echo "1) Increase Hourly Wage    2) Increase Base Salary"
        read opt
        if [ $opt -eq 1 ]
        then
          echo Enter ID:
          read id
          increase_hourly_wage $id
        elif [ $opt -eq 2 ]
        then
          echo Enter ID:
          read id
          increase_base_salary $id
        else echo -e "\e[1;31mInvalid Option!\e[0m"
        fi
    ;;
    "8") echo -e "\e[1;93m                     Thank you for using our system! :D\e[0m" 
    exit
    ;;
    *) echo -e "\e[1;31mInvalid Option! Try again\e[0m"
  esac
done

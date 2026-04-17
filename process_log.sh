printf "\nWelcome to your log Management System.\nPlease enter the name of the log file you want to analyze:\n"
while true 
do #keep asking until the user enters a valid, readable file
read logFileName #read the file name from the user
if [ -r "$logFileName" ] #check if the file exists and is readable 
then
break  #If valid, break the loop and continue
else #ask again
printf "\nPlease enter a correct name for an existing readable log file.\n"
fi
done
./Functions/process_log_functions.sh "$logFileName" #call process_log_functions.sh and send to it the log file  

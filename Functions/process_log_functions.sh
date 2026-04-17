logFileName=$1
readData="" # to hold the users choice 
while [ "$readData" != "9" ]
do # menu 
printf "\nKindly, Choose an option from the following menu:\n1. Number of sessions per course.\n2. Average attendance per course.\n3. List of absent students per course.\n4. List of late arrivals per session.\n5. List of students leaving early.\n6. Average attendance time per student per course.\n7. Average number of attendances per instructor.\n8. Most frequently used tool.\n9. Exit.\n"
read readData # to read users input 
case "$readData"
in
1) #count the number of sessions for a given course 
printf "\nPlease enter the coursre ID:\n"
read courseID
numOfSessions=`grep ".*,.*,.*,.*,.*,\<$courseID\>,.*,.*,.*,.*,.*" "$logFileName" | cut -d, -f9 | sort | uniq | wc -l`
 # grep → filter only the lines that contain the given course ID
 # cut -d, -f9 → extract the 9th field (SessionID)
 # sort → sort the session IDs
 # uniq → remove duplicates (keep only unique sessions)
 # wc -l → count the number of unique sessions
printf "\nThe number of %s sessions is %s.\n" "$courseID" "$numOfSessions";; 

2) # average attendance per course 
printf "\nPlease enter the coursre ID\n"
read courseID

#count total student entries for this course
#each line = one student’s attendance record

numOfStudents=`grep ".*,.*,.*,.*,.*,\<$courseID\>,.*,.*,.*,.*,.*" "$logFileName" | wc -l` #this count how many students  have watched all the course sessions
numOfSessions=`grep ".*,.*,.*,.*,.*,\<$courseID\>,.*,.*,.*,.*,.*" "$logFileName" | cut -d, -f9 | sort | uniq | wc -l` #count the number of unique sessions for this course
if [ "$numOfSessions" -ne 0 ] # If there are sessions, calculate the average attendance else dont calculate to avoid 0 division
then
averageNumOfStudentsPerSession=`echo "scale=6; $numOfStudents/$numOfSessions" | bc` 
#note that bc : basic calculator we use it to divide num of students over num of sessions because its float not int
 #scale=6 → keep 6 digits after the decimal point
printf "\nThe average number of students who attended %s's sessions is %f.\n" "$courseID" "$averageNumOfStudentsPerSession"
else printf "\nThere is no sessions for this course.\n"
fi;;

3) #list of absent students per course (didn't attend any session of this course)
flag=""
printf "\nPlease Enter the course ID.\n"
read courseID
registrationFileName="./Registration files/${courseID}.txt"
#registration  file : each course  have one , and its contains all the students names in the course and it should  be in a directory called registration file
if [ -r "$registrationFileName" ] # check  if the registration file readable  or not 
then
logFileInfo=`grep ".*,.*,.*,.*,.*,\<$courseID\>,.*,.*,.*,.*,.*" "$logFileName"` # all students names who take this course in any session 
numOfStudents=`wc -l < "$registrationFileName"` #num of students  = lines in the registration file 
i=1
countAbsent=1 #for printing
printf "\nList of absent students in course %s:\n" "$courseID"
while [ "$i" -le  "$numOfStudents" ]
do #loop over each student in the registration  file 
studentID=`sed -n "${i}p" "$registrationFileName" | cut -d, -f1` # take the first student id in the first line of reg file
# sed -n to take the first line 
#cut in ID so then we can search about the student with this id
studentExists=`echo "$logFileInfo" | grep ".*,\<$studentID\>,.*,.*,.*,.*,.*,.*,.*,.*,.*"`
if [ -z "$studentExists" ] # if null thats mean that the student didn't  attend to any session 
then
studentFirstName=`sed -n "${i}p" "$registrationFileName" | cut -d, -f2` #take the student  first name
studentSecondName=`sed -n "${i}p" "$registrationFileName" | cut -d, -f3` #take the student  second  name
printf "\n%s- Student info:\nStudent ID: %s.\nStudent name: %s %s.\n" "$countAbsent" "$studentID" "$studentFirstName" "$studentSecondName"
countAbsent=$((countAbsent+1)) #add this student to the absent count   
flag=1 #flag that there is an absent student 
fi
i=$((i+1))
done
if [ -z "$flag" ] #No absent 
then
printf "\nThere is no absent students.\n"
fi
else printf "\nThe registration file for such a course doesn't exist or it is unreadable.\n"
fi
;;
4) #list of late arrivals per session
flag=""
printf "\nPlease enter the course ID.\n"
read courseID
printf "\nPlease enter the session ID.\n"
read sessionID
printf "\nPlease enter the number of minutes from the session start such that any person entering after it will be considered late.\n"
while true #check that the input is a positive  number 
do
read X
if [[ "$X" =~ ^[0-9][0-9]*$ ]] #[[ ]] this supports regex matching integer and positive
then
break
else 
printf "\nPlease enter a correct number.\n"
fi
done
wantedStudentsInfo=`grep ".*,.*,.*,.*,.*,\<$courseID\>,.*,.*,.*,.*,.*" "$logFileName" | grep ".*,.*,.*,.*,.*,.*,.*,.*,\<$sessionID\>,.*,.*"` #extract session records for this course and session

sessionStartTime=`echo "$wantedStudentsInfo" |  cut -d, -f7 | cut -d' ' -f2` #Get scheduled session start times (field 7 → StartTime column → time part only) 

studentBeginTime=`echo "$wantedStudentsInfo" |  cut -d, -f10` #Get each student's actual join time (field 10)
i=1
countLateStudents=1
numOfLines=`echo "$wantedStudentsInfo" | wc -l` 
#Number of students in this session
XInSeconds=$((X*60)) #Convert threshold minutes → seconds
printf "\nStudents that has arrived late Info's:\n"
while [ "$i" -le "$numOfLines" ]
do #Extract i-th session start time and student join time
sessionStartTimeOfI=`echo "$sessionStartTime" | sed -n "${i}p"`
studentBeginTimeOfI=`echo "$studentBeginTime" | sed -n "${i}p"`
#Convert both times into seconds
sessionStartTimeOfIInSeconds=`date -d "$sessionStartTimeOfI" +%s`
studentBeginTimeOfIInSeconds=`date -d "$studentBeginTimeOfI" +%s`
lateTimeInSeconds=$(( studentBeginTimeOfIInSeconds - sessionStartTimeOfIInSeconds )) #delay = join time − start time
if [ "$lateTimeInSeconds" -ge "$XInSeconds" ] # If delay >= threshold → student is late
then
flag=1
 # Extract student details from the i-th record
studentID=`echo "$wantedStudentsInfo" | sed -n "${i}p" | cut -d, -f2`
studentFirstName=`echo "$wantedStudentsInfo" | sed -n "${i}p" | cut -d, -f3`
studentSecondName=`echo "$wantedStudentsInfo" |  sed -n "${i}p" | cut -d, -f4`
lateTimeInMinutes=$((lateTimeInSeconds/60)) #Convert delay back to minutes (no need to use bc and float calculation because lateTimeInSeconds is a 60 multiplied by integer
printf "\n%s- Student info:\nStudent ID: %s.\nStudent name: %s %s\nArrived late by %s minutes.\n" "$countLateStudents" "$studentID" "$studentFirstName" "$studentSecondName" "$lateTimeInMinutes"
countLateStudents=$((countLateStudents+1))
fi
i=$((i+1)) #move to next student
done
if [ -z "$flag" ]
then
printf "\nThere is no late students.\n"
fi
;;
5) #List of students leaving early
flag=""
printf "\nPlease enter the course ID.\n"
read courseID
printf "\nPlease enter the session ID.\n"
read sessionID
printf "\nPlease enter the number of minutes from the end of the session such that any person leaving before it will be considered leaving early.\n"
while true #ensure Y is a positive number
do
read Y
if [[ "$Y" =~ ^[0-9][0-9]*$ ]]
then
break
else 
printf "\nPlease enter a correct number.\n"
fi
done
wantedStudentsInfo=`grep ".*,.*,.*,.*,.*,\<$courseID\>,.*,.*,.*,.*,.*" "$logFileName" | grep ".*,.*,.*,.*,.*,.*,.*,.*,\<$sessionID\>,.*,.*"` # Extract all records for this course and session
sessionStartTime=`echo "$wantedStudentsInfo" |  cut -d, -f7 | cut -d' ' -f2` #Extract session start time (field 7 → time part only)
sessionLength=`echo "$wantedStudentsInfo" |  cut -d, -f8` #Extract scheduled session length in minutes (field 8)
studentLeaveTime=`echo "$wantedStudentsInfo" |  cut -d, -f11` #Extract each student’s leave time (field 11)
i=1
countEarlyLeavingStudents=1
numOfLines=`echo "$wantedStudentsInfo" | wc -l` #Number of students in this session
YInSeconds=$((Y*60)) #Convert minutes → seconds
printf "\nStudents that has left early Info's:\n"
while [ "$i" -le "$numOfLines" ]
do #Get i-th values
sessionStartTimeOfI=`echo "$sessionStartTime" | sed -n "${i}p"`
sessionLengthOfI=`echo "$sessionLength" | sed -n "${i}p"`
studentLeaveTimeOfI=`echo "$studentLeaveTime" | sed -n "${i}p"`
sessionStartTimeOfIInSeconds=`date -d "$sessionStartTimeOfI" +%s` # Convert start and leave times to epoch seconds
studentLeaveTimeOfIInSeconds=`date -d "$studentLeaveTimeOfI" +%s`
#Calculate scheduled end time = start + length
#Then subtract actual leave time → how early the student left
earlyTimeInSeconds=$(( sessionStartTimeOfIInSeconds + sessionLengthOfI*60 - studentLeaveTimeOfIInSeconds ))
if [ "$earlyTimeInSeconds" -ge "$YInSeconds" ] # If early departure ≥ threshold → student left early
then
flag=1
studentID=`echo "$wantedStudentsInfo" | sed -n "${i}p" | cut -d, -f2`
studentFirstName=`echo "$wantedStudentsInfo" | sed -n "${i}p" | cut -d, -f3`
studentSecondName=`echo "$wantedStudentsInfo" |  sed -n "${i}p" | cut -d, -f4`
earlyTimeInMinutes=$((earlyTimeInSeconds/60))
printf "\n%s- Student info:\nStudent ID: %s.\nStudent name: %s %s.\nLeft early by %s minutes.\n" "$countEarlyLeavingStudents" "$studentID" "$studentFirstName" "$studentSecondName" "$earlyTimeInMinutes"
countEarlyLeavingStudents=$((countEarlyLeavingStudents+1))
fi
i=$((i+1)) # Move to next student
done
if [ -z "$flag" ] #if no student left early
then
printf "\nThere is no students that left early.\n"
fi
;;
6)
printf "\nPlease Enter the course ID.\n"
read courseID
maxNumOfSessions=`grep ".*,.*,.*,.*,.*,\<$courseID\>,.*,.*,.*,.*,.*" "$logFileName" | cut -d, -f9 | sort | uniq | wc -l`
 #count how many unique sessions exist for this course (maxNumOfSessions)
        #cut -d, -f9 → extract session IDs
        #sort | uniq → remove duplicates
        # wc -l → count them

if [ "$maxNumOfSessions" -ne 0 ] # If there are no sessions for this course → exit
then
wantedStudentsInfo=`grep ".*,.*,.*,.*,.*,\<$courseID\>,.*,.*,.*,.*,.*" "$logFileName" | cut -d, -f2,3,4,7,8,10,11 | sort`  #Extract fields needed: StudentID, FirstName, LastName, StartTime, Length, BeginTime, LeaveTime
numOfLines=`echo "$wantedStudentsInfo" | wc -l` # total rows
i=1
studentID="" #track current student
sum=0 #accumulate time attended
countStudents=0
while [ "$i" -le "$numOfLines" ] #attendance record
do # Extract data for this student in line i
newStudentID=`echo "$wantedStudentsInfo" | sed -n "${i}p" | cut -d, -f1`
studentSessionStartTime=`echo "$wantedStudentsInfo" | sed -n "${i}p" | cut -d, -f4 | cut -d' ' -f2`
studentSessionDuration=`echo "$wantedStudentsInfo" | sed -n "${i}p" | cut -d, -f5`
studentBeginTime=`echo "$wantedStudentsInfo" | sed -n "${i}p" | cut -d, -f6`
studentLeaveTime=`echo "$wantedStudentsInfo" | sed -n "${i}p" | cut -d, -f7`
# convert times to seconds
studentSessionStartTimeInSeconds=`date -d "$studentSessionStartTime" +%s`
studentBeginTimeInSeconds=`date -d "$studentBeginTime" +%s`
studentLeaveTimeInSeconds=`date -d "$studentLeaveTime" +%s`
studentSessionFinishTimeInSeconds=$((studentSessionStartTimeInSeconds+studentSessionDuration*60)) #Calculate scheduled finish time = start time + session length

 #Adjust begin/leave times if they are outside scheduled range
if [ "$studentBeginTimeInSeconds" -lt "$studentSessionStartTimeInSeconds" ]
then
studentBeginTimeInSeconds="$studentSessionStartTimeInSeconds"
elif [ "$studentBeginTimeInSeconds" -gt "$studentSessionFinishTimeInSeconds" ]
then
studentBeginTimeInSeconds="$studentSessionFinishTimeInSeconds"
fi
if [ "$studentLeaveTimeInSeconds" -lt "$studentSessionStartTimeInSeconds" ]
then
studentLeaveTimeInSeconds="$studentSessionStartTimeInSeconds"
elif [ "$studentLeaveTimeInSeconds" -gt "$studentSessionFinishTimeInSeconds" ]
then
studentLeaveTimeInSeconds="$studentSessionFinishTimeInSeconds"
fi
if [ "$studentID" !=  "$newStudentID" ] #If this is a new student (different ID from previous) count again
then
if [ "$i" -ne 1 ]   #For previous student: print average before switching
then
averageTimePerSession=`echo "scale=6; $sum/($maxNumOfSessions*60)" | bc` #average attendance time = total attended ÷ (max sessions * 60 minutes)
printf "\n%s- Student info:\nStudent ID: %s.\nStudent name: %s %s.\nStudent average time per session: %s .\n" "$countStudents" "$studentID" "$studentFirstName" "$studentSecondName" "$averageTimePerSession"
fi
studentID="$newStudentID"  #Start new student
studentFirstName=`echo "$wantedStudentsInfo" | sed -n "${i}p" | cut -d, -f2`
studentSecondName=`echo "$wantedStudentsInfo" | sed -n "${i}p" | cut -d, -f3`
sum=$((studentLeaveTimeInSeconds-studentBeginTimeInSeconds))
countStudents=$((countStudents+1))
else   #same student → accumulate total attended time
sum=$((sum+studentLeaveTimeInSeconds-studentBeginTimeInSeconds))
fi
i=$((i+1))
done # do it for the last student also
averageTimePerSession=`echo "scale=6; $sum/($maxNumOfSessions*60)" | bc`
printf "\n%s- Student info:\nStudent ID: %s.\nStudent name: %s %s.\nStudent average time per session: %s .\n" "$countStudents" "$studentID" "$studentFirstName" "$studentSecondName" "$averageTimePerSession"
else printf "\nThere is no Sessions for this course.\n"
fi
;;
7) #average number of attendances per instructor
InstructorsInfo=`cut -d, -f5 "$logFileName" | sort | uniq -c | sed 's/^ *//' | tr -s ' '`    
# extract InstructorID column (field 5)
 #sort | uniq -c → count how many rows per instructor
 #sed/tr → clean formatting (remove spaces, compress multiple spaces) because of uniq -c
numOfInstructors=`echo "$InstructorsInfo" | wc -l` #count instructors
firstLine=1
i=1
if [ "$numOfInstructors" -ne 0 ]
then
while [ "$i" -le "$numOfInstructors" ]
do
numOfStudentsPerInstructor=`echo "$InstructorsInfo" |  sed -n "${i}p" | cut -d' ' -f1` # Get number of student records for this instructor
lastLine=$((firstLine+numOfStudentsPerInstructor-1)) # calculate range of lines that belong to this instructor
numOfSessions=`cut -d, -f5,9 "$logFileName" | sort | sed -n "${firstLine},${lastLine}p" | cut -d, -f2 | sort | uniq | wc -l` #count number of unique sessions taught by this instructor
firstLine=$((firstLine+numOfStudentsPerInstructour)) #update firstLine for next instructor
averageNumOfStudentsPerInstructor=`echo "scale=6; $numOfStudentsPerInstructor/$numOfSessions" | bc` #calculate average = total attendances ÷ number of sessions
InstructorID=`echo "$InstructorsInfo" | sed -n "${i}p" | cut -d' ' -f2` #extract instructor ID
printf "\n%s- Instructor info:\nInstructor ID: %s.\nInstructor average number of student per session is: %s .\n" "$i" "$InstructorID" "$averageNumOfStudentsPerInstructor"
i=$((i+1))
done
else printf "\nThere is no instructors.\n"
fi
;;
8) #Most frequently used tool Zoom or Teams
zoomCount=`grep "\<[zZ]oom\>,.*,.*,.*,.*,.*,.*,.*,.*,.*,.*" "$logFileName" | wc -l` #count how many times Zoom appears (case-insensitive for 'Zoom' or 'zoom')
teamsCount=`grep "\<[tT]eams\>,.*,.*,.*,.*,.*,.*,.*,.*,.*,.*" "$logFileName" | wc -l` #count how many times Teams appears (case-insensitive)
#compare count
if [ "$zoomCount" -gt "$teamsCount" ]
then
printf "\nZoom is more frequently used based on session records with %s usage times.\n" "$zoomCount"
elif [ "$zoomCount" -lt "$teamsCount" ]
then
printf "\nTeams is more frequently used based on session records with %s usage times.\n" "$teamsCount"
else  
printf "\nTeams and Zoom have the same usage frequency based on session records with %s usage times.\n" "$zoomCount"
fi;;
9) #exit the program
printf "\nThanks for using the log management system, see you again.\n";;
*) #defult: Invalid input
printf "\nplease enter a correct number.\n";;
esac
done


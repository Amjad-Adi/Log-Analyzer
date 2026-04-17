# **ENCS3130 – Shell Scripting Project**  

# **Online Course Log Analyzer**  



done by : Hanan ALawawda 1230827

&nbsp;         Amjad Adi 1230800 



## Code Usage Describe



this project is made up of two files. the first file is process\_log.sh and the second file is process\_log\_functions.sh. they both together create the system for processing log file of courses.



###### process\_log.sh

when you run it, it greets you and asks you to input the log file name , it will keep asking again and again until you give it a file name which exists and is readable ,then it invokes the second script process\_log\_functions.sh and sends the log file name to it , so this file is a starting point , it validates the file is ok and then move to the next file

---------------------------------------------------------



process\_log\_functions.sh

this file is main menu , it shows options 1 to 9. you can choose number. it will keep asking until you press 9 for exit , the menu options:



1 -display how many sessions for a single course.



2 -show average attendance in a single course.



3 -show students who are absent (do not attend) in the course.



4 -show students who attend late in a single session.



5 -show students who leave early in a single session.



6 -show average time each student stays in the session of a single course.



7 -show average attendance for each instructor.



8 -check which tool is used more, Zoom or Teams.



9 -end program.



in every option it use linux command to extract data from log file and do calculations ,for example

* option 1: filter lines with courseID, then cut the sessionID and count uniq.
* option 2: calculate number of student divided by number of sessions in bc calculator.
* option 3: match the course registration file and the log file in order to see who never show up.
* option 4 and 5: it compares join time or leave time with start time and duration, to find late or early.
* option 6: it calculates average time per student for all sessions.
* option 7: it groups by instructor and divides.
* option 8: just count occurrences of words "Zoom" or "Teams".

-------------------------------------------------------------------------------------------------------------



## execution commands:

1 -first open terminal in linux



2 -go to directory where the files are available \& make sure both the files are available there (process\_log.sh, process\_log\_functions.sh)



3 -write ./process_log.sh to execute program



4 -enter the path of the log file that you want to analysis 



4 -program will ask you type the log file name(write the file name and press Enter.)



5 -after that you see menu 1–9. type number for the option you want.



6 -when you finish, press 9 to exit

-------------------------------------------------------------------------------------------------------------



## System Features



* the system is simple log management for courses and students.  
* it is able to read log file and show lots of useful information.
* menu-driven, so the user can choose easily by number.
* check the number of sessions for one course.
* calculate the average attendance for each course.
* show the list of students who never attend (absent).
* show the list of students who attend late.
* show the list of students who leave early.
* calculate the average time each student stay in session.
* calculate the average attendance for each instructor.
* check which online tool is used more (Zoom or Teams).
* have the choice to end program safely.
* program is interactive, always ask user to input course id or session id whenever needed.
* program keep asking until the input is valid .




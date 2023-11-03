#!/bin/bash

u_item="$1"
u_data="$2"
u_user="$3"

printf -- "---------------------------------\n
User Name : SeongJoon Kim\n
Student Number : 12181583\n
     [  MENU  ]\n
1. Get the data of the movie identified by a spescific 'movie id' from 'u.item'\n
2. Get the data of 'action' genre movies from 'u.item'\n
3. Get the average 'rating' of the movie identified by specific 'movie id' from 'u.data'\n
4. Delete the 'IMDb URL' from 'u.item'\n
5. Get data about users from 'u.user'\n
6. Modify the format of 'release date' in 'u.item'\n
7. Get the data of movies rated by a specific 'user id' from 'u.data'\n
8. Get the average 'rating' of movies rated by users with age between 20 and 29 and 'occupation' as 'programmer'\n
9. Exit\n
---------------------------------\n"

while true; do
	printf "Enter your choice [ 1 - 9 ] : "
	read -r choice
	case $choice in
		1)
			printf "Please enter 'movie id' (1~1682) : "
			read -r input
			awk -F'|' -v id="$input" '$1==id {print}' "$u_item"
			;;
		2)
			printf "Do you want to get the data of 'action' genre movies from 'u.item'? (y/n) : "
			read -r input
			if [ "$input" == "y" ]; then
				awk -F'|' '$7==1 {gsub(/\([0-9]+\)/, "", $2); printf "%s %s (%s)\n", $1, $2, substr($3, 8, 4)}' "$u_item" | head -10
			else printf ""
			fi
			;;
 		3)
			printf "Please enter the 'movie id' (1~1682) : "
			read -r input
			awk -F'\t' -v id="$input" '$2==id {sum+=$3; count++} END {if (count > 0) printf "%.5f\n", sprintf("%.6f", sum/count); else printf "Wrong input"}' "$u_data"
			;;
		4)
			printf "Do you want to delete the 'IMDb URL' from 'u.item' and show the first 10 entries? (y/n) : "
			read -r input
			if [ "$input" = "y" ]; then
				sed 's/^\(\([^|]*|\)\{4\}\)[^|]*|\(.*\)$/\1\3/' "$u_item" | head -n 10

			else printf ""
			fi
			;;

		5)
			printf "Do you want to get the data about users from 'u.user'? (y/n) : "
			read -r input
			if [ "$input" == "y" ]; then
				awk -F'|' 'BEGIN {count=0} {temp = ($3 == "F") ? "female" : "male"; printf "user %s is %s years old %s %s\n", $1, $2, temp, $4; count++; if (count >= 10) {exit}}' "$u_user"
			else printf ""
			fi
			;;
		6)
			printf "Do you want to Modify the format of 'release date' in 'u.item'? (y/n) : "
			read -r input
			if [ "$input" == "y" ]; then
				awk -F'|' 'BEGIN {OFS="|"} NR >= 1673 && NR < 1683 {split($3, a, "-"); month["Jan"] = "01"; month["Feb"] = "02"; month["Mar"] = "03"; month["Apr"] = "04"; month["May"] = "05"; month["Jun"] = "06"; month["Jul"] = "07"; month["Aug"] = "08"; month["Sep"] = "09"; month["Oct"] = "10"; month["Nov"] = "11"; month["Dec"] = "12"; $3 = a[3] month[a[2]] a[1]; print;}' "$u_item"
			else printf ""
			fi
			;;
		7)
			echo "Please enter the 'user id' (1~943) : "
			read -r input
			awk -F'\t' -v uid="$input" '$1==uid {print $2}' u.data | sort -n | uniq | tr '\n' '|'
			awk -F'\t' -v uid="$input" '$1==uid {print $2}' u.data | sort -n | uniq | head -10 | while read -r temp
			do
				awk -F'|' -v mid="$temp" '$1==mid {printf "\n%s|%s", $1, $2}' u.item
			done
			printf "\n"
			;;
		8)
			printf "Do you want to get the average 'rating' of movies rated by users with 'age' between 20 and 29 and 'occupation' as 'programmer'? (y/n) : "
			read -r input
			if [ "$input" == "y" ]; then
				awk -F'|' '$2 >= 20 && $2 <= 29 && $4 == "programmer" {print $1}' u.user>temp.txt
				awk -F'\t' 'NR==FNR {ids[$1]; next} $1 in ids {sum[$2] += $3; count[$2]++} END {for (i in sum) {round = sprintf("%.6f", sum[i]/count[i]); printf "%s %g\n", i, round}}' temp.txt u.data | sort -k1,1n
			else printf ""
			fi
			;;
		9)
			printf "Bye!\n"
			exit 0
			;;
		*)
			printf "Type error!"
			;;
	esac
done

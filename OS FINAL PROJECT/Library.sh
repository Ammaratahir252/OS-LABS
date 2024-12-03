#!/bin/bash

# Initialize files
USER_FILE="users.db"
BOOK_FILE="books.db"
STUDENT_FILE="students.db"

# Styling enhancements
LINE="========================================="
DOUBLE_LINE="*****************************************"
GREEN=$(tput setaf 2)
RED=$(tput setaf 1)
CYAN=$(tput setaf 6)
YELLOW=$(tput setaf 3)
BOLD=$(tput bold)
UNDERLINE=$(tput smul)
NORMAL=$(tput sgr0)

# Center-align function
print_centered() {
    text="$1"
    cols=$(tput cols)
    padding=$(( (cols - ${#text}) / 2 ))
    printf "%*s%s%*s\n" "$padding" "" "$text" "$padding" ""
}

# Login function with centered title
login() {
    clear
    echo -e "\n${CYAN}"
    print_centered "========================================="
    print_centered "Welcome to the Library Management System"
    print_centered "========================================="
    echo -e "${NORMAL}"

    read -p "${YELLOW}Enter Username: ${NORMAL}" username
    read -sp "${YELLOW}Enter Password: ${NORMAL}" password
    echo ""

    # Verify credentials
    if grep -q "^$username:$password:" "$USER_FILE"; then
        role=$(grep "^$username:$password:" "$USER_FILE" | cut -d ':' -f3)
        echo "${GREEN}Login successful!${NORMAL}"
    else
        echo "${RED}Invalid credentials. Exiting.${NORMAL}"
        exit 1
    fi
}

# Menu function with centered title
menu() {
    clear
    echo -e "\n${CYAN}"
    print_centered "========================================="
    print_centered "Library Management Menu"
    print_centered "========================================="
    echo -e "${NORMAL}"

    if [[ "$role" == "admin" ]]; then
        echo -e "${YELLOW}1. View Books${NORMAL}"
        echo -e "${YELLOW}2. Add Book${NORMAL}"
        echo -e "${YELLOW}3. Delete Book${NORMAL}"
        echo -e "${YELLOW}4. Issue Book${NORMAL}"
        echo -e "${YELLOW}5. Return Book${NORMAL}"
        echo -e "${YELLOW}6. Manage Students${NORMAL}"
        echo -e "${YELLOW}7. Exit${NORMAL}"
        read -p "${CYAN}Choose an option [1-7]: ${NORMAL}" choice
    else
        echo -e "${YELLOW}1. View Books${NORMAL}"
        echo -e "${YELLOW}4. Issue Book${NORMAL}"
        echo -e "${YELLOW}5. Return Book${NORMAL}"
        echo -e "${YELLOW}7. Exit${NORMAL}"
        read -p "${CYAN}Choose an option [1,4,5,7]: ${NORMAL}" choice
    fi
}

# Validate choice input
validate_choice() {
    if [[ ! "$choice" =~ ^[1-7]$ || ( "$role" != "admin" && "$choice" -gt 5 ) ]]; then
        echo "${RED}Invalid input. Please try again.${NORMAL}"
        read -p "${CYAN}Press [Enter] to continue...${NORMAL}"
        clear
        menu
    fi
}

# View books
view_books() {
    echo -e "\n${CYAN}"
    print_centered "*****************************************"
    print_centered "Library Books"
    print_centered "*****************************************"
    echo -e "${NORMAL}"
    echo "${BOLD}${UNDERLINE}ID | Title | Author | Status${NORMAL}"
    [[ -s "$BOOK_FILE" ]] && cat "$BOOK_FILE" || echo "${RED}No books available.${NORMAL}"
}

# Add book (admin)
add_book() {
    echo -e "\n${CYAN}"
    print_centered "*****************************************"
    print_centered "Add a New Book"
    print_centered "*****************************************"
    echo -e "${NORMAL}"

    while true; do
        read -p "${YELLOW}Enter Book ID (numbers only): ${NORMAL}" id
        if ! [[ "$id" =~ ^[0-9]+$ ]]; then
            echo "${RED}ID must be a number.${NORMAL}"
        elif grep -q "^$id " "$BOOK_FILE"; then
            echo "${RED}ID already exists.${NORMAL}"
        else
            break
        fi
    done

    read -p "${YELLOW}Enter Title: ${NORMAL}" title
    read -p "${YELLOW}Enter Author: ${NORMAL}" author
    echo "$id | $title | $author | Available" >> "$BOOK_FILE"
    echo "${GREEN}Book added successfully!${NORMAL}"
}

# Delete book (admin)
delete_book() {
    echo -e "\n${CYAN}"
    print_centered "*****************************************"
    print_centered "Delete a Book"
    print_centered "*****************************************"
    echo -e "${NORMAL}"

    read -p "${YELLOW}Enter Book ID to delete: ${NORMAL}" id
    if grep -q "^$id " "$BOOK_FILE"; then
        sed -i "/^$id /d" "$BOOK_FILE"
        echo "${GREEN}Book deleted successfully!${NORMAL}"
    else
        echo "${RED}Book not found.${NORMAL}"
    fi
}

# Issue book
issue_book() {
    echo -e "\n${CYAN}"
    print_centered "*****************************************"
    print_centered "Issue a Book"
    print_centered "*****************************************"
    echo -e "${NORMAL}"

    read -p "${YELLOW}Enter Book ID to issue: ${NORMAL}" id
    if grep -q "^$id .*Available" "$BOOK_FILE"; then
        sed -i "/^$id /s/Available/Issued/" "$BOOK_FILE"
        echo "${GREEN}Book issued successfully!${NORMAL}"
    else
        echo "${RED}Book not available.${NORMAL}"
    fi
}

# Return book
return_book() {
    echo -e "\n${CYAN}"
    print_centered "*****************************************"
    print_centered "Return a Book"
    print_centered "*****************************************"
    echo -e "${NORMAL}"

    read -p "${YELLOW}Enter Book ID to return: ${NORMAL}" id
    if grep -q "^$id .*Issued" "$BOOK_FILE"; then
        sed -i "/^$id /s/Issued/Available/" "$BOOK_FILE"
        echo "${GREEN}Book returned successfully!${NORMAL}"
    else
        echo "${RED}Book not found or not issued.${NORMAL}"
    fi
}

# Manage students (admin)
manage_students() {
    echo -e "\n${CYAN}"
    print_centered "========================================="
    print_centered "Manage Students"
    print_centered "========================================="
    echo -e "${NORMAL}"

    echo -e "${YELLOW}1. View Students${NORMAL}"
    echo -e "${YELLOW}2. Add Student${NORMAL}"
    echo -e "${YELLOW}3. Remove Student${NORMAL}"
    read -p "${CYAN}Choose an option [1-3]: ${NORMAL}" option

    case $option in
        1) 
            echo -e "\n${BOLD}${UNDERLINE}ID | Name${NORMAL}"
            [[ -s "$STUDENT_FILE" ]] && cat "$STUDENT_FILE" || echo "${RED}No students found.${NORMAL}"
            ;;
        2) 
            while true; do
                read -p "${YELLOW}Enter Student ID: ${NORMAL}" student_id
                if ! [[ "$student_id" =~ ^[0-9]+$ ]]; then
                    echo "${RED}Student ID must be a number.${NORMAL}"
                elif grep -q "^$student_id " "$STUDENT_FILE"; then
                    echo "${RED}Student ID already exists.${NORMAL}"
                else
                    break
                fi
            done
            read -p "${YELLOW}Enter Student Name: ${NORMAL}" student_name
            echo "$student_id | $student_name" >> "$STUDENT_FILE"
            echo "${GREEN}Student added successfully!${NORMAL}"
            ;;
        3)
            read -p "${YELLOW}Enter Student ID to remove: ${NORMAL}" student_id
            if grep -q "^$student_id " "$STUDENT_FILE"; then
                sed -i "/^$student_id /d" "$STUDENT_FILE"
                echo "${GREEN}Student removed successfully!${NORMAL}"
            else
                echo "${RED}Student not found.${NORMAL}"
            fi
            ;;
        *) echo "${RED}Invalid choice.${NORMAL}" ;;
    esac
}


# Main program loop
while true; do
    login
    while true; do
        menu
        validate_choice

        case $choice in
            1) view_books ;;
            2) [[ "$role" == "admin" ]] && add_book ;;
            3) [[ "$role" == "admin" ]] && delete_book ;;
            4) issue_book ;;
            5) return_book ;;
            6) [[ "$role" == "admin" ]] && manage_students ;;
            7) 
                echo -e "\n${CYAN}Logging out... Returning to login screen.${NORMAL}"
                break  # Exit menu loop and return to login
                ;;
            *) echo "${RED}Invalid choice!${NORMAL}" ;;
        esac
        echo ""
        read -p "${CYAN}Press [Enter] to continue...${NORMAL}"
        clear
    done
done


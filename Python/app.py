#### TO-DO ####
# Make sure all queries to DB are good or else exit app
# pods need to restart if db connect is lost in order to reconnect to psql DB)

# The amount of money is added again when refreshing page


# Postgres DB: thebank User: banker PW: banker12345

# CREATE USER banker WITH PASSWORD 'banker12345';
# CREATE DATABASE thebank OWNER banker;
##

from flask import Flask, render_template, request, redirect, url_for
import psycopg2

######## FUNCTIONS AND CLASSES ########
app = Flask(__name__)

@app.route("/", methods=["POST", "GET"])
def home():
    global selected_operation

    # Query bank account current ammount
    select_script = 'SELECT account_amount from bank_account'

    cur.execute(select_script)
    account_amount = cur.fetchall()[0][0]

    if request.method == "POST":
        print(request.form)
        if "deposit_button" in request.form:
            print("deposit selected")
            selected_operation = 'deposit'
            return render_template('index.html', operation="deposit", account_amount=account_amount)

        elif "withdraw_button" in request.form:
            print("withdrawal selected")
            selected_operation = 'withdraw'
            return render_template('index.html', operation="withdrawal", account_amount=account_amount)

        elif "operation_amount" in request.form:
            operation_amount = request.form["operation_amount"]

            if operation_amount.isnumeric():
                print('Update to pgsql')
                # Deposit in bank_account pgsql table
                if selected_operation == 'deposit':
                    account_amount += int(operation_amount)
                elif selected_operation == 'withdraw':
                    account_amount -= int(operation_amount)

                update_script = f"UPDATE bank_Account SET account_amount = {account_amount}"
                cur.execute(update_script)
                conn.commit()

                return render_template('index.html', account_amount=account_amount)
                # return render_template('operation_confirmed.html', amount=amount)
            else:
                return render_template('index.html', errorflag="Please enter a valid value for this operation")
        
    else:
        return render_template('index.html', account_amount=account_amount)

@app.route("/deposit", methods=["POST", "GET"])
def deposit():
    global account_amount
    if request.method == "POST":
        amount = request.form["deposit_amount"]
        if amount.isnumeric():
            account_amount = account_amount + int(amount)
            return render_template('deposit.html', amount=amount)
            # return render_template('operation_confirmed.html', amount=amount)
        else:
            return render_template('deposit.html', errorflag="Please enter a valid value for this operation")
        
    else:
        return render_template('deposit.html')

######## VARIABLES ########

# Postgresql variables
# hostname = 'localhost'
# hostname = 'pgsqlcontainer'
hostname = 'postgresql'
database = 'thebank'
username = 'banker'
pwd = 'banker12345'
port_id = 5432
conn = None
cur = None
selected_operation = 'not selected yet'

######## SCRIPT START ########

# Connect to postgresql DB and create bank account if there are none.
try:
    print('connecting to pg db')
    conn = psycopg2.connect(
                host = hostname,
                dbname = database,
                user = username,
                password = pwd,
                port = port_id)

    cur = conn.cursor()

except Exception as error:
    print(error)
    quit()

try:
    print('Create the bank_account table if it does not exists')
    # Create the bank_account table if it does not exists
    create_script = 'CREATE TABLE IF NOT EXISTS bank_account (id int PRIMARY KEY, account_amount int)'

    cur.execute(create_script)

    print("Select current amount from bank account")
    select_script = 'SELECT account_amount from bank_account'
    cur.execute(select_script)

    table_content = None

    try:
        table_content = cur.fetchall()[0][0]
    except:
        pass


    print(f'The account amount is: {table_content}')
    if table_content != None:
        print('There is already a bank account, doing nothing')
    else:
        print('No table content, inserting the first bank account with 0$ in it')

        insert_script = 'INSERT INTO bank_account (id, account_amount) VALUES (%s, %s)'
        insert_values = (1, 0)
        cur.execute(insert_script, insert_values)

    conn.commit()

except Exception as error:
    print(error)
    quit()

# finally:
#     if cur is not None:
#         cur.close()
#     if conn is not None:
#         conn.close()


if __name__ == "__main__":
    app.run(debug=True)

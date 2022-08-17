import psycopg2

# Postgresql variables
hostname = 'localhost'
database = 'thebank'
username = 'banker'
pwd = 'banker12345'
port_id = 5432
conn = None
cur = None

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

    # Create the bank_account table if it does not exists
    create_script = ''' CREATE TABLE IF NOT EXISTS bank_account (
                            id             int PRIMARY KEY,
                            account_amount int) '''

    cur.execute(create_script)

    select_script = 'SELECT account_amount from bank_account'

    cur.execute(select_script)
    table_content = cur.fetchall()[0][0]
    

    print(f'The table content is: {table_content}')
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



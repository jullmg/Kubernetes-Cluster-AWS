from flask import Flask, render_template, request, redirect, url_for

app = Flask(__name__)

@app.route("/", methods=["POST", "GET"])
def home():
    account_amount = 0

    if request.method == "POST":
        if request.form["deposit_button"]:
            print("deposit selected")
        # operation_to_do = request.form["deposit_button"]
        # return redirect("/deposit")
        return render_template('index.html', operation=True, account_amount=account_amount)
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

account_amount = 0

if __name__ == "__main__":
    app.run(debug=True)

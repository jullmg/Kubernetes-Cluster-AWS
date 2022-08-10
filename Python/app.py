from flask import Flask, render_template, request, url_for

app = Flask(__name__)

@app.route("/")
def home():
    return render_template('index.html')

@app.route("/deposit", methods=["POST", "GET"])
def deposit():
    return render_template('deposit.html')

# amount = request.form["amount"] 

if __name__ == "__main__":
    app.run(debug=True)

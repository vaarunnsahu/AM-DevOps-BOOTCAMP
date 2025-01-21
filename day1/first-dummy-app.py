from flask import Flask


app = Flask(__name__)

@app.route('/')
def hello_docker():
    return '<h1> This is Varun Sahu Congratulations on Project Completion</h1><br><p>You've successfully completed your project. Great job!</p> '

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0')

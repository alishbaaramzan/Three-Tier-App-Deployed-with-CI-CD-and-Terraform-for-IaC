from flask import Flask, request, jsonify
from flask_cors import CORS
from flask_sqlalchemy import SQLAlchemy
import os
from dotenv import load_dotenv

load_dotenv()

app = Flask(__name__)
CORS(app)

app.config['SQLALCHEMY_DATABASE_URI'] = f"mysql+pymysql://{os.getenv('DB_USERNAME')}:{os.getenv('DB_PASSWORD')}@{os.getenv('DB_HOST')}/{os.getenv('DB__NAME')}"
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
db = SQLAlchemy(app)

class Task(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    title = db.Column(db.String(50), nullable=False)

# Check if the tasks table exists; if not, create it
with app.app_context():
    db.create_all()

@app.route('/')
def home():
    return "hello", 200

@app.route('/tasks', methods=['GET', 'POST'])
def handle_tasks():
    if request.method == 'GET':
        tasks = Task.query.all()
        task_list = [{'id': task.id, 'title': task.title} for task in tasks]
        return jsonify(task_list)
    elif request.method == 'POST':
        data = request.get_json()
        new_task = Task(title=data['title'])
        db.session.add(new_task)
        db.session.commit()
        return jsonify({'message': 'Task added successfully'})

@app.route('/tasks/<int:task_id>', methods=['DELETE'])
def remove_task(task_id):
    task = Task.query.get(task_id)
    if task:
        db.session.delete(task)
        db.session.commit()
        return jsonify({'message': 'Task removed successfully'})
    else:
        return jsonify({'message': 'Task not found'}), 404

if __name__ == '__main__':
    app.run(debug=True, host="0.0.0.0")


import main

def handle_tasks_test():
    assert main.handle_tasks() == jsonify({'message': 'Task added successfully'})
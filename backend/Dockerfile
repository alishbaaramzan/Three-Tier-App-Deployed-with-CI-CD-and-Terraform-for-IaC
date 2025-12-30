FROM python:3.10-slim

WORKDIR /app

RUN pip install flask flask_sqlalchemy pymysql python-dotenv flask-cors

COPY . .

ENV DB_USERNAME=""
ENV DB_PASSWORD=""
ENV DB_HOST=""
ENV DB__NAME=""

CMD ["python", "main.py"]
FROM python:3

ENV FLASK_APP=/home/app/app.py

RUN pip install Flask psycopg2

RUN mkdir -p /home/app

COPY ./app.py /home/app/

COPY ./start.sh /home/app/

EXPOSE 5000

RUN chmod +x /home/app/start.sh

CMD ["/home/app/start.sh"]
FROM python

LABEL "Owner" = "Guy"
EXPOSE 8080

ENV FLASK_APP = app.py

WORKDIR /app

RUN pip install -r requirements.txt

COPY . /app

ENTRYPOINT [ "python" ]

CMD [ "app.py" ]
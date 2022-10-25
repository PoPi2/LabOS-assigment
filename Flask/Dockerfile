FROM python

LABEL "Owner" = "Guy"
EXPOSE 8080

ENV FLASK_APP = app.py

WORKDIR /app

COPY . /app

RUN pip install -r requirements.txt

ENTRYPOINT [ "python" ]

CMD [ "app.py" ]
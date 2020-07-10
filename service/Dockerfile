FROM python:3.8.3 AS base

WORKDIR /srv
COPY ./Pipfile ./Pipfile
COPY ./Pipfile.lock ./Pipfile.lock
ENV PYTHONPATH=/srv/
ENV PYTHONUNBUFFERED=1
RUN pip install 'pipenv==2018.11.26'

FROM base as test
RUN pipenv install --deploy --system --dev
COPY ./falabella ./falabella
COPY ./pytest.ini ./pytest.ini
ENV FLASK_APP=falabella.src.app.py
RUN pytest

FROM base as prod
RUN pipenv install --deploy --system
COPY --from=test /srv/ ./srv
ENTRYPOINT ["flask", "run", "--host=0.0.0.0", "--port=80"]
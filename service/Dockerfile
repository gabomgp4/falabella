FROM python:3.8.3 AS base

WORKDIR /srv
COPY ./Pipfile ./Pipfile
COPY ./Pipfile.lock ./Pipfile.lock
ENV PYTHONPATH=/srv/
ENV PYTHONUNBUFFERED=1

FROM base as test
RUN  pip install pipenv && pipenv install --deploy --system --dev
COPY ./fallabella ./falabella
COPY ./pytest.ini ./pytest.ini
ENV FLASK_APP=falabella.src.app.py
RUN pytest

FROM base as prod
RUN pip install pipenv && pipenv install --deploy --system
COPY --from=test /srv/ ./srv
ENTRYPOINT ["flask", "run", "--host=0.0.0.0"]
# From here:
# https://stackoverflow.com/questions/53835198/integrating-python-poetry-with-docker
# NOTE: we might want to make things a bit nicer here

# Right now this must be built in the root directory of the Docker-compose project

FROM python:3.9

RUN apt-get update && \
  pip install "poetry==1.1.11" && \
  rm -rf /var/lib/apt/lists/* && \
  poetry config virtualenvs.create false

ENV PIP_DEFAULT_TIMEOUT=100 \
  PIP_DISABLE_PIP_VERSION_CHECK=1

WORKDIR /app/

# Copy only requirements to cache them in docker layer
COPY ./deps /app/deps
COPY ./pyproject.toml /app/

RUN poetry install --no-interaction --no-ansi --no-root --no-dev

EXPOSE 8000

# Creating folders, and files for a project:
COPY ./ /app/

# Install the root package
RUN poetry install --no-interaction --no-ansi --no-dev
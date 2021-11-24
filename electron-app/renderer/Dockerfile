# From here:
# https://stackoverflow.com/questions/53835198/integrating-python-poetry-with-docker
# NOTE: we might want to make things a bit nicer here

# Right now this must be built in the root directory of the Docker-compose project

FROM python:3.9

WORKDIR /app/

COPY ./index.html ./main.css /app/

CMD python -m http.server 3000
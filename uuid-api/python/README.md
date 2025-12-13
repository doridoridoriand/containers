# UUID API Python
## Requirements
- Python >= 3.6 (Reccomend >= 3.7)
- pipenv

## Installation
- pipenv run

## Run
Standalone
```
$ python app.py
```

with Gunicron
```
$ gunicorn -k uvicorn.workers.UvicornWorker app:api
```

## Execute with Docker
### docker build
```
$ docker build -t uuid-api-python ./python
```

### docker container execution
```
$ docker run -p 3000:3000 uuid-api-python
```

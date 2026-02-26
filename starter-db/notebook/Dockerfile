FROM python:3.11-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1

RUN pip install --upgrade pip && \
    pip install \
        notebook==7.4.5 \
        jupyterlab==4.4.7 \
        pandas==3.0.1 \
        matplotlib==3.9.0 \
        seaborn==0.13.2

WORKDIR /home/jovyan/work

EXPOSE 8888

CMD sh -c "jupyter lab \
  --ip=0.0.0.0 \
  --port=8888 \
  --no-browser \
  --allow-root \
  --ServerApp.token=${JUPYTER_TOKEN:-sql-nosql} \
  --ServerApp.root_dir=/home/jovyan/work"
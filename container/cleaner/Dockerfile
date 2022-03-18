FROM python:3.9.11-alpine3.15

COPY requirements.txt /
RUN pip install -r /requirements.txt

COPY clean.py /
CMD ["python", "clean.py"]
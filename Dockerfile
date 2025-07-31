FROM python:3.10-slim
LABEL Builder="Xirano"
LABEL Maintainer="sajadtaj@gmail.com"
LABEL version="1.0.0"
WORKDIR /src

COPY hello.py .
CMD [ "python","hello.py" ]

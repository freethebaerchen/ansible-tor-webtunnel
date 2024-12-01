FROM willhallonline/ansible:2.16.4-alpine-3.18

COPY ./requirements.yaml /tmp/requirements.yaml
COPY ./requirements.txt /tmp/requirements.txt

RUN apk add --update --no-cache sshpass py3-pip

RUN pip install -r /tmp/requirements.txt
RUN ansible-galaxy install -r /tmp/requirements.yaml

WORKDIR /ansible
FROM willhallonline/ansible:2.16-alpine-3.16

COPY ./scripts/wrapper.sh /workdir/scripts/wrapper.sh

COPY ./requirements.yaml /tmp/requirements.yaml
COPY ./requirements.txt /tmp/requirements.txt

RUN apk add --update --no-cache sshpass py3-pip figlet

RUN pip install -r /tmp/requirements.txt
RUN ansible-galaxy install -r /tmp/requirements.yaml

WORKDIR /ansible

ENTRYPOINT [ "sh", "/workdir/scripts/wrapper.sh" ]
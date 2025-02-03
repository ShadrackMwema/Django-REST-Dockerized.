#base image /name of my image and tag(alphine ia lightweight version of linux ideal for running docker images)
FROM python:3.9-alpine3.13

LABEL maintainer="shad"

#steps that docker will follow to create my image

#tells our docker container that you dont wanna buffer the output,
#output of running python will be printed on the console
ENV PYTHONBUFFERED=1

#copy our reqmts file from local machine into docker image
COPY ./requirements.txt /tmp/requirements.txt

COPY ./requirements.dev.txt /tmp/requirements.dev.txt

#copy app directly
COPY ./app /app

#default working directory , where commands are gonna be running from when we run commands on docker image
#setting it to location of django management app
WORKDIR /app

#expose port from our container to our local machine when we run the container
#allows us access that port on the container that is running our image
#and hence connect to django development server
EXPOSE 8000

ARG DEV=false


#runs commands on our alphine image
RUN python -m venv /py && \
    #for python package upgrading
    /py/bin/pip install --upgrade pip && \
    #installing postgresql packages
    apk add --update --no-cache postgresql-client && \
    #installing build dependencies
    apk add --update --no-cache --virtual .tmp-build-deps build-base postgresql-dev musl-dev && \
    #install requirements to the aphine image
    /py/bin/pip install -r /tmp/requirements.txt && \
    #install dev requirements to temp
    /py/bin/pip install -r /tmp/requirements.dev.txt && \
    #remove temporarily created files...to make the image light weight
    #if dev is true, install dev requirements
    if [ $DEV = "true" ]; then \
        /py/bin/pip install -r /tmp/requirements.dev.txt ; \
    fi && \
    rm -rf /temp && \
    #remove build dependencies
    apk del .tmp-build-deps && \
    #add a non root user to the alphine image
    adduser \
        --disabled-password \
        --no-create-home \
        django-user

#env variable ...it involves the directories where all the executables can be run
#it eliminates the need to specifiy the full path of what we want to run
ENV PATH="/py/bin:$PATH"

#to run image as user; django user
USER django-user

FROM public.ecr.aws/lambda/python:3.10
RUN yum update -y && \
    yum install -y mesa-libGL && \
    yum clean all && \
    rm -rf /var/cache/yum
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
ENV PYTHONPATH=${LAMBDA_TASK_ROOT}
COPY . .
CMD [ "covision.covid_test_classifier.lambda_function.handler" ]

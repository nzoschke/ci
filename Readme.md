
```
# Set sandboxed AWS credentials

$ export AWS_DEFAULT_PROFILE=default
$ export AWS_ACCESS_KEY_ID=$(aws configure get aws_access_key_id)
$ export AWS_SECRET_ACCESS_KEY=$(aws configure get aws_secret_access_key)

# Build and run the test!

$ docker build -t ci .

$ docker run -it                                \
  -e AWS_ACCESS_KEY_ID -e AWS_SECRET_ACCESS_KEY \
  -v /var/run/docker.sock:/var/run/docker.sock  \
  ci sh -c /root/teardown.sh

$ docker run -it                                \
  -e AWS_ACCESS_KEY_ID -e AWS_SECRET_ACCESS_KEY \
  -v /var/run/docker.sock:/var/run/docker.sock  \
  ci sh -c /root/setup.sh
```

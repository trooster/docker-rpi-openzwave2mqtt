# docker-rpi-openzwave2mqtt

Allows you to use your ZWave devices using ozwdaemon, a service that allows you
to remotely manage a Z-Wave Network via ozw-admin or connect to a MQTT Broker.

Have a look: https://github.com/OpenZWave/qt-openzwave

### Develop and test builds

Just type:

```
# Create new container image
docker build . -t openzwave2mqtt

# Run the docker image
docker run --privileged  -ti --rm -e TZ=Europe/Amsterdam -v /dev/ttyUSB0:/dev/ttyUSB0 -v $(pwd)/config:/config -e MQTT_SERVER="10.100.200.102" -e MQTT_USER=ozw -e MQTT_PASS="pass" openzwave2mqtt
```

### Create final release and publish to Docker Hub

```
create-release.sh
```


### Run in production

Given the docker image with name `openzwave2mqtt`:

```
docker run --privileged  --name openzwave -e TZ=Europe/Amsterdam -v /dev/ttyUSB0:/dev/ttyUSB0 -v $(pwd)/config:/config -e MQTT_SERVER="127.0.0.1" -e MQTT_USER=ozw -e MQTT_PASS="pass" -d jriguera/openzwave2mqtt
```

Variables, they can be updated at any time re-defining env variables (all except `NETWORK_KEY`).

* `TZ` Timezone, defaults to Europe/Amsterdam.
* `NETWORK_KEY` By default is generated automatically and stored in `NETWORK_KEY.txt` file.
  Changing requires repairing of all devices!!. So is not possible to change it once it was generated via
  env var, you will need to delete the previous files.
* `DEVICE` Controller device, by default is `/dev/ttyUSB0`.
* `LOG_LEVEL` default to `info`.
* `MQTT_SERVER` MQTT server, defaults to `127.0.0.1`.
* `MQTT_USER` MQTT username auth.
* `MQTT_PASS` MQTT Password.
* `MQTT_PORT` MQTT Port, default is `1883`.

# Author

Jose Riguera `<jriguera@gmail.com>`

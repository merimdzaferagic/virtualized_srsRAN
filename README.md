# srsRAN in docker containers

> This repo based on the repo created [davwheat](https://github.com/davwheat/srsRAN-docker-emulated), and adjusted to work with ZeroMQ

This setup allows you to run:
- srsEPC in one container
- srsENB and srsUE in one container (they are sharing one container, which makes it easier to configure with the ZeroMQ networking library to transfer radio samples)

### Setup

Clone the repository, and run the following command to spin up the Docker containers:

    $ docker-compose up

If you are running the command above for the first time, it will take a couple of minutes to build the containers and compile all the libraries.
Once the build is finished, you will have two containers running. You can verify that by running the following command:

    $ docker ps

The next step is to spin up the `eNB` by running the following command in a separate terminal:

    $ ./run_enb

Once the connection between the `eNB` and the `EPC` is established, you will see the following text in the terminal:

    $ ==== eNodeB started ===
    $ Type <t> to view trace

By pressing `t` you can start the trace on the `eNB `. In a separate terminal you should run the `UE` by executing the following command:

    $ ./run_ue

This will spin up the UE and connect it to the `eNB` and `EPC`. This will take some time. In the meantime, you can enter the `srsRAN` container by executing the following cammand:

    $ ./enterRAN

Once the connection between the `UE` and the `EPC` is established, you will be able to see a new network interface (i.e. ) by running the following command:

    $ ifconfig

Now, you are already able to ping the `UE` from the `EPC`. To do that, you can open another terminal and enter the `EPC` container by running the following command:

    $ ./enterEPC

The `ifconfig` command showed us the ip address of the `UE`, which is by default `172.16.0.2` (if you have not changed it you can ping this address):

    $ ping 172.16.0.2

### Change config files

This example uses the default config files from the `srsRAN` repository. These files are copied
to the `/etc/srsran/` directory during the `make` job. You can place your own custom files in the
following directories before the `make` command is executed in the Dockerfile.

You can find the exact versions in [`srsepc`], [`srsenb`] and [`srsue`].

The config files should be added to the `/etc/srsran` directory.

[srsepc]: https://github.com/srsran/srsran/tree/master/srsepc
[srsenb]: https://github.com/srsran/srsran/tree/master/srsenb
[srsue]: https://github.com/srsran/srsran/tree/master/srsue

#### Adding more UEs

To add more UEs, you can replicate the command from `./run_ue` with differnet parameters and
by using the second IMSI from the default `user_db.csv` (inside `srsEPC`). To add more UEs,
add IMSIs to the CSV and tell the UEs to use them.

### Internet access for UEs

To enable internet access and to meke sure that the traffic goes throught the `EPC`, run the
`./setup-internet-access` script. If you made any changes to the IP addresses please adjust the
script accordingly.

On some machines, dns will not be enabled by default on your docker configuration. A workaround is to
connect to both containers and to edit the `/etc/resolv.conf` script. The easiest way is to replace the
default ip address in the first line with `8.8.8.8`, which is google's DNS server.

This finalizes the setup, and now you can connect to the container running the `UE` and ping google or install
and run any service you want. If tracing is enabled in your `eNB` terminal, you will see that the traffic goes
through the emulated network.

### Shutting down the configuration

To shut down the configuration you can `CTRL+C` in the terminal in which you ran `docker-compose up` and then run:

    $ docker-compose down

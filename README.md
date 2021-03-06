# srsRAN in docker containers

> This repo based on the repo created [davwheat](https://github.com/davwheat/srsRAN-docker-emulated), and adjusted to work with ZeroMQ

This setup allows you to run:
- srsEPC in one container
- srsENB and srsUE in one container (they are sharing one container, which makes it easier to configure with the ZeroMQ networking library to transfer radio samples)

The architecture is shown in the figure below:
![Architecture](https://github.com/merimdzaferagic/virtualized_srsRAN/blob/master/figures/overview.jpg?raw=true)



### Setup

Clone the repository, and run the following command to spin up the Docker containers:

    docker-compose up

If you are running the command above for the first time, it will take a couple of minutes to build the containers and compile all the libraries.
Once the build is finished, you will have two containers running. You can verify that by running the following command:

    docker ps

The next step is to spin up the `eNB` by running the following command in a separate terminal:

    ./run_enb

Once the connection between the `eNB` and the `EPC` is established, you will see the following text in the terminal:

    ==== eNodeB started ===
    Type <t> to view trace

By pressing `t` you can start the trace on the `eNB`. In a separate terminal you should run the `UE` by executing the following command:

    ./run_ue

This will spin up the UE and connect it to the `eNB` and `EPC`. This will take some time. In the meantime, you can enter the `srsRAN` container by executing the following cammand:

    ./enterRAN

Once the connection between the `UE` and the `EPC` is established, you will be able to see a new network interface (i.e. `tun_srsue`) by running the following command:

    ifconfig

In the terminal in which you executed the `./run_ue` command, you can type `t` to start a trace for the `UE` as well.
Now, you are already able to ping the `UE` from the `EPC`. To do that, you can open another terminal and enter the `EPC` container by running the following command:

    ./enterEPC

The `ifconfig` command showed us the ip address of the `UE`, which is by default `172.16.0.2` (if you have not changed it you can ping this address):

    ping 172.16.0.2

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

    docker-compose down

## Setting the containers up to work with multiple hosts

There are multiple scripts available to set this up:
1. `setup_epc_multiple_hosts`
2. `run_epc_multiple_hosts`
3. `run_enb_multiple_hosts`

The `setup_epc_multiple_hosts` script first builds the existing docker file and then initializes a swarm (swarm manager
running on the host that runs the `EPC`). After running the script, follow the instructions to add the other host (the one
that will be running the `eNB` and `UE`) to the swarm. This script will also create an `overlay` network for the containers
to communicate:

    ./setup_epc_multiple_hosts

Once the script finishes, we run the `run_epc_multiple_hosts` script. This script starts the `EPC`.

    ./run_epc_multiple_hosts

Now, we can ssh into the other host (the one that will run the `eNB` and `UE`). There we run first build the image:

    docker build -t virtualized-srsran .

One the execution of the command above finishes, we can spin up the `eNB` by running the `run_enb_multiple_hosts` script:

    ./run_enb_multiple_hosts

Now, we have the `eNB` connected to the `EPC` and we can run the `UE` the same way we did it when everything was running on one host.
Everything else is exactly the same as it was when the whole setup was running on one host.


## Running the X2 handover example
In order to allow the `UE` to perform a handover we need to make changes to the config files and we have to introduce a second cell. The config files have been taken from the official `srsRAN` website and a detailed explanation can be found there. In order to run the scenario, after spinning up the docker containers with `docker-compose up`, you need to open 5 separate terminal windows.

In the first one, navigate to the `handover_example_conf` directory, and execute:

    ./copy_config

In the remaining three terminal windows navigate to the home directory of the project (i.e. `virtualized_srsRAN`) and execute:

    ./enterRAN

This will enter allow you to enter the container that will run the `eNB` and the `UE`. In the first of the three terminal windows execute the following command:

    ./intra_enb.py

This will run the GNU-radio broker that will force handovers between the cells. In the next terminal window execute:

    srsenb

This will start the `eNB` and connect it to the already running `EPC`. In the next terminal window run:

    srsue

This will run the `UE` and connect it to the `eNB`. The next terminal window is reserved for pinging the `EPC` from the `UE`.

Once the `UE` connects to the `eNB` you can start the ping:

    ping 172.16.0.1

After a while, if you have tracing turned on for the `eNB` and the `UE`, you will notice that the `UE` is being handaded over between the two running cells. To turn on tracing, simply hit `t` and then `Enter` in the terminal running the `eNB` and the `UE`.

# irs-labs
Intelligent Robotic Systems Laboratory Activities

## Usage

You can run an instance of the [Argos Simulator](https://www.argos-sim.info/) with the provided docker compose:
```bash
docker compose -f run_argos.yaml up -d
```

Then you can visit [`http://localhost:6080`](http://localhost:6080) to open up vnc indside the container.

Lab activities are located in `/root/Desktop`.
You can run any argos file with:

```bash
argos3 -c <lab_activity>.argos
```

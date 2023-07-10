# at

`at` and `batch` read commands from standard input or a specified file which are to be executed at a later time, using `/bin/sh`

# Usage

* interactive provide instruction

    ```bash
    at now + 1 hour
    > here is interactive
    > <Ctrl-D> to save and exit
    ```

* direct provide instruction

    ```bash
    at now + 1 hour <<< "notify-send 'hello-notification'"
    ```

## Command

1. execute command at a later time

    ```bash
    at <time>
    ```

2. execute command at a later time from **now**

    * `count`: *number*
    * `time-unit`: minutes, hours, days, or weeks

    ```bash
    at now + <count> <time-unit>
    ```

    - example:
        1. run script from /bin/sh after 1 minute

            ```bash
            at now + 1minute <<< "echo \"run after a minute\" > /tmp/at_test.txt"
            ```


2. check pending job list

    ```bash
    at -l
    ```

    or

    ```bash
    atq
    ```

3. remove pending job list

    ```bash
    at -r <job_number>
    ```

    or

    ```bash
    atrm <job_number>
    ```

# troubleshoot

1. `Can't open /var/run/atd.pid to signal atd. No atd running?`

    ```bash
    sudo service atd start
    ```

# Khal

### Introduction

[Khal](https://github.com/pimutils/khal) is a standards based CLI and terminal calendar program, able to synchronize with [CalDAV](https://en.wikipedia.org/wiki/CalDAV) servers through [vdirsyncer](https://github.com/pimutils/vdirsyncer).

### Usage

#### New event

1. single CLI[^h1]:

    ```bash
    khal new
    ```

2. single CLI with interactive:

    ```bash
    khal new -i
    ```

3. interactive:

    ```bash
    khal interactive
    ```

    1. move to specific date and press <kbd> Enter </kbd>

    2. press <kbd> n </kbd> to create new event

    3. edit with normal keyboard without vi-mode

        | keys                                  | description                    |
        | :-:                                   | :-:                            |
        | <kbd> Tab </kbd>                      | swap to next                   |
        | <kbd> Shift </kbd> + <kbd> Tab </kbd> | swap to previous               |
        | <kbd> Esc </kbd> + <kbd> Esc </kbd>   | to quit                        |
        | <kbd> Tab </kbd> (s)                  | swap to `> Save` to save event |

### Remote Sync Cloud Calendar

[vdirsyncer](./khal_vdirsyncer.md)

[^h1]: `khal new --help`: review more informations for new event.

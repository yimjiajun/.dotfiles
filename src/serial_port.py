"""
Copyright (c) 2025 [JiaJun Yim]

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
"""
import serial
import threading
import time
import argparse
import os

def pretty_print_data(data, bytes_per_line=16):
    """
    Pretty-prints binary data in a hexdump-like format.

    :param data: The binary data to print (bytes or bytearray).
    :param bytes_per_line: Number of bytes to display per line (default: 16).
    """
    for i in range(0, len(data), bytes_per_line):
        chunk = data[i:i + bytes_per_line]
        hex_part = ' '.join(f"{byte:02X}" for byte in chunk)
        # ASCII representation (printable characters or '.' for non-printable)
        ascii_part = ''.join(chr(byte) if 32 <= byte < 127 else '.' for byte in chunk)
        offset = f"{i:08X}"
        print(f"{offset}  {hex_part:<{bytes_per_line * 3}}  |{ascii_part}|")

def user_input_thread(ser, stop_event):
    """
    Thread to capture user input for interactive commands.
    """
    try:
        while not stop_event.is_set():
            user_input = input("Enter command ('exit' to quit): ").strip()

            if user_input.lower() == 'exit':
                stop_event.set()
                break

            if not user_input:
                continue

            ser.write(user_input.encode())
            print("Sent user input :")
            pretty_print_data(user_input.encode())

    except Exception as e:
        print(f"Exception exit from user input ... {e}")

def write_to_serial(ser, file_path, stop_event):
    """
    Writes data from a file to the shared serial port.

    :param ser: Shared serial port object.
    :param file_path: Path to the file containing data to send.
    :param stop_event: Event to signal when to stop writing.
    """
    if not file_path:
        return

    try:
        with open(file_path, 'rb') as file:
            file_size = os.path.getsize(file_path)
            bytes_written = 0

            print(f"Sending {file_size} bytes from {file_path}")

            while not stop_event.is_set() and (chunk := file.read(512)):
                ser.write(chunk)
                bytes_written += len(chunk)
                print(f"Sent {len(chunk)} bytes ({bytes_written}/{file_size} bytes sent)")
                pretty_print_data(chunk)
                time.sleep(0.1)
    except Exception as e:
        print(f"Error writing to serial: {e}")

def read_from_serial(ser, output_file, stop_event):
    """
    Reads data from the shared serial port and writes it to a file.

    :param ser: Shared serial port object.
    :param output_file: Path to save the received data.
    :param stop_event: Event to signal when to stop reading.
    """
    try:
        if output_file:
            file = open(output_file, 'wb')

        while not stop_event.is_set():
            data = ser.read(512)
            if data:
                if output_file:
                    file.write(data)
                print(f"Received {len(data)} bytes")
                pretty_print_data(data)
            time.sleep(0.1)
    except Exception as e:
        print(f"Error reading from serial: {e}")

def main():
    """
    Main function to parse arguments and start the threads.

    User able to send and receive binary data via serial port.
    User interactive is available to send command/data to the serial port.
    The send and receive data will indicates in hexdump-like format.
    """
    parser = argparse.ArgumentParser(description="Send and receive binary data via serial port.")
    parser.add_argument('--port', type=str, default='COM1', help="Serial port (default: COM1 or /dev/ttyUSB0)")
    parser.add_argument('--baudrate', type=int, default=115200, help="Baud rate (default: 115200)")
    parser.add_argument('--input', type=str, help="Input file to send")
    parser.add_argument('--output', type=str, help="Output file to save received data")

    args = parser.parse_args()
    serial_port = args.port
    baudrate = args.baudrate
    input_file = args.input
    output_file = args.output

    try:
        ser = serial.Serial(serial_port, baudrate, timeout=1)

        print(f"Opened serial port: {serial_port}")
        print(f"- baudrate: {baudrate}")
        print(f"- input file: {args.input}")
        print(f"- output file: {args.output}")

        stop_event = threading.Event()
        reader_thread = threading.Thread(target=read_from_serial, args=(ser, output_file, stop_event))
        reader_thread.start()
        input_thread = threading.Thread(target=user_input_thread, args=(ser, stop_event))
        input_thread.start()
        writer_thread = threading.Thread(target=write_to_serial, args=(ser, input_file, stop_event))
        writer_thread.start()
        # Wait serial port to complete / close
        writer_thread.join()
        input_thread.join()
        reader_thread.join()
    except Exception as e:
        print(f"Error opening serial port: {e}")
    except KeyboardInterrupt:
        print("Keyboard interrupt detected. Stopping program.")
        stop_event.set()
    finally:
        if 'ser' in locals() and ser.is_open:
            ser.close()
            print("Closed serial port.")

    print("Program terminated successfully.")

if __name__ == '__main__':
    main()

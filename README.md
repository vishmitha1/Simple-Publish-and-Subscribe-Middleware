# Middleware Pub/Sub System

This repository contains a middleware Publish/Subscribe (Pub/Sub) system implemented using Ballerina. The system allows multiple clients to connect to a server concurrently, where clients can act as publishers or subscribers to specific topics. Clients can publish messages to a server on specific topics, and the server then routes these messages to all subscribers interested in those topics.

## Table of Contents

- [How It Works](#how-it-works)
- [Features](#features)
- [Installation](#installation)
- [Usage](#usage)
  - [Starting the Server](#starting-the-server)
  - [Starting a Client](#starting-a-client)


## How It Works

1. **Client-Server Architecture**: The system operates on a client-server model. The server listens on a predefined port for client connections. Clients connect to the server using the server's IP address and port number.

2. **Roles**: Clients can act as either publishers or subscribers. A publisher sends messages to the server, and the server distributes those messages to all subscribers interested in the specific topic(s).

3. **Topics**: Both publishers and subscribers specify one or more topics when connecting. Messages sent by a publisher are only distributed to subscribers interested in the same topic(s).

4. **Concurrency**: The server can handle multiple concurrent client connections, allowing for a scalable and robust communication system.

5. **Termination**: Clients can disconnect from the server by typing the keyword `terminate`, after which they will be disconnected and the application will exit.

## Features

- **Multiple Topics**: Clients can publish or subscribe to multiple topics by specifying a comma-separated list of topics.
- **Real-time Communication**: Messages are relayed in real-time between publishers and subscribers.
- **Scalable Design**: The server can handle multiple concurrent client connections.
- **Flexible Client Roles**: Clients can dynamically choose to be either a publisher or a subscriber at runtime.

## Installation

1. **Clone the Repository**:
    ```bash
    git clone https://github.com/vishmitha1/Simple-Publish-and-Subscribe-Middleware.git
    cd Simple-Publish-and-Subscribe-Middleware
    ```

2. **Install Ballerina**:
    Ensure that Ballerina is installed on your system. If not, download and install it from [Ballerina's official website](https://ballerina.io/downloads/).

## Usage

### Starting the Server

To start the server, run the following command:
**Server Run On Port 9090**

```bash 
bal run server.bal  

```
### Starting a Client
you can start a  multiple clients by running the following command:
```bash
bal run client.bal  -- 9090 127.0.0.1 publisher topic1
bal run client.bal  -- 9090 127.0.0.1 publisher topic1,topic2
bal run client.bal  -- 9090 127.0.0.1 SubScriber topic1,topic2

```
*after running the publishers client you can type the message  and it will be published to the server and the server will send the message to the subscriber who is subscribed to the topic.*


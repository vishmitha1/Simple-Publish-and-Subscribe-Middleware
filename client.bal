import ballerina/io;
import ballerina/tcp;
import ballerina/lang.runtime;

public function main() returns error? {
    // Create a new TCP client by providing the `remoteHost` and `remotePort`.
    tcp:Client socketClient = check new ("localhost", 9090);

    // Loop to keep the client running
    while true {
        // Send the desired content to the server.
        check socketClient->writeBytes("Hello Ballerina from client".toBytes());
        
        // Read the response from the server.
        readonly & byte[] receivedData = check socketClient->readBytes();
        io:println("Received: ", string:fromBytes(receivedData));

        // Wait for some time before sending the next message
        runtime:sleep(5); // Sleep for 5 seconds
    }
}

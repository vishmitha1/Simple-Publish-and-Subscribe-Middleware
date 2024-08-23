import ballerina/io;
import ballerina/lang.runtime;
import ballerina/websocket;

public function main(int port, string ip, string userType,string topic) returns error? {
    // Create a new WebSocket client.
    io:println(port);
    io:println(ip);
    string clientType = userType.toUpperAscii();
    string url = string `ws://${ip}:${port}/${clientType}/${topic}`; 
    websocket:Client chatClient = check new (url);
    // check chatClient->writeTextMessage(clientType);

    // Write a message to the server using `writeMessage`.
    // This function accepts `anydata`. If the given type is a `byte[]`, the message will be sent as
    // binary frames and the rest of the data types will be sent as text frames.
    while true {

      

        if (clientType === "PUBLISHER") {
            // Read a message sent from the server using `readMessage`.
            // The contextually-expected data type is inferred from the LHS variable type. The received data
            // will be converted to that particular data type.
            string? userInput = io:readln("What you want to say to the server?");
            if (userInput == "terminate") {
                

                break;
            }
            check chatClient->writeMessage(userInput);
            //set the sleep time in 3 seconds
            runtime:sleep(3);
        }

        else{
        string message = check chatClient->readMessage();

        io:println(message);
        }

    }
 
    // Close the connection.
    check chatClient->close();
}

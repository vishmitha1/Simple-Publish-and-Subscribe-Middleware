import ballerina/io;
import ballerina/websocket;
import ballerina/lang.runtime;

public function main(int port, string ip) returns error? {
    // Create a new WebSocket client.
    io:println(port);
    io:println(ip);
    string url = string `ws://${ip}:${port}/`;
    websocket:Client chatClient = check new (url);
    
    // Write a message to the server using `writeMessage`.
    // This function accepts `anydata`. If the given type is a `byte[]`, the message will be sent as
    // binary frames and the rest of the data types will be sent as text frames.
    while true {
        
    string? userInput= io:readln("What you want to say to the server?");
    if(userInput=="terminate"){
        check chatClient->writeMessage(userInput);
        
        break;
    }
    check chatClient->writeMessage(userInput);
    
    // Read a message sent from the server using `readMessage`.
    // The contextually-expected data type is inferred from the LHS variable type. The received data
    // will be converted to that particular data type.
    string message = check chatClient->readMessage();
    io:println(message);
    runtime:sleep(3); //set the sleep time in 3 seconds

    }
    string message = check chatClient->readMessage();
    io:println(message);
    // Close the connection.
    check chatClient->close();
}

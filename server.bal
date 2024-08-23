import ballerina/io;
import ballerina/regex;
import ballerina/websocket;

listener websocket:Listener PubSubListner = new websocket:Listener(9090);

isolated websocket:Caller[] subscriberList = [];
isolated websocket:Caller[] publisherList = [];

service /SUBSCRIBER on PubSubListner {

    resource isolated function get [string topic]() returns any {

        return new PubSubService("SUBSCRIBER", topic);

    }

}

service /PUBLISHER on PubSubListner {

    resource isolated function get [string topic]() returns any {

        return new PubSubService("PUBLISHER", topic);

    }

}

service class PubSubService {
    *websocket:Service;

    private string userType;
    private string topic = "";
    private string[] multipleTopics = [];

    isolated function init(string userType, string topic) {
        self.userType = userType;
        self.multipleTopics = regex:split(topic, ",");

        if (self.multipleTopics.length() == 1) {

            self.topic = self.multipleTopics[0];

        }

    }

    public isolated function onOpen(websocket:Caller caller) returns error? {
        // This `remote function` is triggered when a new connection is established.
        // The `caller` object represents the connected client.


        io:println("New client connected");
        if (self.userType === "SUBSCRIBER") {

            lock {
                subscriberList.push(caller);
                io:println("Connected Subscribers Count: ",subscriberList.length());

            }
            if (self.multipleTopics.length() > 1) {
                caller.setAttribute("isMultipleTopics", true);
                caller.setAttribute("multipleTopics", self.multipleTopics);

            }

            caller.setAttribute("topic", self.topic);

        }

        else if (self.userType === "PUBLISHER") {
            lock {
                publisherList.push(caller);
                 io:println("Connected Publishers Count: ",publisherList.length());
            
            }
            if (self.multipleTopics.length() > 1) {
                caller.setAttribute("isMultipleTopics", true);
                caller.setAttribute("multipleTopics", self.multipleTopics);

            }

            caller.setAttribute("topic", self.topic);
        }

    }

    // This `remote function` is triggered when a new message is received
    // from a client. It accepts `anydata` as the function argument. The received data 
    // will be converted to the data type stated as the function argument.
    remote function onMessage(websocket:Caller caller, string chatMessage) returns error? {
      
        if (self.userType === "PUBLISHER") {
            return self.broadCast(chatMessage);
        }

    }

    remote isolated function onClose(websocket:Caller caller) {
        if (self.userType === "PUBLISHER") {
            lock {
                string[] publishersIds = publisherList.'map(n => n.getConnectionId());
                int index = <int>publishersIds.indexOf(caller.getConnectionId());
                _ = publisherList.remove(index);
            }
        }
        if (self.userType === "SUBSCRIBER") {
            lock {
                string[] subscriberIds = subscriberList.'map(n => n.getConnectionId());
                int index = <int>subscriberIds.indexOf(caller.getConnectionId());
                _ = subscriberList.remove(index);
            }
        }
    }

    isolated function broadCast(string msg) returns error? {

        lock {

            foreach websocket:Caller item in subscriberList {

                if (self.multipleTopics.length() == 1) { //check publisher single topic

                    if (item.getAttribute("isMultipleTopics") == true) { //single topic pub -> multiple topic sub
                        string[] subscriberTopics = check item.getAttribute("multipleTopics").ensureType();

                        foreach string topic in subscriberTopics {
                            if (self.multipleTopics[0] === topic) {
                                websocket:Error? writeTextMessage = item->writeMessage(msg);
                                if writeTextMessage is error {
                                    io:println("Error in Bradcasting:", writeTextMessage);
                                }
                            }
                        }
                    }

                    else { //single topic pub -> single topic sub
                        if (item.getAttribute("topic") === self.multipleTopics[0]) {
                            websocket:Error? writeTextMessage = item->writeMessage(msg);
                            if writeTextMessage is error {
                                io:println("Error in Broadcasting:", writeTextMessage);
                            }
                        }
                    }

                }

                else if (self.multipleTopics.length() > 1) { //check publishers multiple topics

                    if (item.getAttribute("isMultipleTopics") == true) { //multi topic pub -> multi topic pub
                        string[] subscriberTopics = check item.getAttribute("multipleTopics").ensureType();

                        foreach string subTopic in subscriberTopics {
                            boolean isFound = self.multipleTopics.some(n => n === subTopic);
                            if (isFound) {
                                websocket:Error? writeTextMessage = item->writeMessage(msg);
                                if writeTextMessage is error {
                                    io:println("Error in Broadcasting:", writeTextMessage);
                                }
                            }
                        }
                    }

                    else { //multi topic pub -> single topic sub
                        string subTopic = check item.getAttribute("topic").ensureType();
                        int? index = self.multipleTopics.indexOf(subTopic);
                        if index is int {
                            websocket:Error? writeTextMessage = item->writeMessage(msg);
                            if writeTextMessage is error {
                                io:println("Error in Bradcasting:", writeTextMessage);
                            }
                        }

                    }
                }

            }
        }
    }

}


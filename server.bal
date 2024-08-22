import ballerina/io;
// import ballerina/lang.value;
import ballerina/websocket;

listener websocket:Listener PubSubListner =  new websocket:Listener(9090);
// isolated map<websocket:Caller> subscriberList={};
isolated websocket:Caller[] subscriberList = [];
isolated websocket:Caller[] publisherList = [];

service /SUBSCRIBER on PubSubListner {

    resource isolated function get.() returns any {

        return new PubSubService("SUBSCRIBER");

    }
    

}
service /PUBLISHER on PubSubListner {

    resource isolated function get.() returns any {

        return new PubSubService("PUBLISHER");

    }
    

}

service class PubSubService {
    *websocket:Service;

    private string userType;

    isolated function init(string userType) {
        self.userType = userType;
    }

    public isolated function onOpen(websocket:Caller caller) returns error? {
        // This `remote function` is triggered when a new connection is established.
        // The `caller` object represents the connected client.
        // value:Cloneable clientType=caller.getAttribute("clientType");

        io:println("New client connected");
        if (self.userType === "SUBSCRIBER") {

            lock {
                subscriberList.push(caller);
                io:println("subs",subscriberList);
            }
        }

        else if (self.userType==="PUBLISHER") {
            lock {
                publisherList.push(caller);
                io:println("pub",publisherList);
            }
        }

    }

    // This `remote function` is triggered when a new message is received
    // from a client. It accepts `anydata` as the function argument. The received data 
    // will be converted to the data type stated as the function argument.
    remote function onMessage(websocket:Caller caller, string chatMessage) returns error? {
        io:println(chatMessage);
        if(self.userType==="PUBLISHER"){
        check caller->writeMessage("Hello!, How are you?");
            self.broadCast(chatMessage);
        }

    }

    remote isolated function onClose(websocket:Caller caller) {
        if(self.userType==="PUBLISHER"){
            lock {
                string [] publishersIds=publisherList.'map(n=>n.getConnectionId());
                io:println(publishersIds);
                int index =<int>publishersIds.indexOf(caller.getConnectionId());
                _ = publisherList.remove(index);
            }
        }
        if(self.userType==="SUBSCRIBER"){
            lock {
                string [] subscriberIds=subscriberList.'map(n=>n.getConnectionId());
                int index =<int>subscriberIds.indexOf(caller.getConnectionId());
                _ = subscriberList.remove(index);
            }
        }
    }

    isolated   function broadCast(string msg){
        lock {
	        foreach websocket:Caller item in subscriberList {
	            websocket:Error? writeTextMessage = item->writeMessage(msg);
                if  writeTextMessage is error{
                    io:println("Error in Bradcasting:",writeTextMessage);
                }
	        }
        }
    }

}


import ballerina/http;
import ballerina/io;

type Album readonly & record {|
    string title;
    string artist;
|};

public function main() returns error? {
    // Creates a new client with the Basic REST service URL.
    final http:Client httpClient = check new("http://localhost:9090");

    // Binding the payload to a `record` array type.
    // The contextually expected type is inferred from the LHS variable type.
    Album[] albums = check httpClient->/albums;
    io:println("First artist name: " + albums[0].artist);
}

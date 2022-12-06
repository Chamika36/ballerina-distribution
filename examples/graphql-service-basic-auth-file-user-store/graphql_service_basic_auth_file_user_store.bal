import ballerina/graphql;

type Profile record {|
    string name;
    int age;
|};

listener graphql:Listener securedEP = new (9090,
    secureSocket = {
        key: {
            certFile: "../resource/path/to/public.crt",
            keyFile: "../resource/path/to/private.key"
        }
    }
);

// The service can be secured with Basic Auth and can be authorized optionally. Using Basic Auth
// with the file user store can be enabled by setting the `graphql:FileUserStoreConfig`
// configurations. Authorization is based on scopes. A scope maps to one or more groups.
// Authorization can be enabled by setting the `string|string[]` type configurations for the
// `scopes` field.
@graphql:ServiceConfig {
    auth: [
        {
            fileUserStoreConfig: {},
            scopes: ["admin"]
        }
    ]
}
service /graphql on securedEP {
    resource function get profile() returns Profile {
        return {
            name: "Walter White",
            age: 50
        };
    }
}

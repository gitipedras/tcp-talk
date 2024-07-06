# TCP Talk
Talk app that uses tcp in the backend

## Features
1. Simple Chat
You can chat, simplelest feature

2. Color coding
Send messages with colors
`Hello World.green` the `.green` puts the text in green

3. Config file for server and client
You can configure your server and your client with two JSON files.

## More Info

### Color Coding
Sending messages with colors works like this:
`Hello World.green` the `.green` puts the text in green

Other avalible colors are:
	**color** ascii color code
    **black**:   30
    **red**:     31
    **green**:   32
    **yellow**:  33
    **blue**:    34
    **magenta**: 35
    **cyan**:    36
    **white**:   37

### Server Config
The server configuration file `server-config.json` is a JSON file to configure you server:
```
{
  "server_name": "tcp-test-server",
  "port": 4000
}
```
### Client Config
The client configuration file `client-config.json` is a JSON file to configure you client:
```
{
  "hostname": "localhost",
  "port": 4000,
  "username": "user"
}

```
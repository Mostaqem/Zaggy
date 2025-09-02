# Zaglib (Taglib wrapper in Zig V0.1)

### Problems
- Needed Metadata library for Mostaqem , found [Metadata God](https://pub.dev/packages/metadata_god) library , it was working fine , but suddenly , it asks for things for Rust , I couldn't understand how to solve so I built my own in my love language [Zig](https://ziglang.org/)


### Goals
- Needed to handle metadata in flutter for Mostaqem using [Taglib](https://taglib.org/) which a C++ MetaData Audio Library
- Continue Testing it for cross platform , right now , I only tested it on my Linux (EndeavorOS/Arch)

### Build
- Make sure u have taglib installed for your OS (Only tested in Linux , haven't tested Mac or Windows)
- Simply run `zig build run` to run the [example](src/main.zig) 
- If u want static library , simply run
```bash
zig build
```



# Locky Swift SDK
This SDK contains a demo SDK written in swift. It also contains communication over the bluetooth and restful services.

This SDK has been built to demostrate how to build other app's on top of this demostration code. If you need a sdk for android, have a look at our sdk's named: android-sdk.


### import
+ Use SPM, in the tab 'Package Dependencies' of Xcode, add the below package link, choose the branch or tag you want, then add it.

```
https://github.com/thundertechnologyas/ios-sdk
```
+ add NSBluetoothAlwaysUsageDescription and UIBackgroundModes into the Info.plist of your project

``` bash
<key>NSBluetoothAlwaysUsageDescription</key>
<string>Use bluetooth to discover, connect to, and share information with nearby devices</string>
<key>UIBackgroundModes</key>
<array>
	<string>bluetooth-central</string>
</array>
```

### You log on to the sdk using a two token based authentication process, first ask for a verification code sent by email

```
// Ask the locky backend for an authentication code.
let sdk = Locky();
sdk.startVerify(email);
```
### Then use the authentication code to login
```
let sdk = Locky();
locky.verify(code: codeFromEmail) { result in
   // result is Bool to show sucess or failure.
}
```

### Recieve the list of locks
Now you have access and get ask for all locks this user has access to.

The devices object contain all the nessesary data to run operations on the lock, example pulse open.

If the ble status is changed, the callback would trigger again at once.

```
let sdk = Locky();
locky.getAllLocks {locks, result in
    // result is Bool to show sucess or failure.
    // locks is one list contains all locks which contain ble status
}
```

### Run pulse open
If the ble status of lock is true, then we can run perations.

```
let sdk = Locky();
sdk.pulseOpen(device.id);
```


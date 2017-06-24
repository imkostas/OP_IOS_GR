OPA
========

OPA IOS code

# OPA_IOS


In the Apple developer website open certificates,
Register iPad/iPhone by getting UDID using iTunes
Register AppID using the bundle ID from xcode
Select push notifications in AppServices

Open Keychain Access (type "keychain" in the launchpad), the from the menu go to Certificate Assistant -> Request certificate from authority
Save certificate to disk
Within the Apple developer website, create iOS App Development certficate 
Select saved certificate
Download certificate to disk
Then execute the certificate to import it to keychain (it should show in "My certificates" in keychain access)

Go to provisioning profiles and choose manually generate
Choose certificate, device ...
Download profile to disk
Execute profile (it should be imported to xcode)

In xcode, go to Build setting and replace all Code signing and provisioning profiles entities with the newly created one
(it is good to use several profiles for debug/production)
From the top of the screen you can now select the devices registered earlier.

Open Keychain Access (type "keychain" in the launchpad), the from the menu go to Certificate Assistant -> Request certificate from authority
Save certificate to disk (use different name than before)
Within the Apple developer website, go back to App ID, select the app, Edit, Create Push notification certificate
Select the CSR file you just created
Download certificate to disk
Then execute the certificate to import it to keychain (it should show in "My certificates" in keychain access)
Open Keys in keychain and export p12 key
Open terminal and follow instruction from page http://www.raywenderlich.com/32960/apple-push-notification-services-in-ios-6-tutorial-part-1
(from "Making a PEM file")
Copy the last generated pem file to the server
Edit globals.php (PUSH_CERT nd PUSH_PASSPHRASE)
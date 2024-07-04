# FridaCodeManager

## Notes
I made this project because my parents took my mac and I still wanted to code and AppInstalleriOS was the first person that helped me making this project, without them this would not exist so give them a follow!

## Compatibility
iOS 15.0 - 17.0 was offcially tested on both, roothide and rootless.

Compiled projects can run on lower iOS with the right API used. This is your choice for supported iOS for your app, not us.

## Compiling
It's meant to be compiled on jailbroken iOS devices as
compiling on macOS can cause certain anomalies with UI, etc

You need `swift`,`clang`,`git` and `make`. Run `make all` to compile and package it to a rootless .deb
To compile package for roothide use `make roothide`.

These are used and modifiable environment variables:

<table>
	<tr>
		<th>Variable name</th>
		<th>Usage</th>
	<tr>
	<tr>
        <td>SDK_PATH</td>
        <td>Relative path to the SDK. Defaults to an SDK from Theos that will be cloned if not found</td>
    </tr>
    <tr>
        <td>SDK_URL</td>
        <td>Full URL of SDKs for git to clone (defaults to theos/sdks on GitHub)</td>
    </tr>
</table>

Was successfully compiled on
</br>
    <table>
        <tr>
            <th>iDevice</th>
            <th>iOS Version</th>
        </tr>
        <tr>
            <td>iPhone 6s</td>
            <td>iOS 15.8.2</td>
        </tr>
        <tr>
            <td>iPhone 7</td>
            <td>iOS 15.6</td>
        </tr>
        <tr>
            <td>iPhone X</td>
            <td>iOS 15.0</td>
        </tr>
        <tr>
            <td>iPhone 11</td>
            <td>iOS 16.5</td>
        </tr>
    </table>
</br>

## Credits
- SeanIsNotAConstant: [https://github.com/fridakitten](https://github.com/fridakitten)
- AppInstallerIOS: [https://github.com/AppInstalleriOSGH](https://github.com/AppInstalleriOSGH)
- meighler: [https://github.com/meighler](https://github.com/meighler)
- HAHALOSAH: [https://github.com/HAHALOSAH](https://github.com/HAHALOSAH)
- MudSplasher: [https://github.com/MudSplasher](https://github.com/MudSplasher)
- Opa334: [https://github.com/Opa334](https://github.com/Opa334)
- Theos: [https://github.com/theos](https://github.com/theos)
- RootHideDev: [https://github.com/roothide](https://github.com/roothide)
- Speedyfriend67: [https://github.com/speedyfriend433](https://github.com/speedyfriend433)
- Burhan Rana: [https://github.com/burhangee](https://github.com/burhangee)

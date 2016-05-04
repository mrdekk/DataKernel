# DataKernel

## What is DataKernel?

DataKernel is a minimalistic wrapper around CoreData stack to ease persistence operations. It is havily inspired by SugarRecord but have no external dependencies (except cocoa of course) and with some refinements. It is covered with unit tests.

If you have any propositions please file issue.
If you need usage examples - see unit test, it is very straightforward

## Features
- Swift (now tested in xCode 7.2.1, but it should work in 7.3)
- Protocols based design
- Fully tested
- Actively supported
- No carthage (but you can try and submit PR)
- No iCloud yet (but planned)

## Setup

### [CocoaPods](https://cocoapods.org)

1. Install [CocoaPods](https://cocoapods.org). You can do it with `gem install cocoapods`
2. Edit your `Podfile` file and add the following line `pod 'DataKernel'` (you have to use use_frameworks!, because this is a Swift pod)
3. Update your pods with the command `pod install`
4. Open the project from the generated workspace (`.xcworkspace` file).

*Note: You can also test the last commits by specifying it directly in the Podfile line*

### [Carthage](https://carthage)
1. Install [Carthage](https://github.com/carthage/carthage) on your computer using `brew install carthage`
3. Edit your `Cartfile` file adding the following line `github "mrdekk/DataKernel"`
4. Update and build frameworks with `carthage update`
5. Add generated frameworks to your app main target following the steps [here](https://github.com/carthage/carthage)
6. Link your target with **CoreData** library *(from Build Phases)*

#### Notes
- Carthage integration includes both, CoreData and Carthage. We're planning to separate it in multiple frameworks. [Task](https://trello.com/c/hyhN1Tp2/11-create-separated-frameworks-for-foundation-coredata-and-realm)
- SugarRecord 2.0 is not compatible with the 1.x interface. If you were using that version you'll have to update your project to support this version.

# How to use

TBD, not completed yet, see unit tests

# Contributing

## Support

If you want to communicate any issue, suggestion or even make a contribution, you have to keep in mind the flow bellow:

- If you need help, ask your doubt in Stack Overflow using the tag 'datakernel'
- If you want to ask something in general, use Stack Overflow too.
- Open an issue either when you have an error to report or a feature request.
- If you want to contribute, submit a pull request, and remember the rules to follow related with the code style, testing, ...

## Code of conduct

This project adheres to the [Open Code of Conduct][code-of-conduct]. By participating, you are expected to honor this code.
[code-of-conduct]: http://todogroup.org/opencodeofconduct/#DataKernel/mrdekk@yandex.ru

## License
The MIT License (MIT)

Copyright (c) <2014> <Pedro Piñera>

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

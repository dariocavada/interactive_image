# interactive_image

Interactive Image package created with Flutter.


The source code is **100% Dart**, and everything resides in the [/lib](https://github.com/mohak1283/CustomSwitch/tree/master/lib) folder.

## Show some :heart: and star the repo to support the project

[![GitHub followers](https://img.shields.io/github/followers/dariocavada.svg?style=social&label=Follow)](https://github.com/dariocavada)  
[![Open Source Love](https://badges.frapsoft.com/os/v1/open-source.svg?v=102)](https://opensource.org/licenses/Apache-2.0)

## 💻 Installation

In the `dependencies:` section of your `pubspec.yaml`, add the following line:

```yaml
interactive_image: <latest_version>
```

Import in your project:
```dart
import 'package:interactive_image/interactive_image.dart';
```

## ❔Basic Usage
```dart
class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  bool status = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Custom Switch Example'),
      ),
      body: InteractiveImage(
          // see below the json example
          url: 'interactive_image.json',
      )
    );
  }
}
```





## 👨 Developed By

```
Dario Cavada
```


<a href="https://twitter.com/dariocavada"><img src="https://user-images.githubusercontent.com/35039342/55471524-8e24cb00-5627-11e9-9389-58f3d4419153.png" width="60"></a>
<a href="https://it.linkedin.com/in/dariocavada"><img src="https://user-images.githubusercontent.com/35039342/55471530-94b34280-5627-11e9-8c0e-6fe86a8406d6.png" width="60"></a>
<a href="https://it-it.facebook.com/dario.cavada"><img src="https://github.com/aritraroy/social-icons/blob/master/facebook-icon.png?raw=true" width="60"></a>
<a href="https://medium.com/@dario.cavada.lab"><img src="https://user-images.githubusercontent.com/35039342/60429733-5a9f1000-9c19-11e9-9243-54052a4e4f05.png" width="60"></a>


# 👍 How to Contribute

1. Fork it
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create new Pull Request

# 📃 License

    Copyright (c) 2021-2025 Dario Cavada

    Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

## Getting Started

For help getting started with Flutter, view our online [documentation](https://flutter.dev/).

For help on editing package code, view the [documentation](https://flutter.dev/developing-packages/).
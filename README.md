# cocoapods-packing-cubes

A small CocoaPods plugin that allows specifying how individual pods are packaged and linked.

## Installation

    $ gem install cocoapods-packing-cubes

## Usage

```ruby
# Podfile

plugin 'cocoapods-packing-cubes',
    'AFNetworking' => { 'linkage' => 'static', 'packaging' => 'framework' },
    'SVGKit' => { 'linkage' => 'dynamic', 'packaging' => 'framework' },
    'JSONKit' => { 'linkage' => 'static', 'packaging' => 'framework' }
```

Now run the pod installation.

```
pod install

```

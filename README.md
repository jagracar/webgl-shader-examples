# WebGL shader examples

Some simple examples of WebGL shaders. They can be seen live at [webgl-shaders.com](https://webgl-shaders.com).

# Build the project

Install [Node.js](https://nodejs.org) (for Ubuntu):

``` bash
sudo apt-get install curl
curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash -
sudo apt-get install -y nodejs
```

Install [grunt](https://gruntjs.com/), [glslify](https://github.com/glslify/glslify) and [budo](https://github.com/mattdesl/budo) globally:

``` bash
sudo npm install -g grunt-cli
sudo npm install -g glslify
sudo npm install -g budo
```

Download the git repository and install the dependencies:

``` bash
git clone https://github.com/jagracar/webgl-shader-examples.git
cd webgl-shader-examples
npm install
```

Build the project:

``` bash
grunt
```

Run budo:

``` bash
budo --dir WebContent/ --live
```

Then open [http://localhost:9966/](http://localhost:9966/) to test the examples.

# Micrograd 🧮💎📉

This is an example implementation of a **small neural network library** in Ruby, with [automatic differentiation](https://en.wikipedia.org/wiki/Automatic_differentiation) and [backpropagation](https://en.wikipedia.org/wiki/Backpropagation). If you have no clue what that means, check out [this video series](https://www.youtube.com/watch?v=aircAruvnKk&list=PLZHQObOWTQDNU6R1_67000Dx_ZCJB-3pi), which explains Neural Networks and Deep Learning visually, without math.

I implemented this library by going through the YouTube lecture
[“The spelled-out intro to neural networks and backpropagation: building micrograd”](https://www.youtube.com/watch?v=VMj-3S1tku0&list=PLAqhIrjkxbuWI23v9cThsA9GvCAUhRvKZ))
by Andrej Karpathy. It's the first in a series called "Neural Networks: From Zero to Hero", which builds up from the basic building blocks all the way to implementing GPT-2. As I watched the video, I translated the Python code into Ruby.

There's a canonical implementation of the functionality implemented in Python, available as [micrograd](https://github.com/karpathy/micrograd).
I didn't reference the `micrograd` codebase at all,
nor any of the other micrograd implementations [in Ruby](https://github.com/search?utf8=%E2%9C%93&q=micrograd+language%3ARuby+&type=repositories),
nor in any other languages.

This is a fine codebase to learn from (though you should write it yourself).
If you're building anything real, you probably want to use [torch.rb](https://github.com/ankane/torch.rb), which is based on libtorch, the high-performance C++ library that powers PyTorch.

### Motivation
Why? Because I am learning neural networks & deep learning.
I know enough Python to have been able to write it in Python,
but (1) I didn't want to just write all the same code he wrote and (2) I learn best by adapting principles to a different language and taking a different approach.
I know Ruby best (and enjoy writing it the most), so it was the obvious choice.

## Approach
I implemented it in **idiomatic** Ruby: I didn't just copy the Python and adapt the syntax directly:
* I used bang methods, e.g. `Value#backward!`, since in Ruby we use that to signify that we're mutating the object in-place.
* I leveraged methods on Enumerable instead of using loops (since we don't have list comprehension in Ruby)
* I changed expanded short variable/parameter names to be unabbreviated in most cases
* I used symbol keys, of course
* I used keyword args in most cases
* I extracted `Visualizer` and `TopoGraph` classes, instead of encapsulating that logic within `Value`.

And, since it's Ruby, I also implemented it in an **idiosyncratic** way:
* I added a bracket constructor (factory) syntax (e.g. `Micrograd::Value[scalar_value]`), since I was jealous of Python's terseness with no `.new` when creating Value objects.
  * I also added a shorthand to pair labels with scalar data values via this syntax: `Micrograd::Value[label: scalar_value]`.
  * I think using parens, e.g. `Micrograd::Value(...)` to construct the value would work too (since that's the convention for conversion methods).
* Prefer immutability by default, when realistic. Mutating state is hard to reason about, avoiding it as much as possible is preferable.
* Prefer using `attr_reader` internally for accessing instance variables (so all references to instance variables are mutation. This makes it easier to find them).
* Prefer injecting dependencies rather than relying on global state. You can see I did this with `random:` being passed into `Neuron`, `Layer`, `MLP`, and `Training`.

I balanced that with being **pragmatic**:
* In `lib/micrograd/value.rb`, I do use mutation of instance variables to update `@grad` and `@data`. In many (most?) applications, immutability can provide better performance since it's easier on the Garbage Collector. However, these kind of neural nets are meant to be computed at a massive scale and repeatedly, on GPU's. In that case, creating millions or billions of objects on each iteration would obviously be much slower than mutating in place, since object creation is relatively slow and memory-intensive.
* In `lib/micrograd/value.rb`, I used `self.` when it's not necessary (and disabled the `Style/RedundantSelf` to allow this). Why? Because many of the methods are operations that reference `other`, so I find it more readable to have symmetry between `self` and `other`. And, for the rest of the class, I wanted to be consistent with that choice. This is also the standard way to access instance variables in Python.
* I used `Enumerable#reduce` which is an alias for `Enumerable#inject`. I default to using `#inject` but figured non-Rubyists might read this, and `#reduce` is the name that's more common in other languages, so I think it makes more sense here.
* I kept the leading underscore for `_backward` lambda, to signify it's different from the externally facing `backward!`. I could have named it `backward` (without the bang), but I feel like the underscore reveals the intent that it's an implementation detail and shouldn't be used directly. This is a pattern used occasionally in Ruby, and I think it's worth using here.

I **extended** the work from the video slightly. At the end, he builds out the training process using the MLP (multi-level perceptron), ad-hoc in the Jupyter notebook. I did that as well first, in the `MLP` class's spec file. After that, though, I extracted an `Micrograd::Training` class to encapsulate and generalize that work.


### Overview of library

#### Value
The basic object is the `Micrograd::Value`. This has a `data` attribute (which is the value), a `grad` attribute, and a `backward!` method. I wanted to follow the convention established by micrograd (and PyTorch), but I think I prefer to name this class `Node` and have the `data` attribute be named `value` or `scalar` instead. While we're at it, I'd also name `grad` as `gradient`, but that's an even starker break from convention.

This class handles operations, computing `grad`, the `backward!` pass, and `gradient_step!` as well (which is used in the `Training` class). The `backward!` method uses a helper class called `TopoSort`

It also has a convenience method `generate_image`, which uses the `Visualizer` class to generate a visual representation of the network (with [d2](https://github.com/terrastruct/d2)).

#### Building up a neural net (using `Neuron`, `Layer`, `MLP`, and `Training`)

The rest of the classes all stack on top of each other to build a full Neural net(work).

The basic building block there is the `Neuron`. This uses `Value` for its *weights* and *bias*.

Those are combined into a `Layer`, which is then combined into an `MLP` ([multi-layer perceptron](https://en.wikipedia.org/wiki/Multilayer_perceptron)). Again, I'd usually name this class its full name but MLP is a ubiquitous acronym in Deep Learning, and I didn't want to buck the conventions too much.

Finally, there is the `Training` class. This is used to train the Neural net! This is the real guts of the library, the fullest expression of what we're trying to accomplish.

In brief, this takes:
1. how many layers and what size you want as an array, e.g. [3, 2, 2, 2, 2, 1] signifies: 3 input scalars, 4 'hidden' internal layers of 2 neurons each, and 1 output value.
2. an array of arrays of `inputs` values
3. an array of `target` values
4. an optional `Random` instance (else it just defaults to `Random.new`, helpful for reproducing results and testing)

Then once it's created, the training occurs when `call` is received.
This takes:
1. number of `epochs` (how many times the gradient descent occurs)
2. the `learning_rate`
3. an optional `varbose` flag if you want the loss function results to be printed as it goes. This is helpful for manually adjusting the number of `epochs` and the `learning_rate`

What this does is :
1. First `iterate!` on the MLP, by:
  1. calculating the forward pass,
  2. calculate the loss (using difference of two squares)
  3. run `backward!` on the loss

2. Then `epoch` number of times, do the following:
  1. Descend!! That is: go through all the parameters in the MLP and step them downward a small amount (the `learning_rate`)
  2. Recalculate the loss, but `iterate!`ing the same way as above

3. Once that is done, return a `Training::Result` object, which holds the last run's `outputs` and the `mlp`. This `MLP` is now the trained neural net.

4. [????](https://youtu.be/2B3slX6-_20?feature=shared&t=6)

5. Profit!

## Coding modalities
In the lecture, Andrej uses a Jupyter notebook: these are ubiquitous in Python Data/AI/ML world.
There's a library called `iruby` that let you use Ruby in Jupyter notebooks, but I didn't do that.

> As an aside, I found it extremely hard to reason about state in Jupyter when watching the videos.
> I guess it may be easier when you're coding in a notebook yourself, since your memory is more clear,
> but having blocks of code that redefine variables executed ad-hoc in different sequences... Ah!! GOTO considered harmful, indeed!

I preferred to write code in classes, then execute it in a file when necessary (e.g. `ruby lib/micrograd/examples.rb`).
Sometimes I used `bin/console` to load the files and work with them like that, in an `irb` session.

Finally, I transitioned to using RSpec to ensure behavior stayed consistent as I refactored.

## TODO's
- [ ] Convert examples.rb to runnable script in `bin/`
- [ ] Update README with actual usages instead of telling people to look at the specs
- [ ] Adapt/complete the [exercises](https://colab.research.google.com/drive/1FPTx1RXtBfc4MaTkf7viZZD4U2F9gtKN?usp=sharing) from the video description
- [ ] Add a note when doing `require "micrograd"` to require the specific parts you need


## COULDDO's (but probably will not)
- [ ] Add alternate `Training` runner that gets the loss function within the threshold, and reports the number of steps
- [ ] Adapt Torch examples from video with torch.rb
- [ ] Add a `Micrograd::Torch::` namespace that implements the same API as Micrograd (`Value`, `Neuron`, `Layer`, `MLP`, `Training`), using torch.rb
- [ ] Fix `# TODO` in `Training` class (validate and/or compute sizes)


## Installation
You're probably just curious and may read the code and specs here on GitHub.
But if you want to mess around with the code, you can clone this repo.

I don't see why you'd want to install this as a dependency, but you could do `gem "micrograd", github: "cllns/micrograd"` if you want.

## Usage
Take a look at the specs, particularly `specs/training_spec.rb`, for the highest level. Or start at `specs/value_spec.rb` and work your way up the stack. There's also a `lib/micrograd/examples.rb` which be be run directly with `ruby lib/micrograd/examples.rb`.

## Contributing
No need. This was an educational exercise. :)

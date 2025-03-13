# Micrograd

This is an example implementation of a small neural network library in Ruby, with [automatic differentiation](https://en.wikipedia.org/wiki/Automatic_differentiation) and [backpropagation](https://en.wikipedia.org/wiki/Backpropagation). If you have no clue what that means, check out [this video series](https://www.youtube.com/watch?v=aircAruvnKk&list=PLZHQObOWTQDNU6R1_67000Dx_ZCJB-3pi), which explains Neural Networks and Deep Learning visually, without math.

I implemented this library by going through the YouTube lecture 
[“The spelled-out intro to neural networks and backpropagation: building micrograd”](https://www.youtube.com/watch?v=VMj-3S1tku0&list=PLAqhIrjkxbuWI23v9cThsA9GvCAUhRvKZ))
by Andrej Karpathy. It's the first in a series called "Neural Networks: From Zero to Hero", which builds up from the basic building blocks all the way to implementing GPT-2.

There's a canonical implementation of the functionality implemented in Python, available as [micrograd](https://github.com/karpathy/micrograd).

As I watched the video, I translated the Python code into Ruby.

I didn't reference the `micrograd` codebase at all, nor any of the other micrograd implementations [in Ruby](https://github.com/search?utf8=%E2%9C%93&q=micrograd+language%3ARuby+&type=repositories), nor in any other languages.

### Motivation
Why? Because I am learning neural networks & deep learning.
I know enough Python to have been able to write it in Python,
but (1) I didn't want to just write all the same code he wrote and (2) I learn best by adapting principles to a different language and taking a different approach.
I know Ruby best (and enjoy writing it the most), so it was the obvious choice.

## Approach
I implemented it in **idiomatic** Ruby:
* I didn't just copy the Python and adapt the syntax directly
* The backward method is called `Value#backward!`, since in Ruby we use that to signify that we're mutating the object in-place.

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
- [ ] Convert examples.rb to [bake script](https://github.com/ioquatix/bake)
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

If you're building anything real, you probably want to use [torch.rb](https://github.com/ankane/torch.rb), which is based on libtorch, the high-performance C++ library that PyTorch uses.

## Usage
Take a look at the specs and also `lib/micrograd/examples.rb` to see how to use this library.

You need to require the specific file you want to use. `require "micrograd"` doesn't do anything.

## Development
After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing
No need. This was an educational exercise. :)

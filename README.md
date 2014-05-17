NoFlo Component Tester [![Build Status](https://travis-ci.org/noflo/noflo-test.svg?branch=master)](https://travis-ci.org/noflo/noflo-test)
=====================

This library provides a fluent, chainable API for testing [NoFlo](http://noflojs.org) components in an easy manner. It is inspired by the [api-easy](http://flatiron.github.com/api-easy) library for testing RESTful APIs.

Most NoFlo components are designed to be reusable between different projects, and so having a good set of unit tests for them is vital.

## Installation

Add noflo-test into your component's development dependencies:

    "devDependencies": {
      "noflo-test": "0.0.x"
    }

Then run *npm install*.

## Writing tests

Here is an example test file against the NoFlo core component *SplitArray*:

    test = require 'noflo-test'

    test.component('SplitArray').
      describe('When receiving an array with two cells').
        send.data('in', ['foo', 'bar']).
        it('Should send each cell out as a separate package').
          receive.data('out', 'foo').
          receive.data('out', 'bar').
    export module

In a typical case, this is all you need to test a component!

## Test API

The noflo-test library exposes one method as the entry point:

**.component(ComponentName, [InstanceGetter])**

The first argument is the name of the component, which will also be the name of the generated test suite. In normal NoFlo libraries where components are registered in the package.json, this is all that is needed, as noflo-test will use NoFlo's ComponentLoader to load the component source code.

In case of custom setups you can also provide an optional second argument, which is a function that should return a new instance of a component on every invocation. Example:

    test.component 'MyCustomComponent', -> new MyCustomComponent

### Test suite methods

**suite.describe(description)**

Describe a scenario. NoFlo tests are usually provided in a structure where you first *describe* the environment, then provide input arguments, then discuss the desirable outputs using *it*, and then provide them.

**suite.it(predicate)**

Describe an expectation in the form, "it should..."

#### Input commands

Once you have described a scenario using the *describe* method, you can register a set of input commands to be sent. These will be stored into a queue and run in the order they were registered.

**suite.send.connect(port)**

Register a connection event for a given input port.

**suite.send.beginGroup(port, group)**

Register a new group bracket event to a given input port.

**suite.send.data(port, data)**

Register data to be sent to a given input port.

**suite.send.endGroup(port)**

Register an ending of group bracket to a given input port.

**suite.send.disconnect(port)**

Regiter a disconnection event for a given input port.

#### Output commands

Once you have set up the desired inputs for a scenario, you should use *it* to describe the desired output. Then you can register the output events you want to see happen:

**suite.receive.connect(port)**

Expect a *connect* message.

**suite.receive.beginGroup(port, data)**

Expect the beginning of a group. If `data` is a function it will be passed the received value and the instance of [Chai](http://chaijs.com/) used in the tests.

**suite.receive.data(port, data)**

Expect to receive matching data from the output port. If `data` is a function it will be passed the received value the instance of [Chai](http://chaijs.com/) used in the tests.

**suite.receive.endGroup(port)**

Expect a *endgroup* message.

**suite.receive.disconnect(port)**

Expect a *disconnect* message.

#### Ending a scenario

Using *describe* after *it* ends the current scenario so that you can start describing a new one from scratch. No data is shared between scenarios.

#### Exposing your tests

**suite.export(module)**

Expose the tests to the test runner.

## Running tests

There are many test frameworks for Node.js, each with their own way of being invoked. To make your library easier to work with for newcomers, it is a good idea to provide the *npm test* command with it. Add to the package.json:

    "scripts":    {
      "pretest": "./node_modules/.bin/coffeelint -r components",
      "test": "./bin/noflo-test test"
    }

Now running:

    $ npm test

Will first check your component sources for CoffeeScript coding standards compliance, and then run all the noflo-test component tests you have in your test directory.

### Travis integration

[Travis CI](https://travis-ci.org/) provides a free Continuous Integration environment for open source code hosted on GitHub. If that applies to the components you're writing, it is a good idea to enable Travis for your library.

To do so, login to the Travis website, and enable it for your repository. Then add the following file to the root of your repository:

    language: node_js
    node_js:
      - "0.10"
    script: npm test

Now each time you push your project to GitHub it will be automatically tested on Travis against various different Node.js versions (tune the version numbers in the file according to your needs).

Pull requests made for your repository will be tested automatically as well.

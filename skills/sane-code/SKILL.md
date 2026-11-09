---
name: sane-code
description: Use this when writing or reviewing code
---

# Sane Code

It's important that we structure application in a way that makes it easy to
reason about them and maintain them. Here are a few principles that should be
followed.

## Principles

### Unified data-flow

If we have some unified input stream, we never split it to recombine later.
We keep it the single stream. Let's say we have a stream of events and there
are mostly two kinds of events. We should create a single system that processes
these events. Splitting the stream into two streams per event handling each and merging afterwards
often creates subtle bugs in synchronization and we may need to create some elaborate scheme to
synchronize them.

We want:

```
input -> storage -> presentation
```

There should be no arrow between input and presentation

### Fragmentation is bad

Often we have things that just need to do a few steps. It's valuable to do them
in a single function in series as they are described, instead of splitting them
into many small function. We prefer one larger function that is easy to follow from
top to bottom, possibly adding one line comment for each section.

If we have some behavior the common code path should handle it.
We don't want two functions that kinda do the same thing but not quite.
The code should be changed such that those functions will naturally collapse
into one.

### Abstractions have to provide value

If we create an abstraction to do something, it should try to solve
all of the problems of that system. We don't force the caller to handle
internals of the abstraction. This can be judged by looking at the API of that
module and the internals of it. We should strive for a simple and performant
API while handling all the weirdness internally.

More layers of abstraction = bad
Better abstractions = good

**For example:**

A module for handling external file systems should deal with the mount point.
The caller wants to write to the device. It's wants to ask for a handle or a path
to that device and read/write from it. It doesn't want to care if the mount
path exists, possibly creating it etc. This should be handled by the
abstraction internally.

### Data transport

Often our system is split into two parts that need to communicate.
In an ideal world that communication channel is transparent -> it's as easy
as calling a function. REST API or similar things are bad for internal to internal
communication. We want to just take the things, serialize them, send them
and deserialize on the other end. If the app is supposed to be user facing
we can provide an API, but that needs stability guarantees and similar things,
so we can build that on top only if the product actually requires it.

### Unit testing

Make sure to only write valuable unit tests.
A test is more valuable if it's less likely to change over time.
A test is more valuable if more lines of code run during the execution of that test.

Testing a complex parser on example inputs is valuable.
Testing a 4 line parse function is not.

### There should be always one way of doing things

If we need to configure the application, we should have one configuration module.
If we have a module for doing something, it should be powerful enough to handle
the needs of every caller so that everyone can go through it.

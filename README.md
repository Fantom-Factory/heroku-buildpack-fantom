# Heroku Buildpack for Fantom
---
[![Made for: Fantom](http://img.shields.io/badge/made_for-Fantom-lightgray.svg)](http://fantom.org/)
![Licence: MIT](http://img.shields.io/badge/licence-MIT-blue.svg)

This is a [Heroku Buildpack][buildpack] for [Fantom][fantom]. 

Use this to run your `Fantom` application on the [Heroku][heroku] cloud application platform.

See [Fantom-Factory][fantom-factory-articles] for further articles on Fantom and Heroku.

Contents:

[TOC]

##Heroku Deployment

Steps to Heroku Fantom fulfillment:

1. Convert your Heroku application to use Fantom 
2. Create your Fantom environment
3. Create your (web) process
4. Git push your code



### 1. Convert your Heroku application to fantom

To run a Fantom application on Heroku you must first configure your heroku app to use this `buildpack`.

To convert an existing Heroku app to use Fantom, type:

```
#!bash
C:\> heroku config:set BUILDPACK_URL=https://bitbucket.org/AlienFactory/heroku-buildpack-fantom.git -a <myapp>
```

To create a new Heroku app that uses Fantom, type:

```
#!bash
C:\> heroku create <myapp> --buildpack https://bitbucket.org/AlienFactory/heroku-buildpack-fantom.git
```

See [Using A Custom Buildpack][custom-buildpack] for more details.

As long as you have `build.fan` in the root of your application directory, Heroku will recognise your app as a fantom app.



### 2. Create your Fantom environment

When this buildpack runs it downloads a fresh copy of Fantom (v1.0.67 at time of writing) and installs it in the directory `/app/.fan/`. 

The buildpack then compiles your application from source by running the following 2 commands:

```
#!bash
C:\> fan build.fan herokuPreCompile

C:\> fan build.fan compile
```

Because the Fantom installation is a fresh one, before your source can compile, it needs to download and install all external pods dependencies (such as the most excellent [afIoc][afIoc]) into your Fantom environment. This is what the (optional) `herokuPreComile` build target is for.

Note that the `compile` build target is customisable.



### 3. Create your web process

For Heroku to launch your application, it requires a file called `Procfile` in the root of your project dir:

```
#!bash
|-fan/
|  |...
|-build.fan
`-Procfile
```

`Procfile` contains the command Heroku should run, prefixed with the type of task. The simplest (and most common) `Procfile` is just:

```
#!bash
web: fan <yourPod> $PORT
```

Which calls `<yourPod>::Main.main(Str[] args)` passing in the port number your web app should listen on. Make sure this class and method exists to successfully launch your application.

If `Procfile` does not exist then Fantom buildpack will create one for you, containing the line mentioned above. See [Procfile][procfile] for more details.



### 4. Git push your code

To deploy and run your application on Heroku, simply `git push` your code as normal and hopefully you should see something like this:

```
#!bash

C:\> git push heroku master

-----> Fetching set buildpack... done
-----> Fantom app detected

-----> Reading file 'heroku.props'...
-----> Java version        : 1.6
-----> Fantom version      : 1.0.67
-----> Fantom download URL : https://xxx/fantom-1.0.67.zip
-----> Fantom build target : compile

-----> Creating file 'system.properties' for use by JVM Buildpack... done
-----> Installing OpenJDK 1.6... done
-----> Downloading http://xxx/fantom-1.0.67.zip ... done
-----> Installing Fantom 1.0.67... done

       Fantom Launcher
       Copyright (c) 2006-2013, Brian Frank and Andy Frank
       Licensed under the Academic Free License version 3.0

       Java Runtime:
         java.version:    1.6.0_27
         java.vm.name:    OpenJDK 64-Bit Server VM
         java.vm.vendor:  Sun Microsystems Inc.
         java.vm.version: 20.0-b12
         java.home:       /tmp/build/.jdk/jre
         fan.platform:    linux-x86_64
         fan.version:     1.0.67
         fan.env:         sys::BootEnv
         fan.home:        /app/tmp/repo.git/.cache/fantom-1.0.67

-----> Calling Build Target: herokuPreCompile...
-----> Calling Build Target: compile...
       compile [<myapp>]
         Compile [<myapp>]
           FindSourceFiles [18 files]
             WritePod [file:/tmp/build/.fan/lib/fan/<myapp>.pod]
       BUILD SUCCESS [100ms]!
-----> Creating Procfile...
       web: fan <myapp> $PORT
-----> Discovering process types
       Procfile declares types -> web

-----> Compiled slug size: 60.4MB
-----> Launching... done, v69
       http://<myapp>.herokuapp.com deployed to Heroku
```



## Installing Fantom pods

More than likely, your application has dependencies on external Fantom pods such as [BedSheet][afBedSheet] and [IoC][afIoc]. These pods need to be installed by the `herokuPreCompile()` build task. The easiest means of doing so, is by programmatically calling `fanr`.



### From a local repository

You can install pods from a local `fanr` repository as long as it is checked into your Heroku Git repository. For example, if your project had the following directory structure:

```
#!bash
|-fan/
|  |...
|-lib-fanr/
|  `-afBedSheet/
|     `-afBedSheet-1.5.x.pod
`-build.fan
```

You could install [BedSheet][afBedSheet] like this:

```
#!java
@Target { help = "Heroku pre-compile hook, use to install dependencies" }
Void herokuPreCompile() {

    // install pods from a local fanr repository
    fanr("install -y -r file:lib-fanr/ afBedSheet")
}

private Void fanr(Str args) {
    fanr::Main().main(args.split)
}
```

This is useful when you're using pods developed by yourself, or ones that are not publicly available.



### From a remote repository

Most external pods are available publicly, usually from the [Eggbox Repository][eggbox-repo]. Here is a modified script that downloads and installs pods from there:

```
#!java
@Target { help = "Heroku pre-compile hook, use to install dependencies" }
Void herokuPreCompile() {

    // install pods from a remote fanr repository
    fanr("install -y -r http://pods.fantomfactory.org/fanr/ afIoc")
}

private Void fanr(Str args) {
    fanr::Main().main(args.split)
}
```



### Example Script

If *ALL* your dependant pods are available from the same repository (probably [Eggbox][eggbox-repo]), then here is a useful script that installs everything for you:

```
#!java
@Target { help = "Heroku pre-compile hook, use to install dependencies" }
Void herokuPreCompile() {

    // find all non-installed dependant pods
    pods := depends.findAll |Str dep->Bool| {
        depend := Depend(dep)
        pod := Pod.find(depend.name, false)
        return (pod == null) ? true : !depend.match(pod.version)
    }
    installFromRepo(pods, "http://pods.fantomfactory.org/fanr/") // repo = "file:lib/fanr/"
}

private Void installFromRepo(Str[] pods, Str repo) {
    if (pods.isEmpty) return
    cmd := "install -errTrace -y -r ${repo}".split.add(pods.join(","))
    log.info("")
    log.info("Installing pods...")
    log.info("> fanr " + cmd.join(" ") { it.containsChar(' ') ? "\"$it\"" : it })
    status := fanr::Main().main(cmd)
    // abort build if something went wrong
    if (status != 0) Env.cur.exit(status)
}
```

Output from a successful install should look like:

```
#!bash

Installing pods...
> fanr install -errTrace -y -r http://pods.fantomfactory.org/fanr/ "..."

afBedSheet         [install]  not-installed => 1.3.4
afIoc              [install]  not-installed => 1.5.4
afIocConfig        [install]  not-installed => 1.0.4
afIocEnv           [install]  not-installed => 1.0.2.1
afPlastic          [install]  not-installed => 1.0.10

Downloading afIocConfig ... Complete
Downloading afIoc ... Complete
Downloading afIocEnv ... Complete
Downloading afPlastic ... Complete
Downloading afBedSheet ... Complete

Download successful (5 pods)

Installing afIocConfig ... Complete
Installing afIoc ... Complete
Installing afIocEnv ... Complete
Installing afPlastic ... Complete
Installing afBedSheet ... Complete

Installation successful (5 pods)
```



## Installing Java libraries

Sometimes you have a dependency on a Java library. To install these, again make sure they are checked into your Heroku Git repository. Assuming the jars are in the following directory structure:

```
#!bash
|-fan/
|  |...
|-lib-java/
|  `-wotever-1.7.2.jar
`-build.fan
```

You can install them like this:

```
#!java
@Target { help = "Heroku pre-compile hook, use to install dependencies" }
Void herokuPreCompile() {
   
    // install jar files from local
    installJar(`lib/java/wotever-1.7.2.jar`)
}

private Void installJar(Uri jarFile) {
    (scriptDir + jarFile).copyInto(Env.cur.homeDir + `lib/java/ext/`, ["overwrite" : true])		
}
```



## Customising the Buildpack

The buildpack can be customised by placing a `heroku.props` file in the root of your project, next to your `build.fan`:

```
#!bash
|-fan/
|  |...
|-build.fan
`-heroku.props
```

A sample `heroku.props` file looks like:

```
java.runtime.version=1.6
fantom.version=1.0.67
fantom.downloadUrl=http://example.com/fantom-custom.zip
fantom.buildTarget=compile
```

Note that (due to bash script restrictions) you **must** have a trailing new line `\n` character on the last line of `heroku.props`.



### Java Version

By default this buildpack installs *OpenJDK 1.6*, should you wish to install a different version then edit `heroku.props`:

```
java.runtime.version=1.8
```

At the time of writing the following Java versions are supported:

* 1.8
* 1.7
* 1.6

For more details about setting the Java version, see [Choose a JDK](https://github.com/heroku/heroku-buildpack-java#choose-a-jdk). You could also download the [Java Common Buildpack](http://heroku-jvm-common.s3.amazonaws.com/jvm-buildpack-common.tar.gz) and inspect the `bin/java` script.

Note that this buildpack also creates a file called `system.properties` that is used by the Java Buildpack. So if you create such a file, it *will be overwritten!*



### Fantom Version

By default this buildpack installs *Fantom 1.0.67*, should you wish to install a different version then edit `heroku.props`:

```
fantom.version=1.0.68
```

At the time of writing the following Fantom versions are supported:

* 1.0.68
* 1.0.67
* 1.0.66
* 1.0.65

You may also specify an alternative download location for Fantom:

```
fantom.version=1.0.67
fantom.downloadUrl=http://example.com/fantom-custom.zip
```

Note that if you specify `fantom.downloadUrl` you must also specify `fantom.version`.



### Custom Build Target

To call a custom build target called on `build.fan`, edit `heroku.props`:

```
fantom.buildTarget=herokuCompile
```



## Licence

Licensed under the MIT Licence. See `licence.txt` for details.



Have fun!

[fantom]: http://fantom.org/
[heroku]: http://www.heroku.com/
[buildpack]: http://devcenter.heroku.com/articles/buildpacks
[custom-buildpack]: https://devcenter.heroku.com/articles/third-party-buildpacks#using-a-custom-buildpack
[procfile]: https://devcenter.heroku.com/articles/procfile
[afBedSheet]: http://pods.fantomfactory.org/pods/afBedSheet
[afIoc]: http://pods.fantomfactory.org/pods/afIoc
[fantom-factory-articles]: http://www.fantomfactory.org/tags/heroku
[eggbox-repo]: http://pods.fantomfactory.org/
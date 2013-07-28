# Heroku Buildpack: Fantom

This is a [Heroku Buildpack][buildpack] for [Fantom][fantom]. 

Use this to run your `Fantom` app on the [Heroku][heroku] cloud application platform.

Steps to Heroku Fantom fulfilment:

1. Convert your Heroku application to use Fantom 
2. Create your Fantom environment
3. Create your web process
4. Git push your code



## 1. Convert your Heroku application to fantom

To run a Fantom application on Heroku you must first configure your heroku app to use this `buildpack`.

To convert an existing Heroku app to use Fantom, type:

```
#!bash
$ heroku config:set BUILDPACK_URL=https://bitbucket.org/SlimerDude/heroku-buildpack-fantom.git -a myapp
```

To create a new Heroku app that uses Fantom, type:

```
#!bash
$ heroku create myapp --buildpack https://bitbucket.org/SlimerDude/heroku-buildpack-fantom.git
```

See [Using A Custom Buildpack][custom-buildpack] for more details.

As long as you have `build.fan` in the root of your application directory, Heroku will recognise your app as a fantom app.



## 2. Create your Fantom environment

When this buildpack runs it downloads a fresh copy of Fantom (currently 1.0.65) and installs it in the directory `/app/.fan/`. 

The buildpack then compiles your application from source by running the following 2 commands:

```
#!bash
$ fan build.fan herokuPreComile

$ fan build.fan compile
```

Because the Fantom installation is a fresh one, before your source can comple, you need to download and install any external dependencies (such as the most excellent [afIoc][afIoc]) into your Fantom environment. This is what the (optional) `herokuPreComile` build target is for.

An exert from a sample `build.fan`:

```
#!fantom
@Target { help = "Heroku pre-compile hook, use to install dependencies" }
Void herokuPreCompile() {
    
    // install pods from a remote fanr repository
    fanr("install -y -r http://repo.status302.com/fanr/ afIoc")

    // install pods from a local fanr repository
    fanr("install -y -r file:lib/fanr/ afBedSheet")
    
    // install jar files from local
    installJar(`lib/java/wotever-1.7.2.jar`)
}

private Void fanr(Str args) {
    fanr::Main().main(args.split)
}

private Void installJar(Uri jarFile) {
    (scriptDir + jarFile).copyInto(devHomeDir + `lib/java/ext/`, ["overwrite" : true])		
}
```

The above example assumes the following project dir structure:

```
#!bash
|-fan/
|  |...
|-lib/
|  |-java/
|  |  |-wotever-1.7.2.jar`
|  |-fanr/
|    |-afBedSheet/
|       |-afBedSheet-1.0.x.pod
|-build.fan
|-Procfile
```

Note that the `lib` dir (with the jars and local fanr repository) needs to be checked in the Heroku Git repository.



## 3. Create your web process

For Heroku to launch your application, it requires a file called `Procfile` in the root of your project dir that contains the command it should run. The simplest (and most common) command is just:

```
#!bash
web: fan <yourPod> $PORT
```

Which calls `yourPod::Main.main(Str[] args)` passing in the port number your web app should listen on.

If `Procfile` does not exist then Fantom buildpack will create one for you, containing the line mentioned above. See [Procfile][procfile] for more details.



## 4. Git push your code

To deploy and run your app on Heroku, simply `git push` your code as normal and hopefully you should see something like this:

```
#!bash

$ git push heroku master

...

-----> Fetching custom git buildpack... done
-----> Fantom app detected
-----> Installing OpenJDK 1.6... done
-----> Downloading http://fan.googlecode.com/files/fantom-1.0.65.zip ... done
-----> Installing Fantom 1.0.65... done

       Fantom Launcher
       Copyright (c) 2006-2012, Brian Frank and Andy Frank
       Licensed under the Academic Free License version 3.0

       Java Runtime:
         java.version:    1.6.0_27
         java.vm.name:    OpenJDK 64-Bit Server VM
         java.vm.vendor:  Sun Microsystems Inc.
         java.vm.version: 20.0-b12
         java.home:       /tmp/build/.jdk/jre
         fan.platform:    linux-x86_64
         fan.version:     1.0.65
         fan.env:         sys::BootEnv
         fan.home:        /app/tmp/repo.git/.cache/fantom-1.0.65

-----> Calling Build Target: herokuPreCompile...
       afIoc  [install]  not-installed => 1.3.10
       Downloading afIoc ... Complete
       Download successful (1 pods)
       Installing afIoc ... Complete
       Installation successful (1 pods)
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

Have fun!

[fantom]: http://fantom.org/
[heroku]: http://www.heroku.com/
[buildpack]: http://devcenter.heroku.com/articles/buildpacks
[custom-buildpack]: https://devcenter.heroku.com/articles/third-party-buildpacks#using-a-custom-buildpack
[procfile]: https://devcenter.heroku.com/articles/procfile
[afIoc]: http://repo.status302.com/doc/afIoc/#overview

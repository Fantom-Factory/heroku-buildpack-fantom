# Heroku Buildpack: Fantom

This is a [Heroku Buildpack][buildpack] for [Fantom][fantom]. 

Use this to run your `fantom` app on the [Heroku][heroku] cloud application platform.

Steps to Heroku fantom fulfilment:

1. Convert your Heroku application to fantom 
2. Create your fantom environment
3. Create your web process
4. Git push your code


## 1. Convert your Heroku application to fantom

To run a fantom application on Heroku you must first configure your heroku app to use this `buildpack`.

To convert an existing app to use fantom, type:

```
#!bash
$ heroku config:set BUILDPACK_URL=https://bitbucket.org/SlimerDude/heroku-buildpack-fantom.git -a myapp
```

To create a new app that uses fantom, type:

```
#!bash
$ heroku create myapp --buildpack https://bitbucket.org/SlimerDude/heroku-buildpack-fantom.git
```

See [Using A Custom Buildpack][custom-buildpack] for more details.

As long as you have a `build.fan` in the root of your application, Heroku will recognise your app as a fantom app.


## 2. Create your fantom environment

When this buildpack kicks off it downloads a fresh copy of fantom (currently 1.0.63) and installs it in the directory `/app/.fan/`. 

Before the buildpack can compile your fantom pod, you have to download any external dependencies (such as the most excellent [afIoc][afIoc]). Do this by adding a `herokuPreComile` build target to your `build.fan`.

Here's a sample exert from a `build.fan`:

```
#!fantom
@Target { help = "Heroku pre-compile hook, use to install dependencies" }
Void herokuPreCompile() {
    
    // install pods from a remote fan repository
    fanr("install -y -r http://repo.status302.com/fanr/ afIoc")

    // install pods from a local fan repository
    fanr("install -y -r file:localRepo/ afDraft")
    
    // install jar files from local
    installJar(`lib/java/jsoup-1.7.2.jar`)
}

private Void fanr(Str args) {
    fanr::Main().main(args.split)
}

private Void installJar(Uri jarFile) {
    (scriptDir + jarFile).copyInto(devHomeDir + `lib/java/ext/`, ["overwrite" : true])		
}
```


## 3. Create your web process

For Heroku to launch your application, create a file called `Procfile` in the root of your application. This contains the command it should run. The simplest (and most common) command is just:

```
#!bash
web: fan <yourPod> $PORT
```

Which calls `yourPod::Main.main(Str[] args)` passing in the port number your app should listen on.

In fact, this step is optional. If you don't create a `Procfile`, the fantom buildpack will create one for you - which looks just the one above!

See [Procfile][procfile] for more details.


## 4. Git push your code

To deploy and run your app on heroku, simply `git push` your code as normal and hopefully you should see something like this:

```
#!bash

$ git push heroku master

...

-----> Fetching custom git buildpack... done
-----> Fantom app detected
-----> Installing OpenJDK 1.6... done
-----> Downloading http://fan.googlecode.com/files/fantom-1.0.63.zip ... done
-----> Installing Fantom 1.0.63... done

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
         fan.version:     1.0.63
         fan.env:         sys::BootEnv
         fan.home:        /app/tmp/repo.git/.cache/fantom-1.0.63

-----> Calling Build Target: herokuPreCompile...
       afIoc  [install]  not-installed => 1.2.2
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
       web: fan afPlagueScanner $PORT
-----> Discovering process types
       Procfile declares types -> web

-----> Compiled slug size: 60.4MB
-----> Launching... done, v69
       http://<myapp>.herokuapp.com deployed to Heroku
```

[fantom]: http://fantom.org/
[heroku]: http://www.heroku.com/
[buildpack]: http://devcenter.heroku.com/articles/buildpacks
[custom-buildpack]: https://devcenter.heroku.com/articles/third-party-buildpacks#using-a-custom-buildpack
[procfile]: https://devcenter.heroku.com/articles/procfile
[afIoc]: http://repo.status302.com/doc/afIoc/#overview
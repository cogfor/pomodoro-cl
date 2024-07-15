# A pomodoro command-line app written in Common Lisp

This is a small project to learn Common Lisp and create something useful at the same time. The aim is a command-line app that allows the user to track time in the Pomodoro fashion. In addition, there will be some reporting functionality. 

## Limitations

* Mac Only for now

## Requirements

* QuickLisp installed with `cl-ppcre`, `local-time`, and `usocket` installed.

## Usage

### Running from REPL

Load the file and use the provided functions:

```lisp
Copy code
(load "path/to/pomodoro.lisp")

;; Start a pomodoro session
(pomodoro:start-pomodoro "programming" "writing a pomodoro app")

;; Generate a daily report
(pomodoro:generate-report :daily)

;; Add, list, and delete topics
(pomodoro:manage-topics 'add "programming")
(pomodoro:manage-topics 'list)
(pomodoro:manage-topics 'delete "programming")
```

### Running from the Command Line

You can execute the application with various commands:

```shell
sbcl --script path/to/pomodoro.lisp start topic=programming description="writing a pomodoro app" duration=25
sbcl --script path/to/pomodoro.lisp report period=daily
sbcl --script path/to/pomodoro.lisp topic command=add name="programming"
sbcl --script path/to/pomodoro.lisp topic command=list
sbcl --script path/to/pomodoro.lisp topic command=delete name="programming"
```

## TODO

* Extend the support of `topics`. These should stored in the database for re-use.
* Expand reporting; make this a bit more visual
* Expand command-line options 
* Add a short intro on the usage of the pomodoro way of working
* Make a compiled version; create Github actions to compile
* Add unit tests
 

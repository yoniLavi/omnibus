;;
;; Author:: Adam Jacob (<adam@opscode.com>)
;; Author:: Christopher Brown (<cb@opscode.com>)
;; Copyright:: Copyright (c) 2010 Opscode, Inc.
;; License:: Apache License, Version 2.0
;;
;; Licensed under the Apache License, Version 2.0 (the "License");
;; you may not use this file except in compliance with the License.
;; You may obtain a copy of the License at
;;
;;     http://www.apache.org/licenses/LICENSE-2.0
;;
;; Unless required by applicable law or agreed to in writing, software
;; distributed under the License is distributed on an "AS IS" BASIS,
;; WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
;; See the License for the specific language governing permissions and
;; limitations under the License.
;;

(ns omnibus.util
  (:use (omnibus (log :only [log-sh-result]))
        (clojure.java (shell :only [sh])))
  (:import (java.io File))
  (:gen-class))

;; pulled in from clojure.contrib.io/file-str
(defn ^java.io.File file-str
  "Concatenates args as strings and returns a java.io.File.  Replaces
  all / and \\ with File/separatorChar.  Replaces ~ at the start of
  the path with the user.home system property."
  [& args]
  (let [^String s (apply str args)
        s (.replace s \\ File/separatorChar)
        s (.replace s \/ File/separatorChar)
        s (if (.startsWith s "~")
            (str (System/getProperty "user.home")
                 File/separator (subs s 1))
            s)]
    (File. s)))

(defn- copy-source-to-build
  "Copy the source directory to the build directory"
  [build-root source-root soft]
  (when-let [src (soft :source)]
    (let [status (sh "cp" "-R" (.getPath (file-str source-root "/" src)) (.getPath build-root))]
      (log-sh-result status
                     (str "Copied " src " to build directory.")
                     (str "Failed to copy " src " to build directory.")))))

(defn clean
  "Clean a previous build directory"
  [build-root soft]
  (when-let [src (soft :source)]
    (let [status (sh "rm" "-rf" (.getPath (file-str build-root "/" src)) )]
      (log-sh-result status
                     (str "Removed old build directory for " src)
                     (str "Failed to remove old build directory for " src)))))

(defn prep
  "Prepare to build a software package by copying its source to a pristine build directory"
  [build-root source-root soft]
  (when (soft :source)
    (do
      (.mkdirs build-root)
      (copy-source-to-build build-root source-root soft))))

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

(software "openssl" :source "openssl-0.9.8o"
                    :steps [
                            (cond
                             (and (is-os? "darwin") (is-machine? "x86_64"))
                              {
                               :command "./Configure"
                               :args ["darwin64-x86_64-cc"
                                      "--prefix=/opt/chef/embedded"
                                      "--with-zlib-lib=/opt/chef/embedded/lib"
                                      "--with-zlib-include=/opt/chef/embedded/include"
                                      "zlib"
                                      "shared"]
                               }
                              (is-os? "solaris2")
                              {
                                :command "./Configure"
                                :args ["solaris-x86-gcc"
                                       "--prefix=/opt/chef/embedded"
                                       "--with-zlib-lib=/opt/chef/embedded/lib"
                                       "--with-zlib-include=/opt/chef/embedded/include"
                                       "zlib"
                                       "shared"
                                       "-L/opt/chef/embedded/lib"
                                       "-I/opt/chef/embedded/include"
                                       "-R/opt/chef/embedded/lib"]
                               }
                              true
                              {
                                :env {"LD_RUN_PATH" "/opt/chef/embedded/lib"}
                                :command "./config"
                                :args ["--prefix=/opt/chef/embedded"
                                       "--with-zlib-lib=/opt/chef/embedded/lib"
                                       "--with-zlib-include=/opt/chef/embedded/include"
                                       "zlib"
                                       "shared"
                                       "-L/opt/chef/embedded/lib"
                                       "-I/opt/chef/embedded/include"]
                               })
                            {
                             :env {"LD_RUN_PATH" "/opt/chef/embedded/lib"}
                             :command "make"
                             }
                            {
                             :command "make"
                             :args ["install"]
                             }])


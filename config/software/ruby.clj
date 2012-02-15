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

(let [env
      (cond
       (and (is-os? "darwin") (is-machine? "x86_64"))
       { "CFLAGS" "-arch x86_64 -m64 -L/opt/chef/embedded/lib -I/opt/chef/embedded/include"
         "LDFLAGS" "-arch x86_64 -R/opt/chef/embedded/lib -L/opt/chef/embedded/lib -I/opt/chef/embedded/include"}
       (is-os? "linux")
       { "CFLAGS" "-L/opt/chef/embedded/lib -I/opt/chef/embedded/include"
         "LDFLAGS" "-Wl,-rpath /opt/chef/embedded/lib -L/opt/chef/embedded/lib -I/opt/chef/embedded/include"}
       (is-os? "solaris2")
       { "CFLAGS" "-L/opt/chef/embedded/lib -I/opt/chef/embedded/include"
         "LDFLAGS" "-R/opt/chef/embedded/lib -L/opt/chef/embedded/lib -I/opt/chef/embedded/include"}
       )
      ]
  (software "ruby"
            :source "ruby-1.9.2-p180"
            :steps [
                    {:env env
                     :command "/opt/chef/embedded/bin/autoconf"
                     }
                    {:env env
                     :command "./configure"
                     :args ["--prefix=/opt/chef/embedded"
                            "--with-opt-dir=/opt/chef/embedded"
                            "--enable-shared"
                            "--disable-install-doc"]}
                    {:env env :command "make"}
                    {:command "make" :args ["install"]}]))

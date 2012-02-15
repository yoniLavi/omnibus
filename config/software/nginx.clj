;;
;; Author:: Adam Jacob (<adam@opscode.com>)
;; Copyright:: Copyright (c) 2011 Opscode, Inc.
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

(software "nginx" :source "nginx-1.0.10"
          :steps [
                  {:command "./configure"
                   :args ["--prefix=/opt/chef/embedded"
                          "--with-http_ssl_module",
                          "--with-ld-opt=-L/opt/chef/embedded/lib"
                          "--with-cc-opt=-L/opt/chef/embedded/lib -I/opt/chef/embedded/include"
                          ]}
                  {:command "make" :env { "LD_RUN_PATH" "/opt/chef/embedded/lib" }}
                  {:command "make" :args ["install"]}
                  ])




(ns omnibus.test.core
  (:use omnibus.core :reload-all)
  (:use clojure.test))

(let [base-project {:project-name "UberChef"
                      :version 123
                      :iteration 666
                      :os-data {:platform "ubuntu"
                                :platform_version "10.04"
                                :machine "x86_64"}}]
  (deftest correct-asset-names
    (are [type project name] (= (asset-name type project) name)
         :omnibus.core/rpm base-project "UberChef-123-666.x86_64.rpm"
         :omnibus.core/deb base-project "UberChef_123-666_amd64.deb"
         :omnibus.core/deb (assoc-in base-project [:os-data :machine] "FUUUUUUUUU") "UberChef_123-666_i386.deb"
         :omnibus.core/tarball base-project "UberChef-123-666-ubuntu-10.04-x86_64.tar.gz"
         :omnibus.core/makeself base-project "UberChef-123-666-ubuntu-10.04-x86_64.sh"))

  (deftest correct-asset-paths
    (with-bindings {#'OMNIBUS-PKG-DIR "my_package_dir"}
      (are [type project name] (= (asset-path type project) name)
           :omnibus.core/rpm base-project "my_package_dir/UberChef-123-666.x86_64.rpm"
           :omnibus.core/deb base-project "my_package_dir/UberChef_123-666_amd64.deb"
           :omnibus.core/deb (assoc-in base-project [:os-data :machine] "FUUUUUUUUU") "my_package_dir/UberChef_123-666_i386.deb"
           :omnibus.core/tarball base-project "my_package_dir/UberChef-123-666-ubuntu-10.04-x86_64.tar.gz"
           :omnibus.core/makeself base-project "my_package_dir/UberChef-123-666-ubuntu-10.04-x86_64.sh")))

  (deftest correct-cli
    (with-bindings {#'OMNIBUS-SOURCE-DIR "my_src_dir"
                    #'OMNIBUS-PKG-DIR "my_package_dir"
                    #'OMNIBUS-MAKESELF-DIR "my_makeself_dir"
                    #'OMNIBUS-HOME-DIR "my_home_dir"}
      (are [type project cli] (= (command-line type project) cli)
           :omnibus.core/rpm base-project ["fpm" "-s" "dir" "-t" "rpm" "-v" 123
                                           "--iteration" 666 " -n" "UberChef" "/opt/opscode" "-m" "Opscode, Inc."
                                           "--post-install" "my_src_dir/postinst" "--post-uninstall" "my_src_dir/postrm"
                                           "--description" "The full stack install of Opscode Chef"
                                           "--url" "http://www.opscode.com" :dir "./pkg"]
           :omnibus.core/deb base-project ["fpm" "-s" "dir" "-t" "deb" "-v" 123
                                           "--iteration" 666 " -n" "UberChef" "/opt/opscode" "-m" "Opscode, Inc."
                                           "--post-install" "my_src_dir/postinst" "--post-uninstall" "my_src_dir/postrm"
                                           "--description" "The full stack install of Opscode Chef"
                                           "--url" "http://www.opscode.com" :dir "./pkg"]
           :omnibus.core/tarball base-project ["tar" "czf" "my_package_dir/UberChef-123-666-ubuntu-10.04-x86_64.tar.gz"
                                               "opscode" :dir "/opt"]
           :omnibus.core/makeself base-project ["my_makeself_dir/makeself.sh" "--gzip" "/opt/opscode"
                                                "my_package_dir/UberChef-123-666-ubuntu-10.04-x86_64.sh" "'Opscode UberChef 123'"
                                                "./setup.sh" :dir "my_home_dir"]))))

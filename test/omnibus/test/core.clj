(ns omnibus.test.core
  (:use omnibus.core :reload-all)
  (:use clojure.test))

(deftest correct-asset-names
  (let [base-project {:project-name "UberChef"
                      :version 123
                      :iteration 666
                      :os-data {:platform "ubuntu"
                                :platform_version "10.04"
                                :machine "x86_64"}}]
    (are [type project name] (= (asset-name type project) name)
         :omnibus.core/rpm base-project "UberChef-123-666.x86_64.rpm"
         :omnibus.core/deb base-project "UberChef_123-666_amd64.deb"
         :omnibus.core/deb (assoc-in base-project [:os-data :machine] "FUUUUUUUUU") "UberChef_123-666_i386.deb"
         :omnibus.core/tarball base-project "UberChef-123-666-ubuntu-10.04-x86_64.tar.gz"
         :omnibus.core/makeself base-project "UberChef-123-666-ubuntu-10.04-x86_64.sh")))

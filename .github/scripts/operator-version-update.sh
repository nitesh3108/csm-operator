#!/bin/bash

# Copyright 2025 DELL Inc. or its subsidiaries.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

echo "INSIDE BASH SCRIPT"

op_version="$1"
op_skip_version="$2"
op_ver_fmt="  version: ${op_version:1}"
op_version_v="${op_version:1}"
csm_ver_v="$3"
csm_ver_wv="${csm_ver_v:1}"


echo "Latest version -->> $op_version"
echo "Existing version -->> $op_skip_version"
echo "CSM Version -->> $csm_ver_v"

echo "part-1"
pwd

        # part-1
        sed -i "s/release=\"[^\"]*\"/release=\"${csm_ver_wv}\"/g" Dockerfile
        sed -i "s/version=\"[^\"]*\"/version=\"${op_version_v}\"/g" Dockerfile
        echo "Done updating Dockerfile"

echo "part-2"
pwd

        # part-2
        k_file="kustomization.yaml"
        for k_dir in {'config/install/','config/manager/'}; do
        cd "$GITHUB_WORKSPACE/$k_dir"
        sed -i "s/newTag: .*/newTag: ${op_version}/" $k_file
        done
        echo "Done updating kustomization.yaml"

echo "part-3"
pwd

        cd "$GITHUB_WORKSPACE"
        # part-3: update CSMVersion
        sed -i "s/CSMVersion = .*/CSMVersion = \"${csm_ver_v}\"/g" controllers/csm_controller.go
        echo "Done updating CSMVersion"

echo "part-4"
pwd
        # part-4
        sed -i "s/dell-csm-operator:.*/dell-csm-operator:${op_version}/g" deploy/olm/operator_community.yaml
        sed -i "s/dell-csm-operator:.*/dell-csm-operator:${op_version}/g" deploy/operator.yaml
        sed -i "s/CSMVersion: .*/CSMVersion: ${csm_ver_v}/g" deploy/operator.yaml
        echo "Done updating operator.yaml"

echo "part-5"
pwd
        # part-5
        d_file="docker.mk"
        sed -i "s/VERSION ?=.*/VERSION ?= ${op_version}/g" $d_file
        sed -i "s/BUNDLE_VERSION ?=.*/BUNDLE_VERSION ?= ${op_version_v}/g" $d_file
        sed -i "s/e.g. - .*/e.g. - ${op_version}.001/g" $d_file
        sed -i "s/example.com\/operator-catalog:.*/example.com\/operator-catalog:${op_version})./g" $d_file
        echo "Done updating docker.mk"

echo "part-6"
pwd
        # part-6
        file="dell-csm-operator.clusterserviceversion.yaml"
        for i_dir in {'bundle/manifests/','config/manifests/bases/'}; do
            cd "$GITHUB_WORKSPACE/$i_dir"
            sed -i "s/dell-csm-operator:.*/dell-csm-operator:${op_version}/g" $file
            sed -i "s/name: dell-csm-operator.v.*/name: dell-csm-operator.${op_version}/g" $file
            sed -i "s/- dell-csm-operator.v.*/- dell-csm-operator.${op_skip_version}/g" $file
            awk -v var="$op_ver_fmt" '/skips/{ n=NR+2 } NR==n{$0=var }1' $file > $file.tmp
            mv -f $file.tmp $file
            rm -f $file.tmp
        done
        echo "OPERATOR VERSION UPDATED SUCCESSFULLY"

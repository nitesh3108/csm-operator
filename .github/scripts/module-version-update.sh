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

# Reading actual release version from csm repository
obs_ver="$KARAVI_OBSERVABILITY"
auth_v2="$CSM_AUTHORIZATION_V2"
rep_ver="$CSM_REPLICATION"
res_ver="$KARAVI_RESILIENCY"
revproxy_ver="$CSIREVERSEPROXY"
csm_ver="$CSM_VERSION"
pscale_matrics="$CSM_METRICS_POWERSCALE"
pflex_matrics="$KARAVI_METRICS_POWERFLEX"
pmax_matrics="$CSM_METRICS_POWERMAX"
topology="$KARAVI_TOPOLOGY"
otel_col="$OTEL_COLLECTOR"
pscale_driver_ver="$CSI_POWERSCALE"
pstore_driver_ver="$CSI_POWERSTORE"
pmax_driver_ver="$CSI_POWERMAX"
pflex_driver_ver="$CSI_VXFLEXOS"

dell_csi_replicator="$CSM_REPLICATION"
dell_replication_controller="$CSM_REPLICATION"

pscale_driver_ver=${pscale_driver_ver//./}
pstore_driver_ver=${pstore_driver_ver//./}
pmax_driver_ver=${pmax_driver_ver//./}
pflex_driver_ver=${pflex_driver_ver//./}

auth_v2_samples_format=${auth_v2//./}

input_csm_ver="$1"
update_flag="$2"

# Step-1:- <<<< Updating observability module version >>>>
if [ -n $obs_ver ]; then
      cd $GITHUB_WORKSPACE/operatorconfig/moduleconfig/observability
      echo "module path"
      pwd
      if [ -d $obs_ver ]; then
          if [[ "$update_flag" == "tag" ]]; then
             echo "Observability --> update flag received is --> tag"
             echo "Updating tags for Observability module"
             # Updating tags to latest observability module config
             cd $GITHUB_WORKSPACE/operatorconfig/moduleconfig/observability/$obs_ver
             sed -i "s|quay.io/dell/container-storage-modules/csm-metrics-powerflex.*|quay.io/dell/container-storage-modules/csm-metrics-powerflex:${pflex_matrics}|g" karavi-metrics-powerflex.yaml
             sed -i "s|quay.io/dell/container-storage-modules/csm-metrics-powermax.*|quay.io/dell/container-storage-modules/csm-metrics-powermax:${pmax_matrics}|g" karavi-metrics-powermax.yaml
             sed -i "s|quay.io/dell/container-storage-modules/csm-metrics-powerscale.*|quay.io/dell/container-storage-modules/csm-metrics-powerscale:${pscale_matrics}|g" karavi-metrics-powerscale.yaml
             sed -i "s|quay.io/dell/container-storage-modules/csm-topology.*|quay.io/dell/container-storage-modules/csm-topology:${topology}|g" karavi-topology.yaml

             cd $GITHUB_WORKSPACE/pkg/modules
             if [ -n "$otel_col" ]; then
             sed -i "s|ghcr.io/open-telemetry/opentelemetry-collector-releases/opentelemetry-collector.*|ghcr.io/open-telemetry/opentelemetry-collector-releases/opentelemetry-collector:${otel_col}\"|g" observability.go
             fi

             # Updating observability nightly images with the actual tags for the release
             cd $GITHUB_WORKSPACE/samples
             for input_file in {storage_csm_powerflex_${pflex_driver_ver}.yaml,storage_csm_powermax_${pmax_driver_ver}.yaml,storage_csm_powerscale_${pscale_driver_ver}.yaml,storage_csm_powerstore_${pstore_driver_ver}.yaml};
               do
               sed -i "s|quay.io/dell/container-storage-modules/csm-topology.*|quay.io/dell/container-storage-modules/csm-topology:${topology}|g" $input_file
               if [ -n "$otel_col" ]; then
                sed -i "s|ghcr.io/open-telemetry/opentelemetry-collector-releases/opentelemetry-collector.*|ghcr.io/open-telemetry/opentelemetry-collector-releases/opentelemetry-collector:${otel_col}|g" $input_file
               fi
               if [[ "$input_file" == "storage_v1_csm_powerscale.yaml" ]]; then
                sed -i "s|quay.io/dell/container-storage-modules/csm-metrics-powerscale.*|quay.io/dell/container-storage-modules/csm-metrics-powerscale:${pscale_matrics}|g" $input_file
               fi
               if [[ "$input_file" == "storage_v1_csm_powermax.yaml" ]]; then
                  sed -i "s|quay.io/dell/container-storage-modules/csm-metrics-powermax.*|quay.io/dell/container-storage-modules/csm-metrics-powermax:${pmax_matrics}|g" $input_file
               fi
               if [[ "$input_file" == "storage_v1_csm_powerflex.yaml" ]]; then
                sed -i "s|quay.io/dell/container-storage-modules/csm-metrics-powerflex.*|quay.io/dell/container-storage-modules/csm-metrics-powerflex:${pflex_matrics}|g" $input_file
              fi
             done
             echo "Latest release tags are updated to Observability module"
          else
          echo "Observability Module config directory --> $obs_ver already exists. Skipping Observability module version update"
          fi
      else
          echo "Observability Module config directory --> $obs_ver doesn't exists. Proceeding to update Observability module version"

          # observability moduleconfig update to latest
          cd $GITHUB_WORKSPACE/operatorconfig/moduleconfig/observability/
          dir_to_del=$(ls -d */ | sort -V | head -1)
          dir_to_copy=$(ls -d */ | sort -V | tail -1)
          cp -r $dir_to_copy $obs_ver
          rm -rf $dir_to_del

          # Update latest versions of different metrics and topology
          cd $obs_ver
          sed -i "s|quay.io/dell/container-storage-modules/csm-metrics-powerflex.*|quay.io/dell/container-storage-modules/csm-metrics-powerflex:nightly|g" karavi-metrics-powerflex.yaml
          sed -i "s|quay.io/dell/container-storage-modules/csm-metrics-powermax.*|quay.io/dell/container-storage-modules/csm-metrics-powermax:nightly|g" karavi-metrics-powermax.yaml
          sed -i "s|quay.io/dell/container-storage-modules/csm-metrics-powerscale.*|quay.io/dell/container-storage-modules/csm-metrics-powerscale:nightly|g" karavi-metrics-powerscale.yaml
          sed -i "s|quay.io/dell/container-storage-modules/csm-topology.*|quay.io/dell/container-storage-modules/csm-topology:nightly|g" karavi-topology.yaml

          cd $GITHUB_WORKSPACE/bundle/manifests
          input_file="dell-csm-operator.clusterserviceversion.yaml"
          search_string_1="  - image: quay.io/dell/container-storage-modules/csm-topology"
          search_string_2="\"image\": \"quay.io/dell/container-storage-modules/csm-topology"
          search_string_3="value: quay.io/dell/container-storage-modules/csm-topology"
          new_line_1="   - image: quay.io/dell/container-storage-modules/csm-topology:$topology"
          new_line_2="                   \"image\": \"quay.io/dell/container-storage-modules/csm-topology:${topology}\","
          new_line_3="                       value: quay.io/dell/container-storage-modules/csm-topology:$topology"

          search_string_4="  - image: quay.io/dell/container-storage-modules/csm-metrics-powerscale"
          search_string_5="\"image\": \"quay.io/dell/container-storage-modules/csm-metrics-powerscale"
          search_string_6="value: quay.io/dell/container-storage-modules/csm-metrics-powerscale"
          new_line_4="   - image: quay.io/dell/container-storage-modules/csm-metrics-powerscale:$pscale_matrics"
          new_line_5="                   \"image\": \"quay.io/dell/container-storage-modules/csm-metrics-powerscale:${pscale_matrics}\","
          new_line_6="                       value: quay.io/dell/container-storage-modules/csm-metrics-powerscale:$pscale_matrics"

          search_string_7="  - image: quay.io/dell/container-storage-modules/csm-metrics-powermax"
          search_string_8="\"image\": \"quay.io/dell/container-storage-modules/csm-metrics-powermax"
          search_string_9="value: quay.io/dell/container-storage-modules/csm-metrics-powermax"
          new_line_7="   - image: quay.io/dell/container-storage-modules/csm-metrics-powermax:$pmax_matrics"
          new_line_8="                   \"image\": \"quay.io/dell/container-storage-modules/csm-metrics-powermax:${pmax_matrics}\","
          new_line_9="                       value: quay.io/dell/container-storage-modules/csm-metrics-powermax:$pmax_matrics"

          search_string_10="  - image: quay.io/dell/container-storage-modules/csm-metrics-powerflex"
          search_string_11="\"image\": \"quay.io/dell/container-storage-modules/csm-metrics-powerflex"
          search_string_12="value: quay.io/dell/container-storage-modules/csm-metrics-powerflex"
          new_line_10="   - image: quay.io/dell/container-storage-modules/csm-metrics-powerflex:$pflex_matrics"
          new_line_11="                   \"image\": \"quay.io/dell/container-storage-modules/csm-metrics-powerflex:${pflex_matrics}\","
          new_line_12="                       value: quay.io/dell/container-storage-modules/csm-metrics-powerflex:$pflex_matrics"

          search_string_13="  - image: docker.io/otel/opentelemetry-collector"
          search_string_14="\"image\": \"docker.io/otel/opentelemetry-collector"
          search_string_15="value: docker.io/otel/opentelemetry-collector"
          new_line_13="   - image: docker.io/otel/opentelemetry-collector:$otel_col"
          new_line_14="                   \"image\": \"docker.io/otel/opentelemetry-collector:${otel_col}\","
          new_line_15="                       value: docker.io/otel/opentelemetry-collector:$otel_col"

          line_number=0
          while IFS= read -r line; do
             line_number=$((line_number + 1))
             if [[ "$line" == *"$search_string_1"* ]]; then
                 sed -i "$line_number c\ $new_line_1" "$input_file"
             fi
             if [[ "$line" == *"$search_string_2"* ]]; then
                 sed -i "$line_number c\ $new_line_2" "$input_file"
             fi
             if [[ "$line" == *"$search_string_3"* ]]; then
                 sed -i "$line_number c\ $new_line_3" "$input_file"
             fi
             if [[ "$line" == *"$search_string_4"* ]]; then
                 sed -i "$line_number c\ $new_line_4" "$input_file"
             fi
             if [[ "$line" == *"$search_string_5"* ]]; then
                 sed -i "$line_number c\ $new_line_5" "$input_file"
             fi
             if [[ "$line" == *"$search_string_6"* ]]; then
                 sed -i "$line_number c\ $new_line_6" "$input_file"
             fi
             if [[ "$line" == *"$search_string_7"* ]]; then
                 sed -i "$line_number c\ $new_line_7" "$input_file"
             fi
             if [[ "$line" == *"$search_string_8"* ]]; then
                 sed -i "$line_number c\ $new_line_8" "$input_file"
             fi
             if [[ "$line" == *"$search_string_9"* ]]; then
                 sed -i "$line_number c\ $new_line_9" "$input_file"
             fi
             if [[ "$line" == *"$search_string_10"* ]]; then
                 sed -i "$line_number c\ $new_line_10" "$input_file"
             fi
             if [[ "$line" == *"$search_string_11"* ]]; then
                 sed -i "$line_number c\ $new_line_11" "$input_file"
             fi
             if [[ "$line" == *"$search_string_12"* ]]; then
                 sed -i "$line_number c\ $new_line_12" "$input_file"
             fi
             if [[ "$line" == *"$search_string_13"* ]]; then
                 sed -i "$line_number c\ $new_line_13" "$input_file"
             fi
             if [[ "$line" == *"$search_string_14"* ]]; then
                 sed -i "$line_number c\ $new_line_14" "$input_file"
             fi
             if [[ "$line" == *"$search_string_15"* ]]; then
                 sed -i "$line_number c\ $new_line_15" "$input_file"
             fi
          done <"$input_file"

          search_string1="quay.io/dell/container-storage-modules/csm-metrics-"
          search_string2="metrics-"
          newver="$obs_ver"
          line_number=0
          tmp_line=0
          while IFS= read -r line
             do
               line_number=$((line_number+1))
               if [[ "$line" == *"$search_string1"* ]] && [[ "$line" != *"value"*  ]] ; then
                  IFS= read -r next_line
                    if [[ "$next_line" == *"$search_string2"* ]]; then
                        line_number_tmp=$((line_number+4+tmp_line))
                        tmp_line=$((tmp_line+1))
                        data=$(sed -n "${line_number_tmp}p" "$input_file")
                           if [[ "$data" == *"configVersion"* ]]; then
                              sed -i "$line_number_tmp s/.*/                \"configVersion\": \"$newver\",/" "$input_file"
                           fi
                    fi
               fi
             done < "$input_file"

          cd $GITHUB_WORKSPACE/config/manager
          file_to_be_updated="manager.yaml"
           sed -i "s|quay.io/dell/container-storage-modules/csm-topology.*|quay.io/dell/container-storage-modules/csm-topology:${topology}|g" $file_to_be_updated
           sed -i "s|quay.io/dell/container-storage-modules/csm-metrics-powerscale.*|quay.io/dell/container-storage-modules/csm-metrics-powerscale:${pscale_matrics}|g" $file_to_be_updated
           sed -i "s|quay.io/dell/container-storage-modules/csm-metrics-powermax.*|quay.io/dell/container-storage-modules/csm-metrics-powermax:${pmax_matrics}|g" $file_to_be_updated
           sed -i "s|quay.io/dell/container-storage-modules/csm-metrics-powerflex.*|quay.io/dell/container-storage-modules/csm-metrics-powerflex:${pflex_matrics}|g" $file_to_be_updated
           if [ -n "$otel_col" ]; then
              sed -i "s|ghcr.io/open-telemetry/opentelemetry-collector-releases/opentelemetry-collector.*|ghcr.io/open-telemetry/opentelemetry-collector-releases/opentelemetry-collector:${otel_col}|g" $file_to_be_updated
           fi

          cd $GITHUB_WORKSPACE/config/manifests/bases
          file_to_be_updated="dell-csm-operator.clusterserviceversion.yaml"
          sed -i "s|quay.io/dell/container-storage-modules/csm-topology.*|quay.io/dell/container-storage-modules/csm-topology:${topology}|g" $file_to_be_updated
          sed -i "s|quay.io/dell/container-storage-modules/csm-metrics-powerscale.*|quay.io/dell/container-storage-modules/csm-metrics-powerscale:${pscale_matrics}|g" $file_to_be_updated
          sed -i "s|quay.io/dell/container-storage-modules/csm-metrics-powermax.*|quay.io/dell/container-storage-modules/csm-metrics-powermax:${pmax_matrics}|g" $file_to_be_updated
          sed -i "s|quay.io/dell/container-storage-modules/csm-metrics-powerflex.*|quay.io/dell/container-storage-modules/csm-metrics-powerflex:${pflex_matrics}|g" $file_to_be_updated
          if [ -n "$otel_col" ]; then
             sed -i "s|ghcr.io/open-telemetry/opentelemetry-collector-releases/opentelemetry-collector.*|ghcr.io/open-telemetry/opentelemetry-collector-releases/opentelemetry-collector:${otel_col}|g" $file_to_be_updated
          fi

          cd $GITHUB_WORKSPACE/config/samples
          for input_file in {storage_v1_csm_powerflex.yaml,storage_v1_csm_powermax.yaml,storage_v1_csm_powerscale.yaml};
          do
             search_string1="name: observability"
             search_string2="enabled"
             newver="$obs_ver"
             line_number=0
             tmp_line=0
             while IFS= read -r line
                do
                  line_number=$((line_number+1))
                  if [[ "$line" == *"$search_string1"* ]] ; then
                     IFS= read -r next_line
                     if [[ "$next_line" == *"$search_string2"* ]]; then
                        line_number_tmp=$((line_number+4+tmp_line))
                        tmp_line=$((tmp_line+1))
                        data=$(sed -n "${line_number_tmp}p" "$input_file")
                        if [[ "$data" == *"configVersion"* ]]; then
                           sed -i "$line_number_tmp s/.*/      configVersion: $newver/" "$input_file"
                        fi
                     fi
                  fi
             done < "$input_file"

             sed -i "s|quay.io/dell/container-storage-modules/csm-topology.*|quay.io/dell/container-storage-modules/csm-topology:${topology}|g" $input_file
             if [ -n "$otel_col" ]; then
                sed -i "s|docker.io/otel/opentelemetry-collector.*|docker.io/otel/opentelemetry-collector:${otel_col}|g" $input_file
             fi
             if [[ "$input_file" == "storage_v1_csm_powerscale.yaml" ]]; then
                sed -i "s|quay.io/dell/container-storage-modules/csm-metrics-powerscale.*|quay.io/dell/container-storage-modules/csm-metrics-powerscale:${pscale_matrics}|g" $input_file
             fi
             if [[ "$input_file" == "storage_v1_csm_powermax.yaml" ]]; then
                sed -i "s|quay.io/dell/container-storage-modules/csm-metrics-powermax.*|quay.io/dell/container-storage-modules/csm-metrics-powermax:${pmax_matrics}|g" $input_file
             fi
             if [[ "$input_file" == "storage_v1_csm_powerflex.yaml" ]]; then
                sed -i "s|quay.io/dell/container-storage-modules/csm-metrics-powerflex.*|quay.io/dell/container-storage-modules/csm-metrics-powerflex:${pflex_matrics}|g" $input_file
             fi
          done

          cd $GITHUB_WORKSPACE/deploy
          file_to_be_updated="operator.yaml"
          sed -i "s|quay.io/dell/container-storage-modules/csm-topology.*|quay.io/dell/container-storage-modules/csm-topology:${topology}|g" $file_to_be_updated
          sed -i "s|quay.io/dell/container-storage-modules/csm-metrics-powerscale.*|quay.io/dell/container-storage-modules/csm-metrics-powerscale:${pscale_matrics}|g" $file_to_be_updated
          sed -i "s|quay.io/dell/container-storage-modules/csm-metrics-powermax.*|quay.io/dell/container-storage-modules/csm-metrics-powermax:${pmax_matrics}|g" $file_to_be_updated
          sed -i "s|quay.io/dell/container-storage-modules/csm-metrics-powerflex.*|quay.io/dell/container-storage-modules/csm-metrics-powerflex:${pflex_matrics}|g" $file_to_be_updated
          if [ -n "$otel_col" ]; then
             sed -i "s|ghcr.io/open-telemetry/opentelemetry-collector-releases/opentelemetry-collector.*|ghcr.io/open-telemetry/opentelemetry-collector-releases/opentelemetry-collector:${otel_col}|g" $file_to_be_updated
          fi

      echo "before line number -->286"
      ls
      pwd
          # Update detailed samples
          cd $GITHUB_WORKSPACE/samples
          for input_file in {storage_csm_powerflex_${pflex_driver_ver}.yaml,storage_csm_powermax_${pmax_driver_ver}.yaml,storage_csm_powerscale_${pscale_driver_ver}.yaml,storage_csm_powerstore_${pstore_driver_ver}.yaml};
          do
             search_string1="name: observability"
             search_string2="enabled"
             newver="$obs_ver"
             line_number=0
             tmp_line=0
             while IFS= read -r line
                do
                  line_number=$((line_number+1))
                  if [[ "$line" == *"$search_string1"* ]] ; then
                     IFS= read -r next_line
                     if [[ "$next_line" == *"$search_string2"* ]]; then
                        line_number_tmp=$((line_number+4+tmp_line))
                        tmp_line=$((tmp_line+1))
                        data=$(sed -n "${line_number_tmp}p" "$input_file")
                        if [[ "$data" == *"configVersion"* ]]; then
                           sed -i "$line_number_tmp s/.*/      configVersion: $newver/" "$input_file"
                        fi
                     fi
                  fi
             done < "$input_file"
             pwd
echo "After line number -->309"
pwd
ls 
             sed -i "s|quay.io/dell/container-storage-modules/csm-topology.*|quay.io/dell/container-storage-modules/csm-topology:nightly|g" $input_file
             if [ -n "$otel_col" ]; then
                sed -i "s|ghcr.io/open-telemetry/opentelemetry-collector-releases/opentelemetry-collector.*|ghcr.io/open-telemetry/opentelemetry-collector-releases/opentelemetry-collector:${otel_col}|g" $input_file
             fi
             if [[ "$input_file" == "storage_v1_csm_powerscale.yaml" ]]; then
                sed -i "s|quay.io/dell/container-storage-modules/csm-metrics-powerscale.*|quay.io/dell/container-storage-modules/csm-metrics-powerscale:nightly|g" $input_file
             fi
             if [[ "$input_file" == "storage_v1_csm_powermax.yaml" ]]; then
                sed -i "s|quay.io/dell/container-storage-modules/csm-metrics-powermax.*|quay.io/dell/container-storage-modules/csm-metrics-powermax:nightly|g" $input_file
             fi
             if [[ "$input_file" == "storage_v1_csm_powerflex.yaml" ]]; then
                sed -i "s|quay.io/dell/container-storage-modules/csm-metrics-powerflex.*|quay.io/dell/container-storage-modules/csm-metrics-powerflex:nightly|g" $input_file
             fi
          done

          # Update testfiles
          cd $GITHUB_WORKSPACE/tests/e2e/testfiles
          for input_file in storage_csm* ;
          do
             search_string1="name: observability"
             search_string2="enabled"
             newver="$obs_ver"
             line_number=0
             tmp_line=0
             while IFS= read -r line
                do
                  line_number=$((line_number+1))
                  if [[ "$line" == *"$search_string1"* ]] ; then
                     IFS= read -r next_line
                     if [[ "$next_line" == *"$search_string2"* ]]; then
                        line_number_tmp=$((line_number+3+tmp_line))
                        tmp_line=$((tmp_line+1))
                        data=$(sed -n "${line_number_tmp}p" "$input_file")
                        if [[ "$data" == *"configVersion"* ]]; then
                           sed -i "$line_number_tmp s/.*/      configVersion: $newver/" "$input_file"
                        fi
                     fi
                  fi
             done < "$input_file"
             sed -i "s|quay.io/dell/container-storage-modules/csm-topology.*|quay.io/dell/container-storage-modules/csm-topology:nightly|g" $input_file
             if [ -n "$otel_col" ]; then
                sed -i "s|ghcr.io/open-telemetry/opentelemetry-collector-releases/opentelemetry-collector.*|ghcr.io/open-telemetry/opentelemetry-collector-releases/opentelemetry-collector:${otel_col}|g" $input_file
             fi
             if [[ "$input_file" == "storage_v1_csm_powerscale.yaml" ]]; then
                sed -i "s|quay.io/dell/container-storage-modules/csm-metrics-powerscale.*|quay.io/dell/container-storage-modules/csm-metrics-powerscale:nightly|g" $input_file
             fi
             if [[ "$input_file" == "storage_v1_csm_powermax.yaml" ]]; then
                sed -i "s|quay.io/dell/container-storage-modules/csm-metrics-powermax.*|quay.io/dell/container-storage-modules/csm-metrics-powermax:nightly|g" $input_file
             fi
             if [[ "$input_file" == "storage_v1_csm_powerflex.yaml" ]]; then
                sed -i "s|quay.io/dell/container-storage-modules/csm-metrics-powerflex.*|quay.io/dell/container-storage-modules/csm-metrics-powerflex:nightly|g" $input_file
             fi
          done

          # Update pkg/modules/testdata
          cd $GITHUB_WORKSPACE/pkg/modules/testdata
          for input_file in cr_* ;
          do
             search_string1="name: observability"
             search_string2="enabled"
             newver="$obs_ver"
             line_number=0
             tmp_line=0
             while IFS= read -r line
                do
                  line_number=$((line_number+1))
                  if [[ "$line" == *"$search_string1"* ]] ; then
                     IFS= read -r next_line
                     if [[ "$next_line" == *"$search_string2"* ]]; then
                        line_number_tmp=$((line_number+3+tmp_line))
                        tmp_line=$((tmp_line+1))
                        data=$(sed -n "${line_number_tmp}p" "$input_file")
                        if [[ "$data" == *"configVersion"* ]]; then
                           sed -i "$line_number_tmp s/.*/      configVersion: $newver/" "$input_file"
                        fi
                     fi
                  fi
             done < "$input_file"
             sed -i "s|quay.io/dell/container-storage-modules/csm-topology.*|quay.io/dell/container-storage-modules/csm-topology:nightly|g" $input_file
             if [ -n "$otel_col" ]; then
                sed -i "s|ghcr.io/open-telemetry/opentelemetry-collector-releases/opentelemetry-collector.*|ghcr.io/open-telemetry/opentelemetry-collector-releases/opentelemetry-collector:${otel_col}|g" $input_file
             fi
             if [[ "$input_file" == "storage_v1_csm_powerscale.yaml" ]]; then
                sed -i "s|quay.io/dell/container-storage-modules/csm-metrics-powerscale.*|quay.io/dell/container-storage-modules/csm-metrics-powerscale:nightly|g" $input_file
             fi
             if [[ "$input_file" == "storage_v1_csm_powermax.yaml" ]]; then
                sed -i "s|quay.io/dell/container-storage-modules/csm-metrics-powermax.*|quay.io/dell/container-storage-modules/csm-metrics-powermax:nightly|g" $input_file
             fi
             if [[ "$input_file" == "storage_v1_csm_powerflex.yaml" ]]; then
                sed -i "s|quay.io/dell/container-storage-modules/csm-metrics-powerflex.*|quay.io/dell/container-storage-modules/csm-metrics-powerflex:nightly|g" $input_file
             fi
          done
          echo "Observability Module config --> $obs_ver updated successfully"
      fi
fi
# <<<< Observability module update complete >>>>

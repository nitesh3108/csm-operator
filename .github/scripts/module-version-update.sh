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

obs_ver="$(echo -e "${obs_ver}" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"
auth_v2="$(echo -e "${auth_v2}" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"
rep_ver="$(echo -e "${rep_ver}" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"
res_ver="$(echo -e "${res_ver}" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"
revproxy_ver="$(echo -e "${revproxy_ver}" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"
csm_ver="$(echo -e "${csm_ver}" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"
pscale_matrics="$(echo -e "${pscale_matrics}" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"
pflex_matrics="$(echo -e "${pflex_matrics}" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"
pmax_matrics="$(echo -e "${pmax_matrics}" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"
topology="$(echo -e "${topology}" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"
otel_col="$(echo -e "${otel_col}" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"
dell_csi_replicator="$(echo -e "${dell_csi_replicator}" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"
dell_replication_controller="$(echo -e "${dell_replication_controller}" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"

pscale_driver_ver=${pscale_driver_ver//./}
pstore_driver_ver=${pstore_driver_ver//./}
pmax_driver_ver=${pmax_driver_ver//./}
pflex_driver_ver=${pflex_driver_ver//./}

pscale_driver_ver="$(echo -e "${pscale_driver_ver}" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"
pstore_driver_ver="$(echo -e "${pstore_driver_ver}" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"
pmax_driver_ver="$(echo -e "${pmax_driver_ver}" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"
pflex_driver_ver="$(echo -e "${pflex_driver_ver}" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"

auth_v2_samples_format=${auth_v2//./}

input_csm_ver="$1"
update_flag="$2"
input_csm_ver="$(echo -e "${input_csm_ver}" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"
update_flag="$(echo -e "${update_flag}" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"


echo "obs_ver --> $obs_ver"
echo "auth_v2 --> $auth_v2"
echo "rep_ver --> $rep_ver"
echo "res_ver --> $res_ver"
echo "revproxy_ver --> $revproxy_ver"
echo "csm_ver --> $csm_ver"
echo "pscale_matrics --> $pscale_matrics"
echo "pflex_matrics --> $pflex_matrics"
echo "pmax_matrics --> $pmax_matrics"
echo "topology --> $topology"
echo "otel_col --> $otel_col"
echo "pscale_driver_ver --> $pscale_driver_ver"
echo "pstore_driver_ver --> $pstore_driver_ver"
echo "pmax_driver_ver --> $pmax_driver_ver"
echo "pflex_driver_ver --> $pflex_driver_ver"
echo "dell_csi_replicator --> $dell_csi_replicator"
echo "dell_replication_controller --> $dell_replication_controller"

echo "input_csm_ver --> $input_csm_ver"
echo "update_flag --> $update_flag"

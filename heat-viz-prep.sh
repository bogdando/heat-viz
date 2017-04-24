#!/bin/bash
# Prepare repos by URL/path, generate tht from jinja and process graphs
set -ue -o pipefail

# Default repo paths, filter and decor for graphs
HEAT_VIZ_PATH=${HEAT_VIZ_PATH:-none}
THT_PATH=${THT_PATH:-none}
FILTER=${FILTER:-'.*'}
DECOR=${DECOR:-'pre[^p],post,batch,prep,step1,step2,step3,step4,step5,step6,upgrade,docker'}

# Clone or prepare repos
if [[ "${THT_PATH}" =~ "http:" ]]; then
  git clone --depth 20 ${THT_PATH}
  THT_PATH=$(pwd)/tripleo-heat-templates
elif [ ${THT_PATH} != "none" ]; then
  git -C ${THT_PATH} stash
  git -C ${THT_PATH} clean -fd
else
  git clone --depth 20 https://git.openstack.org/openstack/tripleo-heat-templates.git
  THT_PATH=$(pwd)/tripleo-heat-templates
fi

if [[ "${HEAT_VIZ_PATH}" =~ "http:" ]]; then
  git clone --depth 20 ${HEAT_VIZ_PATH}
  HEAT_VIZ_PATH=$(pwd)/heat-viz
elif [ ${HEAT_VIZ_PATH} != "none" ]; then
  git -C ${HEAT_VIZ_PATH} stash
  git -C ${HEAT_VIZ_PATH} clean -fd
else
  git clone --depth 20 https://github.com/bogdando/heat-viz.git
  HEAT_VIZ_PATH=$(pwd)/heat-viz
fi

# Generate overcloud/undercloud templates
mkdir -p ${HEAT_VIZ_PATH}/{undercloud,overcloud}
cd ${THT_PATH}
# w/a -o doesn't work
python ./tools/process-templates.py -r roles_data.yaml
git ls-files -o --exclude-standard | xargs -n1 -I {} rsync -avxHR {} ${HEAT_VIZ_PATH}/overcloud/
git clean -fd
python ./tools/process-templates.py -r roles_data_undercloud.yaml
git ls-files -o --exclude-standard | xargs -n1 -I {} rsync -avxHR {} ${HEAT_VIZ_PATH}/undercloud/
git clean -fd

# Generate graphs
cd ${HEAT_VIZ_PATH}
set +e
for f in $(git ls-files -o --exclude-standard); do
  echo "####### Processing ${f} #######"
  prefix=$(echo $(dirname ${f}) | sed "s#/#_#g")
  fname="${prefix}_$(basename ${f})"
  ruby heat-viz.rb -f "${FILTER}" -d "${DECOR}" ${f} -o ${fname%.yaml}.html
done

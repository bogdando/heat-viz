heat-viz
========

GraphViz depiction of Heat dependencies.

Run with EG `ruby heat-viz.rb ../tripleo-heat-templates/overcloud.yaml` then
browse heat-deps.yaml.

The diagram is produced dynamically with viz.js (https://github.com/mdaines/viz.js/).

Both CFN and HOT format are handled but the dependency detection is very simple.
It does not handle resource groups or autoscaling at all.

Or run ``./heat-viz-prep.sh`` to just get things done (works only for t-h-t).

Requirements
------------

#TODO(bogdando) this should be somehow packaged/bundled/given a version ranges
* packages (RHEL/Centos): ncurses-devel, ncurses
* packages (Debian/Ubuntu): libncurses5-dev, libncursesw5-dev
* gems: curses, executable-hooks, gem-wrappers, mustache, json, deep_merge

Use with TripleO Heat Templates
-------------------------------

* Render existing Heat templates with ``tox -e templates``
* Alternatively, use the process-templates tool directly, for example:
```
./tools/process-templates.py -r roles_data.yaml
./tools/process-templates.py -r roles_data_undercloud.yaml
```
* Copy YAML templates under the heat-viz repo root
* Run ``ruby heat-viz.rb`` for a given template/filter/decors of your choice
* Alternatively, run it with merge mode ``-m undercloud`` or ``-m overcloud``.
  This depicts the whole picture, as if all of the templates' resources belonged
  to a single heat template.
#TODO(bogdando) nested stacks to be included and processed for merge mode

Filters
-------

The option `-f` allows to apply regex (case sensitive) filters for the names of
the graph nodes. Use your imagination!

Decors
------

Filtered graph nodes may be as well vizually differentiated and grouped
(decorated with colors) based on provided tags. Think of tags like roles or
types of deployment steps. Specify tags (accepts regexes, case insensitive) as
a comma separated list placed next to the `-d` option. Here are a few example
decors:

* swift,ceph,block
* puppet,docker,kolla
* prep,pre[^p],post,batch,upgrade,update,step1,step2,step3,step4,step5,step6
* controller,compute,storage,allnodes

The latter provides the default color scheme.

package cis_1_2_17

import data.lib.kubernetes

violation[msg] {
	kubernetes.containers[container]
  not kubernetes.flag_contains_string(container, "--enable-admission-plugins", "NodeRestriction")
	msg = kubernetes.format(sprintf("%s in the %s %s does not have --enable-admission-plugins NodeRestriction", [container.name, kubernetes.kind, kubernetes.name]))
}

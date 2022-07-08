helm upgrade wiki requarks/wiki \
--namespace wiki \
--set ingress.enabled=true \
--set ingress.className="nginx" \
--set ingress.hosts=[{"host": "wiki.andyg.io", "paths": ["/"]}] \
--set postgresql.enabled=false


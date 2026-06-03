import urllib.request, json
url = 'https://sonarcloud.io/api/issues/search?componentKeys=advprog-2026-A15-project_yomu-api-gateway'
data = json.loads(urllib.request.urlopen(url).read())
for i in data['issues']:
    print(f"[{i['type']}] {i['rule']} in {i['component']} at line {i.get('line', 'N/A')}: {i['message']}")

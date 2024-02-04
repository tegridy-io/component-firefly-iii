// main template for firefly-iii
local kap = import 'lib/kapitan.libjsonnet';
local kube = import 'lib/kube.libjsonnet';
local inv = kap.inventory();
// The hiera parameters for the component
local params = inv.parameters.firefly_iii;
local instanceName = inv.parameters._instance;
local appName = 'firefly-iii';
local hasPrometheus = std.member(inv.applications, 'prometheus');

local namespace = kube.Namespace(params.namespace.name) {
  //   metadata+: {
  //     labels+: {
  //       'pod-security.kubernetes.io/enforce': 'restricted',
  //     },
  //   },
};


// Secrets
local secrets = [
  kube.Secret('postgresql') {
    metadata+: {
      labels+: {
        'app.kubernetes.io/instance': instanceName,
        'app.kubernetes.io/managed-by': 'commodore',
        'app.kubernetes.io/name': 'postgresql',
      },
      namespace: params.namespace.name,
    },
    stringData: {
      'postgres-username': params.helmValues.postgresql.auth.username,
      'postgres-password': params.secrets.postgresql,
    },
  },
  kube.Secret(appName) {
    metadata+: {
      labels+: {
        'app.kubernetes.io/instance': instanceName,
        'app.kubernetes.io/managed-by': 'commodore',
        'app.kubernetes.io/name': appName,
      },
      namespace: params.namespace.name,
    },
    stringData: {
      APP_PASSWORD: params.secrets.firefly,
      DB_PASSWORD: params.secrets.postgresql,
      APP_TOKEN: params.secrets.token,
    },
  },
  kube.Secret(appName + '-app-key') {
    metadata+: {
      labels+: {
        'app.kubernetes.io/instance': instanceName,
        'app.kubernetes.io/managed-by': 'commodore',
        'app.kubernetes.io/name': appName,
      },
      namespace: params.namespace.name,
    },
    stringData: {
      APP_KEY: params.secrets.fireflyKey,
    },
  },
];

// Define outputs below
{
  '00_namespace': namespace,
  '20_secrets': secrets,
}

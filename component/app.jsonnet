local kap = import 'lib/kapitan.libjsonnet';
local inv = kap.inventory();
local params = inv.parameters.firefly_iii;
local argocd = import 'lib/argocd.libjsonnet';

local app = argocd.App('firefly-iii', params.namespace);

{
  'firefly-iii': app,
}

KustomizeInfo = provider(
    fields = ["bin"]
)

KustomizeDepInfo = provider(
    fields = ["out", "sources", "kustomization_yaml"]
)

KustomizationsInfo = provider(
    fields = ["kustomizations", "sources"]
)
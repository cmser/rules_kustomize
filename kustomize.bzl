load("//:providers.bzl", "KustomizeDepInfo", "KustomizationsInfo")

def _kustomize(ctx):
    kustomizations = [ctx.file.kustomization_yaml]
    sources = [] + ctx.files.srcs
    for dep in ctx.attr.deps:
        kustomizations += dep[KustomizationsInfo].kustomizations
        sources += dep[KustomizationsInfo].sources
    out = ctx.actions.declare_file("deployment.yaml")
    ctx.actions.run(
        inputs = kustomizations + sources,
        outputs = [out],
        executable = ctx.toolchains["@com_github_cmser_rules_kustomize//:toolchain_type"].KustomizeInfo.bin,
        arguments = [
            "build",
            "--load-restrictor", "LoadRestrictionsNone",
            ctx.file.kustomization_yaml.dirname,
            "--output",
            out.path
        ]
    )
    return [
        KustomizeDepInfo(
            kustomization_yaml = ctx.file.kustomization_yaml,
            sources = ctx.files.srcs
        ),
        DefaultInfo(
            files = depset([out])
        )
    ]

def _kustomize_aspect_impl(target, ctx):
    kustomizations = [ctx.rule.file.kustomization_yaml]
    sources = [] + ctx.rule.files.srcs
    for dep in ctx.rule.attr.deps:
        kustomizations += dep[KustomizationsInfo].kustomizations
        kustomizations.append(dep[KustomizeDepInfo].kustomization_yaml)

        sources += dep[KustomizeDepInfo].sources
        sources += dep[KustomizationsInfo].sources
    return [
        KustomizationsInfo(
            kustomizations = kustomizations,
            sources = sources
        )
    ]

kustomize_aspect = aspect(
    implementation = _kustomize_aspect_impl
)

kustomize = rule(
    implementation = _kustomize,
    toolchains = ["@com_github_cmser_rules_kustomize//:toolchain_type"],
    attrs = {
        "srcs": attr.label_list(allow_files = True, mandatory = True),
        "deps": attr.label_list(default = [], providers = [KustomizeDepInfo], aspects = [kustomize_aspect]),
        "kustomization_yaml": attr.label(allow_single_file = True, mandatory = True),
    }
)
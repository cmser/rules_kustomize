def _kustomize(ctx):
    binary = ctx.toolchains["@com_github_cmser_rules_kustomize//:toolchain_type"].KustomizeInfo.bin
    out = ctx.actions.declare_file("out")
    inputs = ctx.files.srcs + [ctx.file.kustomization_yaml]
    ctx.actions.run_shell(
        inputs = ctx.files.srcs + [ctx.file.kustomization_yaml],
        outputs = [out],
        command = "%s build --load-restrictor LoadRestrictionsNone %s > %s" % (binary.path, ctx.label.package, out.path),
        tools = [binary],
        use_default_shell_env = True
    )
    return [
        DefaultInfo(
            files = depset([out]),
            runfiles = ctx.runfiles(
                files = inputs
            )
        )
    ]

kustomize = rule(
    implementation = _kustomize,
    toolchains = ["@com_github_cmser_rules_kustomize//:toolchain_type"],
    attrs = {
        "srcs": attr.label_list(allow_files = True, mandatory = True),
        "kustomization_yaml": attr.label(allow_single_file = True, mandatory = True),
    }
)
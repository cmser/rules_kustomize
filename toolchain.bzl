load(":providers.bzl", "KustomizeInfo")

def _kustomize_toolchain_impl(ctx):
    return [
        platform_common.ToolchainInfo(
            KustomizeInfo = KustomizeInfo(
                bin = ctx.executable.bin,
            ),
        )
    ]

kustomize_toolchain = rule(
    implementation = _kustomize_toolchain_impl,
    attrs = {
        "bin": attr.label(allow_single_file = True, executable = True, cfg = "host"),
    },
)
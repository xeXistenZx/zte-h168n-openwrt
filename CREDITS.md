# Credits, provenance and AI transparency

## Human research and testing

This independent community hardware-enablement project is based on real experiments on a borrowed ZTE ZXHN H168N V3.5 / V3.5.2, including UART RAM boot, Ethernet DSA mapping, throughput and memory measurements, and USB device enumeration. The release's claims refer to the **recorded tests**, not to general device certification. The project's owner and contributors are responsible for reviewing and validating changes; AI assistants did not independently run the physical tests.

## Upstream work

- **OpenWrt** developers and contributors: build system, userspace, board support infrastructure and packages.
- **Linux kernel** developers: kernel and networking infrastructure.
- **CJ DeLisle**: [`econet_eth`](https://github.com/cjdelisle/econet_eth) out-of-tree Ethernet driver; alpha.1 uses pinned source revision `df20a0548c9142ef80ee613a81da90885b57e6c5`.
- Other contributors and reviewers: please credit specific patches and tested findings with commit links as they are contributed.

Attribution is **not** an endorsement of this experimental image by any upstream contributor.

## AI assistance disclosure

**ChatGPT (OpenAI)** and other AI assistants have been used as supporting tools during technical discussion, hypothesis generation, interpreting shared logs and outputs, suggesting test procedures and source changes, drafting commands, preparing documentation, and Arabic translation. AI suggestions can be wrong, incomplete or unsafe. Their use does not substitute for code review, evidence, testing, maintainer approval or secure flash recovery. Statements tagged **OBSERVED** are based on the human-operated test outputs recorded in the project, not on AI execution of a router experiment.

Please report incorrect explanations, attribution, missing citations, errors in generated scripts, unsafe instructions or reproducibility gaps through the repository issue tracker or a pull request.

See [CONTRIBUTING.md](CONTRIBUTING.md), [evidence register](docs/H168N-EVIDENCE-REGISTER.md), and [alpha.1 validation](docs/releases/v0.2.0-alpha.1-validation.md).

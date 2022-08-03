{
  description = "Goldstein's flake templates";
  outputs = { self }: {
    shell = {
      path = ./shell;
      description = "When you only need devShell";
    };
    rust = {
      path = ./rust;
      description = "Rust binary";
    };
    rust-systemd = {
      path = ./rust-systemd;
      description = "Rust binary + systemd service";
    };
    rust-shell = {
      path = ./rust-shell;
      description = "devShell with rust + cargo";
    };
    defaultTemplate = self.shell;
  };
}

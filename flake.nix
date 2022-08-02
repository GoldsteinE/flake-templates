{
  description = "Goldstein's flake templates";
  outputs = { self }: {
    shell = {
      path = ./shell;
      description = "When you only need devShell";
    };
    defaultTemplate = self.shell;
  };
}

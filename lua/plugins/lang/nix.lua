return {
	{
		"nvim-lspconfig",
		opts = {
			servers = {
				nixd = {
					enabled = true,
					cmd = { "nixd", "--semantic-tokens=true" },
					settings = {
						nixd = {
							nixpkgs = {
								expr = "import <nixpkgs> { }",
							},
							formatting = {
								command = { "nixfmt" },
							},
							options = {
								["nix-darwin"] = {
									expr = [[(builtins.getFlake  ("git+file://" + toString ./.)).darwinConfigurations.Isaacs-MacBook-Pro.options]],
								},
								nixos = {
									expr = [[(builtins.getFlake  ("git+file://" + toString ./.)).nixosConfigurations.Isaac-NixOS.options]],
								},
								["home-manager"] = {
									expr = '(builtins.getFlake  ("git+file://" + toString ./.)).darwinConfigurations.Isaacs-MacBook-Pro.options.home-manager.users.type.getSubOptions []',
								},
							},
						},
					},
				},
			},
		},
	},
	{
		"conform.nvim",
		opts = {
			formatters_by_ft = {
				nix = { "nixfmt" },
			},
		},
	},
}

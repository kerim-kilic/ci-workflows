# The bundled Terraform ruleset only, so the self-test downloads no plugins.
plugin "terraform" {
  enabled = true
  preset  = "recommended"
}

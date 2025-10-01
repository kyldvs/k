# Main execution
main() {
  check_config
  configure_termux_properties
  configure_termux_colors
  configure_termux_font
  install_packages
  init_profile
  install_proot_distro
  install_alpine
  install_doppler_alpine
  create_doppler_wrapper
  check_doppler_auth
  retrieve_ssh_keys
  generate_ssh_config
  test_ssh_connection
  show_next_steps
}

main

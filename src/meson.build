sources = files(
  'application.vala',
  'header.vala',
  'helpers.vala',
  'keys.vala',
  'maybe_empty_box.vala',
  'pages.vala',
  'pages_container.vala',
  'scrolly_area.vala',
)

dependencies = [
  meson.get_compiler('vala').find_library('linux'),
  dependency('glib-2.0'),
  dependency('gtk4'),
  meson.get_compiler('c').find_library('m'),
]

fabric_ui_lib = shared_library(
  meson.project_name(),
  [resources, sources],
  dependencies: dependencies,
  install: true,
  install_dir: [true, true, true]
)

fabric_ui_dep = declare_dependency(
  link_with: fabric_ui_lib,
  include_directories: include_directories('.'),
)

pkgg = import('pkgconfig')
pkgg.generate(
  libraries: fabric_ui_lib,
  version: meson.project_version(),
  name: meson.project_name(),
  description: 'Building blocks for Fabric Desktop',
)
